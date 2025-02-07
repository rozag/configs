#!/bin/zsh

# Function to ping an IP address and return 0 if successful, 1 if failed
ping_ip() {
    local ip=$1
    # Ping with timeout of 1 second, 3 times, and suppress output
    ping -c 3 -W 1 $ip >/dev/null 2>&1
    return $?
}

# Function to send an HTTP GET request and check for Keenetic HTML page
check_keenetic() {
    local ip=$1
    # Send HTTP GET request with timeout of 60 seconds and check for Keenetic HTML page
    response=$(curl -s -m 60 $ip)
    if [[ $response == *"KeeneticOS Web Panel"* ]]; then
        echo $ip
        return 0
    fi
    return 1
}

# Loop through IP addresses
for i in {1..254}; do
    # Construct the IP address
    ip="192.168.10.$i"

    # Ping the IP address in the background
    (
        if ping_ip $ip; then
            if check_keenetic "http://$ip"; then
                exit 0
            fi
        fi
    ) &
done

# Wait for all background processes to complete
wait

# Check if any background process found the Keenetic router
if [[ $? -eq 0 ]]; then
    exit 0
else
    echo "Keenetic router not found on the network."
    exit 1
fi
