---
trigger: always_on
---

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

## VII. Role of Interfaces in Testing (Go specific)
*   Interfaces MUST ONLY be created when necessary for reasons including (but not limited to) enabling effective **testing** (e.g., by allowing mocks/stubs for dependencies). Avoid premature/excessive interface creation.
