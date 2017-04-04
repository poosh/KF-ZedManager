class ZedCfgN extends ZedManagerMut;

defaultproperties
{
    FriendlyName="ZED Manager - Mixed Zeds 2"
    Description="Random event zeds, e.g. Normal Clot + Circus Clot + XMas Clot etc."
    
    bAllowVoting=false
    
    ZedDefs(0)=(Kind="CLOT",UserName="Clot",ClassName="KFChar.ZombieClot_STANDARD",bEnabled=True)
    ZedDefs(1)=(Kind="CRAWLER",UserName="Crawler",ClassName="KFChar.ZombieCrawler_STANDARD",bEnabled=True)
    ZedDefs(2)=(Kind="GOREFAST",UserName="Gorefast",ClassName="KFChar.ZombieGorefast_STANDARD",bEnabled=True)
    ZedDefs(3)=(Kind="STALKER",UserName="Stalker",ClassName="KFChar.ZombieStalker_STANDARD",bEnabled=True)
    ZedDefs(4)=(Kind="SCRAKE",UserName="Scrake",ClassName="KFChar.ZombieScrake_STANDARD",bEnabled=True)
    ZedDefs(5)=(Kind="FLESHPOUND",UserName="Fleshpound",ClassName="KFChar.ZombieFleshpound_STANDARD",bEnabled=True)
    ZedDefs(6)=(Kind="BLOAT",UserName="Bloat",ClassName="KFChar.ZombieBloat_STANDARD",bEnabled=True)
    ZedDefs(7)=(Kind="SIREN",UserName="Siren",ClassName="KFChar.ZombieSiren_STANDARD",bEnabled=True)
    ZedDefs(8)=(Kind="HUSK",UserName="Husk",ClassName="KFChar.ZombieHusk_STANDARD",bEnabled=True)
    ZedDefs(9)=(Kind="BOSS",UserName="Boss",ClassName="KFChar.ZombieBoss_STANDARD",bEnabled=True)
    ZedDefs(10)=(Kind="BOSS",UserName="BossC",ClassName="KFChar.ZombieBoss_CIRCUS",bEnabled=True)
    ZedDefs(11)=(Kind="BOSS",UserName="BossH",ClassName="KFChar.ZombieBoss_HALLOWEEN",bEnabled=True)
    ZedDefs(12)=(Kind="BOSS",UserName="BossX",ClassName="KFChar.ZombieBoss_XMas",bEnabled=True)
    
    ZedRepl(0)=(From="KFChar.ZombieClot_STANDARD",To="KFChar.ZombieClot_CIRCUS",Chance=0.25)
    ZedRepl(1)=(From="KFChar.ZombieClot_STANDARD",To="KFChar.ZombieClot_HALLOWEEN",Chance=0.25)
    ZedRepl(2)=(From="KFChar.ZombieClot_STANDARD",To="KFChar.ZombieClot_XMas",Chance=0.25)
    ZedRepl(3)=(From="KFChar.ZombieCrawler_STANDARD",To="KFChar.ZombieCrawler_CIRCUS",Chance=0.25)
    ZedRepl(4)=(From="KFChar.ZombieCrawler_STANDARD",To="KFChar.ZombieCrawler_HALLOWEEN",Chance=0.25)
    ZedRepl(5)=(From="KFChar.ZombieCrawler_STANDARD",To="KFChar.ZombieCrawler_XMas",Chance=0.25)
    ZedRepl(6)=(From="KFChar.ZombieGorefast_STANDARD",To="KFChar.ZombieGorefast_CIRCUS",Chance=0.25)
    ZedRepl(7)=(From="KFChar.ZombieGorefast_STANDARD",To="KFChar.ZombieGorefast_HALLOWEEN",Chance=0.25)
    ZedRepl(8)=(From="KFChar.ZombieGorefast_STANDARD",To="KFChar.ZombieGorefast_XMas",Chance=0.25)
    ZedRepl(9)=(From="KFChar.ZombieStalker_STANDARD",To="ScrnMonsters.ZombieGhost",Chance=0.30)
    ZedRepl(10)=(From="KFChar.ZombieStalker_STANDARD",To="KFChar.ZombieStalker_CIRCUS",Chance=0.20)
    ZedRepl(11)=(From="KFChar.ZombieStalker_STANDARD",To="KFChar.ZombieStalker_HALLOWEEN",Chance=0.20)
    ZedRepl(12)=(From="KFChar.ZombieStalker_STANDARD",To="KFChar.ZombieStalker_XMas",Chance=0.20)
    ZedRepl(13)=(From="KFChar.ZombieScrake_STANDARD",To="KFChar.ZombieScrake_CIRCUS",Chance=0.25)
    ZedRepl(14)=(From="KFChar.ZombieScrake_STANDARD",To="KFChar.ZombieScrake_HALLOWEEN",Chance=0.25)
    ZedRepl(15)=(From="KFChar.ZombieScrake_STANDARD",To="KFChar.ZombieScrake_XMas",Chance=0.25)
    ZedRepl(16)=(From="KFChar.ZombieFleshpound_STANDARD",To="KFChar.ZombieFleshpound_CIRCUS",Chance=0.25)
    ZedRepl(17)=(From="KFChar.ZombieFleshpound_STANDARD",To="KFChar.ZombieFleshpound_HALLOWEEN",Chance=0.25)
    ZedRepl(18)=(From="KFChar.ZombieFleshpound_STANDARD",To="KFChar.ZombieFleshpound_XMas",Chance=0.25)
    ZedRepl(19)=(From="KFChar.ZombieBloat_STANDARD",To="KFChar.ZombieBloat_CIRCUS",Chance=0.25)
    ZedRepl(20)=(From="KFChar.ZombieBloat_STANDARD",To="KFChar.ZombieBloat_HALLOWEEN",Chance=0.25)
    ZedRepl(21)=(From="KFChar.ZombieBloat_STANDARD",To="KFChar.ZombieBloat_XMas",Chance=0.25)
    ZedRepl(22)=(From="KFChar.ZombieSiren_STANDARD",To="KFChar.ZombieSiren_CIRCUS",Chance=0.25)
    ZedRepl(23)=(From="KFChar.ZombieSiren_STANDARD",To="KFChar.ZombieSiren_HALLOWEEN",Chance=0.25)
    ZedRepl(24)=(From="KFChar.ZombieSiren_STANDARD",To="KFChar.ZombieSiren_XMas",Chance=0.25)
    ZedRepl(25)=(From="KFChar.ZombieHusk_STANDARD",To="KFChar.ZombieHusk_CIRCUS",Chance=0.25)
    ZedRepl(26)=(From="KFChar.ZombieHusk_STANDARD",To="KFChar.ZombieHusk_HALLOWEEN",Chance=0.25)
    ZedRepl(27)=(From="KFChar.ZombieHusk_STANDARD",To="KFChar.ZombieHusk_XMas",Chance=0.25)
}  