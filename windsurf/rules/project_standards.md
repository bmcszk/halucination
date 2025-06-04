---
trigger: always_on
---

# Project Overview & Workflow

This document MANDATES project overview and workflow rules. AI Agents MUST ALWAYS adhere to these rules.
This is a Go project.

## Documentation
1.  AI Agent MUST ALWAYS consult and adhere to:
    *   `.windsurf/rules/prd_setup_and_planning.md` and `.windsurf/rules/prd_implementation_and_review.md` for understanding PRD-driven development, including processing PRDs, breaking them into tasks, and managing implementation.
    *   the `.windsurf/rules/testing_*.md` files for all general and specific testing methodologies, requirements, and practices.
    *   The specific **Product Requirements Document (PRD)** for the feature being worked on (e.g., `prds/[feature_name]/[feature_name]_prd.md`) for all requirements, user stories, and acceptance criteria.
    *   The associated **Task Tracking** file for that PRD (e.g., `prds/[feature_name]/[feature_name]_prd_task_tracking.md`) for task details and status.
2.  **Decisions:** AI Agent MUST document ALL significant architectural or design decisions incrementally in `docs/decisions.md`, including rationale.
3.  **README:** AI Agent MUST keep `README.md` up-to-date with essential project information (setup, build, usage).
4.  **Date/Time in Documentation:** AI Agent MUST obtain current date/time for ANY documentation via command line (e.g., `date +%Y-%m-%d`).
5.  **Project Structure Document:** AI Agent MUST use `docs/project_structure.md` for understanding project structure, and ensure it aligns with the PRD-based organization.
6.  **Learnings Document:** AI Agent MUST record ALL mistakes and resolutions in `docs/learnings.md`.

## Quality Assurance & Workflow
1.  **Pre-commit Checks:** AI Agent MUST NEVER commit code UNLESS it has passed ALL checks mandated by `.windsurf/rules/testing_*.md` (typically executed via `make check` or equivalent). This includes, but is not limited to, compilation, linting, and all relevant automated tests (unit, integration, E2E as applicable).
2.  **Makefile Targets for Tools:** ALL essential development tools (e.g., `sqlc`, `migrate`, linters, test runners) MUST have corresponding targets in the main `Makefile`, consistent with `.windsurf/rules/testing_*.md`.
3.  **Task Completion & Version Control:** AI Agent MUST follow task completion and progress reporting guidelines as implied or stated in `.windsurf/rules/prd_setup_and_planning.md`, `.windsurf/rules/prd_implementation_and_review.md`, and the associated task tracking file for the PRD. For all version control (Git) guidelines, refer to `.windsurf/rules/git_guidelines.md`. Ensure all testing requirements from the `.windsurf/rules/testing_*.md` files are met before marking tasks/PRDs as done.
4.  **Maximum File Size:** AI Agent MUST ensure that any source code file (including test files) does not exceed 1000 lines. If this limit is reached or crossed, the code MUST be refactored by splitting it into smaller, more manageable files.
