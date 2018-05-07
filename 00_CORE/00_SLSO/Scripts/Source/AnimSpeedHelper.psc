scriptname AnimSpeedHelper Hidden

; None of these commands save anything to save game, you will need to reuse them
; if game is loaded. All changes are cleared when you reload a game.

; Get version of mod.
int function GetVersion() global native

;/ Set new animation speed for target actor.
target: target actor to set for
scale: time scale of animation speed, 1.0 is normal and 0.5 is 50% speed, negative is now allowed to play animation in reverse
transition: time in seconds until this speed is reached
absolute: time in seconds is fixed or not, if nonzero then it takes exactly this
          many seconds to reach target speed, if zero then it takes
		  speedDiff * transition seconds. Just set 0 if you don't understand :P
		  /;
function SetAnimationSpeed(Actor target, float scale, float transition, int absolute) global native

;/ Get current animation speed of target actor.
target: target actor to get for
absolute: get the target speed (non-zero) or current speed (zero)
/;
float function GetAnimationSpeed(Actor target, int absolute) global native

; This actor will stop transitioning animation speed and stay at current speed. If none
; then all actors will do this (all actors that have been set in SetAnimationSpeed).
function ResetTransition(Actor target) global native

; Gets the name of the last animation event that was sent to actor. Is empty if none were found.
string function GetAnimationEventName(Actor target) global native

;/ Gets the time in seconds that has passed since last animation event was received. This time
is modified by our scalers and may be negative due to this! /;
float function GetAnimationEventElapsed(Actor target) global native

; Warps animation forward or backwards by X seconds.
function WarpAnimation(Actor target, float amount) global native

; Reset and remove all animation overwrites.
function ResetAll() global native
