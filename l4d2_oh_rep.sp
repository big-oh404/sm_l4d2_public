#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <adminmenu>
#define PLUGIN_VERSION  "0.2"

public Plugin:myinfo = {
	name = "Player Report System",
	author = "oh",
	description = "Bad players will be banned!",
	version = PLUGIN_VERSION,
	url = "https://github.com/ohyeah04/gameviolators-reporter"
};

Database g_hDatabase = null;

// Default Report Reasons. To-Do: custom reason catch from the chat
char reportReasons[7][24] =
{
	"Cheater", "Mic Spam", "Abusive", "Disrespect", "Spray", "Breaking Sever Rules", "Other"
};

char sDisplay[32];
int target[MAXPLAYERS+1];
char sQuery[512];
char ReportLogs[64];
float lastReportTime[MAXPLAYERS+1]; // timer to cool-down.

public OnPluginStart()
{
    RegConsoleCmd("sm_report", Command_report);
    RegConsoleCmd("sm_r", Command_report);
    RegConsoleCmd("sm_rep", Command_report);
    BuildPath(Path_SM, ReportLogs, sizeof(ReportLogs), "logs/reports.txt");
}

public void OnConfigsExecuted()
{
	if (!g_hDatabase)
	{
		Database.Connect(SQL_Connection, "reportsystem");
	}
}

// setup SQL:
public void SQL_Connection(Database database, const char[] error, int data)
{
	if (database == null)
		SetFailState(error);
	else
	{
		g_hDatabase = database;

		g_hDatabase.SetCharset("utf8mb4");

		g_hDatabase.Query(SQL_CreateCallback, "CREATE TABLE IF NOT EXISTS `reportsystem` ( \
                        `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT, \
                        `date` DATETIME NULL DEFAULT NULL, \
                        `reporter_steamid` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci', \
                        `violator_steamid`  VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci', \
                        `violator_ip` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci', \
                        `reason` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci', \
                        `server` INT(1) UNSIGNED NOT NULL, \
                        PRIMARY KEY (`id`) USING BTREE \
                        ) DEFAULT CHARSET = 'utf8mb4' ENGINE=InnoDB;");
	}
}

public void SQL_CreateCallback(Database datavas, DBResultSet results, const char[] error, int data)
{
	if (results == null)
		SetFailState(error);
}

public void SQL_Error(Database datavas, DBResultSet results, const char[] error, int data)
{
	if (results == null)
	{
		SetFailState(error);
	}
}

public Action Command_report(int client, int args)
{
    if(!client) return;
    if (CanReportAgain(client)) ReportMenu(client);
    // Cool down: 15 minutes default
    else PrintToChat(client, "\x05[\x04!report\x05] Wait \x04%i \x05seconds.", 900 - RoundToZero(GetEngineTime() - lastReportTime[client]));
}

void ReportMenu(client)
{
	Handle ReportMenu = CreateMenu(ReportMenuHandler);
	SetGlobalTransTarget(client);

    SetMenuTitle(ReportMenu, "Report:");
	SetMenuExitBackButton(ReportMenu, true);
	
	AddTargetsToMenu2(ReportMenu, client, COMMAND_FILTER_NO_IMMUNITY); //COMMAND_FILTER_NO_BOTS); -> hiding bots.
	
	DisplayMenu(ReportMenu, client, MENU_TIME_FOREVER);
}

public int ReportMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        char info[32];
        GetMenuItem(menu, param2, info, sizeof(info));
        int selected = GetClientOfUserId(StringToInt(info));
        
        if(selected == 0)
        {
            PrintToChat(client, "Disconnected :(");
        }
        else if (selected == client)
        {
            PrintToChat(client, "You cant report yourself...");
        }
        else
        {
            target[client] = selected;
            SelectReasonMenu(client);
        }
        //PrintToChat(client, "%i", );
    }
}

void SelectReasonMenu(int client)
{
    if (!client) return;

	Panel panel = new Panel();
    sDisplay[0] = '\0';
    Format(sDisplay, sizeof(sDisplay), "Target: %N\nReason:", target[client]);
	panel.SetTitle(sDisplay);

    for(int i=0; i < sizeof(reportReasons); i++)
	{
        sDisplay[0] = '\0';
        Format(sDisplay, sizeof(sDisplay), "%s", reportReasons[i]);		
        panel.DrawItem(sDisplay);
	}

	panel.Send(client, SelectReasonMenuHandler, 20);
	delete panel;
	//return Plugin_Handled;
}

public int SelectReasonMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
    if (action == MenuAction_Select)
    {
        char reporterSteamID[32];
        char violatorSteamID[32];
        char violatorIP[32];
        char date[50];

        lastReportTime[client] = GetEngineTime();

        GetClientAuthId(client, AuthId_Steam2, reporterSteamID, sizeof(reporterSteamID));
        GetClientAuthId(target[client], AuthId_Steam2, violatorSteamID, sizeof(violatorSteamID));
        GetClientIP(target[client], violatorIP, sizeof(violatorIP));       
        FormatTime(date, sizeof(date), "%Y-%m-%d %H:%M:%S");

        // writing logs
        Handle file = OpenFile(ReportLogs, "at+");
        WriteFileLine(file, "%s - Reporter STEAMID: %s. Violator: STEAMID: %s, IP: %s, Reason: %s", date, client, reporterSteamID, target[client], violatorSteamID, violatorIP, reportReasons[param2-1]);
        CloseHandle(file); // dont forget to close reader handler!!!!

        // preparing SQL request
        sQuery[0] = '\0';
        g_hDatabase.Format(sQuery, sizeof(sQuery), "INSERT INTO `reportsystem`(`date`, `reporter_steamid`, `violator_steamid`, `violator_ip`, `reason`, `server`) VALUES ('%s','%s','%s','%s','%s', 0)", date, reporterSteamID, violatorSteamID, violatorIP, reportReasons[param2-1]);
		g_hDatabase.Query(SQL_Error, sQuery);

        // announcing to all
        PrintToChatAll("\x05[\x04!report\x05] \x04%N \x05reported \x04%N \x05. Reason: \x04%s", client, target[client], reportReasons[param2 - 1]);
    }
}

bool CanReportAgain(int client)
{
    return (GetEngineTime() - lastReportTime[client] > 900.0);
}