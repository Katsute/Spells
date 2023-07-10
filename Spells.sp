// Copyright (C) 2023 Katsute | Licensed under CC BY-NC-SA 4.0

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

public Plugin myinfo = {
    name        = "Spells",
    author      = "Katsute",
    description = "Set spell probabilities",
    version     = "1.0",
    url         = "https://github.com/KatsuteTF/Spells"
}

public void OnPluginStart(){

}

public void OnConvarChanged(const ConVar convar, const char[] oldValue, const char[] newValue){

}

public void OnEntityCreated(int ent, const char[] classname){
    if(strcmp("tf_spell_pickup", classname) == 0)
        HookSingleEntityOutput(ent, "OnPlayerTouch", OnPlayerSpellbookTouch);
}

public void OnPlayerSpellbookTouch(const char[] output, const int ent, const int client, const float delay){
    if(0 < client <= MaxClients){
        int sb = GetSpellbook(client);
        if(sb != -1 && GetEntProp(sb, Prop_Send,"m_iSpellCharges") == 0){
            bool rare = GetEntProp(entity, Prop_Data, "m_nTier") == 1;
        }
    }
}

public int GetSpellbook(const int client){
    int i = -1;
    while((i = FindEntityByClassname(i, "tf_weapon_spellbook")) != -1)
        if(GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") == client)
            return i;
    return -1;
}

public Action SetSpell(const Handle timer, const DataPack packet){
    packet.Reset();
    int ent = packet.ReadCell();

    SetEntProp(ent, Prop_Send, "m_iSelectedSpellIndex", packet.ReadCell());
    SetEntProp(ent, Prop_Send, "m_iSpellCharges", packet.ReadCell());
    return Plugin_Handled;
}

int RandomInt(const int min = 0, const int max = 1){
    return RoundToFloor((max + 1 - min) * GetURandomFloat()) + min;
}