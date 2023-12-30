#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#pragma newdecls required

public Plugin myinfo =
{
	name = "Death Announcer",
	author = "oh",
	description = "",
	version = "1.1",
	url = ""
};

int survcount = 0;

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("defibrillator_used", Event_PlayerDefibed);
}

public Action Event_PlayerDefibed(Event event, const char[] name, bool dontBroadcast)
{
	int iUserid = GetClientOfUserId(GetEventInt(event, "subject"));

	if (iUserid == 0) return Plugin_Continue;

    if(GetClientTeam(iUserid) == 2) 
    {
		CountAlive();
        PrintHintTextToAll("%N is ALIVE\nSurvivors now: %i!", iUserid, survcount);
    }
	return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int iUserid = GetClientOfUserId(event.GetInt("userid"));

	if (iUserid == 0) return Plugin_Continue;

    if(GetClientTeam(iUserid) == 2) 
    {
		CountAlive();
        PrintHintTextToAll("%N is DEAD\nSurvivors left: %i!", iUserid, survcount);
    }
    
	return Plugin_Continue;

}

void CountAlive() 
{
	survcount = 0;
	for (int i = 1; i <= MaxClients; i++)
    {
		if (!IsClientInGame(i) || GetClientTeam(i) != 2) continue;
		if (GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			survcount++;
		}	
	}
}