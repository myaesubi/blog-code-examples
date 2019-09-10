$ErrorActionPreference = "Stop"

$dotNetVersion = "2.2"
$releasesJSONURL = "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/" + $dotNetVersion + "/releases.json"
$fileName = "dotnet-hosting-win.exe"
$installerFilePath = Join-Path "$(System.DefaultWorkingDirectory)" $fileName
$installerLogFilePath = "C:\tmp\net-core-install.txt"


Write-Host ARGUMENTS:
Write-Host `t dotNetVersion: $dotNetVersion
Write-Host `t releasesJSONURL: $releasesJSONURL
Write-Host `t fileName: $fileName
Write-Host `t installerFilePath: $installerFilePath
Write-Host `t installerLogFilePath: $installerLogFilePath


$webClient = new-Object System.Net.WebClient

# Load releases.json
Write-Host Load release data from: $releasesJSONURL
$releases = $webClient.DownloadString($releasesJSONURL) | ConvertFrom-Json
      
Write-Host Latest Release Version: $releases.'latest-runtime'
Write-Host Latest Release Date: $releases.'latest-release-date'


# Select the latest release
$latestRelease = $releases.releases | Where-Object { ($_.'aspnetcore-runtime'.'version' -eq $releases.'latest-runtime') -and ($_.'release-date' -eq $releases.'latest-release-date') }
      
if ($latestRelease -eq $null)
{
    throw "No latest release found"
}


# Select the installer to download
$file = $latestRelease.'aspnetcore-runtime'.files | Where-Object { $_.name -eq $fileName }
      
if ($file -eq $null)
{
    throw "File $fileName not found in latest release"
}


# Download installer
Write-Host Downloading $file.name from: $file.url
$webClient.DownloadFile($file.url, $installerFilePath)
Write-Host Downloaded $file.name to: $installerFilePath


# Execute installer
$installationArguments = "/passive /log $installerLogFilePath"
Write-Host Execute $installerFilePath with the following arguments: $installationArguments
Write-Host Executing...
Start-Process -FilePath $installerFilePath -ArgumentList $installationArguments -Wait
Write-Host Installation completed