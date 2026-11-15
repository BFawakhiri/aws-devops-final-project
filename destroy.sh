#!/bin/bash
set -e

KEY_NAME="AKIASCJI7QPLGY4YEBOU"

echo "🗑️ Destroying Terraform-managed infrastructure..."
cd terraform
terraform destroy -auto-approve -var="key_name=$AKIASCJI7QPLGY4YEBOU"
cd ..

# تنظيف الملفات المحلية المؤقتة
rm -f ansible/inventory.ini
echo "🧹 Local cleanup complete. All AWS resources successfully deleted."
