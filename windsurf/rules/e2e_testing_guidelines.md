---
trigger: always_on
---

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

## Test Case Granularity: Positive and Negative Scenarios

To ensure clarity and focused testing:
1.  Each test function SHOULD target EITHER a positive scenario (valid inputs, expected successful outcome) OR a negative scenario (invalid inputs or conditions, expected error/failure).
2.  Avoid combining positive and negative test cases within a single test function, for instance, by using flags like `wantErr bool` to switch assertion logic.
3.  **Positive Scenario Tests:**
    *   These tests verify the function's correct behavior with valid data and conditions.
    *   They SHOULD NOT expect an error to be returned. Assertions should focus on the correctness of the non-error result and any side effects.
4.  **Negative Scenario Tests:**
    *   These tests verify the function's error handling capabilities with invalid data, incorrect states, or boundary conditions.
    *   They MUST expect an error to be returned.
    *   Assertions MUST verify that an error is indeed returned.
    *   Assertions SHOULD also verify the type and/or content of the returned error message (e.g., using `errors.Is`, `errors.As`, or string matching) to ensure the correct error is being triggered for the specific scenario.
