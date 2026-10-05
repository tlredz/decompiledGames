local DandyMonster = {
	Name = "Twisted Dandy",
	Rarity = "Lethal",
	Icon = "rbxassetid://17515073882",
	VisionRadius = 80,
	InstantRadius = 35,
	WalkSpeed = 9,
	RunSpeed = 16,
	InterestTime = 5,
	HearingRadius = 9999,
	Damage = 99,
	WaitTime = 3,
	LineOfSight = 0.4,
	KillRadius = 8.5,
	HitCooldown = 5,
	ChaseAbility = false,
	AbilityCooldown = 0,
	Lethal = true,
	NoTargetOverride = true,
	GuardsTapes = false,
	TapeGuardRadius = 60,
	UseBehaviorTree = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://81125720755078",
			NormalTexture = "rbxassetid://95233809632840",
			AttackTexture = "rbxassetid://134509123011380"
		}
	}
}

function DandyMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, DandyMonster.SpecialAnimatorData.Config)
end

return DandyMonster