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
        $ServerApiToken,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [System.String]
        $NodeId
    )

    # Install the application
    Write-Verbose "Install Graylog Sidecar application from $SetupPath"
    $appInstallResult = (& $SetupPath /S "-SERVERURL=$ServerUrl" "-APITOKEN=$ServerApiToken")
    $appInstallResult | Write-Verbose

    # Wait for the install to complete. To be sure, add a sleep second after
    # scanning the installation status.
    $appInstallState = $false
    for ($c = 0; $c -lt 300 -and -not $appInstallState; $c++)
    {
        $appInstallState = -not [System.String]::IsNullOrWhiteSpace((Get-GraylogSidecarVersion))
        Start-Sleep -Seconds 3
    }

    # Update the node if, if it was specified
    if (-not ([System.String]::IsNullOrEmpty($NodeId)))
    {
        Set-GraylogSidecarNodeId -NodeId $NodeId
    }

    # Install the service
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
