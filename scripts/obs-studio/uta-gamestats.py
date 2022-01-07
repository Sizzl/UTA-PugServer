#requires Python 3.6.x - e.g. https://www.python.org/ftp/python/3.6.8/python-3.6.8-amd64.exe
import obspython as obs
import socket
import time

interval            = 30
unrealserver        = ""
source_team0score   = ""
source_team1score   = ""
source_team0name    = ""
source_team1name    = ""
source_serverstatus = ""
source_servermap    = ""
source_servertime   = ""
source_gametime     = ""
source_gameobjs     = ""
source_debug        = ""
cache_remainingtime = -1

udpsock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udpsock.settimeout(5)

# ------------------------------------------------------------
def unreal_query(udpsock, svdata, querytype):
    # Loosely based on utserverquery by Chris Wilkins
    # https://github.com/cwilkc/utserverquery
    try:
        udpsock.sendto(str.encode(f"\\{querytype}\\"),(svdata['ip'], svdata['query_port']))
        udpdata = []
        while True:
            udprcv, _ = udpsock.recvfrom(4096)
            try:
                udpdata.extend(udprcv.decode('utf-8').split('\\')[1:-2]) 
            except UnicodeDecodeError:
                return
            if udprcv.split(b'\\')[-2] == b'final':
                break

        parts = zip(udpdata[::2], udpdata[1::2])
        for part in parts:
            svdata[part[0]] = part[1]
        #svdata['rawdata'] = udpdata
        svdata['code'] = 200
    except socket.timeout:
        svdata['status'] = "Timeout connecting to server."
        svdata['code'] = 408

    return svdata

def update_tickers():
    # Run every second(ish) to update real-time controls
    global cache_remainingtime
    global source_gametime
    
    control_gametime = obs.obs_get_source_by_name(source_gametime)
    datastream = obs.obs_data_create()
    if cache_remainingtime > 0 and control_gametime not in ['',None]:
        cache_remainingtime -= 1
        obs.obs_data_set_string(datastream, "text", "{0}".format(str(time.strftime("%M:%S",time.gmtime(cache_remainingtime)))))
        obs.obs_source_update(control_gametime, datastream)
    else:
        obs.timer_remove(update_tickers)

    obs.obs_data_release(datastream)
    obs.obs_source_release(control_gametime)

        
def update_text():
    # Run per defined interval
    global udpsock
    global interval
    global unrealserver
    global cache_remainingtime
    global source_debug
    global source_servermap
    global source_gametime
    global source_team0name
    global source_team0score
    global source_team1name
    global source_team1score
    global source_serverstatus
    
    control_debug        = obs.obs_get_source_by_name(source_debug)
    control_servermap    = obs.obs_get_source_by_name(source_servermap)
    control_gametime     = obs.obs_get_source_by_name(source_gametime)
    control_team0name    = obs.obs_get_source_by_name(source_team0name)
    control_team0score   = obs.obs_get_source_by_name(source_team0score)
    control_team1name    = obs.obs_get_source_by_name(source_team1name)
    control_team1score   = obs.obs_get_source_by_name(source_team1score)
    control_serverstatus = obs.obs_get_source_by_name(source_serverstatus)
    control_gameobjs     = obs.obs_get_source_by_name(source_gameobjs)
    
    if unrealserver not in ['',"",None] and control_debug is not None:
        if ':' in unrealserver:
            ip = unrealserver.split(':', 2)[0]
            qport = int(unrealserver.split(':', 2)[1])+1
        else:
            ip = unrealserver
            qport = 7778

        svcore = {'ip':ip,'game_port':(qport-1),'query_port':qport}
        svdata = unreal_query(udpsock, svcore, "info")

        if 'code' in svdata and svdata['code'] == 200:
            # Fetch more data
            svdata = unreal_query(udpsock, svcore, "status\\\\level_property\\timedilation\\\\game_property\\teamscore\\\\game_property\\teamnamered\\\\game_property\\teamnameblue\\\\player_property\\Health\\\\game_property\\elapsedtime\\\\game_property\\remainingtime\\\\game_property\\bmatchmode\\\\game_property\\friendlyfirescale\\\\game_property\\currentdefender\\\\game_property\\bdefenseset\\\\game_property\\matchcode\\\\rules")
            if 'gametype' in svdata and svdata['gametype'] == "Assault":
                svdata = unreal_query(udpsock, svdata, "teams")
                svdata = unreal_query(udpsock, svdata, "objectives")
        
        

        if control_debug not in ['',None]:
            datastream = obs.obs_data_create()
            obs.obs_data_set_string(datastream, "text", "Raw data: {0}".format(str(svdata).replace(', ',', \n')))
            obs.obs_source_update(control_debug, datastream)
            obs.obs_data_release(datastream)
            obs.obs_source_release(control_debug)

        if control_servermap not in ['',None] and 'maptitle' in svdata and len(svdata['maptitle']) > 1:
            datastream = obs.obs_data_create()
            obs.obs_data_set_string(datastream, "text", "{0}".format(str(svdata['maptitle'])))
            obs.obs_source_update(control_servermap, datastream)
            obs.obs_data_release(datastream)
            obs.obs_source_release(control_servermap)
        elif control_servermap not in ['',None] and 'mapname' in svdata:
            datastream = obs.obs_data_create()
            obs.obs_data_set_string(datastream, "text", "{0}".format(str(svdata['mapname'])))
            obs.obs_source_update(control_servermap, datastream)
            obs.obs_data_release(datastream)
            obs.obs_source_release(control_servermap)
            
        if control_gametime not in ['',None] and 'remainingtime' in svdata:
            datastream = obs.obs_data_create()
            obs.obs_data_set_string(datastream, "text", "{0}".format(str(time.strftime("%M:%S",time.gmtime(int(svdata['remainingtime']))))))
            obs.obs_source_update(control_gametime, datastream)
            obs.obs_data_release(datastream)
            obs.obs_source_release(control_gametime)
            if 'timedilation' in svdata:
                cache_remainingtime = int(svdata['remainingtime'])
                obs.timer_remove(update_tickers)
                #obs.timer_add(update_tickers, int(1/(float(svdata['timedilation'])) * 1000)) # use unreal dilated time to update regularly
                obs.timer_add(update_tickers, int(0.99 * 1000)) # use unreal dilated time to update regularly
            else:
                cache_remainingtime = 0
                obs.timer_remove(update_tickers)
            if 'elapsedtime' in svdata and int(svdata['elapsedtime']) == 0:
                obs.timer_remove(update_tickers)
                
        if control_team0name not in ['',None] and 'teamnamered' in svdata:
            datastream = obs.obs_data_create()
            obs.obs_data_set_string(datastream, "text", "{0}".format(str(svdata['teamnamered'])))
            obs.obs_source_update(control_team0name, datastream)
            obs.obs_data_release(datastream)
            obs.obs_source_release(control_team0name)

        if control_team1name not in ['',None] and 'teamnamered' in svdata:
            datastream = obs.obs_data_create()
            obs.obs_data_set_string(datastream, "text", "{0}".format(str(svdata['teamnameblue'])))
            obs.obs_source_update(control_team1name, datastream)
            obs.obs_data_release(datastream)
            obs.obs_source_release(control_team1name)


        if control_team0score not in ['',None]:
            datastream = obs.obs_data_create()
            obs.obs_data_set_string(datastream, "text", "")
            if 'score_0' in svdata:
                obs.obs_data_set_string(datastream, "text", str(svdata['score_0']))
            elif 'teamscore' in svdata:
                obs.obs_data_set_string(datastream, "text", str(svdata['teamscore']))
            obs.obs_source_update(control_team0score, datastream)
            obs.obs_data_release(datastream)
            obs.obs_source_release(control_team0score)

        if control_team1score not in ['',None] and 'score_1' in svdata:
            datastream = obs.obs_data_create()
            obs.obs_data_set_string(datastream, "text", str(svdata['score_1']))
            obs.obs_source_update(control_team1score, datastream)
            obs.obs_data_release(datastream)
            obs.obs_source_release(control_team1score)
            
            
        if control_serverstatus not in ['',None]:
            datastream = obs.obs_data_create()
            if 'bdefenseset' in svdata and 'currentdefender' in svdata:
                if svdata['bdefenseset'] in ['true','True','1']:
                    roundstatus = "2/2"
                else:
                    roundstatus = "1/2"
                if svdata['currentdefender'] == '1':
                    if 'teamnamered' in svdata:
                        roundstatus = "Round {0}; {1} attacking".format(roundstatus,svdata['teamnamered'])
                    else:
                        roundstatus = "Round {0}; {1} attacking".format(roundstatus,"Red Team")
                else:
                    if 'teamnameblue' in svdata:
                        roundstatus = "Round {0}; {1} attacking".format(roundstatus,svdata['teamnameblue'])
                    else:
                        roundstatus = "Round {0}; {1} attacking".format(roundstatus,"Blue Team")
                        
                obs.obs_data_set_string(datastream, "text", "{0}".format(roundstatus))
            else:
                obs.obs_data_set_string(datastream, "text", "{0}".format(str(svdata['AdminName'])))
                
            obs.obs_source_update(control_serverstatus, datastream)
            obs.obs_data_release(datastream)
            obs.obs_source_release(control_serverstatus)

        if control_gameobjs not in ['',None] and 'fortcount' in svdata:
            objstatus = "Objectives:";
            for i in range(int(svdata['fortcount'])):
                objstatus = "{0}\n \t {1} - {2}".format(objstatus,str(svdata["fort_{0}".format(i)]),str(svdata["fortstatus_{0}".format(i)]))
            datastream = obs.obs_data_create()
            obs.obs_data_set_string(datastream, "text", "{0}".format(objstatus))
            obs.obs_source_update(control_gameobjs, datastream)
            obs.obs_data_release(datastream)
            obs.obs_source_release(control_gameobjs)

def refresh_pressed(props, prop):
    update_text()

# ------------------------------------------------------------

def script_description():
    return "<b>UT Assault Server Monitor</b><br />Grabs current game statistics via GameSpy unreal:// protocol.<br /><br/>When defining a port in the Server Address, use the regular game port, not the query port (i.e. 7777 not 7778).<br /><br />Contact: Sizzl @ UTA Discord - <a href='https://discord.gg/unbFxh2t66'>discord.gg/unbFxh2t66</a><hr />"

def script_update(settings):
    global interval
    global unrealserver
    global source_team0score
    global source_team1score
    global source_team0name
    global source_team1name
    global source_serverstatus
    global source_servermap
    global source_gametime
    global source_gameobjs
    global source_debug
    
    unrealserver         = obs.obs_data_get_string(settings, "unrealserver")
    interval             = obs.obs_data_get_int(settings, "interval")
    source_team0score    = obs.obs_data_get_string(settings, "team0score")
    source_team1score    = obs.obs_data_get_string(settings, "team1score")
    source_team0name     = obs.obs_data_get_string(settings, "team0name")
    source_team1name     = obs.obs_data_get_string(settings, "team1name")
    source_serverstatus  = obs.obs_data_get_string(settings, "serverstatus")
    source_servermap     = obs.obs_data_get_string(settings, "servermap")
    source_gametime      = obs.obs_data_get_string(settings, "gametime")
    source_gameobjs      = obs.obs_data_get_string(settings, "gameobjs")
    source_debug         = obs.obs_data_get_string(settings, "debug")
    
    obs.timer_remove(update_text)
    obs.timer_remove(update_tickers)

    if unrealserver != "" and (
        source_serverstatus != "" or source_team0score != "" or
        source_team1score != "" or source_team1name != "" or
        source_team1score != "" or source_serverstatus != "" or
        source_servermap != "" or source_gameobjs != "" or source_debug != ""):
        
        obs.timer_add(update_text, interval * 1000)
        
    if unrealserver != "" and source_gametime != "":
        obs.timer_add(update_tickers, 1000)

def script_defaults(settings):
    obs.obs_data_set_default_int(settings, "interval", 15)

def script_unload():
    obs.timer_remove(update_text)
    obs.timer_remove(update_tickers)

def script_properties():
    props = obs.obs_properties_create()

    obs.obs_properties_add_text(props, "unrealserver", "Server Address - unreal://", obs.OBS_TEXT_DEFAULT)
    obs.obs_properties_add_int(props, "interval", "Update Interval (seconds)", 5, 3600, 1)
    
    ut_t0n = obs.obs_properties_add_list(props, "team0name", "Red Team Name", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    ut_t0s = obs.obs_properties_add_list(props, "team0score", "Red Team Score", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    ut_t1n = obs.obs_properties_add_list(props, "team1name", "Blue Team Name", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    ut_t1s = obs.obs_properties_add_list(props, "team1score", "Blue Team Score", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    ut_sts = obs.obs_properties_add_list(props, "serverstatus", "Server Status", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    ut_map = obs.obs_properties_add_list(props, "servermap", "Current Map", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    ut_tim = obs.obs_properties_add_list(props, "gametime", "Remaining Time", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    ut_obj = obs.obs_properties_add_list(props, "gameobjs", "Objective Stats", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    ut_dbg = obs.obs_properties_add_list(props, "debug", "Debug", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    
    sources = obs.obs_enum_sources()
    if sources is not None:
        for source in sources:
            source_id = obs.obs_source_get_unversioned_id(source)
            if source_id == "text_gdiplus" or source_id == "text_ft2_source":
                name = obs.obs_source_get_name(source)
                obs.obs_property_list_add_string(ut_t0n, name, name)
                obs.obs_property_list_add_string(ut_t0s, name, name)
                obs.obs_property_list_add_string(ut_t1n, name, name)
                obs.obs_property_list_add_string(ut_t1s, name, name)
                obs.obs_property_list_add_string(ut_sts, name, name)
                obs.obs_property_list_add_string(ut_map, name, name)
                obs.obs_property_list_add_string(ut_tim, name, name)
                obs.obs_property_list_add_string(ut_obj, name, name)
                obs.obs_property_list_add_string(ut_dbg, name, name)

        obs.source_list_release(sources)

    obs.obs_properties_add_button(props, "button", "&Save && Run", refresh_pressed)
    return props
