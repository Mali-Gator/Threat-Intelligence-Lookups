# Define the path to the current directory
$scriptFolderPath = Get-Location

# Define the output CSV file path
$outputCsvPath = "$scriptFolderPath\CombinedResults.csv"

# Run each PowerShell script in the current directory except "IP_Whitelist_Scan.ps1"
$psScripts = Get-ChildItem -Path $scriptFolderPath -Filter "*.ps1" | Where-Object { $_.Name -ne "IP_Whitelist_Scan.ps1" }

foreach ($psScript in $psScripts) {
    Write-Host "Running script: $($psScript.FullName)"
    & $psScript.FullName
}

# Pause to ensure all scripts have finished running
Start-Sleep -Seconds 10

# Combine the CSV files into a single CSV file
# Get a list of CSV files in the current directory
$csvFiles = Get-ChildItem -Path $scriptFolderPath -Filter "*.csv"

# Initialize an array to hold all data
$allData = @()

# Loop through each CSV file and add its content to the array
foreach ($csvFile in $csvFiles) {
    $csvData = Import-Csv -Path $csvFile.FullName
    $allData += $csvData
}

# Export the combined data to a single CSV file
$allData | Export-Csv -Path $outputCsvPath -NoTypeInformation

Write-Host "All CSV files have been combined into $outputCsvPath"
