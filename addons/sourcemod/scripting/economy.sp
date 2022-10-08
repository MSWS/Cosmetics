#include <cosmetics>
#include <economy>
#include <sourcemod>
#include <clientprefs>
#include <multicolors>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
    name        = "Cosmetics - Economy",
    author      = "MSWS",
    description = "Basic Economy",
    version     = "0.0.1",
    url         = ""
};

Cookie gC_Credits;
char gS_Curr[16], gS_CurOne[16];

int gI_Credits[MAXPLAYERS + 1] = { -1, ... };
int gB_Late;

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max) {
    RegPluginLibrary("economy");
    CreateNative("GetCredits", Native_GetCredits);
    CreateNative("SetCredits", Native_SetCredits);
    CreateNative("GiveCredits", Native_GiveCredits);
    gB_Late = late;
    return APLRes_Success;
}

public void OnPluginStart() {
    gC_Credits = RegClientCookie("credits", "Client's credits", CookieAccess_Protected);
    char prefix[32];
    LoadTranslations("economy.phrases");
    LoadTranslations("common.phrases");
    Format(gS_Curr, sizeof(gS_Curr), "%t", "Credits");
    Format(gS_CurOne, sizeof(gS_CurOne), "%t", "Credit");
    Format(prefix, sizeof(prefix), "%t", "Prefix");

    CSetPrefix(prefix);

    RegConsoleCmd("sm_credits", Command_Credits, "Check your credits");
    RegAdminCmd("sm_givecredits", Command_GiveCredits, ADMFLAG_ROOT, "Give credits to a player");

    if (!gB_Late)
        return;
    for (int i = 1; i <= MaxClients; i++) {
        if (!IsValidEntity(i) || !AreClientCookiesCached(i))
            continue;
        OnClientCookiesCached(i);
    }
}

public Action Command_Credits(int client, int args) {
    int user = client;
    if (args == 1 && CheckCommandAccess(client, "sm_creditscheck", ADMFLAG_BAN)) {
        char target[32];
        GetCmdArg(1, target, sizeof(target));
        user = FindTarget(client, target, true);
        if (user == -1)
            return Plugin_Handled;
    }
    CReplyToCommand(client, "%T", "Command_Credits", client, user, GetCredits(user), gS_Curr);
    return Plugin_Handled;
}

public Action Command_GiveCredits(int client, int args) {
    if (args < 2) {
        CPrintToChat(client, "Usage: sm_givecredits <#userid|name> <amount>");
        return Plugin_Handled;
    }
    int targets[MAXPLAYERS + 1];
    char target[32], name[MAX_NAME_LENGTH];
    bool isml;
    GetCmdArg(1, target, sizeof(target));
    int result = ProcessTargetString(target, client, targets, sizeof(targets), COMMAND_FILTER_CONNECTED | COMMAND_FILTER_NO_BOTS, name, sizeof(name), isml);
    if (result <= 0) {
        ReplyToTargetError(client, result);
        return Plugin_Handled;
    }
    int credits = GetCmdArgInt(2);
    if (credits == 0) {
        CPrintToChat(client, "Invalid amount of credits");
        return Plugin_Handled;
    }
    for (int i = 0; i < result; i++) {
        int t = targets[i];
        GiveCredits(t, credits);
        CPrintToChat(t, "%N gave you %d %s.", client, credits, credits == 1 ? gS_CurOne : gS_Curr);
    }
    CPrintToChat(client, "Gave %d %s to %s.", credits, credits == 1 ? gS_CurOne : gS_Curr, name);
    return Plugin_Handled;
}

public int Native_GetCredits(Handle plugin, int args) {
    int client = GetNativeCell(1);
    return gI_Credits[client];
}

public int Native_SetCredits(Handle plugin, int args) {
    int client         = GetNativeCell(1);
    int credits        = GetNativeCell(2);
    gI_Credits[client] = credits;

    char buffer[16];
    IntToString(credits, buffer, sizeof(buffer));
    gC_Credits.Set(client, buffer);
    return 0;
}

public int Native_GiveCredits(Handle plugin, int args) {
    int client  = GetNativeCell(1);
    int credits = GetNativeCell(2);
    gI_Credits[client] += credits;

    char buffer[16];
    IntToString(gI_Credits[client], buffer, sizeof(buffer));
    gC_Credits.Set(client, buffer);
    return gI_Credits[client];
}

public void OnClientCookiesCached(int client) {
    char buffer[16];
    gC_Credits.Get(client, buffer, sizeof(buffer));
    gI_Credits[client] = StringToInt(buffer);
}

public void OnClientConnected(int client) {
    gI_Credits[client] = -1;
}

public void OnClientDisconnect(int client) {
    gI_Credits[client] = -1;
}