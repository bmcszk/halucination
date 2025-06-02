# Testing Guidelines

This document MANDATES project-wide testing guidelines. AI Agents MUST ALWAYS adhere to these rules when developing, modifying, or interacting with tests. These guidelines apply across all workflows (PRD-driven, task-based, etc.) unless explicitly overridden by a more specific, active rule for a particular context.

Refer to language-specific guidelines (e.g., `.windsurf/rules/go_guideline.md`) for additional, language-focused testing rules.

## I. General Testing Principles & Quality Gates

1.  **Test Integrity (Universal Requirement):**
    *   Ensure all relevant tests pass before EVERY commit.
    *   Ensure all relevant tests pass before marking ANY task or Product Requirements Document (PRD) as 'Done' or complete. This is a critical quality gate.
    *   AI Agent MUST NEVER commit code UNLESS it has been verified by ALL relevant checks (compilation, linters, unit tests, E2E tests as applicable).
    *   The `make check` command (or equivalent) is the primary pre-commit check. It MUST pass successfully for ALL changes. `make check` MUST include compilation, linting, and unit tests. For Go projects, it should not require Docker.
    *   Specific workflows (e.g., PRD completion) may mandate additional checks like passing E2E tests before final completion.

2.  **Test Coverage:**
    *   Tests MUST ADEQUATELY cover requirements as defined in the relevant Product Requirements Document (PRD) or requirements specification.
    *   For functional requirements, corresponding test scenarios MUST be documented (e.g., in `docs/scenarios.md` for older workflows, or implicitly by PRD acceptance criteria).
    *   These scenarios serve as a MANDATORY checklist for test coverage.
    *   AI Agent MUST ALWAYS verify E2E test coverage when implementing or modifying E2E tests related to a requirement.

3.  **Post-Test File Change Protocol:**
    *   After ANY change to test files (add, refactor, modify), AI Agent MUST run `make check` (or equivalent).
    *   AI Agent MUST PROCEED with further development or commits only if all tests pass and quality standards are met.

4.  **Proactive Checks:**
    *   AI Agent MUST ALWAYS proactively perform checks (compile, lint, test) during development iterations, not just before commits.

## II. Test-Driven Development (TDD)

1.  **TDD Mandate:**
    *   AI Agent MUST ALWAYS write tests *before* writing implementation code.
    *   AI Agent MUST apply TDD principles for EVERY task or functional unit of work.
    *   If TDD is not applicable for a specific situation (rare), AI Agent MUST explicitly state the rationale.

2.  **TDD Cycle (MANDATORY):**
    1.  Create a minimal code stub (e.g., empty function/struct).
    2.  Write a unit test against the stub (this test MUST initially fail).
    3.  Implement the necessary logic to make the test pass.
    *   TDD is a development methodology, not just a testing strategy. It ensures tests validate intended functionality from the start.

## III. Unit Tests

1.  **Purpose & Scope:**
    *   Unit tests MUST test individual components (functions, structs, methods) in isolation.
    *   Private functions (or methods, depending on the language) SHOULD NOT be tested directly. Focus on testing the public API of a module or component, as this is what consumers of the code will interact with. If a private function's logic is complex and warrants testing, consider if it should be extracted into its own component with a public API, or if its behavior can be adequately tested through the existing public interface of its containing module/class.

2.  **Dependency Management:**
    *   ALL external dependencies (Databases, external APIs, other services/modules) MUST be mocked or stubbed.

3.  **Execution Characteristics:**
    *   Unit tests MUST be fast.
    *   NO Docker or other external services/processes are ALLOWED for unit tests.

4.  **Tooling (Go specific):**
    *   AI Agent MUST utilize the `testify` library for assertions (`github.com/stretchr/testify/assert` or `require`).
    *   AI Agent MUST employ the `testify/mock` library for creating mocks.

## IV. End-to-End (E2E) / Integration Tests

1.  **Purpose & Scope:**
    *   E2E/Integration tests MUST verify system behavior as a whole or verify the interaction of integrated parts.
    *   Build Tag (Go specific): Use `//go:build e2e` for Go E2E test files.

2.  **Coverage:**
    *   E2E tests MUST cover ALL functional requirements and acceptance criteria specified in the active PRD (or `docs/scenarios.md` for older workflows). This ensures validation of key user flows and API interactions against a realistic environment.

3.  **Style & Structure:**
    *   Tests SHOULD be written in a Behavior-Driven Development (BDD) style (e.g., Godog, or similar structured approach).
    *   (Go specific): For cucumber-like test structure guidance without specific libraries (e.g. Godog), AI Agent MUST refer to patterns in `github.com/bmcszk/effective-monorepo/tree/feature/tilt/e2e`.

4.  **Environment & Dependencies:**
    *   E2E tests REQUIRE a running application and its dependencies (e.g., via Docker Compose).
    *   (Go specific): For mocking 3rd party REST services during E2E tests, `unimock` (`github.com/bmcszk/unimock`) MUST be used.
    *   (Go specific): E2E tests MUST use a separate Docker Compose file (e.g., `docker-compose.e2e.yml`) that includes the main `docker-compose.yml` and overrides for E2E specifics for isolated configuration.

5.  **Location (Go specific):**
    *   E2E tests MUST be located in the root `e2e/` directory.

## V. Test Case Design and Structure

1.  **Conciseness and Focus:**
    *   Tests MUST be concise and focused, testing one specific aspect of behavior or functionality per test case.
    *   Avoid overly complex tests that try to validate multiple unrelated things at once.

2.  **Test File Size and Organization:**
    *   Test files MUST be kept small and manageable. If a test file grows too large (e.g., significantly exceeding a few hundred lines or covering too many distinct features/contexts), it MUST be split into multiple, more focused files.
    *   Related tests for a specific unit or feature SHOULD be grouped together.

3.  **Given-When-Then (GWT) Structure:**
    *   ALL tests (both unit and E2E, where applicable and practical) MUST clearly follow the Given-When-Then structure to delineate setup, action, and verification phases.
    *   Each individual test case (function/method) MUST contain conceptually one 'Given' block/section (setup), one 'When' block/section (action), and one 'Then' block/section (assertions).
    *   This structure can be implemented using comments (e.g., `// Given: ...`, `// When: ...`, `// Then: ...`), dedicated helper functions, or language-specific BDD/testing framework constructs.

4.  **'When' Section Clarity:**
    *   The 'When' section of a test, which describes or executes the primary action being performed on the system under test, SHOULD ideally be a single, expressive line of code or a call to a single function that encapsulates this action.

5.  **Test File Organization: Test Logic vs. Helper Logic:**
    *   To enhance readability and maintainability, test files SHOULD separate test case logic from complex setup and assertion helper logic.
    *   **Primary Test File (e.g., `feature_test.go`):**
        *   This file MUST contain the actual test functions (e.g., `TestFeatureX`, `TestAPIEndpointY`).
        *   It SHOULD clearly orchestrate the Given-When-Then flow for each test case, primarily by calling helper functions for setup and assertions.
    *   **Helper File(s) (e.g., `feature_test_helpers.go`, `testutils/builders.go`):**
        *   These files MUST encapsulate reusable or complex logic for:
            *   **Given (Setup):** Functions to prepare test data, configure mocks, set up preconditions (e.g., `setupUserProfileTestData()`, `mockUserServiceSuccess()`).
            *   **Then (Assertions):** Functions for performing detailed or repeated assertions (e.g., `assertUserProfileMatchesExpected(actual, expected)`, `verifyOrderPersistedCorrectly(orderID)`).
        *   Helper files can be co-located with the test file (e.g., using `_test` package in Go) or placed in a shared test utility package/directory if the helpers are broadly applicable.
    *   The goal is to make the primary test file read like a clear specification of test scenarios, with implementation details abstracted into helpers.

## VI. Test Execution & Makefile Integration

1.  **Dedicated Targets:** Both unit and E2E tests MUST be runnable via dedicated Makefile targets.
    *   `make test-unit`: MUST run ONLY unit tests.
    *   `make test-e2e`: MUST run ONLY E2E tests. This target MUST require Docker (e.g., via Docker Compose).

2.  **Comprehensive Check Target:**
    *   The `make check` target MUST include `make test-unit` (or the direct command for running unit tests) and other checks like linting as specified in `.windsurf/rules/project_guidelines.md` or language-specific guidelines.

3.  **Task/PRD Completion Criteria:**
    *   Any task, feature, or PRD is ONLY considered 'Done' or complete when, in addition to other functional criteria, ALL relevant testing requirements outlined in this document (Section I.1. Test Integrity) are met. This typically means all associated automated tests (unit, integration, E2E as applicable to the scope of work) are passing.

## VII. Role of Interfaces in Testing (Go specific)
*   Interfaces MUST ONLY be created when necessary for reasons including (but not limited to) enabling effective **testing** (e.g., by allowing mocks/stubs for dependencies). Avoid premature/excessive interface creation.
