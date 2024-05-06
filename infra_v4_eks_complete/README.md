to upgrade cluster

---error--------
Changes to Outputs:
  ~ cluster_version                                  = "1.28" -> "1.29"
╷
│ Error: query: failed to query with labels: secrets is forbidden: User "system:anonymous" cannot list resource "secrets" in API group "" in the namespace "kube-system"
│
│   with helm_release.loadbalancer_controller,
│   on e4_lbc_install.tf line 6, in resource "helm_release" "loadbalancer_controller":
│    6: resource "helm_release" "loadbalancer_controller" {
│
╵
╷
│ Error: query: failed to query with labels: secrets is forbidden: User "system:anonymous" cannot list resource "secrets" in API group "" in the namespace "kube-system"
│
│   with helm_release.external_dns,
│   on f3_external_dns.tf line 2, in resource "helm_release" "external_dns":
│    2: resource "helm_release" "external_dns" {
│
╵


---fix----------
mv e4_lbc_install.tf e4_lbc_install.tfBKP
mv f3_external_dns.tf f3_external_dns.tfBKP
terraform apply
vi a2_eks_variables.tf
upgrade cluster 1.28 > 1.29
mv e4_lbc_install.tfBKP e4_lbc_install.tf
mv f3_external_dns.tfBKP f3_external_dns.tf
terraform apply
