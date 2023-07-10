// Copyright (C) 2023 Katsute | Licensed under CC BY-NC-SA 4.0

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define TFSPELL_FIREBALL            0
#define TFSPELL_SWARM_OF_BATS       1
#define TFSPELL_OVERHEAL            2
#define TFSPELL_PUMPKIN_MIRV        3
#define TFSPELL_BLAST_JUMP          4
#define TFSPELL_STEALTH             5
#define TFSPELL_SHADOW_LEAP         6
#define TFSPELL_BALL_O_LIGHTNING    7
#define TFSPELL_MINIFY              8
#define TFSPELL_METEOR_SHOWER       9
#define TFSPELL_SUMMON_MONOCULUS    10
#define TFSPELL_SKELETON_HORDE      11

float delay;

int fireball;
int bats;
int overheal;
int pumpkin;
int jump;
int stealth;
int leap;
int lightning;
int minify;
int meteor;
int monoculus;
int skeletons;

ConVar delayCV;

ConVar fireballCV;
ConVar batsCV;
ConVar overhealCV;
ConVar pumpkinCV;
ConVar jumpCV;
ConVar stealthCV;
ConVar leapCV;
ConVar lightningCV;
ConVar minifyCV;
ConVar meteorCV;
ConVar monoculusCV;
ConVar skeletonsCV;

public Plugin myinfo = {
    name        = "Spells",
    author      = "Katsute",
    description = "Set spell probabilities",
    version     = "1.0",
    url         = "https://github.com/KatsuteTF/Spells"
}

public void OnPluginStart(){
    delayCV = CreateConVar("sm_spell_delay", "2.05", "Delay to set spell in seconds");
    delayCV.AddChangeHook(OnConvarChanged);

    delay = delayCV.FloatValue;

    fireballCV = CreateConVar("sm_spell_fireball", "1", "Weight for fireball spell");
    fireballCV.AddChangeHook(OnConvarChanged);

    fireball = fireballCV.IntValue;

    batsCV = CreateConVar("sm_spell_swarm_of_bats", "1", "Weight for swarm of bats spell");
    batsCV.AddChangeHook(OnConvarChanged);

    bats = batsCV.IntValue;

    overhealCV = CreateConVar("sm_spell_overheal", "1", "Weight for overheal spell");
    overhealCV.AddChangeHook(OnConvarChanged);

    overheal = overhealCV.IntValue;

    pumpkinCV = CreateConVar("sm_spell_pumpkin_mirv", "1", "Weight for pumpkin MIRV spell");
    pumpkinCV.AddChangeHook(OnConvarChanged);

    pumpkin = pumpkinCV.IntValue;

    jumpCV = CreateConVar("sm_spell_blast_jump", "1", "Weight for blast jump spell");
    jumpCV.AddChangeHook(OnConvarChanged);

    jump = jumpCV.IntValue;

    stealthCV = CreateConVar("sm_spell_stealth", "1", "Weight for stealth spell");
    stealthCV.AddChangeHook(OnConvarChanged);

    stealth = stealthCV.IntValue;

    leapCV = CreateConVar("sm_spell_shadow_leap", "0", "Weight for shadow leap spell, doesn't work if spell not supported");
    leapCV.AddChangeHook(OnConvarChanged);

    leap = leapCV.IntValue;

    lightningCV = CreateConVar("sm_spell_ball_o_lightning", "1", "Weight for ball o' lightning spell");
    lightningCV.AddChangeHook(OnConvarChanged);

    lightning = lightningCV.IntValue;

    minifyCV = CreateConVar("sm_spell_minify", "1", "Weight for minify spell");
    minifyCV.AddChangeHook(OnConvarChanged);

    minify = minifyCV.IntValue;

    meteorCV = CreateConVar("sm_spell_meteor_shower", "1", "Weight for meteor shower spell");
    meteorCV.AddChangeHook(OnConvarChanged);

    meteor = meteorCV.IntValue;

    monoculusCV = CreateConVar("sm_spell_summon_monoculus", "1", "Weight for summon monoculus spell");
    monoculusCV.AddChangeHook(OnConvarChanged);

    monoculus = monoculusCV.IntValue;

    skeletonsCV = CreateConVar("sm_spell_skeleton_horde", "1", "Weight for skeleton_horde spell");
    skeletonsCV.AddChangeHook(OnConvarChanged);

    skeletons = skeletonsCV.IntValue;
}


public void OnConvarChanged(const ConVar convar, const char[] oldValue, const char[] newValue){
    if(convar == delayCV)
        delay = StringToFloat(newValue);
    else if(convar == fireballCV)
        fireball = StringToInt(newValue);
    else if(convar == batsCV)
        bats = StringToInt(newValue);
    else if(convar == overhealCV)
        overheal = StringToInt(newValue);
    else if(convar == pumpkinCV)
        pumpkin = StringToInt(newValue);
    else if(convar == jumpCV)
        jump = StringToInt(newValue);
    else if(convar == stealthCV)
        stealth = StringToInt(newValue);
    else if(convar == leapCV)
        leap = StringToInt(newValue);
    else if(convar == lightningCV)
        lightning = StringToInt(newValue);
    else if(convar == minifyCV)
        minify = StringToInt(newValue);
    else if(convar == meteorCV)
        meteor = StringToInt(newValue);
    else if(convar == monoculusCV)
        monoculus = StringToInt(newValue);
    else if(convar == skeletonsCV)
        skeletons = StringToInt(newValue);
}

public void OnEntityCreated(int ent, const char[] classname){
    if(strcmp("tf_spell_pickup", classname) == 0)
        HookSingleEntityOutput(ent, "OnPlayerTouch", OnPlayerSpellbookTouch);
}

public void OnPlayerSpellbookTouch(const char[] output, const int ent, const int client, const float delay2){
    if(0 < client <= MaxClients){
        int sb = GetSpellbook(client);
        if(sb != -1 && GetEntProp(sb, Prop_Send,"m_iSpellCharges") == 0){
            bool rare = GetEntProp(ent, Prop_Data, "m_nTier") == 1;

            // | ← A → | ← B → | ← ... → |
            // ↑       ↑       ↑         ↑
            // 0       1 wt A  2 wt B    * wt last

            int end_fireball  = rare ? 0 : fireball;
            int end_bats      = rare ? 0 : bats     + end_fireball;
            int end_overheal  = rare ? 0 : overheal + end_bats;
            int end_pumpkin   = rare ? 0 : pumpkin  + end_overheal;
            int end_jump      = rare ? 0 : jump     + end_pumpkin;
            int end_stealth   = rare ? 0 : stealth  + end_jump;
            int end_leap      = rare ? 0 : leap     + end_stealth;
            int end_lightning = lightning           + end_leap;
            int end_minify    = minify              + end_lightning;
            int end_meteor    = meteor              + end_minify;
            int end_monoculus = monoculus           + end_meteor;
            int end_skeletons = skeletons           + end_monoculus;

            int len = end_skeletons;

            if(len <= 0) return;

            int x = RandomInt(1, len);
            int spell = -1;

            if(x <= end_fireball)       spell = TFSPELL_FIREBALL;
            else if(x <= end_bats)      spell = TFSPELL_SWARM_OF_BATS;
            else if(x <= end_overheal)  spell = TFSPELL_OVERHEAL;
            else if(x <= end_pumpkin)   spell = TFSPELL_PUMPKIN_MIRV;
            else if(x <= end_jump)      spell = TFSPELL_BLAST_JUMP;
            else if(x <= end_stealth)   spell = TFSPELL_STEALTH;
            else if(x <= end_leap)      spell = TFSPELL_SHADOW_LEAP;
            else if(x <= end_lightning) spell = TFSPELL_BALL_O_LIGHTNING;
            else if(x <= end_minify)    spell = TFSPELL_MINIFY;
            else if(x <= end_meteor)    spell = TFSPELL_METEOR_SHOWER;
            else if(x <= end_monoculus) spell = TFSPELL_SUMMON_MONOCULUS;
            else if(x <= end_skeletons) spell = TFSPELL_SKELETON_HORDE;

            if(spell <= 0) return;

            DataPack packet;
            CreateDataTimer(delay, SetSpell, packet);
            packet.WriteCell(sb);
            packet.WriteCell(spell);
            packet.WriteCell(spell == TFSPELL_FIREBALL || spell == TFSPELL_SWARM_OF_BATS || spell == TFSPELL_BLAST_JUMP || spell == TFSPELL_SHADOW_LEAP ? 2 : 1);
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