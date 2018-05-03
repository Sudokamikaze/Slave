Slave - Docker image for fast Jenkins slave creation
==========

Table of contents
-----------------
- [Installation](#installation)

Installation
------------

First of all, you must to create an slave on your Jenkins and set to `Launch agent via Java Web Start`

After that you'll get your secret ID which you need to expose to container via ENV

There's some ENVs which need to be corrected:

ENV | Description
-------:|:-------------------------
Jenkins_Secret= | You'll find your unique ID in Jenkins slave creation menu
Jenkins_Node_Name= | Name that you'll set in Jenkins slave creation menu
Jenkins_Master_IP= | IP of your main node Jenkins
Jenkins_Master_Port | Port of it

When you accnowledged with these information let's begin to initial procedures

#### Clone this repo

`https://github.com/Sudokamikaze/Slave.git`

#### Run docker build

```
    docker build \
    --build-arg Jenkins_Secret="Your_Secret here" \
    --build-arg Jenkins_Node_Name="Your node name here" \
    --build-arg Jenkins_Master_IP="Your Master Jenkins ip here" \
    --build-arg Jenkins_Master_Port="Your Master Jenkins port here" \
    -t slave:latest .
``` 
    DO NOT FORGET THE `.` 

#### Create volume for projects data

`docker volume create slave_data`

#### (Optional) Create isolated network

`docker network create pipe-to-slave`

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

