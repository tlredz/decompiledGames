local SkillStats = require(script.Parent.Parent.Parent.Modules.SkillStats)
return {
	HasCancelBypass = function(instance, value: string?)
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

		if v ~= nil and v.cancel_bypass then
			return true
		end

		return false
	end
}