scriptname SLSO_MCM extends SKI_ConfigBase
{MCM Menu script}

SexLabFramework property SexLab auto
Spell property SLSO_SpellAnimSync auto
Spell property SLSO_SpellVoice auto
Spell property SLSO_SpellGame auto

String File
;string[] VoiceList

;=============================================================
;INIT
;=============================================================

event OnConfigInit()
    ModName = "SL Separate Orgasms"
	self.RefreshStrings()
endEvent

Function RefreshStrings()
	Pages = new string[4]
	Pages[0] = "$page1"
	Pages[1] = "$page2"
	Pages[2] = "$page3"
	Pages[3] = "$page4"
	
	File = "/SLSO/Config.json"

;	VoiceList = new string[20]
;	while i < ((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist).GetAt(1).GetSize()
;		if (((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist).GetAt(1) as formlist).GetAt(i) != none
;			VoiceList[i] = i
;		else
;			VoiceList[i] = "--"
;		endif
;	i = i + 1
;	endwhile
EndFunction

event OnPageReset(string page)
	if page == ""
		;self.LoadCustomContent("MilkMod/MilkLogo.dds")
		self.RefreshStrings()
	else
		;self.UnloadCustomContent()
	endif

	if page == "$page1"
		self.Page_Config()
	elseif page == "$page2"
		self.Page_Widget()
	elseif page == "$page3"
		self.Page_Widget_Colors()
	elseif page == "$page4"
		self.Page_Sound_System()
	endif
endEvent

;=============================================================
;PAGES Layout
;=============================================================

function Page_Config()
	SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("$Config_Orgasm_event_configuration_Header_1")
			AddToggleOptionST("condition_leadin_orgasm", "$condition_leadin_orgasm", JsonUtil.GetIntValue(File, "condition_leadin_orgasm"))
			AddToggleOptionST("condition_ddbelt_orgasm", "$condition_ddbelt_orgasm", JsonUtil.GetIntValue(File, "condition_ddbelt_orgasm"))
			AddToggleOptionST("condition_female_orgasm", "$condition_female_orgasm", JsonUtil.GetIntValue(File, "condition_female_orgasm"))
			AddToggleOptionST("condition_male_orgasm", "$condition_male_orgasm", JsonUtil.GetIntValue(File, "condition_male_orgasm"))
			AddToggleOptionST("condition_futa_orgasm", "$condition_futa_orgasm", JsonUtil.GetIntValue(File, "condition_futa_orgasm"))
			AddToggleOptionST("condition_female_orgasm_bonus", "$condition_female_orgasm_bonus", JsonUtil.GetIntValue(File, "condition_female_orgasm_bonus"))
			AddToggleOptionST("condition_male_orgasm_penalty", "$condition_male_orgasm_penalty", JsonUtil.GetIntValue(File, "condition_male_orgasm_penalty"))
			
			AddEmptyOption()
			
		AddHeaderOption("$Config_Orgasm_event_configuration_Header_2")
			
			AddToggleOptionST("condition_aggressor_orgasm", "$condition_aggressor_orgasm", JsonUtil.GetIntValue(File, "condition_aggressor_orgasm"))
			AddToggleOptionST("condition_aggressor_change_animation", "$condition_aggressor_change_animation", JsonUtil.GetIntValue(File, "condition_aggressor_change_animation"))
			AddSliderOptionST("condition_chance_minimum_aggressor_orgasm_increase", "$condition_chance_minimum_aggressor_orgasm_increase", JsonUtil.GetIntValue(File, "condition_chance_minimum_aggressor_orgasm_increase"), "{0}%")
			AddToggleOptionST("condition_player_aggressor_orgasm", "$condition_player_aggressor_orgasm", JsonUtil.GetIntValue(File, "condition_player_aggressor_orgasm"))
			AddSliderOptionST("condition_minimum_aggressor_orgasm", "$condition_minimum_aggressor_orgasm", JsonUtil.GetIntValue(File, "condition_minimum_aggressor_orgasm"))
			AddSliderOptionST("condition_maximum_aggressor_orgasm", "$condition_maximum_aggressor_orgasm", JsonUtil.GetIntValue(File, "condition_maximum_aggressor_orgasm"))
			;AddToggleOptionST("sl_agressor_bonus_enjoyment", "$sl_agressor_bonus_enjoyment", JsonUtil.GetIntValue(File, "sl_agressor_bonus_enjoyment"))

			if JsonUtil.GetIntValue(File, "condition_victim_orgasm") == 1
				AddTextOptionST("condition_victim_orgasm", "$condition_victim_orgasm", "$condition_victim_orgasm_s1")
			elseif JsonUtil.GetIntValue(File, "condition_victim_orgasm") == 2
				AddTextOptionST("condition_victim_orgasm", "$condition_victim_orgasm", "$condition_victim_orgasm_s2")
			else
				AddTextOptionST("condition_victim_orgasm", "$condition_victim_orgasm", "$condition_victim_orgasm_s0")
			endif
			
			if JsonUtil.GetIntValue(File, "condition_victim_arousal") == 1
				AddTextOptionST("condition_victim_arousal", "$condition_victim_arousal", "$condition_victim_arousal_s1")
			elseif JsonUtil.GetIntValue(File, "condition_victim_arousal") == 2
				AddTextOptionST("condition_victim_arousal", "$condition_victim_arousal", "$condition_victim_arousal_s2")
			else
				AddTextOptionST("condition_victim_arousal", "$condition_victim_arousal", "$condition_victim_arousal_s0")
			endif

			AddEmptyOption()

		AddHeaderOption("$Config_Misc_configuration_Header")
			AddToggleOptionST("sl_default_always_orgasm", "$sl_default_always_orgasm", JsonUtil.GetIntValue(File, "sl_default_always_orgasm"))
			AddToggleOptionST("sl_npcscene_always_orgasm", "$sl_npcscene_always_orgasm", JsonUtil.GetIntValue(File, "sl_npcscene_always_orgasm"))
			AddToggleOptionST("sl_passive_enjoyment", "$sl_passive_enjoyment", JsonUtil.GetIntValue(File, "sl_passive_enjoyment"))
			AddToggleOptionST("sl_stage_enjoyment", "$sl_stage_enjoyment", JsonUtil.GetIntValue(File, "sl_stage_enjoyment"))
			AddSliderOptionST("sl_enjoymentrate_female", "$sl_enjoymentrate_female", (JsonUtil.GetFloatValue(File, "sl_enjoymentrate_female")*100) as int)
			AddSliderOptionST("sl_enjoymentrate_male", "$sl_enjoymentrate_male", (JsonUtil.GetFloatValue(File, "sl_enjoymentrate_male")*100) as int)
			AddSliderOptionST("sl_estrusforcedenjoyment", "$sl_estrusforcedenjoyment", (JsonUtil.GetFloatValue(File, "sl_estrusforcedenjoyment")*100) as int)
			AddSliderOptionST("sl_sla_orgasmexposureloss", "$sl_sla_orgasmexposureloss", JsonUtil.GetIntValue(File, "sl_sla_orgasmexposureloss"))
			AddSliderOptionST("sl_sla_orgasmexposuremodifier", "$sl_sla_orgasmexposuremodifier", JsonUtil.GetIntValue(File, "sl_sla_orgasmexposuremodifier"))
			if JsonUtil.GetIntValue(File, "sl_sla_arousal") == 1
				AddTextOptionST("sl_sla_arousal", "$sl_sla_arousal", "$sl_sla_arousal_s1")
			elseif JsonUtil.GetIntValue(File, "sl_sla_arousal") == 2
				AddTextOptionST("sl_sla_arousal", "$sl_sla_arousal", "$sl_sla_arousal_s2")
			elseif JsonUtil.GetIntValue(File, "sl_sla_arousal") == 3
				AddTextOptionST("sl_sla_arousal", "$sl_sla_arousal", "$sl_sla_arousal_s3")
			else
				AddTextOptionST("sl_sla_arousal", "$sl_sla_arousal", "$sl_sla_arousal_s0")
			endif
			AddToggleOptionST("sl_sla_stage_arousal", "$sl_sla_stage_arousal", JsonUtil.GetIntValue(File, "sl_sla_stage_arousal"))
			if JsonUtil.GetIntValue(File, "sl_exhibitionist") == 1
				AddTextOptionST("sl_exhibitionist", "$sl_exhibitionist", "$sl_exhibitionist_s1")
			elseif JsonUtil.GetIntValue(File, "sl_exhibitionist") == 2
				AddTextOptionST("sl_exhibitionist", "$sl_exhibitionist", "$sl_exhibitionist_s2")
			else
				AddTextOptionST("sl_exhibitionist", "$sl_exhibitionist", "$sl_exhibitionist_s0")
			endif
			AddToggleOptionST("sl_masturbation", "$sl_masturbation", JsonUtil.GetIntValue(File, "sl_masturbation"))
			AddSliderOptionST("sl_multiorgasmchance", "$sl_multiorgasmchance", JsonUtil.GetIntValue(File, "sl_multiorgasmchance"))
			AddSliderOptionST("sl_multiorgasmchance_curve", "$sl_multiorgasmchance_curve", JsonUtil.GetIntValue(File, "sl_multiorgasmchance_curve"))
			AddSliderOptionST("sl_hot_voice_strength", "$sl_hot_voice_strength", JsonUtil.GetIntValue(File, "sl_hot_voice_strength"))
			AddToggleOptionST("condition_player_orgasm", "$condition_player_orgasm", JsonUtil.GetIntValue(File, "condition_player_orgasm"))

	SetCursorPosition(1)
			
		AddHeaderOption("$Config_Game_Header_3")
			AddToggleOptionST("slso_game", "$slso_game", JsonUtil.GetIntValue(File, "game_enabled"))
			AddToggleOptionST("slso_game_npc", "$slso_game_npc", JsonUtil.GetIntValue(File, "game_npc_enabled"))
			AddToggleOptionST("slso_game_edging", "$slso_game_edging", JsonUtil.GetIntValue(File, "game_edging"))
			;AddToggleOptionST("slso_game_scriptupdate_boost", "$slso_game_scriptupdate_boost", JsonUtil.GetIntValue(File, "game_scriptupdate_boost"))
			AddToggleOptionST("game_player_autoplay", "$game_player_autoplay", JsonUtil.GetIntValue(File, "game_player_autoplay"))
			AddToggleOptionST("game_passive_enjoyment_reduction", "$game_passive_enjoyment_reduction", JsonUtil.GetIntValue(File, "game_passive_enjoyment_reduction"))
			AddToggleOptionST("game_enjoyment_reduction_chance", "$game_enjoyment_reduction_chance", JsonUtil.GetIntValue(File, "game_enjoyment_reduction_chance"))
			if JsonUtil.GetIntValue(File, "game_animation_speed_control") == 1
				AddTextOptionST("game_animation_speed_control", "$game_animation_speed_control", "$game_animation_speed_control_s1")
			elseif JsonUtil.GetIntValue(File, "game_animation_speed_control") == 2
				AddTextOptionST("game_animation_speed_control", "$game_animation_speed_control", "$game_animation_speed_control_s2")
			else
				AddTextOptionST("game_animation_speed_control", "$game_animation_speed_control", "$game_animation_speed_control_s0")
			endif
			if JsonUtil.GetIntValue(File, "game_animation_speed_control_actorsync") == 1
				AddTextOptionST("game_animation_speed_control_actorsync", "$game_animation_speed_control_actorsync", "$game_animation_speed_control_actorsync_s1")
			elseif JsonUtil.GetIntValue(File, "game_animation_speed_control_actorsync") == 2
				AddTextOptionST("game_animation_speed_control_actorsync", "$game_animation_speed_control_actorsync", "$game_animation_speed_control_actorsync_s2")
			else
				AddTextOptionST("game_animation_speed_control_actorsync", "$game_animation_speed_control_actorsync", "$game_animation_speed_control_actorsync_s0")
			endif
			AddSliderOptionST("game_animation_speed_control_min", "$game_animation_speed_control_min", JsonUtil.GetIntValue(File, "game_animation_speed_control_min")+JsonUtil.GetIntValue(File, "game_animation_speed_control_base"))
			AddSliderOptionST("game_animation_speed_control_max", "$game_animation_speed_control_max", JsonUtil.GetIntValue(File, "game_animation_speed_control_max")+JsonUtil.GetIntValue(File, "game_animation_speed_control_base"))
			if JsonUtil.GetIntValue(File, "game_pleasure_priority") == 0
				AddTextOptionST("game_pleasure_priority", "$game_pleasure_priority", "$game_pleasure_priority_s1")
			else
				AddTextOptionST("game_pleasure_priority", "$game_pleasure_priority", "$game_pleasure_priority_s2")
			endif
			AddToggleOptionST("game_no_sta_endanim", "$game_no_sta_endanim", JsonUtil.GetIntValue(File, "game_no_sta_endanim"))
			AddToggleOptionST("game_male_orgasm_endanim", "$game_male_orgasm_endanim", JsonUtil.GetIntValue(File, "game_male_orgasm_endanim"))
	
			AddEmptyOption()

		AddHeaderOption("$Config_Orgasm_hotkeys_Header")
			AddKeyMapOptionST("hotkey_bonusenjoyment", "$hotkey_bonusenjoyment", JsonUtil.GetIntValue(File, "hotkey_bonusenjoyment"))
			AddKeyMapOptionST("hotkey_edge", "$hotkey_edge", JsonUtil.GetIntValue(File, "hotkey_edge"))
;			AddKeyMapOptionST("hotkey_orgasm", "$hotkey_orgasm", JsonUtil.GetIntValue(File, "hotkey_orgasm"))
			AddKeyMapOptionST("hotkey_utility", "$hotkey_utility", JsonUtil.GetIntValue(File, "hotkey_utility"))
			AddKeyMapOptionST("hotkey_pausegame", "$hotkey_pausegame", JsonUtil.GetIntValue(File, "hotkey_pausegame"))
			AddKeyMapOptionST("hotkey_widget", "$hotkey_widget", JsonUtil.GetIntValue(File, "hotkey_widget"))
endfunction

function Page_Widget()
	SetCursorFillMode(TOP_TO_BOTTOM)
		AddToggleOptionST("widget_player_only", "$widget_player_only", JsonUtil.GetIntValue(File, "widget_player_only"))
		AddToggleOptionST("widget_show_enjoymentmodifier", "$widget_show_enjoymentmodifier", JsonUtil.GetIntValue(File, "widget_show_enjoymentmodifier"))
		AddSliderOptionST("LabelTextSize", "$LabelTextSize", JsonUtil.GetFloatValue(File, "widget_labeltextsize") as Int)
		AddSliderOptionST("ValueTextSize", "$ValueTextSize", JsonUtil.GetFloatValue(File, "widget_valuetextsize") as Int)
		AddEmptyOption()
		
		AddHeaderOption("$Widget_1")
			AddTextOptionST("widget1_0", "$Enabled", JsonUtil.StringListGet(File, "widget1", 0))
			AddSliderOptionST("widget1_1", "$Position_X", JsonUtil.StringListGet(File, "widget1", 1) as Int)
			AddSliderOptionST("widget1_2", "$Position_Y", JsonUtil.StringListGet(File, "widget1", 2) as Int)
			AddTextOptionST("widget1_3", "$FillDirection", JsonUtil.StringListGet(File, "widget1", 3))
			
		AddHeaderOption("$Widget_2")
			AddTextOptionST("widget2_0", "$Enabled", JsonUtil.StringListGet(File, "widget2", 0))
			AddSliderOptionST("widget2_1", "$Position_X", JsonUtil.StringListGet(File, "widget2", 1) as Int)
			AddSliderOptionST("widget2_2", "$Position_Y", JsonUtil.StringListGet(File, "widget2", 2) as Int)
			AddTextOptionST("widget2_3", "$FillDirection", JsonUtil.StringListGet(File, "widget2",3))

	SetCursorPosition(1)
		
		AddHeaderOption("$Widget_3")
			AddTextOptionST("widget3_0", "$Enabled", JsonUtil.StringListGet(File, "widget3", 0))
			AddSliderOptionST("widget3_1", "$Position_X", JsonUtil.StringListGet(File, "widget3", 1) as Int)
			AddSliderOptionST("widget3_2", "$Position_Y", JsonUtil.StringListGet(File, "widget3", 2) as Int)
			AddTextOptionST("widget3_3", "$FillDirection", JsonUtil.StringListGet(File, "widget1", 3))
			
		AddHeaderOption("$Widget_4")
			AddTextOptionST("widget4_0", "$Enabled", JsonUtil.StringListGet(File, "widget4", 0))
			AddSliderOptionST("widget4_1", "$Position_X", JsonUtil.StringListGet(File, "widget4", 1) as Int)
			AddSliderOptionST("widget4_2", "$Position_Y", JsonUtil.StringListGet(File, "widget4", 2) as Int)
			AddTextOptionST("widget4_3", "$FillDirection", JsonUtil.StringListGet(File, "widget4", 3))
			
		AddHeaderOption("$Widget_5")
			AddTextOptionST("widget5_0", "$Enabled", JsonUtil.StringListGet(File, "widget5", 0))
			AddSliderOptionST("widget5_1", "$Position_X", JsonUtil.StringListGet(File, "widget5", 1) as Int)
			AddSliderOptionST("widget5_2", "$Position_Y", JsonUtil.StringListGet(File, "widget5", 2) as Int)
			AddTextOptionST("widget5_3", "$FillDirection", JsonUtil.StringListGet(File, "widget5", 3))
endfunction	

function Page_Widget_Colors()
	SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("$Enjoyment_Colours_Header")
			AddColorOptionST("widgetcolors_0", "$Flash", JsonUtil.StringListGet(File, "widgetcolors", 0) as int)
			AddColorOptionST("widgetcolors_1", "$High", JsonUtil.StringListGet(File, "widgetcolors", 1) as int)
			AddColorOptionST("widgetcolors_2", "$Moderate", JsonUtil.StringListGet(File, "widgetcolors", 2) as int)
			AddColorOptionST("widgetcolors_3", "$Low", JsonUtil.StringListGet(File, "widgetcolors", 3) as int)
			AddColorOptionST("widgetcolors_4", "$Base_Male", JsonUtil.StringListGet(File, "widgetcolors", 4) as int)
			AddColorOptionST("widgetcolors_5", "$Base_Female", JsonUtil.StringListGet(File, "widgetcolors", 5) as int)
		AddEmptyOption()

	SetCursorPosition(1)
		AddHeaderOption("$Widget_Settings_Header")
			AddColorOptionST("LabelColor", "$LabelColor", JsonUtil.GetFloatValue(File, "widget_labelcolor") as int)
			AddColorOptionST("SelectedActorColor", "$SelectedActorColor", JsonUtil.GetFloatValue(File, "widget_selectedactorcolor") as int)
			AddSliderOptionST("BorderAlpha", "$BorderAlpha", JsonUtil.GetFloatValue(File, "widget_borderalpha") as Int)
			AddSliderOptionST("BackgroundAlpha", "$BackgroundAlpha", JsonUtil.GetFloatValue(File, "widget_backgroundalpha") as Int)
			AddSliderOptionST("MeterAlpha", "$MeterAlpha", JsonUtil.GetFloatValue(File, "widget_meteralpha") as Int)
			AddSliderOptionST("MeterScale", "$MeterScale", JsonUtil.GetFloatValue(File, "widget_meterscale") as Int)
endfunction	

function Page_Sound_System()
	SetCursorFillMode(TOP_TO_BOTTOM)
		AddHeaderOption("$Sound_System_VoicePacks_Selection_Header")
		AddToggleOptionST("sl_voice_enjoymentbased", "$sl_voice_enjoymentbased", JsonUtil.GetIntValue(File, "sl_voice_enjoymentbased"))
		AddToggleOptionST("sl_voice_playandwait", "$sl_voice_playandwait", JsonUtil.GetIntValue(File, "sl_voice_playandwait"))
		AddSliderOptionST("sl_voice_painswitch", "$sl_voice_painswitch", JsonUtil.GetIntValue(File, "sl_voice_painswitch") * 10)
		AddSliderOptionST("sl_voice_player", "$PC_voice_pack", JsonUtil.GetIntValue(File, "sl_voice_player"))
		AddSliderOptionST("sl_voice_npc", "$NPC_voice_pack", JsonUtil.GetIntValue(File, "sl_voice_npc"))
	
		AddEmptyOption()

		;AddToggleOptionST("sl_voice_reset", "$sl_voice_reset", "")

	SetCursorPosition(1)
		AddHeaderOption("$Sound_System_Installed_VoicePacks_Header")
		AddHeaderOption("$Sound_System_Installed_F_VoicePacks_Header")
		int i = 0
		while i < ((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist).GetSize()
			if ((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist).GetAt(i) != none
				AddTextOption(i + 1, (((Game.GetFormFromFile(0x63A3, "SLSO.esp") as formlist).GetAt(1) as formlist).GetAt(i) as form).GetName() + " (" + DectoHex((((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist).GetAt(i) as form).GetFormID())+")", OPTION_FLAG_DISABLED)
			else
				AddTextOption("Something wrong", "save, reload", OPTION_FLAG_DISABLED)
			endif
		i = i + 1
		endwhile
		
;		AddHeaderOption("$Sound_System_Installed_M_VoicePacks_Header")
;		i = 0
;		while i < ((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(0) as formlist).GetSize()
;			if ((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(0) as formlist).GetAt(i) != none
;				AddTextOption(i + 1, (((Game.GetFormFromFile(0x63A3, "SLSO.esp") as formlist).GetAt(0) as formlist).GetAt(i) as form).GetName() + " (" + DectoHex((((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(0) as formlist).GetAt(i) as form).GetFormID())+")", OPTION_FLAG_DISABLED)
;			else
;				AddTextOption("Voice pack", "?????", OPTION_FLAG_DISABLED)
;			endif
;		i = i + 1
;		endwhile
endfunction	

string function DectoHex(Int value)
    String digits = "0123456789ABCDEF"
    int base = 16
    String hex = ""
	
	if (value <= 0)
		return 0
	endif
	
    while (value > 0)
        int digit = value % base
        hex = StringUtil.GetNthChar(digits, digit) + hex
        value = value / base
	endwhile
	
    return hex
endfunction	

;=============================================================
;STATES, mess below
;=============================================================

;=============================================================
;Config
;=============================================================

;=============================================================
;Sliders
;=============================================================

state sl_estrusforcedenjoyment
	event OnSliderOpenST()
		SetSliderDialogStartValue((JsonUtil.GetFloatValue(File, "sl_estrusforcedenjoyment")*100) as int)
		SetSliderDialogDefaultValue(200)
		SetSliderDialogRange(0, 500)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetFloatValue(File, "sl_estrusforcedenjoyment", value/100)
		SetSliderOptionValueST((JsonUtil.GetFloatValue(File, "sl_estrusforcedenjoyment")*100) as int)
	endEvent
	event OnHighlightST()
		SetInfoText("$sl_estrusforcedenjoyment_description")
	endEvent
endState

state sl_sla_orgasmexposureloss
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "sl_sla_orgasmexposureloss"))
		SetSliderDialogDefaultValue(-20)
		SetSliderDialogRange(-100, 0)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "sl_sla_orgasmexposureloss", value as int)
		SetSliderOptionValueST(JsonUtil.GetIntValue(File, "sl_sla_orgasmexposureloss"))
	endEvent
	event OnHighlightST()
		SetInfoText("$sl_sla_orgasmexposureloss_description")
	endEvent
endState

state sl_sla_orgasmexposuremodifier
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "sl_sla_orgasmexposuremodifier"))
		SetSliderDialogDefaultValue(3)
		SetSliderDialogRange(0, 5)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "sl_sla_orgasmexposuremodifier", value as int)
		SetSliderOptionValueST(JsonUtil.GetIntValue(File, "sl_sla_orgasmexposuremodifier"))
	endEvent
	event OnHighlightST()
		SetInfoText("$sl_sla_orgasmexposuremodifier_description")
	endEvent
endState

state sl_enjoymentrate_male
	event OnSliderOpenST()
		SetSliderDialogStartValue((JsonUtil.GetFloatValue(File, "sl_enjoymentrate_male")*100) as int)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(1, 200)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetFloatValue(File, "sl_enjoymentrate_male", value/100)
		SetSliderOptionValueST((JsonUtil.GetFloatValue(File, "sl_enjoymentrate_male")*100) as int)
	endEvent
endState

state sl_enjoymentrate_female
	event OnSliderOpenST()
		SetSliderDialogStartValue((JsonUtil.GetFloatValue(File, "sl_enjoymentrate_female")*100) as int)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(1, 200)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetFloatValue(File, "sl_enjoymentrate_female", value/100)
		SetSliderOptionValueST((JsonUtil.GetFloatValue(File, "sl_enjoymentrate_female")*100) as int)
	endEvent
endState

state condition_minimum_aggressor_orgasm
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "condition_minimum_aggressor_orgasm"))
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "condition_minimum_aggressor_orgasm", value as int)
		SetSliderOptionValueST(JsonUtil.GetIntValue(File, "condition_minimum_aggressor_orgasm"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_minimum_aggressor_orgasm_description")
	endEvent
endState

state condition_maximum_aggressor_orgasm
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "condition_maximum_aggressor_orgasm"))
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "condition_maximum_aggressor_orgasm", value as int)
		SetSliderOptionValueST(JsonUtil.GetIntValue(File, "condition_maximum_aggressor_orgasm"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_maximum_aggressor_orgasm_description")
	endEvent
endState

state condition_chance_minimum_aggressor_orgasm_increase
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "condition_chance_minimum_aggressor_orgasm_increase"))
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "condition_chance_minimum_aggressor_orgasm_increase", value as int)
		SetSliderOptionValueST(JsonUtil.GetIntValue(File, "condition_chance_minimum_aggressor_orgasm_increase"), "{0}%")
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_chance_minimum_aggressor_orgasm_increase_description")
	endEvent
endState

state sl_hot_voice_strength
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "sl_hot_voice_strength"))
		SetSliderDialogDefaultValue(90)
		SetSliderDialogRange(30, 200)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "sl_hot_voice_strength", value as int)
		SetSliderOptionValueST(JsonUtil.GetIntValue(File, "sl_hot_voice_strength"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_hot_voice_strength_description")
	endEvent
endState

state sl_multiorgasmchance
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "sl_multiorgasmchance"))
		SetSliderDialogDefaultValue(25)
		SetSliderDialogRange(0, 200)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "sl_multiorgasmchance", value as int)
		SetSliderOptionValueST(JsonUtil.GetIntValue(File, "sl_multiorgasmchance"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_multiorgasmchance_description")
	endEvent
endState

state sl_multiorgasmchance_curve
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "sl_multiorgasmchance_curve"))
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(0, 200)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "sl_multiorgasmchance_curve", value as int)
		SetSliderOptionValueST(JsonUtil.GetIntValue(File, "sl_multiorgasmchance_curve"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_multiorgasmchance_curve_description")
	endEvent
endState


;=============================================================
;TOGGLES
;=============================================================

state sl_default_always_orgasm
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "sl_default_always_orgasm") == 1
			JsonUtil.SetIntValue(File, "sl_default_always_orgasm", 0)
		else
			JsonUtil.SetIntValue(File, "sl_default_always_orgasm", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "sl_default_always_orgasm"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_default_always_orgasm_description")
	endEvent
endState

state sl_npcscene_always_orgasm
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "sl_npcscene_always_orgasm") == 1
			JsonUtil.SetIntValue(File, "sl_npcscene_always_orgasm", 0)
		else
			JsonUtil.SetIntValue(File, "sl_npcscene_always_orgasm", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "sl_npcscene_always_orgasm"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_npcscene_always_orgasm_description")
	endEvent
endState

state game_no_sta_endanim
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "game_no_sta_endanim") == 1
			JsonUtil.SetIntValue(File, "game_no_sta_endanim", 0)
		else
			JsonUtil.SetIntValue(File, "game_no_sta_endanim", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "game_no_sta_endanim"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$game_no_sta_endanim_description")
	endEvent
endState

state game_male_orgasm_endanim
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "game_male_orgasm_endanim") == 1
			JsonUtil.SetIntValue(File, "game_male_orgasm_endanim", 0)
		else
			JsonUtil.SetIntValue(File, "game_male_orgasm_endanim", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "game_male_orgasm_endanim"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$game_male_orgasm_endanim_description")
	endEvent
endState

state sl_passive_enjoyment
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "sl_passive_enjoyment") == 1
			JsonUtil.SetIntValue(File, "sl_passive_enjoyment", 0)
		else
			JsonUtil.SetIntValue(File, "sl_passive_enjoyment", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "sl_passive_enjoyment"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_passive_enjoyment_description")
	endEvent
endState

state sl_stage_enjoyment
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "sl_stage_enjoyment") == 1
			JsonUtil.SetIntValue(File, "sl_stage_enjoyment", 0)
		else
			JsonUtil.SetIntValue(File, "sl_stage_enjoyment", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "sl_stage_enjoyment"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_stage_enjoyment_description")
	endEvent
endState

state condition_aggressor_orgasm
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "condition_aggressor_orgasm") == 1
			JsonUtil.SetIntValue(File, "condition_aggressor_orgasm", 0)
		else
			JsonUtil.SetIntValue(File, "condition_aggressor_orgasm", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "condition_aggressor_orgasm"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_aggressor_orgasm_description")
	endEvent
endState

state condition_aggressor_change_animation
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "condition_aggressor_change_animation") == 1
			JsonUtil.SetIntValue(File, "condition_aggressor_change_animation", 0)
		else
			JsonUtil.SetIntValue(File, "condition_aggressor_change_animation", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "condition_aggressor_change_animation"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_aggressor_change_animation_description")
	endEvent
endState

state condition_player_aggressor_orgasm
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "condition_player_aggressor_orgasm") == 1
			JsonUtil.SetIntValue(File, "condition_player_aggressor_orgasm", 0)
		else
			JsonUtil.SetIntValue(File, "condition_player_aggressor_orgasm", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "condition_player_aggressor_orgasm"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_player_aggressor_orgasm_description")
	endEvent
endState

state sl_agressor_bonus_enjoyment
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "sl_agressor_bonus_enjoyment") == 1
			JsonUtil.SetIntValue(File, "sl_agressor_bonus_enjoyment", 0)
		else
			JsonUtil.SetIntValue(File, "sl_agressor_bonus_enjoyment", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "sl_agressor_bonus_enjoyment"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_agressor_bonus_enjoyment_description")
	endEvent
endState

state condition_female_orgasm_bonus
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "condition_female_orgasm_bonus") == 1
			JsonUtil.SetIntValue(File, "condition_female_orgasm_bonus", 0)
		else
			JsonUtil.SetIntValue(File, "condition_female_orgasm_bonus", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "condition_female_orgasm_bonus"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_female_orgasm_bonus_description")
	endEvent
endState

state condition_male_orgasm_penalty
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "condition_male_orgasm_penalty") == 1
			JsonUtil.SetIntValue(File, "condition_male_orgasm_penalty", 0)
		else
			JsonUtil.SetIntValue(File, "condition_male_orgasm_penalty", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "condition_male_orgasm_penalty"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_male_orgasm_penalty_description")
	endEvent
endState

state condition_female_orgasm
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "condition_female_orgasm") == 1
			JsonUtil.SetIntValue(File, "condition_female_orgasm", 0)
		else
			JsonUtil.SetIntValue(File, "condition_female_orgasm", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "condition_female_orgasm"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_female_orgasm_description")
	endEvent
endState

state condition_male_orgasm
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "condition_male_orgasm") == 1
			JsonUtil.SetIntValue(File, "condition_male_orgasm", 0)
		else
			JsonUtil.SetIntValue(File, "condition_male_orgasm", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "condition_male_orgasm"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_male_orgasm_description")
	endEvent
endState

state condition_futa_orgasm
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "condition_futa_orgasm") == 1
			JsonUtil.SetIntValue(File, "condition_futa_orgasm", 0)
		else
			JsonUtil.SetIntValue(File, "condition_futa_orgasm", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "condition_futa_orgasm"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_futa_orgasm_description")
	endEvent
endState

state condition_leadin_orgasm
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "condition_leadin_orgasm") == 1
			JsonUtil.SetIntValue(File, "condition_leadin_orgasm", 0)
		else
			JsonUtil.SetIntValue(File, "condition_leadin_orgasm", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "condition_leadin_orgasm"))
	endEvent
endState

state sl_sla_arousal
	event OnSelectST()
		String value
		if JsonUtil.GetIntValue(File, "sl_sla_arousal") == 1
			JsonUtil.SetIntValue(File, "sl_sla_arousal", 2)
			value = "$sl_sla_arousal_s2"
		elseif JsonUtil.GetIntValue(File, "sl_sla_arousal") == 2
			JsonUtil.SetIntValue(File, "sl_sla_arousal", 3)
			value = "$sl_sla_arousal_s3"
		elseif JsonUtil.GetIntValue(File, "sl_sla_arousal") == 3
			JsonUtil.SetIntValue(File, "sl_sla_arousal", 0)
			value = "$sl_sla_arousal_s0"
		else
			JsonUtil.SetIntValue(File, "sl_sla_arousal", 1)
			value = "$sl_sla_arousal_s1"
		endif
		SetTextOptionValueST(value)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_sla_arousal_description")
	endEvent
endState

state sl_sla_stage_arousal
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "sl_sla_stage_arousal") == 1
			JsonUtil.SetIntValue(File, "sl_sla_stage_arousal", 0)
		else
			JsonUtil.SetIntValue(File, "sl_sla_stage_arousal", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "sl_sla_stage_arousal"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_sla_stage_arousal_description")
	endEvent
endState

state sl_exhibitionist
	event OnSelectST()
		String value
		if JsonUtil.GetIntValue(File, "sl_exhibitionist") == 0
			JsonUtil.SetIntValue(File, "sl_exhibitionist", 1)
			value = "$sl_exhibitionist_s1"
		elseif JsonUtil.GetIntValue(File, "sl_exhibitionist") == 1
			JsonUtil.SetIntValue(File, "sl_exhibitionist", 2)
			value = "$sl_exhibitionist_s2"
		else
			JsonUtil.SetIntValue(File, "sl_exhibitionist", 0)
			value = "$sl_exhibitionist_s0"
		endif
		SetTextOptionValueST(value)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_exhibitionist_description")
	endEvent
endState

state slso_game
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "game_enabled") == 1
			JsonUtil.SetIntValue(File, "game_enabled", 0)
		else
			JsonUtil.SetIntValue(File, "game_enabled", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "game_enabled"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$slso_game_description")
	endEvent
endState

state slso_game_npc
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "game_npc_enabled") == 1
			JsonUtil.SetIntValue(File, "game_npc_enabled", 0)
		else
			JsonUtil.SetIntValue(File, "game_npc_enabled", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "game_npc_enabled"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$slso_game_npc_description")
	endEvent
endState

state slso_game_edging
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "game_edging") == 1
			JsonUtil.SetIntValue(File, "game_edging", 0)
		else
			JsonUtil.SetIntValue(File, "game_edging", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "game_edging"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$slso_game_edging_description")
	endEvent
endState

state slso_game_scriptupdate_boost
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "game_scriptupdate_boost") == 1
			JsonUtil.SetIntValue(File, "game_scriptupdate_boost", 0)
		else
			JsonUtil.SetIntValue(File, "game_scriptupdate_boost", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "game_scriptupdate_boost"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$slso_game_scriptupdate_boost_description")
	endEvent
endState

state game_player_autoplay
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "game_player_autoplay") == 1
			JsonUtil.SetIntValue(File, "game_player_autoplay", 0)
		else
			JsonUtil.SetIntValue(File, "game_player_autoplay", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "game_player_autoplay"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$game_player_autoplay_description")
	endEvent
endState

state sl_masturbation
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "sl_masturbation") == 1
			JsonUtil.SetIntValue(File, "sl_masturbation", 0)
		else
			JsonUtil.SetIntValue(File, "sl_masturbation", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "sl_masturbation"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_masturbation_description")
	endEvent
endState

state game_passive_enjoyment_reduction
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "game_passive_enjoyment_reduction") == 1
			JsonUtil.SetIntValue(File, "game_passive_enjoyment_reduction", 0)
		else
			JsonUtil.SetIntValue(File, "game_passive_enjoyment_reduction", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "game_passive_enjoyment_reduction"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$game_passive_enjoyment_reduction_description")
	endEvent
endState

state game_enjoyment_reduction_chance
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "game_enjoyment_reduction_chance") == 1
			JsonUtil.SetIntValue(File, "game_enjoyment_reduction_chance", 0)
		else
			JsonUtil.SetIntValue(File, "game_enjoyment_reduction_chance", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "game_enjoyment_reduction_chance"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$game_enjoyment_reduction_chance_description")
	endEvent
endState

state game_animation_speed_control
	event OnSelectST()
		String value
		if JsonUtil.GetIntValue(File, "game_animation_speed_control") == 1
			JsonUtil.SetIntValue(File, "game_animation_speed_control", 2)
			value = "$game_animation_speed_control_s2"
		elseif JsonUtil.GetIntValue(File, "game_animation_speed_control") == 2
			JsonUtil.SetIntValue(File, "game_animation_speed_control", 0)
			value = "$game_animation_speed_control_s0"
		else
			JsonUtil.SetIntValue(File, "game_animation_speed_control", 1)
			value = "$game_animation_speed_control_s1"
		endif
		SetTextOptionValueST(value)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$game_animation_speed_control_description")
	endEvent
endState

state game_animation_speed_control_actorsync
	event OnSelectST()
		String value
		if JsonUtil.GetIntValue(File, "game_animation_speed_control_actorsync") == 1
			JsonUtil.SetIntValue(File, "game_animation_speed_control_actorsync", 2)
			value = "$game_animation_speed_control_actorsync_s2"
		elseif JsonUtil.GetIntValue(File, "game_animation_speed_control_actorsync") == 2
			JsonUtil.SetIntValue(File, "game_animation_speed_control_actorsync", 0)
			value = "$game_animation_speed_control_actorsync_s0"
		else
			JsonUtil.SetIntValue(File, "game_animation_speed_control_actorsync", 1)
			value = "$game_animation_speed_control_actorsync_s1"
		endif
		SetTextOptionValueST(value)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$game_animation_speed_control_actorsync_description")
	endEvent
endState

state game_animation_speed_control_min
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "game_animation_speed_control_min"))
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, JsonUtil.GetIntValue(File, "game_animation_speed_control_max"))
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "game_animation_speed_control_min", value as int)
		SetSliderOptionValueST(JsonUtil.GetIntValue(File, "game_animation_speed_control_min")+JsonUtil.GetIntValue(File, "game_animation_speed_control_base"))
	endEvent
endState
state game_animation_speed_control_max
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "game_animation_speed_control_max"))
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(JsonUtil.GetIntValue(File, "game_animation_speed_control_min"), 150)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "game_animation_speed_control_max", value as int)
		SetSliderOptionValueST(JsonUtil.GetIntValue(File, "game_animation_speed_control_max")+JsonUtil.GetIntValue(File, "game_animation_speed_control_base"))
	endEvent
endState

state game_pleasure_priority
	event OnSelectST()
		String value
		if JsonUtil.GetIntValue(File, "game_pleasure_priority") == 0
			JsonUtil.SetIntValue(File, "game_pleasure_priority", 1)
			value = "$game_pleasure_priority_s2"
		else
			JsonUtil.SetIntValue(File, "game_pleasure_priority", 0)
			value = "$game_pleasure_priority_s1"
		endif
		SetTextOptionValueST(value)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$game_pleasure_priority_description")
	endEvent
endState

state condition_player_orgasm
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "condition_player_orgasm") == 1
			JsonUtil.SetIntValue(File, "condition_player_orgasm", 0)
		else
			JsonUtil.SetIntValue(File, "condition_player_orgasm", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "condition_player_orgasm"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_player_orgasm_description")
	endEvent
endState

state condition_victim_orgasm
	event OnSelectST()
		String value
		if JsonUtil.GetIntValue(File, "condition_victim_orgasm") == 1
			JsonUtil.SetIntValue(File, "condition_victim_orgasm", 2)
			value = "$condition_victim_orgasm_s2"
		elseif JsonUtil.GetIntValue(File, "condition_victim_orgasm") == 2
			JsonUtil.SetIntValue(File, "condition_victim_orgasm", 0)
			value = "$condition_victim_orgasm_s0"
		else
			JsonUtil.SetIntValue(File, "condition_victim_orgasm", 1)
			value = "$condition_victim_orgasm_s1"
		endif
		SetTextOptionValueST(value)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_victim_orgasm_description")
	endEvent
endState

state condition_victim_arousal
	event OnSelectST()
		String value
		if JsonUtil.GetIntValue(File, "condition_victim_arousal") == 1
			JsonUtil.SetIntValue(File, "condition_victim_arousal", 2)
			value = "$condition_victim_arousal_s2"
		elseif JsonUtil.GetIntValue(File, "condition_victim_arousal") == 2
			JsonUtil.SetIntValue(File, "condition_victim_arousal", 0)
			value = "$condition_victim_arousal_s0"
		else
			JsonUtil.SetIntValue(File, "condition_victim_arousal", 1)
			value = "$condition_victim_arousal_s1"
		endif
		SetTextOptionValueST(value)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$condition_victim_arousal_description")
	endEvent
endState

state condition_ddbelt_orgasm
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "condition_ddbelt_orgasm") == 1
			JsonUtil.SetIntValue(File, "condition_ddbelt_orgasm", 0)
		else
			JsonUtil.SetIntValue(File, "condition_ddbelt_orgasm", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "condition_ddbelt_orgasm"))
	endEvent
endState

state widget_player_only
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "widget_player_only") == 1
			JsonUtil.SetIntValue(File, "widget_player_only", 0)
		else
			JsonUtil.SetIntValue(File, "widget_player_only", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "widget_player_only"))
	endEvent
endState

state widget_show_enjoymentmodifier
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "widget_show_enjoymentmodifier") == 1
			JsonUtil.SetIntValue(File, "widget_show_enjoymentmodifier", 0)
		else
			JsonUtil.SetIntValue(File, "widget_show_enjoymentmodifier", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "widget_show_enjoymentmodifier"))
	endEvent
endState


;=============================================================
;HOTKEYS
;=============================================================

state hotkey_bonusenjoyment
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		UnregisterForAllKeys()
		bool continue = true
 
		; Check for conflict
		if conflictControl != ""
			string msg
			if conflictName != ""
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n(" + conflictName + ")\n\n Are you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n\n Are you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "Yes", "No")
		endIf

		; Set allowed key change
		if continue
			JsonUtil.SetIntValue(File, "hotkey_bonusenjoyment", newKeyCode)
			SetKeyMapOptionValueST(JsonUtil.GetIntValue(File, "hotkey_bonusenjoyment"))
		endIf
		RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_bonusenjoyment"))
	endEvent

	event OnHighlightST()
		SetInfoText("$hotkey_bonusenjoyment_description")
	endEvent
endState

state hotkey_edge
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		UnregisterForAllKeys()
		bool continue = true
 
		; Check for conflict
		if conflictControl != ""
			string msg
			if conflictName != ""
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n(" + conflictName + ")\n\n Are you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n\n Are you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "Yes", "No")
		endIf

		; Set allowed key change
		if continue
			JsonUtil.SetIntValue(File, "hotkey_edge", newKeyCode)
			SetKeyMapOptionValueST(JsonUtil.GetIntValue(File, "hotkey_edge"))
		endIf
		RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_edge"))
	endEvent

	event OnHighlightST()
		SetInfoText("$hotkey_edge_description")
	endEvent
endState

state hotkey_orgasm
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		UnregisterForAllKeys()
		bool continue = true
 
		; Check for conflict
		if conflictControl != ""
			string msg
			if conflictName != ""
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n(" + conflictName + ")\n\n Are you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n\n Are you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "Yes", "No")
		endIf

		; Set allowed key change
		if continue
			JsonUtil.SetIntValue(File, "hotkey_orgasm", newKeyCode)
			SetKeyMapOptionValueST(JsonUtil.GetIntValue(File, "hotkey_orgasm"))
		endIf
		RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_orgasm"))
	endEvent

	event OnHighlightST()
		SetInfoText("$hotkey_orgasm_description")
	endEvent
endState

state hotkey_utility
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		UnregisterForAllKeys()
		bool continue = true
 
		; Check for conflict
		if conflictControl != ""
			string msg
			if conflictName != ""
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n(" + conflictName + ")\n\n Are you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n\n Are you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "Yes", "No")
		endIf

		; Set allowed key change
		if continue
			JsonUtil.SetIntValue(File, "hotkey_utility", newKeyCode)
			SetKeyMapOptionValueST(JsonUtil.GetIntValue(File, "hotkey_utility"))
		endIf
		RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_utility"))
	endEvent

	event OnHighlightST()
		SetInfoText("$hotkey_utility_description")
	endEvent
endState

state hotkey_pausegame
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		UnregisterForAllKeys()
		bool continue = true
 
		; Check for conflict
		if conflictControl != ""
			string msg
			if conflictName != ""
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n(" + conflictName + ")\n\n Are you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n\n Are you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "Yes", "No")
		endIf

		; Set allowed key change
		if continue
			JsonUtil.SetIntValue(File, "hotkey_pausegame", newKeyCode)
			SetKeyMapOptionValueST(JsonUtil.GetIntValue(File, "hotkey_pausegame"))
		endIf
		RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_pausegame"))
	endEvent

	event OnHighlightST()
		SetInfoText("$hotkey_pausegame_description")
	endEvent
endState

state hotkey_widget
	event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		UnregisterForAllKeys()
		bool continue = true
 
		; Check for conflict
		if conflictControl != ""
			string msg
			if conflictName != ""
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n(" + conflictName + ")\n\n Are you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n\n Are you sure you want to continue?"
			endIf
			continue = ShowMessage(msg, true, "Yes", "No")
		endIf

		; Set allowed key change
		if continue
			JsonUtil.SetIntValue(File, "hotkey_widget", newKeyCode)
			SetKeyMapOptionValueST(JsonUtil.GetIntValue(File, "hotkey_widget"))
		endIf
		RegisterForKey(JsonUtil.GetIntValue(File, "hotkey_widget"))
	endEvent

	event OnHighlightST()
		SetInfoText("$hotkey_widget_description")
	endEvent
endState

;=============================================================
;Widgets
;=============================================================

state widget1_0
	event OnSelectST()
		if JsonUtil.StringListGet(File, "widget1", 0) == "On"
			JsonUtil.StringListSet(File, "widget1", 0, "Off")
		else
			JsonUtil.StringListSet(File, "widget1", 0, "On")
		endif
		SetTextOptionValueST(JsonUtil.StringListGet(File, "widget1", 0))
	endEvent
endState

state widget1_1
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.StringListGet(File, "widget1", 1) as Int)
		SetSliderDialogDefaultValue(495)
		SetSliderDialogRange(1, 4000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.StringListSet(File, "widget1", 1, value )
		(self.GetAlias(1) as SLSO_Widget1Update).UpdateWidgetPosition()
		SetSliderOptionValueST(JsonUtil.StringListGet(File, "widget1", 1) as int)
	endEvent
endState

state widget1_2
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.StringListGet(File, "widget1", 2) as Int)
		SetSliderDialogDefaultValue(680)
		SetSliderDialogRange(1, 4000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.StringListSet(File, "widget1", 2, value )
		(self.GetAlias(1) as SLSO_Widget1Update).UpdateWidgetPosition()
		SetSliderOptionValueST(JsonUtil.StringListGet(File, "widget1", 2) as int)
	endEvent
endState

state widget1_3
	event OnSelectST()
		if JsonUtil.StringListGet(File, "widget1", 3) == "left"
			JsonUtil.StringListSet(File, "widget1", 3, "right")
		elseif JsonUtil.StringListGet(File, "widget1", 3) == "right"
			JsonUtil.StringListSet(File, "widget1", 3, "both")
		else
			JsonUtil.StringListSet(File, "widget1", 3, "left")
		endif
		SetTextOptionValueST(JsonUtil.StringListGet(File, "widget1", 3))
	endEvent
endState

state widget2_0
	event OnSelectST()
		if JsonUtil.StringListGet(File, "widget2", 0) == "On"
			JsonUtil.StringListSet(File, "widget2", 0, "Off")
		else
			JsonUtil.StringListSet(File, "widget2", 0, "On")
		endif
		SetTextOptionValueST(JsonUtil.StringListGet(File, "widget2", 0))
	endEvent
endState

state widget2_1
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.StringListGet(File, "widget2", 1) as Int)
		SetSliderDialogDefaultValue(495)
		SetSliderDialogRange(1, 4000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.StringListSet(File, "widget2", 1, value )
		(self.GetAlias(2) as SLSO_Widget2Update).UpdateWidgetPosition()
		SetSliderOptionValueST(JsonUtil.StringListGet(File, "widget2", 1) as int)
	endEvent
endState

state widget2_2
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.StringListGet(File, "widget2", 2) as Int)
		SetSliderDialogDefaultValue(680)
		SetSliderDialogRange(1, 4000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.StringListSet(File, "widget2", 2, value )
		(self.GetAlias(2) as SLSO_Widget2Update).UpdateWidgetPosition()
		SetSliderOptionValueST(JsonUtil.StringListGet(File, "widget2", 2) as int)
	endEvent
endState

state widget2_3
	event OnSelectST()
		if JsonUtil.StringListGet(File, "widget2", 3) == "left"
			JsonUtil.StringListSet(File, "widget2", 3, "right")
		elseif JsonUtil.StringListGet(File, "widget2", 3) == "right"
			JsonUtil.StringListSet(File, "widget2", 3, "both")
		else
			JsonUtil.StringListSet(File, "widget2", 3, "left")
		endif
		SetTextOptionValueST(JsonUtil.StringListGet(File, "widget2", 3))
	endEvent
endState

state widget3_0
	event OnSelectST()
		if JsonUtil.StringListGet(File, "widget3", 0) == "On"
			JsonUtil.StringListSet(File, "widget3", 0, "Off")
		else
			JsonUtil.StringListSet(File, "widget3", 0, "On")
		endif
		SetTextOptionValueST(JsonUtil.StringListGet(File, "widget3", 0))
	endEvent
endState

state widget3_1
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.StringListGet(File, "widget3", 1) as Int)
		SetSliderDialogDefaultValue(495)
		SetSliderDialogRange(1, 4000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.StringListSet(File, "widget3", 1, value )
		(self.GetAlias(3) as SLSO_Widget3Update).UpdateWidgetPosition()
		SetSliderOptionValueST(JsonUtil.StringListGet(File, "widget3", 1) as int)
	endEvent
endState

state widget3_2
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.StringListGet(File, "widget3", 2) as Int)
		SetSliderDialogDefaultValue(680)
		SetSliderDialogRange(1, 4000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.StringListSet(File, "widget3", 2, value )
		(self.GetAlias(3) as SLSO_Widget3Update).UpdateWidgetPosition()
		SetSliderOptionValueST(JsonUtil.StringListGet(File, "widget3", 2) as int)
	endEvent
endState

state widget3_3
	event OnSelectST()
		if JsonUtil.StringListGet(File, "widget3", 3) == "left"
			JsonUtil.StringListSet(File, "widget3", 3, "right")
		elseif JsonUtil.StringListGet(File, "widget3", 3) == "right"
			JsonUtil.StringListSet(File, "widget3", 3, "both")
		else
			JsonUtil.StringListSet(File, "widget3", 3, "left")
		endif
		SetTextOptionValueST(JsonUtil.StringListGet(File, "widget3", 3))
	endEvent
endState

state widget4_0
	event OnSelectST()
		if JsonUtil.StringListGet(File, "widget4", 0) == "On"
			JsonUtil.StringListSet(File, "widget4", 0, "Off")
		else
			JsonUtil.StringListSet(File, "widget4", 0, "On")
		endif
		SetTextOptionValueST(JsonUtil.StringListGet(File, "widget4", 0))
	endEvent
endState

state widget4_1
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.StringListGet(File, "widget4", 1) as Int)
		SetSliderDialogDefaultValue(495)
		SetSliderDialogRange(1, 4000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.StringListSet(File, "widget4", 1, value )
		(self.GetAlias(4) as SLSO_Widget4Update).UpdateWidgetPosition()
		SetSliderOptionValueST(JsonUtil.StringListGet(File, "widget4", 1) as int)
	endEvent
endState

state widget4_2
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.StringListGet(File, "widget4", 2) as Int)
		SetSliderDialogDefaultValue(680)
		SetSliderDialogRange(1, 4000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.StringListSet(File, "widget4", 2, value )
		(self.GetAlias(4) as SLSO_Widget4Update).UpdateWidgetPosition()
		SetSliderOptionValueST(JsonUtil.StringListGet(File, "widget4", 2) as int)
	endEvent
endState

state widget4_3
	event OnSelectST()
		if JsonUtil.StringListGet(File, "widget4", 3) == "left"
			JsonUtil.StringListSet(File, "widget4", 3, "right")
		elseif JsonUtil.StringListGet(File, "widget4", 3) == "right"
			JsonUtil.StringListSet(File, "widget4", 3, "both")
		else
			JsonUtil.StringListSet(File, "widget4", 3, "left")
		endif
		SetTextOptionValueST(JsonUtil.StringListGet(File, "widget4", 3))
	endEvent
endState

state widget5_0
	event OnSelectST()
		if JsonUtil.StringListGet(File, "widget5", 0) == "On"
			JsonUtil.StringListSet(File, "widget5", 0, "Off")
		else
			JsonUtil.StringListSet(File, "widget5", 0, "On")
		endif
		SetTextOptionValueST(JsonUtil.StringListGet(File, "widget5", 0))
	endEvent
endState

state widget5_1
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.StringListGet(File, "widget5", 1) as Int)
		SetSliderDialogDefaultValue(495)
		SetSliderDialogRange(1, 4000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.StringListSet(File, "widget5", 1, value )
		(self.GetAlias(4) as SLSO_widget5Update).UpdateWidgetPosition()
		SetSliderOptionValueST(JsonUtil.StringListGet(File, "widget5", 1) as int)
	endEvent
endState

state widget5_2
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.StringListGet(File, "widget5", 2) as Int)
		SetSliderDialogDefaultValue(680)
		SetSliderDialogRange(1, 4000)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.StringListSet(File, "widget5", 2, value )
		(self.GetAlias(4) as SLSO_widget5Update).UpdateWidgetPosition()
		SetSliderOptionValueST(JsonUtil.StringListGet(File, "widget5", 2) as int)
	endEvent
endState

state widget5_3
	event OnSelectST()
		if JsonUtil.StringListGet(File, "widget5", 3) == "left"
			JsonUtil.StringListSet(File, "widget5", 3, "right")
		elseif JsonUtil.StringListGet(File, "widget5", 3) == "right"
			JsonUtil.StringListSet(File, "widget5", 3, "both")
		else
			JsonUtil.StringListSet(File, "widget5", 3, "left")
		endif
		SetTextOptionValueST(JsonUtil.StringListGet(File, "widget5", 3))
	endEvent
endState

state LabelTextSize
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetFloatValue(File, "widget_labeltextsize") as Int)
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(1, 50)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetFloatValue(File, "widget_labeltextsize", value )
		SetSliderOptionValueST(JsonUtil.GetFloatValue(File, "widget_labeltextsize") as int)
	endEvent
endState

state ValueTextSize
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetFloatValue(File, "widget_valuetextsize") as Int)
		SetSliderDialogDefaultValue(20)
		SetSliderDialogRange(1, 50)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetFloatValue(File, "widget_valuetextsize", value )
		SetSliderOptionValueST(JsonUtil.GetFloatValue(File, "widget_valuetextsize") as int)
	endEvent
endState

state BorderAlpha
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetFloatValue(File, "widget_borderalpha") as Int)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetFloatValue(File, "widget_borderalpha", value )
		SetSliderOptionValueST(JsonUtil.GetFloatValue(File, "widget_borderalpha") as int)
	endEvent
endState

state BackgroundAlpha
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetFloatValue(File, "widget_backgroundalpha") as Int)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetFloatValue(File, "widget_backgroundalpha", value )
		SetSliderOptionValueST(JsonUtil.GetFloatValue(File, "widget_backgroundalpha") as int)
	endEvent
endState

state MeterAlpha
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetFloatValue(File, "widget_meteralpha") as Int)
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetFloatValue(File, "widget_meteralpha", value )
		SetSliderOptionValueST(JsonUtil.GetFloatValue(File, "widget_meteralpha") as int)
	endEvent
endState

state MeterScale
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetFloatValue(File, "widget_meterscale") as Int)
		SetSliderDialogDefaultValue(50)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetFloatValue(File, "widget_meterscale", value )
		SetSliderOptionValueST(JsonUtil.GetFloatValue(File, "widget_meterscale") as int)
	endEvent
endState

;=============================================================
;Widget Colours
;=============================================================

state widgetcolors_0
	event OnColorOpenST()
		SetColorDialogStartColor(JsonUtil.StringListGet(File, "widgetcolors", 0) as int)
	endEvent

	event OnColorAcceptST(int value)
		JsonUtil.StringListSet(File, "widgetcolors", 0, value )
		SetColorOptionValueST(JsonUtil.StringListGet(File, "widgetcolors", 0) as int)
	endEvent
endState

state widgetcolors_1
	event OnColorOpenST()
		SetColorDialogStartColor(JsonUtil.StringListGet(File, "widgetcolors", 1) as int)
	endEvent

	event OnColorAcceptST(int value)
		JsonUtil.StringListSet(File, "widgetcolors", 1, value as string)
		SetColorOptionValueST(JsonUtil.StringListGet(File, "widgetcolors", 1) as int)
	endEvent
endState

state widgetcolors_2
	event OnColorOpenST()
		SetColorDialogStartColor(JsonUtil.StringListGet(File, "widgetcolors", 2) as int)
	endEvent

	event OnColorAcceptST(int value)
		JsonUtil.StringListSet(File, "widgetcolors", 2, value as string)
		SetColorOptionValueST(JsonUtil.StringListGet(File, "widgetcolors", 2) as int)
	endEvent
endState

state widgetcolors_3
	event OnColorOpenST()
		SetColorDialogStartColor(JsonUtil.StringListGet(File, "widgetcolors", 3) as int)
	endEvent

	event OnColorAcceptST(int value)
		JsonUtil.StringListSet(File, "widgetcolors", 3, value as string)
		SetColorOptionValueST(JsonUtil.StringListGet(File, "widgetcolors", 3) as int)
	endEvent
endState

state widgetcolors_4
	event OnColorOpenST()
		SetColorDialogStartColor(JsonUtil.StringListGet(File, "widgetcolors", 4) as int)
	endEvent

	event OnColorAcceptST(int value)
		JsonUtil.StringListSet(File, "widgetcolors", 4, value as string)
		SetColorOptionValueST(JsonUtil.StringListGet(File, "widgetcolors", 4) as int)
	endEvent
endState

state widgetcolors_5
	event OnColorOpenST()
		SetColorDialogStartColor(JsonUtil.StringListGet(File, "widgetcolors", 5) as int)
	endEvent

	event OnColorAcceptST(int value)
		JsonUtil.StringListSet(File, "widgetcolors", 5, value as string)
		SetColorOptionValueST(JsonUtil.StringListGet(File, "widgetcolors", 5) as int)
	endEvent
endState

state LabelColor
	event OnColorOpenST()
		SetColorDialogStartColor(JsonUtil.GetFloatValue(File, "widget_labelcolor", 16777215) as int)
	endEvent

	event OnColorAcceptST(int value)
		JsonUtil.SetFloatValue(File, "widget_labelcolor", value)
		SetColorOptionValueST(JsonUtil.GetFloatValue(File, "widget_labelcolor", 16777215) as int)
	endEvent
endState

state SelectedActorColor
	event OnColorOpenST()
		SetColorDialogStartColor(JsonUtil.GetFloatValue(File, "widget_selectedactorcolor", 16768768) as int)
	endEvent

	event OnColorAcceptST(int value)
		JsonUtil.SetFloatValue(File, "widget_selectedactorcolor", value)
		SetColorOptionValueST(JsonUtil.GetFloatValue(File, "widget_selectedactorcolor", 16768768) as int)
	endEvent
endState

;=============================================================
;Sound System
;=============================================================

state sl_voice_enjoymentbased
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "sl_voice_enjoymentbased") == 1
			JsonUtil.SetIntValue(File, "sl_voice_enjoymentbased", 0)
		else
			JsonUtil.SetIntValue(File, "sl_voice_enjoymentbased", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "sl_voice_enjoymentbased"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_voice_enjoymentbased_description")
	endEvent
endState

state sl_voice_playandwait
	event OnSelectST()
		if JsonUtil.GetIntValue(File, "sl_voice_playandwait") == 1
			JsonUtil.SetIntValue(File, "sl_voice_playandwait", 0)
		else
			JsonUtil.SetIntValue(File, "sl_voice_playandwait", 1)
		endif
		SetToggleOptionValueST(JsonUtil.GetIntValue(File, "sl_voice_playandwait"))
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_voice_playandwait_description")
	endEvent
endState

state sl_voice_reset
	event OnSelectST()
		;sl_voice_reset
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_voice_reset_description")
	endEvent
endState

;=============================================================
;Sliders
;=============================================================

state sl_voice_painswitch
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "sl_voice_painswitch"))
		SetSliderDialogDefaultValue(8)
		SetSliderDialogRange(0, 10)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "sl_voice_painswitch", value as int)
		SetSliderOptionValueST((value * 10) as int)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$sl_voice_painswitch_description")
	endEvent
endState

state sl_voice_player
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "sl_voice_player"))
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, ((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist).GetSize())
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "sl_voice_player", value as int)
		SetSliderOptionValueST(value as int)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$PC_voice_pack_description")
	endEvent
endState

state sl_voice_npc
	event OnSliderOpenST()
		SetSliderDialogStartValue(JsonUtil.GetIntValue(File, "sl_voice_npc"))
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-2, 0)	;((Game.GetFormFromFile(0x535D, "SLSO.esp") as formlist).GetAt(1) as formlist).GetSize())
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float value)
		JsonUtil.SetIntValue(File, "sl_voice_npc", value as int)
		SetSliderOptionValueST(value as int)
	endEvent
	
	event OnHighlightST()
		SetInfoText("$NPC_voice_pack_description")
	endEvent
endState

;state sl_voice_player_Menu
;	event OnMenuOpenST()
;		SetMenuDialogStartIndex(JsonUtil.GetIntValue(File, "sl_voice_player"))
;		SetMenuDialogDefaultIndex(0)
;		SetMenuDialogOptions(VoiceList)
;	endEvent
;
;	event OnMenuAcceptST(int index)
;		JsonUtil.SetIntValue(File, "sl_voice_player", index)
;		ForcePageReset()
;	endEvent
;
;	event OnHighlightST()
;		SetInfoText("$MME_MENU_PAGE_Debug_Milk_Maid_H1_S2_Higlight")
;	endEvent
;endState

;state sl_voice_npc_Menu
;	event OnMenuOpenST()
;		SetMenuDialogStartIndex(JsonUtil.GetIntValue(File, "sl_voice_npc"))
;		SetMenuDialogDefaultIndex(0)
;		SetMenuDialogOptions(VoiceList)
;	endEvent
;
;	event OnMenuAcceptST(int index)
;		JsonUtil.SetIntValue(File, "sl_voice_player", index)
;		ForcePageReset()
;	endEvent
;
;	event OnHighlightST()
;		SetInfoText("$MME_MENU_PAGE_Debug_Milk_Maid_H1_S2_Higlight")
;	endEvent
;endState
