#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#define PLUGIN_VERSION        "1.0"

public Plugin myinfo =
{
    name = "[L4D2] Force Tanks!",
    author = "oh",
    description = "Tanks!",
    version = PLUGIN_VERSION,
    url = "https://github.com/ohyeah04/"
}

public Action L4D_OnGetMissionVSBossSpawning(float &spawn_pos_min, float &spawn_pos_max, float &tank_chance, float &witch_chance)
{
    tank_chance = 1.0;
    return Plugin_Changed;
} 