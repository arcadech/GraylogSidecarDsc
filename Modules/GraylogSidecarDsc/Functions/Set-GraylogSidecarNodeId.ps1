<#
    .SYNOPSIS
        Set the sidecar node id.

    .DESCRIPTION
        Update the node id in the file C:\Program Files\Graylog\sidecar\node-id.

    .EXAMPLE
        PS C:\> Set-GraylogSidecarNodeId -NodeId '19c484fd-5624-42fd-8013-06724ca340cc'
        Set a new node id.
#>
function Set-GraylogSidecarNodeId
{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $NodeId
    )

    [System.IO.File]::WriteAllText('C:\Program Files\Graylog\sidecar\node-id', $NodeId, [System.Text.Encoding]::UTF8)
}
