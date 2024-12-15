---
title: Tracking CSV
parent: Home
nav_order: 2
---

# Tracking CSV

When updating the documentation for this project, the tracking CSV plays a huge part in organizing of the markdown documents. Any new functions or endpoints should be added to the tracking CSV when publishing an updated module or documentation version.

{: .warning }
I recommend downloading the CSV from the link provided rather then viewing the table below.

[Tracking CSV](https://github.com/Celerium/TeamsFun/blob/main/docs/Endpoints.csv)

---

## CSV markdown table

|Category |EndpointUri                             |Method|Function                       |Complete|Notes|
|---------|----------------------------------------|------|-------------------------------|--------|-----|
|berry    |/berry/                                 |GET   |Get-PokeBerry                  |YES     |     |
|berry    |/berry/{id or name}/                    |GET   |Get-PokeBerry                  |YES     |     |
|berry    |/berry-firmness                         |GET   |Get-PokeBerryFirmness          |YES     |     |
|berry    |/berry-firmness/{id or name}/           |GET   |Get-PokeBerryFirmness          |YES     |     |
|berry    |/berry-flavor/                          |GET   |Get-PokeBerryFlavor            |YES     |     |
|berry    |/berry-flavor/{id or name}/             |GET   |Get-PokeBerryFlavor            |YES     |     |
|contest  |/contest-type/                          |GET   |Get-PokeContestType            |YES     |     |
|contest  |/contest-type/{id or name}/             |GET   |Get-PokeContestType            |YES     |     |
|contest  |/contest-effect/                        |GET   |Get-PokeContestEffect          |YES     |     |
|contest  |/contest-effect/{id}/                   |GET   |Get-PokeContestEffect          |YES     |     |
|contest  |/super-contest-effect/                  |GET   |Get-PokeContestSuperEffect     |YES     |     |
|contest  |/super-contest-effect/{id}/             |GET   |Get-PokeContestSuperEffect     |YES     |     |
|encounter|/encounter-method/                      |GET   |Get-PokeEncounterMethod        |YES     |     |
|encounter|/encounter-method/{id or name}/         |GET   |Get-PokeEncounterMethod        |YES     |     |
|encounter|/encounter-condition/                   |GET   |Get-PokeEncounterCondition     |YES     |     |
|encounter|/encounter-condition/{id or name}/      |GET   |Get-PokeEncounterCondition     |YES     |     |
|encounter|/encounter-condition-value/{id or name}/|GET   |Get-PokeEncounterConditionValue|YES     |     |
|encounter|/encounter-condition-value/{id or name}/|GET   |Get-PokeEncounterConditionValue|YES     |     |
|evolution|/evolution-chain/                       |GET   |Get-PokeEvolutionChain         |YES     |     |
|evolution|/evolution-chain/{id}/                  |GET   |Get-PokeEvolutionChain         |YES     |     |
|evolution|/evolution-trigger/                     |GET   |Get-PokeEvolutionTrigger       |YES     |     |
|evolution|/evolution-trigger/{id or name}/        |GET   |Get-PokeEvolutionTrigger       |YES     |     |
|game     |/generation/                            |GET   |Get-PokeGameGeneration         |YES     |     |
|game     |/generation/{id or name}/               |GET   |Get-PokeGameGeneration         |YES     |     |
|game     |/pokedex/                               |GET   |Get-PokeGamePokedex            |YES     |     |
|game     |/pokedex/{id or name}/                  |GET   |Get-PokeGamePokedex            |YES     |     |
|game     |/version/                               |GET   |Get-PokeGameVersion            |YES     |     |
|game     |/version/{id or name}/                  |GET   |Get-PokeGameVersion            |YES     |     |
|game     |/version-group/                         |GET   |Get-PokeGameVersionGroup       |YES     |     |
|game     |/version-group/{id or name}/            |GET   |Get-PokeGameVersionGroup       |YES     |     |
|Internal |                                        |POST  |Add-PokeBaseURI                |YES     |     |
|Internal |                                        |PUT   |ConvertTo-PokeQueryString      |YES     |     |
|Internal |                                        |GET   |Export-PokeModuleSettings      |YES     |     |
|Internal |                                        |GET   |Get-PokeBaseURI                |YES     |     |
|Internal |                                        |GET   |Get-PokeMetaData               |YES     |     |
|Internal |                                        |GET   |Get-PokeModuleSettings         |YES     |     |
|Internal |                                        |SET   |Import-PokeModuleSettings      |YES     |     |
|Internal |                                        |GET   |Invoke-PokeRequest             |YES     |     |
|Internal |                                        |DELETE|Remove-PokeBaseURI             |YES     |     |
|Internal |                                        |DELETE|Remove-PokeModuleSettings      |YES     |     |
|item     |/item/                                  |GET   |Get-PokeItem                   |YES     |     |
|item     |/item/{id or name}/                     |GET   |Get-PokeItem                   |YES     |     |
|item     |/item-attribute/                        |GET   |Get-PokeItemAttribute          |YES     |     |
|item     |/item-attribute/{id or name}/           |GET   |Get-PokeItemAttribute          |YES     |     |
|item     |/item-category/                         |GET   |Get-PokeItemCategory           |YES     |     |
|item     |/item-category/{id or name}/            |GET   |Get-PokeItemCategory           |YES     |     |
|item     |/item-fling-effect/                     |GET   |Get-PokeItemFlingEffect        |YES     |     |
|item     |/item-fling-effect/{id or name}/        |GET   |Get-PokeItemFlingEffect        |YES     |     |
|item     |/item-pocket/                           |GET   |Get-PokeItemPocket             |YES     |     |
|item     |/item-pocket/{id or name}/              |GET   |Get-PokeItemPocket             |YES     |     |
|location |/location/                              |GET   |Get-PokeLocation               |YES     |     |
|location |/location/{id or name}/                 |GET   |Get-PokeLocation               |YES     |     |
|location |/location-area/                         |GET   |Get-PokeLocationArea           |YES     |     |
|location |/location-area/{id or name}/            |GET   |Get-PokeLocationArea           |YES     |     |
|location |/pal-park-area/                         |GET   |Get-PokeLocationPalParkArea    |YES     |     |
|location |/pal-park-area/{id or name}/            |GET   |Get-PokeLocationPalParkArea    |YES     |     |
|location |/region/                                |GET   |Get-PokeLocationRegion         |YES     |     |
|location |/region/{id or name}/                   |GET   |Get-PokeLocationRegion         |YES     |     |
|machine  |/machine/                               |GET   |Get-PokeMachine                |YES     |     |
|machine  |/machine/{id}/                          |GET   |Get-PokeMachine                |YES     |     |
|move     |/move/                                  |GET   |Get-PokeMove                   |YES     |     |
|move     |/move/{id or name}/                     |GET   |Get-PokeMove                   |YES     |     |
|move     |/move-ailment/                          |GET   |Get-PokeMoveAilment            |YES     |     |
|move     |/move-ailment/{id or name}/             |GET   |Get-PokeMoveAilment            |YES     |     |
|move     |/move-battle-style/                     |GET   |Get-PokeMoveBattleStyle        |YES     |     |
|move     |/move-battle-style/{id or name}/        |GET   |Get-PokeMoveBattleStyle        |YES     |     |
|move     |/move-category/                         |GET   |Get-PokeMoveCategory           |YES     |     |
|move     |/move-category/{id or name}/            |GET   |Get-PokeMoveCategory           |YES     |     |
|move     |/move-damage-class/                     |GET   |Get-PokeMoveDamageClass        |YES     |     |
|move     |/move-damage-class/{id or name}/        |GET   |Get-PokeMoveDamageClass        |YES     |     |
|move     |/move-learn-method/                     |GET   |Get-PokeMoveLearnMethod        |YES     |     |
|move     |/move-learn-method/{id or name}/        |GET   |Get-PokeMoveLearnMethod        |YES     |     |
|move     |/move-target/                           |GET   |Get-PokeMoveTarget             |YES     |     |
|move     |/move-target/{id or name}/              |GET   |Get-PokeMoveTarget             |YES     |     |
|pokemon  |/ability/                               |GET   |Get-PokePokemonAbility         |Yes     |     |
|pokemon  |/ability/{id or name}/                  |GET   |Get-PokePokemonAbility         |Yes     |     |
|pokemon  |/characteristic/                        |GET   |Get-PokePokemonCharacteristic  |Yes     |     |
|pokemon  |/characteristic/{id}/                   |GET   |Get-PokePokemonCharacteristic  |Yes     |     |
|pokemon  |/egg-group/                             |GET   |Get-PokePokemonEggGroup        |Yes     |     |
|pokemon  |/egg-group/{id or name}/                |GET   |Get-PokePokemonEggGroup        |Yes     |     |
|pokemon  |/gender/                                |GET   |Get-PokePokemonGender          |Yes     |     |
|pokemon  |/gender/{id or name}/                   |GET   |Get-PokePokemonGender          |Yes     |     |
|pokemon  |/growth-rate/                           |GET   |Get-PokePokemonGrowthRate      |Yes     |     |
|pokemon  |/growth-rate/{id or name}/              |GET   |Get-PokePokemonGrowthRate      |Yes     |     |
|pokemon  |/nature/                                |GET   |Get-PokePokemonNature          |Yes     |     |
|pokemon  |/nature/{id or name}/                   |GET   |Get-PokePokemonNature          |Yes     |     |
|pokemon  |/pokeathlon-stat/                       |GET   |Get-PokePokemonPokeathlonStat  |Yes     |     |
|pokemon  |/pokeathlon-stat/{id or name}/          |GET   |Get-PokePokemonPokeathlonStat  |Yes     |     |
|pokemon  |/pokemon/                               |GET   |Get-PokePokemon                |Yes     |     |
|pokemon  |/pokemon/{id or name}/                  |GET   |Get-PokePokemon                |Yes     |     |
|pokemon  |/pokemon/{id or name}/encounters        |GET   |Get-PokePokemonEncounter       |Yes     |     |
|pokemon  |/pokemon-color/                         |GET   |Get-PokePokemonColor           |Yes     |     |
|pokemon  |/pokemon-color/{id or name}/            |GET   |Get-PokePokemonColor           |Yes     |     |
|pokemon  |/pokemon-form/                          |GET   |Get-PokePokemonForm            |Yes     |     |
|pokemon  |/pokemon-form/{id or name}/             |GET   |Get-PokePokemonForm            |Yes     |     |
|pokemon  |/pokemon-habitat/                       |GET   |Get-PokePokemonHabitat         |Yes     |     |
|pokemon  |/pokemon-habitat/{id or name}/          |GET   |Get-PokePokemonHabitat         |Yes     |     |
|pokemon  |/pokemon-shape/                         |GET   |Get-PokePokemonShape           |Yes     |     |
|pokemon  |/pokemon-shape/{id or name}/            |GET   |Get-PokePokemonShape           |Yes     |     |
|pokemon  |/pokemon-species/                       |GET   |Get-PokePokemonSpecies         |Yes     |     |
|pokemon  |/pokemon-species/{id or name}/          |GET   |Get-PokePokemonSpecies         |Yes     |     |
|pokemon  |/stat/                                  |GET   |Get-PokePokemonStat            |Yes     |     |
|pokemon  |/stat/{id or name}/                     |GET   |Get-PokePokemonStat            |Yes     |     |
|pokemon  |/type/                                  |GET   |Get-PokePokemonType            |Yes     |     |
|pokemon  |/type/{id or name}/                     |GET   |Get-PokePokemonType            |Yes     |     |
|utility  |/language/                              |GET   |Get-PokeLanguage               |Yes     |     |
|utility  |/language/{id or name}/                 |GET   |Get-PokeLanguage               |Yes     |     |
|utility  |/                                       |GET   |Get-PokeEndpoint               |Yes     |     |
