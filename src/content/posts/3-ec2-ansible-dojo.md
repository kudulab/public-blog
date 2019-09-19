+++
date = "2019-09-18"
title = "EC2 instance with Terraform and Ansible"
description = "Walkthrough on how to deploy and provision an AWS EC2 instance using Terraform, Ansible, Dojo and Docker"
math = "false"
series = []
author = "Ewa Czechowska"
+++

In this post we explain how to deploy an AWS EC2 instance using Terraform and then provision it using Ansible. Those tasks will be performed in multiple [Dojo](https://github.com/kudulab/dojo) docker images.

The supporting code may be found on [github](https://github.com/xmik/edu-aws-ansible). All the tools used are open source. The setup was tested on Ubuntu 18.04 LTS.

### Audience

You will be interested in this post if you:

* want to learn how to deploy [EC2 instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html) with [Terraform](https://www.terraform.io/)
* want to make your deployments from Docker, using [Dojo](https://github.com/kudulab/dojo)
* want to know how to provision a Virtual Machine using [Ansible](https://www.ansible.com/) and SSH

### Requirement

The requirement here is to:

* **deploy an EC2 instance and provision it**
* keep all the code in source control, applying **infrastructure-as-code**
* **automate** the deployment, so using GUI is not allowed
* be able to **perform the setup from different machines** while still using the same tools and their versions (e.g. on your laptop and on a CI server)
* **keep the costs low**

### Choice of Tools
#### Terraform
Terraform is a great tool if you want to automate your infrastructure and incorporate the Infrastructure-as-code process. It helps to deploy and destroy resources in a repetitive and reproducible way. It is also great if you are learning a new cloud (like AWS), because you can perform a lot of experiments, keep them in code and after some time: get back to them to in order to remind yourself the scenarios.

Besides, Terraform is a very popular tool, has numerous providers and the Internet is full of use cases and examples of how to work with it.

#### Ansible
It is a Configuration Management tool, achieving similar aims as Chef, Puppet or SaltStack. It is very easy to configure, minimal in nature and just nice to work with. [The Ansible's design goals](https://en.wikipedia.org/wiki/Ansible_(software)) are very important too, as we want to provision machines in a reliable, idempotent and secure way. Another essential advantages of Ansible are:

* the possibility of ad-hoc tasks execution and
* that the machine you want to provision is only required to have SSH server and python installed. (Sometimes SSH server is not even needed, e.g. when connecting to a docker container).

#### Dojo
Dojo is also open source (like all the tools used here) and it is written by us - KuduLab developers. It aims to provide a reproducible development environment including all the needed tools on any Linux/Mac machine. Thanks to that, you can version your development environment (by using a particular version of a particular Dojo Docker image) and you can ensure that the same environment is used on your development machine and on a CI server. Dojo was written **to minimize the problem of 'Works on my machine' situation**. Some real-life use-cases are:

* if you are a Software Developer and are working on a program e.g. written in Java and you want to try if your program works on a newer Gradle, all you need is to use a newer Dojo Docker image. E.g. if you need Gradle 4.10 - use `kudulab/openjdk-dojo:0.4.0`, but if you need Gradle 5.4.1 - use `kudulab/openjdk-dojo:1.1.0`.
* if you are doing some experiments, e.g. learning AWS and Terraform, you can use `kudulab/terraform-dojo:1.2.1`. Then, after 6 months, you can come back to these experiments and still use the same development environment, with the same Terraform version and its plugins setup.

### Requisites

In order to perform this setup you need to:

* have [Docker](https://www.docker.com/) installed
* have [Dojo](https://github.com/kudulab/dojo) installed
* configure AWS credentials. This can be done in many ways, e.g. in this file: `~/.aws/credentials` or by environment variables. Read [this](https://www.terraform.io/docs/providers/aws/index.html).
* git clone [this](https://github.com/xmik/edu-aws-ansible) github repository and change your current working directory to it

### Setup
#### SSH keypair

First, we need to generate a SSH keypair. We can do it locally:
```
$ key_owner="test"
$ mkdir -p secrets
$ ssh-keygen -q -b 2048 -t rsa -N '' -C ${key_owner} -f ./secrets/${key_owner}_id_rsa
```

We also need to change the permissions of the private key, so that SSH login is possible:
```
$ chmod 600 secrets/${key_owner}_id_rsa
```

#### Deploy EC2 instance

Next, we can deploy an EC2 instance and also a nondefault VPC. The instance will have access to the Internet, so that we can later provision it. The nondefault VPC is needed in order for us to have more control and understand the VPC concept better.

All the infrastructure deployment is done with a single command:
```
./tasks deploy
```

You can run this command many times and from the 2nd time on Terraform should return such output:
```
No changes. Infrastructure is up-to-date.
```
Which means that the infrastructure is not going to be changed.

---

Now, we are going to explain what this command `./tasks deploy` does. It uses a bash script: `tasks` from a local directory and invokes command `deploy` from that script. Here, the deployment is done using [docker-terraform-dojo](https://github.com/kudulab/docker-terraform-dojo). We need a Dojo configuration file, a Dojofile, to use Terraform from a Docker image. We name it `Dojofile.terraform` and apply such contents:
```
DOJO_DOCKER_IMAGE="kudulab/terraform-dojo:1.2.1"
```
and then, we can run `./tasks deploy` command which in turn runs:
```
$ dojo -c Dojofile.terraform
# all the commands below will be invoked in a dojo docker container
$ cd terraform/
$ terraform init
$ terraform get
$ terraform plan -out=tf.plan
$ terraform apply tf.plan
$ terraform output ec2_public_ip > ../ip.txt
```

**Warning:** the EC2 instance type used here is not covered by the AWS free tier, but a smaller type was chosen. If you want to use free tier, change the type to: `t2.micro`.

The last-invoked Terraform resource logs into the EC2 instance using SSH, so afterwards you should be able to SSH login yourself:
```
$ ssh -i secrets/test_id_rsa ubuntu@$(cat ip.txt)
```

Now, we have the EC2 instance and a VPC deployed.

#### Get more information about the instance (optional step)

Additionally you can use [docker-aws-dojo](https://github.com/kudulab/docker-aws-dojo) to check if the EC2 instance is running. First, create the `Dojofile.aws` with such contents:
```
DOJO_DOCKER_IMAGE="kudulab/aws-dojo:0.2.1"
```
and then, proceed with:
```
$ dojo -c Dojofile.aws
# all the commands below will be invoked in a dojo docker container
#
# using boto3 python library
$ python ./list-instances.py
Current region is: eu-west-1
('i-03b88bd67b04bacf4', {u'Code': 16, u'Name': 'running'})
#
# using awscli
$ aws ec2 describe-instances --filters "Name=tag:Name,Values=ec2-ansible-test"
{
    "Reservations": [
        {
            "Instances": [
                {
# ... removed the rest of the output for brevity
```

#### Provision EC2 instance with Ansible
In order to provision that EC2 instance, run:
```
./tasks provision
```

---

That command uses [docker-ansible-dojo](https://github.com/kudulab/docker-ansible-dojo). Such a Dojo configuration file `Dojofile.ansible` is needed:
```
DOJO_DOCKER_IMAGE="kudulab/ansible-dojo:1.1.0"
```
the command `./tasks provision` runs these commands:
```
$ dojo -c Dojofile.ansible
# all the commands below will be invoked in a dojo docker container
$ ansible-playbook -i ansible/hosts.yaml ansible/playbook.yaml -v -e "variable_ip=$(cat ip.txt)"
```

The `hosts.yaml` file needs a variable: `variable_ip`. That is why we needed to set `-e "variable_ip=$(cat ip.txt)"` to the `ansible-playbook` command:
```
$ cat ansible/hosts.yaml
all:
  hosts:
    myserver:
      ansible_connection: ssh
      ansible_host: "{{ variable_ip }}"
      ansible_user: ubuntu
      ansible_ssh_private_key_file: secrets/test_id_rsa
```

The Ansible playbook is supposed to (among other tasks) create a dummy file in the EC2 instance. You can verify that the file was indeed created:
```
$ ssh -i secrets/test_id_rsa ubuntu@$(cat ip.txt) "cat /tmp/hello"
Warning: Permanently added '<some-aws-public-ip>' (ECDSA) to the list of known hosts.
hi
```

#### Clean up (destroy the AWS resources)

When you decide that you are done with this setup and want to destroy all the AWS resources, run this command:
```
./tasks destroy
```

This command can also be run many times and nothing should be done from the 2nd time on, because all the Terraform resources should be destroyed already.

---

This command also uses `Dojofile.terraform` and it runs the following commands:
```
$ dojo -c Dojofile.terraform
# all the commands below will be invoked in a dojo docker container
$ cd terraform/
$ terraform plan -destroy -out=tf.plan
$ terraform apply tf.plan
```

### Summary

The requirement is met by the setup. Thanks to Dojo we don't have to provision our laptops with development tools needed to perform this setup. Dojo Docker images bring us the tools. Each step of the setup is run in a different Dojo Docker container. Terraform solves the problem of keeping Infrastructure as Code and Ansible is a very easy to set up Configuration Management tool.


The chosen solution seems easy enough to be later used in some production case and then tailored to a more demanding set of requirements.
