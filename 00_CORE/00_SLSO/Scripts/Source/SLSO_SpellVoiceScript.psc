Scriptname SLSO_SpellVoiceScript extends activemagiceffect

import MfgConsoleFunc

SexLabFramework SexLab
sslThreadController controller

Actor ActorRef
String File
Bool IsVictim
Bool IsPlayer
Bool IsSilent
Bool IsFemale
Int Voice
FormList SoundContainer

Event OnEffectStart( Actor akTarget, Actor akCaster )
	IsPlayer = akTarget == Game.GetPlayer()
	if ((JsonUtil.GetIntValue(File, "sl_voice_player") == 0 && IsPlayer) || (JsonUtil.GetIntValue(File, "sl_voice_npc") == 0 && !IsPlayer))
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
	
	IsVictim = controller.IsVictim(ActorRef)
	IsSilent = controller.ActorAlias(ActorRef).IsSilent()
	IsFemale = controller.ActorAlias(ActorRef).GetGender() == 1

	;check if female and setup voices according to mcm/json options
	if IsFemale
		Voice = 0
		SoundContainer = (Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist
		if SoundContainer.GetSize() > 0
			if IsPlayer																							;PC selected voice
				Voice = JsonUtil.GetIntValue(File, "sl_voice_player")
				SexLab.Log(" SLSO Setup() actor: " + ActorRef.GetLeveledActorBase().GetName() + " Voice: " +Voice + " PC selected voice")
			elseif JsonUtil.GetIntValue(File, "sl_voice_npc") == -2 && SoundContainer.GetSize() > 0				;NPC random voice
				Voice = Utility.RandomInt(1, (SoundContainer.GetSize()))
				SexLab.Log(" SLSO Setup() actor: " + ActorRef.GetLeveledActorBase().GetName() + " Voice: " +Voice + " NPC random voice")
			elseif JsonUtil.GetIntValue(File, "sl_voice_npc") == -1 && SoundContainer.GetSize() > 1				;NPC random non PC voice
				while Voice < 1 || Voice == JsonUtil.GetIntValue(File, "sl_voice_player") 
					Voice = Utility.RandomInt(1, (SoundContainer.GetSize()))
					SexLab.Log(" SLSO Setup() actor: " + ActorRef.GetLeveledActorBase().GetName() + " Voice: " +Voice + " NPC random non PC voice")
				endwhile
			elseif JsonUtil.GetIntValue(File, "sl_voice_npc") > 0												;todo	;NPC selected voice ; or not todo
				Voice = JsonUtil.GetIntValue(File, "sl_voice_npc")
				SexLab.Log(" SLSO Setup() actor: " + ActorRef.GetLeveledActorBase().GetName() + " Voice: " +Voice + " sl_voice_npc > 0")
			endif
		else
			JsonUtil.SetIntValue(File, "sl_voice_player", 0)
			JsonUtil.SetIntValue(File, "sl_voice_npc", 0)
			Voice = 0
			SexLab.Log(" SLSO Setup() actor: " + ActorRef.GetLeveledActorBase().GetName() + " no voice packs found")
		endif
		
		if Voice > 0
			SoundContainer = SoundContainer.GetAt(Voice - 1) as formlist
			SexLab.Log(" SLSO Setup() actor: " + ActorRef.GetLeveledActorBase().GetName() + " Voice: " +Voice + " SoundContainer " + SoundContainer)
		else
			SexLab.Log(" SLSO Setup() actor: " + ActorRef.GetLeveledActorBase().GetName() + " Voice(0=disabled): " +Voice + " SoundContainer " + SoundContainer)
		endif
	else 
		Voice = 0
		SoundContainer = none
		SexLab.Log(" SLSO Setup() actor: " + ActorRef.GetLeveledActorBase().GetName() + " is not female, playing sexlab voice")
	endif

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
			if !IsSilent && IsFemale
				if Voice > 0 && SoundContainer != none
					;SexLab.Log(" voice set " + ActorRef.GetLeveledActorBase().GetName() + ", you should not see this after animation end")
					TransitUp(20, 50)
					
					sound mySFX
					Int RawFullEnjoyment = controller.ActorAlias(ActorRef).GetFullEnjoyment()
					Int FullEnjoyment = PapyrusUtil.ClampInt(RawFullEnjoyment/10, 0, 10) + 1
						
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
						;SexLab.Log(" SLSO GAME() PlayAndWait: " +ActorRef.GetLeveledActorBase().GetName())
					else
						mySFX.Play(ActorRef)
						;SexLab.Log(" SLSO GAME() Play: " +ActorRef.GetLeveledActorBase().GetName())
					endif
					
					TransitDown(50, 20)
					RegisterForSingleUpdate(1)
					return
				elseif Voice != 0
					SexLab.Log(" smthn wrong " + ActorRef.GetLeveledActorBase().GetName() + " Voice " + Voice + " SoundContainer " + SoundContainer)
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

function Remove()
	If ActorRef != none
		SLSO_MCM SLSO = Quest.GetQuest("SLSO") as SLSO_MCM
		ActorRef.RemoveSpell(SLSO.SLSO_SpellVoice)
	endIf
endFunction
