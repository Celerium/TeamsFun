---
external help file: TeamsFun-help.xml
grand_parent: dad
Module Name: TeamsFun
online version: https://celerium.github.io/TeamsFun/site/dad/Send-TeamsDadJoke.html
parent: POST
schema: 2.0.0
title: Send-TeamsDadJoke
---

# Send-TeamsDadJoke

## SYNOPSIS
Sends a dad joke to a Teams channel

## SYNTAX

```powershell
Send-TeamsDadJoke [-TeamsUri] <String> [<CommonParameters>]
```

## DESCRIPTION
The Send-TeamsDadJoke cmdlet sends a dad joke to a Teams channel using a Teams webhook connector URI.

Unless the -Verbose parameter is used, no output is displayed

## EXAMPLES

### EXAMPLE 1
```
.\Send-TeamsDadJoke.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....'
```

Using the defined webhooks connector URI a random dad joke is sent to the webhooks Teams channel

No output is displayed to the console.

### EXAMPLE 2
```
.\Send-TeamsDadJoke.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/123/123/.....' -Verbose
```

Using the defined webhooks connector URI a random dad joke is sent to the webhooks Teams channel.

Output is displayed to the console.

## PARAMETERS

### -TeamsUri
A string that defines where the Microsoft Teams connector URI sends information to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### TeamsURI
## OUTPUTS

### Console
## NOTES
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

## RELATED LINKS

[https://www.celerium.org](https://www.celerium.org)

