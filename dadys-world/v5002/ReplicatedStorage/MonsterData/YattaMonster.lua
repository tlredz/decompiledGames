local YattaMonster = {
	Name = "Yatta Monster",
	Rarity = "Common",
	Icon = "rbxassetid://92678844815201",
	VisionRadius = 60,
	InstantRadius = 30,
	WalkSpeed = 7,
	RunSpeed = 19,
	InterestTime = 1.5,
	HearingRadius = 140,
	Damage = 1,
	WaitTime = 3,
	LineOfSight = 0.5,
	KillRadius = 3,
	HitCooldown = 3,
	ChaseAbility = false,
	AbilityCooldown = 15,
	UseBehaviorTree = true,
	PatrolGroupTag = "BlottSiblings",
	StaresAtBlottHands = true,
	BlottHandStareDuration = 3,
	BlottHandStareCooldown = 25,
	BlottHandGlobalCooldown = 15,
	BlottHandStareDistance = 7,
	BlottHandGuardRadius = 150,
	BlottHandStareAnimation = "rbxassetid://0",
	FeedsBlottCandy = true,
	CandyDeliveryCooldown = 60,
	CandyDeliveryDuration = 2,
	CandyDeliveryDistance = 7,
	CandyDeliveryAnimation = "rbxassetid://0",
	HangsNearBlott = true,
	BlottIdleRadius = 30,
	BlottIdleFarTrigger = 60,
	BlottIdleCooldown = 8,
	CustomPatrol = function(p)
		return p.PatrolModule.buildCandyDelivery(p) or p.PatrolModule.buildHandStare(p) or p.PatrolModule.buildIdleNearBlott(p) or p.PatrolModule.buildGroupPatrol(p)
	end,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://98503048967129",
			NormalTexture = "rbxassetid://128539827303859",
			AttackTexture = "rbxassetid://110605873725900"
		}
	}
}

function YattaMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, YattaMonster.SpecialAnimatorData.Config)
end

return YattaMonster