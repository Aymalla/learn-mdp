.PHONY: help provision destroy status clean env-check

# Default target
help:
	@echo "Azure Managed DevOps Pool Infrastructure Management"
	@echo ""
	@echo "Available targets:"
	@echo "  help        - Show this help message"
	@echo "  env-check   - Check required environment variables"
	@echo "  provision   - Provision infrastructure using Azure Developer CLI"
	@echo "  destroy     - Destroy infrastructure"
	@echo "  status      - Show current deployment status"
	@echo "  clean       - Clean up local Azure Developer CLI state"
	@echo ""
	@echo "Required environment variables:"
	@echo "  AZURE_ENV_NAME              - Environment name (e.g., dev, prod)"
	@echo "  AZURE_DEVOPS_ORG_NAME       - Azure DevOps organization name"
	@echo "  AZURE_DEVOPS_PROJECT_NAMES  - Azure DevOps project names (comma-separated)"
	@echo ""
	@echo "Optional environment variables:"
	@echo "  AZURE_MDP_POOL_NAME         - Managed DevOps Pool name (default: mdp-pool)"
	@echo "  AZURE_MDP_MAX_CONCURRENCY   - Maximum concurrency (default: 1)"
	@echo "  AZURE_MDP_SKU              - SKU name (default: Standard)"
	@echo "  AZURE_LOCATION             - Azure region (default: uses azd default)"
	@echo "  AZURE_SUBSCRIPTION_ID      - Azure subscription ID (default: uses azd default)"

# Check required environment variables
env-check:
	@echo "Checking required environment variables..."
	@test -n "$(AZURE_ENV_NAME)" || (echo "ERROR: AZURE_ENV_NAME is not set" && exit 1)
	@test -n "$(AZURE_DEVOPS_ORG_NAME)" || (echo "ERROR: AZURE_DEVOPS_ORG_NAME is not set" && exit 1)
	@test -n "$(AZURE_DEVOPS_PROJECT_NAMES)" || (echo "ERROR: AZURE_DEVOPS_PROJECT_NAMES is not set" && exit 1)
	@echo "✓ All required environment variables are set"

# Provision infrastructure
provision: env-check
	@echo "Provisioning infrastructure..."
	azd provision

# Destroy infrastructure
destroy:
	@echo "Destroying infrastructure..."
	azd down --force --purge

# Show deployment status
status:
	@echo "Deployment status:"
	@if azd env list 2>/dev/null | grep -q "$(AZURE_ENV_NAME)"; then \
		azd env get-values; \
	else \
		echo "No environment found. Run 'make provision' first."; \
	fi

# Clean up local state
clean:
	@echo "Cleaning up local Azure Developer CLI state..."
	@rm -rf .azure
	@echo "✓ Local state cleaned"
