variable "location"             { type = string }
variable "resource_group_name"  { type = string }
variable "log_analytics_name"   { type = string }
variable "tags"                 { type = map(string)}
variable "zones"                { type = list(number) }
