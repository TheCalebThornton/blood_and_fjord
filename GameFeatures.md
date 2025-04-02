## Features / Mechanics
- Turn-based tactical combat system
- Rougelite systems (RNG upgrades per map, in-map extras, unloackables outside of gameplay loop)
- Terrain specific tiles with combat and movement influence
- Characters and classes
- Series of levels (maps) with increasing difficulty
- Custom Norse themed art (If I can get an artist for this)

## Classes
### Base classes
- Raider  (Drengr) – A term for a brave and honorable warrior.
- Shieldbearer (Huskarl) – Elite Viking bodyguards and warriors.
- Runecaster (Seiðkona / Seiðmenn) – Norse practitioners of magic (Seiðr).
- Shadow Seer (Vǫlva) – A powerful female sorcerer or shaman.
- Spiritcaller (Galdrsmith) – One who weaves Galdr, magical chants.
- Priest (Goði / Gyðja) – A priest or priestess of Norse faith.
- Shade (Skuggi) – Meaning "shadow," fitting for stealthy fighters.
- Hunter (Bogmaður) – Norse term for bowmen.
- Rider (Riddari) – Norse for a mounted warrior (borrowed from chivalric influences).
- Bowrider (Veiðimaðr) – Meaning "huntsman," a mounted archer.
- Healer (Lækni) – Healer or doctor in Old Norse.
- Sky Rider (Vindridari) – "Wind Rider," inspired by mythical Norse flying steeds.
- Dragonkin (Fáfnirson) – Named after Fáfnir, the legendary dragon.

### Evolved classes and requirements
- Berserker - (Raider lvl 10, ?? upgrade)
- Reaver – (Raider/Shieldbearer lvl 10, ?? upgrade)
- Warlord – (Shieldbearer lvl 10, ?? upgrade)
- Runemaster – (Runecaster lvl 10, ?? upgrade)
- Flamecaller – (Runecaster/Shadow Seer lvl 10, ?? upgrade)
- Dreadcaller – (Shadow Seer lvl 10, ?? upgrade) Add undead allies
- Runesmith – (Spiritcaller lvl 10, ?? upgrade)
- Stormcaller – (Spiritcaller/Priest lvl 10, ?? upgrade)
- High Priest – (Priest lvl 10, ?? upgrade)
- Nightblade – (Shade lvl 10, ?? upgrade)
- Beastmaster – (Shade/Hunter lvl 10, ?? upgrade) Adds an ally pet spawn
- Sharpshot – (Hunter lvl 10, ?? upgrade)
- Charioteer – (Rider lvl 10, ?? upgrade)
- Wanderer – (Rider/Bowrider lvl 10, ?? upgrade)
- Valkyrie – (Healer lvl 10, ?? upgrade)
- Skyguard – (Healer/Sky Rider lvl 10, ?? upgrade)
- Valgryph – (Sky Rider/Dragonkin lvl 10, ?? upgrade)
- Dragonlord – (Dragonkin lvl 10, ?? upgrade)

## Terrain / Weather
### Terrain
- Plains (N/A)
- Forest (-1 movement, +20 avoid)
- Sand (-2 movement, -20 avoid)
  - Mounted: -3 movement
- Fortress (+2 defense, +10 avoid)
  - Mounted: -1 movement
- Mountains (-99 movement, +10 avoid)
- Wall (-99 movement)
- Water (-99 movement, +20 avoid)
- Cliff (-99 movement, -20 avoid)
- Fliers ignore terrain effects

### Weather
- Normal (N/A)
- Extreme Heat (-1 movement)
  - Flamecaller: +3 magic
- Rain (-1 movement, -10 accuracy)
  - Mounted: -2 movement
  - Stormcaller: +20 avoid
  - Flamecaller: -3 magic
- Thunderstorm (-1 movement, -20 accuracy)
  - Mounted/Flier: -2 movement
  - Stormcaller: +3 magic, effective against fliers
  - Flamecaller: +2 magic
- Snow (-2 movement, +10 accuracy)
  - Fliers: -3 movement

## Rougelite in-game features
Features that apply during gameplay and are lost upon defeat.

### Auras / gifts (Every other map victory)
4 maximum unique Auras. Each Aura has 3 ranks.
- Might makes right
  - No more chip exp, but +50/100/150% exp on killing blow
- Mystic reach
  - All magic units gain +1/2/3 attack range
- Higher altitude
  - +5/10/15 avoid for flying units
- Brambles
  - X = lvl/5, lvl/3, lvl/2 (Min dmg is 1)
  - Inflict X true damage when hit
- Best friends
  - Being adjacent to allies gives +3/5/10 accuracy and avoid
- Mount breeder
  - Mounted units gain 3/5/10 extra max HP
- More TBD

### In-map chests/items
Map chests/items are revealed on map tiles but hidden by fog, unless otherwise specified
- Multi-Heart icon
  - +30% max HP all units
- Heart icon
  - +100% max HP for unit
- Chest icon
  - Max gifts per chest is 3
  - If we have Class Promotions requirements, promote a random eligible unit
  - RNG roll for the following:
    - Stat Buff: +1 Hp,Str,Mag,Agi,Def,Res
	- Weight these rolls based on class

### Unit experience/level ups

## Roguelite post-game features/unlockables
Features that are 'unlocked' based on gameplay and persist across plays

### Starting Armies
- Triple Raider (3 Raiders, lvl 1, default)
- Solo Raider (1 Raider, lvl 8, default)
- CSL Army (??, ??, ??)
  - Reach map 3
- BLM Army (??, ??, ??)
  - Reach map 4
- JHA Army (??, ??, ??)
  - Reach map 5

### Aura options
- Re-roll (each stat below unlocks a charge, up to 3x)
  - Beat map 2 in 5 rounds
  - Beat map 5 with no casualties
  - Beat map 1 without taking any damage
- Banish
  - Defeat 50 enemy Raiders
  - Defeat 100 enemy Shieldbearers
  - One-shot 30 enemy units
