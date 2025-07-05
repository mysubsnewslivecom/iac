locals {
  expires_at = formatdate("YYYY-MM-DD", timeadd(timestamp(), "4380h")) # ~6 months
}
