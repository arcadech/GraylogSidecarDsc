<#
    .SYNOPSIS
        Get the installed Graylog Sidecar version.

    .DESCRIPTION
        Scan the MSI Uninstall registry key to detect, if the Graylog Sidecar is
        installed. Return the installed version or an empty string, if not
        installed.

    .EXAMPLE
        PS C:\> Get-GraylogSidecarVersion
        This will return the current intalled version.
#>
function Get-GraylogSidecarVersion
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    try
    {
        $displayVersion = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GraylogSidecar' -Name 'DisplayVersion' -ErrorAction Stop

        Write-Verbose "Graylog Sidecar Version = $displayVersion"

        return $displayVersion
    }
    catch
    {
        Write-Verbose 'Graylog Sidecar Version does not exist'

        return ''
    }
}
