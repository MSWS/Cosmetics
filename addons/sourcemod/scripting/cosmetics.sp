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

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
    CreateNative("HasCosmetic", Native_HasCosmetic);
    CreateNative("IsEquipped", Native_IsEquipped);
    CreateNative("GrantCosmetic", Native_GrantCosmetic);
    return APLRes_Success;
}

public void OnPluginStart() {
    RegConsoleCmd("sm_shop", Command_Shop);
}

public Action Command_Shop(int client, int args) {
    OpenCosmeticMenu(client);
    return Plugin_Handled;
}

public void OpenCosmeticMenu(int client) {
    Menu menu = new Menu(MenuHandler_Cosmetic);
    menu.SetTitle("Store Menu - %d Credits", GetCredits(client));
    menu.AddItem("highlight", "Highlights");
    menu.AddItem("trails", "Trails");
    menu.AddItem("styles", "Styles");
    menu.AddItem("glows", "Glow");
    menu.AddItem("ws", "Weapon Skins");
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

// public void OpenHighlightMenu(int client) {
//     Menu menu = new Menu(MenuHandler_Highlight);
//     menu.SetTitle("Player Highlights - %d Credits\nOther players will see your player model tinted this color.", GetCredits(client));
//     char cls[3][8]   = { "255;0;0", "0;255;0", "0;0;255" };
//     char names[3][8] = { "Red", "Green", "Blue" };
//     int costs[]      = { 250, 200, 180 };
//     for (int i = 0; i < sizeof(cls); i++) {
//         char id[32];
//         Format(id, sizeof(id), "highlight_%s", names[i]);
//         char line[32];
//         if (!HasCosmetic(client, id)) {
//             Format(line, sizeof(line), "%s - %d Credits", names[i], costs[i]);
//             menu.AddItem(cls[i], line, GetCredits(client) > costs[i] ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
//         }
//         if (HasCosmetic(client, id)) {
//             if (IsEquipped(client, id)) {
//                 Format(line, sizeof(line), "%s - Equipped", names[i]);
//                 menu.AddItem(cls[i], line, ITEMDRAW_DISABLED);
//             }
//             Format(line, sizeof(line), "%s", names[i]);
//             menu.AddItem(cls[i], line);
//         }
//     }
//     menu.Display(client, MENU_TIME_FOREVER);
// }

int MenuHandler_Cosmetic(Menu menu, MenuAction action, int param1, int param2) {
    if (action != MenuAction_Select) {
        if (action == MenuAction_End)
            delete menu;
        return 0;
    }
    char sid[32];
    GetMenuItem(menu, param2, sid, sizeof(sid));
    if (StrEqual(sid, "highlight")) {
        // OpenHighlightMenu(param1);
    } else if (StrEqual(sid, "glows")) {
        //     OpenGlowMenu(param1);
        // } else if (StrEqual(sid, "weaponskin")) {
        //     OpenWeaponSkinMenu(param1);
    }
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
    // char sid[32];
    // GetMenuItem(menu, param2, sid, sizeof(sid));
    // char sCol[3][4];
    // ExplodeString(sid, ";", sCol, sizeof(sCol), sizeof(sCol[]));
    // int r     = StringToInt(sCol[0]);
    // int g     = StringToInt(sCol[1]);
    // int b     = StringToInt(sCol[2]);
    // int alpha = 255;
    // int un;
    // GetEntityRenderColor(param1, un, un, un, alpha);
    // SetEntityRenderColor(param1, r, g, b, alpha);
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