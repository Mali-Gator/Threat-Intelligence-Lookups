## This script looks up IP addresses in "input_ip_addresses.csv" against the AbuseCh FeodoTracker and ThreatFox database

# Read a list of IP addresses from a CSV file
$ipAddresses = import-csv -Path "input_ip_addresses.csv"

# Create an empty array to store the results
$results = @()

# Loop through each IP address in the input CSV file
foreach ($ip in $ipAddresses.IP) {
    # Create a custom object to store the IP address and results
    $result = [PSCustomObject]@{
        IP = $ip
    }

    # Query first website to check if the IP address is present in its blocklist
    $ipBlockList = Invoke-WebRequest -Uri "https://feodotracker.abuse.ch/downloads/ipblocklist.txt"
    $result | Add-Member -MemberType NoteProperty -Name "FeodoTracker" -Value ($ipBlockList.Content -match $ip)

    # Query second website to check if the IP address is present in its blocklist
    $ipBlockList = Invoke-WebRequest -Uri "https://threatfox.abuse.ch/export/json/ip-port/recent/"
    $result | Add-Member -MemberType NoteProperty -Name "ThreatFox" -Value ($ipBlockList.Content -match $ip)

    # Add the results for this IP address to the array
    $results += $result
}

# Write the results to a new CSV file
$results | export-csv -Path "Abuse_ch_list_results.csv" -NoTypeInformation
