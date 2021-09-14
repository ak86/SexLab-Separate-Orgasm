scriptname SLSO_PlayerAliasScript extends ReferenceAlias
{SLSO_PlayerAliasScript script}

int Player_orgasms_count
int Player_bonusenjoyment
String File

;=============================================================
;INIT
;=============================================================

Event OnInit()
	Maintenance()
EndEvent

Event OnPlayerLoadGame()
	Maintenance()
EndEvent

function Maintenance()
	File = "/SLSO/Config.json"
	if JsonUtil.GetErrors(File) != ""
		Debug.Messagebox("SLSO Json has errors, mod wont work")
		return
	endif
	
	;register events
	self.RegisterForModEvent("SexLabOrgasmSeparate", "Orgasm")
	self.RegisterForModEvent("AnimationStart", "OnSexLabStart")
	self.RegisterForModEvent("AnimationEnd", "OnSexLabEnd")
	self.RegisterForSingleUpdateGameTime(1)								;1 game hour
	RegisterKey(JsonUtil.GetIntValue(File, "hotkey_widget"))
	
	Clear()
	
	;check and reset normal voices if needed
	if	((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist).GetSize() > 0
		int i = 0
		while i < ((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist).GetSize()
			if ((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist).GetAt(i) == none
				((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist).Revert()
				((Game.GetFormFromFile(0x63A3, "SLSO.esp") as formlist).GetAt(1) as formlist).Revert()
				JsonUtil.SetIntValue(File, "sl_voice_player", 0)
				JsonUtil.SetIntValue(File, "sl_voice_npc", 0)
				return
			endif
		i = i + 1
		endwhile
	endif
	
	;check and reset victim voices if needed
	if	((Game.GetFormFromFile(0x7935, "SLSO.esp") as formlist).GetAt(1) as formlist).GetSize() > 0
		int i = 0
		while i < ((Game.GetFormFromFile(0x7935, "SLSO.esp") as formlist).GetAt(1) as formlist).GetSize()
			if ((Game.GetFormFromFile(0x7935, "SLSO.esp") as formlist).GetAt(1) as formlist).GetAt(i) == none
				((Game.GetFormFromFile(0x7935, "SLSO.esp") as formlist).GetAt(1) as formlist).Revert()
				((Game.GetFormFromFile(0x7938, "SLSO.esp") as formlist).GetAt(1) as formlist).Revert()
				;JsonUtil.SetIntValue(File, "sl_voice_player", 0)
				;JsonUtil.SetIntValue(File, "sl_voice_npc", 0)
				return
			endif
		i = i + 1
		endwhile
	endif
	
endFunction

function Clear()
	int i = 1
	SLSO_MCM SLSO = self.GetOwningQuest() as SLSO_MCM
	while i <= 5
		;clear widget alias
		(self.GetOwningQuest().GetAlias(i)).RegisterForModEvent("SLSO_Stop_widget", "Stop_widget")
		int handle = ModEvent.Create("SLSO_Stop_widget")
		if (handle)
			ModEvent.PushInt(handle, i)
			ModEvent.Send(handle)
		endif
		i += 1
	endwhile
endFunction

Event Orgasm(Form ActorRef, Int Thread)
	if (ActorRef as actor) == Game.GetPlayer()
		Player_orgasms_count = (self.GetOwningQuest() as SLSO_MCM).SexLab.GetController(Thread).ActorAlias(ActorRef as actor).GetOrgasmCount()
		self.RegisterForSingleUpdateGameTime(1)
	endif
EndEvent

Event OnUpdateGameTime()
	;reset orgasms and enjoyment after 1 hour
	Player_orgasms_count = 0
	Player_bonusenjoyment = 0
EndEvent

;----------------------------------------------------------------------------
;SexLab hooks
;----------------------------------------------------------------------------

Event OnSexLabStart(string EventName, string argString, Float argNum, form sender)
	sslThreadController controller = (self.GetOwningQuest() as SLSO_MCM).SexLab.GetController(argString as int)

	;if thread has player, enable widgets
	int i = 0
	if controller.HasPlayer
		while i < controller.ActorAlias.Length
			if controller.ActorAlias[i].GetActorRef() != none
				;add orgasms to player ince last animation if 1h hasnt passed
				if controller.ActorAlias[i].GetActorRef() == Game.GetPlayer()
					(controller.ActorAlias(Game.GetPlayer()) as sslActorAlias).SetOrgasmCount(Player_orgasms_count)
				endif
				
				;fill widget and game() alias
				(self.GetOwningQuest().GetAlias(i+1) as ReferenceAlias).ForceRefTo(controller.ActorAlias[i].GetActorRef())
				
				;start alias widget
				(self.GetOwningQuest().GetAlias(i+1)).RegisterForModEvent("SLSO_Start_widget", "Start_widget")
			endif
			i += 1
		endwhile
		i = 0
	endif
	
	;add game, voice, animsync abilities and start everything
	while i < controller.ActorAlias.Length
		if controller.ActorAlias[i].GetActorRef() != none
			;game, animation speed and voice abilities
			;attemp to force remove abilities, that may not have finished, if animation fired up right after previous has ended
			controller.ActorAlias[i].GetActorRef().RemoveSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellAnimSync)
			controller.ActorAlias[i].GetActorRef().RemoveSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellVoice)
			controller.ActorAlias[i].GetActorRef().RemoveSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellGame)
			
			;add fresh abilities
			controller.ActorAlias[i].GetActorRef().AddSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellAnimSync, false)
			controller.ActorAlias[i].GetActorRef().AddSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellVoice, false)
			controller.ActorAlias[i].GetActorRef().AddSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellGame, false)
			
			;wait 1s for scripts and abilities setup and be ready for events
			;there should be some sort of callback, but fuck that magic, waiting 1 sec is easier
			utility.wait(1)
			
			;push event to start everything
			int handle = ModEvent.Create("SLSO_start_widget")
			if (handle)
				ModEvent.PushInt(handle, i+1)
				ModEvent.PushInt(handle, argString as int)
				ModEvent.Send(handle)
			endif
		endif
		i += 1
	endwhile
EndEvent

Event OnSexLabEnd(string EventName, string argString, Float argNum, form sender)
	sslThreadController controller = (self.GetOwningQuest() as SLSO_MCM).SexLab.GetController(argString as int)

	if controller.HasPlayer
		;clear player orgasms in 1h(for non separate orgasms option)
		self.RegisterForSingleUpdateGameTime(1)
		;clear alias widget, abilities
		Clear()
	endif
EndEvent


Function RegisterKey(int RKey = 0)
	If (RKey != 0)
		self.RegisterForKey(RKey)
	EndIf
EndFunction

Event OnKeyDown(int keyCode)
	If !Utility.IsInMenuMode()
		If JsonUtil.GetIntValue(File, "hotkey_widget") == keyCode && Input.IsKeyPressed(JsonUtil.GetIntValue(File, "hotkey_utility"))
			If JsonUtil.GetIntValue(File, "widget_enabled") == 1
				JsonUtil.SetIntValue(File, "widget_enabled", 0)
				(self.GetOwningQuest().GetAlias(1) as SLSO_Widget1Update).HideWidget()
				(self.GetOwningQuest().GetAlias(2) as SLSO_Widget2Update).HideWidget()
				(self.GetOwningQuest().GetAlias(3) as SLSO_Widget3Update).HideWidget()
				(self.GetOwningQuest().GetAlias(4) as SLSO_Widget4Update).HideWidget()
				(self.GetOwningQuest().GetAlias(5) as SLSO_Widget5Update).HideWidget()
			Else
				JsonUtil.SetIntValue(File, "widget_enabled", 1)
			EndIf
		EndIf
	EndIf
EndEvent
