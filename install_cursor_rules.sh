#!/bin/bash
set -e

# Script to install Cursor rules from this project to a target project directory.

# --- Configuration ---
SOURCE_PROJECT_DIR=$(pwd)
SOURCE_RULES_DIR_RELATIVE="cursor/rules"
SOURCE_CURSORIGNORE_RELATIVE=".cursorignore"

SOURCE_RULES_DIR="$SOURCE_PROJECT_DIR/$SOURCE_RULES_DIR_RELATIVE"
SOURCE_CURSORIGNORE="$SOURCE_PROJECT_DIR/$SOURCE_CURSORIGNORE_RELATIVE"

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


# --- Backup Phase ---
echo ""
echo "--- Backing up existing Cursor configuration in target project ---"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
# The target project will have rules placed in its .cursor/rules directory
TARGET_DOT_CURSOR_DIR_ABSOLUTE="$TARGET_PROJECT_DIR/.cursor" # This is where linked rules will go
TARGET_CURSORIGNORE_ABSOLUTE="$TARGET_PROJECT_DIR/.cursorignore" # This is where linked .cursorignore will go

# Backup .cursor directory in target if it exists
if [ -d "$TARGET_DOT_CURSOR_DIR_ABSOLUTE" ]; then
  BACKUP_NAME=".cursor.bak.$TIMESTAMP"
  mv "$TARGET_DOT_CURSOR_DIR_ABSOLUTE" "$TARGET_PROJECT_DIR/$BACKUP_NAME"
  echo "Backed up existing '$TARGET_DOT_CURSOR_DIR_ABSOLUTE' to '$TARGET_PROJECT_DIR/$BACKUP_NAME'"
fi

# Backup .cursorignore file in target if it exists
if [ -L "$TARGET_CURSORIGNORE_ABSOLUTE" ]; then # If it's already a symlink, just replace
    echo "Existing '$TARGET_CURSORIGNORE_ABSOLUTE' is a symlink. It will be replaced."
elif [ -f "$TARGET_CURSORIGNORE_ABSOLUTE" ]; then # If it's a regular file, back it up
  BACKUP_IGNORE_NAME=".cursorignore.bak.$TIMESTAMP"
  mv "$TARGET_CURSORIGNORE_ABSOLUTE" "$TARGET_PROJECT_DIR/$BACKUP_IGNORE_NAME"
  echo "Backed up existing '$TARGET_CURSORIGNORE_ABSOLUTE' to '$TARGET_PROJECT_DIR/$BACKUP_IGNORE_NAME'"
fi

# --- Symbolic Link Creation Phase ---
echo ""
echo "--- Creating symbolic links for Cursor rules and .cursorignore ---"
# Ensure the .cursor/rules directory exists in the target project
TARGET_RULES_DIR_IN_DOT_CURSOR="$TARGET_DOT_CURSOR_DIR_ABSOLUTE/rules"
mkdir -p "$TARGET_RULES_DIR_IN_DOT_CURSOR"
echo "Ensured target rules directory exists: $TARGET_RULES_DIR_IN_DOT_CURSOR"

# Link rule files from source (cursor/rules) to target (.cursor/rules)
if [ -d "$SOURCE_RULES_DIR" ]; then
  shopt -s nullglob # Handle case with no files in source rules dir
  for source_rule_file in "$SOURCE_RULES_DIR"/*; do
    if [ -f "$source_rule_file" ]; then # Ensure it's a file
      rule_name=$(basename "$source_rule_file")
      # Use realpath for robust absolute path resolution of source file
      absolute_source_rule_path=$(realpath "$source_rule_file") 
      target_symlink_path="$TARGET_RULES_DIR_IN_DOT_CURSOR/$rule_name"
      
      ln -sf "$absolute_source_rule_path" "$target_symlink_path"
      echo "Linked: $target_symlink_path -> $absolute_source_rule_path"
    fi
  done
  shopt -u nullglob
else
  echo "Warning: Source rules directory '$SOURCE_RULES_DIR' not found. No rules will be linked."
fi

# Link .cursorignore from source (.cursorignore) to target (.cursorignore)
if [ -f "$SOURCE_CURSORIGNORE" ]; then
  absolute_source_cursorignore_path=$(realpath "$SOURCE_CURSORIGNORE")
  ln -sf "$absolute_source_cursorignore_path" "$TARGET_CURSORIGNORE_ABSOLUTE"
  echo "Linked: $TARGET_CURSORIGNORE_ABSOLUTE -> $absolute_source_cursorignore_path"
else
  echo "Warning: Source '$SOURCE_CURSORIGNORE' not found. Not linking .cursorignore."
fi

# --- Update Ignore Files Phase ---
echo ""
echo "--- Updating .gitignore and .dockerignore in target project ---"
GITIGNORE_FILE="$TARGET_PROJECT_DIR/.gitignore"
DOCKERIGNORE_FILE="$TARGET_PROJECT_DIR/.dockerignore"

echo "Updating $GITIGNORE_FILE..."
add_to_ignore_file "$GITIGNORE_FILE" "/.cursor.bak.*/"
add_to_ignore_file "$GITIGNORE_FILE" "/.cursorignore.bak.*/"

# Add individual symlinked rules to .gitignore
if [ -d "$TARGET_RULES_DIR_IN_DOT_CURSOR" ]; then # Check if target rules dir was created and might contain links
  shopt -s nullglob
  # Iterate over what's actually in the target, these would be the symlinks
  for linked_rule_file in "$TARGET_RULES_DIR_IN_DOT_CURSOR"/*; do 
    if [ -L "$linked_rule_file" ]; then # Ensure it's a symlink
      rule_name=$(basename "$linked_rule_file")
      add_to_ignore_file "$GITIGNORE_FILE" "/.cursor/rules/$rule_name"
    fi
  done
  shopt -u nullglob
fi

# Add linked .cursorignore to .gitignore
if [ -L "$TARGET_CURSORIGNORE_ABSOLUTE" ]; then 
    add_to_ignore_file "$GITIGNORE_FILE" "/.cursorignore"
fi

echo "Updating $DOCKERIGNORE_FILE..."
add_to_ignore_file "$DOCKERIGNORE_FILE" ".cursor.bak.*/"
add_to_ignore_file "$DOCKERIGNORE_FILE" ".cursorignore.bak.*/"
# For Docker, it's often safer to ignore the whole .cursor directory due to symlink handling by Docker context
add_to_ignore_file "$DOCKERIGNORE_FILE" "/.cursor/" 
# And also the root .cursorignore if it was linked
if [ -L "$TARGET_CURSORIGNORE_ABSOLUTE" ]; then
    add_to_ignore_file "$DOCKERIGNORE_FILE" "/.cursorignore"
fi

echo ""
echo "--- Cursor rules installation complete! ---"
echo "Please review the changes in '$TARGET_PROJECT_DIR/.gitignore' and '$TARGET_PROJECT_DIR/.dockerignore'."
echo "Remember to commit these ignore file changes in the target project." 
