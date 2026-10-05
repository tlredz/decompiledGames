local PebbleMonster = {
	Name = "Twisted Pebble",
	Rarity = "MainCharacter",
	Icon = "rbxassetid://17011493217",
	VisionRadius = 125,
	InstantRadius = 35,
	WalkSpeed = 10,
	RunSpeed = 24,
	InterestTime = 3,
	HearingRadius = 200,
	Damage = 1,
	WaitTime = 3,
	LineOfSight = 0.4,
	KillRadius = 6.5,
	HitCooldown = 3,
	AttackDelay = 0.5,
	AIConfig = {
		PhysFriction = 0.15,
		PhysDensity = 0.8,
		PhysShapeBall = false,
		MovementPredictionMagnitude = 1.2,
		CollinearOffset = 0.4,
		TurnSpeedPenaltyEnabled = true,
		TurnSpeedPenaltyMin = 0.7,
		TurnSpeedPenaltyRecovery = 0.4,
		TurnSpeedPenaltyThreshold = 0.8,
		TurnSpeedPenaltyHoldTime = 0.8
	},
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://137499835418239",
			NormalTexture = "rbxassetid://70423239459075",
			AttackTexture = "rbxassetid://70423239459075"
		}
	}
}

function PebbleMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, PebbleMonster.SpecialAnimatorData.Config)
end

return PebbleMonster