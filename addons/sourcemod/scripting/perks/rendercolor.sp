#include <../include/cosmetics.inc>

public Plugin myinfo =
{
    name        = "Cosmetics - RenderColor Perk",
    author      = "MSWS",
    description = "Description",
    version     = "1.0",
    url         = "https://github.com/MSWS"
};

char gS_ItemIDs[][]   = { "rendercolor_red", "rendercolor_blue", "rendercolor_green",
    "rendercolor_rainbow", "rendercolor_style" };
char gS_ItemNames[][] = { "Red", "Blue", "Green", "Rainbow", "Style" };

int gI_ItemCosts[] = { 100, 100, 100, 100, 100 };

public void OnPluginStart() {
    for (int i = 0; i < sizeof(gS_ItemIDs); i++) {
        MenuItem item;
        strcopy(item.name, sizeof(item.name), gS_ItemNames[i]);
        strcopy(item.info, sizeof(item.info), gS_ItemIDs[i]);
        item.cost = gI_ItemCosts[i];

        RegisterCosmetic(HIGHLIGHT, item);
    }
}

public void OnCosmeticEquip(int client, const char cosmetic[MAX_COSMETIC_INFO]) {
    PrintToChat(client, "You equipped %s!", cosmetic);
}

public void OnCosmeticUnequip(int client, const char cosmetic[MAX_COSMETIC_INFO]) {
    PrintToChat(client, "You unequipped %s!", cosmetic);
}