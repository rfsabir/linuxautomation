#!/bin/bash

# Define the base IP address and network interface
BASE_IP="103.213.38."
INTERFACE="eth0"

# Loop through IP addresses from 1 to 14 and assign them to the interface
for ((i=1; i<=14; i++)); do
    sudo ip addr add $BASE_IP$i dev $INTERFACE
done
