#!/bin/bash
set -e

# Script to install Cursor rules from this project to a target project directory.

# --- Configuration ---
SOURCE_PROJECT_DIR=$(pwd)
SOURCE_RULES_DIR_RELATIVE="cursor/rules"
SOURCE_CURSORIGNORE_RELATIVE=".cursorignore"

SOURCE_RULES_DIR="$SOURCE_PROJECT_DIR/$SOURCE_RULES_DIR_RELATIVE"
SOURCE_CURSORIGNORE="$SOURCE_PROJECT_DIR/$SOURCE_CURSORIGNORE_RELATIVE"
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
TARGET_BACKUP_DIR_ABSOLUTE="$TARGET_PROJECT_DIR/.cursor.back"
TARGET_BACKUP_RULES_DIR_ABSOLUTE="$TARGET_BACKUP_DIR_ABSOLUTE/rules" # For individual rule file backups
echo ""
echo "--- Setting up backup directory ---"
mkdir -p "$TARGET_BACKUP_RULES_DIR_ABSOLUTE" # This also creates TARGET_BACKUP_DIR_ABSOLUTE if it doesn't exist
echo "Ensured backup directory exists: $TARGET_BACKUP_RULES_DIR_ABSOLUTE"
add_to_ignore_file "$GITIGNORE_FILE" "/.cursor.back/"
echo "Added '/.cursor.back/' to $GITIGNORE_FILE to ignore all backups within this directory."

# --- Processing Rules ---
echo ""
echo "--- Processing Cursor rule files ---"
TARGET_DOT_CURSOR_DIR_ABSOLUTE="$TARGET_PROJECT_DIR/.cursor"
TARGET_RULES_DIR_IN_DOT_CURSOR="$TARGET_DOT_CURSOR_DIR_ABSOLUTE/rules"
mkdir -p "$TARGET_RULES_DIR_IN_DOT_CURSOR"
echo "Ensured target rules directory exists: $TARGET_RULES_DIR_IN_DOT_CURSOR"

if [ -d "$SOURCE_RULES_DIR" ]; then
  shopt -s nullglob # Handle case with no files in source rules dir
  for source_rule_file in "$SOURCE_RULES_DIR"/*; do
    if [ -f "$source_rule_file" ]; then # Ensure it's a file
      rule_name=$(basename "$source_rule_file")
      target_rule_path="$TARGET_RULES_DIR_IN_DOT_CURSOR/$rule_name"
      relative_target_rule_path_for_ignore=".cursor/rules/$rule_name" # Relative to target project root

      echo ""
      echo "Processing rule: $rule_name"

      # 1. Backup old existing file (if it's a real file, not a symlink)
      if [ -f "$target_rule_path" ] && [ ! -L "$target_rule_path" ]; then
        backup_file_path="$TARGET_BACKUP_RULES_DIR_ABSOLUTE/$rule_name.$TIMESTAMP"
        mv "$target_rule_path" "$backup_file_path"
        echo "Backed up existing '$target_rule_path' to '$backup_file_path'"
        # Gitignore for the entire .cursor.back/ directory is handled earlier
        # DO NOT add rule backup to .dockerignore

        # 2. Remove it from git (if it was a real file and presumably tracked)
        (cd "$TARGET_PROJECT_DIR" && git rm --cached "$relative_target_rule_path_for_ignore" > /dev/null 2>&1 || true)
        echo "Attempted to remove '$relative_target_rule_path_for_ignore' from git index in target project."
      elif [ -L "$target_rule_path" ]; then
        echo "Existing '$target_rule_path' is a symlink. It will be replaced."
      fi
      
      # 3. Add the file (symlink path) to .gitignore
      add_to_ignore_file "$GITIGNORE_FILE" "/$relative_target_rule_path_for_ignore"
      echo "Added '$relative_target_rule_path_for_ignore' to $GITIGNORE_FILE"
      # DO NOT add individual rule path to .dockerignore (will be covered by .cursor/)

      # 4. Create symbolic link
      absolute_source_rule_path=$(realpath "$source_rule_file")
      ln -sf "$absolute_source_rule_path" "$target_rule_path"
      echo "Linked: $target_rule_path -> $absolute_source_rule_path"
    fi
  done
  shopt -u nullglob
else
  echo "Warning: Source rules directory '$SOURCE_RULES_DIR' not found. No rules will be linked."
fi

# --- Processing .cursorignore ---
echo ""
echo "--- Processing .cursorignore file ---"
TARGET_CURSORIGNORE_ABSOLUTE="$TARGET_PROJECT_DIR/.cursorignore"
RELATIVE_TARGET_CURSORIGNORE_FOR_IGNORE=".cursorignore" # Relative to target project root

if [ -f "$SOURCE_CURSORIGNORE" ]; then
  # 1. Backup old existing file
  if [ -f "$TARGET_CURSORIGNORE_ABSOLUTE" ] && [ ! -L "$TARGET_CURSORIGNORE_ABSOLUTE" ]; then
    backup_cursorignore_file_path="$TARGET_BACKUP_DIR_ABSOLUTE/.cursorignore.$TIMESTAMP"
    mv "$TARGET_CURSORIGNORE_ABSOLUTE" "$backup_cursorignore_file_path"
    echo "Backed up existing '$TARGET_CURSORIGNORE_ABSOLUTE' to '$backup_cursorignore_file_path'"
    # Gitignore for the entire .cursor.back/ directory is handled earlier
    # DO NOT add .cursorignore backup to .dockerignore

    # 2. Remove it from git
    (cd "$TARGET_PROJECT_DIR" && git rm --cached "$RELATIVE_TARGET_CURSORIGNORE_FOR_IGNORE" > /dev/null 2>&1 || true)
    echo "Attempted to remove '$RELATIVE_TARGET_CURSORIGNORE_FOR_IGNORE' from git index in target project."
  elif [ -L "$TARGET_CURSORIGNORE_ABSOLUTE" ]; then
    echo "Existing '$TARGET_CURSORIGNORE_ABSOLUTE' is a symlink. It will be replaced."
  fi

  # 3. Add the file and backup file to .gitignore / .dockerignore
  add_to_ignore_file "$GITIGNORE_FILE" "/$RELATIVE_TARGET_CURSORIGNORE_FOR_IGNORE"
  echo "Added '$RELATIVE_TARGET_CURSORIGNORE_FOR_IGNORE' to $GITIGNORE_FILE"
  add_to_ignore_file "$DOCKERIGNORE_FILE" "$RELATIVE_TARGET_CURSORIGNORE_FOR_IGNORE" # Add .cursorignore itself
  echo "Added '$RELATIVE_TARGET_CURSORIGNORE_FOR_IGNORE' to $DOCKERIGNORE_FILE"
  
  # 4. Create symbolic link
  absolute_source_cursorignore_path=$(realpath "$SOURCE_CURSORIGNORE")
  ln -sf "$absolute_source_cursorignore_path" "$TARGET_CURSORIGNORE_ABSOLUTE"
  echo "Linked: $TARGET_CURSORIGNORE_ABSOLUTE -> $absolute_source_cursorignore_path"
else
  echo "Warning: Source '$SOURCE_CURSORIGNORE' not found. Not linking .cursorignore."
fi

echo ""
echo "--- General .gitignore/.dockerignore updates ---"
# Add general backup patterns to .gitignore
# Specific backup patterns are now covered by '/.cursor.back/' added earlier.

# Ensure .cursor/ is in .dockerignore
add_to_ignore_file "$DOCKERIGNORE_FILE" ".cursor/"
# Specific backup patterns are NOT added to .dockerignore

echo ""
echo "--- Cursor rules installation complete! ---"
echo "Please review the changes in '$GITIGNORE_FILE' and '$DOCKERIGNORE_FILE'."
echo "Remember to commit these ignore file changes in the target project." 
