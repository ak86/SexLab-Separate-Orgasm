scriptname SLSO_VoicePackInstallerScript extends ReferenceAlias
{SLSO_VoicePackInstaller script}

FormList Property This_VoiceSet Auto

;=============================================================
;INIT
;=============================================================

Event OnInit()
	RegisterForSingleUpdate(10)
EndEvent

Event OnPlayerLoadGame()
	RegisterForSingleUpdate(10)
EndEvent

Event OnUpdate()
	FormList SLSO_VoicesSets = (Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist

	If !SLSO_VoicesSets.HasForm(This_VoiceSet)
		SLSO_VoicesSets.AddForm(This_VoiceSet)
		;Debug.Notification("SLSO: addEd " + This_VoiceSet.GetFormID() + " voice set.")
	EndIf
	
	FormList SLSO_VoicesSetsQuests = (Game.GetFormFromFile(0x63A3, "SLSO.esp") as formlist).GetAt(1) as formlist
	If !SLSO_VoicesSetsQuests.HasForm(self.GetOwningQuest())
		SLSO_VoicesSetsQuests.AddForm(self.GetOwningQuest())
		Debug.Notification("SLSO: addEd " + self.GetOwningQuest().GetName() + " voice set.")
	EndIf
EndEvent