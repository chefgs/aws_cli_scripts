# Cloud Init Sample code Repo
## AWS EC2 Instance creation with cloud-init script passed as user_data 
### This code is the wrapper script which does the following
-  Creates 'n' number EC2 instances of type t2.micro with RHEL OS <br>
-  Each instance will be having below configurations set when the instances creation is completed <br>
   - Set a hostname on operating system level <br>
   - Install a package called “my-monitoring-agent”. Assume that the package repository is already configured <br>
   - Set the hostname in the configuration of the monitoring agent. Config file located at “/etc/mon-agent/agent.conf”  <br>
   - Ensure that the two users, “alice” and “bob”, exist and are part of the group “my-staff” <br>

### Technologies used
- `AWS CLI` command for instance creation <br>
- `Cloud-init` script passed in instance creation user_data section <br>
- `bash shell` scripting used to code the `cloud-init` script <br>
- `rpm-build` used for creation of dummy rpm package <br>
- `Chef` used for setting the required system state explained in item 2 above <br>
- `Github` used as source repo and git commands extensively used while development <br>
- `Chef-client` run in local-mode eliminating the need of Chef server. <br>

### Instance creation steps
- AWS CLI setup / config
- Git installation, if git not available
- Setup SG rule for rhel in AWS
- Setup AWS keypair to be used for login to instance
- Clone the Cloud_init_sample repo 
- cd Cloud_init_sample
- Update the SG-rule name and key-pair name in the script
- Run `./create_instance 1` . This command will create 1 EC2 instance of type t2.micro with RHEL OS <br>

### Source code repo details
[AWS CLI instance create repo](https://github.com/chefgs/aws_cli_scripts/tree/master/cloud_init_sample) <br>
[Chef cookbook repo](https://github.com/chefgs/cloud_init.git) <br>
[Dummy rpm create repo](https://github.com/chefgs/create_dummy_rpm.git) <br>
