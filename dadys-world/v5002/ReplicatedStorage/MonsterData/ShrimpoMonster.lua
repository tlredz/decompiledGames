local ShrimpoMonster = {
	Name = "Twisted Shrimpo",
	Rarity = "Common",
	Icon = "rbxassetid://17583256112",
	VisionRadius = 70,
	InstantRadius = 28,
	WalkSpeed = 9.5,
	RunSpeed = 16.5,
	InterestTime = 2,
	HearingRadius = 125,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 3.33,
	HitCooldown = 3,
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			AttackTexture = "rbxassetid://129523370370878",
			BlinkTexture = "rbxassetid://121945968028220",
			NormalTexture = "rbxassetid://127921644759978"
		}
	}
}

function ShrimpoMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, ShrimpoMonster.SpecialAnimatorData.Config)
end

return ShrimpoMonster