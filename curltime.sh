#!/bin/bash

usage() {
  echo -e "Usage: $0 [options...] <url> \n\
 -h, --help          Display help
 -s, --simple        Run in simple mode (no CSV output)
 -o, --output <path> Output path where to save results" 1>&2
  exit 1
}

simple=0
output=

while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    usage
    shift
    ;;
  -s | --simple)
    simple=1
    shift
    ;;
  -o | --output)
    output=$2
    shift 2
    ;;
  *)
    url=$1
    break
    shift
    ;;
  esac
done

# check if cURL is installed
if ! command -v curl &>/dev/null; then
  echo "cURL is not installed. Please install it to use this script."
  exit 1
fi

# if output is not set and simple is not set, show usage
if [ -z "$output" ] && [ -z "$simple" ]; then
  echo "Output path or simple mode is required."
  1>&2
  echo -e "Use -o or --output to specify the output path or -s or --simple to run in simple mode."
  exit 1
fi

if [ -z "$url" ]; then
  usage
fi

# if simple flag is set
if [ -n "$simple" ]; then
 curl -w @- -o /dev/null -s "$url" <<'EOF'
|                    0.000000s\n
| time_namelookup    %{time_namelookup}s\n
| time_connect       %{time_connect}s\n
| time_appconnect    %{time_appconnect}s\n
| time_pretransfer   %{time_pretransfer}s\n
| time_redirect      %{time_redirect}s\n
| time_starttransfer %{time_starttransfer}s\n
| time_total         %{time_total}s\n
EOF
  exit 0
fi

LOG_FILE=log.txt

echo "[1/4] Running cURL with trace output..."
curl -sS -L -o /dev/null --trace-ascii "$LOG_FILE" --trace-time "$url"

echo "[2/4] Parsing trace log..."

# Convert time to microseconds
time_to_us() {
  local time_str=$1
  IFS=':.'
  read -r hh mm ss us <<< "$time_str"
  echo $(( (10#$hh * 3600000000) + (10#$mm * 60000000) + (10#$ss * 1000000) + (10#$us)))
}

# Detect connection phase
detect_phase() {
  local desc="$1"

  shopt -s nocasematch
  if [[ $desc == *"resolve"* || $desc == *"name lookup"* ]]; then
    echo "DNS"
  elif [[ $desc == *"connected to"* || $desc == *"connect to"* || $desc == *"Trying"* ]]; then
    echo "TCP Connect"
  elif [[ $desc == *"TLS"* || $desc == *"SSL"* || $desc == *"Cipher"* || $desc == *"ALPN"* || $desc == *"Key"* || $desc == *"CAfile"* || $desc == *"Handshake"* ]]; then
    echo "SSL Handshake"
  elif [[ $desc == *"Send header"* || $desc == *"POST"* || $desc == *"GET"* || $desc == *"PUT"* || $desc == *"HEAD"* ]]; then
    echo "Request"
  elif [[ $desc == *"Recv header"* || $desc == *"HTTP/"* || $desc == *"Status:"* ]]; then
    echo "Response"
  elif [[ $desc == *"Upload"* || $desc == *"Download"* || $desc == *"Data"* || $desc == *"Received"* ]]; then
    echo "Transfer"
  else
    echo "Other"
  fi
  shopt -u nocasematch
}

echo "[3/4] Writing to CSV..."

# Build CSV
{
  echo "Timestamp,Time Elapsed (us),Self Duration (us),Type,Phase,Description"

  first_time=""
  grep -E "^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{6}" "$LOG_FILE" | while IFS= read -r line; do
    TIMESTAMP=$(echo "$line" | awk '{print $1}')
    REST=$(echo "$line" | cut -d' ' -f2-)

    # Type detection
    if [[ "$REST" =~ ^"== " ]]; then
      TYPE="Info"
      DESC=${REST#"== "}
    elif [[ "$REST" =~ ^"=> " ]]; then
      TYPE="Send"
      DESC=${REST#"=> "}
    elif [[ "$REST" =~ ^"<= " ]]; then
      TYPE="Receive"
      DESC=${REST#"<="}
    else
      TYPE="Other"
      DESC=$REST
    fi

    # Clean description
    DESC=$(echo "$DESC" | sed 's/^ *//; s/ *$//' | sed 's/"/""/g')

    # Time tracking
    current=$(time_to_us "$TIMESTAMP")
    if [ -z "$first_time" ]; then
      first_time=$current
      delta=0
    else
      delta=$((current - last_time))
    fi
    elapsed=$((current - first_time))
    last_time=$current

    # Phase
    PHASE=$(detect_phase "$DESC")

    echo "$TIMESTAMP,$elapsed,$delta,$TYPE,$PHASE,\"$DESC\""
  done
} > "$output"

echo "[4/4] Cleaning up..."
rm -f "$LOG_FILE"

echo "✅ Done! CSV created: $output"
