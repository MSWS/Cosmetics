#include <cosmetics>
#include <economy>
#include <clientprefs>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
    name        = "Cosmetics",
    author      = "MSWS",
    description = "Basic Cosmetics",
    version     = "0.0.1",
    url         = ""
};

int gI_Categories[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    CreateNative("HasCosmetic", Native_HasCosmetic);
    CreateNative("IsEquipped", Native_IsEquipped);
    CreateNative("GrantCosmetic", Native_GrantCosmetic);
    CreateNative("RegisterCosmetic", Native_RegisterCosmetic);
    CreateNative("EquipCosmetic", Native_EquipCosmetic);
    CreateNative("UnequipCosmetic", Native_UnequipCosmetic);
    return APLRes_Success;
}

public void OnPluginStart() {
    RegConsoleCmd("sm_shop", Command_Shop);

    for (int cat = 0; cat < sizeof(g_MenuItems); cat++) {
        for (int i = 0; i < MAX_COSMETICS; i++) {
            g_MenuItems[cat][i].cost = -1;
        }
    }
}

public Action Command_Shop(int client, int args) {
    OpenCosmeticMenu(client);
    return Plugin_Handled;
}

public void OpenCosmeticMenu(int client) {
    Menu menu = new Menu(MenuHandler_Cosmetic);
    menu.SetTitle("Store Menu - %d Credits", GetCredits(client));
    for (int i = 0; i < sizeof(g_MenuItems); i++) {
        char line[64];
        FormatCategory(view_as<Category>(i), line, sizeof(line));
        menu.AddItem("", line);
    }
    menu.Display(client, MENU_TIME_FOREVER);
}

public void OpenCategoryMenu(int client, Category cat) {
    Menu menu = new Menu(MenuHandler_Highlight);
    char catName[32];
    FormatCategory(cat, catName, sizeof(catName));
    menu.SetTitle("%s - %d Credits", catName, GetCredits(client));

    for (int i = 0; i < MAX_COSMETICS; i++) {
        MenuItem item;
        item = g_MenuItems[cat][i];
        char line[32];
        if (!HasCosmetic(client, item.info)) {
            Format(line, sizeof(line), "%s - %d Credits", item.name, item.cost);
            menu.AddItem(item.info, line, GetCredits(client) > item.cost ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
        }
        if (HasCosmetic(client, item.info)) {
            if (IsEquipped(client, item.info)) {
                Format(line, sizeof(line), "%s - Equipped", item.name);
                menu.AddItem(item.info, line, ITEMDRAW_DISABLED);
            }
            Format(line, sizeof(line), "%s", item.name);
            menu.AddItem(item.info, line);
        }
    }
}

int MenuHandler_Cosmetic(Menu menu, MenuAction action, int param1, int param2) {
    if (action != MenuAction_Select) {
        if (action == MenuAction_End)
            delete menu;
        return 0;
    }
    gI_Categories[param1] = param2;
    OpenCategoryMenu(param1, view_as<Category>(param2));
    return 0;
}

int MenuHandler_Highlight(Menu menu, MenuAction action, int param1, int param2) {
    if (action != MenuAction_Select) {
        if (action == MenuAction_End)
            delete menu;
        return 0;
    }
    char info[32];
    GetMenuItem(menu, param2, info, sizeof(info));
    PrintToChat(param1, "You selected %s", info);
    if (!HasCosmetic(param1, info)) {
        // Open purchase menu
        return 0;
    }

    UnequipCategory(param1, view_as<Category>(gI_Categories[param1]));
    EquipCosmetic(param1, info);
    return 0;
}

int Native_HasCosmetic(Handle plugin, int args) {
    int client = GetNativeCell(1);
    char info[32];
    GetNativeString(2, info, sizeof(info));
    Cookie ck = RegClientCookie(info, "Auto-generated", CookieAccess_Private);
    char buff[3];
    ck.Get(client, buff, sizeof(buff));
    delete ck;
    return StringToInt(buff) > 0;
}

int Native_IsEquipped(Handle plugin, int args) {
    int client = GetNativeCell(1);
    char info[32];
    GetNativeString(2, info, sizeof(info));
    Cookie ck = RegClientCookie(info, "Auto-generated", CookieAccess_Private);
    char buff[3];
    ck.Get(client, buff, sizeof(buff));
    delete ck;
    return StringToInt(buff) == 2;
}

int Native_GrantCosmetic(Handle plugin, int args) {
    int client = GetNativeCell(1);
    char info[32];
    GetNativeString(2, info, sizeof(info));
    bool equip = view_as<bool>(GetNativeCell(3));
    Cookie ck  = RegClientCookie(info, "Auto-generated", CookieAccess_Private);
    char buff[3];
    ck.Get(client, buff, sizeof(buff));
    if (StringToInt(buff) != 0)
        return 0;
    ck.Set(client, equip ? "2" : "1");
    delete ck;
    return 0;
}

int Native_RegisterCosmetic(Handle plugin, int args) {
    Category cat = view_as<Category>(GetNativeCell(1));
    MenuItem item;
    GetNativeArray(2, item, sizeof(item));
    int index = CountCosmetics(cat);
    if (index >= MAX_COSMETICS)
        ThrowError("Reached max cosmetics of %d (%d)", view_as<int>(cat), index);
    return 0;
}

public int CountCosmetics(Category cat) {
    for (int i = 0; i < MAX_COSMETICS; i++) {
        if (g_MenuItems[view_as<int>(cat)][i].cost == -1)
            return i;
    }
    return MAX_COSMETICS;
}

void UnequipCategory(int client, Category cat) {
    for (int i = 0; i < MAX_COSMETICS; i++) {
        MenuItem item;
        item = g_MenuItems[view_as<int>(cat)][i];
        if (item.cost == -1)
            continue;
        if (IsEquipped(client, item.info))
            UnequipCosmetic(client, item.info);
    }
}

public int Native_EquipCosmetic(Handle plugin, int args) {
    int client = GetNativeCell(1);
    char info[32];
    GetNativeString(2, info, sizeof(info));
    if (!HasCosmetic(client, info))
        ThrowError("Attempted to grant cosmetic %s to %N, but they don't have it", info, client);
    Cookie ck = RegClientCookie(info, "Auto-generated", CookieAccess_Private);
    ck.Set(client, "2");
    delete ck;
    return 0;
}

public int Native_UnequipCosmetic(Handle plugin, int args) {
    int client = GetNativeCell(1);
    char info[32];
    GetNativeString(2, info, sizeof(info));
    if (!HasCosmetic(client, info))
        ThrowError("Attempted to unequip cosmetic %s from %N, but they don't have it", info, client);
    Cookie ck = RegClientCookie(info, "Auto-generated", CookieAccess_Private);
    ck.Set(client, "1");
    delete ck;
    return 0;
}