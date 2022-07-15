#include <sdktools>
#include <sdktools_sound>
#include <sourcemod>
#include <tf2_stocks>
#pragma semicolon 1
#define VERSION "1.2"


new Handle:CvarJoinSoundName;
new Handle:CvarJoinSoundCheck;
new Handle:CvarEndMapSoundName;
new Handle:CvarEndMapSoundCheck;
new Handle:CvarStartRoundSoundName;
new Handle:CvarStartRoundSoundCheck;
new Handle:CvarEndRoundSoundName;
new Handle:CvarEndRoundSoundCheck;
new Handle:CvarTFWinRoundSoundCheck;
new Handle:CvarTFWinRoundSoundName;
new Handle:CvarTFLoseRoundSoundCheck;
new Handle:CvarTFLoseRoundSoundName;

new String:g_JoinSoundName[128];
new String:g_EndMapSoundName[128];
new String:g_StartRoundSoundName[128];
new String:g_EndRoundSoundName[128];
new String:g_WinRoundSoundName[128];
new String:g_LoseRoundSoundName[128];
new bool:g_LastRound = false;

public Plugin:myinfo = 
{
	name = "ServerSounds",
	author = "Xilver266 Steam: donchopo",
	description = "Emit sounds in multiple events",
	version = VERSION,
	url = "servers-cfg.foroactivo.com"
};


public OnPluginStart()
{
	AutoExecConfig(true, "serversounds");
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	HookEvent("teamplay_round_win", TFRoundEnd);
	
	CreateConVar("sm_serversounds_version", VERSION, "ServerSounds", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	CvarJoinSoundCheck = CreateConVar("sm_ssjoinsound", "1", "Play sound to connecting players. 0 -No | 1 -Yes", _, true, 0.0, true, 1.0);
	CvarJoinSoundName = CreateConVar("sm_ssjoinsoundpath", "serversounds/joinserver.mp3", "Sound played to connecting players");
	CvarEndMapSoundCheck = CreateConVar("sm_ssendmapsound", "1", "Play sound on map end. 0 -No | 1 -Yes", _, true, 0.0, true, 1.0);
	CvarEndMapSoundName = CreateConVar("sm_ssendmapsoundpath", "serversounds/mapend.mp3", "Sound played on map end");
	CvarStartRoundSoundCheck = CreateConVar("sm_sssrsound", "1", "Play sound on round start. 0 -No | 1 -Yes", _, true, 0.0, true, 1.0);
	CvarStartRoundSoundName = CreateConVar("sm_sssrsoundpath", "serversounds/roundstart.mp3", "Sound played on round start");
	CvarEndRoundSoundCheck = CreateConVar("sm_ssersound", "1", "Play sound on round end. 0 -No | 1 -Yes", _, true, 0.0, true, 1.0);
	CvarEndRoundSoundName = CreateConVar("sm_ssersoundpath", "serversounds/roundend.mp3", "Sound played on round end");
	CvarTFWinRoundSoundCheck = CreateConVar("sm_sswrsound", "1", "Play sound on round win. 0 -No | 1 -Yes", _, true, 0.0, true, 1.0);
	CvarTFWinRoundSoundName = CreateConVar("sm_sswrsoundpath", "serversounds/roundwin.mp3", "Sound played on round win");
	CvarTFLoseRoundSoundCheck = CreateConVar("sm_sslrsound", "1", "Play sound on round lose. 0 -No | 1 -Yes", _, true, 0.0, true, 1.0);
	CvarTFLoseRoundSoundName = CreateConVar("sm_sslrsoundpath", "serversounds/roundlose.mp3", "Sound played on round lose");
}

public OnConfigsExecuted()
{
	if (GetConVarBool(CvarJoinSoundCheck))
	{
		GetConVarString(CvarJoinSoundName, g_JoinSoundName, sizeof(g_JoinSoundName));
		decl String:JoinPath[128];
		PrecacheSound(g_JoinSoundName, true);
		Format(JoinPath, sizeof(JoinPath), "sound/%s", g_JoinSoundName);
		AddFileToDownloadsTable(JoinPath);	
	}
	
	if (GetConVarBool(CvarEndMapSoundCheck))
	{
		GetConVarString(CvarEndMapSoundName, g_EndMapSoundName, sizeof(g_EndMapSoundName));
		decl String:EndMapPath[128];
		PrecacheSound(g_EndMapSoundName, true);
		Format(EndMapPath, sizeof(EndMapPath), "sound/%s", g_EndMapSoundName);
		AddFileToDownloadsTable(EndMapPath);
	}
	
	if (GetConVarBool(CvarStartRoundSoundCheck))
	{
		GetConVarString(CvarStartRoundSoundName, g_StartRoundSoundName, sizeof(g_StartRoundSoundName));
		decl String:StartRoundPath[128];
		PrecacheSound(g_StartRoundSoundName, true);
		Format(StartRoundPath, sizeof(StartRoundPath), "sound/%s", g_StartRoundSoundName);
		AddFileToDownloadsTable(StartRoundPath);
	}
	
	if (GetConVarBool(CvarEndRoundSoundCheck))
	{
		GetConVarString(CvarEndRoundSoundName, g_EndRoundSoundName, sizeof(g_EndRoundSoundName));
		decl String:EndRoundPath[128];
		PrecacheSound(g_EndRoundSoundName, true);
		Format(EndRoundPath, sizeof(EndRoundPath), "sound/%s", g_EndRoundSoundName);
		AddFileToDownloadsTable(EndRoundPath);
	}
	
	if (GetConVarBool(CvarTFWinRoundSoundCheck))
	{
		GetConVarString(CvarTFWinRoundSoundName, g_WinRoundSoundName, sizeof(g_WinRoundSoundName));
		decl String:WinRoundPath[128];
		PrecacheSound(g_WinRoundSoundName, true);
		Format(WinRoundPath, sizeof(WinRoundPath), "sound/%s", g_WinRoundSoundName);
		AddFileToDownloadsTable(WinRoundPath);
	}
	
	if (GetConVarBool(CvarTFLoseRoundSoundCheck))
	{
		GetConVarString(CvarTFLoseRoundSoundName, g_LoseRoundSoundName, sizeof(g_LoseRoundSoundName));
		decl String:LoseRoundPath[128];
		PrecacheSound(g_LoseRoundSoundName, true);
		Format(LoseRoundPath, sizeof(LoseRoundPath), "sound/%s", g_LoseRoundSoundName);
		AddFileToDownloadsTable(LoseRoundPath);
	}
}

public Action:RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_LastRound = false;
	if (GetConVarBool(CvarStartRoundSoundCheck))
	{
		EmitSoundToAll(g_StartRoundSoundName);
	}
}

public Action:RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarBool(CvarEndMapSoundCheck))
	{
		new timeleft;
		GetMapTimeLeft(timeleft);
		if (timeleft <= 0)
		{
			EmitSoundToAll(g_EndMapSoundName);
			g_LastRound = true;
		}
	}
	if (GetConVarBool(CvarEndRoundSoundCheck))
	{
		if (!g_LastRound)
		{
			EmitSoundToAll(g_EndRoundSoundName);
		}	
	}
}

public Action:TFRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	int winner = GetEventInt(event, "team");
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
	    if (IsClientInGame(i))
	    {
			int clientTeam = GetClientTeam(i);
			
			if (clientTeam < 2) 
			{
				continue;
			}
			if (clientTeam == winner && GetConVarBool(CvarTFWinRoundSoundCheck)) 
			{
				EmitSoundToClient(i, g_WinRoundSoundName);
			} 
			else if (clientTeam != winner && GetConVarBool(CvarTFLoseRoundSoundCheck)) 
			{
				EmitSoundToClient(i, g_LoseRoundSoundName);
			}
	    }
	} 
}

public OnClientPostAdminCheck(client)
{
	if (GetConVarBool(CvarJoinSoundCheck))
	{
		EmitSoundToClient(client, g_JoinSoundName);
	}	
}





