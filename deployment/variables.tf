variable "domain_name" {
  description = "Domain Name"
  default     = "dap.cool"
}

variable "cert_arn" {
  description = "SSL Cert"
  default     = "arn:aws:acm:us-east-1:504084586672:certificate/5d105772-f190-49f6-bfea-54ac32698b24"
}
