
Kubernetes Node Autoscaling with Karpenter (AWS EKS & Terraform) (Putra)
https://www.youtube.com/watch?v=C_YZXpXwtbg&t=94s
-------------------------------------------------------
AWS EKS Auto Mode, the Good, the Bad & the Costly
https://shirmon.medium.com/aws-eks-auto-mode-the-good-the-bad-the-costly-9db72333927c

EKS Auto Mode nodes are hard-capped at 110 pods, while originally nodes can support a lot more.
This limitation means you’ll need more nodes to handle the same amount of workloads, potentially driving up costs significantly.

You might expect a small increase in control plane costs as this includes extra managed services in the control plane, right?
Think again — it’s at least a whopping 12% premium on your data plane! That means an additional 12% cost for every instance running in EKS Auto Mode.

Why “at least” 12%? Because the AWS Auto Mode prices are not affected by instance discounts from Spot, RI, Savings plans ect. 
making it potentially even more than 12% premium if you’re utilizing these discounts

-------------------------------------------------------
Autoscaling EKS Cluster With Karpenter Using Terraform
https://blog.saintmalik.me/autoscaling-eks-karpenter/
