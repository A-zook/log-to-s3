# aws-s3-performance-logger

A PowerShell automation script that collects system performance metrics (CPU, memory usage), exports them to a CSV file, and uploads them securely to an AWS S3 bucket. A pre-signed URL is also generated for temporary external access to the uploaded log.

## Features

- Collects real-time CPU and memory usage statistics.
- Saves data as a timestamped CSV log.
- Automatically creates an S3 bucket if it doesn't exist.
- Blocks public access on the S3 bucket for security.
- Uploads log files to structured S3 paths (`logs/COMPUTERNAME/yyyy/MM/`).
- Generates a pre-signed URL valid for 1 hour (configurable).

## Requirements

- Windows PowerShell (v5.1+)
- AWS Tools for PowerShell (`AWS.Tools.S3`)
- Valid AWS credentials configured (via `Set-AWSCredential`, environment variables, or AWS config file)

## Usage

1. Clone this repository:
    ```bash
    git clone [https://github.com/A-zook/log-to-s3.git]
    cd aws-s3-performance-logger
    ```

2. Open PowerShell and run:
    ```powershell
    .\aws-s3-bucket.ps1
    ```

3. View the uploaded log or access it via the printed pre-signed URL.

## Output

Example S3 object key format:
logs/MACHINE_NAME/2025/05/performance_log_2025-05-10_02-02-17.csv

## Security

- S3 bucket has **all public access blocked** by default.
- Pre-signed URLs allow temporary secure access to logs.

