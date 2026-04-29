#!/bin/bash

aws cloudformation create-stack \
  --stack-name wordpress-platform \
  --template-body file://cloudformation/00-vpc.yaml
