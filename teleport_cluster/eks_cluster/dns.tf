# data "aws_route53_zone" "teleportdemo" {
#   name         = var.hosted_zone
# }

# data "kubernetes_service" "elb" {
#   metadata {
#     name = "${var.ingressname}-ingress-nginx-controller"
#   }
#   depends_on = [ helm_release.nginx ]
# }

# resource "aws_route53_record" "proxy" {
#   zone_id = data.aws_route53_zone.teleportdemo.zone_id
#   name    = var.cluster_fqdn
#   type    = "CNAME"
#   ttl     = "100"
#   records = [data.kubernetes_service.elb.status.0.load_balancer.0.ingress.0.hostname]
#   allow_overwrite = true
# }

# resource "aws_route53_record" "wildcard" {
#   zone_id = data.aws_route53_zone.teleportdemo.zone_id
#   name    = "*.${var.cluster_fqdn}"
#   type    = "CNAME"
#   ttl     = "100"
#   records = [data.kubernetes_service.elb.status.0.load_balancer.0.ingress.0.hostname]
#   allow_overwrite = true
# }