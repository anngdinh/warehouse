# #!/bin/bash

# # Get the PIDs for processes containing "vmo" or "dog" in their names
# pids=$(pgrep -d, -f "vmo|dog")

# # Run top with the specified PIDs and process the output
# top -b -n 1 -p "$pids" | while IFS= read -r line; do
#   if [[ "$line" == *"$pids"* ]]; then
#     echo "PID: $(echo "$line" | awk '{print $1}'), CPU Usage: $(echo "$line" | awk '{print $9}')"
#   fi
# done



#!/bin/bash
# z=$(ps aux)
# z=$(top -p $(pgrep -d, -f "vmo|datadog-agent/bin"))
pids=$(pgrep -d, -f "vmo|datadog-agent/bin")
z=$(top -b -n 1 -p "$pids" | tail -n +7)  # Skip the first 6 lines
while read -r z
do
   var=$var$(awk '{print "cpu_usage{command=\""$12"\", pid=\""$1"\"}", $9z}');
done <<< "$z"

echo "$var"
# curl -X POST -H  "Content-Type: text/plain" --data "$var" http://10.76.0.131:9091/metrics/job/top/instance/machine




# #!/bin/bash

# # Get the PIDs for processes containing "vmo" or "datadog-agent/bin" in their names
# pids=$(pgrep -d, -f "vmo|datadog-agent/bin")

# # Run top with the specified PIDs
# z=$(top -b -n 1 -p "$pids")

# # Process the output to extract and format CPU usage information
# var=""
# echo "$z" | tail -n +8 | while IFS= read -r line; do
#   if [[ "$line" == *"$pids"* ]]; then
#     var="$var $(awk '{print "cpu_usage{command=\"" $12 "\", pid=\"" $1 "\"}", $9}')"
#   fi
# done

# echo "$var"