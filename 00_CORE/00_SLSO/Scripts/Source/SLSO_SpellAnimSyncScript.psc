Scriptname SLSO_SpellAnimSyncScript extends activemagiceffect

SexLabFramework SexLab
sslThreadController controller

Actor ActorRef
Actor ActorSync	; for animation speed control
String File
Float Base_speed
Float Min_speed
Float Max_speed

Event OnEffectStart( Actor akTarget, Actor akCaster )
	if JsonUtil.GetIntValue(File, "game_animation_speed_control", 0) != 0
		ActorRef = akTarget
		File = "/SLSO/Config.json"
		SexLab = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
		RegisterForModEvent("SLSO_Start_widget", "Start_widget")
		RegisterForModEvent("AnimationEnd", "OnSexLabEnd")
	else
		Remove()
	endif
EndEvent

Event Start_widget(Int Widget_Id, Int Thread_Id)
	UnregisterForModEvent("SLSO_Start_widget")

	controller = SexLab.GetController(Thread_Id)
	
	if JsonUtil.GetIntValue(File, "game_animation_speed_control_actorsync") == 1 && controller.HasPlayer
		;sync to player
		ActorSync = Game.GetPlayer()
		SexLab.Log(" SLSO Setup() actor: " + ActorRef.GetLeveledActorBase().GetName() + " ActorSync to player")
	elseif JsonUtil.GetIntValue(File, "game_animation_speed_control_actorsync") == 2
		;sync to last actor in animation(probably male\aggressor)
		int i = controller.ActorCount
		while i > 0 && ActorSync == none
			i -= 1
			if controller.ActorAlias[i].GetActorRef() != none
				if !controller.ActorAlias[i].IsVictim()
					ActorSync = controller.ActorAlias[i].GetActorRef()
				endIf
			endIf
		endWhile
		SexLab.Log(" SLSO Setup() actor: " + ActorRef.GetLeveledActorBase().GetName() + " ActorSync to " + controller.ActorAlias[i].GetActorRef().GetLeveledActorBase().GetName())
	endif
	
	if ActorSync == none
		ActorSync = ActorRef
		SexLab.Log(" SLSO Setup() actor: " + ActorRef.GetLeveledActorBase().GetName() + " ActorSync to self")
	endif
	
	Base_speed = JsonUtil.GetIntValue(File, "game_animation_speed_control_base")/100
	Min_speed = JsonUtil.GetIntValue(File, "game_animation_speed_control_min")/100
	Max_speed = JsonUtil.GetIntValue(File, "game_animation_speed_control_max")/100
	
	RegisterForSingleUpdate(1)
EndEvent

Event OnSexLabEnd(string EventName, string argString, Float argNum, form sender)
	if controller == SexLab.GetController(argString as int)
		UnRegisterForUpdate()
		UnregisterForAllModEvents()
		UnregisterForAllKeys()
		Remove()
	endif
EndEvent

Event OnUpdate()
	if controller.ActorAlias(ActorRef).GetActorRef() != none
		if controller.ActorAlias(ActorRef).GetState() == "Animating"
			Float FullEnjoymentMOD
			
			if JsonUtil.GetIntValue(File, "game_animation_speed_control") == 1														;stamina based animation speed
				FullEnjoymentMOD = PapyrusUtil.ClampFloat(ActorSync.GetActorValuePercentage("Stamina")*100/30/3, Min_speed, Max_speed)
				AnimSpeedHelper.SetAnimationSpeed(ActorRef, FullEnjoymentMOD+Base_speed, 0.5, 0)
				;SexLab.Log(" SLSO AnimSpeed()(sta) actor: " + ActorRef.GetLeveledActorBase().GetName() + " ActorSync to " + ActorSync.GetLeveledActorBase().GetName() + " , speed: ", FullEnjoymentMOD / 3 + 0.5)
			elseif JsonUtil.GetIntValue(File, "game_animation_speed_control") == 2													;enjoyment based animation speed
				FullEnjoymentMOD = PapyrusUtil.ClampFloat(controller.ActorAlias(ActorSync).GetFullEnjoyment()/30/3, Min_speed, Max_speed)
				AnimSpeedHelper.SetAnimationSpeed(ActorRef, FullEnjoymentMOD+Base_speed, 0.5, 0)
				;SexLab.Log(" SLSO AnimSpeed()(enjoyment) actor: " + ActorRef.GetLeveledActorBase().GetName() + " ActorSync to " + ActorSync.GetLeveledActorBase().GetName() + " , speed: ", FullEnjoymentMOD / 3 + 0.5)
			endif
			
			RegisterForSingleUpdate(1)
			return
		endif
	endif
	Remove()
EndEvent

Event OnPlayerLoadGame()
	Remove()
EndEvent

Event OnEffectFinish( Actor akTarget, Actor akCaster )
	;AnimSpeedHelper.ResetAll()
	AnimSpeedHelper.SetAnimationSpeed(ActorRef, 1, 0, 0)
EndEvent

function Remove()
	SLSO_MCM SLSO = Quest.GetQuest("SLSO") as SLSO_MCM
	ActorRef.RemoveSpell(SLSO.SLSO_SpellAnimSync)
endFunction
