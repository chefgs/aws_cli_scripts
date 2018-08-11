# Cloud Init Sample code Repo
## AWS EC2 Instance creation with cloud-init script passed as user_data 
### This code is the wrapper script which does the following
-  Creates 'n' number EC2 instances of type t2.micro with RHEL OS <br>
-  Each instance will be having below configurations set when the instances creation is completed <br>
   - Set a hostname on operating system level <br>
   - Install a package called “my-monitoring-agent”. Assume that the package repository is already configured <br>
   - Set the hostname in the configuration of the monitoring agent. Config file located at “/etc/mon-agent/agent.conf”  <br>
   - Ensure that the two users, “alice” and “bob”, exist and are part of the group “my-staff” <br>

### Goal
- The script can be used to create the bulk instances, applied with similar config across all the instances. Hence this can be considered as "Cattle" instance provisioning. <br>
- In case the instances needed to be updated with new config, they can be terminated in bulk <br>
- We can update the Chef config and can re-create the instances in bulk using the `create_instance.sh` script. <br>

### Technologies used
- `AWS CLI` command for instance creation <br>
- `Cloud-init` script passed in instance creation user_data section <br>
- `bash shell` scripting used to code the `cloud-init` script <br>
- `rpm-build` used for creation of dummy rpm package <br>
- `Chef` used for setting the required system state explained in item 2 above <br>
- `Github` used as source repo and git commands extensively used while development <br>
- `Chef-client` run in local-mode eliminating the need of Chef server. <br>

### Pre-requisite Setup
- AWS CLI setup / config
- Git for Linux or Gitbash for Windows setup required to access git and clone repos.

### Instance creation steps
- Setup SG rule for rhel in AWS
- Setup AWS keypair to be used for login to instance
- Clone the Cloud_init_sample repo 
- cd Cloud_init_sample
- Update the SG-rule name and key-pair name in the script
- Run `./create_instances.sh 1` . This command will create 1 EC2 instance of type t2.micro with RHEL OS <br>
- TBA > profile and subnet/sg param

### Terminate Instances
- Run `./terminate_instances.sh default` . This command will terminate all the instances available under account linked to default profile

### Source code repo details
[AWS CLI instance create repo](https://github.com/chefgs/aws_cli_scripts/tree/master/cloud_init_sample) <br>
[Chef cookbook repo](https://github.com/chefgs/cloud_init.git) <br>
[Dummy rpm create repo](https://github.com/chefgs/create_dummy_rpm.git) <br>

### Output details
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
