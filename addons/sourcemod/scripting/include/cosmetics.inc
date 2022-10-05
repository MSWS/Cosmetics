#if defined _mscosmetics_included
	#endinput
#endif
#define _mscosmetics_included
#define CID_LENGTH 32

enum struct Cosmetic {
  char name[64];
  char type[32];
  int price;
  char sId[32];
}

native void GrantCosmetic(int client, char sId[CID_LENGTH]);

native bool HasCosmetic(int client, char sId[CID_LENGTH]);

native void RegisterCosmetic(any cosmetic);