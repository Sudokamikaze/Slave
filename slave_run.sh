#!/bin/bash

echo "Starting jenkins slave agent..."

su -c "java -jar /bin/slave.jar -jnlpUrl http://172.20.0.2:8090/computer/Builder/slave-agent.jnlp -secret $Jenkins_Secret -workDir '/home/jenkins/'" slave