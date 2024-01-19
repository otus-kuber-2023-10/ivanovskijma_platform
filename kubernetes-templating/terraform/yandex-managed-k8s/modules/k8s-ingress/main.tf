resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  namespace = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  create_namespace = true
  atomic = true
}


resource "null_resource" "externalip" {
  triggers  =  { always_run = "${timestamp()}" }
  provisioner "local-exec" {
    command = "kubectl -n ingress-nginx get service/ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' > loadbalancerip.txt"
  }
  depends_on = [
    helm_release.ingress-nginx
  ]
}

data "local_file" "loadbalancer-ip" {
    filename = "loadbalancerip.txt"
  depends_on = [
    null_resource.externalip
  ]
}

resource "yandex_dns_zone" "zone1" {
  name        = "ivanovskijma-zone"
  zone             = "${var.domain-name}."
  public           = true
  depends_on = [
    data.local_file.loadbalancer-ip
  ]
}



resource "yandex_dns_recordset" "rs1" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "${var.domain-name}."
  type    = "A"
  ttl = 200
  data = [ "${data.local_file.loadbalancer-ip.content}" ]
}

resource "yandex_dns_recordset" "rs2" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "chartmuseum.${var.domain-name}."
  type    = "A"
  ttl = 200
  data = [ "${data.local_file.loadbalancer-ip.content}" ]
}

resource "yandex_dns_recordset" "rs3" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "harbor.${var.domain-name}."
  type    = "A"
  ttl = 200
  data = [ "${data.local_file.loadbalancer-ip.content}" ]
}

resource "yandex_dns_recordset" "rs4" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "shop.${var.domain-name}."
  type    = "A"
  ttl = 200
  data = [ "${data.local_file.loadbalancer-ip.content}" ]
}

# resource "yandex_dns_recordset" "rs4" {
#   zone_id = yandex_dns_zone.zone1.id
#   name    = "grafana.${var.domain-name}."
#   type    = "A"
#   ttl = 200
#   data = [ "${data.local_file.loadbalancer-ip.content}" ]
# }

# resource "helm_release" "cert-manager" {
#   name       = "cert-manager"
#   namespace = "cert-manager"
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
#   version = "1.13.2"
#   create_namespace = true
#   atomic = true
#   set {
#     name = "installCRDs"
#     value = true
#   }
#   depends_on = [
#     yandex_dns_recordset.rs1,
#     yandex_dns_recordset.rs2
#     # yandex_dns_recordset.rs3,
#     # yandex_dns_recordset.rs4
#   ]
# }


# resource "kubectl_manifest" "clusterissuer" {
#   yaml_body = <<YAML
# apiVersion: cert-manager.io/v1
# kind: ClusterIssuer
# metadata:
#   name: letsencrypt
#   namespace: cert-manager
# spec:
#   acme:
#     server: https://acme-v02.api.letsencrypt.org/directory
#     email: "${var.email}"
#     privateKeySecretRef:
#       name: letsencrypt
#     solvers:
#     - http01:
#         ingress:
#             class: nginx
# YAML
#   depends_on = [
#     helm_release.cert-manager
#   ]
# }
