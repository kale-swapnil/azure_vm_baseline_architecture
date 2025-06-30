variable "location"                { type = string }
variable "resource_group_name"     { type = string }
variable "vnet_id"                 { type = string }
variable "subnet_id"               { type = string }
variable "base_name"               { type = string }
variable "zones"                   { type = list(number) }
variable "log_analytics_name"      { type = string }
