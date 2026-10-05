local rankInGroups = {}

local function GetUserRank(object)
	if not rankInGroups[object] then
		rankInGroups[object] = object:GetRankInGroup(15109848)
	end

	return rankInGroups[object]
end

return {
	{
		Name = "Roblox Verified",
		Icon = "rbxassetid://15802896714",
		IconColor = Color3.new(1, 1, 1),
		Condition = function(p)
			return p.HasVerifiedBadge
		end
	},
	{
		Name = "Neighbors Developer",
		Icon = "rbxassetid://15802845064",
		IconColor = Color3.new(1, 0.254902, 0.254902),
		Condition = function(object)
			if not rankInGroups[object] then
				rankInGroups[object] = object:GetRankInGroup(15109848)
			end

			return rankInGroups[object] == 200
		end
	},
	{
		Name = "Neighbors Tester",
		Icon = "rbxassetid://15803168937",
		IconColor = Color3.new(1, 0.254902, 0.254902),
		Condition = function(object)
			local v = true

			if not rankInGroups[object] then
				rankInGroups[object] = object:GetRankInGroup(15109848)
			end

			if rankInGroups[object] ~= 25 then
				if not rankInGroups[object] then
					rankInGroups[object] = object:GetRankInGroup(15109848)
				end

				return rankInGroups[object] == 30
			end

			return v
		end
	},
	{
		Name = "Neighbors Moderator",
		Icon = "rbxassetid://15802872630",
		IconColor = Color3.new(0.333333, 1, 0.498039),
		Condition = function(object)
			local v = true

			if not rankInGroups[object] then
				rankInGroups[object] = object:GetRankInGroup(15109848)
			end

			if rankInGroups[object] ~= 100 then
				if not rankInGroups[object] then
					rankInGroups[object] = object:GetRankInGroup(15109848)
				end

				return rankInGroups[object] == 250
			end

			return v
		end
	}
}