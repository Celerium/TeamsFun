
function Send-TeamsDadJoke {
<#
.NOTES
    NAME: Send-TeamsDadJoke.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        DATE:    2022-06-20
        EMAIL:   celerium@celerium.org
        Updated:
        Date:

    VERSION HISTORY:
    0.1 - 2022-06-20 - Initial Release
    0.2 - 2024-12-15 - General cleanup

    TODO:
    N\A

.SYNOPSIS
    Sends a dad joke to a Teams channel

.DESCRIPTION
    The Send-TeamsDadJoke cmdlet sends a dad joke to a Teams channel using a Teams webhook connector URI.

    Unless the -Verbose parameter is used, no output is displayed

.PARAMETER TeamsURI
    A string that defines where the Microsoft Teams connector URI sends information to

.EXAMPLE
    .\Send-TeamsDadJoke.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....'

    Using the defined webhooks connector URI a random dad joke is sent to the webhooks Teams channel

    No output is displayed to the console.

.EXAMPLE
    .\Send-TeamsDadJoke.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....' -Verbose

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
        [String]$TeamsUri
    )

#EndRegion  [ Parameters ]

begin {

    $FunctionName           = $MyInvocation.InvocationName
    $ErrorActionPreference  = 'Stop'

}

process {

#Region     [ Prerequisites ]

    $Log        = "C:\Celerium\Logs\$FunctionName-Report"
    $TXTReport  = "$Log\$FunctionName-Log.txt"
    $StepNumber = 0

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Configuring Perquisites"
    $StepNumber++

    if ( (Test-Path -Path $Log -PathType Container) -eq $false ) {
        New-Item -Path $Log -ItemType Directory > $null
    }

#EndRegion  [ Prerequisites ]

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Getting data"
    $StepNumber++

#Region     [ Data ]

    try {

        $DadJoke = (Invoke-RestMethod -Uri 'https://icanhazdadjoke.com/' -Headers @{Accept='application/json'} ).joke

    }
    catch {
        Write-Error $_
        "$(Get-Date -Format yyyy-MM-dd-HH:mm)-[ Step (1/3) ]-$($_.Exception.Message)" | Out-File $TXTReport -Append -Encoding utf8

        exit 1
    }

#EndRegion  [ Data ]

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Formatting data"
    $StepNumber++

#Region     [ Main Code ]

    $JSONBody = @"

{
    "type":"message",
    "attachments":[
    {
        "contentType":"application/vnd.microsoft.card.adaptive",
        "contentUrl":null,
        "content":{
            "$('$schema')":"http://adaptivecards.io/schemas/adaptive-card.json",
            "type":"AdaptiveCard",
            "version":"1.4",
                "body": [
                    {
                        "type": "Container",
                        "items": [
                            {
                                "type": "TextBlock",
                                "text": "The Daily Knee-Slapper!",
                                "weight": "Bolder",
                                "size": "Medium"
                            }
                        ]
                    },
                    {
                        "type": "Container",
                        "items": [
                            {
                                "type": "TextBlock",
                                "text": "$DadJoke",
                                "wrap": true
                            }
                        ]
                    }
                ],
                "actions": [
                    {
                        "type": "Action.OpenUrl",
                        "title": "View",
                        "url": "https://icanhazdadjoke.com",
                        "role": "Link"
                    }
                ],
                "msTeams": {
                    "width": "Full"
                }
            }
        }
    ]
}

"@

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Sending Data"
    $StepNumber++

    try {
        Invoke-RestMethod -Uri $TeamsURI -Method Post -ContentType 'application/json' -Body $JsonBody > $null

        $FunctionNameReturn = [PSCustomObject]@{
            Data    = $DadJoke
            Json    = $JsonBody
        }

        $FunctionName = $MyInvocation.InvocationName -replace '-','_'
        Set-Variable -Name $FunctionName -Value $FunctionNameReturn -Scope Global -Force

    }
    catch {
        Write-Error $_
        "$(Get-Date -Format yyyy-MM-dd-HH:mm)-[ Step (1/3) ]-$($_.Exception.Message)" | Out-File $TXTReport -Append -Encoding utf8

        exit 1
    }

#EndRegion  [ Main Code ]

}

end {}

}