local PoppyMonster = {
	Name = "Twisted Poppy",
	Rarity = "Common",
	Icon = "rbxassetid://17011493901",
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
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://119055206267698",
			NormalTexture = "rbxassetid://86450922386911",
			AttackTexture = "rbxassetid://84346243312439"
		}
	}
}

function PoppyMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, PoppyMonster.SpecialAnimatorData.Config)
end

return PoppyMonster