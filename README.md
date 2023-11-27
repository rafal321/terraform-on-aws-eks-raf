# terraform-on-aws-eks-raf
Terraform on AWS EKS Kubernetes
based on "terraform-on-aws-eks" by Kalyan Reddy Daida | stacksimplify 

raf notes:
Prepare for faster disaster recovery: Deploy an Amazon Aurora global database with Terraform (Part 1)
https://aws.amazon.com/blogs/infrastructure-and-automation/disaster-recovery-deploy-amazon-aurora-global-database-with-terraform/

How we structure our Terraform project
https://blog.softup.co/how-we-structure-our-terraform-code/


[1] Each Terraform module should live in its own repository and versioning should be leveraged.
[2] Minimal structure: main.tf, variables.tf, outputs.tf.
[3] Use input and output variables (outputs can be accessed with module.module_name.output_name).
==================================================
==================================================
# DYNAMO DB

aws dynamodb list-tables
----
aws dynamodb describe-table --table-name terraform-raf-vpc
----
aws dynamodb describe-table --table-name $table_name | jq '.Table | del(.TableId, .TableArn, .ItemCount, .TableSizeBytes, .CreationDateTime, .TableStatus, .LatestStreamArn, .LatestStreamLabel, .ProvisionedThroughput.NumberOfDecreasesToday, .ProvisionedThroughput.LastIncreaseDateTime)' > schema.json
Parameter validation failed:
Unknown parameter in input: "TableClassSummary", must be one of: AttributeDefinitions, TableName, KeySchema, LocalSecondaryIndexes, GlobalSecondaryIndexes, BillingMode, ProvisionedThroughput, StreamSpecification, SSESpecification, Tags, TableClass, DeletionProtectionEnabled
Unknown parameter in ProvisionedThroughput: "LastDecreaseDateTime", must be one of: ReadCapacityUnits, WriteCapacityUnits
----
export table_name=terraform-raf-vpc
----
aws dynamodb delete-table --table-name $table_name
----
cat schema.json
{
  "AttributeDefinitions": [
    {
      "AttributeName": "LockID",
      "AttributeType": "S"
    }
  ],
  "TableName": "terraform-raf-vpc",
  "KeySchema": [
    {
      "AttributeName": "LockID",
      "KeyType": "HASH"
    }
  ],
  "ProvisionedThroughput": {
    "ReadCapacityUnits": 1,
    "WriteCapacityUnits": 1
  },
  "DeletionProtectionEnabled": false
}

----
aws dynamodb create-table --cli-input-json file://schema.json

===================================================

