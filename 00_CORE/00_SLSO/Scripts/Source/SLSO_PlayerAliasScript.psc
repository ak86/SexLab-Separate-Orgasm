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
	
	self.RegisterForModEvent("SexLabOrgasmSeparate", "Orgasm")
	self.RegisterForModEvent("AnimationStart", "OnSexLabStart")
	self.RegisterForModEvent("AnimationEnd", "OnSexLabEnd")
	self.RegisterForSingleUpdateGameTime(1)								;1 game hour
	self.RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_widget"))
	
	Clear()
	
	;check and reset voices if needed
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
	
endFunction

function Clear()
	int i = 1
	SLSO_MCM SLSO = self.GetOwningQuest() as SLSO_MCM
	while i <= 5
		;clear widget alias
		(self.GetOwningQuest().GetAlias(i)).RegisterForModEvent("SLSO_Stop_widget", "Stop_widget")
		Utility.Wait(1)
		int handle = ModEvent.Create("SLSO_Stop_widget")
		if (handle)
			ModEvent.PushInt(handle, i)
			ModEvent.Send(handle)
		endif
		
		;clear game() alias
		;used to be filled in alias, now its ability
		;((self.GetOwningQuest().GetAlias(i+5) as ReferenceAlias) as SLSO_Game).Shutdown()
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
	Player_orgasms_count = 0
	Player_bonusenjoyment = 0
EndEvent

;----------------------------------------------------------------------------
;SexLab hooks
;----------------------------------------------------------------------------

Event OnSexLabStart(string EventName, string argString, Float argNum, form sender)
	sslThreadController controller = (self.GetOwningQuest() as SLSO_MCM).SexLab.GetController(argString as int)

	if controller.HasPlayer
		int i = 0
		while i < controller.ActorAlias.Length
			if controller.ActorAlias[i].GetActorRef() != none
				;add orgasms to player ince last animation if 1h hasnt passed
				if controller.ActorAlias[i].GetActorRef() == Game.GetPlayer()
					(controller.ActorAlias(Game.GetPlayer()) as sslActorAlias).SetOrgasmCount(Player_orgasms_count)
				endif
				
				;fill widget and game() alias
				(self.GetOwningQuest().GetAlias(i+1) as ReferenceAlias).ForceRefTo(controller.ActorAlias[i].GetActorRef())
;				(self.GetOwningQuest().GetAlias(i+1+5) as ReferenceAlias).ForceRefTo(controller.ActorAlias[i].GetActorRef())
				
				;animation speed and voice abilities
				;attemp to force remove abilities, that may not have finished, if animation fired up right after previous has ended
				controller.ActorAlias[i].GetActorRef().RemoveSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellAnimSync)
				controller.ActorAlias[i].GetActorRef().RemoveSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellVoice)
				controller.ActorAlias[i].GetActorRef().RemoveSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellGame)
				;add abilities
				controller.ActorAlias[i].GetActorRef().AddSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellAnimSync, false)
				controller.ActorAlias[i].GetActorRef().AddSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellVoice, false)
				controller.ActorAlias[i].GetActorRef().AddSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellGame, false)
				
				;start alias widget, game, abilities
				(self.GetOwningQuest().GetAlias(i+1)).RegisterForModEvent("SLSO_Start_widget", "Start_widget")
				(self.GetOwningQuest().GetAlias(i+1)).RegisterForModEvent("SLSO_Stop_widget", "Stop_widget")
				
				;wait 1s for scripts and abilities setup and be ready for events
				;there should be some sort of callback, but fuck that magic, waiting 1 sec is easier
				utility.wait(1)
				
				;push event
				int handle = ModEvent.Create("SLSO_start_widget")
				if (handle)
					ModEvent.PushInt(handle, i+1)
					ModEvent.PushInt(handle, argString as int)
					ModEvent.Send(handle)
				endif
			endif
			i += 1
		endwhile
	else
		int i = 0
		while i < controller.ActorAlias.Length
			if controller.ActorAlias[i].GetActorRef() != none
				;animation speed and voice abilities
				;attemp to force remove abilities, that may not have finished, if animation fired up right after previous has ended
				controller.ActorAlias[i].GetActorRef().RemoveSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellAnimSync)
				controller.ActorAlias[i].GetActorRef().RemoveSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellVoice)
				controller.ActorAlias[i].GetActorRef().RemoveSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellGame)
				;add abilities
				controller.ActorAlias[i].GetActorRef().AddSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellAnimSync, false)
				controller.ActorAlias[i].GetActorRef().AddSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellVoice, false)
				controller.ActorAlias[i].GetActorRef().AddSpell((self.GetOwningQuest() as SLSO_MCM).SLSO_SpellGame, false)
				
				;wait 1s for scripts and abilities setup and be ready for events
				;there should be some sort of callback, but fuck that magic, waiting 1 sec is easier
				utility.wait(1)
				
				;push event
				int handle = ModEvent.Create("SLSO_start_widget")
				if (handle)
					ModEvent.PushInt(handle, i+1)
					ModEvent.PushInt(handle, argString as int)
					ModEvent.Send(handle)
				endif
			endif
			i += 1
		endwhile
	endif
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


Event OnKeyDown(int keyCode)
	If JsonUtil.GetIntValue(File, "hotkey_widget") == keyCode
		If JsonUtil.GetIntValue(File, "widget_enabled") == 1
			JsonUtil.SetIntValue(File, "widget_enabled", 0)
			(self.GetOwningQuest().GetAlias(1) as SLSO_Widget1Update).HideWidget()
			(self.GetOwningQuest().GetAlias(2) as SLSO_Widget2Update).HideWidget()
			(self.GetOwningQuest().GetAlias(3) as SLSO_Widget3Update).HideWidget()
			(self.GetOwningQuest().GetAlias(4) as SLSO_Widget4Update).HideWidget()
			(self.GetOwningQuest().GetAlias(5) as SLSO_Widget5Update).HideWidget()
			
				;actor[] sexActors = new actor[1]
				;sslBaseAnimation[] anims
				;anims = new sslBaseAnimation[1]
				;sexActors[0] = self.GetActorRef()
				;anims[0] = "ZaZAPCHorFA"

			;(self.GetOwningQuest() as SLSO_MCM).SexLab.QuickStart(self.GetActorRef())
		Else
			JsonUtil.SetIntValue(File, "widget_enabled", 1)
		EndIf
	EndIf
EndEvent
