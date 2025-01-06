#!/bin/zsh

# Function to ping an IP address and return 0 if successful, 1 if failed
ping_ip() {
    local ip=$1
    # Ping with timeout of 1 second, 3 times, and suppress output
    ping -c 3 -W 1 $ip >/dev/null 2>&1
    return $?
}

# Loop through IP addresses
for i in {1..254}; do
    # Construct the IP address
    ip="192.168.10.$i"

    # Ping the IP address in the background
    (
        if ping_ip $ip; then
            echo $ip
        fi
    ) &

    # # Construct the IP address
    # ip="192.168.1.$i"
    #
    # # Ping the IP address in the background
    # (
    #     if ping_ip $ip; then
    #         echo $ip
    #     fi
    # ) &
done

# Wait for all background processes to complete
wait
