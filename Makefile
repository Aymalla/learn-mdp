.PHONY: help init validate build deploy clean lint test azd-up azd-down

# Default target
help:
	@echo "Available targets:"
	@echo "  help          - Show this help message"
	@echo "  init          - Initialize Azure Developer CLI environment"
	@echo "  validate      - Validate Bicep templates"
	@echo "  build         - Build Bicep templates to ARM JSON"
	@echo "  lint          - Lint Bicep templates"
	@echo "  deploy        - Deploy infrastructure using Azure CLI"
	@echo "  azd-up        - Deploy infrastructure using Azure Developer CLI"
	@echo "  azd-down      - Delete infrastructure using Azure Developer CLI"
	@echo "  clean         - Remove generated files"
	@echo ""
	@echo "Environment variables:"
	@echo "  RESOURCE_GROUP    - Azure resource group name (default: rg-managed-devops-pool)"
	@echo "  LOCATION          - Azure region (default: eastus)"
	@echo "  DEPLOYMENT_NAME   - Deployment name (default: mdp-deployment)"

# Variables
RESOURCE_GROUP ?= rg-managed-devops-pool
LOCATION ?= eastus
DEPLOYMENT_NAME ?= mdp-deployment
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
	az bicep build --file $(BICEP_FILE)
	az deployment group validate \
		--resource-group $(RESOURCE_GROUP) \
		--template-file $(BICEP_FILE) \
		--parameters $(PARAMS_FILE) || true

# Build Bicep to ARM JSON
build:
	@echo "Building Bicep templates..."
	az bicep build --file $(BICEP_FILE)
	@echo "Building module templates..."
	az bicep build --file infra/modules/devCenter.bicep
	az bicep build --file infra/modules/vnet.bicep
	az bicep build --file infra/modules/managedPool.bicep

# Lint Bicep templates
lint:
	@echo "Linting Bicep templates..."
	az bicep build --file $(BICEP_FILE)
	az bicep build --file infra/modules/devCenter.bicep
	az bicep build --file infra/modules/vnet.bicep
	az bicep build --file infra/modules/managedPool.bicep

# Deploy using Azure CLI
deploy:
	@echo "Creating resource group if it doesn't exist..."
	az group create --name $(RESOURCE_GROUP) --location $(LOCATION)
	@echo "Deploying infrastructure..."
	az deployment group create \
		--resource-group $(RESOURCE_GROUP) \
		--template-file $(BICEP_FILE) \
		--parameters $(PARAMS_FILE) \
		--name $(DEPLOYMENT_NAME)
	@echo "Deployment complete!"
	@echo "Outputs:"
	az deployment group show \
		--resource-group $(RESOURCE_GROUP) \
		--name $(DEPLOYMENT_NAME) \
		--query properties.outputs

# What-if analysis
what-if:
	@echo "Running what-if analysis..."
	az deployment group what-if \
		--resource-group $(RESOURCE_GROUP) \
		--template-file $(BICEP_FILE) \
		--parameters $(PARAMS_FILE)

# Deploy using Azure Developer CLI
azd-up:
	@echo "Deploying with Azure Developer CLI..."
	azd up

# Delete infrastructure using Azure Developer CLI
azd-down:
	@echo "Deleting infrastructure with Azure Developer CLI..."
	azd down --force --purge

# Show deployment outputs
show:
	@echo "Deployment outputs:"
	az deployment group show \
		--resource-group $(RESOURCE_GROUP) \
		--name $(DEPLOYMENT_NAME) \
		--query properties.outputs

# Clean generated files
clean:
	@echo "Cleaning generated ARM JSON files..."
	find infra -name "*.json" -not -name "main.parameters.json" -not -name "main.parameters.azd.json" -type f -delete
	@echo "Clean complete!"

# Test - placeholder for future tests
test:
	@echo "No tests defined yet"
