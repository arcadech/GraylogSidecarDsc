<#
    .SYNOPSIS
        Get the current Graylog sidecar configuration assignment.

    .PARAMETER ServerUrl
        Target Graylog server url.

    .PARAMETER Credential
        Username and password for the Graylog server.

    .PARAMETER CollectorId
        The sidecar collector id to assign to the local node.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerUrl,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CollectorId
    )

    Write-Verbose 'Get Graylog Sidecar Configuration resource'

    $ensure = 'Absent'

    $nodeId = Get-GraylogSidecarNodeId

    if (![System.String]::IsNullOrEmpty($nodeId))
    {
        $configurationId = Get-GraylogSidecarConfigurationAssignment -Uri $ServerUrl -Credential $Credential -NodeId $nodeId -CollectorId $CollectorId

        if (![System.String]::IsNullOrEmpty($configurationId))
        {
            $ensure = 'Present'
        }
    }

    $returnValue = @{
        Ensure          = $ensure
        ServerUrl       = $ServerUrl
        Credential      = $Credential
        NodeId          = [System.String] $nodeId
        CollectorId     = $CollectorId
        ConfigurationId = [System.String] $configurationId
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Add or remove Graylog sidecar configuration assignment.

    .PARAMETER Ensure
        Specified if the configuration should be added or removed.

    .PARAMETER ServerUrl
        Target Graylog server url.

    .PARAMETER Credential
        Username and password for the Graylog server.

    .PARAMETER CollectorId
        The sidecar collector id to assign to the local node.

    .PARAMETER ConfigurationId
        The sidecar configuration id to assign to the local node.
#>
function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerUrl,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CollectorId,

        [Parameter(Mandatory = $false)]
        [System.String]
        $ConfigurationId
    )

    Write-Verbose 'Set Graylog Sidecar Configuration resource'

    $nodeId = Get-GraylogSidecarNodeId

    if (![System.String]::IsNullOrEmpty($nodeId))
    {
        if ($Ensure -eq 'Present')
        {
            Add-GraylogSidecarConfigurationAssignment -Uri $ServerUrl -Credential $Credential -NodeId $nodeId -CollectorId $CollectorId -ConfigurationId $ConfigurationId
        }

        if ($Ensure -eq 'Absent')
        {
            Remove-GraylogSidecarConfigurationAssignment -Uri $ServerUrl -Credential $Credential -NodeId $nodeId -CollectorId $CollectorId
        }
    }
    else
    {
        throw 'Node id not found!'
    }
}

<#
    .SYNOPSIS
        Test Graylog sidecar configuration assignment.

    .PARAMETER Ensure
        Specified if the configuration should be added or removed.

    .PARAMETER ServerUrl
        Target Graylog server url.

    .PARAMETER Credential
        Username and password for the Graylog server.

    .PARAMETER CollectorId
        The sidecar collector id to assign to the local node.

    .PARAMETER ConfigurationId
        The sidecar configuration id to assign to the local node.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [System.String]
        $ServerUrl,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CollectorId,

        [Parameter(Mandatory = $false)]
        [System.String]
        $ConfigurationId
    )

    Write-Verbose 'Test Graylog Sidecar Configuration resource'

    $currentState = Get-TargetResource -ServerUrl $ServerUrl -Credential $Credential -CollectorId $CollectorId

    if ($Ensure -eq 'Present')
    {
        return $currentState.Ensure -eq $Ensure -and
               $currentState.ServerUrl -eq $ServerUrl -and
               $currentState.CollectorId -eq $CollectorId -and
               $currentState.ConfigurationId -eq $ConfigurationId
    }

    if ($Ensure -eq 'Absent')
    {
        return $currentState.Ensure -eq $Ensure
    }
}
