$command = Get-Command -Name msbuild -ErrorAction SilentlyContinue
if ($null -eq $command) {
    Write-Host "The msbuild-Tool is not installed or not available in the system path"
    exit
}

$command = Get-Command -Name pac -ErrorAction SilentlyContinue
if ($null -eq $command) {
    Write-Host "The pac-Tool is not installed or not available in the system path"
    exit
}

pac auth list
$userInput = Read-Host "Is the right environment selected? (y/n)"
if ($userInput -eq 'n') {
    exit
}

if ($userInput -ne 'y') {
    Write-Host "Wrong input"
    exit
}

$parentFolder = Get-Location
$solutionXmlPath = Get-ChildItem -Path $parentFolder -Recurse -Filter "Solution.xml" | Select-Object -ExpandProperty FullName
if ($solutionXmlPath) {
    [xml]$solutionXml = Get-Content -Path $solutionXmlPath
    $currentVersion = $solutionXml.ImportExportXml.SolutionManifest.Version
    $newVersion = [Version]::new($currentVersion)  # Konvertiere die aktuelle Version in ein Version-Objekt
    $newVersion = $newVersion.Major, $newVersion.Minor, ($newVersion.Build + 1) -join "."  # Inkrementiere den Build-Wert
    $solutionXml.ImportExportXml.SolutionManifest.Version = $newVersion
    $solutionXml.Save($solutionXmlPath)
} else {
    Write-Host "Solution.xml not found"
    exit
}

$projectPath = Get-ChildItem -Path $parentFolder -Filter *.pcfproj | Select-Object -ExpandProperty FullName
Start-Process -FilePath msbuild -ArgumentList "$projectPath /t:restore" -NoNewWindow -Wait
$projectPaths = Get-ChildItem -Path $parentFolder -Recurse -Filter *.cdsproj | Select-Object -ExpandProperty FullName
foreach ($projectPath in $projectPaths) {
    Start-Process -FilePath msbuild -ArgumentList "$projectPath /t:restore" -NoNewWindow -Wait
}

Start-Process -FilePath msbuild -ArgumentList "$projectPath /p:Configuration=Release" -NoNewWindow -Wait
$solutionFilePath = Get-ChildItem -Path $parentFolder -Recurse -Filter "*.zip" | Select-Object -ExpandProperty FullName
if ($solutionFilePath -eq $null) {
    Write-Host "No solution file found"
    exit
}

Write-Host "Importing solution..."
pac solution import --path $solutionFilePath --publish-changes
$process = Start-Process -FilePath "pac" -ArgumentList "solution import --path $solutionFilePath --publish-changes" -PassThru -Wait
if ($process.ExitCode -eq 0) {
    Write-Host "Import successfully completed"
    } else {
        Write-Host "An error has occurred. ExitCode: $($process.ExitCode)"
    }