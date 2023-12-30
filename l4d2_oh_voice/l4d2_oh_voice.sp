#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Extension:__ext_voice = 
{
    name = "VoiceHook",
    file = "VoiceHook.ext",
    autoload = 1,
    required = 1,
}

bool ClientSpeaking[MAXPLAYERS+1];
int iCount[2]; // 0 - survivor; 1 - infected
char SpeakingPlayers[2][255]

public Plugin myinfo =
{
	name = "l4D2 Voice Announcer",
	author = "oh",
	description = "See who is speaking on 4+ VS",
	version = "0.1",
	url = ""
};

public void OnPluginStart()
{
    CreateTimer(1.0, UpdateSpeaking, _, TIMER_REPEAT);
}

public OnClientSpeaking(client)
{
    ClientSpeaking[client] = true;
}

public Action UpdateSpeaking(Handle timer)
{
    iCount[0] = 0;
    iCount[1] = 0;
    SpeakingPlayers[0][0] = '\0';
    SpeakingPlayers[1][0] = '\0';

    for (int i = 1; i <= MaxClients; i++)
    {
        if (ClientSpeaking[i])
        {
            if (!IsClientInGame(i)) continue;

            //Team 2 - Survivor; Team 3 - Infected
            if (GetClientTeam(i) == 2)
            {
                Format(SpeakingPlayers[0], sizeof(SpeakingPlayers[]), "%s\n> %N", SpeakingPlayers[0], i);
                iCount[0]++;
            }
            else if (GetClientTeam(i) == 3)
            {
                Format(SpeakingPlayers[1], sizeof(SpeakingPlayers[]), "%s\n> %N", SpeakingPlayers[1], i);
                iCount[1]++;
            }
        }
        ClientSpeaking[i] = false;
    }

    if (iCount[0] > 0)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (!i) continue;
            if (!IsClientInGame(i)) continue;
            if (IsFakeClient(i)) continue;
            if (GetClientTeam(i) != 2) continue;

            PrintCenterText(i, "Players Speaking:%s", SpeakingPlayers[0]);
        }
    }

    if (iCount[1] > 0)
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (!i) continue;
            if (!IsClientInGame(i)) continue;
            if (IsFakeClient(i)) continue;
            if (GetClientTeam(i) != 3) continue;

            PrintCenterText(i, "Players Speaking:%s", SpeakingPlayers[1]);
        }
    }
}