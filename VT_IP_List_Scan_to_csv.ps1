## This script uses the API key provided by the user to lookup IP addresses in "input_ip_addresses.csv" against the VirusTotal database

# Import the IP addresses from the CSV file
$ipAddresses = Import-Csv -Path "input_ip_addresses.csv" | ForEach-Object -Process { $_.ip }

# Set VirusTotal API key
$apikey = "[INSERT API KEY HERE]"

# Create an empty array to store the results
$results = @()

# Loop through each IP address
foreach ($ip in $ipAddresses) {
    # Use API to get report for IP address
    $headers = @{
        "x-apikey" = $apikey
    }

    $response = Invoke-RestMethod -Uri "https://www.virustotal.com/api/v3/ip_addresses/$ip" -Method GET -Headers $headers

    # Extract number of AV detections
    $detections = $response.data.attributes.last_analysis_stats.malicious

    # Add the IP address and number of detections to the results array
    $results += [pscustomobject]@{
        IP = $ip
        Detections = $detections
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "VT_IP_scan_results.csv" -NoTypeInformation
