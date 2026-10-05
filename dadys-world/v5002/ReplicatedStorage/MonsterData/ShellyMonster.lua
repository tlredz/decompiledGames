local ShellyMonster = {
	Name = "Twisted Shelly",
	Rarity = "MainCharacter",
	Icon = "rbxassetid://18211657552",
	VisionRadius = 60,
	InstantRadius = 30,
	WalkSpeed = 10,
	RunSpeed = 20,
	InterestTime = 2,
	HearingRadius = 150,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 4,
	HitCooldown = 2,
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	Abilities = {},
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://84743996418738",
			NormalTexture = "rbxassetid://135902270929033",
			AttackTexture = "rbxassetid://79855414344851"
		}
	}
}

function ShellyMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, ShellyMonster.SpecialAnimatorData.Config)
end

return ShellyMonster