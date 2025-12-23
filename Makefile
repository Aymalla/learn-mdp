.PHONY: help init validate build deploy clean lint azd-up azd-down show trigger-mdp-test-workflows 


# Load environment file if exists
ENV_FILE := .env
ifeq ($(filter $(MAKECMDGOALS),config clean),)
	ifneq ($(strip $(wildcard $(ENV_FILE))),)
		ifneq ($(MAKECMDGOALS),config)
			include $(ENV_FILE)
			export
		endif
	endif
endif

# Load azd environment variables if azd is installed and initialized
ifneq ($(shell command -v azd 2> /dev/null),)
	AZD_VALUES := $(shell azd env get-values --output json | jq -r 'to_entries|map("\(.key)=\(.value)")|.[]')
	$(foreach kv,$(AZD_VALUES),$(eval export $(kv)))
endif

# Default target
help: ## Show this help message
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

trigger-mdp-test-workflows:
	./scripts/mdp-run-workflow-batch.sh "mdp-test.yml" 50


# Variables
BICEP_FILE = infra/main.bicep
PARAMS_FILE = infra/main.parameters.json
AZD_PARAMS_FILE = infra/main.parameters.azd.json

# Initialize Azure Developer CLI
init:
	@echo "Initializing Azure Developer CLI..."
	azd init

# Validate Bicep templates (packages and validates)
validate:
	@echo "Validating Bicep templates..."
	@echo "Building and validating Bicep templates using azd..."
	azd package --all

# Build Bicep to ARM JSON (packages templates)
build:
	@echo "Building Bicep templates..."
	@echo "Packaging Bicep templates using azd..."
	azd package --all

# Lint Bicep templates (packages and lints)
lint:
	@echo "Linting Bicep templates..."
	@echo "Packaging and linting Bicep templates using azd..."
	azd package --all

# Deploy using Azure Developer CLI
deploy:
	@echo "Deploying with Azure Developer CLI..."
	azd up

# Deploy using Azure Developer CLI (alias)
azd-up: deploy

# Delete infrastructure using Azure Developer CLI
# WARNING: This will permanently delete all resources without additional confirmation
azd-down:
	@echo "WARNING: This will permanently delete all resources and purge soft-deleted items!"
	@echo "Deleting infrastructure with Azure Developer CLI..."
	azd down --force --purge

# Show deployment outputs
show:
	@echo "Environment values:"
	azd env get-values
	@echo ""
	@echo "Deployment details:"
	azd show

# Clean generated files
clean:
	@echo "Cleaning generated ARM JSON files..."
	@rm -f infra/main.json infra/modules/*.json
	@echo "Clean complete!"
