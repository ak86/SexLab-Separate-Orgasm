Scriptname SLSO_Game Extends ReferenceAlias

SexLabFramework SexLab
sslThreadController controller

import MfgConsoleFunc

String File
Bool IsAggressor
Bool IsVictim
Bool IsPlayer
Bool IsFemale
Bool IsSilent
Bool MentallyBroken
Actor ActorRef
Actor PartnerReference
Actor ActorSync	; for animation speed control
Float Vibrate
Int Voice
FormList SoundContainer
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
	IsVictim = controller.IsVictim(ActorRef)
	IsPlayer = self.GetActorRef() == Game.GetPlayer()
	IsFemale = controller.ActorAlias(ActorRef).GetGender() == 1
	IsSilent = controller.ActorAlias[self.GetID() - 6].IsSilent()
	
	if IsFemale
		Voice = 0
		SoundContainer = (Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist
		if SoundContainer.GetSize() > 0
			if IsPlayer																							;PC selected voice
				Voice = JsonUtil.GetIntValue(File, "sl_voice_player")
				SexLab.Log(" SLSO Setup() actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " Voice: " +Voice + " PC selected voice")
			elseif JsonUtil.GetIntValue(File, "sl_voice_npc") == -2 && SoundContainer.GetSize() > 0				;NPC random voice
				Voice = Utility.RandomInt(1, (SoundContainer.GetSize()))
				SexLab.Log(" SLSO Setup() actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " Voice: " +Voice + " NPC random voice")
			elseif JsonUtil.GetIntValue(File, "sl_voice_npc") == -1 && SoundContainer.GetSize() > 1				;NPC random non PC voice
				while Voice < 1 || Voice == JsonUtil.GetIntValue(File, "sl_voice_player") 
					Voice = Utility.RandomInt(1, (SoundContainer.GetSize()))
					SexLab.Log(" SLSO Setup() actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " Voice: " +Voice + " NPC random non PC voice")
				endwhile
			elseif JsonUtil.GetIntValue(File, "sl_voice_npc") > 0												;todo	;NPC selected voice ; or not todo
				Voice = JsonUtil.GetIntValue(File, "sl_voice_npc")
				SexLab.Log(" SLSO Setup() actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " Voice: " +Voice + " sl_voice_npc > 0")
			endif
		else
			JsonUtil.SetIntValue(File, "sl_voice_player", 0)
			JsonUtil.SetIntValue(File, "sl_voice_npc", 0)
			Voice = 0
			SexLab.Log(" SLSO Setup() actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " no voice packs found")
		endif
		
		if Voice > 0
			SoundContainer = SoundContainer.GetAt(Voice - 1) as formlist
			SexLab.Log(" SLSO Setup() actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " Voice: " +Voice + " SoundContainer " + SoundContainer)
		else
			SexLab.Log(" SLSO Setup() actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " Voice(0=disabled): " +Voice + " SoundContainer " + SoundContainer)
		endif
	else 
		Voice = 0
		SoundContainer = none
		SexLab.Log(" SLSO Setup() actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " is not female, playing sexlab voice")
	endif
	
	if JsonUtil.GetIntValue(File, "game_animation_speed_control_actorsync") == 1
		;sync to player
		ActorSync = Game.GetPlayer()
		SexLab.Log(" SLSO Setup() actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " ActorSync to player")
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
		SexLab.Log(" SLSO Setup() actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " ActorSync to " + controller.ActorAlias[i].GetActorRef().GetLeveledActorBase().GetName())
	endif
	
	if ActorSync == none
		ActorSync = ActorRef
		SexLab.Log(" SLSO Setup() actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " ActorSync to self")
	endif
	
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
	if self.GetActorRef() != none
		AnimSpeedHelper.ResetAll()
	endif
	ActorRef = none
	PartnerReference = none
	ActorSync = none
	Voice = 0
	SoundContainer = none
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
	If self.GetActorRef() != none
		if controller.ActorAlias[self.GetID() - 5 - 1] != none
			if controller.ActorAlias[self.GetID() - 5 - 1].GetState() == "Animating"
				Int RawFullEnjoyment = controller.ActorAlias(ActorRef).GetFullEnjoyment()
				Int FullEnjoyment = PapyrusUtil.ClampInt(RawFullEnjoyment/10, 0, 10) + 1
				AnimSpeed()
				If JsonUtil.GetIntValue(File, "game_enabled") == 1
					Game()
				EndIf
				
				if !IsSilent && IsFemale && controller.ActorAlias[self.GetID() - 5 - 1].GetState() == "Animating"
					if Voice > 0 && SoundContainer != none
						;SexLab.Log(" voice set " + ActorRef.GetLeveledActorBase().GetName() + ", you should not see this after animation end")
						TransitUp(20, 50)
						
						sound mySFX
							
						if FullEnjoyment > 9			;orgasm
							mySFX = (SoundContainer.GetAt(1) As formlist).GetAt(0) As Sound
						elseif IsVictim					;pain
							mySFX = (SoundContainer.GetAt(2) As formlist).GetAt(0) As Sound
						else							;normal
							if (SoundContainer.GetAt(0) As formlist).GetSize() != 10 || JsonUtil.GetIntValue(File, "sl_voice_enjoymentbased") != 1
								FullEnjoyment = 0
							endif
							mySFX = (SoundContainer.GetAt(0) As formlist).GetAt(FullEnjoyment) As Sound
						endif
						
						if JsonUtil.GetIntValue(File, "sl_voice_playandwait") == 1
							mySFX.PlayAndWait(ActorRef)
							;SexLab.Log(self.GetID() - 6 + " SLSO GAME() PW1: " +ActorRef.GetLeveledActorBase().GetName())
						else
							mySFX.Play(ActorRef)
							;SexLab.Log(self.GetID() - 6 + " SLSO GAME() PW2: " +ActorRef.GetLeveledActorBase().GetName())
						endif
						
						TransitDown(50, 20)
					elseif Voice != 0
						SexLab.Log(" smthn wrong " + ActorRef.GetLeveledActorBase().GetName() + " Voice " + Voice + " SoundContainer " + SoundContainer)
					endif
				endif
				
				RegisterForSingleUpdate(1)
				return
			endif
		endif
	endif
	Shutdown()
EndEvent

function TransitUp(int from, int to)
	while from < to
		from += 2
		SetPhonemeModifier(ActorRef, 0, 1, from)
	endWhile
endFunction

function TransitDown(int from, int to)
	while from > to
		from -= 2
		SetPhonemeModifier(ActorRef, 0, 1, from)
	endWhile
endFunction

Function AnimSpeed()
	Float FullEnjoymentMOD
	
	if JsonUtil.GetIntValue(File, "game_animation_speed_control") == 1														;stamina based animation speed
		FullEnjoymentMOD = PapyrusUtil.ClampFloat(ActorSync.GetActorValuePercentage("Stamina")*100/30/3, 0.25, 0.75)
		AnimSpeedHelper.SetAnimationSpeed(ActorRef, FullEnjoymentMOD+0.5, 0.5, 0)
		;SexLab.Log(" SLSO AnimSpeed()(sta) actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " ActorSync to " + ActorSync.GetLeveledActorBase().GetName() + " , speed: ", FullEnjoymentMOD / 3 + 0.5)
	elseif JsonUtil.GetIntValue(File, "game_animation_speed_control") == 2													;enjoyment based animation speed
		FullEnjoymentMOD = PapyrusUtil.ClampFloat(controller.ActorAlias(ActorSync).GetFullEnjoyment()/30/3, 0.25, 0.75)
		AnimSpeedHelper.SetAnimationSpeed(ActorRef, FullEnjoymentMOD+0.5, 0.5, 0)
		;SexLab.Log(" SLSO AnimSpeed()(enjoyment) actor: " + (self.GetID() - 6) + ActorRef.GetLeveledActorBase().GetName() + " ActorSync to " + ActorSync.GetLeveledActorBase().GetName() + " , speed: ", FullEnjoymentMOD / 3 + 0.5)
	endif
EndFunction

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
	;SexLab.Log(" SLSO GAME(): " + (game.GetRealHoursPassed()-bench)*24*60*60 )
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
