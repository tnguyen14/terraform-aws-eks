# EKS Cluster

Based on <https://github.com/hashicorp/learn-terraform-provision-eks-cluster/tree/8410795aab0bf6fb2128d1a9bbf95138e4b5ca3e>

Application Architecture <https://aws.amazon.com/getting-started/hands-on/deploy-kubernetes-app-amazon-eks/>

- VPC with public and private subnets
- EKS cluster
- ALB with a TLS certificate

This module currently does not include a Route53 DNS record for domain.

### IAM Permissions

In order to run this terraform, currently these permissions are used:

- `AmazonEC2FullAccess` - AWS managed policy
- `IAMFullAccess` - AWS managed policy
- `AmazonVPCFullAccess` - AWS managed policy
- `EKSFullAccess` - custom policy - allow `eks:*` on all resources
- `AWSCertificateManagerFullAccess` - AWS managed policy

These policies are needed for S3 backend storage

- `AmazonS3FullAccess`
- `AmazonDynamoDBFullAccess`

### Configure kubectl

Install `aws-iam-authenticator` as per https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html.

Get kubeconfig:

```sh
:; aws eks --region us-east-2 update-kubeconfig --name sonicledger --alias eks
:; kubectl config use-context eks
```

Modify the eks `user` section, from:

```yml
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - --region
      - us-east-2
      - eks
      - get-token
      - --cluster-name
      - sonicledger
      command: aws
```

to:

```yml
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - token
      - -i
      - sonicledger
      command: aws-iam-authenticator
      env:
      - name: AWS_PROFILE
        value: eks
```

According to <https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html>

> When an Amazon EKS cluster is created, the IAM entity (user or role) that creates the cluster is added to the Kubernetes RBAC authorization table as the administrator (with system:master permissions. Initially, only that IAM user can make calls to the Kubernetes API server using kubectl.

So add the credentials of the user used to create the cluster to `~/.aws/credentials`:

```
[eks]
aws_access_key_id =
aws_secret_access_key =
```

