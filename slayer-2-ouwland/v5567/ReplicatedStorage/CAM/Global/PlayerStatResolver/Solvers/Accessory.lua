local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local Series = require(ReplicatedStorage.CAM.Global.Series)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local CombatBalance = require(ReplicatedStorage.CAM.Global.CombatBalance)
return function(p, p2: string, list, _, flag: boolean?)
	local v

	if flag == true then
		v = CombatBalance.IsWeighted(p2)
	else
		v = false
	end

	local v2 = StatTypes.HighestOnlyStats[p2] == true
	local v3 = 0

	for _, v4 in ipairs(list) do
		local item = Items[v4]

		if not (item and item.Stats) then
			continue
		end

		local stat = item.Stats[p2]

		if stat == true then
			return true
		end

		if typeof(stat) ~= "number" then
			continue
		end

		if Series.SetOf(v4) ~= nil or item.Refinable == true then
			local v5 = not v and 1 or CombatBalance.Knob(v4, "Upgrades")
			local wornEntry = Series.WornEntry(p, v4)
			local multiplier = Series.Multiplier(wornEntry)

			if v5 ~= 1 then
				multiplier = 1 + (multiplier - 1) * v5
			end

			stat *= multiplier
			local refineLevel

			if wornEntry ~= nil then
				refineLevel = wornEntry:FindFirstChild("RefineLevel")
			end

			if refineLevel ~= nil then
				local statMultiplier = Refinement.GetStatMultiplier(v4, p2, refineLevel.Value, p)

				if v5 ~= 1 then
					statMultiplier = 1 + (statMultiplier - 1) * v5
				end

				stat *= statMultiplier
			end
		end

		if v then
			stat *= CombatBalance.Knob(v4, "Stats")
		end

		if v2 then
			v3 = math.max(v3, stat)
		else
			v3 += stat
		end
	end

	return v3
end