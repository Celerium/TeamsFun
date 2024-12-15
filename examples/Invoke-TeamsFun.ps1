
<#
.NOTES
    NAME: Invoke-TeamsFun.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        DATE:    2024-12-15
        EMAIL:   celerium@celerium.org
        Updated:
        Date:

    VERSION HISTORY:
    0.1 - 2024-12-15 - Initial Release

    TODO:
    N\A

.SYNOPSIS
    Invokes a defined TeamsFun cmdlet

.DESCRIPTION
    The Invoke-TeamsFun cmdlet invokes a defined TeamsFun cmdlet to post to a defined Teams channel

    Unless the -Verbose parameter is used, no output is displayed

.PARAMETER TeamsURI
    A string that defines where the Microsoft Teams connector URI sends information to

.PARAMETER Invoke
    Which TeamsFun cmdlet to invoke

    Allowed Values:
        DadJoke, Pokemon, Purr, Woof


.EXAMPLE
    .\Invoke-TeamsFun.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....' -Invoke DadJoke

    Using the defined webhooks connector URI a random dad joke is sent to the webhooks Teams channel

    No output is displayed to the console.

.EXAMPLE
    .\Invoke-TeamsFun.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....' -Invoke DadJoke -Verbose

    Using the defined webhooks connector URI a random dad joke is sent to the webhooks Teams channel.

    Output is displayed to the console.

.INPUTS
    TeamsURI

.OUTPUTS
    Console

.LINK
    https://www.celerium.org

#>

#Region  [ Parameters ]

[CmdletBinding()]
param(
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$TeamsUri,

        [Parameter(Mandatory=$true)]
        [ValidateSet( 'DadJoke', 'Pokemon', 'Purr', 'Woof', 'All')]
        [String[]]$Invoke
    )

#EndRegion  [ Parameters ]

begin {

    $FunctionName           = $MyInvocation.MyCommand.Name -replace '.ps1',''
    $ErrorActionPreference  = 'Stop'

}

process {

#Region     [ Prerequisites ]

    $Log        = "C:\Celerium\Logs\$FunctionName-Report"
    $TXTReport  = "$Log\$FunctionName-Log.txt"
    $StepNumber = 0

    Write-Verbose " - ($StepNumber/1) - $(Get-Date -Format MM-dd-HH:mm) - Configuring Perquisites"
    $StepNumber++

    if ( (Test-Path -Path $Log -PathType Container) -eq $false ) {
        New-Item -Path $Log -ItemType Directory > $null
    }

#EndRegion  [ Prerequisites ]

if ($Invoke -eq 'All') { Write-Verbose " - ($StepNumber/1) - $(Get-Date -Format MM-dd-HH:mm) - Invoking all Send-TeamsFun* cmdlets" }
else{ Write-Verbose " - ($StepNumber/1) - $(Get-Date -Format MM-dd-HH:mm) - Invoking Send-TeamsFun$Invoke cmdlet" }
$StepNumber++

#Region     [ Main Code ]

try {

    if ($Invoke -eq 'DadJoke' -or $Invoke -eq 'All') {

        Write-Verbose " -       - $(Get-Date -Format MM-dd-HH:mm) - Invoking DadJoke"

        Send-TeamsDadJoke -TeamsUri $TeamsUri -Verbose

        $Send_TeamsDadJoke

    }

    if ($Invoke -eq 'Pokemon' -or $Invoke -eq 'All') {

        if ([bool]$(Get-InstalledModule -Name PokeAPI -ErrorAction SilentlyContinue) -eq $false){
            Install-Module -Name PokeAPI -Scope CurrentUser
        }

        Write-Verbose " -       - $(Get-Date -Format MM-dd-HH:mm) - Invoking Pokemon"

        Send-TeamsPokemon -TeamsUri $TeamsUri -Verbose

        $Send_TeamsPokemon

    }

    if ($Invoke -eq 'Purr' -or $Invoke -eq 'All') {

        Write-Verbose " -       - $(Get-Date -Format MM-dd-HH:mm) - Invoking Purr"

        Send-TeamsPurr -TeamsUri $TeamsUri -Verbose

        $Send_TeamsPurr

    }

    if ($Invoke -eq 'Woof' -or $Invoke -eq 'All') {

        Write-Verbose " -       - $(Get-Date -Format MM-dd-HH:mm) - Invoking Woof"

        Send-TeamsWoof -TeamsUri $TeamsUri -Verbose

        $Send_TeamsWoof

    }

    }
    catch {
        Write-Error $_
        "$(Get-Date -Format yyyy-MM-dd-HH:mm)-[ Step (1/1) ]-$($_.Exception.Message)" | Out-File $TXTReport -Append -Encoding utf8

        exit 1
    }

#EndRegion  [ Main Code ]

}

end {}