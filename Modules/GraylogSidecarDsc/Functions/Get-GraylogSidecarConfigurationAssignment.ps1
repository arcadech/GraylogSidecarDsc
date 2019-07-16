<#
    .SYNOPSIS
        Get the assigned configuration for the graylog node and collector.

    .DESCRIPTION
        Invoke a web request on the Graylog API to get the currently assigned
        configuration for the specified node an collector.

    .EXAMPLE
        PS C:\> Get-GraylogSidecarConfigurationAssignment -Uri 'https://graylog.contoso.com' -Credential $cred -NodeId '99b5a37c-a277-444e-b8fd-c261c18ac5bd' -CollectorId '5d06f16771c02a78f6ed644f'
        Get the assigned configuration.
#>
function Get-GraylogSidecarConfigurationAssignment
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Uri,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $NodeId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CollectorId
    )

    # Cerate basic authoriazion as base64 encoded string
    $auth = 'Basic {0}' -f [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f $Credential.Username, $Credential.GetNetworkCredential().Password)))

    try
    {
        # Get the current graylog sidecar configuration, including assignments
        $graylogSidecarSplat = @{
            Method  = 'Get'
            Uri     = '{0}/api/sidecars/{1}' -f $Uri, $NodeId
            Headers = @{
                Authorization = $auth
            }
        }
        $graylogSidecar = Invoke-RestMethod @graylogSidecarSplat -ErrorAction 'Stop'

        # Filter all assignments for the desired collector
        $configurationId = $graylogSidecar.assignments | Where-Object { $_.collector_id -eq $CollectorId } | Select-Object -ExpandProperty 'configuration_id' -First 1

        return [System.String] $configurationId
    }
    catch
    {
        Write-Warning $_

        return ''
    }
}
