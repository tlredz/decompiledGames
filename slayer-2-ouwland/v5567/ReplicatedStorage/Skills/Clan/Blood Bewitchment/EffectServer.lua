local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local Utility = require(CAM.Global.Utility)
local StatTypes = require(CAM.Global.Types.StatTypes)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Config = require(ReplicatedStorage.Skills.Clan.Activation.Config)
local name = script.Parent.Name
return {
	Activate = function(_, p, instance)
		if p == nil or instance == nil then
			return
		end

		local v = Config.STAT_MARKS[name]
		local child = instance:FindFirstChild(name)

		if child == nil or v == nil then
			return
		end

		local child2 = instance:FindFirstChild(Combat_Util.RETALIATION_VALUE)

		if child2 ~= nil then
			child2:Destroy()
		end

		local v2 = Utility.AddValue(instance, Combat_Util.RETALIATION_VALUE)
		v2:SetAttribute("_Mark", "Bewitched")
		v2:SetAttribute("_Duration", v.EnemyDuration)

		for k, v3 in v do
			if k ~= "Duration" and k ~= "Enemies" and k ~= "EnemyDuration" then
				v2:SetAttribute(StatTypes.StatToAttribute(k), v3)
			end
		end

		child.Destroying:Once(function()
			if v2.Parent ~= nil then
				v2:Destroy()
			end
		end)
	end
}