#!/bin/bash
set -e

# Test script for install_cursor_rules.sh

# --- Configuration ---
SOURCE_PROJECT_DIR_FOR_TEST=$(pwd) # This is the 'halucination' project dir
INSTALL_SCRIPT="$SOURCE_PROJECT_DIR_FOR_TEST/install_cursor_rules.sh"

TEST_DIR_NAME="_tmp_install_test_project"

SOURCE_RULES_DIR_RELATIVE_TO_SOURCE="cursor/rules"
SOURCE_CURSORIGNORE_RELATIVE_TO_SOURCE=".cursorignore"

# --- Helper Functions ---
assert_symlink_exists_and_points_to() {
  local link_path="$1"
  local expected_target_prefix="$2" # We check if the target starts with this prefix

  if [ ! -L "$link_path" ]; then
    echo "FAIL: Symbolic link $link_path does not exist."
    return 1
  fi

  local actual_target # Use realpath for robust target resolution
  actual_target=$(realpath "$link_path")
  expected_target_prefix=$(realpath "$expected_target_prefix")

  if [[ "$actual_target" != "$expected_target_prefix"* ]]; then
    echo "FAIL: Symbolic link $link_path points to '$actual_target', expected target '$expected_target_prefix'."
    return 1
  fi
  echo "PASS: Symlink $link_path exists and points correctly to $actual_target."
  return 0
}

assert_file_contains() {
  local file_path="$1"
  local pattern="$2"

  if [ ! -f "$file_path" ]; then
    echo "FAIL: File $file_path does not exist for checking content."
    return 1
  fi

  if ! grep -qF "$pattern" "$file_path"; then # -F for fixed string, -q for quiet
    echo "FAIL: File $file_path does not contain expected entry: '$pattern'."
    return 1
  fi
  echo "PASS: File $file_path contains '$pattern'."
  return 0
}

initial_cleanup(){
  if [ -d "$TEST_DIR_NAME" ]; then
    echo "Removing pre-existing test directory: $TEST_DIR_NAME"
    rm -rf "$TEST_DIR_NAME"
  fi
}

# --- Main Test Logic ---

echo "--- Starting test for install_cursor_rules.sh --- "

# 1. Initial Cleanup (if exists from previous run)
initial_cleanup

mkdir -p "$TEST_DIR_NAME"
echo "Created test directory: $TEST_DIR_NAME"

# Create dummy .gitignore and .dockerignore in the test directory
TARGET_GITIGNORE="$TEST_DIR_NAME/.gitignore"
TARGET_DOCKERIGNORE="$TEST_DIR_NAME/.dockerignore"
touch "$TARGET_GITIGNORE"
touch "$TARGET_DOCKERIGNORE"
echo "Created dummy .gitignore and .dockerignore in $TEST_DIR_NAME"

# 2. Invoke the installation script
echo ""
 echo "Invoking install_cursor_rules.sh on $TEST_DIR_NAME ..."
if ! bash "$INSTALL_SCRIPT" "$TEST_DIR_NAME"; then
  echo "FAIL: install_cursor_rules.sh script exited with an error."
  # No cleanup on error, allow inspection
  exit 1
fi
echo "install_cursor_rules.sh script completed."

# 3. Perform Checks
echo ""
echo "--- Performing Checks --- "

# Target project will have rules placed in its .cursor/rules directory
TARGET_PROJECT_DOT_CURSOR_RULES_DIR="$TEST_DIR_NAME/.cursor/rules"
if [ ! -d "$TARGET_PROJECT_DOT_CURSOR_RULES_DIR" ]; then
  echo "FAIL: Target rules directory $TARGET_PROJECT_DOT_CURSOR_RULES_DIR was not created."
  exit 1
fi
echo "PASS: Target rules directory $TARGET_PROJECT_DOT_CURSOR_RULES_DIR exists."

# Check symbolic links for rule files
# Source rules are in SOURCE_PROJECT_DIR_FOR_TEST/cursor/rules/
SOURCE_RULES_ABSOLUTE_DIR="$SOURCE_PROJECT_DIR_FOR_TEST/$SOURCE_RULES_DIR_RELATIVE_TO_SOURCE"
num_source_rules=0
if [ -d "$SOURCE_RULES_ABSOLUTE_DIR" ]; then
    shopt -s nullglob
    for source_rule_file_in_source_project in "$SOURCE_RULES_ABSOLUTE_DIR"/*; do
        if [ -f "$source_rule_file_in_source_project" ]; then
            rule_name=$(basename "$source_rule_file_in_source_project")
            target_symlink_in_target_project="$TARGET_PROJECT_DOT_CURSOR_RULES_DIR/$rule_name"
            # Expected target for the symlink is the absolute path of the source rule file
            expected_actual_target_for_symlink=$(realpath "$source_rule_file_in_source_project")
            assert_symlink_exists_and_points_to "$target_symlink_in_target_project" "$expected_actual_target_for_symlink"
            num_source_rules=$((num_source_rules + 1))
        fi
    done
    shopt -u nullglob
fi
if [ $num_source_rules -eq 0 ]; then
    echo "INFO: No rule files found in source project at $SOURCE_RULES_ABSOLUTE_DIR. Skipping rule symlink checks."
fi

# Check .cursorignore symbolic link
SOURCE_CURSORIGNORE_ABSOLUTE_PATH="$SOURCE_PROJECT_DIR_FOR_TEST/$SOURCE_CURSORIGNORE_RELATIVE_TO_SOURCE"
if [ -f "$SOURCE_CURSORIGNORE_ABSOLUTE_PATH" ]; then
    target_cursorignore_symlink_in_target_project="$TEST_DIR_NAME/.cursorignore"
    expected_actual_target_for_cursorignore_symlink=$(realpath "$SOURCE_CURSORIGNORE_ABSOLUTE_PATH")
    assert_symlink_exists_and_points_to "$target_cursorignore_symlink_in_target_project" "$expected_actual_target_for_cursorignore_symlink"
fi

# Check .gitignore entries
echo "Checking .gitignore entries in $TARGET_GITIGNORE..."
assert_file_contains "$TARGET_GITIGNORE" "/.cursor.bak.*/"
assert_file_contains "$TARGET_GITIGNORE" "/.cursorignore.bak.*/"

if [ $num_source_rules -gt 0 ]; then
    # Check one rule file to see if it's in .gitignore (assuming basename logic is consistent)
    # Need to get the name of an actual rule file from the source directory to check
    first_rule_name_from_source=$(ls "$SOURCE_RULES_ABSOLUTE_DIR" | head -n 1)
    if [ -n "$first_rule_name_from_source" ]; then
         assert_file_contains "$TARGET_GITIGNORE" "/.cursor/rules/$first_rule_name_from_source"
    fi   
fi
if [ -f "$SOURCE_CURSORIGNORE_ABSOLUTE_PATH" ]; then
    assert_file_contains "$TARGET_GITIGNORE" "/.cursorignore"
fi

# Check .dockerignore entries
echo "Checking .dockerignore entries in $TARGET_DOCKERIGNORE..."
assert_file_contains "$TARGET_DOCKERIGNORE" ".cursor.bak.*/"
assert_file_contains "$TARGET_DOCKERIGNORE" ".cursorignore.bak.*/"
assert_file_contains "$TARGET_DOCKERIGNORE" "/.cursor/"
if [ -f "$SOURCE_CURSORIGNORE_ABSOLUTE_PATH" ]; then
    assert_file_contains "$TARGET_DOCKERIGNORE" "/.cursorignore" # Corrected variable here
fi

echo ""
echo "--- All checks passed successfully! --- "
echo "Test directory '$TEST_DIR_NAME' has been left for inspection."
echo "Run 'rm -rf $TEST_DIR_NAME' to remove it manually."

exit 0 
