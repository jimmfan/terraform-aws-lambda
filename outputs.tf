output "name" {
  description = "Unique name for your Lambda Function."
  value       = aws_lambda_function.lambda.function_name
}

output "arn" {
  description = "Amazon Resource Name (ARN) identifying your Lambda Function."
  value       = aws_lambda_function.lambda.arn
}

output "qualified_arn" {
  description = "ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)."
  value       = aws_lambda_function.lambda.qualified_arn
}

output "invoke_arn" {
  description = "ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri."
  value       = aws_lambda_function.lambda.invoke_arn
}

output "qualified_invoke_arn" {
  description = "Qualified ARN (ARN with lambda version number) to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri"
  value       = aws_lambda_function.lambda.qualified_invoke_arn
}

output "version" {
  description = "Latest published version of your Lambda Function."
  value       = aws_lambda_function.lambda.version
}