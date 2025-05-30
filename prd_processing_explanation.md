# AI-Assisted PRD Implementation: A General Workflow

This document outlines the general steps an AI assistant, guided by the `prd_workflow.mdc` rule, takes when tasked with implementing features based on a Product Requirements Document (PRD). For a concrete illustration of a PRD, see [`example_feature_prd.md`](./example_feature_prd.md).

## Invocation

The AI initiates this workflow when:
1.  The user manually invokes a relevant command or rule (e.g., `@prd_workflow`).
2.  A PRD is provided, and the AI determines the PRD implementation workflow is appropriate.

## Core AI Processing Steps

### Step 1: Ingest and Understand PRD
*   **Action:** Read and parse the provided PRD (e.g., [`example_feature_prd.md`](./example_feature_prd.md)).
*   **AI Analysis:**
    *   Identify key features, core requirements, user stories, and constraints.
    *   Extract crucial details for implementation.
    *   Identify potential ambiguities, contradictions, or missing information.
*   **Output:** A structured understanding of the PRD and a list of points needing clarification.

### Step 2: Clarification and Confirmation
*   **Action:** Present identified ambiguities or questions to the user.
*   **AI Interaction:** Request specific details, decisions, or asset locations from the user.
*   **AI Update:** Refine internal understanding based on user feedback.

### Step 3: Task Breakdown and Planning
*   **AI Analysis & Output:**
    *   Decompose requirements into actionable development tasks (frontend, backend, tests, etc.).
    *   Identify affected existing files/modules or necessary new ones.
    *   Propose a high-level implementation plan or sequence.
    *   A detailed example of such a task breakdown can be seen in [`example_feature_prd_task_tracking.md`](./example_feature_prd_task_tracking.md).

### Step 4: Iterative Implementation (Per Task)
*   **Process:** For each task identified in Step 3:
    *   **Code Generation:** Write code adhering to project conventions and PRD specifications.
    *   **Test Generation:** Create relevant unit tests (and other tests as appropriate).
    *   **Documentation:** Add code comments and note potential updates for broader project documentation.
*   The AI applies existing coding styles and patterns from the workspace.

### Step 5: Review and Feedback Cycle
*   **AI Action:** After completing significant work (e.g., a key feature or task set), present changes (code diffs, new files, tests) to the user for review.
*   **Interaction:** Solicit feedback and iterate on the implementation based on user input.
*   This cycle continues until tasks are completed to satisfaction.

## General Guidelines for AI During Implementation
*   Prioritize clarity, maintainability, and adherence to project standards.
*   For large PRDs, suggest sectional processing or feature-by-feature implementation.
*   State any assumptions made if clarifications are not immediately available.
*   Always aim to confirm understanding before making significant, unstated architectural decisions.

## Tracking Progress and Documenting Work

Effective PRD implementation relies on clear progress tracking and documentation.

### 1. Task Management
*   The task list from **Step 3** is the primary guide.
*   The AI conceptually manages task states (e.g., pending, in progress, completed, blocked).
*   An example of a task tracking document can be found at [`example_feature_prd_task_tracking.md`](./example_feature_prd_task_tracking.md).

### 2. Communicating Status
*   The AI communicates status explicitly:
    *   Announcing task commencement and completion.
    *   Highlighting blockers and requesting clarifications.
    *   Providing summaries during review cycles or upon request.

### 3. Documenting Decisions & Artifacts
*   **Conversation Log:** The primary chronological record of clarifications, decisions, and feedback.
*   **Code Artifacts:** Generated code, tests, and inline comments.
*   **Commit Messages (Conceptual):** The AI can suggest descriptive commit messages.
*   **Project Documentation Updates:** The AI notes or drafts necessary updates to broader project docs.

## Organizing for PRD-Driven Development

### 1. Task Tracking Files: Per PRD
*   **Recommendation:** Maintain a separate task tracking file for each PRD (e.g., [`example_feature_prd_task_tracking.md`](./example_feature_prd_task_tracking.md) for [`example_feature_prd.md`](./example_feature_prd.md)).
*   **Rationale:** Enhances clarity, manageability, alignment with PRD lifecycles, and scalability.

### 2. Recommended Project Structure
*   **Central AI Rule:** `.cursor/rules/prd_workflow.mdc`.
*   **PRDs & Related Docs:** Group PRDs and their specific tracking/explanation files into a dedicated project directory (e.g., `prds/` or `features/`), with subdirectories per feature.
    ```
    project_root/
    ├── .cursor/rules/prd_workflow.mdc
    ├── prds/
    │   └── [feature_name]/
    │       ├── [feature_name]_prd.md
    │       └── [feature_name]_prd_task_tracking.md
    └── src/
    ```
*   **Benefits:** Scalability, discoverability, modularity, and consistency.

## Integrating PRD Workflow with Git Flow

Integrating the PRD-driven development process with a Git branching strategy (such as GitFlow or a feature-branch model) provides structure and traceability from requirements to code. **A core principle is that all relevant tests must be passing before any commit is made and before any task or the PRD itself is marked as "Done".** This ensures code quality and stability throughout the development lifecycle. Here's a typical approach:

**1. Feature Branch per PRD/Major Feature:**

*   **Branch Creation:** For each new PRD (or a significant, independent feature within a large PRD that warrants its own lifecycle), a dedicated feature branch should be created from the main development branch (e.g., `develop` in GitFlow, or `main`/`master` if using a simpler model).
    *   **Naming Convention:** Branch names should be descriptive and easily linked to the PRD or feature. Examples:
        *   `feature/user-profile-page` (if `user_profile_page_prd.md` is the PRD)
        *   `feature/auth-oauth2-integration`
        *   `feature/TASK-123-user-profile` (if linking to an external issue tracker ID that corresponds to the PRD)
*   **Scope:** All development work related to implementing the tasks defined in that PRD's task tracking document (`[feature_name]_prd_task_tracking.md`) will occur on this feature branch.

**2. Commits Linked to Tasks:**

*   **Granular Commits:** As the AI (or a developer) works through the tasks in the `[feature_name]_prd_task_tracking.md`, commits should be made frequently and should ideally correspond to the completion of individual tasks or logical sub-parts of tasks. **Crucially, all automated tests (unit, integration, etc.) relevant to the changes must pass before making a commit.**
*   **Commit Messages:** Commit messages are critical for traceability. They should:
    *   Be clear and concise.
    *   Reference the specific task ID from the `[feature_name]_prd_task_tracking.md` and/or the User Story ID from the PRD.
    *   Examples:
        *   `feat(profile): Implement basic user profile view (T1, US-001)`
        *   `fix(profile): Correct email validation on edit form (T2.3)`
        *   `refactor(auth): Improve token refresh logic (T5)`
        *   `test(profile): Add unit tests for UserProfileView component (T1.2)`
*   **AI Assistance:** The `prd_workflow.mdc` can (and does) instruct the AI to suggest or use such commit message formats. If `project_guidelines.mdc` has specific commit message conventions, those should also be followed.

**3. Pull/Merge Requests (PRs/MRs):**

*   **PR Creation:** Once all tasks for a PRD (or a significant milestone within it) are completed on the feature branch, **all associated tests are passing**, and all other checks pass (as per `project_guidelines.mdc`), a Pull Request (or Merge Request) is created to merge the feature branch back into the main development branch (e.g., `develop`).
*   **PR Description:** The PR description should:
    *   Summarize the feature implemented.
    *   **Crucially, link back to the PRD file** (e.g., `prds/[feature_name]/[feature_name]_prd.md`). This provides reviewers with the full context of *why* these changes were made.
    *   Optionally, link to the `[feature_name]_prd_task_tracking.md` or list the main tasks completed.
    *   Highlight any significant architectural decisions made (which should also be in `docs/decisions.md`).
*   **Review Process:**
    *   Code review is performed based on the changes and in the context of the PRD.
    *   Automated checks (CI pipeline) should run, including linters, tests, and builds.
*   **AI Assistance:** The AI can help draft the PR description based on the PRD summary and the completed tasks from the task tracker.

**4. Merging and Release:**

*   Once the PR is approved and all checks pass, the feature branch is merged.
*   The process for releasing this feature into `main`/`master` and then to production would follow your established Git flow (e.g., creating release branches from `develop`, tagging, etc.).

**5. Updating Task Trackers & PRDs:**

*   **Post-Merge:**
    *   The status of the overall PRD (if it has a status field) can be updated (e.g., to "Implemented," "Ready for QA," "Released"). **A PRD should only be marked as "Done" or its equivalent status once all its features are implemented, tested, merged, and verified.**
    *   The `[feature_name]_prd_task_tracking.md` should reflect all tasks as completed. **Individual tasks should only be marked "Done" after their associated code is committed (with tests passing) and, if applicable, merged into the feature branch.**
*   **Feedback Loop:** If issues are found in QA or post-release that trace back to the PRD's requirements, the PRD might be updated (versioned), leading to new tasks and potentially new feature branches for fixes or enhancements.

**Benefits of this Integration:**

*   **Traceability:** Clear line of sight from PRD requirements -> tasks -> commits -> PRs -> deployed code.
*   **Context for Reviewers:** Code reviewers can easily access the PRD to understand the "what" and "why" behind the code changes.
*   **Organized Development:** Isolates work on different features, reducing conflicts.
*   **Collaboration:** Supports collaboration as multiple developers (or AI + developer) can work on different feature branches derived from different PRDs.
*   **Release Management:** Fits well into structured release processes.

By clearly defining this Git integration, the PRD-driven workflow becomes a more robust part of your overall software development lifecycle.

This structured approach, guided by the `prd_workflow.mdc` rule, aims to ensure that AI-assisted development aligns closely with product requirements and user expectations. 
