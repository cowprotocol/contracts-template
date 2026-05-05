ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: all clean build lint slither test fmt coverage-check snapshot

help: ## Print all targets and descriptions
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[.a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } END { printf "\n" }' $(MAKEFILE_LIST)

all: ## Build, fmt, slither, check coverage, and snapshot gas
	make clean && \
	make build && \
	make fmt && \
	make slither && \
	make coverage-check && \
	make snapshot

clean: ## Clean the project
	forge clean

build: ## Build the contracts
	forge build --force 

lint: ## Run lint
	forge fmt --check && \
  	solhint -c .solhint.json --max-warnings 0 "src/**/*.sol"  && \
  	solhint -c script/.solhint.json --max-warnings 0 "script/**/*.sol" && \
  	solhint -c test/.solhint.json --max-warnings 0 "test/**/*.t.sol"

fmt: ## Format the contracts
	forge fmt && \
  	solhint -c .solhint.json --max-warnings 0 "src/**/*.sol"  && \
  	solhint -c script/.solhint.json --max-warnings 0 "script/**/*.sol" && \
  	solhint -c test/.solhint.json --max-warnings 0 "test/**/*.t.sol"

slither: ## Run slither (requires 0.11.0)
	slither . --include-paths "(src)" --fail-low --config-file slither.config.json

test: ## Run tests
	forge test --force --isolate -vvv --show-progress --gas-snapshot-check true

coverage-summary: ## Run tests and generate coverage summary
	forge coverage --no-match-coverage "(test|script)" --force --report summary

coverage-lcov: ## Run tests and generate coverage lcov report
	forge coverage --no-match-coverage "(test|script)" --force --report lcov

COVERAGE_MIN := 100
coverage-check: ## Check if test coverage is above the minimum
	make coverage-summary | tee coverage.txt
	@coverage=$$(grep "| Total" coverage.txt | awk '{print $$4}' | sed 's/%//'); \
	if [ -z "$$coverage" ]; then \
		echo "\n❌ Failed to extract coverage percentage.\n"; \
		exit 1; \
	elif [ $$(echo "$$coverage < $(COVERAGE_MIN)" | bc -l) -eq 1 ]; then \
		echo "\n❌ Current coverage of $$coverage% below the minimum of $(COVERAGE_MIN)%.\n"; \
		exit 1; \
	else \
		echo "\n✅ Current coverage of $$coverage% meets the minimum of $(COVERAGE_MIN)%.\n"; \
	fi
	@rm coverage.txt

snapshot: ## Create a snapshot
	forge snapshot --force --isolate --desc --show-progress
