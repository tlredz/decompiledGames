local CosmoMonster = {
	Name = "Twisted Cosmo",
	Rarity = "Common",
	Icon = "rbxassetid://18673000387",
	VisionRadius = 60,
	InstantRadius = 26,
	WalkSpeed = 10,
	RunSpeed = 18,
	InterestTime = 1.5,
	HearingRadius = 125,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 3.333,
	HitCooldown = 3,
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	HearingPriority = "high",
	PatrolCompanion = "SproutMonster",
	CompanionRole = "leader",
	CompanionFollowDistance = 12,
	CompanionWaitTimeout = 6,
	CustomPatrol = function(p)
		return p.PatrolModule.buildCompanionPatrol(p)
	end,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://84784918176150",
			NormalTexture = "rbxassetid://119118626948975",
			AttackTexture = "rbxassetid://72137664102945"
		}
	}
}

function CosmoMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, CosmoMonster.SpecialAnimatorData.Config)
end

return CosmoMonster