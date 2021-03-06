Slave - Docker image for Jenkins slave creation & deploying
==========

Table of contents
-----------------
* [Installation](#installation)
    * [Ansible](#ansible)
       * [Automated](#automated)
       * [Manual](#manual)
    * [By the hands](#by-the-hands)


Installation
=====

First of all, you must create a slave on your Jenkins and set to `Launch agent via Java Web Start`. After that you'll get your secret ID which you have to expose to container via ENV

#### Clone this repo

`git clone https://github.com/Sudokamikaze/Slave.git`


Ansible
=====

### Automated

Just run `make` in root directory of the project

### Manual 

Run this command and answer some questions before we can start
```
ansible-playbook \
    playbooks/inventory_gen.yml
```

After that, execute main playbook by running this command:
```
ansible-playbook \
    --ask-become-pass \
    playbooks/slave_deploy.yml
```

By the hands
=====

There're some ENVs which have to be corrected:

ENV | Description
-------:|:-------------------------
Jenkins_Secret= | You'll find your unique ID in Jenkins slave creation menu
Jenkins_Node_Name= | Name that you'll set in Jenkins slave creation menu
Jenkins_Master_IP= | IP of your main node Jenkins
Jenkins_Master_Port | Port of it

When you acknowledged with this information let's begin building

#### Run docker build

```
    docker build \
    --no-cache \
    --build-arg Jenkins_Secret="Your_Secret here" \
    --build-arg Jenkins_Node_Name="Your node name here" \
    --build-arg Jenkins_Master_IP="Your Master Jenkins ip here" \
    --build-arg Jenkins_Master_Port="Your Master Jenkins port here" \
    -t slave:latest .
``` 
    DO NOT FORGET THE `.` 

#### Create volume for projects data

`docker volume create slave_data`

#### Issue `run` command

```
   docker run -d -v \
   slave_data:/home/jenkins \
   --name=Jenkins_slave \
   --restart=always \
   --network=pipe-to-slave \ # NOTE, THAT STEP IS OPTIONAL
   -e Jenkins_Secret="YOUR_ID" \
   -e Jenkins_Node_Name="YOUR NODE'S NAME" \
   -e Jenkins_Master_IP="YOUR JENKINS' IP" \
   -e Jenkins_Master_Port="YOUR JENKINS' PORT" \
   slave:latest
```

That's it! You've made it!

