#!/bin/bash

#################################
# DevMinds  Scaffolding
#################################

# Capture verbose output
set -o errexit
set -o nounset
set -o pipefail

######################################
# Check Keys and SG are exisiting 
######################################
rm -rf *.pem
SG_NAME="shopizer_sg"
KEY_NAME="shopizer_key"


#SG_CHK=`aws ec2 describe-security-groups --region eu-west-1 --output text | grep SECURITYGROUPS | grep $SG_NAME | awk '{print $4}'`
#KEY_CHK=`aws ec2 describe-key-pairs  --region eu-west-1 | grep $KEY_NAME | tr -s [:space:] | cut -d ':' -f2 | tr -d "\""`


#if [[ ${SG_CHK} == ${SG_NAME} ]]; then 
#    echo "SECURITY GROUP: $SG_NAME exists, please try another SG Name" 
#    #exit 
#fi 


#if [[ $KEY_CHK == $KEY_NAME ]]; then 
#    echo "KEY NAME: $KEY_NAME already exists, please try another KEY NAME" 
#    #exit 
#fi 

#######################################
# Get relevant values from custom vpc
# #####################################

LATEST_AMI_C7=`aws ec2 describe-images --owners 'aws-marketplace' --filters 'Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce' --query 'sort_by(Images, &CreationDate)[-1].[ImageId]' --output 'text' --region eu-west-1`

SUBNET_VPC_MAPPING=`aws ec2 describe-subnets --region eu-west-1 --output text | grep -vE "Terraform" | grep '\s\+\eu-west-1a' -A1 |  cut -f 3,12,13`
echo -n "$SUBNET_VPC_MAPPING"
echo 
echo "=============================================VPC/SUBNET Mapping=====================================================" 
echo 
echo 

read -p "Select VPCID from above available lists: " VPC_ID
read -p "Select SUBNET-ID from above available lists: " SUBNET_ID

echo $VPC_ID
echo $SUBNET_ID

#######################################
# Create Keys and SG
#######################################
SEC_CR=`aws ec2 create-security-group --group-name $SG_NAME --description "ecomm-fw" --vpc-id $VPC_ID --region eu-west-1`
KEY_PASS=`aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text --region eu-west-1 > $KEY_NAME.pem`


######################################
# Fetch Keys and SG ID 
######################################
SECG_ID=`aws ec2 describe-security-groups --region eu-west-1 --output text | grep "${SG_NAME}" | awk '{print $3}'`
KEYP_ID=`aws ec2 describe-key-pairs  --region eu-west-1 | grep ${KEY_NAME} | tr -s [:space:] | cut -d ':' -f2 | tr -d "\""`

#####################################
# Authorize Security Group Ports
#####################################
for i in 22 8080; do 
    aws ec2 authorize-security-group-ingress --group-id ${SECG_ID} --protocol tcp --port $i --cidr 0.0.0.0/0 --region eu-west-1
done

aws ec2 run-instances --image-id $LATEST_AMI_C7 --count 1 --instance-type t2.medium --key-name ${KEYP_ID} --security-group-ids ${SECG_ID} --subnet-id ${SUBNET_ID} --region eu-west-1  


####################################
# Login And Run Command for Shopizer
#####################################
echo ""
echo ""
echo "#================================================#"
echo "Waiting for instance to initialize..."
echo ""
echo ""
echo ""
sleep 150


USERNAME=centos
HOSTS=`aws ec2 describe-instances --region eu-west-1 --output text | grep "ASSOCIATION" | sort -u | awk '{print $3}'`
SCRIPT="cd /tmp ; pwd ; sudo yum install maven git wget update -y ; git clone https://github.com/dev-minds/dm_training_2019.git ; cd /tmp/dm_training_2019 ; git checkout develop ; cd /tmp/dm_training_2019/dm_ci/java/shopizer ;  mvn clean install ; cd /tmp/tmp/dm_training_2019/dm_ci/java/shopizer/sm-shop ; mvn spring-boot:run & "
KEYP="./${KEY_NAME}.pem"
chmod 0400 ${KEYP}

for HOSTIP in ${HOSTS} ; do 
    ssh -o StrictHostKeyChecking=no -i ${KEYP} ${USERNAME}@${HOSTS} "${SCRIPT}"
done 

