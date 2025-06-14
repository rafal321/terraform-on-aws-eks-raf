https://community.aws/content/2sV2SNSoVeq23OvlyHN2eS6lJfa/amazon-eks-auto-mode-enabled-build-your-super-powered-cluster?lang=en

AWS re:Invent 2024 (playlist)
https://www.youtube.com/watch?v=JwzP8I8tdaY&list=PLiuJrLwgj9f7-lyFs2GgC9DwNVKT5-2PS

=============================================
what is the difference between Manage Built-in node pools general-purpose vs system on EKS?
----
In Amazon EKS Auto Mode, there are key differences between the "general-purpose" and "system" built-in node pools:

    Purpose:
        General-purpose: Designed for running your regular application workloads
        System: Specifically intended for critical cluster add-ons and system components

    Architecture support:
        General-purpose: Supports only AMD64 (x86_64) architecture
        System: Supports both AMD64 and ARM64 architectures

    Taints:
        General-purpose: No default taints, allowing any pods to be scheduled
        System: Has a "CriticalAddonsOnly" NoSchedule taint, which prevents regular workloads from running on these nodes   <-- RAF: IMPOTRANT

    Workload isolation:
        General-purpose: Used for most application workloads
        System: Provides dedicated resources for essential cluster components, improving stability by isolating system services from your application workloads

    Toleration requirements:
        General-purpose: No special tolerations needed for pods to be scheduled
        System: Pods must have a specific toleration for "CriticalAddonsOnly" to be scheduled on these nodes        <-- RAF: IMPOTRANT

    Use cases:
        General-purpose: Suitable for most applications and services you deploy
        System: Ideal for running EKS add-ons, CoreDNS, cluster autoscaler, and other critical cluster services

Both node pools use on-demand EC2 instances from the C, M, and R families (generation 5 or newer) and are managed automatically by EKS Auto Mode. The system node pool helps ensure that critical components have dedicated resources and aren't affected by resource contention from your application workloads, enhancing overall cluster stability.

When deploying workloads to your EKS cluster, you should consider using the appropriate node pool based on the criticality and resource requirements of your applications.
=============================================
can I change capacity-type for General-purpose node pool from on-demand to spot?

No, you cannot change the capacity type of the built-in General-purpose node pool in EKS Auto Mode from On-Demand to Spot instances. The built-in node pools in EKS Auto Mode have predefined configurations that cannot be modified in this way.

Here are the key limitations and alternatives:

    Built-in node pool limitations:
        The General-purpose and System node pools are built-in with fixed configurations
        You can only enable or disable these built-in node pools
        Core attributes like capacity type cannot be changed

    Alternatives for using Spot instances:
        Create a custom node pool that uses Spot instances
        Run your workloads across both the On-Demand General-purpose node pool and a custom Spot node pool

    Benefits of creating a custom Spot node pool:
        Significant cost savings (up to 90% off On-Demand prices)
        Ability to customize instance types and other configurations
        Can be tailored to specific workload requirements

    Best practices when using Spot instances:
        Implement proper pod disruption budgets
        Use the Kubernetes cluster autoscaler for dynamic scaling
        Configure diverse instance types to improve chances of fulfilling capacity
        Design applications to be fault-tolerant and handle potential interruptions

If cost optimization is your goal, creating a custom node pool with Spot instances alongside the built-in General-purpose node pool would be the recommended approach. This gives you the stability of On-Demand instances for critical workloads while leveraging the cost benefits of Spot instances for fault-tolerant applications.
===============================================
if I create custom node pools will they be managed by carpenter on EKS with automode?

Yes, if you create custom node pools in an EKS cluster with Auto Mode enabled, they will be managed by Karpenter. EKS Auto Mode leverages Karpenter under the hood for node provisioning and management.

Here's how custom node pools work with Karpenter in EKS Auto Mode:

    Integration with Karpenter:
        EKS Auto Mode uses Karpenter's APIs for node provisioning and lifecycle management
        Custom node pools you create will be managed by the same Karpenter instance that manages the built-in node pools

    Creating custom node pools:
        You can create custom NodePools alongside the default built-in node pools
        When creating a custom NodePool, you'll need to reference a valid NodeClass
        You can use the default NodeClass created by Auto Mode or create a custom one

    Customization options:
        Custom node pools allow you to specify requirements like:
            Instance types
            Availability zones
            Architectures (x86 or ARM)
            Capacity types (On-Demand or Spot)
            Labels and taints

    Management responsibilities:
        While you define the custom NodePool configuration, EKS Auto Mode and Karpenter will:
            Provision nodes based on your specifications
            Scale nodes up and down as needed
            Handle node lifecycle management
            Perform node replacement when necessary

    Benefits of custom node pools:
        Use Spot instances for cost optimization
        Specify different instance types for specific workloads
        Create node pools with specialized hardware (GPU, high memory, etc.)
        Isolate workloads using taints and tolerations

To verify your custom node pools are working properly after creation, you can use kubectl commands to check node status and monitor their behavior through the EKS console or Kubernetes API.

Remember that while custom node pools give you flexibility, the built-in node pools (general-purpose and system) still have fixed configurations that cannot be modified.


