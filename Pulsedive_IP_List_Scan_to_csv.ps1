# Get API key and input CSV from user
$apiKey = "[INSERT API KEY HERE]"
$inputCsv = "input_ip_addresses.csv"

# Read the input CSV and store the IP addresses in an array
$ipAddresses = Import-Csv $inputCsv | Select-Object -ExpandProperty IP

$output = @()

# Loop through the IP addresses
foreach ($ip in $ipAddresses) {

    # Make GET request to Pulsedive API using the explorer endpoint with the IP address as the query
    $response = Invoke-WebRequest -Uri "https://pulsedive.com/api/explore.php?q=ioc=$ip&limit=10&pretty=1&key=$apiKey" -ErrorAction Stop

    # Check if the response is a valid json
    Write-Output $response.content
    $json = ConvertFrom-Json $response.Content
    $results = $json.results

    if ($results) {

        # Iterate through the results and extract the information
        foreach ($result in $results) {
            $indicator = $result.indicator
            $risk = $result.risk
            $type = $result.type
            $stamp_added = $result.stamp_added
            $stamp_updated = $result.stamp_updated
            $stamp_seen = $result.stamp_seen
            $geo = $result.summary.properties.geo
            $city = $geo.city
            $region = $geo.region
            $country = $geo.country
            $org = $geo.org
            #Create an object with the extracted information
            $obj = New-Object PSObject -Property @{
                IP = $ip
                Indicator = $indicator
                Risk = $risk
                Type = $type
                Stamp_Added = $stamp_added
                Stamp_Updated = $stamp_updated
                Stamp_Seen = $stamp_seen
                City = $city
                Region = $region
                Country = $country
                Org = $org
            }
            $output += $obj
        }
    }
    Start-Sleep -Seconds 2
}

# Output the information
$output

$output | Export-Csv -Path "pulsedive_ip_list_results.csv" -NoTypeInformation

