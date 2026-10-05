local RibeccaMonster = {
	Name = "Twisted Ribecca",
	Rarity = "Common",
	Icon = "rbxassetid://108943745948703",
	VisionRadius = 60,
	InstantRadius = 26,
	WalkSpeed = 10,
	RunSpeed = 18,
	InterestTime = 1.5,
	HearingRadius = 125,
	Holiday = true,
	Halloween = true,
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
			AttackTexture = "rbxassetid://138829182404494",
			BlinkTexture = "rbxassetid://79315815650913",
			NormalTexture = "rbxassetid://75519713276354"
		}
	}
}

function RibeccaMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, RibeccaMonster.SpecialAnimatorData.Config)
end

return RibeccaMonster