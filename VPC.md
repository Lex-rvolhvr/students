
#### List of variables:
```.bash
# VPC CIDR IP address block
VPC_CIDR="192.168.0.0/24"

# Public subnet CIDR IP address block
PUB_SUBNET_CIDR="192.168.0.0/25"

# Private subnet CIDR IP- sg_FRONT
PRI_SUBNET_CIDR="192.168.0.128/25"

# VPC ID
VPS_ID=""

- sg_BACK
- WEB_EC2
- DB_EC2
 - 
```
<br>

#### Get a list of users and groups from IAM IC:
``` bash
./get_users_gpoups_IAMIC.py
```
<details>

```bash
=== Users ===
UserId: 90cc599c-20b1-7078-f7c6-9dbdcf809d43, Username: admin

=== Groups ===
GroupId: d0bc396c-50b1-70c6-d9ec-dd8dd355deff, DisplayName: admins
```
</details>
<details>

```python
File contents ./get_users_gpoups_IAMIC.py:


#!/usr/bin/python3

import boto3

# Указание профиля с SSO
session = boto3.Session(profile_name='admin')
client_identitystore = session.client('identitystore', region_name='eu-north-1')
client_iam = session.client('iam', region_name='eu-north-1')

identity_store_id = 'd-c3670d5ba2'

# Получаем список пользователей
response_users = client_identitystore.list_users(
    IdentityStoreId=identity_store_id
)

print("=== Users ===")
for user in response_users['Users']:
    print(f"UserId: {user['UserId']}, Username: {user['UserName']}")

# Получаем список групп
response_groups = client_identitystore.list_groups(
    IdentityStoreId=identity_store_id
)

print("\n=== Groups ===")
for group in response_groups['Groups']:
    print(f"GroupId: {group['GroupId']}, DisplayName: {group['DisplayName']}")

    # Получаем политики для каждой группы через IAM
    group_name = group['DisplayName']

    try:
        # Получаем политики для группы
        attached_policies = client_iam.list_attached_group_policies(
            GroupName=group_name
        )

        print(f"Policies for group {group_name}:")
        for policy in attached_policies['AttachedPolicies']:
            print(f"  PolicyName: {policy['PolicyName']}, PolicyArn: {policy['PolicyArn']}")

    except client_iam.exceptions.NoSuchEntityException:
        print(f"  No policies attached to group {group_name}")
```
</details>
<br>   

#### Access to the console for the admin user via the sso login using two-factor authentication:
```bash 
aws sso login
```
<details>

```bash
Attempting to automatically open the SSO authorization page in your default browser.
If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

https://device.sso.eu-north-1.amazonaws.com/

Then enter the code:

CNSB-HCFS
Successfully logged into Start URL: https://d-c3670d5ba2.awsapps.com/start/#
```
</details>
<br>   

#### Create VPS:
```bash 
aws ec2 create-vpc --cidr-block $VPC_CIDR
```
<details>

```json
{
    "Vpc": {
        "OwnerId": "577638366295",
        "InstanceTenancy": "default",
        "Ipv6CidrBlockAssociationSet": [],
        "CidrBlockAssociationSet": [
            {
                "AssociationId": "vpc-cidr-assoc-059ede4648c849386",
                "CidrBlock": "192.168.0.0/24",
                "CidrBlockState": {
                    "State": "associated"
                }
            }
        ],
        "IsDefault": false,
        "VpcId": "vpc-010b3550abcb7b585",
        "State": "pending",
        "CidrBlock": "192.168.0.0/24",
        "DhcpOptionsId": "dopt-09bcf27222bbe3369"
    }
}
```
</details>
<br>   


#### Create subnet - public:
```bash
VPC_ID="vpc-010b3550abcb7b585"
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PUB_SUBNET_CIDR  --tag-specifications 'ResourceType=subnet,Tags=[{Key=name,Value=public}]'
```
<details>

```json
{
    "Subnet": {
        "AvailabilityZoneId": "eun1-az1",
        "OwnerId": "577638366295",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "Tags": [
            {
                "Key": "name",
                "Value": "public"
            }
        ],
        "SubnetArn": "arn:aws:ec2:eu-north-1:577638366295:subnet/subnet-0b0b2649997efe2e6",
        "EnableDns64": false,
        "Ipv6Native": false,
        "PrivateDnsNameOptionsOnLaunch": {
            "HostnameType": "ip-name",
            "EnableResourceNameDnsARecord": false,
            "EnableResourceNameDnsAAAARecord": false
        },
        "SubnetId": "subnet-0b0b2649997efe2e6",
        "State": "available",
        "VpcId": "vpc-010b3550abcb7b585",
        "CidrBlock": "192.168.0.0/25",
        "AvailableIpAddressCount": 123,
        "AvailabilityZone": "eu-north-1a",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false
    }
}
```
</details>
<br>   

#### Create subnet - private:
```bash
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $PRI_SUBNET_CIDR  --tag-specifications 'ResourceType=subnet,Tags=[{Key=name,Value=private}]'
```
<details>

```json
{
    "Subnet": {
        "AvailabilityZoneId": "eun1-az1",
        "OwnerId": "577638366295",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "Tags": [
            {
                "Key": "name",
                "Value": "private"
            }
        ],
        "SubnetArn": "arn:aws:ec2:eu-north-1:577638366295:subnet/subnet-02b66d634cf9d8e5f",
        "EnableDns64": false,
        "Ipv6Native": false,
        "PrivateDnsNameOptionsOnLaunch": {
            "HostnameType": "ip-name",
            "EnableResourceNameDnsARecord": false,
            "EnableResourceNameDnsAAAARecord": false
        },
        "SubnetId": "subnet-02b66d634cf9d8e5f",
        "State": "available",
        "VpcId": "vpc-010b3550abcb7b585",
        "CidrBlock": "192.168.0.128/25",
        "AvailableIpAddressCount": 123,
        "AvailabilityZone": "eu-north-1a",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false
    }
}
```
<br>
























