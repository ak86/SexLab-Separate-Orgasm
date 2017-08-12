Scriptname SLSO_Widget5Update Extends ReferenceAlias

SLSO_WidgetCoreScript5 Property Widget Auto

SexLabFramework SexLab
sslThreadController controller

String File
String widgetid
String ActorName
String EnjoymentValue
Float LastTimeFlash
Int BaseColor = 0xFFFFFF	 	; white
Int Gender = 0
Bool Display_widget = true

;----------------------------------------------------------------------------
;Widget Setup
;----------------------------------------------------------------------------

Event OnInit()
	HideWidget()
	File = "/SLSO/Config.json"
	widgetid = "widget" + self.GetID()
EndEvent

Event Start_widget(Int Widget_Id, Int Thread_Id)
	if Widget_Id == self.GetID()
		SexLab = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
		controller = SexLab.GetController(Thread_Id)
		((self.GetOwningQuest().GetAlias(self.GetID()+5) as ReferenceAlias) as SLSO_Game).Setup(Thread_Id)
		StartWidget()
	endif
EndEvent

Event Stop_widget(Int Widget_Id)
	if Widget_Id == self.GetID()
		StopWidget()
	endif
EndEvent

Function StartWidget()
	UpdateWidgetPosition()
EndFunction

Function StopWidget()
	((self.GetOwningQuest().GetAlias(self.GetID()+5) as ReferenceAlias) as SLSO_Game).Shutdown()
	UnregisterForAllKeys()
	UnRegisterForUpdate()
	HideWidget()
	(self as ReferenceAlias).Clear()
EndFunction

Function ShowWidget()
	Widget.Alpha = 100.0
EndFunction

Function HideWidget()
	Widget.Alpha = 0.0
EndFunction

Function UpdateWidgetPosition()
	Actor ActorRef = self.GetActorRef() 
	If ActorRef != none
		;female
		If controller.ActorAlias(ActorRef).GetGender() == 1
			BaseColor = JsonUtil.StringListGet(File, "widgetcolors", 5) as int
			Gender = 1
		;male
		Else
			BaseColor = JsonUtil.StringListGet(File, "widgetcolors", 4) as int
			Gender = 0
		EndIf
	Else
		BaseColor = 0xFFFFFF
	EndIf
	if ((JsonUtil.GetIntValue(File, "widget_player_only") == 1 && self.GetActorRef() == Game.Getplayer()) || JsonUtil.GetIntValue(File, "widget_player_only") != 1)
		Display_widget = true
	else
		Display_widget = false
	endif
	;Widget.Width = JsonUtil.GetFloatValue(File, "widget_width")
	;Widget.Height = JsonUtil.GetFloatValue(File, "widget_height")
	Widget.X = JsonUtil.StringListGet(File, widgetid, 1) as Float
	Widget.Y = JsonUtil.StringListGet(File, widgetid, 2) as Float
	Widget.MeterFillMode = JsonUtil.StringListGet(File, widgetid, 3)
	Widget.SetMeterPercent(0.0)
	Widget.BorderAlpha = JsonUtil.GetFloatValue(File, "widget_borderalpha")
	Widget.BackgroundAlpha = JsonUtil.GetFloatValue(File, "widget_backgroundalpha")
	Widget.MeterAlpha = JsonUtil.GetFloatValue(File, "widget_meteralpha")
	Widget.MeterScale = JsonUtil.GetFloatValue(File, "widget_meterscale")
	Widget.LabelTextSize = JsonUtil.GetFloatValue(File, "widget_labeltextsize")
	Widget.ValueTextSize = JsonUtil.GetFloatValue(File, "widget_valuetextsize")
	ActorName = self.GetActorRef().GetLeveledActorBase().GetName()
	if JsonUtil.GetIntValue(File, "widget_show_enjoymentmodifier") == 1
		EnjoymentValue = "0.00%"
	else
		EnjoymentValue = ""
	endif
	Widget.SetTexts(ActorName, EnjoymentValue)
	LastTimeFlash = game.GetRealHoursPassed()
	RegisterForSingleUpdate(1)
EndFunction

;----------------------------------------------------------------------------
;Widget update Loop
;----------------------------------------------------------------------------

Event OnUpdate()
	If JsonUtil.StringListGet(File, widgetid, 0) == "on"\
	&& JsonUtil.GetIntValue(File, "widget_enabled") == 1\
	&& Display_widget
		ShowWidget()
	Else
		HideWidget()
	EndIf
	
	Actor ActorRef = self.GetActorRef() 
	If ActorRef != none
		if controller.ActorAlias(ActorRef).GetActorRef() != none
			if controller.ActorAlias(ActorRef).GetState() == "Animating"
				If JsonUtil.GetIntValue(File, "widget_enabled") == 1
					UpdateWidget(ActorRef, controller.ActorAlias(ActorRef).GetFullEnjoyment() as float)
				EndIf
				If JsonUtil.GetIntValue(File, "game_passive_enjoyment_reduction") == 1
					controller.ActorAlias(ActorRef).BonusEnjoyment(self.GetActorRef(), -1)
				EndIf
				RegisterForSingleUpdate(1)
			else
				StopWidget()
			endif
		else
			StopWidget()
		endif
	endif
	;cant be like in SLSO_Game cuz widget is should be shown after mcm XY edit 
	;StopWidget()
EndEvent

Function UpdateWidget(Actor akActor, Float Enjoyment)
	If akActor == none
		return
	EndIf
	if EnjoymentValue != ""
		EnjoymentValue = "E:" + StringUtil.Substring(controller.ActorAlias(self.GetActorRef()).GetFullEnjoymentMod(), 0, 5) + "%"
	endif
	Widget.SetTexts(ActorName, EnjoymentValue)
	Enjoyment /= 100
	If Enjoyment >= 0.75
		Widget.SetMeterColors(BaseColor, JsonUtil.StringListGet(File, "widgetcolors", 1) as int)
	ElseIf Enjoyment >= 0.50
		Widget.SetMeterColors(BaseColor, JsonUtil.StringListGet(File, "widgetcolors", 2) as int)
	ElseIf Enjoyment >= 0.25
		Widget.SetMeterColors(BaseColor, JsonUtil.StringListGet(File, "widgetcolors", 3) as int)
	Else
		Widget.SetMeterColors(BaseColor, BaseColor)
	EndIf
	If Enjoyment > 1
		Enjoyment = 1
	EndIf
	Widget.SetMeterPercent(Enjoyment*100)
	If Enjoyment >= 0.90
		GetCurrentHourOfDay()		;flash
	EndIf
EndFunction

Function GetCurrentHourOfDay()
	float Time = game.GetRealHoursPassed() 		; days spend in game
;	Time *= 24 									; hours spend in game
;	Time *= 60 									; minutes spend in game
;	Time *= 60 									; seconds spend in game
;	Time += x 									; x seconds delay so Flash() can play

	;Debug.Notification(Math.Floor(Time*24*60*60) + " | " + Math.Floor(LastTimeFlash*24*60*60 + 10))
	if Math.Floor(Time*86400) >= Math.Floor(LastTimeFlash*86410)
		Widget.StartMeterFlash()
		LastTimeFlash = Time
	endif
EndFunction
