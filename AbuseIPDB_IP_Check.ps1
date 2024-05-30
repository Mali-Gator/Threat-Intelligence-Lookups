$apiKey = "[INSERT API KEY HERE]"

# Import the IP addresses from the CSV file
$ipAddresses = Import-Csv -Path "input_ip_addresses.csv" | ForEach-Object -Process { $_.ip }

# Print the IP addresses to the console
Write-Host "IP addresses: $($ipAddresses | ConvertTo-Json -Depth 4)"

# Create an empty array to store the scan results
$results = @()

# Loop through each IP address
foreach ($ipAddress in $ipAddresses) {
  # Set the request body
  $body = @{
    ipAddress = $ipAddress
  }

  # Set the request headers
  $headers = @{
    Key = $apiKey
    Accept = "application/json"
  }

  # Send the request to the API
  $response = Invoke-RestMethod -Uri "https://api.abuseipdb.com/api/v2/check?ipAddress=$ipAddress" -Method GET -Headers $headers

  # Print the IP address and response data to the console
  Write-Host "IP address: $ipAddress"
  Write-Host "Response data: $($response.data | ConvertTo-Json -Depth 4)"

  # Store the scan results
  $results += $response.data
}

# Export the results to a CSV file
$results | Export-Csv -Path "AbuseIPDB_results.csv" -NoTypeInformation
