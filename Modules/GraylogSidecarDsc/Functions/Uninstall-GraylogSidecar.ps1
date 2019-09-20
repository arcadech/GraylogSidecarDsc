<#
    .SYNOPSIS
        Uninstall the Graylog Sidecar.

    .DESCRIPTION
        Use the uninstall.exe in the Sidecar program folder to remove the
        current installation.

    .EXAMPLE
        PS C:\> Uninstall-GraylogSidecar
        Uninstall the Graylog Sidecar.
#>
function Uninstall-GraylogSidecar
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    # # Uninstall the application
    Write-Verbose 'Uninstall Graylog Sidecar application'
    $appUninstallResult = (& 'C:\Program Files\Graylog\sidecar\uninstall.exe' /S)
    $appUninstallResult | Write-Verbose

    # Wait for the uninstall to complete. To be sure, add a sleep second after
    # scanning the installation status.
    $appInstallState = $true
    for ($c = 0; $c -lt 300 -and $appInstallState; $c++)
    {
        $appInstallState = -not ([System.String]::IsNullOrEmpty((Get-GraylogSidecarVersion)))
        Start-Sleep -Seconds 3
    }
}
