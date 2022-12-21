variable "domain_name" {
  description = "Domain Name"
  default     = "dap.cool"
}

variable "cert_arn" {
  description = "SSL Cert"
  default     = "arn:aws:acm:us-east-1:504084586672:certificate/81292617-2985-4f2e-9c05-88eca22115b4"
}
