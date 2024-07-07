
##Pipelines

The infraestructure is ready to install the EMR cluster with Rstudio, an EFS filesystem for each user home directory and a two s3 shared directories.


In this folder is the code for EMR  Infraestructure 


- EMR Master ec2
- EMR Cluster ec2

### Variables


region: The region where infraestruture will be created
subnet_id: The subnet where 
country: The country code
resource: The resource name
team: Team name "devops|dev|data"
name: Freetext to explain the resource
sg: Security group for from main to join the cluster
efs_id: the efs id that will be mounted on the cluster
masterec2type: master ec2 type
clusterec2type: Cluster EC2 type (spot)
s3emr: The S3 Where users data config files are uploaded. 

### requirements
Before launch terraform, the followings files must be configured.
- users.sh script file with the booststrap code must be uploaded to the default s3emr in the /users directory 
- libraries file with all libraries that will be installed on EMR start
- policydata.json with the policy configuration for each EMR
- configurationEMR.json with the emr configuration for each EMR
 


### Features

- Support different volumes types  https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-supported-instance-types.html
- Support bootstrap bash or sh script
