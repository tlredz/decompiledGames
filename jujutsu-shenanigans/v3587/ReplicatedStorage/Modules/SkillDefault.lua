return {
	LineItems = {
		WAIT = {
			{
				"TIME",
				2,
				1,
				Desc = "(number) How many seconds to delay the next NODE by."
			}
		},
		SKILL = {
			{ "MOVE", 3, "Divergent Fist" },
			{
				"SPEED",
				2,
				1,
				Desc = "Multiplier of the Skill's speed."
			},
			{
				"CANCEL LAST",
				1,
				false,
				Desc = "Cancels the previous NODE if set to true."
			},
			{ "ENABLE VARIANTS", 1, true },
			{
				"HOLD FOR",
				2,
				0,
				Desc = "How many seconds to hold the Skill for. Only applicable to holdable Skills, such as Max Elephant."
			},
			{
				"START",
				2,
				0,
				Desc = "Where to begin the Skill from, starting at 0 seconds."
			}
		},
		SPECIAL = {
			{ "SPEC", 3, "Limitless" },
			{
				"SPEED",
				2,
				1,
				Desc = "Multiplier of the Skill's speed."
			},
			{
				"CANCEL LAST",
				1,
				false,
				Desc = "Cancels the previous NODE if set to true."
			},
			{ "ENABLE VARIANTS", 1, true }
		},
		ANIM = {
			{
				"PREVIEW",
				4,
				{ 0, 15 }
			},
			{
				"ANIM_USE",
				3,
				{ 1, 1 }
			},
			{
				"LOOPED",
				1,
				false,
				Desc = "Loop the animation as long as the skill is active."
			},
			{
				"SPEED",
				2,
				1,
				Desc = "Multiplier of the Animation's speed."
			},
			{
				"FADE IN",
				2,
				0.1,
				Desc = "How fast the Animation should fade in, in seconds."
			},
			{
				"FADE OUT",
				2,
				0,
				Desc = "How fast the Animation should fade out, in seconds."
			},
			{
				"LAST HIT",
				2,
				-1,
				Desc = "Activates this NODE on a target hit in the last (value) seconds."
			}
		},
		SFX = {
			{
				"ID",
				2,
				12222253,
				Desc = "The sound's AssetID."
			},
			{
				"SPEED",
				2,
				1,
				Desc = "Multiplier of the Sound's playback speed."
			},
			{
				"VOLUME",
				2,
				0.5,
				Desc = "Multiplier of the Sound's volume."
			},
			{
				"START",
				2,
				0,
				Desc = "Where to begin the Sound from, starting at 0 seconds."
			},
			{
				"END",
				2,
				500,
				Desc = "Where to end the Sound at, in seconds."
			},
			{ "FADE IN", 2, 0 },
			{ "FADE OUT", 2, 0 },
			{
				"CANCEL",
				1,
				false,
				Desc = "Cancels all currently playing Sound NODEs."
			},
			{
				"GLOBAL",
				1,
				false,
				Desc = "Disables 3D falloff, playing the sound at the same volume for everyone."
			},
			{
				"CLIENT SIDED",
				1,
				false,
				Desc = "Runs the sound only for the target's client."
			},
			{
				"LAST HIT",
				2,
				-1,
				Desc = "Activates this NODE on a target hit in the last (value) seconds."
			},
			{
				"PROJECTILE TAG",
				3,
				nil,
				Desc = "The name of a projectile's tag. If matched with an existing projectile, the sound follows the projectile."
			}
		},
		VELO = {
			{
				"FORCE",
				5,
				"0, 0, 0",
				Desc = "The direction where force should be applied towards. Higher values = bigger force (X, Y, Z)"
			},
			{
				"TIME",
				2,
				0,
				Desc = "How long the force should be active for."
			},
			{
				"FADE",
				1,
				false,
				Desc = "The force linearly fades to 0,0,0 over time."
			},
			{
				"TRACK",
				1,
				false,
				Desc = "Force direction tracks the torso's orientation during the entire duration of the NODE."
			},
			{
				"LAST HIT",
				2,
				-1,
				Desc = "Activates this NODE on a target hit in the last (value) seconds."
			},
			{
				"RAGDOLL",
				2,
				0,
				Desc = "If the value is above 0, ragdolls for (value) seconds."
			},
			{
				"TRUE RAGDOLL",
				1,
				false,
				Desc = "Disables ragdoll cancel."
			},
			{
				"RELATIVE FROM BRANCH",
				1,
				false,
				Desc = "Force direction is relative to the Branch origin."
			}
		},
		CONNECT = {
			{
				"SIGNAL",
				3,
				"Nothing",
				Desc = "The block's signal."
			},
			{
				"TIME",
				2,
				0.1,
				Desc = "How long the signal should be active for, in seconds."
			},
			{
				"RANGE",
				2,
				1e999,
				Desc = "Activation range for the signal, in studs."
			}
		},
		HITBOX = {
			{
				"PREVIEW",
				7,
				{ 0, 15 }
			},
			{
				"POSITION",
				5,
				"0, 0, 4",
				Desc = "The hitbox's position, the origin being the player's center. (X, Y, Z)"
			},
			{
				"ROTATION",
				5,
				"0, 0, 0",
				Desc = "The hitbox's rotation, relative to the player's orientation. (X, Y, Z)"
			},
			{
				"SIZE",
				5,
				"6, 6, 6",
				Desc = "The size of the hitbox. (X, Y, Z)"
			},
			{
				"STUN",
				2,
				1,
				Desc = "How long the stun on hit should last for, in seconds. (-1 for no stun but still mark as LAST HIT)"
			},
			{
				"STUN ANIM",
				1,
				false,
				Desc = "Plays a generic stun animation on the hit target."
			},
			{
				"IGNORE WAKEUP",
				1,
				true,
				Desc = "Ignore the wakeup stun immunity (disable for accurate M1s)."
			},
			{
				"DAMAGE",
				2,
				1,
				Desc = "How much damage should be dealt on hit."
			},
			{
				"DEBREE",
				2,
				0,
				Desc = "If not 0, causes destruction. The value determines the Debree Fidelity, which is 2 by default. Negative values don't spawn debree."
			},
			{ "ATTACK TYPE", 3, "Melee" },
			{
				"BLOCKABLE",
				1,
				true,
				Desc = "The hitbox is blockable from the front."
			},
			{
				"360 BLOCK",
				1,
				false,
				Desc = "The hitbox is blockable regardless of orientation."
			},
			{
				"CANCEL ENEMY",
				1,
				true,
				Desc = "Cancels the hit target(s)."
			},
			{
				"CLEAR KNOCKBACK",
				1,
				false,
				Desc = "Clears hit target(s) velocity, also cancelling their ragdoll."
			},
			{
				"CAN KILL",
				1,
				true,
				Desc = "The hitbox can kill the hit target(s). If disabled, the target(s) cannot receive more damage than their current health."
			},
			{
				"HIT RAGDOLL",
				1,
				false,
				Desc = "The hitbox can hit ragdolls."
			},
			{
				"HIT USER",
				1,
				false,
				Desc = "The hitbox can hit the user of the skill."
			},
			{
				"SINGLE TARGET",
				1,
				true,
				Desc = "The hitbox can only hit one target."
			},
			{
				"BRANCH",
				3,
				nil,
				Desc = "Proceed to a BRANCH on hit."
			},
			{
				"BRANCH TARGET",
				3,
				nil,
				Desc = "Force the hit target(s) to proceed to a BRANCH."
			},
			{
				"BRANCH FINISHER",
				3,
				nil,
				Desc = "Proceed to a BRANCH if the hit was fatal."
			},
			{
				"PROJECTILE TAG",
				3,
				nil,
				Desc = "The name of a projectile's tag. If matched with an existing projectile, the hitbox's origin is set to the projectile's position."
			},
			{
				"LINK USER",
				2,
				0,
				Desc = "How long the hitbox is allowed to be hit, and transfers the attack to the user."
			}
		},
		ULTGIB = {
			{ "AMOUNT", 2, 5 }
		},
		HPGIB = {
			{ "AMOUNT", 2, 5 },
			{ "CAN KILL", 1, false }
		},
		EVGIB = {
			{ "AMOUNT", 2, 5 }
		},
		SETCD = {
			{
				"KEY",
				2,
				-1,
				Desc = "The move to set cooldown for. (-1 for current move)"
			},
			{
				"COOLDOWN",
				2,
				-1,
				Desc = "The cooldown itself. (-1 for default cooldown)"
			}
		},
		HITCNCL = {
			{
				"TIME",
				2,
				1,
				Desc = "Proceeds to BRANCH depending on the value of Flip."
			},
			{
				"FLIP",
				1,
				false,
				Desc = "If set to FALSE: proceed to branch if a target WAS hit in the last (Time) seconds. <br />If set to TRUE: proceed to branch if a target WASN'T hit in the last (Time) seconds."
			},
			{
				"ENDLAG",
				2,
				1,
				Desc = "Become stunned for (value) seconds on cancel."
			},
			{
				"BRANCH",
				3,
				nil,
				Desc = "The BRANCH the user shall proceed to."
			}
		},
		BRANCH = {
			{
				"BRANCH",
				3,
				nil,
				Desc = "The BRANCH the user shall proceed to."
			},
			{
				"RANDOM",
				8,
				nil,
				Desc = "Randomly selects a BRANCH to proceed to any time this NODE is activated. Branch names are separated by commas."
			},
			{
				"LAST HIT",
				2,
				-1,
				Desc = "Activates this NODE on a target hit in the last (value) seconds."
			}
		},
		VISUAL = {
			{ "EFFECT", 3, "Slash" },
			{
				"AMOUNT",
				2,
				1,
				Desc = "How many Effects to emit. If the selected Effect is \"Mesh\", the value of this property becomes the Mesh ID."
			},
			{
				"TEXTURE",
				2,
				0,
				Desc = "The effect's texture. Determined by an AssetID."
			},
			{
				"COLOR",
				6,
				"255, 255, 255",
				Desc = "The effect's color. (R, G, B)"
			},
			{
				"ALT COLOR",
				6,
				"255, 255, 255",
				Desc = "The color to fade into over the course of the Effect's duration."
			},
			{
				"OPACITY",
				2,
				0,
				Desc = "The effect's transparency, with 0 being fully opaque and 1 being completely invisible."
			},
			{
				"ALT OPACITY",
				2,
				0,
				Desc = "The transparency to fade into."
			},
			{
				"POSITION",
				5,
				"0, 0, 0",
				Desc = "The effect's offset from the selected Limb. (X, Y, Z)"
			},
			{
				"ALT POSITION",
				5,
				"0, 0, 0",
				Desc = "The offset to fade into."
			},
			{
				"ROTATION",
				5,
				"0, 0, 0",
				Desc = "The effect's rotation. (X, Y, Z)"
			},
			{
				"ALT ROTATION",
				5,
				"0, 0, 0",
				Desc = "The rotation to fade into."
			},
			{
				"SIZE",
				2,
				1,
				Desc = "Multiplier of the effect's size."
			},
			{
				"ALT SIZE",
				2,
				1,
				Desc = "The size to fade into."
			},
			{
				"TIME",
				2,
				1,
				Desc = "How long the Effect should be active for. Alt (Property) use Time as the speed."
			},
			{
				"LAST HIT",
				2,
				-1,
				Desc = "Activates this NODE on a target hit in the last (value) seconds."
			},
			{ "BODY PART", 3, "HumanoidRootPart" },
			{
				"VISUAL TAG",
				3,
				nil,
				Desc = "The name of the tag. Used by other VISUAL nodes to Cancel the effect, if the selected Effect is \"Cancel\""
			},
			{
				"PROJECTILE TAG",
				3,
				nil,
				Desc = "The name of a projectile's tag. If matched with an existing projectile, the effect's origin (i.e. \"Limb\") is set to the projectile's position."
			},
			{
				"RUN ON SERVER",
				1,
				false,
				Desc = "Runs the effect serverside, recommended for weapons and such."
			},
			{
				"CLIENT SIDED",
				1,
				false,
				Desc = "Runs the effect only for the target's client."
			},
			{
				"CANCEL ON INTERRUPT",
				1,
				false,
				Desc = "Cancels the effect when the skill is interrupted. Requires VISUAL TAG."
			},
			{
				"RELATIVE FROM BRANCH",
				1,
				false,
				Desc = "Body part is selected from the Branch origin."
			},
			{
				"CAN COLLIDE",
				1,
				false,
				Desc = "Enables collision on the effect, making it tangible."
			},
			{ "EASING STYLE", 3, "Linear" },
			{ "EASING DIRECTION", 3, "In" },
			{
				"SIZE 2",
				5,
				"-1, -1, -1",
				Desc = "Uniform sizing, only works for mesh and part related effects. Change to a positive vector to utilize. (X, Y, Z)"
			},
			{
				"ALT SIZE 2",
				5,
				"-1, -1, -1",
				Desc = "Uniform sizing, only works for mesh and part related effects. Change to a positive vector to utilize. (X, Y, Z)"
			}
		},
		LOOP = {
			{ "LOOP BACK", 2, 1 },
			{ "LOOP AMOUNT", 2, 3 },
			{ "HOLD", 1, false }
		},
		GRAB = {
			{ "BODY PART", 3, "HumanoidRootPart" },
			{ "BODY PART2", 3, "HumanoidRootPart" },
			{
				"POSITION",
				5,
				"0, 0, 0",
				Desc = "The TARGET LIMB's offset from LIMB. (X, Y, Z)"
			},
			{
				"ROTATION",
				5,
				"0, 0, 0",
				Desc = "The TARGET LIMB's rotation. (X, Y, Z)"
			},
			{
				"TIME",
				2,
				1,
				Desc = "How long the Grab should be active for."
			},
			{
				"LAST HIT",
				2,
				1,
				Desc = "Activates this NODE on a target hit in the last (value) seconds."
			}
		},
		PROJECTILE = {
			{
				"PROJECTILE TAG",
				3,
				nil,
				Desc = "The name of the tag. Used by VISUAL, HITBOX and SOUND nodes as a link to the projectile."
			},
			{
				"CANCEL PROJECTILE",
				1,
				false,
				Desc = "Removes all projectiles with same PROJECTILE TAG, if CACHE is enabled it won't remove the cached projectile."
			},
			{
				"ID CHECK",
				1,
				true,
				Desc = "Makes the projectile tag only work in this move, if disabled all projectiles spawned with same tag will be seen."
			},
			{
				"SPAWN AT PROJECTILE TAG",
				3,
				nil,
				Desc = "Spawns the projectile relative to an already existing projectile with this tag."
			},
			{
				"POSITION",
				5,
				"0, 0, 0",
				Desc = "The projectile's starting position, the origin being the player's center. (X, Y, Z)"
			},
			{
				"ROTATION",
				5,
				"0, 0, 0",
				Desc = "The projectile's rotation, relative to the player's orientation. (X, Y, Z)"
			},
			{
				"SIZE",
				5,
				"6, 6, 6",
				Desc = "The size of the projectile. (X, Y, Z)"
			},
			{
				"SPEED",
				2,
				1,
				Desc = "How fast the projectile should travel, in studs per second."
			},
			{ "TIME", 2, 1 },
			{
				"STUN",
				2,
				1,
				Desc = "How long the stun on hit should last for, in seconds. (-1 for no stun but still mark as LAST HIT)"
			},
			{
				"STUN ANIM",
				1,
				false,
				Desc = "Plays a generic stun animation on the hit target."
			},
			{
				"IGNORE WAKEUP",
				1,
				true,
				Desc = "Ignore the wakeup stun immunity (disable for accurate M1s)."
			},
			{
				"DAMAGE",
				2,
				1,
				Desc = "How much damage should be dealt on hit."
			},
			{
				"DEBREE",
				2,
				0,
				Desc = "If not 0, causes destruction. The value determines the Debree Fidelity, which is 2 by default. Negative values don't spawn debree."
			},
			{ "ATTACK TYPE", 3, "Melee" },
			{
				"BLOCKABLE",
				1,
				true,
				Desc = "The projectile is blockable from the front."
			},
			{
				"360 BLOCK",
				1,
				false,
				Desc = "The projectile is blockable regardless of orientation."
			},
			{
				"CANCEL ENEMY",
				1,
				true,
				Desc = "Cancels the hit target(s)."
			},
			{
				"CLEAR KNOCKBACK",
				1,
				false,
				Desc = "Clears hit target(s) velocity, also cancelling their ragdoll."
			},
			{
				"CAN KILL",
				1,
				true,
				Desc = "The hitbox can kill the hit target(s). If disabled, the target(s) cannot receive more damage than their current health, instead leaving them at the lowest possible amount, if the hit was fatal."
			},
			{
				"HIT RAGDOLL",
				1,
				false,
				Desc = "The hitbox can hit ragdolls."
			},
			{
				"HIT USER",
				1,
				false,
				Desc = "The hitbox can hit the user of the skill."
			},
			{
				"AIM LAST HIT",
				2,
				-1,
				Desc = "The projectile's rotation gets aligned towards the position of the LAST HIT target. (LAST HIT: target hit in the last (value) seconds.)"
			},
			{
				"CONTINUE",
				1,
				false,
				Desc = "The projectile continues travelling after hitting a target, or colliding with the environment."
			},
			{
				"BRANCH",
				3,
				nil,
				Desc = "Proceed to a BRANCH on hit."
			},
			{
				"BRANCH TARGET",
				3,
				nil,
				Desc = "Force the hit target(s) to proceed to a BRANCH."
			},
			{
				"BRANCH COLLIDED",
				3,
				nil,
				Desc = "Proceed to a BRANCH if the projectile collided with the environment. If empty, the projectile ignores collisions"
			},
			{
				"FILTER INTERVAL",
				2,
				1,
				Desc = "The projectile, upon hitting a target, waits (value) seconds before it can hit the same target."
			},
			{
				"REFLECT COUNT",
				2,
				0,
				Desc = "How many times the projectile can bounce off the environment before despawning."
			},
			{
				"CACHE",
				1,
				true,
				Desc = "Stores projectile in the cache on hit, making PROJECTILE tag usable even after it's gone."
			}
		},
		COUNTER = {
			{ "ATTACK TYPE2", 3, "Melee" },
			{
				"TIME",
				2,
				1,
				Desc = "How long the counter is active for, in seconds."
			},
			{
				"STUN",
				2,
				1,
				Desc = "How long the counter should stun the countered target for, in seconds. (-1 for no stun but still mark as LAST HIT)"
			},
			{
				"CANCEL ENEMY",
				1,
				true,
				Desc = "Cancels the countered target."
			},
			{
				"BRANCH",
				3,
				nil,
				Desc = "Proceed to a BRANCH upon successfully countering a target."
			},
			{
				"BRANCH TARGET",
				3,
				nil,
				Desc = "Force the countered target to proceed to a BRANCH."
			},
			{
				"REMOVE ON HIT",
				1,
				true,
				Desc = "The counter gets removed upon activating."
			},
			{
				"REFLECT",
				1,
				false,
				Desc = "Redirects all near projectiles"
			},
			{
				"CONTINUE",
				1,
				false,
				Desc = "Removes the immunity for counters, meaning you will take damage when hit but the counter will still activate"
			}
		},
		TAG = {
			{
				"TAG",
				3,
				nil,
				Desc = "The name of the tag. This name can be used as a variable by all TAG nodes."
			},
			{
				"VALUE",
				3,
				nil,
				Desc = "Value of the tag. Can be a number, or a string of text."
			},
			{
				"TIME",
				2,
				1,
				Desc = "How long the tag should be active for, if changed."
			},
			{
				"CHECK",
				1,
				false,
				Desc = "Checks if the tag's value matches (value). Performing \"less than\" and \"greater than\" operations can be done by prefixing the value with < or > (e.g. <1 for \"less than 1\")."
			},
			{
				"ADD/REMOVE",
				1,
				true,
				Desc = "Only applicable if Set is false. <br />If true, adds +(value) to the tag's value. If false, subtracts."
			},
			{
				"SET",
				1,
				true,
				Desc = "Replaces the tag's value with (value)."
			},
			{
				"BRANCH",
				3,
				nil,
				Desc = "Only applicable if Check is true. <br />The BRANCH that shall be proceeded to if Check successfully completes the comparison operation (e.g. if the tag's value is equal to (value), then proceed to BRANCH.)"
			},
			{
				"LAST HIT",
				2,
				-1,
				Desc = "Activates this NODE on a target hit in the last X seconds."
			}
		},
		STATE = {
			{ "STATE", 3, "Stun" },
			{
				"VALUE",
				3,
				1,
				Desc = "Used for SpeedMultiplier, JumpMultiplier, and Scale."
			},
			{
				"TIME",
				2,
				1,
				Desc = "How long the State should be active for."
			},
			{
				"CANCEL ON END",
				1,
				false,
				Desc = "The State gets cancelled when the skill ends."
			},
			{
				"DISABLE BURST",
				1,
				false,
				Desc = "Burst is disabled while the State is active."
			},
			{
				"LAST HIT",
				2,
				-1,
				Desc = "Activates this NODE on a target hit in the last X seconds."
			},
			{
				"CHECK",
				1,
				false,
				Desc = "Checks if LAST HIT has that state"
			},
			{
				"BRANCH",
				3,
				nil,
				Desc = "Only applicable if Check is true. <br />The BRANCH that shall be proceeded to if Check successfully completes the state check, then proceed to BRANCH.)"
			},
			{
				"STATE TAG",
				3,
				nil,
				Desc = "The name of the tag. Used by other STATE nodes to Cancel the state, if the selected State is \"Cancel\""
			}
		},
		TELEPORT = {
			{
				"POSITION",
				5,
				"0, 0, 0",
				Desc = "Character's offset from last hit. (X, Y, Z)"
			},
			{
				"ROTATION",
				5,
				"0, 0, 0",
				Desc = "Character's rotation at the location. (X, Y, Z)"
			},
			{
				"LAST HIT",
				2,
				-1,
				Desc = "Applies POSITION and ROTATION of the LAST HIT target"
			},
			{
				"PROJECTILE TAG",
				3,
				nil,
				Desc = "Prioritizes the projectile with this tag instead of the LAST HIT target."
			},
			{
				"RELATIVE FROM BRANCH",
				1,
				false,
				Desc = "Prioritizes the origin of branch instead of the LAST HIT target"
			},
			{
				"IGNORE WALLS",
				1,
				true,
				Desc = "Teleport ignores any obstacles on it's way"
			}
		},
		LOOK = {
			{
				"TIME",
				2,
				1,
				Desc = "How long it should be active for."
			},
			{
				"SMOOTHNESS",
				2,
				40,
				Desc = "How fast should the constraint snap. (10 <-> 200)"
			},
			{
				"HORIZONTAL ONLY",
				1,
				false,
				Desc = "Unlocks verticality on the constraint."
			},
			{
				"LAST HIT",
				2,
				-1,
				Desc = "Target to look at, -1 to look at the cursor."
			},
			{
				"RELATIVE FROM BRANCH",
				1,
				false,
				Desc = "Prioritizes the origin of branch instead of the LAST HIT target"
			},
			{
				"PROJECTILE TAG",
				3,
				nil,
				Desc = "Prioritizes the projectile with this tag instead of the LAST HIT target."
			},
			{
				"CAMERA DIRECTION",
				1,
				false,
				Desc = "Looks at the camera's direction instead of the LAST HIT target."
			},
			{
				"GROUNDED",
				1,
				false,
				Desc = "Vertical direction affects character's vertical position."
			}
		},
		SETMELEE = {
			{
				"COMBO",
				2,
				0,
				Desc = "What part of the melee combo you are set to. Set this to -1 to keep last used melee combo."
			},
			{
				"OFFSET",
				2,
				0,
				Desc = "How long before the melee resets back to 0."
			},
			{
				"LAST HIT",
				2,
				-1,
				Desc = "Activates this NODE on a target hit in the last (value) seconds."
			}
		},
		PARTICLE = {
			{
				"PROJECTILE TAG",
				3,
				nil,
				Desc = "The name of a projectile's tag. If matched with an existing projectile, the effect's origin (i.e. \"Limb\") is set to the projectile's position."
			},
			{
				"LAST HIT",
				2,
				-1,
				Desc = "Activates this NODE on a target hit in the last (value) seconds."
			},
			{
				"PART SIZE",
				5,
				"0, 0, 0",
				Desc = "Keep at 0, 0, 0 to use attachments, otherwise makes a part with that size and spawns particles inside of it. (X, Y, Z)"
			},
			{
				"TEXTURE",
				2,
				0,
				Desc = "The effect's texture. Determined by an AssetID."
			},
			{
				"EMIT COUNT",
				2,
				10,
				Desc = "Amount of particles to spawn at once. (DURATION MUST BE SET TO 0)"
			},
			{
				"RATE",
				2,
				0,
				Desc = "Particles per second. Only active if DURATION is > 0."
			},
			{
				"DURATION",
				2,
				0,
				Desc = "Seconds the emitter stays enabled. 0 = EMIT COUNT."
			},
			{
				"COLOR",
				10,
				"255,255,255 0,0,0",
				Desc = "ColorSequence, colors separated by spaces. (r,g,b r,g,b r,g,b)"
			},
			{
				"SIZE",
				9,
				"1, 0",
				Desc = "NumberSequence, values separated by commas (size1, size2, size3...)"
			},
			{
				"BRIGHTNESS",
				2,
				1,
				Desc = "Particle brightness"
			},
			{
				"TRANSPARENCY",
				9,
				"0, 1",
				Desc = "NumberSequence, same as SIZE"
			},
			{
				"SQUASH",
				9,
				"0, 0",
				Desc = "NumberSequence, same as SIZE"
			},
			{
				"LIFETIME",
				11,
				"0.5, 1",
				Desc = "Particle lifetime in seconds. (min, max)"
			},
			{
				"SPEED",
				11,
				"5, 5",
				Desc = "Particle speed. (min, max)"
			},
			{
				"ROTATION",
				11,
				"0, 0",
				Desc = "Starting rotation of texture (min, max)"
			},
			{
				"ROT SPEED",
				11,
				"0, 0",
				Desc = "Rotation speed (min, max)"
			},
			{
				"ACCELERATION",
				5,
				"0, 0, 0",
				Desc = "Acceleration of particle in world space. (X, Y, Z)"
			},
			{
				"DRAG",
				2,
				0,
				Desc = "Particle slowdown over time."
			},
			{
				"LIGHT EMISSION",
				2,
				0,
				Desc = "How much the particle glows (0-1)."
			},
			{
				"LIGHT INFLUENCE",
				2,
				1,
				Desc = "How much lighting affects the particle (0-1)."
			},
			{
				"ZOFFSET",
				2,
				0,
				Desc = "Depth offset from the camera."
			},
			{
				"SPREAD ANGLE",
				5,
				"0, 0, 0",
				Desc = "Particle direction spread (X, Y, Z)"
			},
			{
				"POSITION",
				5,
				"0, 0, 0",
				Desc = "The effect's offset from the selected Limb. (X, Y, Z)"
			},
			{
				"LOCK TO PART",
				1,
				false,
				Desc = "Particles move with the selected limb instead of staying in same place."
			},
			{ "BODY PART", 3, "HumanoidRootPart" },
			{ "ORIENTATION TYPE", 3, "FacingCamera" },
			{ "EMISSION DIRECTION", 3, "Top" },
			{
				"FLIPBOOK SIZE",
				9,
				"0, 0",
				Desc = "Layout/size of the flipbook grid (0, 0 to disable)."
			},
			{ "FLIPBOOK MODE", 3, "OneShot" },
			{
				"FLIPBOOK FRAMERATE",
				9,
				"10, 10",
				Desc = "Framerate of the flipbook, only applicable if FLIPBOOK MODE is set to Loop"
			},
			{ "SHAPE", 3, "Box" },
			{ "SHAPE INOUT", 3, "Outward" },
			{ "SHAPE PARTIAL", 2, 0 },
			{
				"RUN ON SERVER",
				1,
				false,
				Desc = "Runs the effect on server and for newly joined players as well (use for permanent auras, might cause performance issues on overuse)"
			},
			{
				"CLIENT SIDED",
				1,
				false,
				Desc = "Runs the effect only for the target's client. (does not work with RUN ON SERVER)"
			},
			{ "CANCEL TAG", 3, nil },
			{
				"CANCEL",
				1,
				false,
				Desc = "Cancel all emitters with same tag."
			},
			{
				"CANCEL ON INTERRUPT",
				1,
				false,
				Desc = "Cancel all emitters with same tag on interruption."
			}
		},
		AIR = {
			{ "FLIP", 1, false }
		},
		JUMP = {
			{ "FLIP", 1, false }
		},
		AIM = {
			{ "FLIP", 1, false }
		},
		ULT = {
			{ "FLIP", 1, false }
		},
		HP = {
			{ "AMOUNT", 2, 10 },
			{ "FLIP", 1, false }
		},
		BAR = {
			{ "AMOUNT", 2, 5 },
			{ "FLIP", 1, false }
		},
		DOMAIN = {
			{ "FLIP", 1, false }
		},
		DUR = {
			{ "DURABILITY", 2, 1 }
		},
		HOLD = {
			{ "FLIP", 1, false }
		}
	},
	defaultProp = {
		DMG = 1,
		KNOCK = 1,
		KEEP = false,
		REP = false,
		INV = false,
		REP2 = false,
		AWK = false,
		AWK2 = false,
		USE = false,
		USEONDEATH = false,
		NOSTUN = false,
		NOCANCEL = false,
		VAR = "-"
	}
}