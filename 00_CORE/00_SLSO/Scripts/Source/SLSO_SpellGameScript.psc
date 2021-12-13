Scriptname SLSO_SpellGameScript Extends activemagiceffect

SexLabFramework Property SexLab auto
sslThreadController Property controller auto

String Property File auto
Bool Property IsAggressor auto
Bool Property IsVictim auto
Bool Property IsFemale auto
Bool Property MentallyBroken auto
Bool Property Forced auto
Bool Property PauseGame auto
Actor Property PartnerReference auto
Float Property Vibrate auto
float Property GetModSelfSta auto
float Property GetModSelfMag auto
float Property GetModPartSta auto
float Property GetModPartMag auto
int Property Position auto
int Property RelationshipRank auto

Event OnEffectStart( Actor akTarget, Actor akCaster )
	File = "/SLSO/Config.json"
	SexLab = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
	RegisterForModEvent("SLSO_Start_widget", "Start_widget")
	RegisterForModEvent("AnimationEnd", "OnSexLabEnd")
	RegisterKey(JsonUtil.GetIntValue(File, "hotkey_pausegame"))
EndEvent

Event Start_widget(Int Widget_Id, Int Thread_Id)
	UnregisterForModEvent("SLSO_Start_widget")

	controller = SexLab.GetController(Thread_Id)
	
	;check if game enabled
	if JsonUtil.GetIntValue(File, "game_enabled") == 1 && (controller.HasPlayer || JsonUtil.GetIntValue(File, "game_npc_enabled", 0) == 1)
		PauseGame = false
		IsAggressor = controller.IsAggressor(GetTargetActor())
		IsVictim = controller.IsVictim(GetTargetActor())
		IsFemale = controller.ActorAlias(GetTargetActor()).GetGender() == 1
		
		GetModSelfSta = GetMod("Stamina", GetTargetActor())
		GetModSelfMag = GetMod("Magicka", GetTargetActor())
		Position  = controller.Positions.Find(GetTargetActor())
		RelationshipRank = controller.GetLowestPresentRelationshipRank(GetTargetActor())

		;SexLab.Log("SLSO partner OLD pre: " + PartnerReference.GetDisplayName())
		;if controller.ActorCount > 1
		;	PartnerReference = controller.ActorAlias(controller.Positions[sslUtility.IndexTravel(controller.Positions.Find(GetTargetActor()), controller.ActorCount)]).GetActorRef()
		;	;GetModPartSta = GetMod("Stamina", PartnerReference)
		;	;GetModPartMag = GetMod("Magicka", PartnerReference) 
		;endif
		;SexLab.Log("SLSO partner OLD post: " + PartnerReference.GetDisplayName())
		
		Change_Partner()
		
		if controller.ActorAlias(GetTargetActor()).GetActorRef() == Game.GetPlayer()
;			SexLab.Log(" SLSO Setup() Player, enabling hotkeys")
			RegisterKey(JsonUtil.GetIntValue(File, "hotkey_edge"))
			RegisterKey(JsonUtil.GetIntValue(File, "hotkey_orgasm"))
			RegisterKey(JsonUtil.GetIntValue(File, "hotkey_bonusenjoyment"))
			RegisterKey(JsonUtil.GetIntValue(File, "hotkey_select_actor_1"))
			RegisterKey(JsonUtil.GetIntValue(File, "hotkey_select_actor_2"))
			RegisterKey(JsonUtil.GetIntValue(File, "hotkey_select_actor_3"))
			RegisterKey(JsonUtil.GetIntValue(File, "hotkey_select_actor_4"))
			RegisterKey(JsonUtil.GetIntValue(File, "hotkey_select_actor_5"))
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
			If JsonUtil.GetIntValue(File, "game_enabled") == 1 && !PauseGame
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
	;return Stamina 0..6 							increases enjoyment, increases magicka damage(mentalbreak)
	;return Magicka -6..+6							-6= pure, reduce own magicka action cost/mentalbreak damage; +6 lewd, increase own magicka action cost/mentalbreak damage
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
					;SexLab.Log("raise enjoyment self: " + GetTargetActor().GetDisplayName())
					ModEnjoyment(GetTargetActor(), mod, FullEnjoymentMOD)
					PartnerRef = GetTargetActor()
				;partner
				elseif controller.ActorCount > 1
					;SexLab.Log("raise enjoyment partner: " + PartnerReference.GetDisplayName())
					ModEnjoyment(PartnerReference, mod, FullEnjoymentMOD)
					PartnerRef = PartnerReference
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
				if GetTargetActor().GetActorValuePercentage("Magicka") > 0.10
					GetTargetActor().DamageActorValue("Magicka", GetTargetActor().GetBaseActorValue("Magicka")/(10-mod)*0.5)
					controller.ActorAlias(GetTargetActor()).HoldOut()
				endif
			;partner
			elseif controller.ActorCount > 1
				mod = GetModSelfSta
				if GetTargetActor().GetActorValuePercentage("Stamina") > 0.10
					GetTargetActor().DamageActorValue("Stamina", GetTargetActor().GetBaseActorValue("Stamina")/(10+mod)*0.5)
					controller.ActorAlias(PartnerReference).HoldOut()
					PartnerRef = PartnerReference
				endif
			endif
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
					PartnerRef = GetTargetActor()
				
				;rough sex, nautrals-lovers
				else
				;not broken, pleasure self
					if GetTargetActor().GetActorValuePercentage("Magicka") > 0.10 || controller.ActorCount > 2
						ModEnjoyment(GetTargetActor(), mod, FullEnjoymentMOD)
						PartnerRef = GetTargetActor()
				;mental broken, pleasure partner
					else
						ModEnjoyment(PartnerReference, mod, FullEnjoymentMOD)
						PartnerRef = PartnerReference
					EndIf
				EndIf
			Else
				;not aggressor
				
				;mentally not broken, pleasure self
				if GetTargetActor().GetActorValuePercentage("Magicka") > 0.10 || controller.ActorCount > 2
					;pleasure self if self priority
					;lewdness based check
					if (Utility.RandomInt(0, 100) < SexLab.Stats.GetSkillLevel(GetTargetActor(), "Lewd", 0.3)*10*1.5) && JsonUtil.GetIntValue(File, "game_pleasure_priority") == 1
						ModEnjoyment(GetTargetActor(), mod, FullEnjoymentMOD)
						PartnerRef = GetTargetActor()
				
					;relationship based check
					;try to pleasure other actor
					elseif (Utility.RandomInt(0, 100) < (25+controller.GetHighestPresentRelationshipRank(GetTargetActor())*10*2)) && controller.ActorCount == 2
						ModEnjoyment(PartnerReference, mod, FullEnjoymentMOD)
						PartnerRef = PartnerReference
					
					;pleasure self if partner priority
					;lewdness based check
					elseif (Utility.RandomInt(0, 100) < SexLab.Stats.GetSkillLevel(GetTargetActor(), "Lewd", 0.3)*10*1.5) && JsonUtil.GetIntValue(File, "game_pleasure_priority") == 0
						ModEnjoyment(GetTargetActor(), mod, FullEnjoymentMOD)
						PartnerRef = GetTargetActor()

					EndIf
					
				;mentally broken, pleasure partner
				else
					MentallyBroken = true
					ModEnjoyment(PartnerReference, mod, FullEnjoymentMOD)
					PartnerRef = PartnerReference
				EndIf
			EndIf
		EndIf
		
		mod = GetModSelfMag
		
		;try to hold out orgasm especially if high relation with partner
		If JsonUtil.GetIntValue(File, "game_edging") == 1
			If GetTargetActor().GetActorValuePercentage("Magicka") > 0.10 && (Utility.RandomInt(0, 100) < (25+controller.GetHighestPresentRelationshipRank(GetTargetActor())*10*2) && controller.ActorCount == 2)
				If controller.ActorAlias(GetTargetActor()).GetFullEnjoyment() as float > 95
					GetTargetActor().DamageActorValue("Magicka", GetTargetActor().GetBaseActorValue("Magicka")/(10-mod)) 
					controller.ActorAlias(GetTargetActor()).HoldOut(3)
					PartnerRef = GetTargetActor()
				EndIf
			EndIf
		EndIf
	endif
	
	MentalBreak(PartnerRef)
	
	;DD vibrations
	If Vibrate > 0
		GetTargetActor().DamageActorValue("Stamina", GetTargetActor().GetBaseActorValue("Stamina")/(10-GetModSelfMag+FullEnjoymentMOD))
		controller.ActorAlias(GetTargetActor()).BonusEnjoyment(GetTargetActor(), Vibrate as Int)
		MentalBreak(GetTargetActor())
	EndIf
	
	;EC forced masturbation
	If Forced
		GetTargetActor().DamageActorValue("Stamina", GetTargetActor().GetBaseActorValue("Stamina")/(10-GetModSelfMag+FullEnjoymentMOD))
		controller.ActorAlias(GetTargetActor()).BonusEnjoyment(GetTargetActor(), 1)
		MentalBreak(GetTargetActor())
	EndIf

	;skip to last animation stage if male actor:
	;out of sta(not aggressor)
	;or
	;orgasmed
	;and
	;solo or duo anim
	If ((JsonUtil.GetIntValue(File, "game_no_sta_endanim") == 1 && GetTargetActor().GetActorValuePercentage("Stamina") < 0.10 && !IsAggressor)\
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
	if PartnerRef != none
		if mod < 3 && Utility.RandomInt(0, 100) < (3 - mod) * 10 && JsonUtil.GetIntValue(File, "game_enjoyment_reduction_chance") == 1
			controller.ActorAlias(GetTargetActor()).BonusEnjoyment(PartnerRef, -1)
		else
			controller.ActorAlias(GetTargetActor()).BonusEnjoyment(PartnerRef)
		endif
	else	
		SexLab.Log(" SLSO GAME():ModEnjoyment: something wrong, PartnerRef is none")
	endif
EndFunction

Function MentalBreak(Actor PartnerRef)
	;damage actor magicka/mental break
	if PartnerRef != none
			;1% * (base dmg(10) + own skill(0-6) + partner lewdness(-6+6)) * partner enjoyment% * orgasms(1+)
			;PartnerRef.DamageActorValue("Magicka", \
			;	PartnerRef.GetBaseActorValue("Magicka")/100\
			;		*(10-GetModSelfSta+GetMod("Magicka",PartnerRef)/100)\
			;		*(controller.ActorAlias(PartnerRef) as sslActorAlias).GetFullEnjoyment()/100\
			;		*(1+(controller.ActorAlias(PartnerRef) as sslActorAlias).GetOrgasmCount()))
		PartnerRef.DamageActorValue("Magicka", PartnerRef.GetBaseActorValue("Magicka")/100*(10-GetModSelfSta+GetMod("Magicka",PartnerRef)/100)*((controller.ActorAlias(PartnerRef) as sslActorAlias).GetFullEnjoyment() as float)/100*(1+(controller.ActorAlias(PartnerRef) as sslActorAlias).GetOrgasmCount())*0.5)
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
		If GetTargetActor().HasSpell(SLSO.SLSO_SpellGame)
			GetTargetActor().RemoveSpell(SLSO.SLSO_SpellGame)
		EndIf
	EndIf
EndFunction

Function Change_Partner(int partnerid = 0)
	partnerid = partnerid - 1
	Actor PartnerReference1
	;SexLab.Log("SLSO is victim: " + GetTargetActor().GetDisplayName() +" " + IsVictim)
	;SexLab.Log("SLSO partner pre: " + PartnerReference.GetDisplayName())
	if controller.ActorCount > 1
		if partnerid < 0
			;SexLab.Log("Change_Partner initial setup " + partnerid)
			PartnerReference = controller.ActorAlias(controller.Positions[sslUtility.IndexTravel(controller.Positions.Find(GetTargetActor()), controller.ActorCount)]).GetActorRef()
			if controller.ActorAlias(GetTargetActor()).GetActorRef() == Game.GetPlayer()
				SexLab.Log("SLSO " + GetTargetActor().GetDisplayName() + "'s current partner is " + PartnerReference.GetDisplayName())
			endif
		else
			PartnerReference1 = controller.ActorAlias[partnerid].GetActorRef()
			;SexLab.Log("Change_Partner change partner " + PartnerReference1.GetDisplayName())
			if PartnerReference1 == none || PartnerReference1 == PartnerReference || PartnerReference1 == GetTargetActor() || PartnerReference1 == Game.GetPlayer()
				return
			endif
			PartnerReference = PartnerReference1
			;SexLab.Log("Change_Partner partner changed to: " + PartnerReference.GetDisplayName() + " pos (" + partnerid + ")")
			if controller.ActorAlias(GetTargetActor()).GetActorRef() == Game.GetPlayer()
				SexLab.Log("SLSO " + GetTargetActor().GetDisplayName() + " changed focus to " + PartnerReference.GetDisplayName())
				Debug.Notification(GetTargetActor().GetDisplayName() + " changed partner to " + PartnerReference.GetDisplayName())
			endif
		endif
		;SexLab.Log("Change_Partner partner set to: " + PartnerReference.GetDisplayName() + " pos (" + partnerid + ")")
		GetModPartSta = GetMod("Stamina", PartnerReference)
		GetModPartMag = GetMod("Magicka", PartnerReference) 
		int handle = ModEvent.Create("SLSO_Change_Partner")
		if (handle)
			ModEvent.PushForm(handle, PartnerReference)
			ModEvent.Send(handle)
		endif
	endif
	;SexLab.Log("SLSO partner post: " + PartnerReference.GetDisplayName())
EndFunction

;----------------------------------------------------------------------------
;DD events
;----------------------------------------------------------------------------
Event OnVibrateStart(string eventName, string argString, float argNum, form sender)
	If argString == GetTargetActor().GetDisplayName()
		Vibrate = argNum
	EndIf
EndEvent

Event OnVibrateStop(string eventName, string argString, float argNum, form sender)
	If argString == GetTargetActor().GetDisplayName()
		Vibrate = 0
	EndIf
EndEvent

;----------------------------------------------------------------------------
;Hotkeys
;----------------------------------------------------------------------------
Function RegisterKey(int RKey = 0)
	If (RKey != 0)
		self.RegisterForKey(RKey)
	EndIf
EndFunction

Event OnKeyDown(int keyCode)
	if !Utility.IsInMenuMode()
		if controller.ActorAlias(GetTargetActor()).GetActorRef() != none
			If JsonUtil.GetIntValue(File, "hotkey_pausegame") == keyCode && Input.IsKeyPressed(JsonUtil.GetIntValue(File, "hotkey_utility"))
				if PauseGame
					PauseGame = false
					Debug.Notification("SLSO game paused: " + PauseGame)
				else
					PauseGame = true
					Debug.Notification("SLSO game paused: " + PauseGame)
				endif
			ElseIf JsonUtil.GetIntValue(File, "game_enabled") == 1
				;Debug.Notification("SLSO OnKeyDown : " + keyCode)
				If JsonUtil.GetIntValue(File, "hotkey_bonusenjoyment") == keyCode
					Game("Stamina")
;				ElseIf JsonUtil.GetIntValue(File, "hotkey_orgasm") == keyCode
;					if Input.IsKeyPressed(JsonUtil.GetIntValue(File, "hotkey_utility"))
;						controller.ActorAlias(GetTargetActor()).Orgasm(0)		;normal orgasm, >90 enjoyment
;					endif
;				ElseIf JsonUtil.GetIntValue(File, "hotkey_orgasm") == keyCode
;					if Input.IsKeyPressed(JsonUtil.GetIntValue(File, "hotkey_utility"))
;						controller.ActorAlias(GetTargetActor()).Orgasm(-2)		;forced orgasm, skip slso checks
;					endif
				ElseIf JsonUtil.GetIntValue(File, "hotkey_edge") == keyCode
					Game("Magicka")
				ElseIf Input.IsKeyPressed(JsonUtil.GetIntValue(File, "hotkey_utility"))
					;If !IsVictim
						If JsonUtil.GetIntValue(File, "hotkey_select_actor_1") == keyCode
							Change_Partner(1)
						ElseIf JsonUtil.GetIntValue(File, "hotkey_select_actor_2") == keyCode
							Change_Partner(2)
						ElseIf JsonUtil.GetIntValue(File, "hotkey_select_actor_3") == keyCode
							Change_Partner(3)
						ElseIf JsonUtil.GetIntValue(File, "hotkey_select_actor_4") == keyCode
							Change_Partner(4)
						ElseIf JsonUtil.GetIntValue(File, "hotkey_select_actor_5") == keyCode
							Change_Partner(5)
						EndIf
					;EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndEvent
