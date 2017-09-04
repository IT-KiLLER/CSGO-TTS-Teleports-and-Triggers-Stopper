
/*	Copyright (C) 2017 IT-KiLLER
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#pragma semicolon 1
#pragma newdecls required

bool blockTeleport[MAXPLAYERS+1] = {false,...};
float msgtime[MAXPLAYERS+1];
ConVar sm_tss_enabled;

public Plugin myinfo =
{
	name = "[CS:GO] TTS - Teleports and Triggers Stopper.", // name-credit to LoKoO
	author = "IT-KiLLER",
	description = "Preventing teleports and triggers activation by noclipping players.",
	version = "1.1",
	url = "https://github.com/it-killer"
};

public void OnPluginStart()
{
	sm_tss_enabled = CreateConVar("sm_tss_enabled", "1.0", "Plugin is enabled or disabled.", _, true, 0.0, true, 1.0);
	RegAdminCmd("sm_blocktp", Command_Blocktp, ADMFLAG_ROOT, "Toggle command to enable/disable blocking of teleports and triggers when you are not in noclip mode.");
	RegAdminCmd("sm_unblocktp", Command_Blocktp, ADMFLAG_ROOT, "Toggle command to enable/disable blocking of teleports and triggers when you are not in noclip mode.");
}

public void OnClientDisconnect_Post(int client)
{
	blockTeleport[client] = false;
}

public Action Command_Blocktp(int client, int args)
{
	if(!sm_tss_enabled.BoolValue) return Plugin_Handled;
	if(!blockTeleport[client]) {
		blockTeleport[client] = true;
		CReplyToCommand(client, "{green}[SM] {green}Blocking{default} of teleports and triggers is now {green}Enabled");
	} else {
		blockTeleport[client] = false;
		CReplyToCommand(client, "{green}[SM] {lightred2}Blocking{default} of teleports and triggers is now {lightred2}Disabled");
	}
	return Plugin_Handled;
}

public void OnEntityCreated(int entity, const char[] classname) {
	if(classname[0] == 't' ? StrEqual(classname, "trigger_teleport") || StrEqual(classname, "trigger_multiple") || StrEqual(classname, "trigger_once") : false)
		Hookentity(entity);
}

stock void Hookentity(int entity){
	if (!IsValidEntity(entity) || !IsValidEdict(entity)) return;
	SDKHook(entity, SDKHook_Touch, onStartTouch);
	SDKHook(entity, SDKHook_EndTouch, onStartTouch);
}

public Action onStartTouch(int entity, int client)
{
	if (!IsValidEntity(entity) || !(1 <= client <= MaxClients) || !sm_tss_enabled.BoolValue) return Plugin_Continue;
	if(GetEntityMoveType(client) != MOVETYPE_NOCLIP && !blockTeleport[client]) return Plugin_Continue;

	if((msgtime[client] + 4.0) < GetGameTime()) {
		CPrintToChat(client, "{green}[SM]{lightred2} Blocking a teleporter or trigger. {lightblue}!blocktp{default}");
		PrintHintText(client, "Either you are in <font color='#00FF00'>noclip</font> mode or you have <font color='#00FF00'>enabled</font> <font color='#00FF00'>blocking</font> of teleports and triggers. <font color='#FF0000'>!blocktp</font>");
		msgtime[client] = GetGameTime();
	}
	return Plugin_Handled;
} 