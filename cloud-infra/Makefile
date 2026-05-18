.PHONY: up up-beefy down down-full init fmt validate



# Normal spin-up
up:
	tofu apply

# Beefy spin-up for heavy workloads (m5.2xlarge: 8 vCPU, 32 GB RAM)
up-beefy:
	tofu apply -var="instance_type=m5.2xlarge"

# Tear down compute only — home EBS volume is preserved
down:
	tofu destroy \
		-target=null_resource.install_nixos \
		-target=aws_volume_attachment.home \
		-target=aws_eip.desktop \
		-target=aws_instance.desktop

# Full destroy including the home volume (destructive — loses all data)
down-full:
	@echo "WARNING: This will destroy the home EBS volume and all data on it."
	@echo "WARNING: Remove the prevent_destroy lifecycle block from volume.tf first."
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ]
	tofu destroy

init:
	tofu init

fmt:
	tofu fmt -recursive

validate:
	tofu validate
