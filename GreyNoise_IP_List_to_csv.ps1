# Define the API key and base URL
$apiKey = "[INSERT API KEY HERE]"
$baseURL = "https://api.greynoise.io/v3/community/"

# Define the input and output CSV file paths
$inputCSV = "input_ip_addresses.csv"
$outputCSV = "GreyNoise_IP_List_results.csv"

# Read the list of IP addresses from the input CSV file
$ipAddresses = Import-Csv -Path $inputCSV

# Initialize an empty array to store the results
$results = @()

# Loop through each IP address and query the GreyNoise API
foreach ($row in $ipAddresses) {
    $ip = $row.ip
    $url = $baseURL + $ip
    $headers = @{
        "accept" = "application/json"
        "key" = $apiKey
    }
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -Headers $headers
        $data = $response.Content | ConvertFrom-Json
        $result = [PSCustomObject]@{
            IP_Address      = $data.ip
            Noise           = $data.noise
            Likely_Clean    = $data.riot
            Classification  = $data.classification
            Name            = $data.name
            Link            = $data.link
            Last_Seen       = $data.last_seen
            Message         = $data.message
        }
    }
    catch {
        $result = [PSCustomObject]@{
            IP_Address      = $ip
            Noise           = $null
            Likely_Clean    = $null
            Classification  = $null
            Name            = $null
            Link            = $null
            Last_Seen       = $null
            Message         = "Error querying API: $_"
        }
    }
    $results += $result
}

# Convert the results array to a CSV and export it
$results | Export-Csv -Path $outputCSV -NoTypeInformation

Write-Output "Results have been written to $outputCSV"
