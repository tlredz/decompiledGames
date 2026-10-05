local CoalMonster = {
	Name = "Twisted Coal",
	Rarity = "Rare",
	Icon = "rbxassetid://131591684347264",
	VisionRadius = 70,
	InstantRadius = 35,
	WalkSpeed = 8,
	RunSpeed = 16,
	InterestTime = 5,
	HearingRadius = 150,
	Damage = 1,
	WaitTime = 1.5,
	LineOfSight = 0.6,
	KillRadius = 3.33,
	HitCooldown = 3,
	BlackoutBuff = true,
	BlackoutStats = {
		VisionRadius = 125,
		InstantRadius = 35,
		WalkSpeed = 10,
		RunSpeed = 25,
		InterestTime = 3,
		HearingRadius = 200,
		Damage = 1,
		WaitTime = 2,
		LineOfSight = 0.4,
		KillRadius = 6.5,
		HitCooldown = 3
	},
	Holiday = true,
	Christmas = true,
	Trinket = "Coal",
	Render = "rbxassetid://17632349156",
	Description = "A dark and menacing Twisted, Coal lurks in the shadows and is particularly active during blackouts. Its slow movement is compensated by its superior vision and devastating attacks. Stay in the light to avoid this nightmare!",
	UseBehaviorTree = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			HeadComponentNames = { "LeftEye", "RightEye" },
			BlinkTexture = "rbxassetid://116185313184501",
			NormalTexture = "rbxassetid://109699131038476",
			AttackTexture = "rbxassetid://128043437171016"
		}
	}
}

function CoalMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, CoalMonster.SpecialAnimatorData.Config)
end

return CoalMonster