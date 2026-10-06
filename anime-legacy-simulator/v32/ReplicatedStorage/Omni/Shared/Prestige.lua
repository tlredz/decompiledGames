require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local v = {
	MapName = "Heaven Island",
	Icon = "rbxassetid://128202474900367",
	List = {
		[0] = {
			NeededLevel = 0,
			ExtraStatPoints = 0,
			ExpMultiplier = 1
		},
		[1] = {
			NeededLevel = 50,
			ExtraStatPoints = 1,
			ExpMultiplier = 1.25
		}
	}
}

function v.GetCurrentInfo(p)
	local v2 = v.List[p.Prestige.Amount]

	if v2 then
		return v2
	end

	local v3 = 0

	for k in v.List do
		if v3 < k then
			v3 = k
		end
	end

	return v.List[v3]
end

function v.GetNextInfo(p)
	return v.List[p.Prestige.Amount + 1]
end

function v.CanPrestige(p)
	local nextInfo = v.GetNextInfo(p)

	if nextInfo then
		return p.Level.Amount >= nextInfo.NeededLevel
	end

	return false
end

function v.GetExtraStatPoints(p)
	return v.GetCurrentInfo(p).ExtraStatPoints
end

function v.SystemSolver(p: string, p2)
	local v2 = {}

	if p == "Player Exp" then
		local currentInfo = v.GetCurrentInfo(p2)

		if currentInfo.ExpMultiplier > 1 then
			table.insert(v2, {
				Type = "Multi",
				Amount = currentInfo.ExpMultiplier
			})
		end
	end

	return v2
end

return table.freeze(v)