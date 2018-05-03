#!/bin/bash

echo "Starting jenkins slave agent..."

su -c "java -jar /usr/share/jenkins/slave.jar -jnlpUrl https://172.20.0.2/computer/Builder/slave-agent.jnlp -secret $JENKINS_AUTH_TOKEN" slave