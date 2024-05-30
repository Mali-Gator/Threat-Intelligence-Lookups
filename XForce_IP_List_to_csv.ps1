# Define the API key and base URL for IBM X-Force
$apiKey = "[INSERT API KEY HERE]"
$apiPassword = "[INSERT API PASSWORD HERE]"
$baseUrl = "https://api.xforce.ibmcloud.com"

# Encode the API key and password for Basic Authentication
$authInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${apiKey}:${apiPassword}"))

# Define input and output CSV file paths
$inputCsvPath = "input_ip_addresses.csv"
$outputCsvPath = "Xforce_IP_List_results.csv"

# Import the list of IP addresses from the input CSV
$ipList = Import-Csv -Path $inputCsvPath

# Initialize an array to store results
$results = @()

# Loop through each IP address and query the IBM X-Force API
foreach ($ip in $ipList) {
    $ipAddress = $ip.ip
    $apiUrl = "$baseUrl/ipr/$ipAddress"
    
    # Make the API request
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Headers @{ "Authorization" = "Basic $authInfo" } -Method Get
        
        # Extract the risk score from the response
        $riskScore = $response.score
        
        # Create an object with the IP address and risk score
        $result = [PSCustomObject]@{
            IP = $ipAddress
            RiskScore = $riskScore
        }
        
        # Add the result to the array
        $results += $result
    } catch {
        Write-Host "Failed to retrieve information for IP: $ipAddress"
        Write-Host $_.Exception.Message
    }
}

# Export the results to the output CSV file
$results | Export-Csv -Path $outputCsvPath -NoTypeInformation