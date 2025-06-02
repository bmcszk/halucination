**Objective:** Guide the user through migrating their project to a PRD-driven workflow. Facilitate analysis, content transformation, and process adoption.

**Initiation:** Activate when user expresses intent to migrate their existing process.

**Phase 1: Analyze Current State**

1.  **Instruction: Assess Existing `.mdc` Rules.**
    *   Prompt user for existing guiding rules (e.g., `.windsurf/rules/project_guidelines.md`, `.windsurf/rules/requirement_workflow.md`, `.windsurf/rules/task_workflow.md`).
    *   For each rule provided:
        *   **Analyze `.windsurf/rules/project_guidelines.md`:** Identify general project standards (coding, style, architecture). Propose to user:
            *   Retain as active if general and non-conflicting.
            *   Integrate relevant parts into `.windsurf/rules/prd_workflow.md` if overlapping or specific to old requirement/task handling.
        *   **Analyze `.windsurf/rules/requirement_workflow.md`:** Identify its core logic for processing `requirements.md`. Note key steps for potential adaptation into `.windsurf/rules/prd_workflow.md`.
        *   **Analyze `.windsurf/rules/task_workflow.md`:** Identify its core logic for managing `tasks.md`. Note key steps for potential adaptation into `.windsurf/rules/prd_workflow.md`.
    *   Goal: Extract valuable, non-redundant guidance for the new `.windsurf/rules/prd_workflow.md`.

2.  **Instruction: Analyze `requirements.md` and `tasks.md` Data Files.**
    *   Request user to provide `requirements.md` and `tasks.md`.
    *   **Analyze `requirements.md`:**
        *   Determine its structure (e.g., monolithic list, feature sections).
        *   Assess requirement granularity and format.
        *   Present findings to user and discuss suitability for conversion to PRD(s).
    *   **Analyze `tasks.md`:**
        *   Determine its structure and task definition format.
        *   Identify how tasks are linked to requirements (if at all).
        *   Assess current progress notation methods.
        *   Present findings to user and discuss suitability for migration to PRD-specific trackers.

**Phase 2: Consolidate Workflow Guidance**

3.  **Instruction: Define and Refine `.windsurf/rules/prd_workflow.md`.**
    *   Verify with user that a `.windsurf/rules/prd_workflow.md` exists or offer to help create one based on previous discussions (referencing our established PRD workflow structure).
    *   Propose incorporating essential, non-overlapping logic from `.windsurf/rules/requirement_workflow.md` (for PRD ingestion/clarification) and `.windsurf/rules/task_workflow.md` (for task management within PRDs) directly into `.windsurf/rules/prd_workflow.md`.
    *   If `.windsurf/rules/project_guidelines.md` is retained, ensure `.windsurf/rules/prd_workflow.md` instructs AI to adhere to it.
    *   Recommend to user that `.windsurf/rules/prd_workflow.md` becomes the single, primary workflow rule for PRD processing.

4.  **Instruction: Plan Deprecation of Old Workflow Rules.**
    *   Advise user: "Once `.windsurf/rules/prd_workflow.md` is comprehensive, archive older workflow rules (e.g., `.windsurf/rules/requirement_workflow.md`, `.windsurf/rules/task_workflow.md`) to `.windsurf/rules/archive/` to prevent conflicting instructions."

**Phase 3: Migrate Data to New PRD Structure**

5.  **Instruction: Facilitate Conversion of `requirements.md` to PRD(s).**
    *   Assist user in identifying distinct features/epics within `requirements.md`.
    *   For each identified feature:
        *   Propose creating a new PRD file (e.g., `prds/[feature_name]/[feature_name]_prd.md`).
        *   Offer to restructure content from `requirements.md` into standard PRD sections (referencing `example_feature_prd.md` as a template for sections like Introduction, Goals, User Stories, Requirements).

6.  **Instruction: Facilitate Migration of `tasks.md` to PRD-Specific Task Trackers.**
    *   For each new PRD file created (from step 5):
        *   Propose creating a corresponding `[feature_name]_prd_task_tracking.md` file (referencing `example_feature_prd_task_tracking.md` for format).
        *   Assist user in mapping tasks from `tasks.md` to the relevant new PRD task tracker (transferring description, status, priority, notes).

**Phase 4: Guide Rollout and Iteration**

7.  **Instruction: Recommend and Support a Pilot Project.**
    *   Suggest user select one feature (with its new PRD and task tracker) for a pilot run of the new process.
    *   State: "I will use `.windsurf/rules/prd_workflow.md` to guide my actions for this pilot. Please monitor and provide feedback."

8.  **Instruction: Initiate Post-Pilot Review.**
    *   After pilot completion, ask user: "How did the new process work for the pilot feature? What adjustments, if any, should we make to `.windsurf/rules/prd_workflow.md` or your PRD templates?"

9.  **Instruction: Advise Incremental Migration for Remaining Features.**
    *   Recommend user migrate remaining features/tasks incrementally.

**Phase 5: Guide Transition Finalization**

10. **Instruction: Advise on Archiving Old Data Files.**
    *   Once user confirms all active development uses the new PRD system and data is migrated, advise: "Consider archiving your old `requirements.md` and `tasks.md` files (e.g., to an `archive/` folder) to preserve history while keeping your project clean."

11. **Instruction: Remind User to Update Central Process Documentation.**
    *   Prompt user: "Ensure your main process guide (e.g., `prd_processing_explanation.md` or similar) is updated to reflect the new PRD-driven workflow."

**AI Self-Guidance Notes for This Migration Rule:**
*   Your role is collaborative facilitation. Clearly explain each step and its rationale to the user.
*   Actively offer to perform content analysis, restructuring, and file creation tasks.
*   Be prepared to reference `example_feature_prd.md`, `example_feature_prd_task_tracking.md`, and the general `prd_processing_explanation.md` as examples/templates.
*   Confirm user understanding and agreement at each major decision point.
