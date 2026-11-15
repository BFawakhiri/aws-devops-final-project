output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "db_public_ip" {
  value = aws_instance.db.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.backup_bucket.id
}
