<#
    .SYNOPSIS
        Update the current sidecar configuration.

    .DESCRIPTION
        Write the specified properties to the configuration file sidecar.yml.
        Only specified parameters will be updated. Not specififed parameters
        will not be touched.

    .PARAMETER ServerUrl
        Target Graylog server url.

    .PARAMETER ServerApiToken
        Target Graylog API token.

    .PARAMETER NodeName
        The target node name.

    .EXAMPLE
        PS C:\> Set-GraylogSidecarConfigFile -NodeName $Env:ComputerName
        Update only the node name.

    .EXAMPLE
        PS C:\> Set-GraylogSidecarConfigFile -NodeName $Env:ComputerName -ServerUrl 'https://graylog.contoso.com/api/' -ServerApiToken 'yb34rs6w9nmd6p5y3x2a4kk6a7n8q9p9w7d5us4de3l2ahg'
        Update all properties: ServerUrl, ServerApiToken and NodeName.
#>
function Set-GraylogSidecarConfigFile
{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param
    (
        [Parameter(Mandatory = $false)]
        [System.String]
        $ServerUrl,

        [Parameter(Mandatory = $false)]
        [System.String]
        $ServerApiToken,

        [Parameter(Mandatory = $false)]
        [System.String]
        $NodeName
    )

    Write-Verbose 'Update Graylog Sidecar configuration'

    $path = 'C:\Program Files\Graylog\sidecar\sidecar.yml'

    Stop-Service -Name 'graylog-sidecar'

    # Load the current configuration
    $config = Get-Content -Path $path

    if ($PSBoundParameters.ContainsKey('ServerUrl'))
    {
        Write-Verbose "  ServerUrl = $ServerUrl"
        $config = $config -replace '.*server_url: ".*".*', "server_url: `"$ServerUrl`""
    }

    if ($PSBoundParameters.ContainsKey('ServerApiToken'))
    {
        Write-Verbose "  ServerApiToken = $ServerApiToken"
        $config = $config -replace '.*server_api_token: ".*".*', "node_name: `"$ServerApiToken`""
    }

    if ($PSBoundParameters.ContainsKey('NodeName'))
    {
        Write-Verbose "  NodeName = $NodeName"
        $config = $config -replace '.*node_name: ".*".*', "node_name: `"$NodeName`""
    }

    # Update the configuration with the new values. To not specify an encoding,
    # the target UTF8 w/o BOM file encoding will be used.
    $config | Set-Content -Path $path

    Start-Service -Name 'graylog-sidecar'
}
