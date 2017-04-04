# KF-ZedManager
Allows adding custom zeds to the game or/and replace stock zeds.

# Credits
ZED Manager (ex. Custom monster balance / ScrnMonstersMut)
(c) PooSH, 2012-2015
Contact via Steam: [ScrN]PooSH @
Official Steam Group: http://steamcommunity.com/groups/ScrNBalance

# Version History
## Version 5
v5.01:
- Fixed bug when some squads didn't spawned in Boss wave

v5.00:
- If multiple standard zed replacements are defined, then random ones
  will be chosen. This applies on end-game boss too.
- Added ServerPackages config variable
- ZedRepl config variable - runtime zed replacing
- Added ZedCfgM and ZedCfgN
- ZedManagerMut now is abstract class (can't be spawned). Use ZedCfg instead.

## Version 4
v4.40:
- Added new config for Pure DooM3 Mode (ZedCfgD).
  ScrnDoom3KF mutator is required to use this mode.
- MUTATE VOTE ZED <UserName> LOCK|UNCLOCK  -- allows server admin to lock/unlock zeds

v4.31:
- Configs updated to include Female Fleshpound MKII
- Added new config for SuperZombies.
  Note that Super Crawlers, Stalkers and Fleshpounds are not fully compatible
  without running SuperZombiesMut. Others super zeds can be used with out it.
  If you are using SuperZombiesMut, then set all zeds to FALSE in SuperZombieMut.ini.
- Replacing standard zeds replaces them in special and boss squads too.
- bAllowVoting is not global anymore and can be set for each config individually.
- Fixed Tesla Husk head's hitbox (thanks to Skell for an idea)
- Shivers now are spawning in last Boss squad too.
- Fixed Shiver's head hitbox
- Raised decapitation bonus for assault rifles. Now headshot from SCAR or FNFAL
  instantly kills 6p HoE Shiver.

v4.20:
- Compatible with KF 1062
- Configs updated to include Shafter, Goreshank, Sick and Fatale and
  support them "out-of-the-box"

v4.10:
- Added squad profiles for Shafter, Goreshank, Sick and Fatale
  (made by Forrest Mark X)
- ZED Manager now is marker as ServerSideOnly, i.e. clients don't have to d/l it
- Adjusted some squad profiles

v4.00 - ZED Manager:
- Allows replacing any stock zed with custom one (or another
  stock zeds). You can replace Stalkers with Ghosts, Bloats with Sicks,
  Husks with Hellfires or even Clots with Gorefasts!
- Allows setting any end game boss you wish.
- Has the following built-in custom monster profiles (spawning rules):
  Brute, Jason, Shiver, FemaleFP, Tesla Husk.
- Mutator isn't linked to any monster packages and can be used without
  any of them. For example, if server doesn't use Brute, then no more
  need of installing Brute's assets on the server.
- If monster is disabled, then its clients will not download its
  packages (code and assets) from the server.
- You can replace default custom monster with any other zed the same way
  as replacing stock zeds. For example, you can replace Tesla Husk with
  Fatale.
- Now you can you Balanced (SE - Scrn Edition) or original versions
  of Brute, Jason and Shiver.
- Mutator has 4 config profiles. Each profile can be used for a different
  game config in KFMapVove.
- Each custom zed can be voted on or off via MUTATE VOTE ZED console command.
- Uses ScrnVotingHandlerV4 (required).



## Version 3 (a.k.a. ScrnMonstersMut)
v3.51:
- Fixed wrong reference to ScrnMonstersMut_T.utx

v3.50:
New Specimen - GHOST: a Stalker with enhanced stealth field.
Ghosts are much harder to see (almost invisible at distance),
and Commandos can see them only from 12 meters (Stalkers - 16m).
Ghost can continuously run'n'hit as Super Stalker
(thanks to Scary Ghost for the code), but she doesn't cause bleeding.
Unlike Staker, Ghost always stays cloaked, even when she is hitting
the player or dying.
Sandbox name: ScrnMonstersMut.ZombieGhost

v3.04:
- Fixed Hard Pat... again :)

v3.03:
- Fixed Hard Pat

v3.02:
- Compatible with KF v1058
- Jasons don't turn around or dodge Husk projectiles while stunned

v3.00:
- 2013 XMas Event support
- Uses ScrnVotingHandler v3.00
- Added Tesla Husk support (not linked)
- Admins can bypass vote locks
- Shivers now are spawning starting from the first wave (only a few)


## Version 2
v2.22:
- Fixed a bug when Jason couldn't be stunned by the LAW or pipemobs
- Fixed Jason's stun animation bug (the same Scrake has)
- Added config options to lock voting on particular specimens


v2.20:
- Added support for Female FleshPound.
- Fixed a bug when messed up squads after many map switches

v2.14:
- HardPat doesn't trigger pipebombs while in God Mode (Escaping)
- Jason doesn't get unstunned by weak attacks (except missed headshots)

v2.12:
- Compatible with summer'2013 zeds
- Jason receives x1.5 damage from pipebombs

v2.11:
- Fixed bug in special squads [thanks to picapoo]

v2.10:
- Fixed error of accessing "none" variables, when monsters take environmental damage
- Jason doesn't instantly rage on 9mm bodyshots anymore

v2.08:
Improved Jason:
- Fixed bug, when first attack reset damage multiplier to normal. Before this
  Jason, starting with 2nd hit, made the same damage on all difficulties as
  no Normal. Scrake has the same bug.
- Fixed raged behavior. Now if Jason was raged, he won't stop until he's dead
  or team gets wiped. No more slow-mo after burning.
- [HoE] Jason is immediately unstunned from bodyshots made by sniper weapons.

v2.07:
HardPat reverted to normal

v2.01:
Added Marco's HardPat XMas edition

v2.00:
Added voting to turn on/off particular monsters, e.g.:
    mutate vote brute off
    mutate vote shiver on
    mutate vote jason on

2012-12-13 update:
Fixed squads that Tripwire screwed in TC3 event update
