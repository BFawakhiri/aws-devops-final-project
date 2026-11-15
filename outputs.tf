# Output for Web Server IP
output "web_public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web.public_ip
}

# Output for Database Server IP (Private or Public depending on your subnet)
output "db_public_ip" {
  description = "IP address of the database server"
  value       = aws_instance.db.private_ip # أو public_ip إذا أردت جعله عاماً
}

# Output for S3 Bucket Name
output "s3_bucket_name" {
  description = "Name of the backup S3 bucket"
  value       = aws_s3_bucket.backup_bucket.id
}
