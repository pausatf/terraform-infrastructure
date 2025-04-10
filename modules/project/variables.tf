variable "name" {
  description = "The name of the project"
  type        = string
}

variable "description" {
  description = "The description of the project"
  type        = string
  default     = ""
}

variable "purpose" {
  description = "The purpose of the project"
  type        = string
  default     = "Web Application"
  
  validation {
    condition     = contains([
      "Web Application", 
      "Service or API", 
      "Mobile Application", 
      "Machine Learning / AI", 
      "IoT", 
      "Website or blog", 
      "Operational / Developer tooling", 
      "Staging or Development", 
      "Other"
    ], var.purpose)
    error_message = "Purpose must be one of the allowed values."
  }
}

variable "environment" {
  description = "The environment of the project"
  type        = string
  default     = null
  
  validation {
    condition     = var.environment == null ? true : contains([
      "Development", 
      "Staging", 
      "Production"
    ], var.environment)
    error_message = "Environment must be one of the allowed values or null."
  }
}

variable "is_default" {
  description = "Whether this is the default project"
  type        = bool
  default     = false
}

variable "resources" {
  description = "List of resource URNs to add to the project"
  type        = list(string)
  default     = []
}
