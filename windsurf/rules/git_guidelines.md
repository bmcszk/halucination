---
trigger: always_on
---

# Git Workflow and Commit Guidelines

This document outlines the mandatory Git workflow, branching strategy, commit practices, and Pull/Merge Request (PR/MR) processes.

## I. Branching Strategy

1.  **No Direct Commits to `main` or `master`:**
    *   Do not commit directly to `main` or `master` branches. All changes MUST be made on feature branches and merged via pull requests.

2.  **Feature Branches for PRD Work:**
    *   Before starting work on a Product Requirements Document (PRD), a dedicated Git feature branch (e.g., `feature/[feature-name-slug]`) MUST be created from the main development branch (typically `main` or `master`).
    *   All development work for that PRD MUST occur on this feature branch.
    *   AI Agent SHOULD advise the user on feature branch creation and confirm its status. Assistance with branch creation is permitted if allowed by `.windsurf/rules/project_standards.md`.

## II. Commit Practices

1.  **When to Commit:**
    *   Work SHOULD be committed when a task or a logical sub-part of a task is complete.
    *   A commit MUST only be made when ALL testing requirements from the project's testing guidelines (see `testing_*.md` files) are met for the changes being committed.

2.  **Commit Message Formulation:**
    *   Commit messages MUST be clear and concise.
    *   They MUST reference the relevant Task ID and/or User Story ID from the PRD's task tracking document.
    *   Example: `feat(profile): Implement user profile view (T1, US-001)`
    *   Example: `fix(auth): Correct login redirection issue (T5, US-003)`
    *   AI Agent MUST formulate such messages.

3.  **Offering to Commit:**
    *   AI Agent MAY offer to perform the commit if permitted by project rules and user preference; otherwise, it MUST provide the fully formulated commit message and the list of files to be committed to the user.

## III. Pull/Merge Request (PR/MR) Process

1.  **Preparation for PR/MR:**
    *   A PR/MR can be prepared when all tasks for the PRD on the feature branch are marked 'Completed' in the task tracker.
    *   Crucially, ALL testing requirements from the project's testing guidelines (see `testing_*.md` files) MUST be met for the entire feature branch.
    *   AI Agent MUST inform the user when the feature branch is ready, e.g., "Feature branch `feature/[feature-name-slug]` for PRD `[feature_name]_prd.md` is complete and all tests pass (per the project's testing guidelines). It is ready for a Pull/Merge Request to `[target_branch]`."

2.  **Creating the PR/MR (GitHub):**
    *   If the project's remote repository is hosted on `github.com`, the AI Agent SHOULD offer to create the PR using the `gh` command-line tool.
    *   The base branch for the PR/MR is typically `main` or `master`, unless specified otherwise by the project's branching model.

3.  **PR/MR Description:**
    *   AI Agent MUST offer to draft the PR/MR description.
    *   The description SHOULD include:
        *   A concise summary of the changes.
        *   A link to the PRD.
        *   A link to the PRD's task tracking document or a summary of completed tasks.
        *   References to any relevant decision log entries (`docs/decisions.md`).
    *   The drafted description MUST be provided to the user for review and use.

## IV. Post-Merge Activities

1.  **Branch Merged Confirmation:**
    *   After the PR/MR is successfully merged, the AI Agent SHOULD acknowledge this (e.g., "The feature branch `feature/[feature-name-slug]` has been merged.").
    *   Subsequent activities like updating PRD status are covered in `.windsurf/rules/prd_implementation_and_review.md`.
