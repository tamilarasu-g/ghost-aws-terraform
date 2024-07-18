import boto3
 
ec2_client = boto3.client('ec2', region_name='${aws-required-region}')
 
tag_key = "ghost"
tag_value = "true"
instance_id = '${instance-id}'
 
def get_root_volume_id(instance_id):
    # Describe instance
    response = ec2_client.describe_instances(
        InstanceIds=[instance_id]
    )
 
    # Get root volume ID
    root_volume_id = None
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            for block_device_mapping in instance['BlockDeviceMappings']:
                if block_device_mapping['DeviceName'] == instance['RootDeviceName']:
                    root_volume_id = block_device_mapping['Ebs']['VolumeId']
                    break
 
    return root_volume_id
 
def create_snapshot_with_tags(root_volume_id):
    response = ec2_client.create_snapshot(
        VolumeId=root_volume_id
    )
    snapshot_id = response['SnapshotId']
 
    ec2_client.create_tags(
        Resources=[snapshot_id],
        Tags= [ {'Key': tag_key, 'Value': tag_value}]
    )
 
    print(f"Snapshot {snapshot_id} created and tagged successfully")
 
def detach_and_delete_volume(instance_id, root_volume_id):
    # Detach the volume from the instance
    response_detach = ec2_client.detach_volume(
        VolumeId=root_volume_id,
        InstanceId=instance_id,
        Force=True
    )
 
    print(f"Volume {root_volume_id} detached from instance {instance_id} successfully")
 
    # Wait for the detachment to complete
    waiter = ec2_client.get_waiter('volume_available')
    waiter.wait(
        VolumeIds=[root_volume_id],
        WaiterConfig={
            'Delay': 10,
            'MaxAttempts': 30
        }
    )
 
    # Delete the volume
    response_delete = ec2_client.delete_volume(
        VolumeId=root_volume_id
    )
 
    print(f"Volume {root_volume_id} deleted successfully")
 
def lambda_handler(event,context):
    root_volume_id = get_root_volume_id(instance_id)
    create_snapshot_with_tags(root_volume_id)
    detach_and_delete_volume(instance_id,root_volume_id)