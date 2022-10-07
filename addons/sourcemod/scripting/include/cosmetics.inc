#if defined _mscosmetics_included
	#endinput
#endif
#define _mscosmetics_included

#define MAX_COSMETICS 64

enum Category {
	HIGHLIGHT
}

enum struct MenuItem { 
	char info[32];
	char name[32];
	int cost;
}

MenuItem g_MenuItems[Category][MAX_COSMETICS];

native void RegisterCosmetic(Category cat, any item);

void FormatCategory(Category cat, char[] buffer, int len) {
	switch (cat) {
		case HIGHLIGHT:
			strcopy(buffer, len, "Highlight");
	}
}