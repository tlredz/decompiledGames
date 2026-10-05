local ToodlesMonster = {
	Name = "Twisted Toodles",
	Rarity = "Uncommon",
	Icon = "rbxassetid://17643350074",
	VisionRadius = 50,
	InstantRadius = 25,
	WalkSpeed = 12,
	RunSpeed = 20,
	InterestTime = 1,
	HearingRadius = 125,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 3.33,
	HitCooldown = 3,
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	HearingPriority = "high",
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://133004945930095",
			NormalTexture = "rbxassetid://139290864413083",
			AttackTexture = "rbxassetid://100773041934854"
		}
	}
}

function ToodlesMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, ToodlesMonster.SpecialAnimatorData.Config)
end

return ToodlesMonster