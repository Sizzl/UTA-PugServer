# OBS Studio Game Query Script

This is a "little" OBS Studio script that regularly queries an active UT server utilising the GameSpy unreal protocol via UDP.

Predominantly designed around streaming of League Assault matches, as much of the ServerQuery system has been designed to work with this; though I suppose this could be expanded to other gametypes if needed.

## Dependencies

Per OBS Studio dependencies; this can only operate within Python 3.6 currently.

## Usage

Within your Scene, add Text sources for any or all of the following items:

- Red Team Name
- Red Team Score
- Blue Team Name
- Blue Team Score
- Current Map
- Time Left
- Server Status / Round Info (including which team is attacking)
- Objectives
- Debug (this can be hidden if you want to have it)

After installing Python and selecting the path to Python within the Tools > Scripts > Python Settings tab, simply drop the script into the appropriate folder (e.g. \obs-studio\data\obs-plugins\frontend-tools\scripts) and +add it to the active script list.

Once added, enter a valid server IP (or DNS) and game port, choose a refresh time (recommended no less than 10s) then select any or all of the text sources against the appropriate line item, then hit Save + Run to start the timer.

Script settings will persist across OBS sessions, and the timer will auto-start when OBS starts (i.e. X seconds after OBS starts, it will fetch the server info).

The only source that will update in case of failure or timeout is the debug source, so if your sources aren't updating, check this one out to see why.