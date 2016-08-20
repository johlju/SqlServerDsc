$script:DSCModuleName      = 'xSQLServer' 
$script:DSCResourceName    = 'MSFT_xSqlAlias' 

#region HEADER

# Unit Test Template Version: 1.1.0
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit 

#endregion HEADER

try
{
    #region Pester Test Initialization
    #endregion Pester Test Initialization

    #region Get-TargetResource
    Describe 'Get-TargetResource' {
        Mock -CommandName Get-ItemProperty -MockWith {
            return 'DBMSSOCN,localhost,1433'
        } -ModuleName $script:DSCResourceName
    
        $SqlAlias = Get-TargetResource -Name 'localhost' -Servername 'localhost'

        It 'Should return hashtable with Key Protocol'{
            $SqlAlias.ContainsKey('Protocol') | Should Be $true
        }
        
        It 'Should return hashtable with Value that matches "TCP"'{
            $SqlAlias.Protocol = 'TCP'    
        }
    }
    #end region Get-TargetResource

    #region Set-TargetResource
    Describe 'Set-TargetResource' {
        Mock -CommandName New-ItemProperty -MockWith {} -ModuleName $script:DSCResourceName 
        Mock -CommandName Set-ItemProperty -MockWith {} -ModuleName $script:DSCResourceName
        Mock -CommandName Remove-ItemProperty -MockWith {} -ModuleName $script:DSCResourceName
        
        Mock -CommandName Test-Path -MockWith {
            return $true
        } -ModuleName $script:DSCResourceName 

        Mock -CommandName Get-WmiObject -MockWith {
            return @{
                Class = 'win32_OperatingSystem'
                OSArchitecture = '64-bit'
            }
        } -ModuleName $script:DSCResourceName

        It 'Should call New-ItemProperty when value is not set' {
            Mock -CommandName Get-ItemProperty -MockWith {
                return $null
            } -ModuleName $script:DSCResourceName

            Set-TargetResource -Name 'myServerAlias' -Protocol 'TCP' -ServerName 'localhost' -TCPPort 52002 -Ensure 'Present'

            Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName New-ItemProperty -Exactly 2 -Scope It
            Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Set-ItemProperty -Exactly 0 -Scope It
        }

        Mock -CommandName Get-ItemProperty -MockWith {
            return 'DBMSSOCN,localhost,52002'
        } -ModuleName $script:DSCResourceName

        It 'Should not call any *-ItemProperty when value is already set' {
            Set-TargetResource -Name 'myServerAlias' -Protocol 'TCP' -ServerName 'localhost' -TCPPort 52002 -Ensure 'Present'

            Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Set-ItemProperty -Exactly 0 -Scope It
            Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName New-ItemProperty -Exactly 0 -Scope It
            Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Remove-ItemProperty -Exactly 0 -Scope It
        }

        It 'Should call Set-ItemProperty exactly 2 times (1 for 32bit and 1 for 64 bit reg keys) when server name is different' {
            Set-TargetResource -Name 'myServerAlias' -Protocol 'TCP' -ServerName 'newserver' -TCPPort 52002 -Ensure 'Present'

            Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Set-ItemProperty -Exactly 2 -Scope It
            Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName New-ItemProperty -Exactly 0 -Scope It
        }

        It 'Should call Set-ItemProperty exactly 2 times (1 for 32bit and 1 for 64 bit reg keys) when TCP port is different' {
            Set-TargetResource -Name 'myServerAlias' -Protocol 'TCP' -ServerName 'localhost' -TCPPort 1433 -Ensure 'Present'
            
            Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Set-ItemProperty -Exactly 2 -Scope It
        }

        It 'Should call any Remove-ItemProperty exactly 2 times (1 for 32bit and 1 for 64 bit reg keys) when alias should be absent' {
            Set-TargetResource -Name 'myServerAlias' -Protocol 'TCP' -ServerName 'localhost' -TCPPort 52002 -Ensure 'Absent'

            Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Set-ItemProperty -Exactly 0 -Scope It
            Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName New-ItemProperty -Exactly 0 -Scope It
            Assert-MockCalled -ModuleName $script:DSCResourceName -CommandName Remove-ItemProperty -Exactly 2 -Scope It
        }
    }
    #end region Set-TargetResource

    #region Test-TargetResource
    Describe 'Test-TargetResource' {
        Mock -CommandName Test-Path -MockWith {
            return $true
        } -ModuleName $script:DSCResourceName

        Mock -CommandName Get-ItemProperty -MockWith {
            return @{
                myServerAlias = 'DBMSSOCN,localhost,1433'
            }
        } -ModuleName $script:DSCResourceName

        Mock -CommandName Get-WmiObject -MockWith {
            return @{
                Class = 'win32_OperatingSystem'
                OSArchitecture = '64-bit'
            }
        } -ModuleName $script:DSCResourceName

        It 'Should return $true when Test is passed as Alias thats already set'{
            Test-TargetResource -Name 'myServerAlias'  -Protocol 'TCP' -ServerName localhost -TCPPort 1433 -Ensure 'Present' | Should Be $true
        }

        It 'Should return $false when Test is passed as Alias that is not set'{
            Test-TargetResource -Name 'myServerAlias'  -Protocol 'TCP' -ServerName localhost -TCPPort 52002 -Ensure 'Present' | Should Be $false
        }
    }
    #end region Test-TargetResource
}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $TestEnvironment 

    #endregion
}
