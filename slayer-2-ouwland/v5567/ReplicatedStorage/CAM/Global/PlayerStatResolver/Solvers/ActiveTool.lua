local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local Series = require(ReplicatedStorage.CAM.Global.Series)
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

		if item.ActiveToolStats then
			local activeToolStat = item.ActiveToolStats[p2]

			if typeof(activeToolStat) == "number" and activeToolStat ~= 0 then
				local entry = list.Entry

				if entry ~= nil and entry.Name == v5 then
					local v6 = not v and 1 or CombatBalance.Knob(v5, "Upgrades")
					local refineLevel = entry:FindFirstChild("RefineLevel")

					if refineLevel ~= nil then
						local statMultiplier = Refinement.GetStatMultiplier(v5, p2, refineLevel.Value, p)

						if v6 ~= 1 then
							statMultiplier = 1 + (statMultiplier - 1) * v6
						end

						activeToolStat *= statMultiplier
					end

					local multiplier = Series.Multiplier(entry)

					if v6 ~= 1 then
						multiplier = 1 + (multiplier - 1) * v6
					end

					activeToolStat *= multiplier
				end

				if v then
					activeToolStat *= CombatBalance.Knob(v5, "Stats")
				end
			end

			if activeToolStat == true then
				v4 = true
			elseif typeof(activeToolStat) == "number" then
				if v2 then
					v3 = math.max(v3, activeToolStat)
				else
					v3 += activeToolStat
				end
			end
		end

		if not item.Skills then
			continue
		end

		for _, skill in ipairs(item.Skills) do
			if not skill.ActiveToolStats then
				continue
			end

			local activeToolStat = skill.ActiveToolStats[p2]

			if activeToolStat == true then
				v4 = true
			elseif typeof(activeToolStat) == "number" then
				if v2 then
					v3 = math.max(v3, activeToolStat)
				else
					v3 += activeToolStat
				end
			end
		end
	end

	return v4 and true or v3
end