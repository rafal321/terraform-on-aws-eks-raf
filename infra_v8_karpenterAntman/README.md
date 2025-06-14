 Setup Karpenter in EKS using Terraform (2024) 
 https://www.youtube.com/watch?v=VaD-URDFZqM&t=2s

 - VPC
 - EKS
 - KARPENTER - submodule
___________________________________________
Q:  Why karpenter when deployed on aws eks needs sqs queue? why does it need an aws event?

Karpenter, when deployed on AWS EKS, utilizes an SQS queue and AWS EventBridge for a crucial purpose: interruption handling and graceful node draining.

Here's a breakdown of why they are needed:

1. SQS Queue (Amazon Simple Queue Service):

- Receiving Interruption Events: AWS sends various events that can impact EC2 instances (which are your EKS nodes). These include: 
    -- Spot Instance Interruption Warnings: If you're using AWS Spot Instances (which are cost-effective but can be reclaimed by AWS with a 2-minute notice), AWS sends a warning when an instance is about to be interrupted.
    -- Scheduled Maintenance Events: AWS might schedule maintenance on underlying hardware, requiring instances to be stopped or rebooted.
    -- Instance Rebalance Recommendations: AWS might recommend moving a Spot Instance to a different host to reduce the chance of interruption.
    -- Instance State Changes: Events related to an instance stopping or terminating.
- Decoupling and Reliability: An SQS queue acts as a buffer for these events. Instead of Karpenter directly polling AWS APIs for every potential interruption, EventBridge (explained next) pushes these events to the SQS queue. Karpenter then consumes messages from this queue. This offers several benefits: 
    -- Decoupling: Karpenter doesn't need to be tightly coupled to the AWS event source.
    -- Reliability: If Karpenter temporarily goes down, events will accumulate in the SQS queue and be processed when Karpenter recovers, preventing missed interruptions.
    -- Scalability: SQS is a highly scalable messaging service, ensuring event delivery even during peak activity.
2. AWS EventBridge:

- Centralized Event Bus: EventBridge acts as a serverless event bus that connects various AWS services and your applications.
- Routing Events to SQS: In the Karpenter context, EventBridge is configured with rules to capture specific AWS health, EC2, and other relevant events. These rules then route those captured events to the designated SQS queue that Karpenter monitors.
- Enabling Interruption Handling: By setting up EventBridge rules to forward these interruption and lifecycle events to the SQS queue, Karpenter can be informed in a timely manner when a node it manages is about to be affected.

How it works together:

1. AWS Generates an Event: For example, a Spot Instance interruption warning is issued for an EC2 instance that Karpenter provisioned as an EKS node.
2. EventBridge Captures the Event: A configured EventBridge rule matches this event.
3. EventBridge Sends to SQS: The EventBridge rule forwards the event details as a message to the Karpenter interruption SQS queue.
4. Karpenter Consumes from SQS: Karpenter continuously polls or receives notifications from the SQS queue.
5. Karpenter Takes Action: Upon receiving an interruption event, Karpenter can:
    - Taint the Node: Mark the node as "tainted" to prevent new pods from being scheduled on it.
    - Drain the Node: Evict existing pods from the node gracefully, allowing them to reschedule on other available nodes (or new nodes that Karpenter will provision).
    - Terminate the Node: Once the node is drained, Karpenter can safely terminate the EC2 instance, often before AWS reclaims it (in the case of Spot interruptions), minimizing disruption to your workloads.
    - Provision New Nodes: If needed, Karpenter will provision new nodes to replace the capacity being lost due to the interruption.

In summary, the SQS queue and AWS EventBridge are critical for Karpenter to effectively manage node lifecycle events, especially for handling disruptive events like Spot Instance interruptions, ensuring high availability and minimizing downtime for your EKS workloads.

______________________________________________
Q: does carpenter on aws eks tries to spread pods across avaiability zones?

Karpenter on AWS EKS does not automatically spread pods across Availability Zones (AZs) by default. Instead, Karpenter respects standard Kubernetes scheduling constraints, such as topology spread constraints, pod affinity/anti-affinity, and node affinity, which you can configure to achieve cross-AZ distribution

Key Points
    Default Behavior: Without explicit constraints, Karpenter will provision nodes in any available AZ based on resource availability and cost, but it does not guarantee that your pods will be evenly spread across AZs

______________________________________________
Q:  is kubernetes metrics server needed to be installed on eks automode cluster?

    Retrieving knowledge

No, the Kubernetes Metrics Server is not needed to be installed manually on an EKS Auto Mode cluster. EKS Auto Mode is designed to streamline cluster management by automatically handling many aspects of cluster operation, including metrics collection.

Key points about metrics in EKS Auto Mode:

    Built-in Metrics Collection: EKS Auto Mode includes built-in mechanisms for collecting and exposing essential metrics, eliminating the need for manual installation of the Kubernetes Metrics Server.

    Automatic Scaling Support: The integrated metrics collection in Auto Mode supports features like Horizontal Pod Autoscaler (HPA) and Vertical Pod Autoscaler (VPA) out of the box.

    Simplified Management: By including metrics collection as part of the managed service, EKS Auto Mode reduces the operational overhead for cluster administrators.

    Compatibility with Kubernetes APIs: The metrics collected by EKS Auto Mode are compatible with standard Kubernetes APIs, ensuring that your existing applications and tools will work as expected.

    Enhanced Monitoring: While basic metrics are included, you may still want to consider additional monitoring solutions like Amazon CloudWatch Container Insights for more comprehensive observability.


