## Install Chaos Mesh using Helm
Source: https://chaos-mesh.org/docs/production-installation-using-helm/
        https://github.com/aws-samples/amazon-eks-chaos
```bash
helm search repo chaos-mesh
kubectl create ns chaos-mesh
helm install chaos-mesh chaos-mesh/chaos-mesh -n=chaos-mesh --version 2.7.2
helm upgrade chaos-mesh chaos-mesh/chaos-mesh -n=chaos-mesh --version 2.7.2 --set dashboard.securityMode=false
helm upgrade chaos-mesh chaos-mesh/chaos-mesh -n=chaos-mesh --version 2.7.2 --set dashboard.securityMode=true
# This allows to create experiments with kubectl
helm upgrade --install chaos-mesh chaos-mesh/chaos-mesh --namespace chaos-mesh --create-namespace --set dashboard.securityMode=false
--set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock
# amazon-eks-chaos
helm install chaos-mesh chaos-mesh/chaos-mesh -n=chaos-mesh --set chaosDaemon.runtime=containerd --set chaosDaemon.socketPath=/run/containerd/containerd.sock --version 2.7.2 --create-namespace --set dashboard.securityMode=false
```
## Uninstall Chaos Mesh
```bash
helm uninstall chaos-mesh -n chaos-mesh
```
kubectl -n chaos-mesh create token chaos-controller-manager

## Ingress
Placeholder

## Avaible CRDs
```
NAME                 SHORTNAMES  APIVERSION                NAMESPACED   KIND
awschaos                         chaos-mesh.org/v1alpha1   true         AWSChaos
azurechaos                       chaos-mesh.org/v1alpha1   true         AzureChaos
blockchaos                       chaos-mesh.org/v1alpha1   true         BlockChaos
dnschaos                         chaos-mesh.org/v1alpha1   true         DNSChaos
gcpchaos                         chaos-mesh.org/v1alpha1   true         GCPChaos
httpchaos                        chaos-mesh.org/v1alpha1   true         HTTPChaos
iochaos                          chaos-mesh.org/v1alpha1   true         IOChaos
jvmchaos                         chaos-mesh.org/v1alpha1   true         JVMChaos
kernelchaos                      chaos-mesh.org/v1alpha1   true         KernelChaos
networkchaos                     chaos-mesh.org/v1alpha1   true         NetworkChaos
physicalmachinechaos             chaos-mesh.org/v1alpha1   true         PhysicalMachineChaos
physicalmachines                 chaos-mesh.org/v1alpha1   true         PhysicalMachine
podchaos                         chaos-mesh.org/v1alpha1   true         PodChaos
podhttpchaos                     chaos-mesh.org/v1alpha1   true         PodHttpChaos
podiochaos                       chaos-mesh.org/v1alpha1   true         PodIOChaos
podnetworkchaos                  chaos-mesh.org/v1alpha1   true         PodNetworkChaos
remoteclusters                   chaos-mesh.org/v1alpha1   false        RemoteCluster
schedules                        chaos-mesh.org/v1alpha1   true         Schedule
statuschecks                     chaos-mesh.org/v1alpha1   true         StatusCheck
stresschaos                      chaos-mesh.org/v1alpha1   true         StressChaos
timechaos                        chaos-mesh.org/v1alpha1   true         TimeChaos
workflownodes        wfn         chaos-mesh.org/v1alpha1   true         WorkflowNode
workflows            wf          chaos-mesh.org/v1alpha1   true         Workflow
```
## Sample Experiments
Source: https://github.com/chaos-mesh/chaos-mesh/tree/master/examples

## Other
```bash
kubectl port-forward -n chaos-mesh svc/chaos-dashboard 2333:2333 [this works even if on EKS?]
http://localhost:2333/#/dashboard
# - - - - 
kubectl -n chaos-mesh create token chaos-controller-manager
kubectl auth can-i get endpoints --namespace=<chaos-mesh-installed-namespace> --as=system:serviceaccount:<chaos-mesh-installed-namespace>:chaos-controller-manager
```
## Other Resources
Kubernetes Chaos Mesh: A Guide (Medium)
https://overcast.blog/kubernetes-chaos-mesh-a-guide-662803fc1119

Manage User Permissions     (China - Documentation)
https://www.bookstack.cn/read/chaos-mesh-2.0.7-en/31707314c9f6f905.md