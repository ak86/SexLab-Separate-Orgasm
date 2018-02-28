scriptname sslActorAlias extends ReferenceAlias

; Framework access
sslSystemConfig Config
sslActorLibrary ActorLib
sslActorStats Stats
Actor PlayerRef

; Actor Info
Actor property ActorRef auto hidden
ActorBase BaseRef
string ActorName
int BaseSex
int Gender
bool IsMale
bool IsFemale
bool IsCreature
bool IsVictim
bool IsAggressor
bool IsPlayer
bool IsTracked
bool IsSkilled
Faction AnimatingFaction

; Current Thread state
sslThreadController Thread
int Position
bool LeadIn

float StartWait
string StartAnimEvent
string EndAnimEvent
string ActorKey

; Voice
sslBaseVoice Voice
VoiceType ActorVoice
float BaseDelay
float VoiceDelay
bool IsForcedSilent
bool UseLipSync

; Expression
sslBaseExpression Expression

; Positioning
ObjectReference MarkerRef
float[] Offsets
float[] Center
float[] Loc

; Storage
int[] Flags
Form[] Equipment
bool[] StripOverride
float[] Skills

bool UseScale
float StartedAt
float ActorScale
float AnimScale
float LastOrgasm
float MusturbationMod
float ExhibitionistMod
float GenderMod
int BestRelation
int BaseEnjoyment
int Enjoyment
int ActorFullEnjoyment
int BonusEnjoyment
int Orgasms
int NthTranslation

Form Strapon
Form HadStrapon

Sound OrgasmFX

Spell HDTHeelSpell
Form HadBoots

Faction slaArousal
Faction slaExhibitionist
Bool bslaExhibitionist
Int slaExhibitionistNPCCount
Keyword zadDeviousBelt

; Animation Position/Stage flags
bool property OpenMouth hidden
	bool function get()
		return Flags[1] == 1
	endFunction
endProperty
bool property IsSilent hidden
	bool function get()
		return !Voice || IsForcedSilent || Flags[0] == 1 || Flags[1] == 1
	endFunction
endProperty
bool property UseStrapon hidden
	bool function get()
		return Flags[2] == 1 && Flags[4] == 0
	endFunction
endProperty
int property Schlong hidden
	int function get()
		return Flags[3]
	endFunction
endProperty
bool property MalePosition hidden
	bool function get()
		return Flags[4] == 0
	endFunction
endProperty

; ------------------------------------------------------- ;
; --- Load/Clear Alias For Use                        --- ;
; ------------------------------------------------------- ;

bool function SetActor(Actor ProspectRef)
	if !ProspectRef || ProspectRef != GetReference()
		return false ; Failed to set prospective actor into alias
	endIf
	; Init actor alias information
	ActorRef   = ProspectRef
	BaseRef    = ActorRef.GetLeveledActorBase()
	ActorName  = BaseRef.GetName()
	; ActorVoice = BaseRef.GetVoiceType()
	BaseSex    = BaseRef.GetSex()
	Gender     = ActorLib.GetGender(ActorRef)
	IsMale     = Gender == 0
	IsFemale   = Gender == 1
	IsCreature = Gender >= 2
	IsTracked  = Config.ThreadLib.IsActorTracked(ActorRef)
	IsPlayer   = ActorRef == PlayerRef
	; Player and creature specific
	If IsPlayer
		Thread.HasPlayer = true
	endIf
	if IsCreature
		Thread.CreatureRef = BaseRef.GetRace()
	elseIf !IsPlayer
		Stats.SeedActor(ActorRef)
	endIf
	; Actor's Adjustment Key
	ActorKey = MiscUtil.GetRaceEditorID(BaseRef.GetRace())
	if IsCreature
		ActorKey += "C"
	elseIf BaseSex == 1
		ActorKey += "F"
	else
		ActorKey += "M"
	endIf
	; Set base voice/loop delay
	if IsCreature
		BaseDelay  = 3.0
	elseIf IsFemale
		BaseDelay  = Config.FemaleVoiceDelay
	else
		BaseDelay  = Config.MaleVoiceDelay
	endIf
	VoiceDelay = BaseDelay
	; Init some needed arrays
	Flags   = new int[5]
	Offsets = new float[4]
	Loc     = new float[6]
	if Game.GetModByName("SexLabAroused.esm") != 255
		slaArousal = Game.GetFormFromFile(0x3FC36, "SexLabAroused.esm") As Faction
	endIf
	bslaExhibitionist = false
	slaExhibitionistNPCCount = 0
	if Game.GetModByName("SexLabAroused.esm") != 255
		slaExhibitionist = Game.GetFormFromFile(0x713DA, "SexLabAroused.esm") As Faction
		if slaExhibitionist != none
			if ActorRef.GetFactionRank(slaExhibitionist) >= 0
				bslaExhibitionist = true
			endif
		endif
	endIf
	String File = "/SLSO/Config.json"
	if JsonUtil.GetIntValue(File, "sl_exhibitionist") == 1
		Cell akTargetCell = ActorRef.GetParentCell()
		int iRef = 0
		while iRef <= akTargetCell.getNumRefs(43) && slaExhibitionistNPCCount < 6 ;GetType() 62-char,44-lvchar,43-npc
			Actor aNPC = akTargetCell.getNthRef(iRef, 43) as Actor
			If aNPC!= none && aNPC.GetDistance(ActorRef) < 500 && aNPC != ActorRef && aNPC.HasLOS(ActorRef)
				slaExhibitionistNPCCount += 1
			EndIf
			iRef = iRef + 1
		endWhile
	endif
	if Game.GetModByName("Devious Devices - Assets.esm") != 255
		zadDeviousBelt = Game.GetFormFromFile(0x3330, "Devious Devices - Assets.esm") As Keyword
	endif
	MusturbationMod = 1
	ExhibitionistMod = 1
	GenderMod = 1
	BonusEnjoyment = 0
	; Ready
	RegisterEvents()
	TrackedEvent("Added")
	GoToState("Ready")
	Log(self, "SetActor("+ActorRef+")")
	return true
endFunction

function ClearAlias()
	; Maybe got here prematurely, give it 10 seconds before forcing the clear
	if GetState() == "Resetting"
		float Failsafe = Utility.GetCurrentRealTime() + 10.0
		while GetState() == "Resetting" && Utility.GetCurrentRealTime() < Failsafe
			Utility.WaitMenuMode(0.2)
		endWhile
	endIf
	; Make sure actor is reset
	if GetReference()
		; Init variables needed for reset
		ActorRef   = GetReference() as Actor
		BaseRef    = ActorRef.GetLeveledActorBase()
		ActorName  = BaseRef.GetName()
		BaseSex    = BaseRef.GetSex()
		Gender     = ActorLib.GetGender(ActorRef)
		IsMale     = Gender == 0
		IsFemale   = Gender == 1
		IsCreature = Gender >= 2
		IsPlayer   = ActorRef == PlayerRef
		Log("Actor present during alias clear! This is usually harmless as the alias and actor will correct itself, but is usually a sign that a thread did not close cleanly.", "ClearAlias("+ActorRef+" / "+self+")")
		; Reset actor back to default
		ClearEffects()
		RestoreActorDefaults()
		StopAnimating(true)
		UnlockActor()
		Unstrip()
	endIf
	Initialize()
	GoToState("")
endFunction

; Thread/alias shares
bool DebugMode
bool SeparateOrgasms
int[] BedStatus
float[] RealTime
float[] SkillBonus
string AdjustKey
bool[] IsType

int Stage
int StageCount
string[] AnimEvents
sslBaseAnimation Animation

function LoadShares()
	DebugMode  = Config.DebugMode
	UseLipSync = Config.UseLipSync && !IsCreature
	UseScale   = !Config.DisableScale

	Center     = Thread.CenterLocation
	BedStatus  = Thread.BedStatus
	RealTime   = Thread.RealTime
	SkillBonus = Thread.SkillBonus
	AdjustKey  = Thread.AdjustKey
	IsType     = Thread.IsType
	LeadIn     = Thread.LeadIn
	AnimEvents = Thread.AnimEvents

	SeparateOrgasms = Config.SeparateOrgasms
	AnimatingFaction = Config.AnimatingFaction ; TEMP
endFunction

; ------------------------------------------------------- ;
; --- Actor Prepartion                                --- ;
; ------------------------------------------------------- ;


state Ready

	bool function SetActor(Actor ProspectRef)
		return false
	endFunction

	function PrepareActor()
		; Remove any unwanted combat effects
		ClearEffects()
		if IsPlayer
			Game.SetPlayerAIDriven()
		endIf
		ActorRef.SetFactionRank(AnimatingFaction, 1)
		ActorRef.EvaluatePackage()
		; Starting Information
		LoadShares()
		GetPositionInfo()
		IsAggressor = Thread.VictimRef && Thread.Victims.Find(ActorRef) == -1
		string LogInfo
		; Calculate scales
		if UseScale
			float display = ActorRef.GetScale()
			ActorRef.SetScale(1.0)
			float base = ActorRef.GetScale()
			ActorScale = ( display / base )
			AnimScale  = ActorScale
			ActorRef.SetScale(ActorScale)
			if Thread.ActorCount > 1 && Config.ScaleActors ; FIXME: || IsCreature?
				AnimScale = (1.0 / base)
			endIf
			LogInfo = "Scales["+display+"/"+base+"/"+AnimScale+"] "
		else
			AnimScale = 1.0
			LogInfo = "Scales["+ActorRef.GetScale()+"/ DISABLED] "
		endIf
		; Stop other movements
		if DoPathToCenter
			PathToCenter()
		endIf
		LockActor()
		; Pick a voice if needed
		if !Voice && !IsForcedSilent
			if IsCreature
				SetVoice(Config.VoiceSlots.PickByRaceKey(sslCreatureAnimationSlots.GetRaceKey(BaseRef.GetRace())), IsForcedSilent)
			else
				SetVoice(Config.VoiceSlots.PickVoice(ActorRef), IsForcedSilent)
			endIf
		endIf
		if Voice
			LogInfo += "Voice["+Voice.Name+"] "
		endIf
		; Player specific actions
		if IsPlayer
			FormList FrostExceptions = Config.FrostExceptions
			if FrostExceptions
				FrostExceptions.AddForm(Config.BaseMarker)
			endIf
		endIf
		; Extras for non creatures
		if !IsCreature
			; Decide on strapon for female, default to worn, otherwise pick random.
			if IsFemale && Config.UseStrapons
				HadStrapon = Config.WornStrapon(ActorRef)
				Strapon    = HadStrapon
				if !HadStrapon
					Strapon = Config.GetStrapon()
				endIf
			endIf
			; Strip actor
			Strip()
			ResolveStrapon()
			; Debug.SendAnimationEvent(ActorRef, "SOSFastErect")
			; Suppress High Heels
			if IsFemale && Config.RemoveHeelEffect && ActorRef.GetWornForm(0x00000080)
				; Remove NiOverride High Heels
				if Config.HasNiOverride && NiOverride.HasNodeTransformPosition(ActorRef, false, IsFemale, "NPC", "internal")
					float[] pos = NiOverride.GetNodeTransformPosition(ActorRef, false, IsFemale, "NPC", "internal")
					Log(pos, "RemoveHeelEffect (NiOverride)")
					pos[0] = -pos[0]
					pos[1] = -pos[1]
					pos[2] = -pos[2]
					NiOverride.AddNodeTransformPosition(ActorRef, false, IsFemale, "NPC", "SexLab.esm", pos)
					NiOverride.UpdateNodeTransform(ActorRef, false, IsFemale, "NPC")
				endIf
				; Remove HDT High Heels
				HDTHeelSpell = Config.GetHDTSpell(ActorRef)
				if HDTHeelSpell
					Log(HDTHeelSpell, "RemoveHeelEffect (HDTHeelSpell)")
					ActorRef.RemoveSpell(HDTHeelSpell)
				endIf
			endIf
			; Pick an expression if needed
			if !Expression && Config.UseExpressions
				Expression = Config.ExpressionSlots.PickByStatus(ActorRef, IsVictim, IsType[0] && !IsVictim)
			endIf
			if Expression
				LogInfo += "Expression["+Expression.Name+"] "
			endIf
		endIf
		IsSkilled = !IsCreature || sslActorStats.IsSkilled(ActorRef)
		if IsSkilled
			; Always use players stats for NPCS if present, so players stats mean something more
			Actor SkilledActor = ActorRef
			if !IsPlayer && Thread.HasPlayer 
				SkilledActor = PlayerRef
			; If a non-creature couple, base skills off partner
			elseIf Thread.ActorCount > 1 && !Thread.HasCreature
				SkilledActor = Thread.Positions[sslUtility.IndexTravel(Position, Thread.ActorCount)]
			endIf
			; Get sex skills of partner/player
			Skills       = Stats.GetSkillLevels(SkilledActor)
			BestRelation = Thread.GetHighestPresentRelationshipRank(ActorRef)
			if IsVictim
				BaseEnjoyment = Utility.RandomFloat(BestRelation, ((Skills[Stats.kLewd]*1.1) as int)) as int
			elseIf IsAggressor
				float OwnLewd = Stats.GetSkillLevel(ActorRef, Stats.kLewd)
				BaseEnjoyment = Utility.RandomFloat(OwnLewd, ((Skills[Stats.kLewd]*1.3) as int) + (OwnLewd*1.7)) as int
			else
				BaseEnjoyment = Utility.RandomFloat(BestRelation, ((Skills[Stats.kLewd]*1.5) as int) + (BestRelation*1.5)) as int
			endIf
			if BaseEnjoyment < 0
				BaseEnjoyment = 0
			elseIf BaseEnjoyment > 25
				BaseEnjoyment = 25
			endIf
		else
			BaseEnjoyment = Utility.RandomInt(0, 10)
		endIf
		LogInfo += "BaseEnjoyment["+BaseEnjoyment+"]"
		Log(LogInfo)
		; Play custom starting animation event
		if StartAnimEvent != ""
			Debug.SendAnimationEvent(ActorRef, StartAnimEvent)
		endIf
		if StartWait < 0.1
			StartWait = 0.1
		endIf
		GoToState("Prepare")
		RegisterForSingleUpdate(StartWait)
	endFunction

	function PathToCenter()
		ObjectReference CenterRef = Thread.CenterAlias.GetReference()
		if CenterRef && ActorRef && (Thread.ActorCount > 1 || CenterRef != ActorRef)
			ObjectReference WaitRef = CenterRef
			if CenterRef == ActorRef
				WaitRef = Thread.Positions[IntIfElse(Position != 0, 0, 1)]
			endIf
			float Distance = ActorRef.GetDistance(WaitRef)
			if WaitRef && Distance < 8000.0 && Distance > 135.0
				if CenterRef != ActorRef
					ActorRef.SetFactionRank(AnimatingFaction, 2)
					ActorRef.EvaluatePackage()
				endIf
				ActorRef.SetLookAt(WaitRef, true)
				float Failsafe = Utility.GetCurrentRealTime() + 15.0
				while Distance > 135.0 && Utility.GetCurrentRealTime() < Failsafe
					Utility.Wait(1.0)
					Distance = ActorRef.GetDistance(WaitRef)
					Log("Distance From WaitRef["+WaitRef+"]: "+Distance)
				endWhile
				ActorRef.ClearLookAt()
				if CenterRef != ActorRef
					ActorRef.SetFactionRank(AnimatingFaction, 1)
					ActorRef.EvaluatePackage()
				endIf
			endIf
		endIf
	endFunction

endState

state Prepare
	event OnUpdate()
		ClearEffects()
		GetPositionInfo()
		; Starting position
		OffsetCoords(Loc, Center, Offsets)
		MarkerRef.SetPosition(Loc[0], Loc[1], Loc[2])
		MarkerRef.SetAngle(Loc[3], Loc[4], Loc[5])
		ActorRef.SetPosition(Loc[0], Loc[1], Loc[2])
		ActorRef.SetAngle(Loc[3], Loc[4], Loc[5])
		AttachMarker()
		Debug.SendAnimationEvent(ActorRef, "SOSFastErect")
		; Notify thread prep is done
		if Thread.GetState() == "Prepare"
			Thread.SyncEventDone(kPrepareActor)
		else
			StartAnimating()
		endIf
	endEvent

	function StartAnimating()
		TrackedEvent("Start")
		; Remove from bard audience if in one
		Config.CheckBardAudience(ActorRef, true)
		; Prepare for loop
		StopAnimating(true)
		StartedAt  = Utility.GetCurrentRealTime()
		LastOrgasm = StartedAt
		GoToState("Animating")
		SyncAll(true)
		PlayingSA = Animation.Registry
		CurrentSA = Animation.Registry
		; Debug.SendAnimationEvent(ActorRef, Animation.FetchPositionStage(Position, 1))
		Debug.SendAnimationEvent(ActorRef, "IdleForceDefaultState")
		; If enabled, start Auto TFC for player
		if IsPlayer && Config.AutoTFC
			MiscUtil.SetFreeCameraState(true)
			MiscUtil.SetFreeCameraSpeed(Config.AutoSUCSM)
		endIf
		; Start update loop
		if Thread.GetState() == "Prepare"
			Thread.SyncEventDone(kStartup)
		else
			SendAnimation()
		endIf
		RegisterForSingleUpdate(Utility.RandomFloat(1.0, 3.0))
	endFunction
endState

; ------------------------------------------------------- ;
; --- Animation Loop                                  --- ;
; ------------------------------------------------------- ;


function SendAnimation()
endFunction

function GetPositionInfo()
	if ActorRef
		if !AdjustKey
			SetAdjustKey(Thread.AdjustKey)
		endIf
		LeadIn     = Thread.LeadIn
		Stage      = Thread.Stage
		Animation  = Thread.Animation
		StageCount = Animation.StageCount
		Flags      = Animation.PositionFlags(Flags, AdjustKey, Position, Stage)
		Offsets    = Animation.PositionOffsets(Offsets, AdjustKey, Position, Stage, BedStatus[1])
		CurrentSA  = Animation.Registry
		; AnimEvents[Position] = Animation.FetchPositionStage(Position, Stage)
	endIf
endFunction

string PlayingSA
string CurrentSA
float LoopDelay
state Animating

	function SendAnimation()
		; Reenter SA - On stage 1 while animation hasn't changed since last call
		if Stage == 1 && PlayingSA == CurrentSA
			Debug.SendAnimationEvent(ActorRef, "IdleForceDefaultState")
			Utility.WaitMenuMode(0.2)
			Debug.SendAnimationEvent(ActorRef, Animation.FetchPositionStage(Position, 1))
			; Debug.SendAnimationEvent(ActorRef, Animation.FetchPositionStage(Position, 1)+"_REENTER")
		else
			; Enter a new SA - Not necessary on stage 1 since both events would be the same
			if Stage != 1 && PlayingSA != CurrentSA
				Debug.SendAnimationEvent(ActorRef, Animation.FetchPositionStage(Position, 1))
				Utility.WaitMenuMode(0.2)
				; Log("NEW SA - "+Animation.FetchPositionStage(Position, 1))
			endIf
			; Play the primary animation
		 	Debug.SendAnimationEvent(ActorRef, AnimEvents[Position])
		 	; Log(AnimEvents[Position])
		endIf
		; Save id of last SA played
		PlayingSA = Animation.Registry
	endFunction

	event OnUpdate()
		; Pause further updates if in menu
		while Utility.IsInMenuMode()
			Utility.WaitMenuMode(1.5)
			StartedAt += 1.2
		endWhile
		; Check if still among the living and able.
		if !ActorRef.Is3DLoaded() || ActorRef.IsDisabled() || (ActorRef.IsDead() && ActorRef.GetActorValue("Health") < 1.0)
			Log("Actor is out of cell, disabled, or has no health - Unable to continue animating")
			Thread.EndAnimation(true)
			return
		endIf
		; Trigger orgasm
		;GetEnjoyment()
		if CalculateFullEnjoyment() >= 100 && SeparateOrgasms && (RealTime[0] - LastOrgasm) > 10.0
			OrgasmEffect()
		endIf
		; Lip sync and refresh expression
		if LoopDelay >= VoiceDelay
			LoopDelay = 0.0
			String File = "/SLSO/Config.json"
			if !IsSilent
				if !IsFemale
					Voice.PlayMoan(ActorRef, ActorFullEnjoyment, IsVictim, UseLipSync)
					;Log("  !IsFemale " + ActorName)
					RefreshExpression()
				elseif ((JsonUtil.GetIntValue(File, "sl_voice_player") == 0 && IsPlayer) || (JsonUtil.GetIntValue(File, "sl_voice_npc") == 0 && !IsPlayer))
					Voice.PlayMoan(ActorRef, ActorFullEnjoyment, IsVictim, UseLipSync)
					;Log("  IsFemale " + ActorName)
					RefreshExpression()
				endIf
			endIf
		endIf
		; Loop
		LoopDelay += (VoiceDelay * 0.35)
		RegisterForSingleUpdate(VoiceDelay * 0.35)
	endEvent

	function SyncThread()
		; Sync with thread info
		GetPositionInfo()
		VoiceDelay = BaseDelay
		if !IsSilent && Stage > 1
			VoiceDelay -= (Stage * 0.8) + Utility.RandomFloat(-0.2, 0.4)
		endIf
		if VoiceDelay < 0.8
			VoiceDelay = Utility.RandomFloat(0.8, 1.4) ; Can't have delay shorter than animation update loop
		endIf
		; Update alias info
		GetEnjoyment()
		; Sync status
		if !IsCreature
			ResolveStrapon()
			RefreshExpression()
		endIf
		Debug.SendAnimationEvent(ActorRef, "SOSBend"+Schlong)
		; SyncLocation(false)
	endFunction

	function SyncActor()
		SyncThread()
		SyncLocation(false)
		Thread.SyncEventDone(kSyncActor)
	endFunction

	function SyncAll(bool Force = false)
		SyncThread()
		SyncLocation(Force)
	endFunction

	function RefreshActor()
		UnregisterForUpdate()
		SyncThread()
		StopAnimating(true)
		SyncLocation(true)
		Debug.SendAnimationEvent(ActorRef, "SexLabSequenceExit1")
		Debug.SendAnimationEvent(ActorRef, "IdleForceDefaultState")
		Utility.WaitMenuMode(0.1)
		Debug.SendAnimationEvent(ActorRef, Animation.FetchPositionStage(Position, 1))
		PlayingSA = "SexLabSequenceExit1"
		Debug.SendAnimationEvent(ActorRef, "SexLabSequenceExit1")
		Debug.SendAnimationEvent(ActorRef, Animation.FetchPositionStage(Position, 1))
		PlayingSA = Animation.Registry
		CurrentSA = Animation.Registry
		SyncLocation(true)
		SendAnimation()
		RegisterForSingleUpdate(1.0)
		Thread.SyncEventDone(kRefreshActor)
	endFunction

	function RefreshLoc()
		Offsets = Animation.PositionOffsets(Offsets, AdjustKey, Position, Stage, BedStatus[1])
		SyncLocation(true)
	endFunction

	function SyncLocation(bool Force = false)
		OffsetCoords(Loc, Center, Offsets)
		MarkerRef.SetPosition(Loc[0], Loc[1], Loc[2])
		MarkerRef.SetAngle(Loc[3], Loc[4], Loc[5])
		; Avoid forcibly setting on player coords if avoidable - causes annoying graphical flickering
		if Force && IsPlayer && IsInPosition(ActorRef, MarkerRef, 40.0)
			AttachMarker()
			ActorRef.TranslateTo(Loc[0], Loc[1], Loc[2], Loc[3], Loc[4], Loc[5], 50000, 0)
			return ; OnTranslationComplete() will take over when in place
		elseIf Force
			ActorRef.SetPosition(Loc[0], Loc[1], Loc[2])
			ActorRef.SetAngle(Loc[3], Loc[4], Loc[5])
		endIf
		AttachMarker()
		Snap()
	endFunction

	function Snap()
		; Quickly move into place and angle if actor is off by a lot
		float distance = ActorRef.GetDistance(MarkerRef)
		if distance > 125.0 || !IsInPosition(ActorRef, MarkerRef, 75.0)
			ActorRef.SetPosition(Loc[0], Loc[1], Loc[2])
			ActorRef.SetAngle(Loc[3], Loc[4], Loc[5])
			AttachMarker()
		elseIf distance > 2.0
			ActorRef.TranslateTo(Loc[0], Loc[1], Loc[2], Loc[3], Loc[4], Loc[5], 50000, 0.0)
			return ; OnTranslationComplete() will take over when in place
		endIf
		; Begin very slowly rotating a small amount to hold position
		ActorRef.TranslateTo(Loc[0], Loc[1], Loc[2], Loc[3], Loc[4], Loc[5]+0.01, 500.0, 0.0001)
	endFunction

	event OnTranslationComplete()
		; Log("OnTranslationComplete")
		Snap()
	endEvent

	;/ event OnTranslationFailed()
		Log("OnTranslationFailed")
		; SyncLocation(false)
	endEvent /;

	function OrgasmEffect(bool Force = false)
		if Math.Abs(Utility.GetCurrentRealTime() - LastOrgasm) < 5.0
			Log("Excessive OrgasmEffect Triggered")
			return
		endIf
		String File = "/SLSO/Config.json"
		If !Force
			if LeadIn && JsonUtil.GetIntValue(File, "condition_leadin_orgasm") == 0
				Log("OrgasmEffect Triggered, orgasms disabled at LeadIn/Foreplay Stage")
				return
			endIf
			if IsPlayer && JsonUtil.GetIntValue(File, "condition_player_orgasm") == 0
				Log("OrgasmEffect Triggered, player is forbidden to orgasm")
				return
			endIf
			if JsonUtil.GetIntValue(File, "condition_ddbelt_orgasm") == 0
				if zadDeviousBelt != none
					if ActorRef.WornHasKeyword(zadDeviousBelt)
						Log("OrgasmEffect Triggered, ActorRef has DD belt prevent orgasming")
						return
					EndIf
				endIf
			endIf
			if IsVictim
				if JsonUtil.GetIntValue(File, "condition_victim_orgasm") == 0
					Log("OrgasmEffect Triggered, ActorRef is victim, victim forbidden to orgasm")
					return
				elseif JsonUtil.GetIntValue(File, "condition_victim_orgasm") == 2
					if (Stats.GetSkillLevel(ActorRef, Stats.kLewd)*10) as int < Utility.RandomInt(0, 100)
						Log("OrgasmEffect Triggered, ActorRef is victim, victim didn't pass lewd check to orgasm")
						return
					endIf
				endIf
			endIf
			if !IsAggressor
				if !(Animation.HasTag("69") || Animation.HasTag("Masturbation")) || Thread.Positions.Length == 2
					if  IsFemale && JsonUtil.GetIntValue(File, "condition_female_orgasm") == 1
						if Position == 0 && !(Animation.HasTag("Vaginal") || Animation.HasTag("Anal") || Animation.HasTag("Cunnilingus") || Animation.HasTag("Fisting") || Animation.HasTag("Lesbian"))
							Log("OrgasmEffect Triggered, female pos 0, conditions not met, no HasTag(Vaginal,Anal,Cunnilingus,Fisting)")
							return
						endIf
					elseif IsMale && JsonUtil.GetIntValue(File, "condition_male_orgasm") == 1
						if Position == 0 && !(Animation.HasTag("Anal") || Animation.HasTag("Fisting"))
							Log("OrgasmEffect Triggered, male pos 0, conditions not met, no HasTag(Anal,Fisting)")
							return
						elseif Position != 0 && !(Animation.HasTag("Vaginal") || Animation.HasTag("Anal") || Animation.HasTag("Boobjob") || Animation.HasTag("Blowjob") || Animation.HasTag("Handjob") || Animation.HasTag("Footjob"))
							Log("OrgasmEffect Triggered, male pos > 0, conditions not met, no HasTag(Vaginal,Anal,Boobjob,Blowjob,Handjob,Footjob)")
							return
						endIf
					endIf
				endIf
			endIf
		endIf
		
		UnregisterForUpdate()
		Orgasms   += 1
		
		if (Utility.RandomInt(0, 100) > (JsonUtil.GetIntValue(File, "sl_multiorgasmchance") + ((Skills[Stats.kLewd]*10) as int) - 5 * Orgasms)) || BaseSex != 1
			LastOrgasm = Math.Abs(Utility.GetCurrentRealTime())
			; Reset enjoyment build up, if using separate orgasms
			if Config.SeparateOrgasms
				BaseEnjoyment = BaseEnjoyment - Enjoyment
				BaseEnjoyment += Utility.RandomInt((BestRelation + 10), PapyrusUtil.ClampInt(((Skills[Stats.kLewd]*1.5) as int) + (BestRelation + 10), 10, 35))
			endIf
			BonusEnjoyment = 0
		else
			LastOrgasm = Math.Abs(Utility.GetCurrentRealTime() - 9)
		endIf
		
		; Send an orgasm event hook with actor and orgasm count
		int eid = ModEvent.Create("SexLabOrgasm")
		ModEvent.PushForm(eid, ActorRef)
		ModEvent.PushInt(eid, GetEnjoyment())
		ModEvent.PushInt(eid, Orgasms)
		ModEvent.Send(eid)
		
		int Seid = ModEvent.Create("SexLabOrgasmSeparate")
		if Seid
			ModEvent.PushForm(Seid, ActorRef)
			ModEvent.PushInt(Seid, Thread.tid)
			ModEvent.Send(Seid)
		endif

		TrackedEvent("Orgasm")
		Log("Orgasms["+Orgasms+"] Enjoyment ["+Enjoyment+"] BaseEnjoyment["+BaseEnjoyment+"] FullEnjoyment["+ActorFullEnjoyment+"]")
		if Config.OrgasmEffects
			; Shake camera for player
			if IsPlayer && Game.GetCameraState() >= 8
				Game.ShakeCamera(none, 1.00, 2.0)
			endIf
			; Play SFX/Voice
			if !IsSilent
				if !IsFemale
					PlayLouder(Voice.GetSound(100, false), ActorRef, Config.VoiceVolume)
				elseif ((JsonUtil.GetIntValue(File, "sl_voice_player") == 0 && IsPlayer) || (JsonUtil.GetIntValue(File, "sl_voice_npc") == 0 && !IsPlayer))
					PlayLouder(Voice.GetSound(100, false), ActorRef, Config.VoiceVolume)
				endIf
			endIf
			PlayLouder(OrgasmFX, MarkerRef, Config.SFXVolume)
		endIf
		; Apply cum to female positions from male position orgasm
		int i = Thread.ActorCount
		if i > 1 && Config.UseCum && (MalePosition || IsCreature) && (IsMale || IsCreature || (Config.AllowFFCum && IsFemale))
			if i == 2
				Thread.PositionAlias(IntIfElse(Position == 1, 0, 1)).ApplyCum()
			else
				while i > 0
					i -= 1
					if Position != i && Animation.IsCumSource(Position, i, Stage)
						Thread.PositionAlias(i).ApplyCum()
					endIf
				endWhile
			endIf
		endIf
		Utility.WaitMenuMode(0.2)
		; VoiceDelay = 0.8
		RegisterForSingleUpdate(0.8)
	endFunction

	event ResetActor()
		ClearEvents()
		GoToState("Resetting")
		Log("Resetting!")
		; Clear TFC
		if IsPlayer
			MiscUtil.SetFreeCameraState(false)
		endIf
		; Update stats
		if IsSkilled
			Actor VictimRef = Thread.VictimRef
			if IsVictim
				VictimRef = ActorRef
			endIf
			sslActorStats.RecordThread(ActorRef, Gender, BestRelation, StartedAt, Utility.GetCurrentRealTime(), Utility.GetCurrentGameTime(), Thread.HasPlayer, VictimRef, Thread.Genders, Thread.SkillXP)
			Stats.AddPartners(ActorRef, Thread.Positions, Thread.Victims)
		endIf
		; Apply cum
		;/ int CumID = Animation.GetCum(Position)
		if CumID > 0 && !Thread.FastEnd && Config.UseCum && (Thread.Males > 0 || Config.AllowFFCum || Thread.HasCreature)
			ActorLib.ApplyCum(ActorRef, CumID)
		endIf /;
		; Tracked events
		TrackedEvent("End")
		StopAnimating(Thread.FastEnd, EndAnimEvent)
		RestoreActorDefaults()
		UnlockActor()
		; Unstrip items in storage, if any
		if !IsCreature && !ActorRef.IsDead()
			Unstrip()
			; Add back high heel effects
			if Config.RemoveHeelEffect
				; HDT High Heel
				if HDTHeelSpell && ActorRef.GetWornForm(0x00000080) && !ActorRef.HasSpell(HDTHeelSpell)
					ActorRef.AddSpell(HDTHeelSpell)
				endIf
				; NiOverride High Heels
				if Config.HasNiOverride && NiOverride.RemoveNodeTransformPosition(ActorRef, false, IsFemale, "NPC", "SexLab.esm")
					NiOverride.UpdateNodeTransform(ActorRef, false, IsFemale, "NPC")
				endIf
			endIf
		endIf
		; Free alias slot
		Clear()
		GoToState("")
		Thread.SyncEventDone(kResetActor)
	endEvent
endState

state Resetting
	function ClearAlias()
	endFunction
	event OnUpdate()
	endEvent
	function Initialize()
	endFunction
endState

function SyncAll(bool Force = false)
endFunction

; ------------------------------------------------------- ;
; --- Actor Manipulation                              --- ;
; ------------------------------------------------------- ;

function StopAnimating(bool Quick = false, string ResetAnim = "IdleForceDefaultState")
	if !ActorRef
		return
	endIf
	; Disable free camera, if in it
	; if IsPlayer
	; 	MiscUtil.SetFreeCameraState(false)
	; endIf
	; Clear possibly troublesome effects
	ActorRef.StopTranslation()
	ActorRef.SetVehicle(none)
	; Stop animevent
	if IsCreature
		; Reset creature idle
		Debug.SendAnimationEvent(ActorRef, "Reset")
		Debug.SendAnimationEvent(ActorRef, "ReturnToDefault")
		Debug.SendAnimationEvent(ActorRef, "FNISDefault")
		Debug.SendAnimationEvent(ActorRef, "IdleReturnToDefault")
		Debug.SendAnimationEvent(ActorRef, "ForceFurnExit")
		if ResetAnim != "IdleForceDefaultState" && ResetAnim != ""
			ActorRef.Moveto(ActorRef)
			ActorRef.PushActorAway(ActorRef, 0.75)
		endIf
	else
		; Reset NPC/PC Idle Quickly
		Debug.SendAnimationEvent(ActorRef, ResetAnim)
		Utility.Wait(0.1)
		; Ragdoll NPC/PC if enabled and not in TFC
		if !Quick && ResetAnim != "" && DoRagdoll && (!IsPlayer || (IsPlayer && Game.GetCameraState() != 3))
			ActorRef.Moveto(ActorRef)
			ActorRef.PushActorAway(ActorRef, 0.1)
		endIf
	endIf
	PlayingSA = "SexLabSequenceExit1"
endFunction

function AttachMarker()
	ActorRef.SetVehicle(MarkerRef)
	if UseScale
		ActorRef.SetScale(AnimScale)
	endIf
endFunction

function LockActor()
	if !ActorRef
		return
	endIf
	; Remove any unwanted combat effects
	ClearEffects()
	; Stop whatever they are doing
	; Debug.SendAnimationEvent(ActorRef, "IdleForceDefaultState")
	; Start DoNothing package
	ActorUtil.AddPackageOverride(ActorRef, Config.DoNothing, 100, 1)
	ActorRef.SetFactionRank(AnimatingFaction, 1)
	ActorRef.EvaluatePackage()
	; Disable movement
	if IsPlayer
		if Game.GetCameraState() == 0
			Game.ForceThirdPerson()
		endIf
		; abMovement = true, abFighting = true, abCamSwitch = false, abLooking = false, abSneaking = false, abMenu = true, abActivate = true, abJournalTabs = false, aiDisablePOVType = 0
		;Game.DisablePlayerControls(true, true, false, false, false, false, false, false, 0) 		;SLSO: sexlab disables ui, we dont want that
		Game.SetPlayerAIDriven()
		; Enable hotkeys if needed, and disable autoadvance if not needed
		if IsVictim && Config.DisablePlayer
			Thread.AutoAdvance = true
		else
			Thread.AutoAdvance = Config.AutoAdvance
			Thread.EnableHotkeys()
		endIf
	else
		ActorRef.SetRestrained(true)
		ActorRef.SetDontMove(true)
	endIf
	; Attach positioning marker
	if !MarkerRef
		MarkerRef = ActorRef.PlaceAtMe(Config.BaseMarker)
		int cycle
		while !MarkerRef.Is3DLoaded() && cycle < 50
			Utility.Wait(0.1)
			cycle += 1
		endWhile
		if cycle
			Log("Waited ["+cycle+"] cycles for MarkerRef["+MarkerRef+"]")
		endIf
	endIf
	MarkerRef.Enable()
	ActorRef.StopTranslation()
	MarkerRef.MoveTo(ActorRef)
	AttachMarker()
endFunction

function UnlockActor()
	if !ActorRef
		return
	endIf
	; Detach positioning marker
	ActorRef.StopTranslation()
	ActorRef.SetVehicle(none)
	; Remove from animation faction
	ActorRef.RemoveFromFaction(AnimatingFaction)
	ActorUtil.RemovePackageOverride(ActorRef, Config.DoNothing)
	ActorRef.SetFactionRank(AnimatingFaction, 0)
	ActorRef.EvaluatePackage()
	; Enable movement
	if IsPlayer
		Thread.DisableHotkeys()
		MiscUtil.SetFreeCameraState(false)
		Game.EnablePlayerControls(true, true, false, false, false, false, false, false, 0)
		Game.SetPlayerAIDriven(false)
	else
		ActorRef.SetRestrained(false)
		ActorRef.SetDontMove(false)
	endIf
endFunction

function RestoreActorDefaults()
	; Make sure  have actor, can't afford to miss this block
	if !ActorRef
		ActorRef = GetReference() as Actor
		if !ActorRef
			return ; No actor, reset prematurely or bad call to alias
		endIf
	endIf	
	; Reset to starting scale
	if UseScale && ActorScale > 0.0
		ActorRef.SetScale(ActorScale)
	endIf
	if !IsCreature
		; Reset voicetype
		; if ActorVoice && ActorVoice != BaseRef.GetVoiceType()
		; 	BaseRef.SetVoiceType(ActorVoice)
		; endIf
		; Remove strapon
		if Strapon && !HadStrapon; && Strapon != HadStrapon
			ActorRef.RemoveItem(Strapon, 1, true)
		endIf
		; Reset expression
		ActorRef.ClearExpressionOverride()
		MfgConsoleFunc.SetPhonemeModifier(ActorRef, -1, 0, 0)
	endIf
	; Player specific actions
	if IsPlayer
		; Remove player from frostfall exposure exception
		FormList FrostExceptions = Config.FrostExceptions
		if FrostExceptions
			FrostExceptions.RemoveAddedForm(Config.BaseMarker)
		endIf
	endIf
	; Clear from animating faction
	ActorRef.SetFactionRank(AnimatingFaction, -1)
	ActorRef.RemoveFromFaction(AnimatingFaction)
	ActorUtil.RemovePackageOverride(ActorRef, Config.DoNothing)
	ActorRef.EvaluatePackage()
	; Remove SOS erection
	Debug.SendAnimationEvent(ActorRef, "SOSFlaccid")
endFunction

function RefreshActor()
endFunction

; ------------------------------------------------------- ;
; --- Data Accessors                                  --- ;
; ------------------------------------------------------- ;

int function GetGender()
	return Gender
endFunction

function SetVictim(bool Victimize)
	Actor[] Victims = Thread.Victims
	; Make victim
	if Victimize && (!Victims || Victims.Find(ActorRef) == -1)
		Victims = PapyrusUtil.PushActor(Victims, ActorRef)
		Thread.Victims = Victims
		Thread.IsAggressive = true
	; Was victim but now isn't, update thread
	elseIf IsVictim && !Victimize
		Victims = PapyrusUtil.RemoveActor(Victims, ActorRef)
		Thread.Victims = Victims
		if !Victims || Victims.Length < 1
			Thread.IsAggressive = false
		endIf
	endIf
	IsVictim = Victimize
endFunction

bool function IsVictim()
	return IsVictim
endFunction

bool function IsCreature()
	return IsCreature
endFunction

bool function IsAggressor()
	return IsAggressor
endFunction

bool function IsSilent()
	return IsSilent
endFunction

string function GetActorKey()
	return ActorKey
endFunction

function SetAdjustKey(string KeyVar)
	if ActorRef
		AdjustKey = KeyVar
		Position  = Thread.Positions.Find(ActorRef)
	endIf
endfunction

string function GetActorName()
	return ActorName
endFunction

int function GetEnjoyment()
	String File = "/SLSO/Config.json"
	if !ActorRef
		Enjoyment = 0
	elseif !IsSkilled
		if JsonUtil.GetIntValue(File, "sl_passive_enjoyment") == 1 || Thread.ActorCount > 2  || !Thread.HasPlayer || JsonUtil.GetIntValue(File, "game_enabled") != 1
			if JsonUtil.GetIntValue(File, "sl_stage_enjoyment") == 1 || !Thread.HasPlayer || JsonUtil.GetIntValue(File, "game_enabled") != 1
				Enjoyment = (PapyrusUtil.ClampFloat(((RealTime[0] - StartedAt) + 1.0) / 5.0, 0.0, 40.0) + ((Stage as float / StageCount as float) * 60.0)) as int
			else
				Enjoyment = (PapyrusUtil.ClampFloat(((RealTime[0] - StartedAt) + 1.0) / 5.0, 0.0, 40.0)) as int
			endIf
			if IsAggressor && Orgasms == 0 && JsonUtil.GetIntValue(File, "sl_agressor_bonus_enjoyment") == 1
				Enjoyment += (PapyrusUtil.ClampFloat(((RealTime[0] - StartedAt) + 1.0) / 5.0, 0.0, 40.0)) as int
				;Log("!IsSkilled, IsAggressor, Orgasms == 0, boosting enjoyment by "+(PapyrusUtil.ClampFloat(((RealTime[0] - StartedAt) + 1.0) / 5.0, 0.0, 40.0)) as int+"]")
			endIf
		endIf
	else
		if Position == 0
			Thread.RecordSkills()
			Thread.SetBonuses()
		endIf
		if JsonUtil.GetIntValue(File, "sl_passive_enjoyment") == 1 || Thread.ActorCount > 2 || !Thread.HasPlayer || JsonUtil.GetIntValue(File, "game_enabled") != 1
			if JsonUtil.GetIntValue(File, "sl_stage_enjoyment") == 1 || !Thread.HasPlayer || JsonUtil.GetIntValue(File, "game_enabled") != 1
				Enjoyment = BaseEnjoyment + CalcEnjoyment(SkillBonus, Skills, LeadIn, IsFemale, (RealTime[0] - StartedAt), Stage, StageCount)
			else
				Enjoyment = BaseEnjoyment + CalcEnjoyment(SkillBonus, Skills, LeadIn, IsFemale, (RealTime[0] - StartedAt), 0, StageCount)
			endIf
			if IsAggressor && Orgasms == 0 && JsonUtil.GetIntValue(File, "sl_agressor_bonus_enjoyment") == 1
				Enjoyment += CalcEnjoyment(SkillBonus, Skills, LeadIn, IsFemale, (RealTime[0] - StartedAt), 0, 0)
				;Log("IsSkilled, IsAggressor, Orgasms == 0, boosting enjoyment by "+CalcEnjoyment(SkillBonus, Skills, LeadIn, IsFemale, (RealTime[0] - StartedAt), 0, 0)+"]")
			endIf
			;Log("Enjoyment["+Enjoyment+"] / BaseEnjoyment["+BaseEnjoyment+"] / FullEnjoyment["+(Enjoyment - BaseEnjoyment)+"]")
			if Enjoyment < 0
				Enjoyment = 0
			elseIf Enjoyment > 100
				Enjoyment = 100
			endIf
		endIf
	endIf
	return Enjoyment - BaseEnjoyment
endFunction

int function GetFullEnjoyment()
	return ActorFullEnjoyment
endFunction

float function GetFullEnjoymentMod()
	String File = "/SLSO/Config.json"
	return 	100*MusturbationMod/ExhibitionistMod/GenderMod
endFunction

int function CalculateFullEnjoyment()
	;this can be very script heavy, don't call it unless you absolutely have to, use GetFullEnjoyment()
	int slaActorArousal = 0
	String File = "/SLSO/Config.json"

	if JsonUtil.GetIntValue(File, "sl_sla_arousal") == 2 || JsonUtil.GetIntValue(File, "sl_sla_arousal") == 3
		if slaArousal != none
			slaActorArousal = ActorRef.GetFactionRank(slaArousal)
		else 
			slaActorArousal = 0
		endIf
	endIf

	int FullEnjoyment = (GetEnjoyment() + BaseEnjoyment + slaActorArousal + BonusEnjoyment)
	
	float sl_enjoymentrate = 1
	
	if BaseSex == 0
		sl_enjoymentrate = JsonUtil.GetFloatValue(File, "sl_enjoymentrate_male", missing = 1)
		if JsonUtil.GetIntValue(File, "condition_male_orgasm") == 1
			;male wont be able to orgasm 2nd time if slso game() and sla disabled
			;Log("male FullEnjoyment MOD["+(FullEnjoyment-FullEnjoyment / (1 + GetOrgasmCount()*2)) as int+"]")
			if (Position == 0 && !(Animation.HasTag("Anal") || Animation.HasTag("Fisting"))) || Position != 0
				GenderMod = (1 + GetOrgasmCount()*2)
			endif
		endif
	else
		sl_enjoymentrate = JsonUtil.GetFloatValue(File, "sl_enjoymentrate_female", missing = 1)
	endif
	
	If JsonUtil.GetIntValue(File, "game_enabled") == 1 || JsonUtil.GetIntValue(File, "sl_sla_arousal") >= 2
	;character most likely wont be able to orgasm without slso game(), sla arousal and with below conditions on
		if JsonUtil.GetIntValue(File, "sl_exhibitionist") > 0
			if JsonUtil.GetIntValue(File, "sl_exhibitionist") == 2
				Cell akTargetCell = ActorRef.GetParentCell()
				int iRef = 0
				slaExhibitionistNPCCount = 0
				while iRef <= akTargetCell.getNumRefs(43) && slaExhibitionistNPCCount < 6 ;GetType() 62-char,44-lvchar,43-npc
					Actor aNPC = akTargetCell.getNthRef(iRef, 43) as Actor
					If aNPC!= none && aNPC.GetDistance(ActorRef) < 500 && aNPC != ActorRef && aNPC.HasLOS(ActorRef)
						slaExhibitionistNPCCount += 1
					EndIf
					iRef = iRef + 1
				endWhile
			endif
			if bslaExhibitionist || Skills[Stats.kLewd] > 5
				;Log("slaExhibitionistNPCCount ["+slaExhibitionistNPCCount+"] FullEnjoyment MOD["+(FullEnjoyment-FullEnjoyment / (3 - 0.4 * slaExhibitionistNPCCount)) as int+"]")
				ExhibitionistMod = (3 - 0.4 * slaExhibitionistNPCCount)
			elseif slaExhibitionistNPCCount > 1 && !IsAggressor
				;Log("slaExhibitionistNPCCount ["+slaExhibitionistNPCCount+"] FullEnjoyment MOD["+(FullEnjoyment-FullEnjoyment / (1 + 0.2 * slaExhibitionistNPCCount)) as int+"]")
				ExhibitionistMod = (1 + 0.2 * slaExhibitionistNPCCount)
			endif
		endif

		if JsonUtil.GetIntValue(File, "sl_masturbation") == 1
			if Thread.ActorCount == 1
				;Log("masturbation_penalty FullEnjoyment MOD["+(FullEnjoyment-FullEnjoyment * (1 - 1 * (Skills[Stats.kLewd]) / 10)) as int+"]")
				if Animation.HasTag("Estrus")				;Estrus
					MusturbationMod = 1 + 1 * (Skills[Stats.kLewd]) / 10
				else										;normal
					MusturbationMod = 1 - 1 * (Skills[Stats.kLewd]) / 10
				endif
				MusturbationMod = PapyrusUtil.ClampFloat(MusturbationMod, 0.1, 2.0)
			endif
		endif
	Endif
	;Log("SL Enjoyment ["+Enjoyment+"] SL BaseEnjoyment["+BaseEnjoyment+"] SLArousal["+slaActorArousal+"]"+"] BonusEnjoyment["+BonusEnjoyment+"]"+"] FullEnjoyment["+FullEnjoyment+"]")
	ActorFullEnjoyment = (FullEnjoyment * MusturbationMod / ExhibitionistMod / GenderMod * sl_enjoymentrate) as int
	return ActorFullEnjoyment
endFunction

function BonusEnjoyment(actor Ref = none, int experience = 0)
	if self.GetState() == "Animating"
		int slaActorArousal = 0
		String File = "/SLSO/Config.json"
		if JsonUtil.GetIntValue(File, "sl_sla_arousal") == 1 || JsonUtil.GetIntValue(File, "sl_sla_arousal") == 3
			if slaArousal != none
				slaActorArousal = ActorRef.GetFactionRank(slaArousal)
			else 
				slaActorArousal = 0
			endIf
		endIf
		slaActorArousal = PapyrusUtil.ClampInt(slaActorArousal/20, 1, 5)
		;Log("SLArousal mod["+slaActorArousal+"]"+"] BonusEnjoyment["+(BonusEnjoyment+slaActorArousal)+"] experience["+experience+"]")
		if experience < 0
			;reduce enjoyment by fixed value
			BonusEnjoyment += experience
			;Log("reduce BonusEnjoyment["+BonusEnjoyment+"] experience["+experience+"]")
		elseif Ref == ActorRef && experience > 0
			;increase enjoyment by fixed value
			BonusEnjoyment += experience
			;Log("increase BonusEnjoyment["+BonusEnjoyment+"] experience["+experience+"]")
		elseif Ref == ActorRef || Thread.ActorCount != 2
			;increase own enjoyment
			if BaseSex == 0
				BonusEnjoyment	+=slaActorArousal
			elseif JsonUtil.GetIntValue(File, "condition_female_orgasm_bonus") != 1
				BonusEnjoyment	+=slaActorArousal
			else
				BonusEnjoyment	+=slaActorArousal + GetOrgasmCount()
			endif
			;Log(" BonusEnjoyment from self/other actor or animation has more than 2 actors: increase own enjoyment")
		elseif Thread.ActorCount == 2
			;increase partner enjoyment, + fixed value 
			if Thread.ActorAlias(Thread.Positions[sslUtility.IndexTravel(Position, Thread.ActorCount)]) != none && Thread.ActorAlias(Thread.Positions[sslUtility.IndexTravel(Position, Thread.ActorCount)]) != none
				Thread.ActorAlias(Thread.Positions[sslUtility.IndexTravel(Position, Thread.ActorCount)]).BonusEnjoyment(Thread.ActorAlias(Thread.Positions[sslUtility.IndexTravel(Position, Thread.ActorCount)]).GetActorRef(), experience)
				;Log(" BonusEnjoyment triggered, sending event to other actor")
			endIf
		else
			Log(" SLSO BonusEnjoyment: Something went wrong")
		endIf
	endIf
endFunction

function Orgasm(float experience = 0.0)
	if experience == -2
		LastOrgasm = Math.Abs(RealTime[0] - 11)
		OrgasmEffect(true)
	elseif ActorFullEnjoyment >= 90
		if experience == -1
			LastOrgasm = Math.Abs(RealTime[0] - 11)
		endIf
		if Math.Abs(RealTime[0] - LastOrgasm) > 10.0
			OrgasmEffect()
		endIf
	endIf
endFunction

function HoldOut(float experience = 0.0)
	if Position == 0
		if  IsFemale 
			if (Animation.HasTag("Vaginal" || Animation.HasTag("Fisting") || Animation.HasTag("69")))
				LastOrgasm = Math.Abs(RealTime[0] - 8 + Skills[Stats.kVaginal] + experience)
				BonusEnjoyment(ActorRef, (- 1 - Skills[Stats.kVaginal]) as int)
			elseif(Animation.HasTag("Anal") || Animation.HasTag("Fisting"))
				LastOrgasm = Math.Abs(RealTime[0] - 8 + Skills[Stats.kAnal] + experience)
				BonusEnjoyment(ActorRef, (-1 - Skills[Stats.kAnal]) as int)
			else
				LastOrgasm = Math.Abs(RealTime[0] - 8 + experience)
				BonusEnjoyment(ActorRef, -1)
			endIf
		elseif IsMale
			if (Animation.HasTag("Anal") || Animation.HasTag("Fisting"))
				LastOrgasm = Math.Abs(RealTime[0] - 8 + Skills[Stats.kAnal] + experience)
				BonusEnjoyment(ActorRef, (-1 - Skills[Stats.kAnal]) as int)
			else
				LastOrgasm = Math.Abs(RealTime[0] - 8 + experience)
				BonusEnjoyment(ActorRef, -1)
			endIf
		endIf
	elseif Position == 1
		LastOrgasm = Math.Abs(RealTime[0] - 8 + experience)
		BonusEnjoyment(ActorRef, -1)
	endIf
endFunction

int function GetOrgasmCount()
	if !ActorRef
		Orgasms = 0
	endIf
	return Orgasms
endFunction

function SetOrgasmCount(int SetOrgasms = 0)
	if SetOrgasms >=0
		Orgasms = SetOrgasms
	endIf
endFunction

function ApplyCum()
	if ActorRef
		int CumID = Animation.GetCumID(Position, Stage)
		if CumID > 0
			ActorLib.ApplyCum(ActorRef, CumID)
		endIf
	endIf
endFunction

int function GetPain()
	if !ActorRef
		return 0
	endIf
	float Pain = Math.Abs(100.0 - PapyrusUtil.ClampFloat(GetEnjoyment() as float, 1.0, 99.0))
	if IsVictim
		Pain *= 1.5
	elseIf Animation.HasTag("Aggressive") || Animation.HasTag("Rough")
		Pain *= 0.8
	else
		Pain *= 0.3
	endIf
	return PapyrusUtil.ClampInt(Pain as int, 0, 100)
endFunction

function SetVoice(sslBaseVoice ToVoice = none, bool ForceSilence = false)
	IsForcedSilent = ForceSilence
	if ToVoice && IsCreature == ToVoice.Creature
		Voice = ToVoice
	endIf
endFunction

sslBaseVoice function GetVoice()
	return Voice
endFunction

function SetExpression(sslBaseExpression ToExpression)
	if ToExpression
		Expression = ToExpression
	endIf
endFunction

sslBaseExpression function GetExpression()
	return Expression
endFunction

function SetStartAnimationEvent(string EventName, float PlayTime)
	StartAnimEvent = EventName
	StartWait = PapyrusUtil.ClampFloat(PlayTime, 0.1, 10.0)
endFunction

function SetEndAnimationEvent(string EventName)
	EndAnimEvent = EventName
endFunction

bool function IsUsingStrapon()
	return Strapon && ActorRef.IsEquipped(Strapon)
endFunction

function ResolveStrapon(bool force = false)
	if Strapon
		if UseStrapon && !ActorRef.IsEquipped(Strapon)
			ActorRef.EquipItem(Strapon, true, true)
		elseIf !UseStrapon && ActorRef.IsEquipped(Strapon)
			ActorRef.UnequipItem(Strapon, true, true)
		endIf
	endIf
endFunction

function EquipStrapon()
	if Strapon && !ActorRef.IsEquipped(Strapon)
		ActorRef.EquipItem(Strapon, true, true)
	endIf
endFunction

function UnequipStrapon()
	if Strapon && ActorRef.IsEquipped(Strapon)
		ActorRef.UnequipItem(Strapon, true, true)
	endIf
endFunction

function SetStrapon(Form ToStrapon)
	if Strapon && !HadStrapon
		ActorRef.RemoveItem(Strapon, 1, true)
	endIf
	Strapon = ToStrapon
	if GetState() == "Animating"
		SyncThread()
	endIf
endFunction

Form function GetStrapon()
	return Strapon
endFunction

bool function PregnancyRisk()
	int cumID = Animation.GetCumID(Position, Stage)
	return cumID > 0 && (cumID == 1 || cumID == 4 || cumID == 5 || cumID == 7) && IsFemale && !MalePosition && Thread.IsVaginal
endFunction

function OverrideStrip(bool[] SetStrip)
	if SetStrip.Length != 33
		Thread.Log("Invalid strip override bool[] - Must be length 33 - was "+SetStrip.Length, "OverrideStrip()")
	else
		StripOverride = SetStrip
	endIf
endFunction

bool function ContinueStrip(Form ItemRef, bool DoStrip = true)
	return ItemRef && ((StorageUtil.FormListHas(none, "AlwaysStrip", ItemRef) || SexLabUtil.HasKeywordSub(ItemRef, "AlwaysStrip")) \
		|| (DoStrip && !(StorageUtil.FormListHas(none, "NoStrip", ItemRef) || SexLabUtil.HasKeywordSub(ItemRef, "NoStrip")))) 
endFunction

function Strip()
	if !ActorRef || IsCreature
		return
	endIf
	; Start stripping animation
	if DoUndress
		Debug.SendAnimationEvent(ActorRef, "Arrok_Undress_G"+BaseSex)
		NoUndress = true
	endIf
	; Select stripping array
	bool[] Strip
	if StripOverride.Length == 33
		Strip = StripOverride
	else
		Strip = Config.GetStrip(IsFemale, Thread.UseLimitedStrip(), IsType[0], IsVictim)
	endIf
	Log("Strip: "+Strip)
	; Stripped storage
	Form ItemRef
	Form[] Stripped = new Form[34]
	; Right hand
	ItemRef = ActorRef.GetEquippedObject(1)
	if ContinueStrip(ItemRef, Strip[32])
		Stripped[33] = ItemRef
		ActorRef.UnequipItemEX(ItemRef, 1, false)
		StorageUtil.SetIntValue(ItemRef, "Hand", 1)
	endIf
	; Left hand
	ItemRef = ActorRef.GetEquippedObject(0)
	if ContinueStrip(ItemRef, Strip[32])
		Stripped[32] = ItemRef
		ActorRef.UnequipItemEX(ItemRef, 2, false)
		StorageUtil.SetIntValue(ItemRef, "Hand", 2) 
	endIf
	; Strip armor slots
	int i = 31
	while i >= 0
		; Grab item in slot
		ItemRef = ActorRef.GetWornForm(Armor.GetMaskForSlot(i + 30))
		if ContinueStrip(ItemRef, Strip[i])
			ActorRef.UnequipItemEX(ItemRef, 0, false)
			Stripped[i] = ItemRef
		endIf
		; Move to next slot
		i -= 1
	endWhile
	; Equip the nudesuit
	if Strip[2] && ((Gender == 0 && Config.UseMaleNudeSuit) || (Gender == 1 && Config.UseFemaleNudeSuit))
		ActorRef.EquipItem(Config.NudeSuit, true, true)
	endIf
	; Store stripped items
	Equipment = PapyrusUtil.MergeFormArray(Equipment, PapyrusUtil.ClearNone(Stripped), true)
	Log("Equipment: "+Equipment)
endFunction

function UnStrip()
 	if !ActorRef || IsCreature || Equipment.Length == 0
 		return
 	endIf
	; Remove nudesuit if present
	if ActorRef.GetItemCount(Config.NudeSuit) > 0
		ActorRef.RemoveItem(Config.NudeSuit, ActorRef.GetItemCount(Config.NudeSuit), true)
	endIf
	; Continue with undress, or am I disabled?
 	if !DoRedress
 		return ; Fuck clothes, bitch.
 	endIf
 	; Equip Stripped
 	int i = Equipment.Length
 	while i
 		i -= 1
 		if Equipment[i]
 			int hand = StorageUtil.GetIntValue(Equipment[i], "Hand", 0)
 			if hand != 0
	 			StorageUtil.UnsetIntValue(Equipment[i], "Hand")
	 		endIf
	 		ActorRef.EquipItemEx(Equipment[i], hand, false)
  		endIf
 	endWhile
endFunction

bool NoRagdoll
bool property DoRagdoll hidden
	bool function get()
		if NoRagdoll
			return false
		endIf
		return !NoRagdoll && Config.RagdollEnd
	endFunction
	function set(bool value)
		NoRagdoll = !value
	endFunction
endProperty

bool NoUndress
bool property DoUndress hidden
	bool function get()
		if NoUndress
			return false
		endIf
		return Config.UndressAnimation
	endFunction
	function set(bool value)
		NoUndress = !value
	endFunction
endProperty

bool NoRedress
bool property DoRedress hidden
	bool function get()
		if NoRedress || (IsVictim && !Config.RedressVictim)
			return false
		endIf
		return !IsVictim || (IsVictim && Config.RedressVictim)
	endFunction
	function set(bool value)
		NoRedress = !value
	endFunction
endProperty

int PathingFlag
function ForcePathToCenter(bool forced)
	PathingFlag = (forced as int)
endFunction
function DisablePathToCenter(bool disabling)
	PathingFlag = IntIfElse(disabling, -1, (PathingFlag == 1) as int)
endFunction
bool property DoPathToCenter
	bool function get()
		return (PathingFlag == 0 && Config.DisableTeleport) || PathingFlag == 1
	endFunction
endProperty

function RefreshExpression()
	if !ActorRef || IsCreature
		; Do nothing
	elseIf OpenMouth
		sslBaseExpression.OpenMouth(ActorRef)
	else
		if Expression
			sslBaseExpression.CloseMouth(ActorRef)
			Expression.Apply(ActorRef, ActorFullEnjoyment, BaseSex)
		elseIf sslBaseExpression.IsMouthOpen(ActorRef)
			sslBaseExpression.CloseMouth(ActorRef)			
		endIf
	endIf
endFunction


; ------------------------------------------------------- ;
; --- System Use                                      --- ;
; ------------------------------------------------------- ;

function TrackedEvent(string EventName)
	if IsTracked
		Thread.SendTrackedEvent(ActorRef, EventName)
	endif
endFunction

function ClearEffects()
	if IsPlayer && GetState() != "Animating"
		; MiscUtil.SetFreeCameraState(false)
		if Game.GetCameraState() == 0
			Game.ForceThirdPerson()
		endIf
	endIf
	if ActorRef.IsInCombat()
		ActorRef.StopCombat()
	endIf
	if ActorRef.IsWeaponDrawn()
		ActorRef.SheatheWeapon()
	endIf
	if ActorRef.IsSneaking()
		ActorRef.StartSneaking()
	endIf
	ActorRef.ClearKeepOffsetFromActor()
endFunction

int property kPrepareActor = 0 autoreadonly hidden
int property kSyncActor    = 1 autoreadonly hidden
int property kResetActor   = 2 autoreadonly hidden
int property kRefreshActor = 3 autoreadonly hidden
int property kStartup      = 4 autoreadonly hidden

function RegisterEvents()
	string e = Thread.Key("")
	; Quick Events
	RegisterForModEvent(e+"Animate", "SendAnimation")
	RegisterForModEvent(e+"Orgasm", "OrgasmEffect")
	RegisterForModEvent(e+"Strip", "Strip")
	; Sync Events
	RegisterForModEvent(e+"Prepare", "PrepareActor")
	RegisterForModEvent(e+"Sync", "SyncActor")
	RegisterForModEvent(e+"Reset", "ResetActor")
	RegisterForModEvent(e+"Refresh", "RefreshActor")
	RegisterForModEvent(e+"Startup", "StartAnimating")
endFunction

function ClearEvents()
	UnregisterForUpdate()
	string e = Thread.Key("")
	; Quick Events
	UnregisterForModEvent(e+"Animate")
	UnregisterForModEvent(e+"Orgasm")
	UnregisterForModEvent(e+"Strip")
	; Sync Events
	UnregisterForModEvent(e+"Prepare")
	UnregisterForModEvent(e+"Sync")
	UnregisterForModEvent(e+"Reset")
	UnregisterForModEvent(e+"Refresh")
	UnregisterForModEvent(e+"Startup")
endFunction

function Initialize()
	; Clear actor
	if ActorRef
		; Stop events
		ClearEvents()
		RestoreActorDefaults()
		; Remove nudesuit if present
		if ActorRef.GetItemCount(Config.NudeSuit) > 0
			ActorRef.RemoveItem(Config.NudeSuit, ActorRef.GetItemCount(Config.NudeSuit), true)
		endIf
	endIf
	; Delete positioning marker
	if MarkerRef
		MarkerRef.Disable()
		MarkerRef.Delete()
	endIf
	; Forms
	ActorRef       = none
	MarkerRef      = none
	HadStrapon     = none
	Strapon        = none
	HDTHeelSpell   = none
	; Voice
	Voice          = none
	ActorVoice     = none
	IsForcedSilent = false
	; Expression
	Expression     = none
	; Flags
	NoRagdoll      = false
	NoUndress      = false
	NoRedress      = false
	; Integers
	Orgasms        = 0
	BestRelation   = 0
	BaseEnjoyment  = 0
	Enjoyment      = 0
	BonusEnjoyment      = 0
	ActorFullEnjoyment      = 0
	slaExhibitionistNPCCount      = 0
	PathingFlag    = 0
	; Floats
	LastOrgasm     = 0.0
	ActorScale     = 0.0
	AnimScale      = 0.0
	StartWait      = 0.1
	MusturbationMod     = 1.0
	ExhibitionistMod     = 1.0
	GenderMod     = 1.0
	; Factions
	slaArousal     = None
	slaExhibitionist     = None
	bslaExhibitionist     = false
	; Keywords
	zadDeviousBelt = None
	; Strings
	EndAnimEvent   = "IdleForceDefaultState"
	StartAnimEvent = ""
	ActorKey       = ""
	PlayingSA      = ""
	CurrentSA      = ""
	; Storage
	StripOverride  = Utility.CreateBoolArray(0)
	Equipment      = Utility.CreateFormArray(0)
	; Make sure alias is emptied
	TryToClear()
endFunction

function Setup()
	; Reset function Libraries - SexLabQuestFramework
	if !Config || !ActorLib || !Stats
		Form SexLabQuestFramework = Game.GetFormFromFile(0xD62, "SexLab.esm")
		if SexLabQuestFramework
			Config   = SexLabQuestFramework as sslSystemConfig
			ActorLib = SexLabQuestFramework as sslActorLibrary
			Stats    = SexLabQuestFramework as sslActorStats
		endIf
	endIf
	PlayerRef = Game.GetPlayer()
	Thread    = GetOwningQuest() as sslThreadController
	OrgasmFX  = Config.OrgasmFX
	DebugMode = Config.DebugMode
	AnimatingFaction = Config.AnimatingFaction
endFunction

function Log(string msg, string src = "")
	msg = "ActorAlias["+ActorName+"] "+src+" - "+msg
	Debug.Trace("SEXLAB - " + msg)
	if DebugMode
		SexLabUtil.PrintConsole(msg)
		Debug.TraceUser("SexLabDebug", msg)
	endIf
endFunction

function PlayLouder(Sound SFX, ObjectReference FromRef, float Volume)
	if SFX && FromRef && Volume > 0.0
		if Volume > 0.5
			Sound.SetInstanceVolume(SFX.Play(FromRef), 1.0)
		else
			Sound.SetInstanceVolume(SFX.Play(FromRef), Volume)
		endIf
	endIf
endFunction

; ------------------------------------------------------- ;
; --- State Restricted                                --- ;
; ------------------------------------------------------- ;

; Ready
function PrepareActor()
endFunction
function PathToCenter()
endFunction
; Animating
function StartAnimating()
endFunction
function SyncActor()
endFunction
function SyncThread()
endFunction
function SyncLocation(bool Force = false)
endFunction
function RefreshLoc()
endFunction
function Snap()
endFunction
event OnTranslationComplete()
endEvent
function OrgasmEffect(bool Force = false)
endFunction
event ResetActor()
endEvent
;/ function RefreshActor()
endFunction /;
event OnOrgasm()
	OrgasmEffect()
endEvent
event OrgasmStage()
	OrgasmEffect()
endEvent

function OffsetCoords(float[] Output, float[] CenterCoords, float[] OffsetBy) global native
bool function IsInPosition(Actor CheckActor, ObjectReference CheckMarker, float maxdistance = 30.0) global native
int function CalcEnjoyment(float[] XP, float[] SkillsAmounts, bool IsLeadin, bool IsFemaleActor, float Timer, int OnStage, int MaxStage) global native

int function IntIfElse(bool check, int isTrue, int isFalse)
	if check
		return isTrue
	endIf
	return isFalse
endfunction

; function AdjustCoords(float[] Output, float[] CenterCoords, ) global native
; function AdjustOffset(int i, float amount, bool backwards, bool adjustStage)
; 	Animation.
; endFunction

; function OffsetBed(float[] Output, float[] BedOffsets, float CenterRot) global native

; bool function _SetActor(Actor ProspectRef) native
; function _ApplyExpression(Actor ProspectRef, int[] Presets) global native


; function GetVars()
; 	IntShare = Thread.IntShare
; 	FloatShare = Thread.FloatS1hare
; 	StringShare = Thread.StringShare
; 	BoolShare
; endFunction

; int[] property IntShare auto hidden ; Stage, ActorCount, BedStatus[1]
; float[] property FloatShare auto hidden ; RealTime, StartedAt
; string[] property StringShare auto hidden ; AdjustKey
; bool[] property BoolShare auto hidden ; 
; sslBaseAnimation[] property _Animation auto hidden ; Animation