set shell := ["bash", "-eu", "-o", "pipefail", "-c"]
set quiet # Doesn't print the command that is being run

COVERAGE_MIN := env_var_or_default("COVERAGE_MIN", "100")
JUST := just_executable()

# Runs `just help`
default: help

# Show available recipes
help:
    {{JUST}} --list

# Compile contracts with `forge build`
build:
    forge build

# Compile all contracts with `forge build --force`
build-all:
    forge build --force

# Format Solidity sources with `forge fmt`
fmt:
    forge fmt

# Check formatting and run `solhint` on `src`/`script`/`test`
lint:
    forge fmt --check
    dev/node_modules/.bin/solhint --max-warnings 0 '**/*.sol'

# Run Slither static analysis on `src`
slither:
    dev/.venv/bin/slither src --config-file slither.config.json

# Run tests with `forge test`
test:
    forge test --force --isolate -vvv --show-progress --gas-snapshot-check true

# Print coverage summary (excludes `test`/`script` files)
coverage-summary:
    forge coverage --no-match-coverage "^(test|script)/" --report summary

# Generate lcov coverage report (excludes `test`/`script` files)
coverage-lcov:
    forge coverage --no-match-coverage "^(test|script)/" --report lcov

# Fail if total coverage is below `COVERAGE_MIN` (default `100`)
coverage-check:
    {{JUST}} coverage-summary > coverage.txt
    coverage="$(awk '/^\| Total/ {gsub(/%/, "", $4); print $4}' coverage.txt)"; \
    cat coverage.txt; \
    if [ -z "$coverage" ]; then echo "Failed to extract coverage percentage."; exit 1; fi; \
    awk "BEGIN {exit !($coverage >= {{COVERAGE_MIN}})}" || { echo "Coverage $coverage% is below {{COVERAGE_MIN}}%."; exit 1; }; \
    rm coverage.txt

# Generate gas snapshots with `forge snapshot`
snapshot:
    forge snapshot --force --isolate --desc --show-progress

# Run build, lint, slither, test, coverage-check, snapshot
all:
    {{JUST}} build
    {{JUST}} lint
    {{JUST}} slither
    {{JUST}} coverage-check
    {{JUST}} snapshot
