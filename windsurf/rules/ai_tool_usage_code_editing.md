---
trigger: always_on
---

## General Principles for File Editing (AI Agent)
*   **Verify File State Before Edit:** Before ANY edit (`edit_file`, `replace_file_content`), if there's any doubt about the file's current state (e.g., after previous failed edits, or if working based on potentially stale information), AI Agent MUST use `view_line_range` or `view_file_outline` to re-read the relevant section or the entire file. This ensures `TargetContent` (for `replace_file_content`) or context (for `edit_file`) is accurate and the edit is based on the actual file state.
*   **Verify File State After Edit:** After ANY successful edit tool call, AI Agent MUST use `read_file` (typically after `edit_file`) or `view_line_range`/`view_file_outline` (typically after `replace_file_content`) to confirm the exact application of changes and check for unintended side effects. The diff output from tools (especially `replace_file_content`) can sometimes be misleading; actual file content is the source of truth.
*   **Incremental Changes & Verification:** For complex changes, prefer smaller, incremental edits, verifying each with `make check` (if applicable) and file inspection before proceeding.
*   **Reset on Corruption:** If an edit tool call results in file corruption, syntax errors, or a state that clearly deviates from the intended change, AI Agent MUST immediately reset the file to its last known good state (e.g., `git checkout -- <file_path>`) before attempting any further modifications to that file.

## 1. `edit_file` Tool Usage
*   AI Agent MUST USE `edit_file` for direct changes when `replace_file_content` is not suitable or has failed.
*   `code_edit` parameter: MUST contain new/modified lines. Unchanged code MUST be represented as `// ... existing code ...` (or language-appropriate equivalent).
*   AI Agent MUST PROVIDE sufficient context (unchanged lines around edit) to avoid ambiguity.
*   For new files, `code_edit` MUST contain the entire file content.
*   **Verification & Retries:**
    *   AFTER `edit_file` success, AI Agent MUST USE `read_file` to confirm exact application of changes.
    *   CAUTION: `edit_file` success report DOES NOT guarantee disk write visible to `git` or auto-staging. AI Agent MUST ALWAYS verify file changes & Git status.
    *   If `edit_file` diff is incorrect OR `read_file` shows discrepancies, AI Agent MUST USE `reapply` (on the same file).
    *   If `reapply` fails OR for complex/widespread changes: AI Agent MUST break the task into SMALLER, targeted `edit_file` calls, VERIFYING each.
*   **Critical Cautions & Limitations:**
    *   **Risk of Corruption (HIGH):** `edit_file` can be DANGEROUS with inconsistent file states or large/complex diffs. It may misinterpret context, causing SEVERE file corruption.
    *   **Subtlety Issues:** May struggle with subtle changes (e.g., single trailing space removal, precise whitespace/newline in test data).
    *   **Markdown/Tables:** Unreliable for complex Markdown updates (especially tables).
    *   **Patch Generation:** May have issues generating patch diffs correctly.
    *   **Accidental Deletions:** Tool can misapply diffs, causing accidental content deletion.
    *   **Special Characters:** Be aware that `edit_file` may struggle with changes involving backslashes (e.g., in regex patterns or escaped strings), potentially reporting "no changes made."
    *   **Tool Unresponsiveness:** If `edit_file` becomes unresponsive or errors as an "unknown tool," inform the user and switch to manual edit instructions or other fallbacks.

## 2. `replace_file_content` Tool Usage
*   **`TargetContent` Precision and Uniqueness:**
    *   `TargetContent` MUST be an *exact* and *unique* match for the section to be replaced in the *current* file state.
    *   If the tool reports "target content not unique" or "target content not found," AI Agent MUST NOT retry with the same `TargetContent`. Instead, re-view the file (see "Verify File State Before Edit") to understand the discrepancy and then provide more unique surrounding context or correct the `TargetContent`.
    *   For multi-line replacements or tabular data, ensure `TargetContent` precisely matches the *entire* block to avoid partial replacements or leaving old content.
*   **Handling `ReplacementChunks`:**
    *   When using multiple `ReplacementChunks` in a single call, be extremely cautious. Inaccuracies in `TargetContent` for any chunk can lead to catastrophic deletions or misapplication of other chunks. If such an event occurs, immediately reset the file.
    *   Avoid prepending/appending content intended for *other* parts of the file within a chunk's `ReplacementContent` if it can be handled by a separate, correctly targeted chunk or if it relies on assumptions about surrounding code that might change (e.g., do not try to add a closing brace for a *previous* sub-test within the `ReplacementContent` of a *new* sub-test).
*   **Known Limitations:**
    *   The tool may fail or produce incorrect results if `TargetContent` or `ReplacementContent` contains escaped tab characters (`\t`) within string literals in the JSON payload.
    *   The diff output by the tool can be misleading, especially regarding special characters. Always verify with `view_line_range` or by reading the file.

## 3. Other File Operation Tool Learnings
*   **`view_line_range` Pagination:** `view_line_range` silently truncates output if `EndLine` is more than 200 lines from `StartLine`. For full file retrieval, use paginated calls.
*   **`write_to_file` Size Limitation:** `write_to_file` may time out for very large `CodeContent` (e.g., 700+ lines of Go code). For large new files, if timeout occurs, request manual file creation from the user.

## 4. Fallback Strategies for Problematic Edits
*   If `edit_file` or `replace_file_content` consistently fails, produces incorrect diffs, leads to file corruption, or if the task involves complex refactoring where automated tools are struggling:
    1.  **Identify Problematic File(s):** Note the specific file(s).
    2.  **Reject Changes:** Ensure no partial/corrupt changes from failed attempts are staged or kept.
    3.  **Reset File(s):** Use `git checkout -- <file_path>` or `git restore <file_path>` (via `run_terminal_cmd`) to revert file(s) to their last committed state (HEAD). This is a CRITICAL step to ensure a clean base.
    4.  **Re-Verify File State:** After resetting, re-read the file.
    5.  **Strategize Alternative Approach:**
        *   **Break Down Task:** Consider if the task can be broken into smaller, simpler, and independently verifiable edits.
        *   **Refactor Manually (If AI cannot):** If a large file/struct needs refactoring that tools cannot handle, this might need to be a separate manual step or a user-guided process.
        *   **AI-Generated Patch File:** As a last resort for automated changes, prepare a patch file (e.g., `temp_ai_changes.patch`) in the unified diff format.
            a.  **Author Patch File:** Use `write_to_file` to create this patch file.
            b.  **Apply Patch:** Attempt to apply this patch using `git apply temp_ai_changes.patch` (via `run_terminal_cmd`).
            c.  **Verify Application:** Use `read_file`/`view_line_range` and `git status` to confirm. All verifications, including `make check` (if applicable), MUST be performed.
        *   **Provide Full Code for Manual Replacement:** If patch application fails or is unsuitable (e.g., for self-contained new functions or small files), provide the complete, correct code block for the user to manually paste.
        *   **Manual Intervention:** If all automated/assisted methods fail, clearly state that the task requires manual intervention, detailing attempts made and limitations encountered.
