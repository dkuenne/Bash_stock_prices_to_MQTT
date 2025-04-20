#!/bin/bash

# Function to get the salt from the main JS file
get_salt() {
    # First get the main JS filename
    MAIN_JS=$(curl -s "https://www.boerse-frankfurt.de/" | grep -o 'main[^"]*\.js' | head -1)
    if [ -z "$MAIN_JS" ]; then
        echo "Error: Could not find main JS file" >&2
        exit 1
    fi

    # Then extract the salt from the JS file
    SALT=$(curl -s "https://www.boerse-frankfurt.de/$MAIN_JS" | grep -o 'salt:"[^"]*' | cut -d'"' -f2)
    if [ -z "$SALT" ]; then
        echo "Error: Could not extract salt" >&2
        exit 1
    fi
    echo "$SALT"
}

# Function to create authentication headers
create_headers() {
    local URL="$1"
    local TIME_UTC=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    local TIME_LOCAL=$(date +"%Y%m%d%H%M")
    
    # Create trace ID (md5 of time + url + salt)
    local TRACE_ID=$(echo -n "${TIME_UTC}${URL}${SALT}" | md5sum | cut -d' ' -f1)
    
    # Create security token (md5 of YYYYMMDDhhmm)
    local SECURITY=$(echo -n "$TIME_LOCAL" | md5sum | cut -d' ' -f1)
    
    # Return headers as a string for curl
    echo "-H 'authority: api.boerse-frankfurt.de' \
          -H 'accept: application/json, text/plain, */*' \
          -H 'origin: https://www.boerse-frankfurt.de' \
          -H 'referer: https://www.boerse-frankfurt.de/' \
          -H 'client-date: $TIME_UTC' \
          -H 'x-client-traceid: $TRACE_ID' \
          -H 'x-security: $SECURITY'"
}

# Main script
if [ $# -ne 1 ]; then
    echo "Usage: $0 ISIN"
    echo "Example: $0 DE0007100000"
    exit 1
fi

ISIN="$1"
SALT=$(get_salt)

# Create URL for price information
URL="https://api.boerse-frankfurt.de/v1/data/price_information?isin=${ISIN}&mic=XETR"

# Get headers
HEADERS=$(create_headers "$URL")

# Make the API request, extract price and send to MQTT
# sed: remove beginning string, jq: find value for JSON entry, tr: replace newline through space, cut: take only string before space character
PRICE=$(eval "curl -s $HEADERS '$URL'" | sed 's/^data://' | jq -r '.lastPrice' | tr '\n' ' ' | cut -d ' ' -f1)

# Send to MQTT server
mosquitto_pub -h IP-OR-HOSTNAME-HERE -t "sensors/stocks/${ISIN}" -m "{\"source\":\"stocks\",\"location\":\"xetra\",\"value\": ${PRICE}}"
