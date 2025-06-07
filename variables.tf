variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "flink_api_key" {
  description = "Flink API key"
  type = string
}

variable "flink_api_secret" {
    description = "Flink API secret"
    type = string
}