#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>
#include <sdktools>


public Plugin myinfo = {
	name = "OnSpawnItems",
	author = "CircleSquared, TouchMe",
	description = "Give out items when spawned",
	version = "build_0000",
	url = "https://github.com/TouchMe-Inc/l4d2_on_spawn_weapon"
}


#define TEAM_SURVIVOR           2


enum
{
	HEALTH_FIRST_AID_KIT	= (1 << 0), // 1
	HEALTH_DEFIBRILLATOR	= (1 << 1), // 2

	HEALTH_PAIN_PILLS		= (1 << 2), // 4
	HEALTH_ADRENALINE		= (1 << 3), // 8

	THROWABLE_PIPE_BOMB		= (1 << 4), // 16
	THROWABLE_MOLOTOV		= (1 << 5), // 32
	THROWABLE_VOMITJAR		= (1 << 6)  // 64
};


ConVar g_cvItems = null;

bool g_bRoundIsLive = false;


/**
 * Called before OnPluginStart.
 *
 * @param myself      Handle to the plugin
 * @param bLate       Whether or not the plugin was loaded "late" (after map load)
 * @param sErr        Error message buffer in case load failed
 * @param iErrLen     Maximum number of characters for error message buffer
 * @return            APLRes_Success | APLRes_SilentFailure
 */
public APLRes AskPluginLoad2(Handle myself, bool bLate, char[] sErr, int iErrLen)
{
	if (GetEngineVersion() != Engine_Left4Dead2)
	{
		strcopy(sErr, iErrLen, "Plugin only supports Left 4 Dead 2");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

public void OnPluginStart()
{
	// Cvars.
	g_cvItems = CreateConVar("sm_osi_items", \
		"0", \
		"Item flags to give on leaving the saferoom (0: Disable, 1: Kit, 2: Defib, 4: Pills, 8: Adren, 16: Pipebomb, 32: Molotov, 64: Bile)", \
		_, false, 0.0, true, 127.0 \
	);

	// Events.
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_left_start_area", Event_LeftStartArea, EventHookMode_PostNoCopy);
	HookEvent("player_spawn", Event_PlayerSpawn);
}

void Event_RoundStart(Event event, const char[] sName, bool bDontBroadcast) {
	g_bRoundIsLive = false;
}

void Event_LeftStartArea(Event event, const char[] sName, bool bDontBroadcast) {
	g_bRoundIsLive = true;
}

void Event_PlayerSpawn(Event event, const char[] sName, bool bDontBroadcast)
{
	if (g_bRoundIsLive) {
		return;
	}

	int iClient = GetClientOfUserId(GetEventInt(event, "userid"));

	if (!iClient || !IsClientSurvivor(iClient)) {
		return;
	}

	int iItems = GetConVarInt(g_cvItems);

	if (!iItems) {
		return;
	}

	if (iItems & HEALTH_FIRST_AID_KIT) {
		GivePlayerItem(iClient, "weapon_first_aid_kit");
	} else if (iItems & HEALTH_DEFIBRILLATOR) {
		GivePlayerItem(iClient, "weapon_defibrillator");
	}

	if (iItems & HEALTH_PAIN_PILLS) {
		GivePlayerItem(iClient, "weapon_pain_pills");
	} else if (iItems & HEALTH_ADRENALINE) {
		GivePlayerItem(iClient, "weapon_adrenaline");
	}

	if (iItems & THROWABLE_PIPE_BOMB) {
		GivePlayerItem(iClient, "weapon_pipe_bomb");
	} else if (iItems & THROWABLE_MOLOTOV) {
		GivePlayerItem(iClient, "weapon_molotov");
	} else if (iItems & THROWABLE_VOMITJAR) {
		GivePlayerItem(iClient, "weapon_vomitjar");
	}
}

/**
 * Survivor team player?
 */
bool IsClientSurvivor(int iClient) {
	return (GetClientTeam(iClient) == TEAM_SURVIVOR);
}
