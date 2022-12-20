variable "domain_name" {
  description = "Domain Name"
  default     = "dap.cool"
}

variable "cert_arn" {
  description = "SSL Cert"
  default     = "arn:aws:acm:us-east-1:504084586672:certificate/f92719bb-7990-4bcb-9222-a7b31434b2f5"
}
