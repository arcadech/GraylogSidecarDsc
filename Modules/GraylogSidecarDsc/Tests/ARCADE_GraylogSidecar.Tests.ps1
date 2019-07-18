[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
param ()

$Global:modulePath   = Resolve-Path -Path "$PSScriptRoot\..\.." | Select-Object -ExpandProperty Path
$Global:moduleName   = Resolve-Path -Path "$PSScriptRoot\.." | Get-Item | Select-Object -ExpandProperty BaseName
$Global:resourceName = 'ARCADE_GraylogSidecar'

Remove-Module -Name $Global:moduleName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$Global:modulePath\$Global:moduleName" -Force

Remove-Module -Name $Global:resourceName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$Global:modulePath\$Global:moduleName\DSCResources\$Global:resourceName\$Global:resourceName.psm1" -Force

InModuleScope 'ARCADE_GraylogSidecar' {

    Mock 'Get-ItemProperty' { }

    Mock 'Get-GraylogSidecarVersion' { '' }

    Mock 'Get-GraylogSidecarConfigFile' {
        [PSCustomObject] @{
            ServerUrl      = ''
            ServerApiToken = ''
            NodeName       = ''
        }
    }

    Mock 'Set-GraylogSidecarConfigFile' { }

    Mock 'Install-GraylogSidecar' { }

    Mock 'Uninstall-GraylogSidecar' { }

    Context 'Get-TargetResource' {

        $getParams = @{
            IsSingleInstance = 'Yes'
            SetupPath        = "$Env:Temp\graylog_sidecar_installer_1.0.1-1.exe"
            ServerUrl        = 'https://graylog.contoso.com/'
            ServerApiToken   = 'yb34rs6w9nmd6p5y3x2a4kk6a7n8q9p9w7d5us4de3l2ahg'
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
            SetupPath        = "$Env:Temp\graylog_sidecar_installer_1.0.1-1.exe"
            ServerUrl        = 'https://graylog.contoso.com/'
            ServerApiToken   = 'yb34rs6w9nmd6p5y3x2a4kk6a7n8q9p9w7d5us4de3l2ahg'
            NodeName         = 'demo'
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
            SetupPath        = "$Env:Temp\graylog_sidecar_installer_1.0.1-1.exe"
            ServerUrl        = 'https://graylog.contoso.com/'
            ServerApiToken   = 'yb34rs6w9nmd6p5y3x2a4kk6a7n8q9p9w7d5us4de3l2ahg'
            NodeName         = 'demo'
        }

        It 'Should return a System.Boolean' {

            # Act
            $result = & "$Global:resourceName\Test-TargetResource" @testParams

            # Assert
            $result | Should -BeOfType 'System.Boolean'
        }
    }
}
