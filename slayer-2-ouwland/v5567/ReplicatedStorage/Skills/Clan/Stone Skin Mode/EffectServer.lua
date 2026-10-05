local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Config = require(script.Parent.Config)
local name = script.Parent.Name
return {
	Activate = function(_, p, instance)
		if p == nil or instance == nil then
			return
		end

		local child = instance:FindFirstChild(name)

		if child == nil then
			return
		end

		local child2 = instance:FindFirstChild(Combat_Util.REFLECT_VALUE)

		if child2 ~= nil then
			child2:Destroy()
		end

		local v = Utility.AddValue(instance, Combat_Util.REFLECT_VALUE)
		v:SetAttribute("Share", Config.REFLECT_SHARE)
		v:SetAttribute("M1Only", true)
		v:SetAttribute("Skill", name)
		child.Destroying:Once(function()
			if v.Parent ~= nil then
				v:Destroy()
			end
		end)
	end
}