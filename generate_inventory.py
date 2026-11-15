import json
import subprocess

def main():
    # تشغيل أمر terraform output بصيغة JSON للحصول على الـ IPs واسم الـ S3
    result = subprocess.run(
        ["terraform", "-chdir=terraform", "output", "-json"],
        capture_output=True, text=True, check=True
    )
    outputs = json.loads(result.stdout)
    
    web_ip = outputs["web_public_ip"]["value"]
    db_ip = outputs["db_public_ip"]["value"]
    s3_bucket = outputs["s3_bucket_name"]["value"]

    # كتابة ملف الـ inventory تلقائياً لـ Ansible
    inventory_content = f"""[web]
{web_ip} ansible_user=ubuntu

[db]
{db_ip} ansible_user=ubuntu

[all:vars]
s3_bucket_name={s3_bucket}
ansible_ssh_private_key_file=~/.ssh/id_rsa
"""

    with open("ansible/inventory.ini", "w") as f:
        f.write(inventory_content)
    
    print("Successfully generated ansible/inventory.ini from Terraform outputs.")

if __name__ == "__main__":
    main()
