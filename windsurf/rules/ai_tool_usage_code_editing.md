---
trigger: always_on
---

## File Editing & Patch Management (AI Agent)
1.  **Direct File Modification (`edit_file` tool):**
    - AI Agent MUST USE `edit_file` for direct changes.
    - `code_edit` parameter: MUST contain new/modified lines. Unchanged code MUST be represented as `// ... existing code ...` (or language-appropriate equivalent).
    - AI Agent MUST PROVIDE sufficient context (unchanged lines around edit) to avoid ambiguity.
    - For new files, `code_edit` MUST contain the entire file content.
2.  **Verification & Retries:**
    - AFTER `edit_file` success, AI Agent MUST USE `read_file` to confirm exact application of changes.
    - CAUTION: `edit_file` success report DOES NOT guarantee disk write visible to `git` or auto-staging. AI Agent MUST ALWAYS verify file changes & Git status.
    - If `edit_file` diff is incorrect OR `read_file` shows discrepancies, AI Agent MUST USE `reapply` (on the same file).
    - If `reapply` fails OR for complex/widespread changes: AI Agent MUST break the task into SMALLER, targeted `edit_file` calls, VERIFYING each.
3.  **`edit_file` Tool - CRITICAL CAUTIONS & LIMITATIONS:**
    - **Risk of Corruption (HIGH):** `edit_file` can be DANGEROUS with inconsistent file states or large/complex diffs. It may misinterpret context, causing SEVERE file corruption. Safer alternatives: Manual intervention or Version Control System (VCS) restore. AI Agent MUST USE EXTREME CAUTION beyond simple, localized changes, especially if prior edits were unreliable.
    - **Subtlety Issues:** May struggle with subtle changes (e.g., single trailing space removal, precise whitespace/newline in test data). May not register/apply correctly.
    - **Markdown/Tables:** Unreliable for complex Markdown updates (especially tables).
    - **Patch Generation:** May have issues generating patch diffs correctly.
    - **Verification is KEY:** AI Agent MUST ALWAYS verify `edit_file` results (`read_file`), especially for critical files or subtle changes. If the tool is repeatedly problematic, AI Agent MUST seek alternatives or request manual help.
    - **Accidental Deletions:** Tool can misapply diffs, causing accidental content deletion. AI Agent MUST review diff & `read_file` output carefully.
7.  **Handling Problematic Large File Edits / Complex Refactors:**
    - If `edit_file` or `reapply` consistently fails or produces incorrect diffs for a large file or complex refactoring task:
        1.  **Identify Problematic File(s):** Note the specific file(s).
        2.  **Reject Changes:** Ensure no partial/corrupt changes from failed attempts are staged or kept.
        3.  **Reset File(s):** Use `git checkout -- <file_path>` or `git restore <file_path>` (via `run_terminal_cmd`) to revert file(s) to their last committed state (HEAD).
        4.  **Strategize Refactoring (If Applicable):** If complexity is the issue (e.g., refactoring a large function/struct used in many places):
            *   Consider if the large file/struct can be broken down into smaller, more manageable, and independently modifiable units/files. This might be a separate preliminary task.
            *   If splitting is feasible, AI Agent SHOULD propose and (if approved or per autonomy rules) perform the split first.
        5.  **Re-attempt Task on Smaller Units:** If files were split, or if the original task can be broken into smaller, localized edits, AI Agent MUST attempt these smaller edits sequentially, verifying each with `read_file` and `make check` (if applicable) before proceeding.
        6.  **Fallback to AI-Generated Patch:** If automated edits on smaller units (as per step 5) still fail, or if splitting the file/refactor (as per step 4) is not feasible or also fails, AI Agent MUST attempt to apply the changes using an AI-generated patch file as a last resort before requesting manual intervention:
            a.  **Author Patch File:** AI Agent MUST prepare a patch file (e.g., `temp_ai_changes.patch`) in the unified diff format. This patch file should contain the precise changes intended for the problematic file(s), authored by the AI. The AI SHOULD use `write_to_file` to create this patch file.
            b.  **Apply Patch:** AI Agent MUST attempt to apply this patch using `git apply temp_ai_changes.patch` (via `run_terminal_cmd`).
            c.  **Verify Application:** After attempting to apply the patch, AI Agent MUST use `read_file` to confirm if the changes were applied correctly and `git status` to check the state of the files. All verifications, including `make check` (if applicable), MUST be performed.
            d.  **Manual Intervention on Patch Failure:** If applying the AI-generated patch also fails, results in incorrect changes, or fails verification, AI Agent MUST then explicitly state that the task requires manual intervention. The AI MUST detail the attempts made (direct edit, split attempts, patch application) and the tool limitations encountered.
