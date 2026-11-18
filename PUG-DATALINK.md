# UT99:AS Pug Server Data Link

## Introduction

The following version history and documentation is provided for the use of utassault.net Server Setup.
Commands should be issued synchronously over UDP to the UT99 server in question.

## Version history

### Version 2.01

Provided by: RemoteServerSetup 1.13 - 2.01
Prerequesites: Requires `bNatCompliant=true`
 
#### Additionally Supported Commands

|Command|Description|Return|
|---|---|---|
|`KILLFORTS!`|Simulates "admin killall fortstandard"|`KILLFORTSOK!` if successful, or `NOTASSAULTGT!` if no fortstandards exist|
|`STARTIRCREP!`|Simulates a "start match" command to the reporter|`IRCREPSTARTED!` (assumes successful, no checks)|
|`ZEROTIME!`|Sets 'RemainingTime' to 0 (**ending map**!).|`TIMEZERO!`|
|`STOPCOUNTDOWN!`|Simulates "admin stopcountdown".|`COUNTDOWNSTOPPED!`|
|`GETACLS?`|Queries ACL list|IP ACL list (`ACLS::0,ACCEPT,127.0.0.1;1,DENY,192.168.0.1;!` etc...).|
|`ADDACL::string`|Add ACL (e.g. DENY,127.0.0.1)|`ACLADDED!`|
|`REMACL::string`|Removes all ACLs matching IP (e.g. 127.0.0.1)|`ACLREMOVED!`|

### Version 2.0

Provided by: RemoteServerSetup 1.00-1.12
Prerequesites: Requires `bNatCompliant=true`
 
#### Additionally Supported Commands

|Command|Description|Return|
|---|---|---|
|`CONSOLEGET::string`|Simulates "admin get"|`CONSOLEGET::answer!`|
|`CONSOLESET::string`|Simulates "admin set"|`CONSOLEGET::answer!` (confirming set)|
|`PLAYERCOUNT?`|Queries current playercount|`PLAYERCOUNT::integer!`|
|`CURRENTMAP?`|Queries current map name|`CURRENTMAP::answer!`|
|`GETGAMETYPE?`|Queries current gametype|`GAMETYPE::answer!` (child class only)|
|`GETGAMECLASS?`|Queries current gametype, full class|`GAMECLASS::answer.answer`|
|`GETMUTATORS?`|Queries current mutators (with ints)|`MUTATORS::answer,answer!`|
|`GETALLMUTATORS?`|Queries all available mutators (w/i)|`ALLMUTATORS::answer,answer!`|
|`SENDMUTATE::string`|Sends mutate string to game|`MUTATESENT!`|
|`CHECKMUTATOR::string`|Queries if mutator is present|`CHECKMUTATOR::TRUE!` or `CHECKMUTATOR::FALSE!`|
|`SETGAMETYPE::string`|Sets gametype (use before maplist)|`GAMETYPESET!` or `GAMETYPEFAILED!`|
|`SETUSETLOC::boolean`|Sets bUseTranslocator|`USETLOCSET!`|
|`SETGOALSCORE::integer`|Sets GoalTeamScore|`GOALSCORESET!`|
|`SETWEAPONSTAY::boolean`|Sets bWeaponStay|`WEAPONSTAYSET!`|
|`SETTIMELIMIT::integer`|Sets TimeLimit|`TIMELIMITSET!`|
|`SETFRAGLIMIT::integer`|Ses FragLimit|`FRAGLIMITSET!`|
 
 
#### Revised Commands

|Command|Description|Return|
|---|---|---|
|`SETMAPLIST::string`|-|Revised to include gametype as set by SETGAMETYPE also returns `MAPCHANGEINPROGRESS!` if mapchange not possible|
|`HELLO?`|FIXED! Datalink query test|`HELLO!`|
|`RELAY::string`|FIXED! Relays string data|`RELAYING::string`|


### Version 1.2

Provided by LeagueAS140

#### Additionally Supported Commands
 
|Command|Description|Return|
|---|---|---|
|`SETTIWENABLED::boolean`|Sets TIW usage (inverts bDisableTIW)|`TIWENABLEDSET!`|
|`SETREDSCORE::integer`|Sets Red Team's score|`REDSCORESET!`|
|`SETBLUESCORE::integer`|Sets Blue Team's score|`BLUESCORESET!`|
|`SETPART1::boolean`|Sets bDefenceSet (true/false)|`PART1SET!`|
|`SETTIEPARTONE::boolean`|Sets bTiePartOne (true/false)|`SETTIEPARTONE!`|
|`SETSAVEDTIME::integer`|Sets Attacker's attack time (s)|`SAVEDTIMESET!`|
|`SETCURRENTDEFENDER::byte`|Sets Current defending team (1/0)|`CURRENTDEFENDERSET!`|
|`RESETASSAULT!`|Ends map, resets saved times etc..|`RESETASSAULTDONE!`|
|`SETNEXTMAP::string`|Sets the map rotation pointer|`NextMapSet` or `NextMapNotFound`|
|`SERVERTRAVEL::string`|Initiates ServerTravel to map|-|
|`SETGAMESPEED::float`|Sets GameSpeed|`GAMESPEEDSET!`|
|`SETAIRCONTROL::float`|Sets AirControl|`AIRCONTROLSET!`|
 
#### Revised Commands

|Command|Description|Return|
|---|---|---|
|`SETAUTHMODE::boolean`|Sets Auth System (`true`/`false`)|`AUTHMODESET!`|
|`SETMAPLIST::string`|-|Revised to also returns `MAPCHANGEINPROGRESS!` if mapchange not possible|


### Version 1.1

Provided by: LeagueAS138
 
#### Additionally Supported Commands
 
|Command|Description|Return|
|---|---|---|
|`SETMATCHLENGTH::integer`|Sets LeagueAS match length|`MATCHLENGTHSET!`|
|`SETMAXTEAMSIZE::integer`|Sets MaxTeamSize|`MAXTEAMSIZESET!`|
|`SETFIRSTSTARTTIME::integer`|Sets LeagueAS FirstMapStartTime|`FIRSTSTARTTIMESET!`|
|`SETAUTHMODE::integer`|Sets LeagueAS Authorisation System|`AUTHMODESET!`|


### Version: 1.0

Provided by: LeagueAS1xx - LeagueAS137
Prerequisites: None
 
#### Auto returns:

|Command|Description|Return|
|---|---|---|
|`HELLO!`|If a valid datalink is established, the module will return `HELLO!` after a map change|`HELLO!`|
 
#### Supported Commands

|Command|Description|Return|
|---|---|---|
|`LOGIN::string`|Logs user into datalink|`LOGGEDIN!` if string matches LinkPassword|
|`LOGOUT!`|Logs user out of datalink|`LOGGEDOUT!`|
|`RESTARTMAP!`|Restarts current map|`MAPRESTARTING!`|
|`SETREDTEAMNAME::string`|Sets Red Team name|`REDTEAMNAMESET!`|
|`SETBLUETEAMNAME::string`|Sets Blue Team name|`BLUETEAMNAMESET!`|
|`SETGAMEPASSWORD::string `-- Sets game entry password|`GAMEPASSWORDSET!`|
|`SETREDPASSWORD::string `-- Sets Red Team password|`REDPASSWORDSET!`|
|`SETBLUEPASSWORD::string`|Sets Blue Team password|`BLUEPASSWORDSET!`|
|`SETMODERATORPASSWORD::string`|Sets moderator password|`MODERATORPASSWORDSET!`|
|`SETSPECTATORPASSWORD::string`|Sets spectator password|`SPECTATORPASSWORDSET!`|
|`SETTOURNAMENTMODE::boolean`|Sets tournament mode|`TOURNAMENTMODESET!`|
|`SETATTACKONLY::boolean`|Sets Attack Only mode|`ATTACKONLYSET!`|
|`SETPLAYERLIMIT::integer`|Sets overall player limit|`PLAYERLIMITSET!`|
|`SETSPECLIMIT::integer`|Sets spectator limit|`SPECLIMITSET!`|
|`SETMUTATORLIST::string`|Sets mutators, colon delimited|`MUTATORLISTSET!`|
|`SETMAPLIST::string`|Sets maplist, colon delimited|`MAPLISTSET!`|
|`STARTMATCH!`|Initiates LeagueAS StartMatch|`STARTINGMATCH!`|
|`ENDMATCH!`|Sends EndMatch signal to LeagueAS|`ENDINGMATCH!`|
|`SETFRIENDLYFIRE::integer`|Sets friendly fire scale (%)|`FRIENDLYFIRESET!`|
|`ISMATCHINPROGRESS?`|Queries matchmode=true/false|`MATCHINPROGRESS::YES` or `MATCHINPROGRESS::NO`|
|`SERVERISPASSWORDED?`|Queries if server is passworded|`SERVERISPASSWORDED::YES` or `SERVERISPASSWORDED::NO`|
|`SETMATCHMODE::boolean`|Sets LeagueAS Matchmode=true/false|reutrns `MATCHMODESET!`|
|`SETPRIVATENAME::string`|Sets server Private name|`PRIVATENAMESET!`|
|`SETPUBLICNAME::string`|Sets server Public name|`PUBLICNAMESET!`|
