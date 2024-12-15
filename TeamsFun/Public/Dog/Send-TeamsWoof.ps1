
function Send-TeamsWoof {
<#
.NOTES
    NAME: Send-TeamsWoof.ps1
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
    Sends a dog image & fact to a Teams channel

.DESCRIPTION
    The Send-TeamsWoof cmdlet sends a dog image & fact to a Teams channel using a Teams webhook connector URI.

    Various filters are in place to try and prevent any inappropriate images from being sent.

    An image is randomly selected from a random dog subreddit. Dog facts are pulled from the dogapi.dog API

    Unless the -Verbose parameter is used, no output is displayed

.PARAMETER TeamsURI
    A string that defines where the Microsoft Teams connector URI sends information to

.EXAMPLE
    .\Send-TeamsWoof.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....'

    Using the defined webhooks connector URI a random dog image & fact are sent to the webhooks Teams channel

    No output is displayed to the console.

.EXAMPLE
    .\Send-TeamsWoof.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....' -Verbose

    Using the defined webhooks connector URI a random dog image & fact are sent to the webhooks Teams channel.

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

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Configuring Borkequisites"
    $StepNumber++

    if ( (Test-Path -Path $Log -PathType Container) -eq $false ) {
        New-Item -Path $Log -ItemType Directory > $null
    }

#EndRegion  [ Prerequisites ]

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Getting Woof data"
    $StepNumber++

#Region     [ Woof Data ]

    try {

        $WoofSources = @(   'https://www.reddit.com/r/rarepuppers/.json?sort=top&t=week&limit=25' ,
                            'https://www.reddit.com/r/dogswithjobs/.json?sort=top&t=week&limit=25' ,
                            'https://www.reddit.com/r/WhatsWrongWithYourDog/.json?sort=top&t=week&limit=25' ,
                            'https://www.reddit.com/r/DOG/.json?sort=top&t=week&limit=25' ,
                            'https://www.reddit.com/r/dogpictures/.json?sort=top&t=week&limit=25',
                            'https://www.reddit.com/r/puppies/.json?sort=top&t=week&limit=25'
                        )
        $WoofURI = Get-Random -InputObject $WoofSources -Count 1

        $WoofData = Invoke-RestMethod -Uri $WoofURI
        $WoofFact = (Invoke-RestMethod -Uri 'https://dogapi.dog/api/v2/facts?limit=1').data.attributes.body

        $WoofFilter = $WoofData.data.children.data | Where-Object {
            $_.author -ne 'TrendingBot' -and
            $_.over_18 -eq $false -and
            $_.is_video -eq $false -and
            $_.url -notlike "*gallery*" -and
            $_.url -notlike "*v.redd*" -and
            $_.url -notlike "*gif*" -and
            $_.is_self -eq $false
        }

        $WoofImage = Get-Random $WoofFilter -Count 1


    #Region     [ Adjust for Puppies ]

        $DeployPuppy = [bool]( $WoofURI -like "*puppies*" )

            switch ($DeployPuppy) {
                $true  {
                    $TitleText = "The Daily Doggo - !!! INCOMING PUPPY !!!"
                    $TitleColor = "warning"
                    $SubTitleText = "- I'll be the bestest boy/girl ever! \r"
                    $FactText = "Did you know: _$($WoofFact)_"
                    $ImageHeight = 'auto'
                }
                $false {
                    $TitleText = "The Daily Doggo!"
                    $TitleColor = "accent"
                    $SubTitleText = "- Borking at the evil vacuum monster since 1907 \r"
                    $FactText = "Did you know: _$($WoofFact)_"
                    $ImageHeight = '350px'
                }

            }

    #EndRegion  [ Adjust for Puppies ]

    }
    catch {
        Write-Error $_
        "$(Get-Date -Format yyyy-MM-dd-HH:mm)-[ Step (1/3) ]-$($_.Exception.Message)" | Out-File $TXTReport -Append -Encoding utf8

        exit 1
    }

#EndRegion  [ Woof Data ]

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Formatting Woof data"
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
            "body":[
                    {
                        "type": "TextBlock",
                        "size": "Large",
                        "weight": "Bolder",
                        "color": "$TitleColor",
                        "text": "$TitleText"
                    },
                    {
                        "type": "TextBlock",
                        "size": "Small",
                        "text": "$SubTitleText",
                        "isSubtle" : true
                    },
                    {
                        "type": "TextBlock",
                        "text": "$FactText",
                        "wrap": true
                    },
                    {
                        "type": "Image",
                        "url": "$($WoofImage.url)",
                        "altText": "$($WoofImage.title)",
                        "height": "$ImageHeight",
                        "width": "auto",
                        "msTeams": {
                            "allowExpand": true
                        }
                    }
                ],
                "actions": [
                    {
                        "type": "Action.OpenUrl",
                        "title": "Adopt a Doggo",
                        "url": "https://www.hsbh.org/adopt-a-dog/#adopt-a-dog"
                    },
                    {
                        "type": "Action.OpenUrl",
                        "title": "Source",
                        "url": "https://reddit.com$($WoofImage.permalink)"
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

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Sending Woof Data"
    $StepNumber++

    try {
        Invoke-RestMethod -Uri $TeamsURI -Method Post -ContentType 'application/json' -Body $JsonBody > $null

        $FunctionNameReturn = [PSCustomObject]@{
            Uri     = $WoofURI
            Data    = $WoofFilter
            Fact    = $WoofFact
            Image   = $WoofImage
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