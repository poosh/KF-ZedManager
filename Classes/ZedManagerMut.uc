/*
Custom monster balance mutator
(c) PooSH, 2012 - 2015
Contact via Steam: [ScrN]PooSH, 76561197992537591
*/

class ZedManagerMut extends Mutator
    config (Zeds)
    abstract;

const VERSION = 50200;
var localized string strVersion, strStatus;

const ZI_CLOT      = 0;
const ZI_CRAWLER   = 1;
const ZI_GOREFAST  = 2;
const ZI_STALKER   = 3;
const ZI_SCRAKE    = 4;
const ZI_FLESHPOUND= 5;
const ZI_BLOAT     = 6;
const ZI_SIREN     = 7;
const ZI_HUSK      = 8;

var const string MonsterGroup;
var KFGameType KF;

var config bool bAllowVoting;

struct SZedDef {
    var config string Kind, UserName;
    var config string Package, ClassName;
    var config bool bEnabled, bLocked;
};
var config array<SZedDef> ZedDefs;
var byte StandardReplacements[9];
var byte BossReplacements;

struct SZedRepl {
    var config string From, To;
    var config bool bChildren;
    var config byte StartWave, EndWave;
    var config float Chance;

    var transient class<KFMonster> FromClass, ToClass;
};
var config array<SZedRepl> ZedRepl;
var config array<string> ServerPackages;

var transient int PendingZeds, SquadsLeft;

static function string GetVersionStr()
{
    local String msg, s;
    local int v, sub_v;

    msg = default.strVersion;
    v = VERSION / 100;
    sub_v = VERSION % 100;

    s = String(int(v%100));
    if ( len(s) == 1 )
        s = "0" $ s;
    if ( sub_v > 0 )
        s @= "(BETA "$sub_v$")";
    ReplaceText(msg, "%n", s);

    s = String(v/100);
    ReplaceText(msg, "%m",s);

    return msg;
}

function String GetStatusStr()
{
    local int i;
    local String msg;

    msg = strStatus;
    for ( i=0; i<ZedDefs.length; ++i ) {
        if ( ZedDefs[i].bEnabled ) {
            msg @= ZedDefs[i].UserName;
            if ( !(ZedDefs[i].UserName ~= ZedDefs[i].Kind) )
                msg $= "("$ZedDefs[i].Kind$")";
        }
    }

    return msg;
}

/** Splits long message on short ones before sending it to client.
 *  Copy-pasted from ScrnBalance.
 *  @param   Sender     Player, who will receive message(-s).
 *  @param   S          String to send.
 *  @param   MaxLen     Max lenght of one string. Default: 80. If S is longer than this value,
 *                      then it will be splitted on serveral messages.
 *  @param  Divider     Character to be used as divider. Default: Space. String is splitted
 *                      at last divder's position before MaxLen is reached.
 */
static function LongMessage(PlayerController Sender, string S, optional int MaxLen, optional string Divider)
{
    local int pos;
    local string part;

    if ( Sender == none )
        return;
    if ( MaxLen == 0 )
        MaxLen = 80;
    if ( Divider == "" )
        Divider = " ";

    while ( len(part) + len(S) > MaxLen ) {
        pos = InStr(S, Divider);
        if ( pos == -1 )
            break; // no more dividers

        if ( part != "" && len(part) + pos + 1 > MaxLen) {
            Sender.ClientMessage(part);
            part = "";
        }
        part $= Left(S, pos + 1);
        S = Mid(S, pos+1);
    }

    part $= S;
    if ( part != "" )
        Sender.ClientMessage(part);
}



function Mutate(string MutateString, PlayerController Sender)
{
    super.Mutate(MutateString, Sender);

    if ( MutateString ~= "status" )
        LongMessage(Sender, GetStatusStr());
    else if ( MutateString ~= "version" )
        Sender.ClientMessage(FriendlyName @ GetVersionStr());
}

function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	// append the mutator name.
	local int i;

    super.GetServerDetails(ServerState);

	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.insert(i, 1);

	ServerState.ServerInfo[i].Key = "ZED Manager";
	ServerState.ServerInfo[i++].Value = GetVersionStr();
}





/**
 * Enables or disables squad spawn in a given wave mask.
 * @param	SquadID		Squad number, where 0 is the first squad (4 Clots), 1 - second (4 Clots + Bloat) etc.
 *						27 squads are used by KF. 5 squads (27-3) are avaliable yet.
 * @param 	WaveMask	[out] e.g. KF.LongWaves[9].WaveMask
 * @param	bEnable		Enable or disable squad spawn
 * @author 	PooSH
 */
function EnableSquadSpawn(byte SquadID, out int WaveMask, bool bEnable)
{
	local int a;

	if ( SquadID > 31 ) {
		warn("Only 32 squads can be used in the game (0-31)");
		return;
	}

	a = 1 << SquadID;
	if (bEnable)
		WaveMask = WaveMask | a;
	else
		WaveMask = WaveMask & (a ^ 0xFFFFFFFF);
}

/**
 * Enables or disables squad spawn in a given wave in the Short game.
 * Function must be called before KFGameType.InitGame() execution, e.g. from Mutator.PostBeginPlay()
 *
 * @param	SquadID		Squad number, where 0 is the first squad (4 Clots), 1 - second (4 Clots + Bloat) etc.
 *						27 squads are used by KF. 5 squads (27-3) are avaliable yet.
 * @param 	WaveNum		Wave number, where 0 indicates first wave, 1 - second etc.
 * @param	bEnable		Enable or disable squad spawn
 * @author 	PooSH
*/
function EnableShortSquadSpawn(byte SquadID, int WaveNum, bool bEnable)
{
	EnableSquadSpawn(SquadID, KF.ShortWaves[WaveNum].WaveMask, bEnable);
}
function EnableNormalSquadSpawn(byte SquadID, int WaveNum, bool bEnable)
{
	EnableSquadSpawn(SquadID, KF.NormalWaves[WaveNum].WaveMask, bEnable);
}
function EnableLongSquadSpawn(byte SquadID, int WaveNum, bool bEnable)
{
	EnableSquadSpawn(SquadID, KF.LongWaves[WaveNum].WaveMask, bEnable);
}

/**
 * Completely disables squad spawn in all waves.
 * @param	SquadID		Squad number, where 0 is the first squad (4 Clots), 1 - second (4 Clots + Bloat) etc.
 *						27 squads are used by KF. 5 squads (27-31) are avaliable yet.
 * @author 	PooSH
 */
function DisableSquadSpawn(byte SquadID)
{
	local int i;

	for ( i=0; i<16; ++i )
		EnableSquadSpawn(SquadID, KF.ShortWaves[i].WaveMask, false);
	for ( i=0; i<16; ++i )
		EnableSquadSpawn(SquadID, KF.NormalWaves[i].WaveMask, false);
	for ( i=0; i<16; ++i )
		EnableSquadSpawn(SquadID, KF.LongWaves[i].WaveMask, false);
}

// Original code taken from MutAddShivers (c) [WPC]
function ReplaceMonsterInSquad(byte SquadID, string SpecToReplace, int AmountToReplace, string NewMonsterID)
{
    if ( SquadID >= KF.StandardMonsterSquads.length ) {
        if ( SquadID > 31 )
            return; // 32 squads max
        KF.StandardMonsterSquads.length = SquadID + 1;
    }
	if (SpecToReplace != "")
		KF.StandardMonsterSquads[SquadID] = AmountToReplace $ NewMonsterID
			$ RemoveFromSquad(KF.StandardMonsterSquads[SquadID], SpecToReplace, AmountToReplace);
	else
		KF.StandardMonsterSquads[SquadID] = AmountToReplace $ NewMonsterID
			$ KF.StandardMonsterSquads[SquadID];
}

// copy-pasted from MutAddShvers (c) [WPC]
function string RemoveFromSquad(string SquadStr, string ID, int NumToRemove)
{
	local int x;
	local int OldNum;

	// Locate said specimen
	for (x = 0; x < Len(SquadStr); x += 2)
		if (Mid(SquadStr, x + 1, 1) == ID)
			break;

	if (x == Len(SquadStr))
		return SquadStr;

	OldNum = int(Mid(SquadStr, x, 1));

	// If we are removing all, remove completely
	if (OldNum - NumToRemove <= 0)
		return Left(SquadStr, x) $ Right(SquadStr, Len(SquadStr) - x - 2);

	return Left(SquadStr, x) $ (OldNum - NumToRemove) $ ID $ Right(SquadStr, Len(SquadStr) - x - 2);
}

/**
 * Looks for a monster class in games's current monster collection.
 *
 * @param MonsterClass		Monster class to look for, e.g. "ScrnWPCBrute.ZombieBruteSE"
 * @return Monster's index in MonsterClasses array or -1, if MonsterClass is not found
 *
 * @authror PooSH
 */
function int FindMonsterClass(String MonsterClass)
{
	local int i;

	for ( i=0; i< KF.MonsterCollection.default.MonsterClasses.Length; ++i ) {
		if ( KF.MonsterCollection.default.MonsterClasses[i].MClassName ~= MonsterClass )
            return i;
	}

    return -1;
}

/**
 * Assigns Monster ID (letter) to a given monster class. Monster ID can be used for building wave masks.
 * If monster class already exists in MonsterCollection, its ID will be returned.
 * If monster class not found in MonsterCollection, new record will be created, assigning the next
 * letter to monster ID.
 *
 * @param MonsterClass		Monster class, e.g. "ScrnWPCBrute.ZombieBruteSE"
 * @param MonsterID			[out] Monster ID (letter), which is used to identify this monster in wave masks
 * @return Monster's index in MonsterClasses array
 *
 * @authror PooSH
 */
function int AddMonsterClass(String MonsterClass, out string MonsterID)
{
	local int i;

	// look if monster class is already in the list
    i = FindMonsterClass(MonsterClass);
	if ( i == -1 ) {
		i = KF.MonsterCollection.default.MonsterClasses.Length;
		KF.MonsterCollection.default.MonsterClasses.insert(i, 1);
		KF.MonsterCollection.default.MonsterClasses[i].MClassName = MonsterClass;
		KF.MonsterCollection.default.MonsterClasses[i].MID = Chr(65 + i);
	}
    MonsterID = KF.MonsterCollection.default.MonsterClasses[i].MID;
	// StandardMonsterClasses array isn't used anywhere, but who knows what TWI will come up with?..
    // KF.MonsterCollection.default.StandardMonsterClasses[i] = KF.MonsterCollection.default.MonsterClasses[i];

    return i;
}


/**
 * Adds specimen to a special squad.
 *
 * @param SpecialSquad 		KF.ShortSpecialSquads[x], KF.NormalSpecialSquads[x] or KF.LongSpecialSquads[x],
 *                       	where x is a wave number starting with 0 (pass 9 for wave 10)
 * @param ZedClass     		Zed class to add, e.g. "ScrnMonstersMut.ZombieBruteSE"
 *							Zed class is case sensitive! It allows to use hack of adding multiple
 *							zed records, bypassing bAllowDuplicates restriction.
 * @param NumZeds      		Zed count to spawn in a squad
 * @param bFirstInSquad		Insert zed into the begining of the list (true) or add it to the end (false)
 * @param bAllowDuplicates	Allows multiple records of the same zed class and count in the same wave.
 *							If bAllowDuplicates=False (default value) and zed class is already in
 *							the list, it will not be added.
 *
 * @author PooSH
 **/
function AddToSpecialSquadMC(out KFMonstersCollection.SpecialSquad SpecialSquad, string ZedClass, int NumZeds,
	optional bool bFirstInSquad, optional bool bAllowDuplicates)
{
	local int i;

	if ( !bAllowDuplicates ) {
		for ( i=0; i<SpecialSquad.ZedClass.length; ++i ) {
			if ( SpecialSquad.NumZeds[i] == NumZeds && SpecialSquad.ZedClass[i] == ZedClass)
				return; // zed already in the list
		}
	}
	// if reached here, zed needs to be added, i.e. it is not in the list or bAllowDuplicates=true
	if ( bFirstInSquad )
		i = 0;
	else
		i = SpecialSquad.ZedClass.length;

    SpecialSquad.ZedClass.insert(i, 1);
    SpecialSquad.NumZeds.insert(i, 1);
    SpecialSquad.ZedClass[i] = ZedClass;
    SpecialSquad.NumZeds[i] = NumZeds;
}


// Adds zed class to short special squads
// see AddToSpecialSquadMC() for details
function AddToShortSpecialSquad(string ZedClass, int NumZeds, int WaveIndex, optional bool bFirstInSquad, optional bool bAllowDuplicates)
{
	if ( WaveIndex < 0 || WaveIndex > KF.MonsterCollection.default.ShortSpecialSquads.length ) {
		Warn("Unable to add "$ZedClass$" in short special squad: wave index ("$WaveIndex$") out of bounds");
		return;
	}
	AddToSpecialSquadMC(KF.MonsterCollection.default.ShortSpecialSquads[WaveIndex], ZedClass, NumZeds, bFirstInSquad, bAllowDuplicates);
}
function AddToNormalSpecialSquad(string ZedClass, int NumZeds, int WaveIndex, optional bool bFirstInSquad, optional bool bAllowDuplicates)
{
	if ( WaveIndex < 0 || WaveIndex > KF.MonsterCollection.default.NormalSpecialSquads.length ) {
		warn("Unable to add "$ZedClass$" in normal special squad: wave index ("$WaveIndex$") out of bounds");
		return;
	}
	AddToSpecialSquadMC(KF.MonsterCollection.default.NormalSpecialSquads[WaveIndex], ZedClass, NumZeds, bFirstInSquad, bAllowDuplicates);
}
function AddToLongSpecialSquad(string ZedClass, int NumZeds, int WaveIndex, optional bool bFirstInSquad, optional bool bAllowDuplicates)
{
	if ( WaveIndex < 0 || WaveIndex > KF.MonsterCollection.default.LongSpecialSquads.length ) {
		Warn("Unable to add "$ZedClass$" in long special squad: wave index ("$WaveIndex$") out of bounds");
		return;
	}
	AddToSpecialSquadMC(KF.MonsterCollection.default.LongSpecialSquads[WaveIndex], ZedClass, NumZeds, bFirstInSquad, bAllowDuplicates);
}
function AddToFinalSquad(string ZedClass, int NumZeds, int WaveIndex, optional bool bFirstInSquad, optional bool bAllowDuplicates)
{
	if ( WaveIndex < 0 || WaveIndex > KF.MonsterCollection.default.FinalSquads.length ) {
		Warn("Unable to add "$ZedClass$" in final squad: wave index ("$WaveIndex$") out of bounds");
		return;
	}
	AddToSpecialSquadMC(KF.MonsterCollection.default.FinalSquads[WaveIndex], ZedClass, NumZeds, bFirstInSquad, bAllowDuplicates);
}


/**
 * Removes specimen from a special squad.
 *
 * @param SpecialSquad 		KF.ShortSpecialSquads[x], KF.NormalSpecialSquads[x] or KF.LongSpecialSquads[x],
 *                       	where x is a wave number starting with 0 (pass 9 for wave 10)
 * @param ZedClass     		Zed class to add, e.g. "KFChar.ZombieScrake"
 *
 * @authror PooSH
 */
function RemoveFromSpecialSquadMC(out KFMonstersCollection.SpecialSquad SpecialSquad, string ZedClass)
{
	local int i;

	for ( i=0; i<SpecialSquad.ZedClass.length; ++i ) {
		if ( SpecialSquad.ZedClass[i] ~= ZedClass) {
			SpecialSquad.ZedClass.remove(i, 1);
			SpecialSquad.NumZeds.remove(i, 1);
			i--;
		}
	}
}

/**
 * Removes specimen from a special squad. But unlike RemoveFromSpecialSquadMC(), this function uses
 * MonsterID to identify monster class. That's why it works also with monster replacements like event
 * zeds and super zombies.
 *
 * @param SpecialSquad 		KF.ShortSpecialSquads[x], KF.NormalSpecialSquads[x] or KF.LongSpecialSquads[x],
 *                       	where x is a wave number starting with 0 (pass 9 for wave 10)
 * @param MonsterID			Monster ID (letter), which is assigned to a given monster class.
 *							e.g. E = KFChar.ZombieScrake
 * @authror PooSH
 */
function RemoveFromSpecialSquadByID(out KFMonstersCollection.SpecialSquad SpecialSquad, string MonsterID)
{
	local int i;

	for ( i=0; i< KF.MonsterCollection.default.MonsterClasses.Length; ++i ) {
		if ( KF.MonsterCollection.default.MonsterClasses[i].MID == MonsterID ) {
			RemoveFromSpecialSquadMC(SpecialSquad, KF.MonsterCollection.default.MonsterClasses[i].MClassName);
			return;
		}
	}
}
function RemoveFromShortSpecialSquad(string MonsterID, int WaveIndex)
{
	if ( WaveIndex < 0 || WaveIndex > KF.MonsterCollection.default.ShortSpecialSquads.length ) {
		return;
	}
	RemoveFromSpecialSquadByID(KF.MonsterCollection.default.ShortSpecialSquads[WaveIndex], MonsterID);
}
function RemoveFromNormalSpecialSquad(string MonsterID, int WaveIndex)
{
	if ( WaveIndex < 0 || WaveIndex > KF.MonsterCollection.default.NormalSpecialSquads.length ) {
		return;
	}
	RemoveFromSpecialSquadByID(KF.MonsterCollection.default.NormalSpecialSquads[WaveIndex], MonsterID);
}
function RemoveFromLongSpecialSquad(string MonsterID, int WaveIndex)
{
	if ( WaveIndex < 0 || WaveIndex > KF.MonsterCollection.default.LongSpecialSquads.length ) {
		return;
	}
	RemoveFromSpecialSquadByID(KF.MonsterCollection.default.LongSpecialSquads[WaveIndex], MonsterID);
}
function RemoveFromFinalSquad(string MonsterID, int WaveIndex)
{
	if ( WaveIndex < 0 || WaveIndex > KF.MonsterCollection.default.FinalSquads.length ) {
		return;
	}
	RemoveFromSpecialSquadByID(KF.MonsterCollection.default.FinalSquads[WaveIndex], MonsterID);
}

function ReplaceInAllSpecialSquads(string OldZedClass, string NewZedClass)
{
    local int i;
    local int j;

    for ( i=0; i<KF.MonsterCollection.default.ShortSpecialSquads.length; ++i ) {
        for ( j=0; j<KF.MonsterCollection.default.ShortSpecialSquads[i].ZedClass.length; ++j ) {
            if ( KF.MonsterCollection.default.ShortSpecialSquads[i].ZedClass[j] ~= OldZedClass)
                KF.MonsterCollection.default.ShortSpecialSquads[i].ZedClass[j] = NewZedClass;
        }
    }
    for ( i=0; i<KF.MonsterCollection.default.NormalSpecialSquads.length; ++i ) {
        for ( j=0; j<KF.MonsterCollection.default.NormalSpecialSquads[i].ZedClass.length; ++j ) {
            if ( KF.MonsterCollection.default.NormalSpecialSquads[i].ZedClass[j] ~= OldZedClass)
                KF.MonsterCollection.default.NormalSpecialSquads[i].ZedClass[j] = NewZedClass;
        }
    }
    for ( i=0; i<KF.MonsterCollection.default.LongSpecialSquads.length; ++i ) {
        for ( j=0; j<KF.MonsterCollection.default.LongSpecialSquads[i].ZedClass.length; ++j ) {
            if ( KF.MonsterCollection.default.LongSpecialSquads[i].ZedClass[j] ~= OldZedClass)
                KF.MonsterCollection.default.LongSpecialSquads[i].ZedClass[j] = NewZedClass;
        }
    }
    for ( i=0; i<KF.MonsterCollection.default.FinalSquads.length; ++i ) {
        for ( j=0; j<KF.MonsterCollection.default.FinalSquads[i].ZedClass.length; ++j ) {
            if ( KF.MonsterCollection.default.FinalSquads[i].ZedClass[j] ~= OldZedClass)
                KF.MonsterCollection.default.FinalSquads[i].ZedClass[j] = NewZedClass;
        }
    }

}

function ReplaceStandardZed(byte ZedIndex, String NewZedClass)
{
    ++StandardReplacements[ZedIndex];
    if ( StandardReplacements[ZedIndex] <= 1 || frand() < (1.0 / StandardReplacements[ZedIndex]) ) {
        ReplaceInAllSpecialSquads(KF.MonsterCollection.default.MonsterClasses[ZedIndex].MClassName, NewZedClass);
        KF.MonsterCollection.default.MonsterClasses[ZedIndex].MClassName = NewZedClass;
    }
}

static function string GetPackageName(string FullName)
{
	local int pos;

	pos = InStr(FullName, ".");
	if ( pos != -1 )
        return Left(FullName, pos);

	return FullName;
}

function bool IsZedEnabled(string ZedKind)
{
    local int i;

    for ( i=0; i<ZedDefs.length; ++i ) {
        if ( ZedDefs[i].Kind ~= ZedKind )
            return true;
    }
    return false;
}

function PostBeginPlay()
{
	//local int i, j;
    local ScrnVotingHandlerMut VH;
    local MonsterVoting VO;
    local int i;
    local string s;
    local bool bHasRepl;

	KF = KFGameType(Level.Game);
	if (KF == none) {
		Log("ERROR: Wrong GameType (requires KFGameType)", Class.Outer.Name);
		Destroy();
		return;
	}

    if ( bAllowVoting ) {
        VH = class'ScrnVotingHandlerMut'.static.GetVotingHandler(Level.Game);
        if ( VH == none ) {
            Level.Game.AddMutator(string(class'ScrnVotingHandlerMut'), false);
            VH = class'ScrnVotingHandlerMut'.static.GetVotingHandler(Level.Game);
        }
        if ( VH != none ) {
            VO = MonsterVoting(VH.AddVotingOptions(class'MonsterVoting'));
            if ( VO != none ) {
                VO.Mut = self;
            }
        }
        else
            log("Unable to spawn voting handler mutator", class.outer.name);
    }

    // 1061 fix
    KF.MonsterCollection = KF.SpecialEventMonsterCollections[KF.GetSpecialEventType()];
    KF.StandardMonsterClasses.Length = 0; //fill MonstersCollection instead
	// #23 squad (1 FP) is disabled in vanilla game
	// it will be used only by Female FP, if she is enabled
	DisableSquadSpawn(23);
	DisableSquadSpawn(27);

    if ( Level.NetMode != NM_Standalone ) {
        for ( i=0; i<ServerPackages.length; ++i )
            AddToPackageMap(ServerPackages[i]);
    }

    for ( i=0; i<ZedDefs.length; ++i ) {
        if ( ZedDefs[i].UserName == "" )
            ZedDefs[i].UserName = ZedDefs[i].Kind;
        ReplaceText(ZedDefs[i].UserName, " ", "_");

        if ( ZedDefs[i].bEnabled ) {
            s = GetPackageName(ZedDefs[i].ClassName);
            if ( ZedDefs[i].Package != s ) {
                if ( s == "" ) {
                    s = ZedDefs[i].Package;
                    ZedDefs[i].ClassName = s $ "." $ ZedDefs[i].ClassName;
                }
                else if ( ZedDefs[i].Package == "" )
                    ZedDefs[i].Package = s;
            }

            if ( Class<KFMonster>(DynamicLoadObject(ZedDefs[i].ClassName, Class'Class')) == none ) {
                ZedDefs[i].bEnabled = false;
                ZedDefs[i].bLocked = true;
                log("Unable to load monster class: " $ ZedDefs[i].ClassName, class.outer.name);
                continue;
            }


            // ServerPackages
            if ( Level.NetMode != NM_Standalone ) {
                if ( s != "" )
                    AddToPackageMap(s);
                if ( ZedDefs[i].Package != "" && ZedDefs[i].Package != s )
                    AddToPackageMap(ZedDefs[i].Package);
            }

            switch ( caps(ZedDefs[i].Kind) ) {
                case "CLOT":
                    ReplaceStandardZed(ZI_CLOT, ZedDefs[i].ClassName);
                    break;
                case "CRAWLER":
                    ReplaceStandardZed(ZI_CRAWLER, ZedDefs[i].ClassName);
                    break;
                case "GOREFAST":
                    ReplaceStandardZed(ZI_GOREFAST, ZedDefs[i].ClassName);
                    break;
                case "STALKER":
                    ReplaceStandardZed(ZI_STALKER, ZedDefs[i].ClassName);
                    break;
                case "SCRAKE":
                    ReplaceStandardZed(ZI_SCRAKE, ZedDefs[i].ClassName);
                    break;
                case "FLESHPOUND":
                    ReplaceStandardZed(ZI_FLESHPOUND, ZedDefs[i].ClassName);
                    break;
                case "BLOAT":
                    ReplaceStandardZed(ZI_BLOAT, ZedDefs[i].ClassName);
                    break;
                case "SIREN":
                    ReplaceStandardZed(ZI_SIREN, ZedDefs[i].ClassName);
                    break;
                case "HUSK":
                    ReplaceStandardZed(ZI_HUSK, ZedDefs[i].ClassName);
                    break;
                case "BOSS":
                    ++BossReplacements;
                    if ( BossReplacements <= 1 || frand() < (1.0 / BossReplacements) ) {
                        KF.MonsterCollection.default.EndGameBossClass = ZedDefs[i].ClassName;
                        KF.EndGameBossClass = ZedDefs[i].ClassName;
                    }
                    break;
                case "BRUTE":
                    AddBrutes(ZedDefs[i].ClassName);
                    break;
                case "JASON":
                    AddJasons(ZedDefs[i].ClassName);
                    break;
                case "SHIVER":
                    AddShivers(ZedDefs[i].ClassName);
                    break;
                case "FFP":
                    AddFemaleFP(ZedDefs[i].ClassName);
                    break;
                case "FFP2":
                    AddFemaleFP2(ZedDefs[i].ClassName);
                    break;
                case "TESLAHUSK":
                    AddTeslaHusks(ZedDefs[i].ClassName);
                    break;
                case "SHAFTER":
                    AddShafters(ZedDefs[i].ClassName);
                    break;
                case "SICK":
                    AddSicks(ZedDefs[i].ClassName);
                    break;
                case "GORESHANK":
                    AddGoreShanks(ZedDefs[i].ClassName);
                    break;
                case "FATALE":
                    AddFatales(ZedDefs[i].ClassName);
                    break;

                default:
                    AddCustomZed(ZedDefs[i].Kind, ZedDefs[i].ClassName);
            }
        }
    }

    if ( KFStoryGameInfo(KF) == none ) {
        for ( i=0; i<ZedRepl.length; ++i ) {
            ZedRepl[i].FromClass = Class<KFMonster>(DynamicLoadObject(ZedRepl[i].From, Class'Class'));
            if ( ZedRepl[i].FromClass == none ) {
                log("Unable to load monster class: " $ ZedRepl[i].From, class.outer.name);
                ZedRepl[i].ToClass = none; // just to be sure
                continue;
            }
            ZedRepl[i].ToClass = Class<KFMonster>(DynamicLoadObject(ZedRepl[i].To, Class'Class'));
            if ( ZedRepl[i].ToClass == none ) {
                log("Unable to load monster class: " $ ZedRepl[i].To, class.outer.name);
                continue;
            }
            bHasRepl = true;
            if ( Level.NetMode != NM_Standalone )
                AddToPackageMap(GetPackageName(ZedRepl[i].To));
        }
    }
    if ( bHasRepl )
        Enable('Tick');
    else
        Disable('Tick');
}

// for extended classes
function AddCustomZed(string UserName, string MonsterClass)
{
    log("Unknown zed kind: " $ UserName, class.outer.name);
}



function AddBrutes(string MonsterClass)
{
	local string MonsterID;

    AddMonsterClass(MonsterClass, MonsterID);
    // Add monster to squads

    // Squad: 3 Clots + 1 Crawler + 2 Stalker + 1 Bloat + 1 Siren
    // Waves: 4-10
    // Replace Crawler with Brute
    ReplaceMonsterInSquad(11, "B", 1, MonsterID);

    // Squad: 2 Clots + 2 Crawler + 2 Gorefast + 2 Sirens
    // Waves: 6-10
    // Replace Crawlers with Brute
    ReplaceMonsterInSquad(22, "B", 1, MonsterID);

    // Squad: 2 Clots + 1 Gorefast + 1 Husk
    // Waves: 5-8
    // Add a Brute
    ReplaceMonsterInSquad(25, "", 1, MonsterID);

    //wave 9 should have less Brutes comparing to 6-8 - let players to relax before the final rush

    // Final wave special squad - replace bloats with brutes
	RemoveFromShortSpecialSquad("G", 3);
	RemoveFromNormalSpecialSquad("G", 6);
	RemoveFromLongSpecialSquad("G", 9);
	AddToShortSpecialSquad(MonsterClass, 2, 3);
	AddToNormalSpecialSquad(MonsterClass, 2, 6);
	AddToLongSpecialSquad(MonsterClass, 2, 9);
}

function AddShivers(string MonsterClass)
{
	local string MonsterID;

    AddMonsterClass(MonsterClass, MonsterID);

    // Add monster to squads

    // Squad: 2 Crawlers
    // Waves: 2-3, 5-9
    // Replace Crawlers with Shivers
    ReplaceMonsterInSquad(2, "B", 2, MonsterID);

    // Squad: 3 Clots + 1 Bloat
    // Waves: 3-7, 10
    // Replace 1 clot with Shiver
    ReplaceMonsterInSquad(4, "A", 2, "A");
    ReplaceMonsterInSquad(4, "",  1, MonsterID);

    // Squad: 1 Clots + 3 Gorefasts
    // Waves: 3-7
    // Replace Gorefasts with Shivers - bring some heat in middle waves
    ReplaceMonsterInSquad(9, "C", 3, MonsterID);

    // Squad: 2 Husks + [1|2 Tesla Husks] + [Shafter] + [Goreshank] + [Fatale]
    // Waves: 9-10
    // Add Shivers only if Tesla Husks are not enalbed
    if ( !IsZedEnabled("TESLAHUSK") )
        ReplaceMonsterInSquad(26, "",  2, MonsterID);

	// special squad at wave 1
    AddToShortSpecialSquad(MonsterClass, 1, 0);
    AddToNormalSpecialSquad(MonsterClass, 1, 0);
    AddToLongSpecialSquad(MonsterClass, 1, 0);

    //wave 4 seems too boring - fill it with Shivers ;)
    AddToLongSpecialSquad(MonsterClass, 4, 3);
    // add Shivers to last boss squad
    AddToFinalSquad(MonsterClass, 4, 2);
}

function AddJasons(string MonsterClass)
{
	local string MonsterID;

    AddMonsterClass(MonsterClass, MonsterID);

    // Add monster to squads
    // Squad: 2 Clots + 1 Scrake
    // Waves: 6-10
    // Replace Scrake with Jason
    ReplaceMonsterInSquad(13, "E", 1, MonsterID);

	// Add Jason to special squad in a medium game, because 13-th squad isn't used in wave 7
	AddToNormalSpecialSquad(MonsterClass, 1, 6);
}

function AddFemaleFP(string MonsterClass)
{
	local string MonsterID;

    AddMonsterClass(MonsterClass, MonsterID);

	// squad #23: 1 FP - never used in the vanilla game
	ReplaceMonsterInSquad(23, "F", 1, MonsterID);
	// spawn in waves 3-4 from regular squad
	EnableShortSquadSpawn(23, 2, true);
	//EnableShortSquadSpawn(23, 3, true);
	// spawn in waves 4-10 from regular squad
	EnableNormalSquadSpawn(23, 3, true);
	EnableNormalSquadSpawn(23, 4, true);
	EnableNormalSquadSpawn(23, 5, true);
	//EnableNormalSquadSpawn(23, 6, true);
	// spawn in waves 7-10 from regular squad
	EnableLongSquadSpawn(23, 6, true);
	EnableLongSquadSpawn(23, 7, true);
	EnableLongSquadSpawn(23, 8, true);
	//EnableLongSquadSpawn(23, 9, true);

    // Squad #15: 2 Crawlers + 3 Stalkers + 1 Bloat + 2 Sirens
    // Short  Waves: 4
    // Normal Waves: 7
    // Long   Waves: 10
    // Replace Sirens with Female FPs
    // Add only 1 FFP if FFP_MKII is enabled
    if ( IsZedEnabled("FFP2") )
        ReplaceMonsterInSquad(15, "H",  1, MonsterID);
    else
        ReplaceMonsterInSquad(15, "H",  2, MonsterID);



	// Short game
	// there only 1 FP in short game squad, so give him a mate
	AddToShortSpecialSquad(MonsterClass, 1, 3);

	// Normal Game
	// wave 6 - spawn with FP
	AddToNormalSpecialSquad(MonsterClass, 1, 5);

	// Long game
	// Spawn in long wave 6 from special squads
	AddToLongSpecialSquad(MonsterClass, 1, 5);
	// wave 9 - spawn with FP instead of scrake
	RemoveFromLongSpecialSquad("E", 8);
	AddToLongSpecialSquad(MonsterClass, 1, 8);
}


function AddFemaleFP2(string MonsterClass)
{
	local string MonsterID;

    AddMonsterClass(MonsterClass, MonsterID);

    // Create new squad: #27
    EnableShortSquadSpawn(27, 3, true);
    EnableNormalSquadSpawn(27, 5, true);
    EnableNormalSquadSpawn(27, 6, true);
    EnableLongSquadSpawn(27, 7, true);
    EnableLongSquadSpawn(27, 8, true);
    EnableLongSquadSpawn(27, 9, true);

    // Squad #15: 2 Crawlers + 3 Stalkers + 1 Bloat + (2 Sirens or 1 FFP)
    // Short  Waves: 4
    // Normal Waves: 7
    // Long   Waves: 10
    // Replace 1 stalker with FFP2
    ReplaceMonsterInSquad(15, "D",  2, "D");
    ReplaceMonsterInSquad(15, "",  1, MonsterID);

    // Squad #27: 2 Crawlers + 3 Stalkers + 1 Bloat + 2 Sirens
    // Short  Waves: 4
    // Normal Waves: 6-7
    // Long   Waves: 8-10
    // Spawn a single FPF MKII
	ReplaceMonsterInSquad(27, "",  1, MonsterID);
}

function AddTeslaHusks(string MonsterClass)
{
	local string MonsterID;

    AddMonsterClass(MonsterClass, MonsterID);

    // Add monster to squads

    // Squad: 2 Stalkers
    // Waves: 2, 4-9
    // Add 1 Tesla Husk
    ReplaceMonsterInSquad(5, "", 1, MonsterID);

    // Squad: 4 Gorefasts
    // Waves: 3-10
    // Add 1 Tesla Husk
    ReplaceMonsterInSquad(19, "", 1, MonsterID);

    // Squad: [2 Husks | Fatale] [ + 2 Shivers | +2 Tesla Husks | + 1 Tesla Husk + Goreshank ] [ + Shafter]
    // Waves: 9-10
    // Add 2 Tesla Husks or 1 TH, if Goreshank is enabled
    if ( IsZedEnabled("GORESHANK") )
        ReplaceMonsterInSquad(26, "",  1, MonsterID);
    else
        ReplaceMonsterInSquad(26, "",  2, MonsterID);
}

function AddShafters(string MonsterClass)
{
    local string MonsterID;

    AddMonsterClass(MonsterClass, MonsterID);

    // Add monster to squads
    ReplaceMonsterInSquad(13, "", 1, MonsterID);
    ReplaceMonsterInSquad(25, "C", 1, MonsterID);
    ReplaceMonsterInSquad(26, "", 1, MonsterID);
}

function AddSicks(string MonsterClass)
{
    local string MonsterID;

    AddMonsterClass(MonsterClass, MonsterID);

    // Add monster to squads
    ReplaceMonsterInSquad(15, "G", 1, MonsterID);
    ReplaceMonsterInSquad(22, "H", 1, MonsterID);
    ReplaceMonsterInSquad(13, "", 1, MonsterID);

    AddToLongSpecialSquad(MonsterClass, 1, 7);
    AddToShortSpecialSquad(MonsterClass, 1, 3);
    AddToNormalSpecialSquad(MonsterClass, 1, 3);
}

function AddGoreShanks(string MonsterClass)
{
    local string MonsterID;

    AddMonsterClass(MonsterClass, MonsterID);

    // Add monster to squads
    ReplaceMonsterInSquad(26, "", 1, MonsterID);
    ReplaceMonsterInSquad(14, "C", 1, MonsterID);
    ReplaceMonsterInSquad(12, "", 1, MonsterID);

    AddToLongSpecialSquad(MonsterClass, 1, 6);
    AddToShortSpecialSquad(MonsterClass, 1, 3);
    AddToNormalSpecialSquad(MonsterClass, 1, 4);
}

function AddFatales(string MonsterClass)
{
    local string MonsterID;

    AddMonsterClass(MonsterClass, MonsterID);

    // Add monster to squads
    ReplaceMonsterInSquad(24, "", 1, MonsterID);
    ReplaceMonsterInSquad(25, "", 1, MonsterID);
    ReplaceMonsterInSquad(26, "I", 1, MonsterID);
}


function BuildSquad()
{
    // Throw in the special squad if the time is right
    if( KF.KFGameLength != KF.GL_Custom && !KF.bUsedSpecialSquad
            && KF.WaveNum < KF.MonsterCollection.default.SpecialSquads.Length
            && KF.MonsterCollection.default.SpecialSquads[KF.WaveNum].ZedClass.Length > 0
            && (KF.SpecialListCounter & 1) != 0 )
        KF.AddSpecialSquad();
    else
        KF.BuildNextSquad();

    ReplaceNextSpawn();

    KF.LastZVol = KF.FindSpawningVolume();
    if( KF.LastZVol!=None )
        KF.LastSpawningVolume = KF.LastZVol;

}

function ReplaceNextSpawn()
{
    local int i, j;
    local byte w;

    w = KF.WaveNum + 1;
    for ( i=0; i<KF.NextSpawnSquad.Length; ++i ) {
        for ( j=0; j<ZedRepl.Length; ++j ) {
            if ( ZedRepl[j].ToClass != none
                    && w >= ZedRepl[j].StartWave
                    && (ZedRepl[j].EndWave == 0 || w <= ZedRepl[j].EndWave)
                    && (ZedRepl[j].FromClass == KF.NextSpawnSquad[i] || (ZedRepl[j].bChildren
                        && ClassIsChildOf(KF.NextSpawnSquad[i], ZedRepl[j].FromClass)))
                    && frand() < ZedRepl[j].Chance )
            {
                KF.NextSpawnSquad[i] = ZedRepl[j].ToClass;
                break;
            }
        }
    }
}

function Tick(float DeltaTime)
{
    if ( KF.bGameEnded ) {
        Disable('Tick');
        return;
    }
    if ( KF.bWaveInProgress && KF.TotalMaxMonsters > 0 && KF.NextSpawnSquad.length == 0 )
        BuildSquad();
}


defaultproperties
{
     GroupName="KF-ScrnMonsters"
     FriendlyName="ZED Manager"
     Description="Allows adding custom zeds to the game."

     strVersion="v%m.%n"
     strStatus="Custom Monsters:"

     MonsterGroup="Monsters"

     bAllowVoting=True

     ZedDefs(0)=(Kind="BRUTE",Package="KFBruteFinal_014",ClassName="ScrnWPCBrute.ZombieBruteSE",bEnabled=True)
     ZedDefs(1)=(Kind="JASON",ClassName="ScrnWPCJason.ZombieJason",bEnabled=True)
     ZedDefs(2)=(Kind="SHIVER",Package="Shiver014",ClassName="ScrnWPCShiver.ZombieShiverSE",bEnabled=True)
     ZedDefs(3)=(Kind="FFP",ClassName="FemaleFPZED_v095.FemaleFP",bEnabled=True)
     ZedDefs(4)=(Kind="FFP2",ClassName="FemaleFPZED_v095.FemaleFP_MKII",bEnabled=True)
     ZedDefs(5)=(Kind="TESLAHUSK",ClassName="ScrnMonsters.TeslaHusk",bEnabled=True)
     ZedDefs(6)=(Kind="STALKER",UserName="Ghost",ClassName="ScrnMonsters.ZombieGhost")
     ZedDefs(7)=(Kind="BOSS",UserName="HardPat",ClassName="ScrnMonsters.HardPat",bEnabled=True)
     ZedDefs(8)=(Kind="SHAFTER",UserName="Shafter",ClassName="HMShafterMut.ZombieShafter",bEnabled=True)
     ZedDefs(9)=(Kind="SICK",UserName="Sick",ClassName="HMSickMut.ZombieSick",bEnabled=True)
     ZedDefs(10)=(Kind="GORESHANK",UserName="Goreshank",ClassName="GoreShank.ZombieGoreShank",bEnabled=True)
     ZedDefs(11)=(Kind="FATALE",UserName="Fatale",ClassName="HMFataleMut.ZombieFatale",bEnabled=True)

     //bAddToServerPackages=True
     //bAlwaysRelevant=True
     //RemoteRole=ROLE_SimulatedProxy
}
