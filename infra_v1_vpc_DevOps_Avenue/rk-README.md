https://www.youtube.com/watch?v=385byZe8fM8



Amazon Q:

AWS Recommended CIDR Blocks for EKS: For secondary CIDR blocks to add to your VPC, AWS specifically recommends using CG-NAT (Carrier-Grade NAT) space:

    100.64.0.0/10 - This is the primary recommendation
    198.19.0.0/16 - Alternative option

These ranges are recommended because they're less likely to conflict with corporate networks compared to other RFC1918 ranges.

Recommended Solution:

    Add a secondary CIDR block: 100.64.0.0/16
    to your VPC

    Create 3 subnets from this new CIDR:
        Subnet 1: 100.64.0.0/19
        (8,192 IPs)
        Subnet 2: 100.64.32.0/19
        (8,192 IPs)
        Subnet 3: 100.64.64.0/19
        (8,192 IPs)

    Tag the new subnets with kubernetes.io/role/cni = 1
    for EKS subnet discovery

    Enable Enhanced Subnet Discovery in your VPC CNI (enabled by default since version 1.18.0)

Anton Putra
How To Structure Terraform Project (3 Levels)
https://www.youtube.com/watch?v=nMVXs8VnrF4
23:00 - We needt to remember the sequence we create resources.
        when you split terraform into multiple components we need to implement bash script or terragrunt
        bash script thats applies one component at a time or integrate it into CICD
        SCRIPT EXAMPLE
This is good approach, a lot of copy paste but makes operation a lot easier

NEXTT 25:30 2025-09-14
