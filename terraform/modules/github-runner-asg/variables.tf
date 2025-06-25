variable "fleet_name"     { type = string }
variable "ami_id"         { type = string }
variable "instance_type"  { type = string default = "t3.small" }
variable "subnet_ids"     { type = list(string) }
variable "labels"         { type = list(string) }