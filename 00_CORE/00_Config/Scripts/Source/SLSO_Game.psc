Scriptname SLSO_Game Extends ReferenceAlias

SexLabFramework SexLab
sslThreadController controller

String File
Bool IsAggressor
Bool IsFemale
Bool MentallyBroken
Actor ActorRef
Actor PartnerReference
Float Vibrate
float GetModSelfSta
float GetModSelfMag
float GetModPartSta
float GetModPartMag


Function Setup(Int Thread_Id)
	File = "/SLSO/Config.json"
	SexLab = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
	controller = SexLab.GetController(Thread_Id)
	ActorRef = self.GetActorRef()
	IsAggressor = controller.IsAggressor(ActorRef)
	IsFemale = controller.ActorAlias(ActorRef).GetGender() == 1
	
	GetModSelfSta = GetMod("Stamina", ActorRef)
	GetModSelfMag = GetMod("Magicka", ActorRef)

	if controller.ActorCount > 1
		PartnerReference = controller.ActorAlias(controller.Positions[sslUtility.IndexTravel(controller.Positions.Find(ActorRef), controller.ActorCount)]).GetActorRef()
		GetModPartSta = GetMod("Stamina", PartnerReference)
		GetModPartMag = GetMod("Magicka", PartnerReference) 
	endif

	if controller.ActorAlias(ActorRef).GetActorRef() == Game.GetPlayer()
;		SexLab.Log(" SLSO Setup() Player, enabling hotkeys")
		self.RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_edge"))
;		self.RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_orgasm"))
		self.RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_bonusenjoyment"))
	endif
	self.RegisterForModEvent("DeviceVibrateEffectStart", "OnVibrateStart")
	self.RegisterForModEvent("DeviceVibrateEffectStop", "OnVibrateStop")
	RegisterForSingleUpdate(1)
EndFunction

Function Shutdown()
	UnRegisterForUpdate()
	UnregisterForAllModEvents()
	UnregisterForAllKeys()
	ActorRef = none
	PartnerReference = none
	MentallyBroken = false
	Vibrate = 0
	GetModSelfSta = 0
	GetModSelfMag = 0
	GetModPartSta = 0
	GetModPartMag = 0

	self.Clear()
	;SexLab.Log(" SLSO Shutdown() id: " + (self.GetID() - 6) + " actor: " + (self.GetActorRef()).GetLeveledActorBase().GetName() + " can be cleared: " + self.TryToClear())
EndFunction

Event OnUpdate()
	;SexLab.Log(self.GetID() - 6  + " SLSO_Game OnUpdate() is running on " + ActorRef.GetLeveledActorBase().GetName())
	;float bench = game.GetRealHoursPassed()
	If self.GetActorRef() != none
		if controller.ActorAlias[self.GetID() - 5 - 1] != none
			if controller.ActorAlias[self.GetID() - 5 - 1].GetState() == "Animating"
				If JsonUtil.GetIntValue(File, "game_enabled") == 1
					Game()
				EndIf
				
				;SexLab.Log(" SLSO OnUpdate()Game: " + (game.GetRealHoursPassed()-bench)*60*60 )
				RegisterForSingleUpdate(1)
				return
			endif
		endif
	endif
	Shutdown()
EndEvent

float Function GetMod(string var = "", actor PartnerRef = none)
	if PartnerRef == none
		PartnerRef = ActorRef
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
		mod = SexLab.Stats.GetSkillLevel(PartnerRef, "Lewd") - SexLab.Stats.GetSkillLevel(PartnerRef, "Pure")
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
	float FullEnjoymentMOD = PapyrusUtil.ClampFloat(controller.ActorAlias(ActorRef).GetFullEnjoyment()/30, 1.0, 3.0)
	float mod
	
	if ActorRef.GetActorValuePercentage("Magicka") > 0.25 && MentallyBroken == true
		MentallyBroken = false
	EndIf
	;PC only
	;raise enjoyment
	If var == "Stamina"
		If MentallyBroken == false
			mod = GetModSelfSta
			If ActorRef.GetActorValuePercentage("Stamina") > 0.10
				;self
				if (controller.ActorCount == 1 || Input.IsKeyPressed(JsonUtil.GetIntValue(File, "hotkey_utility")))
					ModEnjoyment(ActorRef, mod, FullEnjoymentMOD)
					PartnerRef = ActorRef
				;partner
				elseif controller.ActorCount == 2
					ModEnjoyment(none, mod, FullEnjoymentMOD)
					PartnerRef = PartnerReference
				else
					return
				endif
			EndIf
		EndIf
	
	;edge
	ElseIf var == "Magicka"
		;Edge
		;self
		if MentallyBroken == false
			if controller.ActorCount == 1 || Input.IsKeyPressed(JsonUtil.GetIntValue(File, "hotkey_utility"))
				mod = GetModSelfMag
				If ActorRef.GetActorValuePercentage("Magicka") > 0.10
					ActorRef.DamageActorValue("Magicka", ActorRef.GetBaseActorValue("Magicka")/(10+mod)*0.5)
					controller.ActorAlias(ActorRef).HoldOut()
				EndIf

			;partner
			Elseif controller.ActorCount == 2
				mod = GetModSelfSta
				If ActorRef.GetActorValuePercentage("Stamina") > 0.10
					ActorRef.DamageActorValue("Stamina", ActorRef.GetBaseActorValue("Stamina")/(10+mod)*0.5)
					PartnerRef = PartnerReference
					controller.ActorAlias(PartnerRef).HoldOut()
				EndIf
			Else
				return
			EndIf
		EndIf

	;PC/NPC
	Elseif ActorRef != Game.GetPlayer()\
	|| JsonUtil.GetIntValue(File, "game_player_autoplay") == 1\
	|| ActorRef.GetActorValuePercentage("Magicka") < 0.10
		mod = GetModSelfSta
		
		If ActorRef.GetActorValuePercentage("Stamina") > 0.10
			;aggressor
			if controller.IsAggressor(ActorRef)
				;not broken, pleasure self
				if ActorRef.GetActorValuePercentage("Magicka") > 0.10
					ModEnjoyment(ActorRef, mod, FullEnjoymentMOD)
				;mental broken, pleasure partner
				else
					ModEnjoyment(none, mod, FullEnjoymentMOD)
				EndIf
				PartnerRef = PartnerReference
			Else
				;not aggressor
				
				;mentally not broken, pleasure self
				if ActorRef.GetActorValuePercentage("Magicka") > 0.10
					;pleasure self if self priority
					;lewdness based check
					if (Utility.RandomInt(0, 100) < SexLab.Stats.GetSkillLevel(ActorRef, "Lewd")*10*1.5) && JsonUtil.GetIntValue(File, "game_pleasure_priority") == 1
						ModEnjoyment(ActorRef, mod, FullEnjoymentMOD)
						PartnerRef = PartnerReference
				
					;relationship based check
					;try to pleasure other actor
					elseif (Utility.RandomInt(0, 100) < (25+controller.GetHighestPresentRelationshipRank(ActorRef)*10*2)) && controller.ActorCount == 2
						ModEnjoyment(none, mod, FullEnjoymentMOD)
						PartnerRef = PartnerReference
					
					;pleasure self if partner priority
					;lewdness based check
					elseif (Utility.RandomInt(0, 100) < SexLab.Stats.GetSkillLevel(ActorRef, "Lewd")*10*1.5) && JsonUtil.GetIntValue(File, "game_pleasure_priority") == 0
						ModEnjoyment(ActorRef, mod, FullEnjoymentMOD)
						PartnerRef = PartnerReference
					EndIf
					
				;mentally broken, pleasure partner
				else
					MentallyBroken = true
					ModEnjoyment(none, mod, FullEnjoymentMOD)
				EndIf
				PartnerRef = PartnerReference
			EndIf
		EndIf
		
		mod = GetModSelfMag
		;try to hold out if high relation with partner
		If ActorRef.GetActorValuePercentage("Magicka") > 0.10 && (Utility.RandomInt(0, 100) < (25+controller.GetHighestPresentRelationshipRank(ActorRef)*10*2) && controller.ActorCount == 2)
			If controller.ActorAlias(ActorRef).GetFullEnjoyment() as float > 95
				ActorRef.DamageActorValue("Magicka", ActorRef.GetBaseActorValue("Magicka")/(10+mod)) 
				controller.ActorAlias(ActorRef).HoldOut(3)
			EndIf
		EndIf
	endif
	
	MentalBreak(PartnerRef)
	
	If Vibrate > 0
		ActorRef.DamageActorValue("Stamina", ActorRef.GetBaseActorValue("Stamina")/(10+GetModSelfMag+FullEnjoymentMOD))
		controller.ActorAlias(ActorRef).BonusEnjoyment(ActorRef, Vibrate as Int)
		MentalBreak(ActorRef)
	EndIf
	
	If ((JsonUtil.GetIntValue(File, "game_no_sta_endanim") == 1 && ActorRef.GetActorValuePercentage("Stamina") < 0.10)\
	|| (JsonUtil.GetIntValue(File, "game_male_orgasm_endanim") == 1 && !IsFemale && (controller.ActorAlias(ActorRef) as sslActorAlias).GetOrgasmCount() > 0))\
	&& ((self.GetID() - 5 - 1 != 0 && controller.ActorCount <= 2) || controller.ActorCount == 1)\
	&& controller.Stage < controller.Animation.StageCount
		controller.AdvanceStage()
	EndIf
	;SexLab.Log(" SLSO GAME(): " + (game.GetRealHoursPassed()-bench)*60*60 )
EndFunction

Function ModEnjoyment(Actor PartnerRef, float mod, float FullEnjoymentMOD)
;with skills 3+ always raise enjoyment
;with skills 3- upto 30 chance to decrease enjoyment
	ActorRef.DamageActorValue("Stamina", ActorRef.GetBaseActorValue("Stamina")/(10+mod+FullEnjoymentMOD))
	;self
	if PartnerRef != none
		if mod < 3 && Utility.RandomInt(0, 100) < (3 - mod) * 10 && JsonUtil.GetIntValue(File, "game_enjoyment_reduction_chance") == 1
			controller.ActorAlias(ActorRef).BonusEnjoyment(PartnerRef, -1)
		else
			controller.ActorAlias(ActorRef).BonusEnjoyment(PartnerRef)
		endif
	else	
	;partner
		if mod < 3 && Utility.RandomInt(0, 100) < (3 - mod) * 10 && JsonUtil.GetIntValue(File, "game_enjoyment_reduction_chance") == 1
			controller.ActorAlias(ActorRef).BonusEnjoyment(none, -1)
		else
			controller.ActorAlias(ActorRef).BonusEnjoyment()
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
		PartnerRef.DamageActorValue("Magicka", PartnerRef.GetBaseActorValue("Magicka")/100*(10+GetModSelfSta+GetMod("Magicka",PartnerRef)/100)*(controller.ActorAlias(PartnerRef) as sslActorAlias).GetFullEnjoyment()/100*(1+(controller.ActorAlias(PartnerRef) as sslActorAlias).GetOrgasmCount())*0.5)
	endif
EndFunction


;----------------------------------------------------------------------------
;DD events
;----------------------------------------------------------------------------
Event OnVibrateStart(string eventName, string argString, float argNum, form sender)
	If argString == self.GetActorRef().GetName()
		Vibrate = argNum
	EndIf
EndEvent

Event OnVibrateStop(string eventName, string argString, float argNum, form sender)
	If argString == self.GetActorRef().GetName()
		Vibrate = 0
	EndIf
EndEvent

;----------------------------------------------------------------------------
;Hotkeys
;----------------------------------------------------------------------------

Event OnKeyDown(int keyCode)
	if controller.ActorAlias[self.GetID() - 5 - 1].GetActorRef() != none && JsonUtil.GetIntValue(File, "game_enabled") == 1
		If JsonUtil.GetIntValue(File, "hotkey_bonusenjoyment") == keyCode
			Game("Stamina")
;		ElseIf JsonUtil.GetIntValue(File, "hotkey_orgasm") == keyCode
;			if Input.IsKeyPressed(JsonUtil.GetIntValue(File, "hotkey_utility"))
;				controller.ActorAlias(ActorRef).Orgasm()
;			endif
		ElseIf JsonUtil.GetIntValue(File, "hotkey_edge") == keyCode
			Game("Magicka")
		EndIf
	EndIf
EndEvent
