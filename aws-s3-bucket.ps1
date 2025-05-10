# Prerequisites:
# AWS Tools for PowerShell: Install-Module -Name AWSPowerShell
# AWS credentials configured using Set-AWSCredential or profile

# ====== CONFIGURATION ======
$bucketName = "my-secure-logs-bucket"
$region = "us-east-1"
$logDir = "C:\Logs"
$systemName = $env:COMPUTERNAME
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFileName = "performance_log_$timestamp.csv"
$logFilePath = Join-Path $logDir $logFileName
$key = "logs/$systemName/{0}/performance_log_{1}.csv" -f (Get-Date -Format "yyyy/MM"), $timestamp
$urlExpiryHours = 1
# ===========================

# Create log directory if it doesn't exist
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

# Collect performance data
$cpu = Get-Counter '\Processor(_Total)\% Processor Time'
$memory = Get-WmiObject -Class Win32_OperatingSystem

$logData = [PSCustomObject]@{
    Timestamp       = $timestamp
    CPU_Usage       = "{0:N2}" -f ($cpu.CounterSamples.CookedValue)
    Total_Memory_MB = [math]::Round($memory.TotalVisibleMemorySize / 1024, 2)
    Free_Memory_MB  = [math]::Round($memory.FreePhysicalMemory / 1024, 2)
    MachineName     = $systemName
}

# Export to CSV
$logData | Export-Csv -Path $logFilePath -NoTypeInformation

# Create the S3 bucket if it doesn't exist
if (-not (Get-S3Bucket -BucketName $bucketName -ErrorAction SilentlyContinue)) {
    New-S3Bucket -BucketName $bucketName -Region $region
    Write-Host " Created S3 bucket: $bucketName"

    # Block all public access (secure bucket)
    Write-S3PublicAccessBlock -BucketName $bucketName `
        -BlockPublicAcls $true -IgnorePublicAcls $true `
        -BlockPublicPolicy $true -RestrictPublicBuckets $true
    Write-Host " Public access blocked on bucket."
}

# Upload log to S3
Write-S3Object -BucketName $bucketName -File $logFilePath -Key $key
Write-Host " Uploaded log to S3: s3://$bucketName/$key"

# Generate pre-signed URL
$expiryTime = (Get-Date).AddHours($urlExpiryHours)
$presignedUrl = Get-S3PreSignedURL -BucketName $bucketName -Key $key -Expires $expiryTime
Write-Host "`n Pre-Signed URL (valid for $urlExpiryHours hour[s]):`n$presignedUrl"
