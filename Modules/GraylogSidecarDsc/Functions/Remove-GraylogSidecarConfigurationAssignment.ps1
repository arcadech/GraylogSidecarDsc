<#
    .SYNOPSIS
        Remove the assigned configuration for the graylog node and collector.

    .DESCRIPTION
        Invoke a web request on the Graylog API to remove the currently assigned
        configuration for the specified node an collector.

    .EXAMPLE
        PS C:\> Remove-GraylogSidecarConfigurationAssignment -Uri 'https://graylog.contoso.com' -Credential $cred -NodeId '99b5a37c-a277-444e-b8fd-c261c18ac5bd' -CollectorId '5d06f16771c02a78f6ed644f'
        Remove the assigned configuration.
#>
function Remove-GraylogSidecarConfigurationAssignment
{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
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

        # Create a new assignment array without our collector id
        $assignments = @($graylogSidecar.assignments | Where-Object { $_.collector_id -ne $CollectorId })

        # Create a new request to push the desired assignments
        $graylogSidecarConfigurationAssignmentSplat = @{
            Method  = 'Put'
            Uri     = '{0}/api/sidecars/configurations' -f $Uri
            Body    = (@{
                nodes = @(
                    @{
                        node_id     = $NodeId
                        assignments = $assignments
                    }
                )
            } | ConvertTo-Json -Depth 4)
            ContentType = 'application/json'
            Headers = @{
                Authorization    = $auth
                'X-Requested-By' = 'XMLHttpRequest'
            }
        }
        Invoke-RestMethod @graylogSidecarConfigurationAssignmentSplat -ErrorAction 'Stop'
    }
    catch
    {
        throw $_
    }
}
