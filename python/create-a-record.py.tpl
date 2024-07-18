import requests
import boto3
import os 
 
ec2_client = boto3.client('ec2', region_name='${aws_required_region}')
access_token = os.environ.get('NETLIFY_ACCESS_TOKEN')
domain = "${domain}"
instance_id = '${instance-id}'
record_type = "A"
record_name = "ghost.${domain}"
 
def get_instance_public_ip(instance_id):
    # Describe instance
    response = ec2_client.describe_instances(
        InstanceIds=[instance_id]
    )
 
    # Extract public IP address
    public_ip = None
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            public_ip = instance.get('PublicIpAddress')
 
    return public_ip
 
def get_netlify_dns_zone_id(access_token, domain):
    # Define the Netlify API endpoint for DNS zones
    api_endpoint = "https://api.netlify.com/api/v1/dns_zones"
 
    # Set up headers with authorization
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
 
    # Send a GET request to retrieve DNS zones
    response = requests.get(api_endpoint, headers=headers)
 
    # Check if the request was successful
    if response.status_code == 200:
        dns_zones = response.json()
        # Search for the domain and return its DNS zone ID
        for zone in dns_zones:
            if zone['name'] == domain:
                return zone['id']
        print(f"Domain '{domain}' not found in Netlify DNS zones.")
        return zone['id']
    else:
        print(f"Failed to fetch DNS zones. Status code: {response.status_code}")
        return None
 
def get_record_id(access_token, zone_id, record_type, record_name):
    # Define the Netlify API endpoint for retrieving DNS records
    api_endpoint = f"https://api.netlify.com/api/v1/dns_zones/{zone_id}/dns_records"
 
    # Set up headers with authorization
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
 
    # Send a GET request to retrieve DNS records
    response = requests.get(api_endpoint, headers=headers)
 
    # Check if the request was successful
    if response.status_code == 200:
        dns_records = response.json()
        # Search for the desired record and return its ID
        for record in dns_records:
            if record['type'] == record_type and record['hostname'] == record_name:
                return record['id']
        print(f"Record of type '{record_type}' and name '{record_name}' not found.")
        return None
    else:
        print(f"Failed to fetch DNS records. Status code: {response.status_code}")
        return None
 
def delete_dns_record(access_token, zone_id, dns_record_id):
    # Define the Netlify API endpoint for deleting a DNS record
    api_endpoint = f"https://api.netlify.com/api/v1/dns_zones/{zone_id}/dns_records/{dns_record_id}"
 
    # Set up headers with authorization
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
 
    # Send a DELETE request to delete the DNS record
    response = requests.delete(api_endpoint, headers=headers)
 
    # Check if the request was successful
    if response.status_code == 204:
        print("DNS record deleted successfully")
    else:
        print(f"Failed to delete DNS record. Status code: {response.status_code}, Error: {response.text}")
 
 
def create_a_record(access_token, record_name, zone_id,public_ip):
    # Define the Netlify API endpoint for adding DNS records
    api_endpoint = f"https://api.netlify.com/api/v1/dns_zones/{zone_id}/dns_records"
 
    # Set up headers with authorization
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
 
    # Define the payload for creating the A record
    payload = {
        "type": "A",
        "hostname": record_name,
        "value": public_ip
    }
 
    # Send a POST request to create the A record
    response = requests.post(api_endpoint, headers=headers, json=payload)
 
    # Check if the request was successful
    if response.status_code == 201:
        print("A record created successfully")
    else:
        print(f"Failed to create A record. Status code: {response.status_code}, Error: {response.text}")
 
def lambda_handler(event,context):
    public_ip = get_instance_public_ip(instance_id)
    print(f"The public ip of instance-id {instance_id} is {public_ip}")
    zone_id = get_netlify_dns_zone_id(access_token, domain)
    print(f"DNS Zone ID for domain '{domain}': {zone_id}")
    dns_record_id = get_record_id(access_token,zone_id,record_type,record_name)
    print(f"The DNS Record ID of the Record {record_name} is {dns_record_id}")
    delete_dns_record(access_token,zone_id, dns_record_id)
    create_a_record(access_token, record_name,zone_id, public_ip)