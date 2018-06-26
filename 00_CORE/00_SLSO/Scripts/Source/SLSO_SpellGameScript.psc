Scriptname SLSO_SpellGameScript Extends activemagiceffect

SexLabFramework SexLab
sslThreadController controller

String File
Bool IsAggressor
Bool IsFemale
Bool MentallyBroken
Bool Forced
Actor PartnerReference
Float Vibrate
float GetModSelfSta
float GetModSelfMag
float GetModPartSta
float GetModPartMag
int Position
int RelationshipRank

Event OnEffectStart( Actor akTarget, Actor akCaster )
	File = "/SLSO/Config.json"
	SexLab = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
	RegisterForModEvent("SLSO_Start_widget", "Start_widget")
	RegisterForModEvent("AnimationEnd", "OnSexLabEnd")
EndEvent

Event Start_widget(Int Widget_Id, Int Thread_Id)
	UnregisterForModEvent("SLSO_Start_widget")

	controller = SexLab.GetController(Thread_Id)
	
	;check if game enabled
	if JsonUtil.GetIntValue(File, "game_enabled") == 1 && (controller.HasPlayer || JsonUtil.GetIntValue(File, "game_npc_enabled", 0) == 1)
		IsAggressor = controller.IsAggressor(GetTargetActor())
		IsFemale = controller.ActorAlias(GetTargetActor()).GetGender() == 1
		
		GetModSelfSta = GetMod("Stamina", GetTargetActor())
		GetModSelfMag = GetMod("Magicka", GetTargetActor())
		Position  = controller.Positions.Find(GetTargetActor())
		RelationshipRank = controller.GetLowestPresentRelationshipRank(GetTargetActor())

		if controller.ActorCount > 1
			PartnerReference = controller.ActorAlias(controller.Positions[sslUtility.IndexTravel(controller.Positions.Find(GetTargetActor()), controller.ActorCount)]).GetActorRef()
			GetModPartSta = GetMod("Stamina", PartnerReference)
			GetModPartMag = GetMod("Magicka", PartnerReference) 
		endif

		if controller.ActorAlias(GetTargetActor()).GetActorRef() == Game.GetPlayer()
;			SexLab.Log(" SLSO Setup() Player, enabling hotkeys")
			self.RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_edge"))
;			self.RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_orgasm"))
			self.RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_bonusenjoyment"))
		endif
		;Estrus, increase enjoyment
		if controller.Animation.HasTag("Estrus")\
		|| controller.Animation.HasTag("Machine")\
		|| controller.Animation.HasTag("Slime")\
		|| controller.Animation.HasTag("Ooze")
			Forced = true
		endif
		self.RegisterForModEvent("DeviceVibrateEffectStart", "OnVibrateStart")
		self.RegisterForModEvent("DeviceVibrateEffectStop", "OnVibrateStop")
		RegisterForSingleUpdate(1)
	else
		Remove()
	endif
EndEvent

Event OnSexLabEnd(string EventName, string argString, Float argNum, form sender)
	if controller == SexLab.GetController(argString as int)
		Remove()
	endif
EndEvent

Event OnUpdate()
	;SexLab.Log(self.GetID() - 6  + " SLSO_Game OnUpdate() is running on " + GetTargetActor().GetDisplayName())
	;float bench = game.GetRealHoursPassed()
	if controller.ActorAlias(GetTargetActor()).GetActorRef() != none
		if controller.ActorAlias(GetTargetActor()).GetState() == "Animating"
			If JsonUtil.GetIntValue(File, "game_enabled") == 1
				Game()
			EndIf
			
			;SexLab.Log(" SLSO OnUpdate()Game: " + (game.GetRealHoursPassed()-bench)*60*60 )
			RegisterForSingleUpdate(1)
			return
		endif
	endif
	Remove()
EndEvent

float Function GetMod(string var = "", actor PartnerRef = none)
	if PartnerRef == none
		PartnerRef = GetTargetActor()
	endif
	float mod = 0
	if var == "Stamina"
		if (controller.Animation.HasTag("Vaginal"))
			mod = SexLab.Stats.GetSkillLevel(PartnerRef, "Vaginal")
		elseif(controller.Animation.HasTag("Anal"))
			mod = SexLab.Stats.GetSkillLevel(PartnerRef, "Anal")
		elseif(controller.Animation.HasTag("Oral"))
			mod = SexLab.Stats.GetSkillLevel(PartnerRef, "Oral")
		elseif(controller.Animation.HasTag("Foreplay") || controller.Animation.HasTag("Masturbation"))
			mod = SexLab.Stats.GetSkillLevel(PartnerRef, "Foreplay")
		endIf
	elseif var == "Magicka"
		mod = SexLab.Stats.GetSkillLevel(PartnerRef, "Lewd", 0.3) - SexLab.Stats.GetSkillLevel(PartnerRef, "Pure", 0.3)
	else
		Debug.Notification("error, SLSO widget GetMod has no var")
	endif
	;return Stamina 0..6
	;return Magicka -6..+6
	return PapyrusUtil.ClampFloat(mod, -6, 6)
EndFunction

Function Game(string var = "")
	;float bench = game.GetRealHoursPassed()
	Actor PartnerRef = none
	float FullEnjoymentMOD = PapyrusUtil.ClampFloat((controller.ActorAlias(GetTargetActor()).GetFullEnjoyment() as float)/30, 1.0, 3.0)
	float mod
	
	if GetTargetActor().GetActorValuePercentage("Magicka") > 0.25 && MentallyBroken == true
		MentallyBroken = false
	EndIf
	
	;PC only (hotkey)
	;raise enjoyment
	If var == "Stamina"
		If MentallyBroken == false
			mod = GetModSelfSta
			If GetTargetActor().GetActorValuePercentage("Stamina") > 0.10
				;self
				if (controller.ActorCount == 1 || Input.IsKeyPressed(JsonUtil.GetIntValue(File, "hotkey_utility")))
					ModEnjoyment(GetTargetActor(), mod, FullEnjoymentMOD)
					PartnerRef = GetTargetActor()
				;partner
				elseif controller.ActorCount == 2
					ModEnjoyment(none, mod, FullEnjoymentMOD)
					PartnerRef = PartnerReference
				else
					return
				endif
			EndIf
		EndIf
	
	;PC only (hotkey)
	;edge
	ElseIf var == "Magicka"
		;Edge
		;self
		if MentallyBroken == false
			if controller.ActorCount == 1 || Input.IsKeyPressed(JsonUtil.GetIntValue(File, "hotkey_utility"))
				mod = GetModSelfMag
				If GetTargetActor().GetActorValuePercentage("Magicka") > 0.10
					GetTargetActor().DamageActorValue("Magicka", GetTargetActor().GetBaseActorValue("Magicka")/(10+mod)*0.5)
					controller.ActorAlias(GetTargetActor()).HoldOut()
				EndIf

			;partner
			Elseif controller.ActorCount == 2
				mod = GetModSelfSta
				If GetTargetActor().GetActorValuePercentage("Stamina") > 0.10
					GetTargetActor().DamageActorValue("Stamina", GetTargetActor().GetBaseActorValue("Stamina")/(10+mod)*0.5)
					PartnerRef = PartnerReference
					controller.ActorAlias(PartnerRef).HoldOut()
				EndIf
			Else
				return
			EndIf
		EndIf

	;PC(auto/mentalbreak)/NPC
	Elseif GetTargetActor() != Game.GetPlayer()\
	|| JsonUtil.GetIntValue(File, "game_player_autoplay") == 1\
	|| GetTargetActor().GetActorValuePercentage("Magicka") < 0.10
		mod = GetModSelfSta
		
		If GetTargetActor().GetActorValuePercentage("Stamina") > 0.10
			;aggressor
			if controller.IsAggressor(GetTargetActor())
				;hate sex, enemies
				if RelationshipRank < 0
					mod = math.abs(RelationshipRank)
					ModEnjoyment(GetTargetActor(), mod, FullEnjoymentMOD)
				
				;rough sex, nautrals-lovers﻿
				else
				;not broken, pleasure self
					if GetTargetActor().GetActorValuePercentage("Magicka") > 0.10
						ModEnjoyment(GetTargetActor(), mod, FullEnjoymentMOD)
				;mental broken, pleasure partner
					else
						ModEnjoyment(none, mod, FullEnjoymentMOD)
					EndIf
				EndIf
			Else
				;not aggressor
				
				;mentally not broken, pleasure self
				if GetTargetActor().GetActorValuePercentage("Magicka") > 0.10
					;pleasure self if self priority
					;lewdness based check
					if (Utility.RandomInt(0, 100) < SexLab.Stats.GetSkillLevel(GetTargetActor(), "Lewd", 0.3)*10*1.5) && JsonUtil.GetIntValue(File, "game_pleasure_priority") == 1
						ModEnjoyment(GetTargetActor(), mod, FullEnjoymentMOD)
				
					;relationship based check
					;try to pleasure other actor
					elseif (Utility.RandomInt(0, 100) < (25+controller.GetHighestPresentRelationshipRank(GetTargetActor())*10*2)) && controller.ActorCount == 2
						ModEnjoyment(none, mod, FullEnjoymentMOD)
					
					;pleasure self if partner priority
					;lewdness based check
					elseif (Utility.RandomInt(0, 100) < SexLab.Stats.GetSkillLevel(GetTargetActor(), "Lewd", 0.3)*10*1.5) && JsonUtil.GetIntValue(File, "game_pleasure_priority") == 0
						ModEnjoyment(GetTargetActor(), mod, FullEnjoymentMOD)

					EndIf
					
				;mentally broken, pleasure partner
				else
					MentallyBroken = true
					ModEnjoyment(none, mod, FullEnjoymentMOD)
				EndIf
			EndIf
			PartnerRef = PartnerReference
		EndIf
		
		mod = GetModSelfMag
		
		;try to hold out orgasm if high relation with partner
		If GetTargetActor().GetActorValuePercentage("Magicka") > 0.10 && (Utility.RandomInt(0, 100) < (25+controller.GetHighestPresentRelationshipRank(GetTargetActor())*10*2) && controller.ActorCount == 2)
			If controller.ActorAlias(GetTargetActor()).GetFullEnjoyment() as float > 95
				GetTargetActor().DamageActorValue("Magicka", GetTargetActor().GetBaseActorValue("Magicka")/(10+mod)) 
				controller.ActorAlias(GetTargetActor()).HoldOut(3)
			EndIf
		EndIf
	endif
	
	MentalBreak(PartnerRef)
	
	;DD vibrations
	If Vibrate > 0
		GetTargetActor().DamageActorValue("Stamina", GetTargetActor().GetBaseActorValue("Stamina")/(10+GetModSelfMag+FullEnjoymentMOD))
		controller.ActorAlias(GetTargetActor()).BonusEnjoyment(GetTargetActor(), Vibrate as Int)
		MentalBreak(GetTargetActor())
	EndIf
	
	;EC forced masturbation
	If Forced
		GetTargetActor().DamageActorValue("Stamina", GetTargetActor().GetBaseActorValue("Stamina")/(10+GetModSelfMag+FullEnjoymentMOD))
		controller.ActorAlias(GetTargetActor()).BonusEnjoyment(GetTargetActor(), 1)
		MentalBreak(GetTargetActor())
	EndIf

	;end animation if male actor out of sta or orgasmed
	If ((JsonUtil.GetIntValue(File, "game_no_sta_endanim") == 1 && GetTargetActor().GetActorValuePercentage("Stamina") < 0.10)\
	|| (JsonUtil.GetIntValue(File, "game_male_orgasm_endanim") == 1 && !IsFemale && (controller.ActorAlias(GetTargetActor()) as sslActorAlias).GetOrgasmCount() > 0))\
	&& ((Position != 0 && controller.ActorCount <= 2) || controller.ActorCount == 1)\
	&& controller.Stage < controller.Animation.StageCount
		controller.AdvanceStage()
	EndIf
	;SexLab.Log(" SLSO GAME(): " + (game.GetRealHoursPassed()-bench)*60*60 )
EndFunction

Function ModEnjoyment(Actor PartnerRef, float mod, float FullEnjoymentMOD)
;with skills 3+ always raise enjoyment
;with skills 3- upto 30 chance to decrease enjoyment
	GetTargetActor().DamageActorValue("Stamina", GetTargetActor().GetBaseActorValue("Stamina")/(10+mod+FullEnjoymentMOD))
	;self
	if PartnerRef != none
		if mod < 3 && Utility.RandomInt(0, 100) < (3 - mod) * 10 && JsonUtil.GetIntValue(File, "game_enjoyment_reduction_chance") == 1
			controller.ActorAlias(GetTargetActor()).BonusEnjoyment(PartnerRef, -1)
		else
			controller.ActorAlias(GetTargetActor()).BonusEnjoyment(PartnerRef)
		endif
	else	
	;partner
		if mod < 3 && Utility.RandomInt(0, 100) < (3 - mod) * 10 && JsonUtil.GetIntValue(File, "game_enjoyment_reduction_chance") == 1
			controller.ActorAlias(GetTargetActor()).BonusEnjoyment(none, -1)
		else
			controller.ActorAlias(GetTargetActor()).BonusEnjoyment()
		endif
	endif
EndFunction

Function MentalBreak(Actor PartnerRef)
	;damage actor magicka/mental break
	if PartnerRef != none
			;1% * (base dmg(10) + own skill(0-6) + partner lewdness(-6+6)) * partner enjoyment% * orgasms(1+)
			;PartnerRef.DamageActorValue("Magicka", \
			;	PartnerRef.GetBaseActorValue("Magicka")/100\
			;		*(10+GetModSelfSta+GetMod("Magicka",PartnerRef)/100)\
			;		*(controller.ActorAlias(PartnerRef) as sslActorAlias).GetFullEnjoyment()/100\
			;		*(1+(controller.ActorAlias(PartnerRef) as sslActorAlias).GetOrgasmCount()))
		PartnerRef.DamageActorValue("Magicka", PartnerRef.GetBaseActorValue("Magicka")/100*(10+GetModSelfSta+GetMod("Magicka",PartnerRef)/100)*((controller.ActorAlias(PartnerRef) as sslActorAlias).GetFullEnjoyment() as float)/100*(1+(controller.ActorAlias(PartnerRef) as sslActorAlias).GetOrgasmCount())*0.5)
	endif
EndFunction

Event OnPlayerLoadGame()
	Remove()
EndEvent

Event OnEffectFinish( Actor akTarget, Actor akCaster )
EndEvent

Function Remove()
	If GetTargetActor() != none
		UnRegisterForUpdate()
		UnregisterForAllModEvents()
		UnregisterForAllKeys()
		SLSO_MCM SLSO = Quest.GetQuest("SLSO") as SLSO_MCM
		GetTargetActor().RemoveSpell(SLSO.SLSO_SpellGame)
	endIf
EndFunction

;----------------------------------------------------------------------------
;DD events
;----------------------------------------------------------------------------
Event OnVibrateStart(string eventName, string argString, float argNum, form sender)
	If argString == GetTargetActor().GetName()
		Vibrate = argNum
	EndIf
EndEvent

Event OnVibrateStop(string eventName, string argString, float argNum, form sender)
	If argString == GetTargetActor().GetName()
		Vibrate = 0
	EndIf
EndEvent

;----------------------------------------------------------------------------
;Hotkeys
;----------------------------------------------------------------------------

Event OnKeyDown(int keyCode)
	if controller.ActorAlias(GetTargetActor()).GetActorRef() != none && JsonUtil.GetIntValue(File, "game_enabled") == 1
		If JsonUtil.GetIntValue(File, "hotkey_bonusenjoyment") == keyCode
			Game("Stamina")
;		ElseIf JsonUtil.GetIntValue(File, "hotkey_orgasm") == keyCode
;			if Input.IsKeyPressed(JsonUtil.GetIntValue(File, "hotkey_utility"))
;				controller.ActorAlias(GetTargetActor()).Orgasm()
;			endif
		ElseIf JsonUtil.GetIntValue(File, "hotkey_edge") == keyCode
			Game("Magicka")
		EndIf
	EndIf
EndEvent
