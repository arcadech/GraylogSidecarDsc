<#
    .SYNOPSIS
        Get the current sidecar node id.

    .DESCRIPTION
        Read the node-id file to get the current id of the sidecar node.

    .EXAMPLE
        PS C:\> Get-GraylogSidecarNodeId
        Get the current sidecar node id.
#>
function Get-GraylogSidecarNodeId
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    try
    {
        $nodeId = Get-Content -Path 'C:\Program Files\Graylog\sidecar\node-id' -Raw -ErrorAction 'Stop'
        $nodeId = $nodeId.Trim()
        return $nodeId
    }
    catch
    {
        return ''
    }
}
