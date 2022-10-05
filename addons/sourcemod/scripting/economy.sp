#include <cosmetics>
#include <economy>

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

int gI_Credits[MAXPLAYERS + 1] = { -1 , ... };
int gB_Late;

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max) {
    RegPluginLibrary("economy");
    CreateNative("GetCredits", Native_GetCredits);
    CreateNative("SetCredits", Native_SetCredits);
    gB_Late = late;
    return APLRes_Success;
}

public void OnPluginStart() {
    if (gB_Late)
        LoadCache();
}

void LoadCache() {
}

public int Native_GetCredits(Handle plugin, int args) {
}

public int Native_SetCredits(Handle plugin, int args) {
}

void SQL_LoadClient(int client, bool force = false) {
  if(gI_Credits[client] != -1 && !force)
    return;
  int auth = GetSteamAccountID(client);
}