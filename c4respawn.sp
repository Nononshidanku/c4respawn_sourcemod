#include <sourcemod>
#include <sdktools>

Handle Bomb_Postion_Sent;
bool Bomb_Issetup;
float Server_C4_Position[3];

public void OnPluginStart(){
    HookEvent("round_start",Trueoff_Bomb_event);
    HookEvent("round_freeze_end",Trueoff_Bomb_event);
    HookEvent("round_end",Trueoff_Bomb_event);
    HookEvent("bomb_planted",Bome_Planted_event);
    HookEvent("player_spawn", Player_Spawn_event);
}

public void Trueoff_Bomb_event(Handle event, char[] name, bool dontBroadcast){
    Bomb_Issetup = false;
}

public void Bome_Planted_event(Handle event, char[] name, bool dontBroadcast){
    Bomb_Issetup = true;
    int Ent = -1;
    Ent = FindEntityByClassname(Ent, "planted_c4");
    GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Server_C4_Position);
}

public void Player_Spawn_event(Handle event, char[] name, bool dontBroadcast){
    int Userid = GetClientOfUserId(GetEventInt(event,"userid"));
    if (Bomb_Issetup == true && IsClientInGame(Userid) && IsFakeClient(Userid)){
        CreateTimer(1.0, Sent_Bot_Bomb_Postion_Data,Userid, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Sent_Bot_Bomb_Postion_Data(Handle timer,any client){
    StartPrepSDKCall(SDKCall_Raw);
    PrepSDKCall_SetSignature(SDKLibrary_Server,"\x55\x89\xE5\x56\x53\x83\xEC\x10\x8B\x75\x0C\xA1\x2A\x2A\x2A\x2A", 16);
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
    Bomb_Postion_Sent = EndPrepSDKCall();
    if ((Bomb_Postion_Sent = EndPrepSDKCall()) == null) SetFailState("Not find CSGameState::UpdatePlantedBomb");

    SDKCall(Bomb_Postion_Sent,GetEntityAddress(client)+22484, Server_C4_Position);
}
