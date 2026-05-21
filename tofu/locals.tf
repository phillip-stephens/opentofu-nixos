locals {
  common_tags = {
    Project     = var.name
    ManagedBy   = "opentofu"
    Environment = "dev"
  }
}
