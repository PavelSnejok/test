# AWS EKS-cluster deployment with self-managed linux nodes
AWS EKS-cluster deployment is been carried out in the AWS cloud environment. The main steps of the deploymet process are: configure VPC network, setup IAM policy, configure securrity group, deployment EKS cluster, configure Worker Nodes, and Ingress-Nginx deployment.

:+1: For a more detailed explanation, you can refer to the following link that provides a depth-guide on ["Getting Started with AWS EKS"](https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs/guides/eks-getting-started)

## Diagram Structure :point_down:
![Diagram Structure](https://snejok.s3.amazonaws.com/images/Screenshot+2023-06-19+at+10.09.06+AM.png)

## Prerequisites and setup links 
  - [AWS account](https://aws.amazon.com/)
  - [AWS-CLI tool](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  - [Terraform](https://developer.hashicorp.com/terraform/downloads)
  - [Kubernetes](https://kubernetes.io/docs/tasks/tools/)
  - [Helm](https://helm.sh/docs/helm/helm_install/)

## Makefile usage
  1. Clone the repository to your local machine.
  2. Navigate to the project directory containing the Makefile.
  3. :point_right: **The Makefile allows you to select the environment (dev.tfvars or prod.tfvars) by modifying the ENVIRONMENT variable.**

  ```
  # Shows resources that will be deployed based on the environment.
  make plan

  # Deploys resources based on the environment. Requires confirmation before proceeding.
  make apply

  # Removes all resources created based on the environment.
  make destroy

  # Updates the kubeconfig file to access the EKS cluster.
  make config
  ```

## Ticket Overview

  **1. VPC:**
  - The VPC must have 3 Public subnets and 3 Private subnets. The EKS cluster needs to be deployed in the Public subnets, but we must be able to create any nodes and other Kubernetes resources in those subnets.
  - The VPC must have DNS hostname and DNS resolution support. Otherwise, nodes cannot register to your cluster.
  - Public subnets should have routes to the internet gateway to allow public access.
  - Private subnets should not have any additional routes.
  - Once your cluster is created, you cannot modify the subnets in which Amazon EKS creates its network interfaces.

  :boom::collision:**To ensure that your VPC functions properly within EKS cluster, you need to assign the following tags:**:boom::collision:
  - VPC itself:
    "kubernetes.io/cluster/${var.cluster_name}"  = "owned"
  - Public subnets
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
    "kubernetes.io/role/elb"                     = 1
  - Private subnets:
    "kubernetes.io/cluster/${var.cluster_name}"  = "shared"
    "kubernetes.io/role/internal-elb"            = 1
  - See more:
    - [kubernetes.io/cluster/my-cluster](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)
    - [kubernetes.io/role/internal-elb or kubernetes.io/role/elb](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html)


  **2. IAM Role and policy attachment that will use for the EKS cluster:**

  **List and Description of necessary policies that we will attach to the EKS cluster**
  - **AmazonEKSClusterPolicy:** This policy provides permissions required for managing the EKS cluster itself, including creating and updating resources related to the cluster.

  - **AmazonEKSServicePolicy:** It enables EKS to handle tasks such as provisioning networking components, managing security groups, and handling IAM roles and policies associated with your EKS cluster.

   **List and Description of necessary policies that we will attach to the Worker Nodes**
  - **AmazonEKSWorkerNodePolicy:** This policy provides necessary permissions for worker nodes to communicate with the EKS control plane, including accessing EKS APIs and resources.

  - **AmazonEC2ContainerRegistryReadOnly:** The policy allows read-only access to the Amazon ECR service, which is required for pulling container images from ECR repositories.

  - **AmazonEKS_CNI_Policy:** This policy enables the CNI (Container Network Interface) plugin to manage networking for containers running on EC2 instances in the EKS cluster.

  **3. Security Groups:**
  - **Security groups** focus on creating a security group for the EKS master cluster, Worker Nodes and RDS (Relational Database Service) instances that enables communication inside EKS cluster.


  **4. EKS cluster**
  - **AWS automatically creates Kubernetes Master.** This is where the EKS service comes into play. It requires a few operator managed resources beforehand so that Kubernetes can properly manage other AWS services as well as allow inbound networking communication from worker nodes.
  - **An add-on** is an extension or module that provides additional functionality to the Kubernetes cluster.
  - **Provider Kubernetes** is allows Terraform to interact with a Kubernetes cluster and manage Kubernetes resources.
  - **ConfigMap "aws-auth"** is commonly used in EKS clusters to configure role mappings for EC2 instances acting as worker nodes. It allows the nodes to join the cluster and assume the appropriate roles for their intended purposes.

  **5. Worker Node (EC2 instances)**
  - **IAM instance profile** is used to associate an IAM role with EC2 instances. 
  - **Launch template** is used to define the configuration parameters for EC2 instances that will be launched based on the template.
  - **Auto Scaling Group** is used to automatically scale the number of EC2 instances based on defined policies and conditions.

   **6. Nginx**
  - **Helm provider** allows you to manage the deployment and configuration of Helm charts in Kubernetes clusters. 
  - **Kubernetes_namespace** s used to create a namespace in Kubernetes. Namespaces provide a way to logically partition and isolate resources within a Kubernetes cluster.
  - **Helm_release** resource is used to deploy a Helm chart in Kubernetes using Terraform. In this case, the Helm chart being deployed is for the Ingress-Nginx controller, which is a popular solution for managing ingress rules in a Kubernetes cluster.

   **7. Locals**
  - By using configuration, you can set the **KUBECONFIG environment variable** to the content of the kubeconfig file, allowing kubectl to authenticate and interact with the specified EKS cluster.

## Structure
- ### README.md
- ### Makefile
- ### templates folder
  - **1_vpc.tf**
    - VPC (custom CIDR)
    - Subnets (custom CIDR)
      - 3 public subnets
      - 3 private subnets
    - Internet Gateway (IG)
    - Routing Tables
      - public routing table
      - private routing table
    - Table Associations 
      - public routing table association
      - private routing table association
  - **2_iam.tf**
    - Roles
      - EKS cluster role
      - EC2 (Worker) Node role
      - Jenkins secret access role
  - **3_sg.tf**
    - Security groups
      - EKS cluster security group 
      - EC2 (Worker) nodes security group
      - RDS security group
  - **4_eks.tf**
    - EKS cluster
    - Addons
      - coredns
      - vpc-cni
      - kube-proxy
      - aws-ebs-csi-driver
    - Configmap
      - aws-auth
  - **5_worker.tf**
    - EC2 (workers) node
      - instance profile (attach role to the worker nodes)
      - launch template
      - autoscaling group 
  - **6_nginx.tf**
    - Helm provider
    - Kubernetes namespace
    - deploy Helm "ingress-nginx"
  - **7_local.tf**
    - Contains data for kubeconfig file
  - **10_variables** 
    - Contains Variables for terraform files
  - **11_outputs.tf**
    - Contains Outputs for our needs
- ### module folder
  - **main.tf**
    - Provider (needs to be run within Terraform init)
    - Module
      - sample eks cluster (contain variables that use in this module)
  - **variables.tf**
    - Contain Variables for module and templates folders
  - **dev.tfvars**
    - Variables for dev stage
  - **prod.tfvars**
    - Variables for prod stage

## Workflow Structure Process :point_down:
![Workflow Structure Process](https://snejok.s3.amazonaws.com/images/Screenshot+2023-06-19+at+10.25.05+AM.png)


## Additional Diagram Structure for Kubernetes :point_down:
![Additional Diagram Structure](https://snejok.s3.amazonaws.com/images/Screenshot+2023-06-19+at+9.12.26+AM.png)