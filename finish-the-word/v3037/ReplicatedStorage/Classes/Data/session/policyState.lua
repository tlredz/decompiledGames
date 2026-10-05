local import = _G.import("class")
local PolicyService = game:GetService("PolicyService")
local v = import.new()

function v:new(p2)
	local success, result = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(p2)
	end)
	self.Policies = success and result or {}
end

return v