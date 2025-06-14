
https://k8s-dash.ops.perf.hosting.com/#/login
------------------------------------
I try to expose dashboard with aws alb controller but no luck 
https://github.com/kubernetes/dashboard/discussions/8522
# [1] kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
# [2] kubectl create clusterrolebinding dashboard-admin-binding --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-admin
    - Mountable secrets: <none> there is no token there, why?
    - You're right to point that out!  It seems like the ServiceAccount doesn't have a token associated with it yet. This can happen, especially in newer Kubernetes rsions (1.24 and later) where tokens are no longer automatically generated for ServiceAccounts.
    - You need to create a Secret of type kubernetes.io/service-account-token and associate it with your ServiceAccount.
# [3] -------------------
vi ashboard-token.yaml
apiVersion: v1
kind: Secret
metadata:
  name: dashboard-admin-token  # Choose a name for your secret
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: dashboard-admin # Your service account name
type: kubernetes.io/service-account-token

# [4] kubectl -n kubernetes-dashboard get secret dashboard-admin-token -o jsonpath='{.data.token}' | base64 -d
# [4] kubectl create token dashboard-admin

# ---------------------------------------------------------------------------------------------------
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard --insecure-bind-address=0.0.0.0 

### BING CHAT
To create an access token for the Kubernetes Dashboard, you'll need to follow these steps:

- [1*ok] Create a Service Account:
kubectl create serviceaccount kubernetes-dashboard-admin-sa -n kubernetes-dashboard

- [2*ok] Bind the Service Account to the Cluster Role:
kubectl create clusterrolebinding kubernetes-dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:kubernetes-dashboard-admin-sa

- [3*ok] Generate the Token: For Kubernetes versions 1.24 and above, you can directly create a token:
kubectl -n kubernetes-dashboard create token kubernetes-dashboard-admin-sa --duration=8h

---
investigate
kubectl exec -it kubernetes-dashboard-kong-78fd98d579-7zrqh -n kubernetes-dashboard -- kong config db_import /path/to/kong.yml
kubectl logs -n kubernetes-dashboard kubernetes-dashboard-kong-78fd98d579-7zrqh -c proxy
kubectl exec -it kubernetes-dashboard-kong-78fd98d579-7zrqh -n kubernetes-dashboard -- nslookup kubernetes-dashboard-web