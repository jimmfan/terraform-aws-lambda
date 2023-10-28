variable "account_id" {
  type        = number
  description = "AWS Account ID"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "lambda_name" {
  description = "Name of lambda function"
  type        = string
}

variable "handler" {
  description = "Lambda Function entrypoint in your code.  For python, it will be the filename (module) and lambda function name.  ie. module.function"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table that the lambda function needs access to.  If empty, DynamoDB policy will not be generated."
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Identifier of the function's runtime. Defaults to python3.8. Valid Values: nodejs | nodejs4.3 | nodejs6.10 | nodejs8.10 | nodejs10.x | nodejs12.x | nodejs14.x | nodejs16.x | java8 | java8.al2 | java11 | python2.7 | python3.6 | python3.7 | python3.8 | python3.9 | dotnetcore1.0 | dotnetcore2.0 | dotnetcore2.1 | dotnetcore3.1 | dotnet6 | nodejs4.3-edge | go1.x | ruby2.5 | ruby2.7 | provided | provided.al2 | nodejs18.x | python3.10 | java17 | ruby3.2 | python3.11"
  type        = string
  default     = "python3.8"
  validation {
    condition = contains(
      [
        "dotnet6", "dotnetcore1.0", "dotnetcore2.0", "dotnetcore2.1", "dotnetcore3.1", "go1.x",
        "java11", "java17", "java8", "java8.al2", "nodejs", "nodejs10.x", "nodejs12.x",
        "nodejs14.x", "nodejs16.x", "nodejs18.x", "nodejs4.3", "nodejs4.3-edge", "nodejs6.10",
        "nodejs8.10", "provided", "provided.al2", "python2.7", "python3.6", "python3.7",
        "python3.8", "python3.9", "python3.10", "python3.11", "ruby2.5", "ruby2.7", "ruby3.2"
      ],
      var.runtime
    )
    error_message = "Supported values for var.runtime can be found here https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html"
  }
}

variable "source_file" {
  description = "File path of lambda function. ie. ../src/lambda"
  type        = string
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function"
  type        = list(string)
  default     = null
  validation {
    condition     = length(var.layers) <= 5
    error_message = "Each lamba function supports up to five layers"
  }
}

variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds. Defaults to 3"
  type        = number
  default     = 3
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128"
  type        = number
  default     = 128
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version. Defaults to false"
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "Optional environment variables for the lambda function. Defaults to {}"
  type        = map(string)
  default     = {}
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Valid values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0, and null. If you select 0, the events in the log group are always retained and never expire. Null will not create a log group"
  type        = number
  default     = null
  /* validation {
    condition = var.log_retention_in_days == null || contains(
      [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0],
      var.log_retention_in_days
    )
    error_message = "Valid values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0, and null."
  } */
}

variable "provisioned_concurrent_executions" {
  description = "Amount of capacity to allocate. If specified, it will overwrite the publish argument in aws_lambda_function resource to be true and create a new lambda version. Must be greater than or equal to 1 to create resource. If 0, resource will not be created."
  type        = number
  default     = 0
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

variable "cloudwatch_log_tags" {
  description = "Additional map of tags for cloudwatch. Merged with the tags variable and assigned to cloudwatch log group resources."
  type        = map(string)
  default     = {}
}
