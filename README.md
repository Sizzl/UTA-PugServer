# UTA-PugServer
Pick-up game server configuration for utassault.net

[![Dependency Check](https://github.com/Sizzl/UTA-PugServer/actions/workflows/validate.yml/badge.svg)](https://github.com/Sizzl/UTA-PugServer/actions/workflows/validate.yml)

## Server configuration
It is recommended to make changes to your server ini file are required prior to first-start of the server with this gametype.

An example MapVoteLA config is included (MapVoteLA.example.ini); copy this to MapVoteLA.ini and modify as needed.

Finally, modify the following ini sections:

```
[Engine.GameEngine]
; ** Keep existing entries, but also add these packages: **
ServerPackages=LeagueAS-CP
ServerPackages=AssaultBonusPack
ServerPackages=Autorip
ServerPackages=EavyAssaultPlus
ServerPackages=UTA-AuthCP12
ServerPackages=ZeroPingPlus103
ServerPackages=LeagueAS140++
ServerPackages=MapVoteLA13
; ** Replace any IpServer.UdpServer or XServerQuery lines with these, if you use extra master servers, copy and paste them here **
ServerActors=LeagueAS-SP.ServerQuery
ServerActors=LeagueAS-SP.ServerUplink MasterServerAddress=unreal.epicgames.com MasterServerPort=27900
ServerActors=LeagueAS-SP.ServerUplink MasterServerAddress=master0.gamespy.com MasterServerPort=27900
; ** Keep remaining actors, but also add these: **
ServerActors=MonsterAnnouncerLA.MA_ServerActor
ServerActors=PugStats.PugLink
ServerActors=PugStats.SmartPUG_SA
ServerActors=UTStatsBeta4_2a.UTStatsSA
ServerActors=BallFiXstic.FixTele
ServerActors=ColderSteelFix.ColderSteelFix
ServerActors=UTA-AuthSP12.Auth_Module
ServerActors=LeagueAS140++.ModernUTSupport
; ** Optionally also (if deemed necessary when running older than 469 server, or CPU constraints require): **
ServerActors=ServerCrashFix_v11.SCFActor

; ** Server setup tool, be sure to change the LinkPassword and ListenPort values **
[PugStats.PugLink]
bDoDataLink=True
LinkPassword=SOMESECUREPASSWORDHERE
LoggedInIP=0
LoggedInPort=0
bNATCompliant=True
ListenPort=6560
bLogChangesOnly=false
bLogChanges=true
bAddMutators=False
MutatorList=None.None
bFixGametype=false
bForceME=False
SetupReference=
bServerDemo=False
LastDemoName=

; ** Legacy setup tool, module is still required for backwards compatibility, but can be disabled **
[LeagueAS-SP.ServerSetupDataLink]
bDoDataLink=False
bNATCompliant=True

; ** Map fixes and weapon tweaks **
[LeagueAS-SP.ServerSideModule]
bSiegeFix=True
MiniPrimAdjust=1.070000
MiniSecAdjust=1.080000
bDebug=False

; ** Main gametype, hack protection is largely disabled to support modern UT and should ideally be substituted for ACE **
; ** Only main difference from defaults is removing suicide penalties and adding modern UT support through Entry **
[LeagueAS140.LeagueAssault]
bngStatsCompatibility=True
bEnableCSHP=False
bAttackOnly=False
bMatchMode=False
bPracticeMode=False
bStandardise=True
bAuthorisePlayers=False
bAdminNameScore=True
bServerNameScore=True
bServerNameGameType=True
bCheckServername=True
bAutoPausing=True
bNoSuicidePenalties=True
FirstMapStartTime=180
SubsequentMapStartTime=55
TeamNameRed=RED
TeamNameBlue=BLUE
MapsWon[0]=
MapsWon[1]=
PrivateString=LOCKED - PRIVATE
PublicString=OPEN - PUBLIC
bImprovedTeamBalance=True
TeamBalanceDelayTime=60
bPreventMapChangeKick=True
PreventMapChangeKickTime=40
AuthModuleClass=LeagueAS140.LeagueAS_AuthAbstract
EntryActorClassString=LeagueAS140++.ModernLASER
lastobjcompletiontime=0
bcrashrecovery=False
bDisableTIW=False
SavedTime=0.000000
NumDefenses=0
CurrentDefender=0
bDefenseSet=False
bTiePartOne=False
GameCode=
Part=1
bNoTeamChanges=False
FriendlyFireScale=0.000000
MaxTeams=2
GoalTeamScore=0.000000
MaxTeamSize=1
FragLimit=0
TimeLimit=9
bMultiWeaponStay=True
bForceRespawn=True
bUseTranslocator=False
MaxCommanders=0
bNoMonsters=False
bHumansOnly=False
bCoopWeaponMode=True
bClassicDeathMessages=False
MinFOV=80.000000
MaxFOV=130.000000
MaxNameChanges=0
MaxPauseTime=300
PauseTimeRemaining[0]=300
PauseTimeRemaining[1]=300
MaxPauseCount=10
PauseCountRemaining[0]=10
PauseCountRemaining[1]=10
MaxPausePerMapCount=3
PauseLeadInOutTime=5

; ** Legacy hack protection, just disable it these days - there are better options **
[LeagueAS140.HackProtection]
ScanForRogues=0
Advertise=0
bEnableCRCCheck=False
bAllowCRC0=True

; ** Legacy IRC reporters **
[LeagueASCheatReporter.UTReporterCfg]
Enabled=False

[LeagueAS-Reporter.UTReporterConfig]
EnableIRCCom=False
Enabled=False

; ** Stats **
[UTStatsBeta4_2a.UTStats]
bEnabled=True

[SmartAS_101.SmartAS_Mutator]
bEnabled=True
bDebug=False
MapSequence=
gRedTeam=RED
gBlueTeam=BLUE
MatchCode=
AssistArea=1000
AssistTimeOut=5
bShowAssistMessage=False
bPlayAssistSound=False
DebugName=
bDamageMutEnabled=True
MaxID=42
bDisableDamageMutator=False
SoundMessageHelperClass=SmartAS-Message.SmartASMessage
bShowEvenTeamsMessage=True

; Uses a dummy LeagueAS136 server-side module for specific pug bot compatibility
[LeagueAS136.LeagueAssault]
SwitchTo=LeagueAS140.LeagueAssault

; Auth system
[UTA-AuthSP12.Auth_Module]
bEnabled=True
bIgnoreClan=True
bAuthInMatchmodeOnly=True
```

## Additional copyrights
The electronic distribution of these files is in line with copyright and licensing of each individual project / map.

See individual map copyrights within entries in the [ut-server/Help/](ut-server/Help/) directory.
