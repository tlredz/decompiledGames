local EggsonMonster = {
	Name = "Twisted Eggson",
	Rarity = "Common",
	HolidayTwisted = true,
	EasterTwisted = true,
	Holiday = true,
	Easter = true,
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
	Trinket = "EggRadar",
	Icon = "rbxassetid://90676203863684",
	Render = "rbxassetid://107135013232148",
	Description = "One of the most common Twisteds you'll encounter. Overcome by Ichor, this Twisted has the innate urge to chase others down. Thankfully, it appears that this Twisted doesn't have any abilities to aid him.",
	ChaseAbility = false,
	AbilityCooldown = 15,
	UseBehaviorTree = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://117079213453099",
			NormalTexture = "rbxassetid://140031293645436",
			AttackTexture = "rbxassetid://117244795084049"
		}
	}
}

function EggsonMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, EggsonMonster.SpecialAnimatorData.Config)
end

return EggsonMonster