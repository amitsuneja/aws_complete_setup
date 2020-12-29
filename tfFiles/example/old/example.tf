 this data source to get IDs or IPs of Amazon EC2 instances to be referenced elsewhere, e.g. to allow easier migration from another management solution or to make it easier for an operator to connect through bastion host(s).




data "aws_instances" "test" {
  instance_tags = {
    Role = "HardWorker"
  }

  filter {
    name   = "instance.group-id"
    values = ["sg-12345678"]
  }

  instance_state_names = ["running", "stopped"]
}

resource "aws_eip" "test" {
  count    = length(data.aws_instances.test.ids)
  instance = data.aws_instances.test.ids[count.index]
}

