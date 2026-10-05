local TeaganMonster = {
	Name = "Twisted Teagan",
	Rarity = "Uncommon",
	Icon = "rbxassetid://18194852499",
	VisionRadius = 60,
	InstantRadius = 26,
	WalkSpeed = 10,
	RunSpeed = 18.5,
	HearingRadius = 125,
	LineOfSight = 0.4,
	Damage = 1,
	KillRadius = 3.333,
	HitCooldown = 3,
	InterestTime = 1.75,
	WaitTime = 1,
	AttackAbility = true,
	AbilityCooldown = 3,
	UseBehaviorTree = true
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = ReplicatedStorage.Events.PopUpEvent
TeaganMonster.SpecialAnimatorData = {
	Module = "MonsterModules/SpecialAnimator",
	Config = {
		BlinkTexture = "rbxassetid://92564282308967",
		NormalTexture = "rbxassetid://79366431401776",
		AttackTexture = "rbxassetid://88646982381789"
	}
}

function TeaganMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, TeaganMonster.SpecialAnimatorData.Config)
end

function TeaganMonster.UseAttackAbility(instance, instance2, _)
	instance:WaitForChild("HumanoidRootPart")
	instance2:WaitForChild("HumanoidRootPart")
	local child = instance2 and workspace.Info.PlayerStats:FindFirstChild(instance2.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		local v = math.round(survivalPoints.Value * 0.2)
		local v2 = v <= 20 and 20 or v
		survivalPoints.Value -= v2

		if survivalPoints.Value <= 0 then
			survivalPoints.Value = 0
		end
	end
end

return TeaganMonster