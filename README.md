# X2CommunityHighlander

Welcome to the X2CommunityHighlander Github project. This is where the work happens.
This file will be very bare-bones as of now, but should be filled up quickly.

# TODO

* Index LWS' changes
* Get work done on the Highlander

# Changes

# Features

# Fixes

# Contributing

The base repository has two branches: `master` and `LW1.1` (for now).
Changes to the Community Highlander should be developed on a new branch (which can be a fork) and will be merged into `master`.
Updates to the LWS Highlander will get added to the `LW1.1` branch (which should be renamed), and then merged into `master`.
This should help to ensure that the Highlander stays generally compatible with LW2 and can be used as a replacement Highlander.

## When contributing, please

* use the code style that is generally used in the XCOM 2 codebase:
  * use tabs
  * use new lines for braces
  * use appropriate spacing
  * use braces even for one-line if/else bodies
  
The following code should illustrate all of this:

    static function CompleteStrategyFromTacticalTransfer()
    {
    	local XComOnlineEventMgr EventManager;
    	local array<X2DownloadableContentInfo> DLCInfos;
    	local int i;

    	UpdateSkyranger();
    	CleanupProxyVips();
    	ProcessMissionResults();
    	SquadTacticalToStrategyTransfer();

    	EventManager = `ONLINEEVENTMGR;
    	DLCInfos = EventManager.GetDLCInfos(false);
    	for (i = 0; i < DLCInfos.Length; ++i)
    	{
    		DLCInfos[i].OnPostMission();
    	}
    }

* sign your changes:
  * if you change single methods, add an event trigger or similar, comment the relevant lines and the function
    * if the file is large, add a short version to the top of the file
  * if you generally change a file for one purpose (i.e. "guard controller only controls with ``if (`ISCONTROLLERACTIVE)`` to prevent log spam"), it is sufficient to commment this at the top of the file
  * add the changes into this file in the appropriate section
  * please add your handle to the change so we know who to blame