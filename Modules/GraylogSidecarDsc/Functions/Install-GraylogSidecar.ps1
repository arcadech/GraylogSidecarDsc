<#
    .SYNOPSIS
        Install the Graylog Sidecar.

    .DESCRIPTION
        Use the specified setup file and install the Graylog Sidecar in silent
        mode. During installation, the ServerUrl and ServerApiToken will be used
        to register the client in the Graylog server.

    .PARAMETER SetupPath
        Path to the setup file.

    .PARAMETER ServerUrl
        Target Graylog server url.

    .PARAMETER ServerApiToken
        Target graylog API token.

    .EXAMPLE
        PS C:\> Install-GraylogSidecar -SetupPath 'C:\Temp\graylog_sidecar_installer_1.0.1-1.exe' -ServerUrl 'https://graylog.contoso.com/api/' -ServerApiToken 'yb34rs6w9nmd6p5y3x2a4kk6a7n8q9p9w7d5us4de3l2ahg'
        Install the Graylog Sidecar Version 1.0.1.
#>
function Install-GraylogSidecar
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SetupPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerApiToken
    )

    # Name of the installer process
    $processName = Get-Item -Path $SetupPath |
                       Select-Object -ExpandProperty 'BaseName'

    # Install or update the application
    Write-Verbose "Install Graylog Sidecar application from $SetupPath"
    $appInstallResult = (& $SetupPath /S "-SERVERURL=$ServerUrl" "-APITOKEN=$ServerApiToken")
    $appInstallResult | Write-Verbose

    # Wait for the install to complete. Check if the setup process is still
    # running. Timeout after 5 minutes.
    $setupRunning = $true
    for ($c = 0; $c -lt 300 -and $setupRunning; $c++)
    {
        $setupRunning = $null -ne (Get-Process -Name $processName -ErrorAction 'SilentlyContinue')

        Start-Sleep -Seconds 1
    }

    # Sleep for 10 seconds to allow post install/update processes to complete
    Start-Sleep -Seconds 10

    # Install the service, if it is not installed alreaday due to an update
    if ($null -eq (Get-Service -Name 'graylog-sidecar' -ErrorAction SilentlyContinue))
    {
        Write-Verbose 'Install Graylog Sidecar service'
        $svcInstallResult = (& 'C:\Program Files\graylog\sidecar\graylog-sidecar.exe' -service install)
        $svcInstallResult | Write-Verbose

        # Wait for the service install to complete. To be sure, add a sleep second
        # after scanning the installation status.
        $svcInstallState = $false
        for ($c = 0; $c -lt 300 -and -not $svcInstallState; $c++)
        {
            $svcInstallState = (Get-Service).Name -contains 'graylog-sidecar'
            Start-Sleep -Seconds 3
        }

        # Start service
        Write-Verbose 'Start Graylog Sidecar service'
        Start-Service -Name 'graylog-sidecar' -ErrorAction Stop
    }
}
