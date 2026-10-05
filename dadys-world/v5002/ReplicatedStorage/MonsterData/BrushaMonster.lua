local BrushaMonster = {
	Name = "Twisted Brusha",
	Rarity = "Common",
	Icon = "rbxassetid://121361541898971",
	VisionRadius = 85,
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
	GraffitiScanRange = 60,
	GraffitiCooldown = 45,
	GraffitiChannel = 5,
	GraffitiArrivalRadius = 8
}
local v = nil

local function graffitiController()
	if v == nil then
		local success, result = pcall(function()
			local ServerScriptService = game:GetService("ServerScriptService")
			return require(ServerScriptService.MonsterAI.Modules.BrushaGraffitiController)
		end)
		v = success and result or false
	end

	return v or nil
end

BrushaMonster.CustomDiverts = {
	{
		name = "graffiti",
		find = function(p)
			if v == nil then
				local success, result = pcall(function()
					local ServerScriptService = game:GetService("ServerScriptService")
					return require(ServerScriptService.MonsterAI.Modules.BrushaGraffitiController)
				end)
				v = success and result or false
			end

			local v2 = v or nil
			return v2 and v2.findTarget(p) or nil
		end,
		onArriveStart = function(p)
			if v == nil then
				local success, result = pcall(function()
					local ServerScriptService = game:GetService("ServerScriptService")
					return require(ServerScriptService.MonsterAI.Modules.BrushaGraffitiController)
				end)
				v = success and result or false
			end

			local v2 = v or nil

			if v2 then
				v2.beginPaint(p)
			end
		end,
		onArrive = function(p)
			if v == nil then
				local success, result = pcall(function()
					local ServerScriptService = game:GetService("ServerScriptService")
					return require(ServerScriptService.MonsterAI.Modules.BrushaGraffitiController)
				end)
				v = success and result or false
			end

			local v2 = v or nil

			if v2 then
				v2.paintAt(p)
			end
		end,
		onNotArrived = function(p)
			if v == nil then
				local success, result = pcall(function()
					local ServerScriptService = game:GetService("ServerScriptService")
					return require(ServerScriptService.MonsterAI.Modules.BrushaGraffitiController)
				end)
				v = success and result or false
			end

			local v2 = v or nil

			if v2 then
				v2.markUnreachable(p)
			end
		end,
		channel = function()
			return BrushaMonster.GraffitiChannel
		end,
		arrivalRadius = BrushaMonster.GraffitiArrivalRadius
	}
}
BrushaMonster.SpecialAnimatorData = {
	Module = "MonsterModules/SpecialAnimator",
	Config = {
		BlinkTexture = "rbxassetid://74157684903817",
		NormalTexture = "rbxassetid://111649343607997",
		AttackTexture = "rbxassetid://87787387473178"
	}
}

function BrushaMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, BrushaMonster.SpecialAnimatorData.Config)
end

return BrushaMonster