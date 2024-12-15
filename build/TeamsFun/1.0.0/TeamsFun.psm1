#Region '.\Public\Cat\Send-TeamsPurr.ps1' -1


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
#EndRegion '.\Public\Cat\Send-TeamsPurr.ps1' 269
#Region '.\Public\Dad\Send-TeamsDadJoke.ps1' -1


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
#EndRegion '.\Public\Dad\Send-TeamsDadJoke.ps1' 198
#Region '.\Public\Dog\Send-TeamsWoof.ps1' -1


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

    $FunctionName           = $MyInvocation.InvocationName
    $ErrorActionPreference  = 'Stop'

}

process {

#Region     [ Prerequisites ]

    $Log        = "C:\Celerium\Logs\$FunctionName-Report"
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
#EndRegion '.\Public\Dog\Send-TeamsWoof.ps1' 263
#Region '.\Public\Pokemon\Send-TeamsPokemon.ps1' -1

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

    $FunctionName           = $MyInvocation.InvocationName
    $ErrorActionPreference  = 'Stop'

}

process {

#Region     [ Prerequisites ]

    $Log        = "C:\Celerium\Logs\$FunctionName-Report"
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
#EndRegion '.\Public\Pokemon\Send-TeamsPokemon.ps1' 372
