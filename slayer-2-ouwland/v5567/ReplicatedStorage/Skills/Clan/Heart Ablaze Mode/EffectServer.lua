local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local AppliedTicks = require(CAM.Global.Subsets.Gameplay.AppliedTicks)
local Config = require(script.Parent.Config)
local name = script.Parent.Name
return {
	Activate = function(p, p2, instance)
		if p2 == nil or instance == nil then
			return
		end

		local child = instance:FindFirstChild(name)

		if child == nil then
			return
		end

		local child2 = instance:FindFirstChild(Combat_Util.THORNS_VALUE)

		if child2 ~= nil then
			child2:Destroy()
		end

		local v = p ~= nil and 1 or Config.BOSS_THORNS_SCALE
		local v2 = Utility.AddValue(instance, Combat_Util.THORNS_VALUE)
		v2:SetAttribute("TickValue", AppliedTicks.ByName.Flame.Value)
		v2:SetAttribute("Ratio", Config.THORNS_RATIO * v)
		v2:SetAttribute("MinDamage", Config.THORNS_MIN_DAMAGE)
		v2:SetAttribute("TickDuration", Config.THORNS_DURATION)
		v2:SetAttribute("TickEvery", Config.THORNS_EVERY)
		v2:SetAttribute("Skill", name)
		child.Destroying:Once(function()
			if v2.Parent ~= nil then
				v2:Destroy()
			end
		end)
	end
}