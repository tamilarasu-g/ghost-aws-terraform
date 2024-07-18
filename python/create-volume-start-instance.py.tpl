import boto3
import time
 
ec2_client = boto3.client('ec2', region_name='${aws-required-region}')
tag_key = 'ghost'
tag_value = 'true'
instance_id = '${instance-id}'
device_name = '${root-device-name}' # For ubuntu the root device is /dev/sda1. Check for your ami and replace this
 
def get_instance_availability_zone(instance_id):
    # Describe the instance
    response = ec2_client.describe_instances(InstanceIds=[instance_id])
 
    # Extract the availability zone from the response
    if 'Reservations' in response and len(response['Reservations']) > 0:
        instance = response['Reservations'][0]['Instances'][0]
        availability_zone = instance['Placement']['AvailabilityZone']
        return availability_zone
    else:
        return None
 
def get_latest_snapshot_id(ec2_client, tag_key, tag_value):
    response = ec2_client.describe_snapshots(Filters=[{'Name': 'tag:' + tag_key, 'Values': [tag_value]}])
    
    # Extracting snapshot information
    snapshots = response['Snapshots']
    
    # Sort snapshots based on start time in descending order
    sorted_snapshots = sorted(snapshots, key=lambda x: x['StartTime'], reverse=True)
    
    if sorted_snapshots:
        latest_snapshot_id = sorted_snapshots[0]['SnapshotId']
        return latest_snapshot_id
    else:
        return None
        
    print("Latest SnapshotId is : ",latest_snapshot_id)
 
def create_volume_from_snapshot(snapshot_id, availability_zone):
    # Create a volume from the snapshot
    volume_response = ec2_client.create_volume(
        SnapshotId=snapshot_id,
        AvailabilityZone=availability_zone,
        TagSpecifications=[
            {
                'ResourceType': 'volume',
                'Tags': [ {'Key': tag_key, 'Value': tag_value}]
            }
        ]
        # Add any other desired parameters here, such as VolumeType or Size
    )
    volume_id = volume_response['VolumeId']
    print("Volume ID is : ",volume_id)
    return volume_id
 
def wait_until_volume_available(volume_id, ec2_client):
    while True:
        volume_response = ec2_client.describe_volumes(VolumeIds=[volume_id])
        volume_state = volume_response['Volumes'][0]['State']
        if volume_state == 'available':
            print("Volume ID : ",volume_id, "is available")
            break
        print(f"Volume {volume_id} is in state {volume_state}. Waiting...")
        time.sleep(5)
 
def attach_root_volume(instance_id, volume_id, device_name):
    attach_response = ec2_client.attach_volume(
        Device=device_name,
        InstanceId=instance_id,
        VolumeId=volume_id
    )
    print(attach_response)
    
def start_ec2_instance(instance_id):
    response = ec2_client.start_instances(
        InstanceIds=[instance_id]
    )
    print(response)
 
def lambda_handler(event,context):
    snapshot_id = get_latest_snapshot_id(ec2_client, tag_key, tag_value)
    availability_zone = get_instance_availability_zone(instance_id)
    volume_id = create_volume_from_snapshot(snapshot_id,availability_zone)
    wait_until_volume_available(volume_id,ec2_client)
    attach_root_volume(instance_id, volume_id,device_name)
    start_ec2_instance(instance_id)