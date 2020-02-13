#include <sourcemod>
#include <sdktools>

Handle bomb_postion_sent;
bool bomb_is_setup;
float server_c4_position[3];

public void OnPluginStart(){
    HookEvent("round_start",trueoff_bomb_event);
    HookEvent("round_freeze_end",trueoff_bomb_event);
    HookEvent("round_end",trueoff_bomb_event);
    HookEvent("bomb_planted",bome_planted_event);
    HookEvent("player_spawn", player_spawn_event);
}

public void trueoff_bomb_event(Handle event, char[] name, bool dontBroadcast){
    bomb_is_setup = false;
}

public void bome_planted_event(Handle event, char[] name, bool dontBroadcast){
    bomb_is_setup = true;
    int ent=-1;
    ent = FindEntityByClassname(ent, "planted_c4");
    GetEntPropVector(ent, Prop_Send, "m_vecOrigin", server_c4_position);
}

public void player_spawn_event(Handle event, char[] name, bool dontBroadcast){
    int userid = GetClientOfUserId(GetEventInt(event,"userid"));
    if (bomb_is_setup == true && IsClientInGame(userid) && IsFakeClient(userid)){
        CreateTimer(1.0, sent_bot_bomb_postion_data,userid, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action sent_bot_bomb_postion_data(Handle timer,any client){
    StartPrepSDKCall(SDKCall_Raw);
    PrepSDKCall_SetSignature(SDKLibrary_Server,"\x55\x89\xE5\x56\x53\x83\xEC\x10\x8B\x75\x0C\xA1\x2A\x2A\x2A\x2A", 16);
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
    bomb_postion_sent = EndPrepSDKCall();
    if ((bomb_postion_sent = EndPrepSDKCall()) == null) SetFailState("Not find CSGameState::UpdatePlantedBomb");

    SDKCall(bomb_postion_sent,GetEntityAddress(client)+22484, server_c4_position);
}
