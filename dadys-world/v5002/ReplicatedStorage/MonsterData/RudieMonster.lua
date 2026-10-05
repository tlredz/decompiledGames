local RudieMonster = {
	Name = "Twisted Rudie",
	Rarity = "Common",
	Icon = "rbxassetid://106888954860502",
	Holiday = true,
	Christmas = true,
	VisionRadius = 60,
	InstantRadius = 26,
	WalkSpeed = 10,
	RunSpeed = 18,
	InterestTime = 1.5,
	HearingRadius = 125,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 3.33,
	HitCooldown = 3,
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	Trinket = "FestiveLights",
	Render = "rbxassetid://17632349157",
	Description = "An energetic and fast Twisted, Rudie makes up for their poor vision with incredible speed. They're easily distracted but quick to chase down their targets. Don't let their playful nature fool you!",
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://128197801422399",
			NormalTexture = "rbxassetid://135128829863755",
			AttackTexture = "rbxassetid://105811648483039"
		}
	}
}

function RudieMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, RudieMonster.SpecialAnimatorData.Config)
end

return RudieMonster