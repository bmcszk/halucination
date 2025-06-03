# Go Project Setup Guide

This guide MANDATES the standard setup for new Go services/microservices. AI Agents and developers MUST adhere to this guide when initializing new projects or services. It complements `.windsurf/rules/testing_*.md` and `.windsurf/rules/go_guideline.md`.

## 1. Directory Structure (Root Level)
This structure MUST be followed:
-   `services/<service_name>/`: Main application and its internal logic.
    -   `main.go` or `cmd/main.go`: Application entry point.
    -   `internal/`: Core service logic.
        -   `handler/`: HTTP request handlers (e.g., Chi).
        -   `service/`: Business logic.
        -   `storage/`: Data persistence (DB interactions).
        -   `model/`: Core data structures (refer to `.windsurf/rules/go_guideline.md`).
        -   `worker/`: Background/periodic task processors.
        -   `config/`: Configuration management.
    -   `db/`: Database assets.
        -   `migration/`: SQL migrations (`golang-migrate`).
        -   `query/`: SQL files for `sqlc`.
        -   `sqlc_generated/`: `sqlc` output.
    -   `api/`: API specifications (e.g., OpenAPI).
-   `pkg/`: Shared libraries/utilities (if any, across services).
-   `docs/`: Project documentation (`requirements.md`, `tasks.md`, `decisions.md`, `project_structure.md`).
-   `.cursor/rules/`: AI assistant guidelines (MDC files).
-   `e2e/`: End-to-End tests (see `.windsurf/rules/testing_*.md` and `.windsurf/rules/go_guideline.md` for testing details).
-   `Makefile`: Common dev tasks.
-   `Dockerfile`: Containerization config.
-   `docker-compose.yml`: Local dev & E2E test environment.
-   `go.mod`, `go.sum`: Go module files.

## 2. Core Tooling & Libraries
The following tools and libraries MUST be used as specified:
-   **HTTP Routing:** `github.com/go-chi/chi`
-   **Configuration:** `github.com/caarlos0/env/v6`
-   **DB Migrations (`golang-migrate`):** `github.com/golang-migrate/migrate`
    -   Location MUST be: `services/<service_name>/db/migration/`.
    -   Naming MUST be lexicographical (e.g., `001_initial_schema.up.sql`).
    -   Execution SHOULD be automated on app startup (in `main.go` or `entrypoint.sh`).
-   **DB Interaction (`sqlc`):** `github.com/sqlc-dev/sqlc`
    -   Config (`sqlc.yaml`) MUST be in `services/<service_name>/`.
    -   Queries MUST be in `services/<service_name>/db/query/`.
    -   Generated Code MUST be in `services/<service_name>/db/sqlc_generated/`.
-   **Logging:** `log/slog` MUST be used for ALL application logging.
-   **Error Handling:** ALL returned errors MUST be wrapped with context: `fmt.Errorf("context: %w", err)`.
-   **Concurrency:** `golang.org/x/sync/errgroup` MUST be used for managing concurrent goroutines.
-   **Messaging (Optional, if event-driven):** `github.com/ThreeDotsLabs/watermill`.

## 3. Standard Makefile Targets
These targets MUST exist in the root `Makefile`. Their testing-related aspects MUST align with `.windsurf/rules/testing_*.md` and `.windsurf/rules/go_guideline.md`.
-   `build`: Compile the project.
-   `run`: Run the project locally.
-   `lint`: Run `golangci-lint run` (as specified in `.windsurf/rules/go_guideline.md`).
-   `test-unit`: Run unit tests ONLY (as defined in `.windsurf/rules/testing_*.md` and `.windsurf/rules/go_guideline.md`).
-   `test-e2e`: Run E2E tests ONLY (as defined in `.windsurf/rules/testing_*.md` and `.windsurf/rules/go_guideline.md`).
-   `check`: Pre-commit checks (MUST include items from `.windsurf/rules/go_guideline.md` and meet all requirements of `.windsurf/rules/testing_*.md`).
-   `sqlc`: Generate SQLC code.
-   `migrate-up`/`migrate-down`: Manual DB migration control.
-   `docker-build`: Build Docker image.
-   `docker-run`: Run project via Docker.

## 4. Testing Strategy (Go Specific Structural Elements)
Refer to `.windsurf/rules/testing_*.md` for overall testing strategy and `.windsurf/rules/go_guideline.md` for Go-specific testing practices (like build tags and libraries).
-   **E2E Test Location:** E2E tests for Go projects MUST be located in the root `e2e/` directory.
-   **E2E Isolated Configuration:** E2E tests MUST use a separate Docker Compose file (e.g., `docker-compose.e2e.yml`) that includes the main `docker-compose.yml` and overrides for E2E specifics.

## 5. Documentation Practice
-   Primary project documentation MUST be in the `docs/` directory (see section 1).
-   `README.md` MUST contain current setup/usage instructions.

## 6. AI Assistant Guidelines
-   AI Agent rules (MDC files) MUST be stored in `.windsurf/rules/`.
-   AI Agent MUST manage tasks via `docs/tasks.md` (see `.windsurf/rules/task_workflow.md`).

## 7. Service Health Checks (Mandatory)
-   Liveness (`/healthz/live`) and readiness (`/healthz/ready`) probes MUST be implemented.
    -   **Liveness:** Checks if app is running (MUST be simple, no external dependencies). Failure results in container restart.
    -   **Readiness:** Checks if app is ready for traffic (MAY check DB, etc.). Failure results in no traffic being sent.

## 8. Dependency Management
-   **Versioning:** AI Agent (or developer) MUST check for latest STABLE versions (Go, Docker images, Go libraries) before adding/updating. STABLE releases MUST ALWAYS be preferred for production environments.

**Note:** Adapt this guide as needed for your project.
