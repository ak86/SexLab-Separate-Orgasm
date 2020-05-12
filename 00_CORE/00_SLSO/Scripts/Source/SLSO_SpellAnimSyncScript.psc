Scriptname SLSO_SpellAnimSyncScript extends activemagiceffect

SexLabFramework Property SexLab auto
sslThreadController Property controller auto

Actor ActorSync	; for animation speed control
String Property File auto
Float Property Base_speed auto
Float Property Min_speed auto
Float Property Max_speed auto

Event OnEffectStart( Actor akTarget, Actor akCaster )
	File = "/SLSO/Config.json"
	
	if (SKSE.GetPluginVersion("animspeed plugin") > 0)
		if JsonUtil.GetIntValue(File, "game_animation_speed_control", 0) != 0
			SexLab = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
			RegisterForModEvent("SLSO_Start_widget", "Start_widget")
			RegisterForModEvent("AnimationEnd", "OnSexLabEnd")
			
			;SexLab.Log(" SLSO AnimSpeed() AnimSpeedHelper installed: " + SKSE.GetPluginVersion("animspeed plugin"))
		else
			Remove()
		endif
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
		SexLab.Log(" SLSO Setup() actor: " + GetTargetActor().GetDisplayName() + " ActorSync to player")
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
		SexLab.Log(" SLSO Setup() actor: " + GetTargetActor().GetDisplayName() + " ActorSync to " + controller.ActorAlias[i].GetActorRef().GetDisplayName())
	endif
	
	if ActorSync == none
		ActorSync = GetTargetActor()
		SexLab.Log(" SLSO Setup() actor: " + GetTargetActor().GetDisplayName() + " ActorSync to self")
	endif
	
	Base_speed = (JsonUtil.GetIntValue(File, "game_animation_speed_control_base", 50) as float)/100
	Min_speed = (JsonUtil.GetIntValue(File, "game_animation_speed_control_min" , 50) as float)/100
	Max_speed = (JsonUtil.GetIntValue(File, "game_animation_speed_control_max", 100) as float)/100
	
	RegisterForSingleUpdate(1)
EndEvent

Event OnSexLabEnd(string EventName, string argString, Float argNum, form sender)
	if controller == SexLab.GetController(argString as int)
		Remove()
	endif
EndEvent

Event OnUpdate()
	if controller.ActorAlias(GetTargetActor()).GetActorRef() != none
		if controller.ActorAlias(GetTargetActor()).GetState() == "Animating"
			Float FullEnjoymentMOD
				;Debug.Notification(" SLSO AnimSpeed()(OnUpdate,Animating) actor: " + GetTargetActor().GetDisplayName())
			
			if JsonUtil.GetIntValue(File, "game_animation_speed_control") == 1														;stamina based animation speed
				FullEnjoymentMOD = PapyrusUtil.ClampFloat(ActorSync.GetActorValuePercentage("Stamina")*100/30/3, Min_speed, Max_speed)
				AnimSpeedHelper.SetAnimationSpeed(GetTargetActor(), FullEnjoymentMOD+Base_speed, 0.5, 0)
				;SexLab.Log(" SLSO AnimSpeed()(sta) actor: " + GetTargetActor().GetDisplayName() + " ActorSync to " + ActorSync.GetDisplayName() + " , speed: ", FullEnjoymentMOD+Base_speed)
			elseif JsonUtil.GetIntValue(File, "game_animation_speed_control") == 2													;enjoyment based animation speed
				FullEnjoymentMOD = PapyrusUtil.ClampFloat((controller.ActorAlias(ActorSync).GetFullEnjoyment() as float)/30/3, Min_speed, Max_speed)
				AnimSpeedHelper.SetAnimationSpeed(GetTargetActor(), FullEnjoymentMOD+Base_speed, 0.5, 0)
				;SexLab.Log(" SLSO AnimSpeed()(enjoyment) actor: " + GetTargetActor().GetDisplayName() + " ActorSync to " + ActorSync.GetDisplayName() + " , speed: ", FullEnjoymentMOD+Base_speed)
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
	If akTarget != none
		if (SKSE.GetPluginVersion("animspeed plugin") > 0)
			;AnimSpeedHelper.ResetAll()
			;SexLab.Log(" SLSO AnimSpeed()(OnEffectFinish1) actor: " + akTarget.GetDisplayName() + " speed: " + AnimSpeedHelper.GetAnimationSpeed(akTarget,0))
			AnimSpeedHelper.SetAnimationSpeed(akTarget, 1, 0, 0)
			;SexLab.Log(" SLSO AnimSpeed()(OnEffectFinish2) actor: " + akTarget.GetDisplayName() + " speed: " + AnimSpeedHelper.GetAnimationSpeed(akTarget,0))
		endif
	EndIf
EndEvent

function Remove()
	If GetTargetActor() != none
		UnRegisterForUpdate()
		UnregisterForAllModEvents()
		UnregisterForAllKeys()
		SLSO_MCM SLSO = Quest.GetQuest("SLSO") as SLSO_MCM
		If GetTargetActor().HasSpell(SLSO.SLSO_SpellAnimSync)
			GetTargetActor().RemoveSpell(SLSO.SLSO_SpellAnimSync)
		EndIf
	EndIf
endFunction
