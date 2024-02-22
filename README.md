# Devops-Project

This repository contains the following components:

1.  Simple Java Code
2.  Dockerfile
3.  Kubernetes manifests (`deployment.yaml` & `service.yaml`)
4.  Jenkinsfile (CI & CD)
5.  Terraform code

## Algorithm

### 1.  Create two EC2 servers: Master & Node using Terraform

    #### a. 'Master-Server' will have Java, Jenkins, Maven, Docker, Ansible, & Trivy packages
    #### b. 'Node-Server' will have Docker, Kubeadm & Kubernetes packages

### 2.  Establish passwordless connection between Master & Node

### 3.  Access Jenkins portal & add credentials in Jenkins portal as below:
        (Manage Jenkins --> Credentials --> System --> Global credentials)

    #### a. Dockerhub credentials - username & password (Use 'secret text' & save them separately)
    #### b. K8s server username with private key (Use 'SSH Username with private key')
    #### c. Add Github username & token (Generate Github token & save as 'secret key' in Jenkins server)
        (Github: Github settings --> Developer settings --> Personal Token classic --> Generate)
    #### d. Dockerhub token (optional) (Generate token & save as 'secret key')
        (Dockerhub: Account --> Settings --> Security --> Generate token & copy it)

### 4.  Also add required plugins in Jenkins portal, here we will require 'ssh agent' plugin to access the Node from the Master
        (Manage Jenkins --> Plugins --> Available plugins --> 'ssh agent' --> Install)

### 5.  Access Jenkins portal & paste the 'CI-pipeline' code
        #### Run
