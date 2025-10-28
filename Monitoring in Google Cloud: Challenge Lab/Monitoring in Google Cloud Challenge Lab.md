### Run the following Commands in CloudShell

```
curl -LO https://raw.githubusercontent.com/chayandeokar/Cloud-Skills-2025/refs/heads/master/Monitoring%20in%20Google%20Cloud%3A%20Challenge%20Lab/arc115.sh

sudo chmod +x arc115.sh

./arc115.sh
```

### NOW FOLLOW INSTRUCTIONS.

* Go to `Create Uptime Check` from [here](https://console.cloud.google.com/monitoring/uptime/create?)

1. For Title: enter `chayandeokar`

* Go to `Dashboards` from [here](https://console.cloud.google.com/monitoring/dashboards?)

1. Add the first line chart that has a Resource metric filter, `CPU load (1m)`, for the VM.

2. Add a second line chart that has a Resource metric filter, `Requests`, for Apache Web Server.

* Go to `Create log-based metric` from [here](https://console.cloud.google.com/logs/metrics/edit?)

1. For Log-based metric name: enter `chayandeokar`

2. Paste The Following in `Build filter` & Replace PROJECT_ID
```
resource.type="gce_instance"
logName="projects/PROJECT_ID/logs/apache-access"
textPayload:"200"
```

3. Paste The Following in `Regular Expression` field:
```
execution took (\d+)
```

### Congratulations 🎉 for completing the Lab !
