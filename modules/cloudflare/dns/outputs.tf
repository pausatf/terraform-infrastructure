output "records" {
  description = "Map of created DNS records"
  value       = cloudflare_record.this
}
