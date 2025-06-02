#!/bin/bash
set -e

# Script to install Windsurf rules from this project to a target project directory.

# --- Configuration ---
SOURCE_PROJECT_DIR=$(pwd)
SOURCE_RULES_DIR_RELATIVE="windsurf/rules"
SOURCE_WINDSURFIGNORE_RELATIVE=".windsurfignore" # Assumed to be at the root of SOURCE_PROJECT_DIR

SOURCE_RULES_DIR="$SOURCE_PROJECT_DIR/$SOURCE_RULES_DIR_RELATIVE"
SOURCE_WINDSURFIGNORE="$SOURCE_PROJECT_DIR/$SOURCE_WINDSURFIGNORE_RELATIVE"
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# --- Functions ---
print_usage() {
  echo "Usage: $0 <target_project_directory>"
  echo "Example: $0 ../my-other-project"
}

add_to_ignore_file() {
  local file_path="$1"
  local entry="$2"
  if [ -f "$file_path" ]; then
    grep -qxF "$entry" "$file_path" || echo "$entry" >> "$file_path"
  else
    echo "$entry" > "$file_path"
  fi
}

# --- Input Validation ---
if [ "$#" -ne 1 ]; then
  echo "Error: Target project directory not specified."
  print_usage
  exit 1
fi

TARGET_PROJECT_DIR="$1"

if [ ! -d "$TARGET_PROJECT_DIR" ]; then
  echo "Error: Target project directory '$TARGET_PROJECT_DIR' does not exist or is not a directory."
  exit 1
fi
echo "Target project directory: $TARGET_PROJECT_DIR"

# Convert target project dir to absolute path for robustness
TARGET_PROJECT_DIR=$(cd "$TARGET_PROJECT_DIR" && pwd)
echo "Absolute target project directory: $TARGET_PROJECT_DIR"

GITIGNORE_FILE="$TARGET_PROJECT_DIR/.gitignore"
DOCKERIGNORE_FILE="$TARGET_PROJECT_DIR/.dockerignore"

# --- Backup Directory Setup ---
TARGET_BACKUP_DIR_ABSOLUTE="$TARGET_PROJECT_DIR/.windsurf.back"
TARGET_BACKUP_RULES_DIR_ABSOLUTE="$TARGET_BACKUP_DIR_ABSOLUTE/rules" # For individual rule file backups
echo ""
echo "--- Setting up Windsurf backup directory ---"
mkdir -p "$TARGET_BACKUP_RULES_DIR_ABSOLUTE"
echo "Ensured Windsurf backup directory exists: $TARGET_BACKUP_RULES_DIR_ABSOLUTE"
add_to_ignore_file "$GITIGNORE_FILE" "/.windsurf.back/"
echo "Added '/.windsurf.back/' to $GITIGNORE_FILE to ignore all Windsurf backups within this directory."

# --- Processing Windsurf Rules ---
echo ""
echo "--- Processing Windsurf rule files ---"
TARGET_DOT_WINDSURF_DIR_ABSOLUTE="$TARGET_PROJECT_DIR/.windsurf"
TARGET_RULES_DIR_IN_DOT_WINDSURF="$TARGET_DOT_WINDSURF_DIR_ABSOLUTE/rules"
mkdir -p "$TARGET_RULES_DIR_IN_DOT_WINDSURF"
echo "Ensured target Windsurf rules directory exists: $TARGET_RULES_DIR_IN_DOT_WINDSURF"

if [ -d "$SOURCE_RULES_DIR" ]; then
  shopt -s nullglob # Handle case with no files in source rules dir
  for source_rule_file in "$SOURCE_RULES_DIR"/*; do
    if [ -f "$source_rule_file" ]; then # Ensure it's a file
      rule_name=$(basename "$source_rule_file")
      target_rule_path="$TARGET_RULES_DIR_IN_DOT_WINDSURF/$rule_name"
      relative_target_rule_path_for_ignore=".windsurf/rules/$rule_name" # Relative to target project root

      echo ""
      echo "Processing Windsurf rule: $rule_name"

      # 1. Backup old existing file (if it's a real file, not a symlink)
      if [ -f "$target_rule_path" ] && [ ! -L "$target_rule_path" ]; then
        backup_file_path="$TARGET_BACKUP_RULES_DIR_ABSOLUTE/$rule_name.$TIMESTAMP"
        mv "$target_rule_path" "$backup_file_path"
        echo "Backed up existing Windsurf rule '$target_rule_path' to '$backup_file_path'"
        # Gitignore for the entire .windsurf.back/ directory is handled earlier
        # DO NOT add rule backup to .dockerignore

        # 2. Remove it from git (if it was a real file and presumably tracked)
        (cd "$TARGET_PROJECT_DIR" && git rm --cached ".windsurf/rules/$rule_name" > /dev/null 2>&1 || true)
        echo "Attempted to remove '.windsurf/rules/$rule_name' from git index in target project."
      elif [ -L "$target_rule_path" ]; then
        echo "Existing Windsurf rule '$target_rule_path' is a symlink. It will be replaced."
      fi
      
      # 3. Add the file (symlink path) to .gitignore
      add_to_ignore_file "$GITIGNORE_FILE" "/$relative_target_rule_path_for_ignore"
      echo "Added '$relative_target_rule_path_for_ignore' to $GITIGNORE_FILE"

      # 4. Create symbolic link
      absolute_source_rule_path=$(realpath "$source_rule_file")
      ln -sf "$absolute_source_rule_path" "$target_rule_path"
      echo "Linked Windsurf rule: $target_rule_path -> $absolute_source_rule_path"
    fi
  done
  shopt -u nullglob
else
  echo "Warning: Source Windsurf rules directory '$SOURCE_RULES_DIR' not found. No rules will be linked."
fi

# --- Processing .windsurfignore ---
echo ""
echo "--- Processing .windsurfignore file (if it exists) ---"
TARGET_WINDSURFIGNORE_ABSOLUTE="$TARGET_PROJECT_DIR/.windsurfignore"
RELATIVE_TARGET_WINDSURFIGNORE_FOR_IGNORE=".windsurfignore" # Relative to target project root

if [ -f "$SOURCE_WINDSURFIGNORE" ]; then
  # 1. Backup old existing file
  if [ -f "$TARGET_WINDSURFIGNORE_ABSOLUTE" ] && [ ! -L "$TARGET_WINDSURFIGNORE_ABSOLUTE" ]; then
    backup_windsurfignore_file_path="$TARGET_BACKUP_DIR_ABSOLUTE/.windsurfignore.$TIMESTAMP"
    mv "$TARGET_WINDSURFIGNORE_ABSOLUTE" "$backup_windsurfignore_file_path"
    echo "Backed up existing '$TARGET_WINDSURFIGNORE_ABSOLUTE' to '$backup_windsurfignore_file_path'"
    # Gitignore for the entire .windsurf.back/ directory is handled earlier

    # 2. Remove it from git
    (cd "$TARGET_PROJECT_DIR" && git rm --cached "$RELATIVE_TARGET_WINDSURFIGNORE_FOR_IGNORE" > /dev/null 2>&1 || true)
    echo "Attempted to remove '$RELATIVE_TARGET_WINDSURFIGNORE_FOR_IGNORE' from git index in target project."
  elif [ -L "$TARGET_WINDSURFIGNORE_ABSOLUTE" ]; then
    echo "Existing '$TARGET_WINDSURFIGNORE_ABSOLUTE' is a symlink. It will be replaced."
  fi

  # 3. Add the file to .gitignore / .dockerignore
  add_to_ignore_file "$GITIGNORE_FILE" "/$RELATIVE_TARGET_WINDSURFIGNORE_FOR_IGNORE"
  echo "Added '$RELATIVE_TARGET_WINDSURFIGNORE_FOR_IGNORE' to $GITIGNORE_FILE"
  add_to_ignore_file "$DOCKERIGNORE_FILE" "$RELATIVE_TARGET_WINDSURFIGNORE_FOR_IGNORE" # Add .windsurfignore itself
  echo "Added '$RELATIVE_TARGET_WINDSURFIGNORE_FOR_IGNORE' to $DOCKERIGNORE_FILE"
  
  # 4. Create symbolic link
  absolute_source_windsurfignore_path=$(realpath "$SOURCE_WINDSURFIGNORE")
  ln -sf "$absolute_source_windsurfignore_path" "$TARGET_WINDSURFIGNORE_ABSOLUTE"
  echo "Linked: $TARGET_WINDSURFIGNORE_ABSOLUTE -> $absolute_source_windsurfignore_path"
else
  echo "Source '$SOURCE_WINDSURFIGNORE' not found. Not linking .windsurfignore."
fi

# --- General .gitignore/.dockerignore updates for Windsurf ---
echo ""
echo "--- General .gitignore/.dockerignore updates for Windsurf ---"
# Ensure .windsurf/ (parent of rules) is in .dockerignore (if not covered by .windsurf/rules/ specific ignore)
# This is more about ignoring the whole .windsurf directory if it contains other things not symlinked.
# However, individual rule files are already added to .gitignore. The .windsurf/rules/ dir itself is not ignored in .gitignore.
add_to_ignore_file "$DOCKERIGNORE_FILE" ".windsurf/" # This will ignore the .windsurf/rules directory and .windsurf/.windsurfignore (if it were placed inside .windsurf)
echo "Added '.windsurf/' to $DOCKERIGNORE_FILE to cover the rules directory and any other content."

echo ""
echo "--- Windsurf rules installation complete! ---"
echo "Please review the changes in '$GITIGNORE_FILE' and '$DOCKERIGNORE_FILE'."
echo "Remember to commit these ignore file changes in the target project."
