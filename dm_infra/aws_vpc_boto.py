#!/usr/bin/python3.6

import json
import boto3
ec2 = boto3.resource('ec2', region_name='eu-west-1a')
client = boto3.client('ec2')

