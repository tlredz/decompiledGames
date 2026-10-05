local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SkillStats = require(script.Parent.Parent.Parent.Modules.SkillStats)
return {
	HasStunBypass = function(instance, value: string?)
		if Utility.getvaluesfolder(instance):FindFirstChild("Strict_Stun") ~= nil then
			return false
		end

		if value == nil then
			local SHC = instance:FindFirstChild("SHC") or instance:FindFirstChild("SHCS")

			if SHC then
				value = SHC.Value
			end
		end

		if value == nil or value == "" then
			return false
		end

		local v = SkillStats.Get(value, instance)

		if v ~= nil and v.stun_bypass_skill then
			return true
		end

		return false
	end
}