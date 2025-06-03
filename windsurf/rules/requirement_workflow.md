# Requirement Workflow

This document MANDATES the workflow for managing requirements and their corresponding test scenarios. AI Agents MUST ALWAYS adhere to this workflow.

## Documentation of Requirements & Test Scenarios

1.  **Requirements File (`docs/requirements.md`):**
    *   ALL functional and non-functional requirements MUST be documented in `docs/requirements.md`.
    *   AI Agent MUST ALWAYS consult and update `docs/requirements.md` BEFORE starting work on ANY new feature or change.

2.  **Test Scenarios File (`docs/scenarios.md`):**
    *   For EVERY requirement in `docs/requirements.md`, corresponding test scenarios (covering common and edge cases) MUST be documented in `docs/scenarios.md`.
    *   AI Agent MUST use `docs/scenarios.md` as a MANDATORY checklist for test coverage, ensuring it aligns with overall strategies in the `.windsurf/rules/testing_*.md` files (referenced via `.windsurf/rules/project_guidelines.md`).

## AI Assistant Responsibilities for Requirements

-   AI Agent MUST ALWAYS consider and update ALL relevant documentation (`docs/requirements.md`, `docs/scenarios.md`) for ANY task. This INCLUDES ensuring that test scenarios defined in `docs/scenarios.md` and their coverage (e.g., through E2E tests) align with the comprehensive testing strategies and requirements detailed in the `.windsurf/rules/testing_*.md` files (referenced via `.windsurf/rules/project_guidelines.md`).

## Git Workflow for Requirements

-   All Git workflow activities (branching, commits, Pull/Merge Requests) related to implementing or modifying requirements MUST adhere to the comprehensive guidelines outlined in `.windsurf/rules/git_guidelines.md`.
-   For task-specific completion and version control aspects within the scope of a requirement, AI Agent MUST also consult and follow `.windsurf/rules/task_workflow.md`.
