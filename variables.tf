# These are the variables required for the instances submodule to function
# properly and are duplicated highly from the main module but instead do not
# have any defaults set because this submodule should never by called from
# anything else expect the main module where values for all these variables will
# always be passed in
variable "user" {
  description = "Instance user name that will used for SSH operations"
  type        = string
  default     = "cody"
}
variable "ssh_key" {
  description = "Location on disk of the SSH public key to be used for instance SSH access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
variable "server_count" {
  description = "The quantity of servers that are deployed within the environment for testing"
  type        = number
  default     = 2
}
variable "node_count" {
  description = "The quantity of nodes that are deployed within the environment for testing"
  type        = number
  default     = 2
}
variable "labels" {
  description = "A map of labels to apply to the instances"
  type        = map
  nullable    = true
  default     = null
}
variable "project" {
  description = "Name of GCP project that will be used for housing require infrastructure"
  type        = string
  default     = "slice-cody"
}
variable "region" {
  description = "GCP region to provision to"
  type        = string
  default     = "us-west1"
}
variable "server_public_ip" {
  description = "To attach a public IP"
  type        = bool
  default     = false 
}
variable "node_public_ip" {
  description = "To attach a public IP"
  type        = bool
  default     = true
}