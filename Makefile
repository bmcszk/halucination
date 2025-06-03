.PHONY: check

# The 'check' target currently only validates rule file installation.
# Typically, a 'check' target in a Go project might also include
# compilation (e.g., go build ./...), linting (e.g., go vet ./... or golangci-lint run),
# and running all tests (e.g., go test ./...).
# You can expand this target or add others (e.g., 'build', 'lint', 'test') as needed.
check:
	@echo "--- Validating Rule Files ---"
	./test_install_rules.sh
	@echo "\nRule file validation complete."
