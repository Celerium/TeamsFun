
function Send-TeamsPurr {
<#
.NOTES
    NAME: Send-TeamsPurr.ps1
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
    Sends a cat image & fact to a Teams channel

.DESCRIPTION
    The Send-TeamsPurr cmdlet sends a cat image & fact to a Teams channel using a Teams webhook connector URI.

    Various filters are in place to try and prevent any inappropriate images from being sent.

    An image is randomly selected from a random cat subreddit. Cat facts are pulled from the catfact.ninja API
    When the r/Chonkers subreddit is used, the Teams post will be formatting to accommodate for the chonks size.

    Unless the -Verbose parameter is used, no output is displayed

.PARAMETER TeamsURI
    A string that defines where the Microsoft Teams connector URI sends information to

.EXAMPLE
    .\Send-TeamsPurr.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....'

    Using the defined webhooks connector URI a random cat image & fact are sent to the webhooks Teams channel

    No output is displayed to the console.

.EXAMPLE
    .\Send-TeamsPurr.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....' -Verbose

    Using the defined webhooks connector URI a random cat image & fact are sent to the webhooks Teams channel.

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

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Configuring Purrequisites"
    $StepNumber++

    if ( (Test-Path -Path $Log -PathType Container) -eq $false ) {
        New-Item -Path $Log -ItemType Directory > $null
    }

#EndRegion  [ Prerequisites ]

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Getting purr data"
    $StepNumber++

#Region     [ Purr Data ]

    try {

        $PurrSources = @(   'https://www.reddit.com/r/catpics/.json?sort=top&t=week&limit=25' ,
                            'https://www.reddit.com/r/IllegallySmolCats/.json?sort=top&t=week&limit=25' ,
                            'https://www.reddit.com/r/CatsInBusinessAttire/.json?sort=top&t=week&limit=25' ,
                            'https://www.reddit.com/r/Thisismylifemeow/.json?sort=top&t=week&limit=25' ,
                            'https://www.reddit.com/r/CatsStandingUp/.json?sort=top&t=week&limit=25',
                            'https://www.reddit.com/r/Chonkers/.json?sort=top&t=week&limit=25'
                    )
        $PurrURI = Get-Random -InputObject $PurrSources -Count 1

        $PurrData = Invoke-RestMethod -Uri $PurrURI
        $PurrFact = (Invoke-RestMethod -Uri 'https://catfact.ninja/fact').fact

        $PurrFilter = $PurrData.data.children.data | Where-Object {
            $_.author -ne 'TrendingBot' -and
            $_.over_18 -eq $false -and
            $_.is_video -eq $false -and
            $_.url -notlike "*gallery*" -and
            $_.url -notlike "*v.redd*" -and
            $_.url -notlike "*gif*" -and
            $_.is_self -eq $false
        }

        $PurrImage = Get-Random $PurrFilter -Count 1


    #Region     [ Adjust for chonker ]

        $DeployChonker = [bool]( $PurrURI -like "*Chonker*" )

        switch ($DeployChonker) {
            $true  {
                $TitleText = "The Daily Purr! - !!! INCOMING CHONKER !!!"
                $TitleColor = "warning"
                $SubTitleText = "- This is what peak performance looks like \r"
                $FactText = "We love pictures of chonkers, but the only thing we love more is a fine boy who was a chonker and has become healthy! If this is your chonk, please check out these links.
                    \r- [How To Put Your Cat On A Diet](https://pets.webmd.com/cats/guide/healthy-weight-for-your-cat#1)
                    \r- [Is My Cat Obese?](https://diamondcarepetfood.com/why-or-is-my-cat-fat/)
                    \r- [Pet Weight Calculator](https://www.petmd.com/healthyweight?mobi_bypass=true)
                    \r- [Getting Your Tubby Tabby Back Into Shape](https://pets.webmd.com/cats/guide/fat-cats-getting-tubby-tabby-back-into-shape#1) \r
                "
                $ImageHeight = 'auto'
            }
            $false {
                $TitleText = "The Daily Purr!"
                $TitleColor = "accent"
                $SubTitleText = "- Meowing for no reason at all since 7500BC \r"
                $FactText = "Did you know: _$($PurrFact)_"
                $ImageHeight = '350px'
            }

        }

    #EndRegion  [ Adjust for chonker ]

    }
    catch {
        Write-Error $_
        "$(Get-Date -Format yyyy-MM-dd-HH:mm)-[ Step (1/3) ]-$($_.Exception.Message)" | Out-File $TXTReport -Append -Encoding utf8

        exit 1
    }

#EndRegion  [ Purr Data ]

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Formatting purr data"
    $StepNumber++

#Region     [ Main Code ]

    $JsonBody = @"

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
                        "url": "$($PurrImage.url)",
                        "altText": "$($PurrImage.title)",
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
                        "title": "Adopt a kitty",
                        "url": "https://www.hsbh.org/adopt-a-cat/#adopt-a-cat"
                    },
                    {
                        "type": "Action.OpenUrl",
                        "title": "Source",
                        "url": "https://reddit.com$($PurrImage.permalink)"
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

    Write-Verbose " - ($StepNumber/3) - $(Get-Date -Format MM-dd-HH:mm) - Sending Purr Data"
    $StepNumber++

    try {
        Invoke-RestMethod -Uri $TeamsURI -Method Post -ContentType 'application/json' -Body $JsonBody > $null

        $FunctionNameReturn = [PSCustomObject]@{
            Uri     = $PurrURI
            Data    = $PurrFilter
            Fact    = $PurrFact
            Image   = $PurrImage
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