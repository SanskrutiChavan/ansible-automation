#!/bin/bash

echo "===================================="
echo "   User Management Automation"
echo "===================================="

PLAYBOOK_PATH="/opt/ansible/user_management/playbooks"
INVENTORY="/opt/ansible/user_management/inventory/aws.ini"

SMTP_USER="sahualok798@gmail.com"
SMTP_PASS="kgfdcmvxdtwgedtz"

# Email validation
while true
do
read -p "Enter user email: " EMAIL
if [[ "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$ ]]; then
echo "Valid email"
break
else
echo "Invalid email format!"
fi
done

send_email() {
ansible localhost -i $INVENTORY -m mail \
-a "host=smtp.gmail.com port=587 username=$SMTP_USER password=$SMTP_PASS to=$EMAIL subject='$1' body='$2' secure=starttls" >/dev/null 2>&1
}

while true
do
echo ""
echo "1. Add User"
echo "2. Remove User"
echo "3. Reset Password"
echo "4. Exit"

read -p "Enter your choice: " choice

case $choice in

1)
read -p "Enter username: " username
password=$(openssl rand -base64 12)

result=$(ansible-playbook -i $INVENTORY $PLAYBOOK_PATH/add_user.yml -e "username=$username password=$password")

if echo "$result" | grep -q "exists"; then
echo "User already exists"
else
echo "User Created Successfully"
echo "Username: $username"
echo "Password: $password"

send_email "User Created" "Username: $username Password: $password"
fi
;;

2)
while true
do
read -p "Enter username: " username

result=$(ansible-playbook -i $INVENTORY $PLAYBOOK_PATH/remove_user.yml -e "username=$username")

if echo "$result" | grep -q "not_found"; then
echo "User not found"
echo "1 Retry 2 Back"
read opt
[ "$opt" == "1" ] && continue || break
else
echo "User Removed"
send_email "User Removed" "Username: $username"
break
fi
done
;;

3)
while true
do
read -p "Enter username: " username
password=$(openssl rand -base64 12)

result=$(ansible-playbook -i $INVENTORY $PLAYBOOK_PATH/reset_password.yml -e "username=$username password=$password")

if echo "$result" | grep -q "not_found"; then
echo "User not found"
echo "1 Retry 2 Back"
read opt
[ "$opt" == "1" ] && continue || break
else
echo "Password Reset"
echo "Password: $password"

send_email "Password Reset" "Username: $username Password: $password"
break
fi
done
;;

4) exit ;;
*) echo "Invalid" ;;
esac
done
