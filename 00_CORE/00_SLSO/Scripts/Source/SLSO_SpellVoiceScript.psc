Scriptname SLSO_SpellVoiceScript extends activemagiceffect

SexLabFramework Property SexLab auto
sslThreadController Property controller auto

String Property File auto
Bool Property IsVictim auto
Bool Property IsPlayer auto
Bool Property IsSilent auto
Bool Property IsFemale auto
Int Property Voice auto
FormList Property SoundContainer auto

Event OnEffectStart( Actor akTarget, Actor akCaster )
	IsPlayer = akTarget == Game.GetPlayer()
	File = "/SLSO/Config.json"
	if ((JsonUtil.GetIntValue(File, "sl_voice_player") != 0 && IsPlayer) || (JsonUtil.GetIntValue(File, "sl_voice_npc") != 0 && !IsPlayer))
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
	
	IsVictim = controller.IsVictim(GetTargetActor())
	IsSilent = controller.ActorAlias(GetTargetActor()).IsSilent()
	IsFemale = controller.ActorAlias(GetTargetActor()).GetGender() == 1

	;check if female and setup voices according to mcm/json options
	if IsFemale
		Voice = 0
		SoundContainer = (Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist
		if SoundContainer.GetSize() > 0
			if IsPlayer																							;PC selected voice
				Voice = JsonUtil.GetIntValue(File, "sl_voice_player")
				SexLab.Log(" SLSO Setup() actor: " + GetTargetActor().GetDisplayName() + " Voice: " +Voice + " PC selected voice")
			elseif JsonUtil.GetIntValue(File, "sl_voice_npc") == -2 && SoundContainer.GetSize() > 0				;NPC random voice
				Voice = Utility.RandomInt(1, (SoundContainer.GetSize()))
				SexLab.Log(" SLSO Setup() actor: " + GetTargetActor().GetDisplayName() + " Voice: " +Voice + " NPC random voice")
			elseif JsonUtil.GetIntValue(File, "sl_voice_npc") == -1 && SoundContainer.GetSize() > 1				;NPC random non PC voice
				while Voice < 1 || Voice == JsonUtil.GetIntValue(File, "sl_voice_player") 
					Voice = Utility.RandomInt(1, (SoundContainer.GetSize()))
					SexLab.Log(" SLSO Setup() actor: " + GetTargetActor().GetDisplayName() + " Voice: " +Voice + " NPC random non PC voice")
				endwhile
			elseif JsonUtil.GetIntValue(File, "sl_voice_npc") > 0												;todo	;NPC selected voice ; or not todo
				Voice = JsonUtil.GetIntValue(File, "sl_voice_npc")
				SexLab.Log(" SLSO Setup() actor: " + GetTargetActor().GetDisplayName() + " Voice: " +Voice + " sl_voice_npc > 0")
			endif
		else
			JsonUtil.SetIntValue(File, "sl_voice_player", 0)
			JsonUtil.SetIntValue(File, "sl_voice_npc", 0)
			Voice = 0
			SexLab.Log(" SLSO Setup() actor: " + GetTargetActor().GetDisplayName() + " no voice packs found")
		endif
		
		if Voice > 0
			SoundContainer = SoundContainer.GetAt(Voice - 1) as formlist
			SexLab.Log(" SLSO Setup() actor: " + GetTargetActor().GetDisplayName() + " Voice: " +Voice + " SoundContainer " + SoundContainer)
		else
			SexLab.Log(" SLSO Setup() actor: " + GetTargetActor().GetDisplayName() + " Voice(0=disabled): " +Voice + " SoundContainer " + SoundContainer)
		endif
	else 
		Voice = 0
		SoundContainer = none
		SexLab.Log(" SLSO Setup() actor: " + GetTargetActor().GetDisplayName() + " is not female, playing sexlab voice")
	endif

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
			if !IsSilent && IsFemale
				if Voice > 0 && SoundContainer != none
					;SexLab.Log(" voice set " + GetTargetActor().GetDisplayName() + ", you should not see this after animation end")
					
					sound mySFX
					Int RawFullEnjoyment = controller.ActorAlias(GetTargetActor()).GetFullEnjoyment()
					Int FullEnjoyment = PapyrusUtil.ClampInt(RawFullEnjoyment/10, 0, 10) + 1
						
					if FullEnjoyment > 9																					;orgasm
						mySFX = (SoundContainer.GetAt(1) As formlist).GetAt(0) As Sound
					elseif IsVictim && FullEnjoyment < JsonUtil.GetIntValue(File, "sl_voice_painswitch")					;pain
						mySFX = (SoundContainer.GetAt(2) As formlist).GetAt(0) As Sound
					else																									;normal
						if (SoundContainer.GetAt(0) As formlist).GetSize() != 10 || JsonUtil.GetIntValue(File, "sl_voice_enjoymentbased") != 1
							FullEnjoyment = 0
						endif
						mySFX = (SoundContainer.GetAt(0) As formlist).GetAt(FullEnjoyment) As Sound
					endif
					

					;if !controller.ActorAlias(GetTargetActor()).IsCreature()
					if Sexlab.Config.UseLipSync
						controller.ActorAlias(GetTargetActor()).GetVoice().TransitUp(GetTargetActor(), 0, 50)
;					else
;						controller.ActorAlias(GetTargetActor()).GetVoice().LipSync(GetTargetActor(), PapyrusUtil.ClampInt(RawFullEnjoyment, 0, 100))
					endif

					if JsonUtil.GetIntValue(File, "sl_voice_playandwait") == 1
						mySFX.PlayAndWait(GetTargetActor())
						;SexLab.Log(" SLSO GAME() PlayAndWait: " +GetTargetActor().GetDisplayName())
					else
						mySFX.Play(GetTargetActor())
						;SexLab.Log(" SLSO GAME() Play: " +GetTargetActor().GetDisplayName())
					endif
					
					if Sexlab.Config.UseLipSync
						controller.ActorAlias(GetTargetActor()).GetVoice().TransitDown(GetTargetActor(), 50, 0)
					endif
					controller.ActorAlias(GetTargetActor()).RefreshExpression()
					RegisterForSingleUpdate(1)
					return
				elseif Voice != 0
					SexLab.Log(" smthn wrong " + GetTargetActor().GetDisplayName() + " Voice " + Voice + " SoundContainer " + SoundContainer)
				endif
			endif
		endif
	endif
	Remove()
EndEvent

Event OnPlayerLoadGame()
	Remove()
EndEvent

Event OnEffectFinish( Actor akTarget, Actor akCaster )
EndEvent

function Remove()
	If GetTargetActor() != none
		UnRegisterForUpdate()
		UnregisterForAllModEvents()
		UnregisterForAllKeys()
		SLSO_MCM SLSO = Quest.GetQuest("SLSO") as SLSO_MCM
		If GetTargetActor().HasSpell(SLSO.SLSO_SpellVoice)
			GetTargetActor().RemoveSpell(SLSO.SLSO_SpellVoice)
		EndIf
	EndIf
endFunction
