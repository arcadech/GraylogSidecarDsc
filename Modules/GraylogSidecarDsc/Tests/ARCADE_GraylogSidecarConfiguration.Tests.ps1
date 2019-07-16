[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param ()

$Global:modulePath   = Resolve-Path -Path "$PSScriptRoot\..\.." | Select-Object -ExpandProperty Path
$Global:moduleName   = Resolve-Path -Path "$PSScriptRoot\.." | Get-Item | Select-Object -ExpandProperty BaseName
$Global:resourceName = 'ARCADE_GraylogSidecarConfiguration'

Remove-Module -Name $Global:moduleName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$Global:modulePath\$Global:moduleName" -Force

Remove-Module -Name $Global:resourceName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$Global:modulePath\$Global:moduleName\DSCResources\$Global:resourceName\$Global:resourceName.psm1" -Force

InModuleScope 'ARCADE_GraylogSidecarConfiguration' {

    Mock 'Get-GraylogSidecarNodeId' { '133bb51e-b8b7-433b-becc-7ed4bed71218' }

    Mock 'Get-GraylogSidecarConfigurationAssignment' { '5d02c71f98a35b06a4edb7fc' }

    Mock 'Add-GraylogSidecarConfigurationAssignment' { }

    Mock 'Remove-GraylogSidecarConfigurationAssignment' { }

    Context 'Get-TargetResource' {

        $getParams = @{
            IsSingleInstance = 'Yes'
            ServerUrl        = 'https://graylog.contoso.com/'
            Credential       = [System.Management.Automation.PSCredential]::new('username', (Protect-String -String 'password'))
            CollectorId      = '5d06f16771c02a78f6ed644f'
        }

        It 'Should return a System.Collections.Hashtable' {

            # Act
            $result = & "$Global:resourceName\Get-TargetResource" @getParams

            # Assert
            $result | Should -BeOfType 'System.Collections.Hashtable'
        }
    }

    Context 'Set-TargetResource' {

        $setParams = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Present'
            ServerUrl        = 'https://graylog.contoso.com/'
            Credential       = [System.Management.Automation.PSCredential]::new('username', (Protect-String -String 'password'))
            CollectorId      = '5d06f16771c02a78f6ed644f'
            ConfigurationId  = '5d02c71f98a35b06a4edb7fc'
        }

        It 'Should not return anything' {

            # Act
            $result = & "$Global:resourceName\Set-TargetResource" @setParams

            # Assert
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Test-TargetResource' {

        $testParams = @{
            IsSingleInstance = 'Yes'
            Ensure           = 'Present'
            ServerUrl        = 'https://graylog.contoso.com/'
            Credential       = [System.Management.Automation.PSCredential]::new('username', (Protect-String -String 'password'))
            CollectorId      = '5d06f16771c02a78f6ed644f'
            ConfigurationId  = '5d02c71f98a35b06a4edb7fc'
        }

        It 'Should return a System.Boolean' {

            # Act
            $result = & "$Global:resourceName\Test-TargetResource" @testParams

            # Assert
            $result | Should -BeOfType 'System.Boolean'
        }
    }
}
