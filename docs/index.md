---
external help file: TeamsFun-help.xml
Module Name: TeamsFun
online version: https://github.com/Celerium/TeamsFun
schema: 2.0.0
title: Home
has_children: true
layout: default
nav_order: 1
---

# TeamsFun

Just a simple module for posting silly things to Microsoft Teams

Contains the following cmdlets

- Send-TeamsDadJoke
- Send-TeamsPokemon
- Send-TeamsPurr
- Send-TeamsWoof

## Initial Setup & Running

1. Teams Channel > Connectors > Incoming Webhook
    - Give the webhook a name, logo, & create the webhook
2. Copy the URI
    - The URI is how you tell the script what teams channel to send a post to

```posh
    .\Send-TeamsPurr.ps1 -TeamsURI 'https://outlook.office.com/webhook/123/.....'
```

## Help :blue_book:

- Help info and a list of parameters can be found by running `Get-Help .\CommandName`, such as:

```posh
Get-Help Send-TeamsPurr.ps1
Get-Help Send-TeamsPurr.ps1 -Full
```

---

## Send-TeamsDadJoke

Dad jokes are randomly selected from [icanhazdadjoke.com](icanhazdadjoke.com)

![Send-TeamsDadJoke](https://raw.githubusercontent.com/Celerium/TeamsFun/main/.github/Celerium-Send-DadJoke-Example001.png)

---

## Send-TeamsPokemon

Pokemon data is pulled from the [PokeAPI API](https://pokeapi.co/) using the [PokeAPI Powershell wrapper](https://www.powershellgallery.com/packages/PokeAPI)

When this script runs it randomly selects a day of the week and tries to match it to the current day of the week. I put this in to simulate wondering through tall grass to randomly get a pokemon

![Send-TeamsPokemon](https://raw.githubusercontent.com/Celerium/TeamsFun/main/.github/Celerium-Send-Pokemon-Example001.png)

---

## Send-TeamsPurr

An image is randomly selected from a random cat subreddit. Cat facts are pulled from the catfact.ninja API
When the r/Chonkers subreddit is used, the Teams post will be formatting to accommodate for the chonks size.

![Send-TeamsPurr](https://raw.githubusercontent.com/Celerium/TeamsFun/main/.github/Celerium-Send-Purr-Example001.png)

---

## Send-TeamsWoof

An image is randomly selected from a random dog subreddit. Dog facts are pulled from the [Dog API](https://dogapi.dog)
When the r/Puppies subreddit is used, the Teams post will be formatting to accommodate for the puppies size.

![Send-TeamsWoof](https://raw.githubusercontent.com/Celerium/TeamsFun/main/.github/Celerium-Send-Woof-Example001.png)

---
