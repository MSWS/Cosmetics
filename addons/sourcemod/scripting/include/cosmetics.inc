#if defined _mscosmetics_included
	#endinput
#endif
#define _mscosmetics_included

#define MAX_COSMETICS 64
#define MAX_COSMETIC_INFO 32

enum Category {
	HIGHLIGHT
}

enum struct MenuItem { 
	char info[MAX_COSMETIC_INFO];
	char name[32];
	int cost;
}

MenuItem g_MenuItems[Category][MAX_COSMETICS];

native void RegisterCosmetic(Category cat, any[] item);

native bool HasCosmetic(int client, const char cosmetic[MAX_COSMETIC_INFO]);

native bool IsEquipped(int client, const char cosmetic[MAX_COSMETIC_INFO]);

native void GrantCosmetic(int client, const char cosmetic[MAX_COSMETIC_INFO], bool equip = false);

native void EquipCosmetic(int client, const char cosmetic[MAX_COSMETIC_INFO]);
native void UnequipCosmetic(int client, const char cosmetic[MAX_COSMETIC_INFO]);

forward void OnCosmeticEquip(int client, const char cosmetic[MAX_COSMETIC_INFO]);
forward void OnCosmeticUnequip(int client, const char cosmetic[MAX_COSMETIC_INFO]);
forward void OnCosmeticsLoaded(int client);
forward void OnCosmeticPurchased(int client, const char cosmetic[MAX_COSMETIC_INFO]);

void FormatCategory(Category cat, char[] buffer, int len) {
	switch (cat) {
		case HIGHLIGHT:
			strcopy(buffer, len, "Highlight");
	}
}