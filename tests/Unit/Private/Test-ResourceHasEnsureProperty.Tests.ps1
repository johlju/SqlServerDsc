[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

BeforeAll {
    $script:dscModuleName = 'SqlServerDsc'

    Import-Module -Name $script:dscModuleName

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:dscModuleName -All | Remove-Module -Force
}

Describe 'Test-ResourceHasEnsureProperty' -Tag 'Private' {
    Context 'When resource does not have an Ensure property' {
        BeforeAll {
            <#
                Must use a here-string because we need to pass 'using' which must be
                first in a scriptblock, but if it outside the here-string PowerShell
                will fail to parse the test script.
            #>
            $inModuleScopeScriptBlock = @'
using module SqlServerDsc

class MyMockResource
{
    [DscProperty(Key)]
    [System.String]
    $MyResourceKeyProperty1

    [DscProperty(Key)]
    [System.String]
    $MyResourceKeyProperty2

    [DscProperty()]
    [System.String]
    $MyResourceProperty3

    [DscProperty(NotConfigurable)]
    [System.String]
    $MyResourceReadProperty
}

$script:mockResourceBaseInstance = [MyMockResource]::new()
'@

            InModuleScope -ScriptBlock ([Scriptblock]::Create($inModuleScopeScriptBlock))
        }

        It 'Should return the correct value' {
            InModuleScope -ScriptBlock {
                $result = Test-ResourceHasEnsureProperty -InputObject $script:mockResourceBaseInstance

                $result | Should -BeFalse
            }
        }
    }

    Context 'When resource have an Ensure property' {
        BeforeAll {
            <#
                Must use a here-string because we need to pass 'using' which must be
                first in a scriptblock, but if it outside the here-string PowerShell
                will fail to parse the test script.
            #>
            $inModuleScopeScriptBlock = @'
using module SqlServerDsc

class MyMockResource
{
    [DscProperty(Key)]
    [System.String]
    $MyResourceKeyProperty1

    [DscProperty(Key)]
    [System.String]
    $MyResourceKeyProperty2

    [DscProperty()]
    [System.String]
    $Ensure

    [DscProperty(NotConfigurable)]
    [System.String]
    $MyResourceReadProperty
}

$script:mockResourceBaseInstance = [MyMockResource]::new()
'@

            InModuleScope -ScriptBlock ([Scriptblock]::Create($inModuleScopeScriptBlock))
        }

        It 'Should return the correct value' {
            InModuleScope -ScriptBlock {
                $result = Test-ResourceHasEnsureProperty -InputObject $script:mockResourceBaseInstance

                $result | Should -BeTrue
            }
        }
    }
}
