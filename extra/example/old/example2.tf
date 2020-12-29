https://discuss.hashicorp.com/t/route53-srv-records/4069/2

Solved it - here is the code in case it helps someone out:

resource "aws_route53_record" "_servers" {
zone_id = aws_route53_zone.myzone.zone_id
name = "_servers._tcp"
type = "SRV"
ttl = 60
records = [for dns_name in data.aws_instance.myservers.private_dns : "0 10 9100 ${dns_name}."]
}
