locals {
  # Common tags for all resources
  common_tags = merge(
    {
      Project     = var.project
    },
    var.common_tags
  )
}


