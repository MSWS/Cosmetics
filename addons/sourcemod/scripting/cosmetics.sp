#include <cosmetics>
#include <economy>

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

public void OnPluginStart() {
    RegConsoleCmd("sm_shop", Command_Shop);
}

public Action Command_Shop(int client, int args) {
    OpenCosmeticMenu(client);
    return Plugin_Handled;
}

public void OpenCosmeticMenu(int client) {
    Menu menu = new Menu(MenuHandler_Cosmetic);
    menu.SetTitle("Cosmetic Store - %d Credits", GetCredits(client));
    menu.AddItem("highlight", "Highlights");
    menu.AddItem("glows", "Glows");
    menu.AddItem("weaponskin", "Weapon Skins");
    menu.Display(client, MENU_TIME_FOREVER);
}

public void OpenHighlightMenu(int client) {
    Menu menu = new Menu(MenuHandler_Cosmetic);
    menu.SetTitle("Player Highlights - %d Credits\nOther players will see your player model tinted this color.", GetCredits(client));
    menu.AddItem("255;0;0", "Red");
    menu.AddItem("0;255;0", "Green");
    menu.AddItem("0;0;255", "Blue");
    menu.Display(client, MENU_TIME_FOREVER);
}

int MenuHandler_Cosmetic(Menu menu, MenuAction action, int param1, int param2) {
    if (action != MenuAction_Select) {
        if (action == MenuAction_End)
            delete menu;
        return 0;
    }
    char sid[32];
    GetMenuItem(menu, param2, sid, sizeof(sid));
    if (StrEqual(sid, "highlight")) {
        OpenHighlightMenu(param1);
    } else if (StrEqual(sid, "glows")) {
        //     OpenGlowMenu(param1);
        // } else if (StrEqual(sid, "weaponskin")) {
        //     OpenWeaponSkinMenu(param1);
    }
    return 0;
}