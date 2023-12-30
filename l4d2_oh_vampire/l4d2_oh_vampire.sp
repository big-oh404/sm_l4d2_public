#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#pragma newdecls required

public Plugin myinfo =
{
	name = "L4D2 Vampire AddHP",
	author = "ohyeah",
	description = "",
	version = "1.1",
	url = ""
};

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int iAttacker = GetClientOfUserId(event.GetInt("attacker"));
	int iVictim = GetClientOfUserId(event.GetInt("userid"));
	bool headshot = event.GetBool("headshot");

	if (!iVictim || !iAttacker) return Plugin_Continue;

    if(GetClientTeam(iAttacker) == 2 && GetClientTeam(iVictim) == 3) 
    {
        float v1[3];
        float v2[3];

        GetClientEyePosition(iVictim, v1);
        
        if(IsValidClient(iAttacker)) GetClientEyePosition(iAttacker, v2);	
        else GetClientEyePosition(iVictim, v2);

		int hp;
        // small math for randomization:
		if(headshot) hp = RoundToCeil(GetVectorDistance(v1, v2) / 650.0) + GetRandomInt(10, 20);
		else hp = RoundToCeil(GetVectorDistance(v1, v2) / 650.0) + GetRandomInt(2, 8);
		if(hp > 25) hp = 25; //no more than +25hp bonus

		//AddHealth(iAttacker, hp);
        SetEntityHealth(client, GetClientHealth(client) + hp);

		PrintHintText(iAttacker, "+1 KILL\n+%i HP", hp);
    }
	return Plugin_Continue;
}

bool IsValidClient(int iClient)
{
	if (iClient <= 0) return false;
	if (iClient > MaxClients) return false;
	if (!IsClientInGame(iClient)) return false;
	return true;
}
