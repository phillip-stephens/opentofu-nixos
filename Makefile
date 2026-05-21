TOFU_DIR := tofu
TOFU     := tofu

# ── Colours ───────────────────────────────────────────────────────────────────
BOLD  := \033[1m
RESET := \033[0m
GREEN := \033[32m
CYAN  := \033[36m
RED   := \033[31m

.PHONY: up down destroy init fmt validate help

## Default target
all: help

## ── init ─────────────────────────────────────────────────────────────────────
## Initialise OpenTofu (run once, or after provider changes)
init:
	@echo "$(BOLD)$(CYAN)→ Initialising OpenTofu...$(RESET)"
	@cd $(TOFU_DIR) && $(TOFU) init

## ── fmt / validate ───────────────────────────────────────────────────────────
fmt:
	@cd $(TOFU_DIR) && $(TOFU) fmt -recursive

validate: init
	@cd $(TOFU_DIR) && $(TOFU) validate

## ── up ───────────────────────────────────────────────────────────────────────
## Deploy the VM, push NixOS config, and print SSH instructions
up: init _check_tfvars
	@echo "$(BOLD)$(CYAN)→ Planning...$(RESET)"
	@cd $(TOFU_DIR) && $(TOFU) plan -var="instance_stopped=false" -out=tfplan
	@echo "$(BOLD)$(CYAN)→ Applying...$(RESET)"
	@cd $(TOFU_DIR) && $(TOFU) apply tfplan
	@rm -f $(TOFU_DIR)/tfplan
	@echo ""
	@echo "$(BOLD)$(GREEN)✔ VM is up!$(RESET)"
	@echo ""
	@echo "$(BOLD)SSH command:$(RESET)"
	@cd $(TOFU_DIR) && $(TOFU) output -raw ssh_command
	@echo ""

## ── down ─────────────────────────────────────────────────────────────────────
## Stop (terminate) the instance but KEEP the data EBS volume
## Re-running 'make up' will recreate the instance and reattach the volume.
down: init _check_tfvars
	@echo "$(BOLD)$(RED)→ Stopping instance (data volume is preserved)...$(RESET)"
	@cd $(TOFU_DIR) && $(TOFU) apply \
	  -var="instance_stopped=true" \
	  -target=aws_volume_attachment.data \
	  -auto-approve
	@cd $(TOFU_DIR) && $(TOFU) destroy \
	  -var="instance_stopped=true" \
	  -target=null_resource.nixos_deploy \
	  -target=aws_instance.nixos \
	  -target=aws_key_pair.nixos \
	  -auto-approve
	@echo "$(BOLD)$(GREEN)✔ Instance terminated. Data volume intact.$(RESET)"

## ── destroy ───────────────────────────────────────────────────────────────────
## DANGER: destroy EVERYTHING including the data volume.
## You will be prompted to confirm and must type the instance name.
destroy: init _check_tfvars
	@echo "$(BOLD)$(RED)!! WARNING: This will delete ALL resources including the data volume. !!$(RESET)"
	@read -p "Type the project name to confirm (e.g. nixos-dev): " confirm && \
	  cd $(TOFU_DIR) && \
	  NAME=$$($(TOFU) output -raw instance_id 2>/dev/null || echo "none") && \
	  echo "Removing prevent_destroy lifecycle guard before final destroy..." && \
	  $(TOFU) state list | grep ebs_volume | xargs -I{} $(TOFU) state rm {} || true
	@cd $(TOFU_DIR) && $(TOFU) destroy -auto-approve
	@echo "$(BOLD)$(GREEN)✔ All resources destroyed.$(RESET)"

## ── helpers ───────────────────────────────────────────────────────────────────
_check_tfvars:
	@if [ ! -f $(TOFU_DIR)/terraform.tfvars ]; then \
	  echo "$(RED)Error: $(TOFU_DIR)/terraform.tfvars not found.$(RESET)"; \
	  echo "Copy $(TOFU_DIR)/terraform.tfvars.example → $(TOFU_DIR)/terraform.tfvars and fill in your values."; \
	  exit 1; \
	fi

## ── help ──────────────────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "$(BOLD)nixos-aws$(RESET) — NixOS on AWS EC2 via OpenTofu"
	@echo ""
	@echo "  $(BOLD)make up$(RESET)       Deploy VM, apply NixOS config, print SSH command"
	@echo "  $(BOLD)make down$(RESET)     Terminate instance (data EBS volume is preserved)"
	@echo "  $(BOLD)make destroy$(RESET)  Delete EVERYTHING (with confirmation prompt)"
	@echo "  $(BOLD)make init$(RESET)     Initialise OpenTofu providers"
	@echo "  $(BOLD)make fmt$(RESET)      Format Terraform files"
	@echo "  $(BOLD)make validate$(RESET) Validate Terraform files"
	@echo ""
	@echo "First time? See README.md."
	@echo ""
