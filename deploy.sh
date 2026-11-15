#!/bin/bash
set -e

KEY_NAME= "AKIASCJI7QPLGY4YEBOU"
echo "🚀 Step 1: Initializing and Applying Terraform..."
cd terraform
terraform init -upgrade
terraform apply -auto-approve -var="key_name=$AKIASCJI7QPLGY4YEBOU"
cd ..

echo "🐍 Step 2: Generating Dynamic Ansible Inventory using Python..."
python3 scripts/gen_inventory.py

echo "⏳ Waiting 30 seconds for EC2 instances to initialize SSH..."
sleep 30

echo "⚙️ Step 3: Running Ansible Playbook..."
cd ansible
ansible-playbook -i inventory.ini site.yml --vault-password-file ~/.vault_pass.txt
cd ..

echo "🔍 Step 4: Performing Health Check..."
WEB_IP=$(terraform -chdir=terraform output -raw web_public_ip)
echo "Checking http://$WEB_IP/health ..."

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$WEB_IP/health)

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ Health check passed successfully! (HTTP 200)"
else
    echo "❌ Health check failed with status: $HTTP_STATUS"
    exit 1
fi

echo "🎉 Deployment completed successfully with a single command!"
