.PHONY: help init validate build deploy clean lint test azd-up azd-down show

# Default target
help:
	@echo "Available targets:"
	@echo "  help          - Show this help message"
	@echo "  init          - Initialize Azure Developer CLI environment"
	@echo "  validate      - Validate Bicep templates"
	@echo "  build         - Build Bicep templates to ARM JSON"
	@echo "  lint          - Lint Bicep templates"
	@echo "  deploy        - Deploy infrastructure using Azure Developer CLI"
	@echo "  azd-up        - Deploy infrastructure using Azure Developer CLI (alias for deploy)"
	@echo "  azd-down      - Delete infrastructure using Azure Developer CLI"
	@echo "  show          - Show environment values and deployment outputs"
	@echo "  clean         - Remove generated files"
	@echo ""
	@echo "Environment variables (set via 'azd env set'):"
	@echo "  AZURE_ENV_NAME           - Environment name"
	@echo "  AZURE_LOCATION           - Azure region"
	@echo "  AZURE_DEVOPS_ORG_NAME    - Azure DevOps organization name"

# Variables
BICEP_FILE = infra/main.bicep
PARAMS_FILE = infra/main.parameters.json
AZD_PARAMS_FILE = infra/main.parameters.azd.json

# Initialize Azure Developer CLI
init:
	@echo "Initializing Azure Developer CLI..."
	azd init

# Validate Bicep templates
validate:
	@echo "Validating Bicep templates..."
	@echo "Building Bicep templates to validate syntax..."
	azd package --all

# Build Bicep to ARM JSON
build:
	@echo "Building Bicep templates..."
	azd package --all

# Lint Bicep templates
lint:
	@echo "Linting Bicep templates..."
	azd package --all

# Deploy using Azure Developer CLI
deploy:
	@echo "Deploying with Azure Developer CLI..."
	azd up

# Deploy using Azure Developer CLI (alias)
azd-up:
	@echo "Deploying with Azure Developer CLI..."
	azd up

# Delete infrastructure using Azure Developer CLI
azd-down:
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
	find infra -name "*.json" -not -name "main.parameters.json" -not -name "main.parameters.azd.json" -type f -delete
	@echo "Clean complete!"

# Test - placeholder for future tests
test:
	@echo "No tests defined yet"
