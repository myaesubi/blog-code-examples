$releasesJSONURL = "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/2.2/releases.json"
$fileName = "dotnet-hosting-win.exe"
$outputFilePath = "$(Build.ArtifactStagingDirectory)\installer.exe"
$ErrorActionPreference = "Stop"


$webClient = new-Object System.Net.WebClient

# Load releases.json
$releases = $webClient.DownloadString($releasesJSONURL) | ConvertFrom-Json

# Select the latest release
$latestRelease = $releases.releases | Where-Object { $_.'aspnetcore-runtime'.'version' -eq $releases.'latest-runtime' -and $_.'release-date' -eq $releases.'latest-release-date' }

if ($latestRelease -eq $null)
{
    throw "No latest release found"
}

Write-Host Latest Release Version: $latestRelease.'release-version'
Write-Host Latest Release Date: $latestRelease.'release-date'

# Select the file to download
$file = $latestRelease.'aspnetcore-runtime'.'files' | Where-Object { $_.'name' -eq $fileName }

if ($file -eq $null)
{
    throw "File $fileName not found in latest release"
}

# Download the file
Write-Host Downloading $file.name from: $file.url
$webClient.DownloadFile($file.url, $outputFilePath)
Write-Host Downloaded $file.name to: $outputFilePath