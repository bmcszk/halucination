# Task Workflow

This document MANDATES the workflow for task creation, management, and completion. AI Agents MUST ALWAYS adhere to this workflow.

## Task Creation & Management (Target: `docs/tasks.md`)

1.  Upon changes to `docs/requirements.md`, AI Agent MUST create new tasks in **ToDo** state. New tasks MUST ALWAYS be appended to `docs/tasks.md`.
    *   For functional requirements, AI Agent MUST add test scenarios to `docs/scenarios.md` AND create a task to implement E2E tests for EVERY scenario (ensure these align with overall testing strategy in the `.windsurf/rules/testing_*.md` files).
2.  When new tasks are added to `docs/tasks.md`, AI Agent MUST then remove tasks that are in the **Done** state from `docs/tasks.md`. Tasks in **Skipped** or any other non-Done state MUST NOT be removed during this process.
3.  AI Agent MUST ALWAYS create and manage tasks, including assigning IDs and tracking status in `docs/tasks.md`.

## AI Assistant Task Processing Workflow

1.  **Task Selection:**
    *   AI Agent MUST process tasks from `docs/tasks.md` sequentially, selecting the first task in **ToDo** state.
    *   If no tasks are in **ToDo** state, AI Agent MUST select the first task in **Blocked** state.
    *   AI Agent MUST skip **Blocked** tasks if **ToDo** tasks exist. AI Agent MUST return to **Blocked** tasks only after all **ToDo** tasks are addressed or when the blocking condition is resolved.
2.  **Update Task Status:** Before commencing work, AI Agent MUST update the task's status to **In Progress** in `docs/tasks.md`.
3.  **Task Execution:**
    *   AI Agent MUST ALWAYS consider and update ALL relevant documentation (`docs/requirements.md`, `docs/scenarios.md`, `docs/tasks.md`, `docs/decisions.md`, `README.md`, `docs/project_structure.md`, `docs/learnings.md`).
    *   AI Agent MUST adhere to TDD and proactive checking principles outlined in the `.windsurf/rules/testing_*.md` files (referenced via `.windsurf/rules/project_guidelines.md`).
    *   **`edit_file` Tool Protocol:**
        *   AI Agent MUST exercise caution with `edit_file` for full-file replacements or large-scale markdown changes (e.g., `docs/tasks.md`).
        *   If `edit_file` reports issues or fails to apply changes correctly, AI Agent MUST verify the actual file state.
        *   AI Agent MUST break down large edits.
        *   If `edit_file` problems persist, AI Agent MUST use the following alternative:
            1.  Generate a patch file in standard `git diff` format.
            2.  Save the patch to a temporary file (e.g., `temp.patch`).
            3.  Use `run_terminal_cmd` to apply the patch: `git apply temp.patch`. AI Agent MUST consult `git apply` documentation for options if needed.
            4.  Verify changes and delete the temporary patch file.
4.  **Task Completion Criteria:** A task is ONLY considered **Done** when ALL the following conditions are met:
    *   ALL code changes are implemented.
    *   ALL functional requirements are met.
    *   ALL testing requirements specified in the `.windsurf/rules/testing_*.md` files (referenced via `.windsurf/rules/project_guidelines.md`) are satisfied for the task's changes.
    *   The task is marked as **Done** in `docs/tasks.md`.
5.  **Post-Completion:**
    *   After successfully committing and pushing changes for a **Done** task, AI Agent MUST immediately process the next **ToDo** task from `docs/tasks.md`.
    *   AI Agent MUST ALWAYS proceed autonomously without asking for confirmation if the next step is clear.

## Task Completion & Version Control

-   All Git workflow activities (committing, pushing) related to task completion MUST adhere to the comprehensive guidelines outlined in `.windsurf/rules/git_guidelines.md`.
-   This includes commit message formulation (which should reference Task IDs as per `git_guidelines.md`), staging files, and pushing commits promptly.
-   Pre-commit checks, as defined in the `.windsurf/rules/testing_*.md` files (referenced via `.windsurf/rules/project_guidelines.md`), MUST pass before any commit.
