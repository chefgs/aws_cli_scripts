# Cloud Init Sample code Repo
## 1. AWS EC2 Instance creation with cloud-init script passed as user_data 
### `create_instance.sh` is the wrapper script which does the following
-  Creates 'n' number EC2 instances of type t2.micro with RHEL 7 OS <br>
-  Each instance will be having below configurations set when the instances creation is completed <br>
   - Set a hostname on operating system level <br>
   - Install a package called “my-monitoring-agent”. Assume that the package repository is already configured <br>
   - Set the hostname in the configuration of the monitoring agent. Config file located at “/etc/mon-agent/agent.conf”  <br>
   - Ensure that the two users, “alice” and “bob”, exist and are part of the group “my-staff” <br>
- Also the instances will be assigned with tag name 'DEMO', so all instances will be grouped under the tag and can be deleted easily later (if not required)

### Goal
- The script can be used to create the bulk instances, applied with similar config across all the instances. Hence achieving the goal of "Cattle" instance provisioning. <br>
- In case the instances needed to be updated with new config, We can update the new config as code in Chef recipe. <br>
- We can terminate all previously created instances and then can re-create the instances in bulk by simply executing the script. <br>

### Technologies used
- `AWS CLI` command for instance creation <br>
- `Cloud-init` script passed in instance creation user_data section <br>
- `bash shell` scripting used to code the `cloud-init` script <br>
- `rpm-build` used for creation of dummy rpm package <br>
- `Chef` used for setting the required system state explained in item 2 above <br>
- `Github` used as source repo and git commands extensively used while development <br>
- `Chef-client` run in local-mode eliminating the need of Chef server. <br>

### Script functionality explained
- `Create_instance.sh` script uses the AWS CLI command to invoke the resource creation in AWS.
- The AWS CLI command for instance creation is `aws ec2 run-instance`. 
- We are sending the `install.txt` file as an option in AWS CLI user-data and the script is executed by `Cloud-init` process when the EC2 instance is created.
- The `install.txt` has the code for installing the required installers, checking out repo from git and running Chef client command to set the desired VM config   

## 2. Instance creation steps Explained
### Pre-requisite Setup
- AWS CLI setup / config : <a href="https://docs.aws.amazon.com/cli/latest/userguide/installing.html">AWS CLI</a> and <a href="https://docs.aws.amazon.com/cli/latest/reference/configure/">Configure CLI</a><br>
- Install Git for Linux using the command `yum install git -y` or <br>
- <a href="https://git-scm.com/downloads">Git Bash for Windows</a> to access Git repo and to run the shell script in Windows. 

### Pre-requisite for running resource creation script
- Setup Security group rule for rhel in AWS. In-bound SG rule with SSH port 22 should be enabled.  
- Setup AWS keypair to be used for login to instance

### Script running procedure
- Clone the cloud_init_sample repo 
- cd cloud_init_sample
- Fetch the SG-rule name and key-pair name by executing the script `./get_sg_key.sh`
- Example script execution command structure, `./create_instance.sh 1 rhel_sg_rule myaws_key` .  This command will create 1 EC2 instance of type t2.micro with RHEL OS <br>

## 3. Terminate Instances
- Run `./terminate_instances.sh` . This command will terminate all the instances with tag name "DEMO".

## 4. Source code repo details making this entire functionality
- I've pushed all the source code in Github, <br>
[AWS CLI instance create repo](https://github.com/chefgs/aws_cli_scripts/tree/master/cloud_init_sample) <br>
[Chef cookbook repo](https://github.com/chefgs/cloud_init.git) <br>
[Dummy rpm create repo](https://github.com/chefgs/create_dummy_rpm.git) <br>

## 5. Best practices followed
- Cloud-init and Chef run outputs are captured in log to identify any script failures.
- Cloud-init output is redirected to the path `/var/log/userdata.out`
- Chef-client output is redirected to the path `/var/log/chefrun.out`
- Shell script has been coded with validation check to avoid the error scenarios
- Chef cookbook coded with below best practices,
  - Variables stored as attributes
  - Gaurd check has been added while installing RPM from local path
- Enough comment has been added in all the scripts for anyone to understand the code.
- Every source code has been preserved in Github SCM. 
- Enitre repo detail has been documented in Github readme.

## 6. Output details
#### Hostname set in OS and agent.conf
```
[root@cloud-init-server log]# hostname
cloud-init-server
[root@cloud-init-server log]# cat /etc/mon-agent/agent.conf
hostname="cloud-init-server"
```
#### RPM package added
```
[root@cloud-init-server log]# rpm -qa | grep monitor
my-monitoring-agent-1.0-1.noarch
```
#### Group and users added
```
[root@cloud-init-server]# cat /etc/group | grep my-staff
my-staff:x:1001:

[root@cloud-init-server]# cat /etc/passwd | grep 1001
alice:x:1001:1001::/home/alice:/bin/bash
bob:x:1002:1001::/home/bob:/bin/bash
```
#### Chef client run sets the desired config state, while the instance is created
```
[2018-08-11T02:23:17+00:00] WARN: No config file found or specified on command line, using command line options.
Starting Chef Client, version 14.3.37
[2018-08-11T02:23:19+00:00] WARN: Run List override has been provided.
[2018-08-11T02:23:19+00:00] WARN: Original Run List: []
[2018-08-11T02:23:19+00:00] WARN: Overridden Run List: [recipe[cloud_init]]
resolving cookbooks for run list: ["cloud_init"]
Synchronizing Cookbooks:
  - cloud_init (0.1.0)
Installing Cookbook Gems:
Compiling Cookbooks...
Recipe: cloud_init::default
  * hostname[cloud-init-server] action set
    * ohai[reload hostname] action nothing (skipped due to action :nothing)
    * execute[set hostname to cloud-init-server] action run
      - execute /bin/hostname cloud-init-server
    * file[/etc/hosts] action create
      - update content in file /etc/hosts from 6768ce to 4f1182
      --- /etc/hosts    2018-03-23 17:51:30.543000000 +0000
      +++ /etc/.chef-hosts20180811-1377-136lrva 2018-08-11 02:23:19.402334478 +0000
      @@ -1,4 +1,4 @@
       127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
       ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
      -
      +172.31.25.53 cloud-init-server cloud-init-server
      - restore selinux security context
    * execute[hostnamectl set-hostname cloud-init-server] action run
      - execute hostnamectl set-hostname cloud-init-server
    * ohai[reload hostname] action reload
      - re-run ohai and merge results into node attributes

  Converging 7 resources
  * hostname[cloud-init-server] action set
    * ohai[reload hostname] action nothing (skipped due to action :nothing)
    * execute[set hostname to cloud-init-server] action run (skipped due to not_if)
    * file[/etc/hosts] action create (skipped due to not_if)
    * execute[hostnamectl set-hostname cloud-init-server] action run (skipped due to not_if)
     (up to date)
  * rpm_package[my-monitoring-agent] action install
    - install version 1.0-1 of package my-monitoring-agent
  * directory[/etc/mon-agent/] action create
    - create new directory /etc/mon-agent/
    - restore selinux security context
  * template[/etc/mon-agent/agent.conf] action create
    - create new file /etc/mon-agent/agent.conf
    - update content in file /etc/mon-agent/agent.conf from none to e38ed0
    --- /etc/mon-agent/agent.conf       2018-08-11 02:23:19.810334478 +0000
    +++ /etc/mon-agent/.chef-agent20180811-1377-5g91rv.conf     2018-08-11 02:23:19.809334478 +0000
    @@ -1 +1,2 @@
    +hostname="cloud-init-server"
    - restore selinux security context
  * group[my-staff] action create
    - create group my-staff
  * linux_user[alice] action create
    - create user alice
  * linux_user[bob] action create
    - create user bob
[2018-08-11T02:23:19+00:00] WARN: Skipping final node save because override_runlist was given

Running handlers:
Running handlers complete
Chef Client finished, 11/17 resources updated in 01 seconds

```

## 7. Possible alternatives of Chef
- The instance desired state configuration could also be possible with Chef "kind-of" alternative technologies like Puppet or Ansible etc.
- So with the same `install.txt` script as a base, it can be modified to alternative Infra as code tool installation and execution.