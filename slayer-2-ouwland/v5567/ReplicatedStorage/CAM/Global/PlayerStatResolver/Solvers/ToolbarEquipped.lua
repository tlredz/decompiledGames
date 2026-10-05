local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local CombatBalance = require(ReplicatedStorage.CAM.Global.CombatBalance)
return function(_, p: string, list, _, flag: boolean?)
	local v

	if flag == true then
		v = CombatBalance.IsWeighted(p)
	else
		v = false
	end

	local v2 = StatTypes.HighestOnlyStats[p] == true
	local v3 = 0
	local v4 = false

	local function add(value)
		if value == true then
			v4 = true
		elseif typeof(value) == "number" then
			local v5

			if v2 then
				v5 = math.max(v3, value)
			else
				v5 = v3 + value
			end

			v3 = v5
		end
	end

	for _, v5 in ipairs(list) do
		local item = Items[v5]

		if not item then
			continue
		end

		if item.ToolbarStats then
			local toolbarStat = item.ToolbarStats[p]

			if v and typeof(toolbarStat) == "number" then
				toolbarStat *= CombatBalance.Knob(v5, "Stats")
			end

			if toolbarStat == true then
				v4 = true
			elseif typeof(toolbarStat) == "number" then
				if v2 then
					v3 = math.max(v3, toolbarStat)
				else
					v3 += toolbarStat
				end
			end
		end

		if not item.Skills then
			continue
		end

		for _, skill in ipairs(item.Skills) do
			if not skill.ToolbarStats then
				continue
			end

			local toolbarStat = skill.ToolbarStats[p]

			if toolbarStat == true then
				v4 = true
			elseif typeof(toolbarStat) == "number" then
				if v2 then
					v3 = math.max(v3, toolbarStat)
				else
					v3 += toolbarStat
				end
			end
		end
	end

	return v4 and true or v3
end