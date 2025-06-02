# Project Overview & Workflow

This document MANDATES project overview and workflow rules. AI Agents MUST ALWAYS adhere to these rules.
This is a Go project.

## Documentation
1.  AI Agent MUST ALWAYS consult and adhere to:
    *   `.windsurf/rules/prd_workflow.md` for understanding PRD-driven development, including processing PRDs, breaking them into tasks, and managing implementation.
    *   `.windsurf/rules/testing_guidelines.md` for all general and specific testing methodologies, requirements, and practices.
    *   The specific **Product Requirements Document (PRD)** for the feature being worked on (e.g., `prds/[feature_name]/[feature_name]_prd.md`) for all requirements, user stories, and acceptance criteria.
    *   The associated **Task Tracking** file for that PRD (e.g., `prds/[feature_name]/[feature_name]_prd_task_tracking.md`) for task details and status.
2.  **Decisions:** AI Agent MUST document ALL significant architectural or design decisions incrementally in `docs/decisions.md`, including rationale.
3.  **README:** AI Agent MUST keep `README.md` up-to-date with essential project information (setup, build, usage).
4.  **Date/Time in Documentation:** AI Agent MUST obtain current date/time for ANY documentation via command line (e.g., `date +%Y-%m-%d`).
5.  **Project Structure Document:** AI Agent MUST use `docs/project_structure.md` for understanding project structure, and ensure it aligns with the PRD-based organization.
6.  **Learnings Document:** AI Agent MUST record ALL mistakes and resolutions in `docs/learnings.md`.

## Quality Assurance & Workflow
1.  **Pre-commit Checks:** AI Agent MUST NEVER commit code UNLESS it has passed ALL checks mandated by `.windsurf/rules/testing_guidelines.md` (typically executed via `make check` or equivalent). This includes, but is not limited to, compilation, linting, and all relevant automated tests (unit, integration, E2E as applicable).
2.  **Makefile Targets for Tools:** ALL essential development tools (e.g., `sqlc`, `migrate`, linters, test runners) MUST have corresponding targets in the main `Makefile`, consistent with `.windsurf/rules/testing_guidelines.md`.
3.  **Task Completion & Version Control:** AI Agent MUST follow task completion, progress reporting, and version control guidelines as implied or stated in `.windsurf/rules/prd_workflow.md` and the associated task tracking file for the PRD, ensuring all testing requirements from `.windsurf/rules/testing_guidelines.md` are met before marking tasks/PRDs as done.

## AI Assistant (You) Responsibilities
- AI Agent MUST ADHERE to ALL guidelines herein without explicit reminder.
- **Initial Context:** At request start, AI Agent MUST CONFIRM project root (main `Makefile` dir), current date (e.g., via `date +%Y-%m-%d`), and current Git branch (e.g., via `git rev-parse --abbrev-ref HEAD`).
- **Documentation Awareness:** When performing tasks, AI Agent MUST ensure all relevant documentation (as specified in the 'Documentation' section, the active PRD, its task tracker, `.windsurf/rules/prd_workflow.md`, and `.windsurf/rules/testing_guidelines.md`) is considered and updated as necessary.
- **Task Processing:** AI Agent MUST follow `.windsurf/rules/prd_workflow.md` and the task details within the specific PRD's task tracking file (e.g., `prds/[feature_name]/[feature_name]_prd_task_tracking.md`).
- **Requirements/Scenarios:** AI Agent MUST derive all requirements, user stories, and acceptance criteria directly from the active **PRD** (e.g., `prds/[feature_name]/[feature_name]_prd.md`).
- **File Not Found Error:** If a path error occurs, AI Agent MUST: 1) attempt to determine current working directory (e.g., `pwd`), 2) consult `docs/project_structure.md` (which should reflect the PRD structure), 3) retry the operation if understanding is gained, or report the error with context.
- **Clarify Ambiguity**: If requirements (within the PRD) or technical terms are ambiguous (allowing multiple interpretations, or choice of libraries/patterns), AI Agent MUST explicitly CONFIRM the intended approach with the user.
- **Mistake Logging (`docs/learnings.md`):**
    1.  Acknowledge the mistake.
    2.  Document the mistake in `docs/learnings.md` (detailing what went wrong).
    3.  After correction, UPDATE `docs/learnings.md` with the resolution and lesson learned.
- **Problem Solving Strategy:** If stuck on a task (e.g., tool limitations, persistent errors):
    1.  Re-consult all relevant project guidelines and documentation (`.md` files from `.windsurf/rules/`, active PRD, task tracker, `docs/` folder).
    2.  If guidelines do not provide a path forward, perform a web search for potential solutions or workarounds. Prefix search queries with "cursor ai" to tailor results (e.g., "cursor ai golang edit_file not applying changes").
    3.  If still unable to resolve, clearly document the issue, attempted steps, and why progress is blocked, then await user guidance.

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
4.  **Generating Git Patches (ONLY When Explicitly Required by User/Workflow):**
    - General Rule: AI Agent MUST NOT use `edit_file` to create patch files.
    - If a Git-formatted patch is NEEDED:
        1.  ENSURE target file(s) correctly modified via `edit_file`/`reapply`/`read_file` workflow.
        2.  Stage file(s): `git add <file_path>`.
        3.  Generate patch (Git commands via `run_terminal_cmd`):
            *   Staged vs. HEAD: `git diff --cached > my_changes.patch`
            *   From commits (mailbox): `git format-patch <commit-range/branch> --stdout > series.patch` OR `git format-patch -1 <sha> -o patches/`
5.  **Applying External Git Patches (via `run_terminal_cmd`):**
    1.  Inspect patch (if text-based and feasible): `cat patch_file.patch`.
    2.  Check applicability: `git apply --check my_patch.patch`.
    3.  Plain diff (`git diff` format): `git apply my_patch.patch` (changes will be unstaged).
    4.  Mailbox format (`git format-patch` output): `git am < my_patch.patch` (creates commits). Use `git am --abort` on issues.
    5.  AI Agent MUST ALWAYS verify changes & run `make check` post-application.
6.  **`edit_file` for Patch CONTENT: AVOID.** `edit_file` modifies source files, not for writing patch content itself.
7.  **Handling Problematic Large File Edits / Complex Refactors:**
    - If `edit_file` or `reapply` consistently fails or produces incorrect diffs for a large file or complex refactoring task:
        1.  **Identify Problematic File(s):** Note the specific file(s).
        2.  **Reject Changes:** Ensure no partial/corrupt changes from failed attempts are staged or kept.
        3.  **Reset File(s):** Use `git checkout -- <file_path>` or `git restore <file_path>` (via `run_terminal_cmd`) to revert file(s) to their last committed state (HEAD).
        4.  **Strategize Refactoring (If Applicable):** If complexity is the issue (e.g., refactoring a large function/struct used in many places):
            *   Consider if the large file/struct can be broken down into smaller, more manageable, and independently modifiable units/files. This might be a separate preliminary task.
            *   If splitting is feasible, AI Agent SHOULD propose and (if approved or per autonomy rules) perform the split first.
        5.  **Re-attempt Task on Smaller Units:** If files were split, or if the original task can be broken into smaller, localized edits, AI Agent MUST attempt these smaller edits sequentially, verifying each with `read_file` and `make check` (if applicable) before proceeding.
        6.  **Manual Intervention**: If automated edits on smaller chunks still fail, or if splitting is not feasible/desired, AI Agent MUST explicitly state that the task requires manual intervention due to tool limitations with the specific file/complexity.
