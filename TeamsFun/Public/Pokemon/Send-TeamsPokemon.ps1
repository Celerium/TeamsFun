function Send-TeamsPokemon {
<#
.NOTES
    NAME: Send-TeamsPokemon.ps1
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
    Sends a Pokemon image & stats to a Teams channel

.DESCRIPTION
    The Send-Pokemon script sends a Pokemon image & stats to a Teams channel using a Teams webhook connector URI.

    This script will only send to teams if the $DeployPokemon variable is set to true which is randomized

    Pokemon images & facts are pulled from the PokeAPI

    Unless the -Verbose parameter is used, no output is displayed.

.PARAMETER TeamsURI
    A string that defines where the Microsoft Teams connector URI sends information to.

.EXAMPLE
    .\Send-Pokemon.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....'

    Using the defined webhooks connector URI a random Pokemon image & stats are sent to the webhooks Teams channel.

    No output is displayed to the console.

.EXAMPLE
    .\Send-Pokemon.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....' -Verbose

    Using the defined webhooks connector URI a random Pokemon image & stats are sent to the webhooks Teams channel.

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

    $FunctionName           = $MyInvocation.InvocationName -replace '-','_'
    $ErrorActionPreference  = 'Stop'

}

process {

#Region     [ Prerequisites ]

    $Log        = "C:\GW\Logs\$FunctionName-Report"
    $TXTReport  = "$Log\$FunctionName-Log.txt"
    $StepNumber = 0

    $TextCulture = (Get-Culture).TextInfo

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Configuring Pokerequisites"
    $StepNumber++

    if ( (Test-Path -Path $Log -PathType Container) -eq $false ) {
        New-Item -Path $Log -ItemType Directory > $null
    }

    #Min & Max not compatible with -Count in PS5
    $CurrentDate = (Get-Date).DayOfWeek.value__
    $RandomDate = 1..5 | Get-Random -Count 2

    $DeployPokemon = foreach ($Number in $RandomDate) {
        $Match = [bool]($CurrentDate -eq $Number )
        $Match
    }

    if ($DeployPokemon -contains $true) {
        Write-Verbose " -       - $(Get-Date -Format MM-dd-HH:mm) - [ $CurrentDate |  $RandomDate ]"
    }
    else{
        Write-Verbose " -       - $(Get-Date -Format MM-dd-HH:mm) - [ $CurrentDate |  $RandomDate ]"
        Write-Verbose " -       - $(Get-Date -Format MM-dd-HH:mm) - Sorry, No wild Pokemon were found today."
        exit 0
    }


#EndRegion  [ Prerequisites ]

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Getting Pokemon data"
    $StepNumber++

#Region     [ Pokemon Data ]

try {

    $AllPokemon     = Get-PokePokemon -allPages
    $PokemonName    = $AllPokemon.results | Get-Random -Count 1

    Write-Verbose " -       - $(Get-Date -Format MM-dd-HH:mm) - Found Name: $($PokemonName.Name) - $($PokemonName.url)"

    $PokemonData    = Get-PokePokemon -name $PokemonName.Name
    $PokemonSpecies = Get-PokePokemonSpecies -id $PokemonData.id

}
catch {
    Write-Error $_
    "$(Get-Date -Format yyyy-MM-dd-HH:mm)-[ Step (1/3) ]-$($_.Exception.Message)" | Out-File $TXTReport -Append -Encoding utf8

    exit 1
}

#EndRegion  [ Pokemon Data ]

#Region  [ Main Code ]

$JsonBody = @"

{
    "type": "message",
    "attachments": [
        {
            "contentType": "application/vnd.microsoft.card.adaptive",
            "contentUrl": null,
            "content": {
                "$('$schema')": "http://adaptivecards.io/schemas/adaptive-card.json",
                "type": "AdaptiveCard",
                "version": "1.4",
                "body": [
                    {
                        "type": "TextBlock",
                        "size": "Large",
                        "weight": "Bolder",
                        "color": "attention",
                        "text": "A wild Pokemon has appeared! - $($TextCulture.ToTitleCase($PokemonData.name)) - #$($PokemonData.id)"
                    },
                    {
                        "type": "ColumnSet",
                        "style": "emphasis",
                        "columns": [
                            {
                                "type": "Column",
                                "style": "default",
                                "size": "stretch",
                                "items": [
                                    {
                                        "type": "Image",
                                        "url": "$($PokemonData.sprites.other.showdown.front_default)",
                                        "altText": "$($TextCulture.ToTitleCase($PokemonData.name))",
                                        "width": "150px",
                                        "msTeams": {
                                            "allowExpand": true
                                        }
                                    }
                                ]
                            },
                            {
                                "type": "Column",
                                "items": [
                                    {
                                        "type": "Container",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "Gen: $($TextCulture.ToTitleCase($PokemonSpecies.generation.name))"
                                            }
                                        ]
                                    },
                                    {
                                        "type": "Container",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "Type: $($TextCulture.ToTitleCase($PokemonData.types.type.name -join ', '))"
                                            }
                                        ]
                                    },
                                    {
                                        "type": "Container",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "Height: $($PokemonData.height) dm"
                                            }
                                        ]
                                    },
                                    {
                                        "type": "Container",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "Weight: $($PokemonData.weight) hg"
                                            }
                                        ]
                                    }
                                ]
                            },
                            {
                                "type": "Column",
                                "items": [
                                    {
                                        "type": "Container",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "Abilities:"
                                            }
                                        ]
                                    },
                                    {
                                        "type": "Container",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "--Normal: $($TextCulture.ToTitleCase(($PokemonData.abilities | Where-Object {$_.is_hidden -eq $false}).ability.name -join ', '))"
                                            }
                                        ]
                                    },
                                    {
                                        "type": "Container",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "--Hidden: $($TextCulture.ToTitleCase(($PokemonData.abilities | Where-Object {$_.is_hidden -eq $true}).ability.name -join ', '))"
                                            }
                                        ]
                                    },
                                    {
                                        "type": "Container",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": ""
                                            }
                                        ]
                                    },
                                    {
                                        "type": "Container",
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "Meta:"
                                            }
                                        ]
                                    },
                                    {
                                        "type": "Container",
                                        "style": "default",
                                        "id": "meta",
                                        "isVisible": false,
                                        "items": [
                                            {
                                                "type": "TextBlock",
                                                "text": "Legendary: $($PokemonSpecies.is_baby)"
                                            },
                                            {
                                                "type": "TextBlock",
                                                "text": "Legendary: $($PokemonSpecies.is_legendary)"
                                            },
                                            {
                                                "type": "TextBlock",
                                                "text": "Mythical: $($PokemonSpecies.is_mythical)"
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
                    }
                ],
                "actions": [
                    {
                        "type": "Action.OpenUrl",
                        "title": "Research more Pokemon",
                        "url": "https://www.pokemon.com/us/pokedex"
                    },
                    {
                        "type": "Action.OpenUrl",
                        "title": "Source",
                        "url": "$($PokemonData.sprites.other.showdown.front_default)"
                    },
                    {
                        "type": "Action.ToggleVisibility",
                        "title": "Show Meta",
                        "targetElements": [
                            {
                                "elementId": "meta",
                                "isVisible": true
                            }
                        ]
                    },
                    {
                        "type": "Action.ToggleVisibility",
                        "title": "Hide Meta!",
                        "targetElements": [
                            {
                                "elementId": "meta",
                                "isVisible": false
                            }
                        ]
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

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Sending Pokemon Data"
    $StepNumber++

    try {
        Invoke-RestMethod -Uri $TeamsURI -Method Post -ContentType 'application/json' -Body $JsonBody > $null

        $FunctionNameReturn = [PSCustomObject]@{
            Pokemon = $PokemonName
            Deploy  = "$DeployPokemon | $CurrentDate |  $RandomDate"
            Data    = $PokemonData
            Species = $PokemonSpecies
            Json    = $JsonBody
        }

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