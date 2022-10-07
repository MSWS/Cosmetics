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
    gB_Late = late;
    return APLRes_Success;
}

public void OnPluginStart() {
    gC_Credits = RegClientCookie("credits", "Client's credits", CookieAccess_Protected);

    LoadTranslations("economy.phrases");
    Format("%t", sizeof(gS_Curr), gS_Curr, "Credits");
    Format("%t", sizeof(gS_CurOne), gS_CurOne, "Credit");

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
    CReplyToCommand(client, "%T", "Command_Credits", client, GetCredits(client), gS_Curr);
    return Plugin_Handled;
}

public Action Command_GiveCredits(int client, int args) {
    
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