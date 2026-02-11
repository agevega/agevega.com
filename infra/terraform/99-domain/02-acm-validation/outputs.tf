output "validation_route53_record_fqdns" {
  description = "List of FQDNs built using the zone domain and name"
  value       = [for record in aws_route53_record.acm_validation : record.fqdn]
}
