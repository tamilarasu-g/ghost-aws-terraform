{
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": {
      "state": ["stopped"],
      "instance-id": ["${instance-id}"]
    }
  }