## Starting Work: PRD and Task Identification from Branch

When the AI Agent begins a work session or switches to a new primary task:
1.  The Agent MUST attempt to identify the relevant Product Requirements Document (PRD) by analyzing the current Git branch name. (e.g., a branch named `feature/XYZ-123-description` would point to PRD `XYZ-123`).
2.  If a PRD is identified, the Agent MUST navigate to the corresponding PRD directory (e.g., `prds/XYZ-123/`).
3.  The Agent MUST then review the tasks outlined within that PRD and prioritize them for execution based on their status and dependencies.
