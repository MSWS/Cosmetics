#include <cosmetics>
#include <economy>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
  name = "Cosmetics",
  author = "MSWS",
  description = "Basic Cosmetics",
  version = "0.0.1",
  url = ""
};

StringMap categories;

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max) {
  RegPluginLibrary("cosmetics");
  CreateNative("RegisterCosmetic", Native_RegisterCosmetic);
}

public int Native_RegisterCosmetic(Handle plugin, int args) {

}