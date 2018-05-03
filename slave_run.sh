#!/bin/bash

echo "Starting jenkins slave agent..."

su -c "java -jar /bin/slave.jar -jnlpUrl http://$Jenkins_Master_IP:$Jenkins_Master_Port/computer/$Jenkins_Node_Name/slave-agent.jnlp -secret $Jenkins_Secret -workDir '/home/jenkins/'" slave