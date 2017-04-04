class MonsterVoting extends ScrnVotingOptions;

var ZedManagerMut Mut; 

var localized string strAdminRequired;  
    

function int GetGroupVoteIndex(PlayerController Sender, string Group, string Key, out string Value, out string VoteInfo)
{
    local int i;
    local int BoolValue;
    
    for ( i=0; i<Mut.ZedDefs.length; ++i ) {
        if ( Mut.ZedDefs[i].UserName ~= Key ) {
            if ( Value ~= "LOCK" || Value ~= "UNLOCK" ) {
                if ( !Sender.PlayerReplicationInfo.bAdmin ) {
                    Sender.ClientMessage(strAdminRequired);
                    return VOTE_LOCAL;
                }
            }
            else {
                if ( Mut.ZedDefs[i].bLocked && !Sender.PlayerReplicationInfo.bAdmin ) {
                    Sender.ClientMessage(strOptionDisabled);
                    return VOTE_LOCAL;
                }  
                BoolValue = TryStrToBool(Value);   
                if ( BoolValue == -1 )
                    return VOTE_ILLEGAL;
                if ( Mut.ZedDefs[i].bEnabled == bool(BoolValue) )
                    return VOTE_NOEFECT;
            }
            return i;            
        }
    }
    
    return VOTE_UNKNOWN;
}

function ApplyVoteValue(int VoteIndex, string VoteValue)
{
    local int BoolValue;
    
    if ( VoteValue ~= "LOCK" )
        Mut.ZedDefs[VoteIndex].bLocked = True;
    else if ( VoteValue ~= "UNLOCK" )
        Mut.ZedDefs[VoteIndex].bLocked = False;
    else {
        BoolValue = TryStrToBool(VoteValue);
        if ( BoolValue == -1 )
            return;
        Mut.ZedDefs[VoteIndex].bEnabled = bool(BoolValue);
        VotingHandler.BroadcastMessage(strRestartRequired);
    }
    Mut.SaveConfig();
}

function SendGroupHelp(PlayerController Sender, string Group)
{
    local string s, sl;
    local int i;
    local int ln;
    
    if ( !Sender.PlayerReplicationInfo.bAdmin )
        sl = "%b";
    
    ln = 1;
    
    for ( i=0; i<Mut.ZedDefs.length; ++i ) {
        if ( !Mut.ZedDefs[i].bLocked ) {
            if ( Mut.ZedDefs[i].bEnabled )  
                s @= "%g";
            else
                s @= "%r";
            s $= Mut.ZedDefs[i].UserName;    
            if ( len(s) > 60 ) {
                // move to new line
                GroupInfo[ln++] = VotingHandler.ParseHelpLine(default.GroupInfo[1] @ s);
                s = "";
            }
        }
        else if ( Sender.PlayerReplicationInfo.bAdmin ) {
            if ( Mut.ZedDefs[i].bEnabled )  
                sl @= "%g";
            else
                sl @= "%r";
            sl $= Mut.ZedDefs[i].UserName;
        }
        else if ( Mut.ZedDefs[i].bEnabled ) {
            sl @= Mut.ZedDefs[i].UserName;
        }            
    }
    GroupInfo[ln] = VotingHandler.ParseHelpLine(default.GroupInfo[1] @ s);
    GroupInfo[ln+1] = VotingHandler.ParseHelpLine(default.GroupInfo[2] @ sl);
    
    super.SendGroupHelp(Sender, Group);
}

defaultproperties
{
    DefaultGroup="ZED"

    HelpInfo(0)="%pZED %y<zed_name> %gON%w|%rOFF %w Add|Remove custom zeds from the game. Type %bMVOTE ZED HELP %w for more info."

    GroupInfo(0)="%pZED %y<zed_name> %gON%w|%rOFF %w Add or remove custom zeds from the game."
    GroupInfo(1)="%wAvaliable zeds:"
    GroupInfo(2)="%wLocked zeds:"
    
    strAdminRequired="Admin rights required"
}     
