local RunService = game:GetService("RunService")
return {
	getPlayerGroups = function(object)
		local v = {}

		if object:GetRankInGroup(game.CreatorId) >= 253 or RunService:IsStudio() then
			v.Admin = true
		end

		return v
	end
}