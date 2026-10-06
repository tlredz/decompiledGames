require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local v = {
	List = {},
	IsQuestAvailable = function(p: string, p2: string, p3)
		local v2 = false

		if p2 then
			local v3 = p3.Quests.List[p2]

			if v3 then
				local v4 = v3.List[p]

				if v4 then
					return v4.Available == true
				end
			end
		else
			for _, v3 in p3.Quests.List do
				local v4 = v3.List[p]

				if not v4 then
					continue
				end

				if v4.Available == true then
					v2 = true
				else
					v2 = false
				end
			end
		end

		return v2
	end
}

function v.CanCollectQuest(p: string, p2: string, p3)
	if not p2 then
		return false, "Failed"
	end

	local v2 = v.List[p2]
	local v3 = p3.Quests.List[p2]

	if not (v2 and v3) then
		return false, "Failed"
	end

	local v4 = v2.List[p]
	local v5 = v3.List[p]

	if v5 then
		if v5.Claimed then
			return false, "Claimed"
		end

		if v5.Available then
			return false, "AlreadyCollected"
		end

		if v4.CompletionCooldown and workspace:GetServerTimeNow() - (v5.LastCompletion or 0) < v4.CompletionCooldown then
			return false, "Cooldown"
		end

		if v4.MaximumCompletions then
			return v5.Completions < v4.MaximumCompletions, "MaxCompletions"
		end

		return true, "Success"
	elseif not v5 then
		return true, "Success"
	end

	return false, "Failed"
end

function v.GetQuestProgress(p: string, p2: string, p3)
	local v2 = 0
	local result = {}
	local v3 = v.List[p2]
	local v4 = p3.Quests.List[p2]

	if not (v3 and v4) then
		return v2, result
	end

	local v5 = v3.List[p]
	local v6 = v4.List[p]

	if v5 and v6 then
		for k, mission in v5.Missions do
			local v7 = (v6.Missions[k] or 0) / mission.Amount
			v2 += v7
			result[k] = v7
		end

		v2 /= #v5.Missions
	end

	return v2, result
end

function v.GetQuestMultiplier(p: string, p2: string, p3: string, p4)
	local perks = {}
	local v2 = v.List[p2]

	if not v2 then
		return perks
	end

	local v3 = v2.List[p3]

	if not v3 then
		return perks
	end

	local perk = v3.Perks[p]

	if not perk then
		return perks
	end

	local v4 = p4.Quests.List[p2]
	local v5 = v4 and v4.List[p3]

	if not v5 or not v5.Completions or v5.Completions <= 0 then
		return perks
	end

	for _ = 1, v3.PerksStack and v5.Completions or 1 do
		table.insert(perks, perk)
	end

	return perks
end

function v.GetAllQuestMultipliers(p: string, p2: string, p3)
	local result = {}
	local v2 = v.List[p]

	if not v2 then
		return result
	end

	local v3 = v2.List[p2]

	if not v3 then
		return result
	end

	for k in v3.Perks do
		result[k] = v.GetQuestMultiplier(k, p, p2, p3)
	end

	return result
end

function v.SystemSolver(p: string, p2)
	local result = {}

	for k, v2 in p2.Quests.List do
		for k2 in v2.List do
			local questMultiplier = v.GetQuestMultiplier(p, k, k2, p2)

			for _, v3 in questMultiplier do
				table.insert(result, v3)
			end
		end
	end

	return result
end

local IterateQuests

IterateQuests = function(instance, p)
	local result = {}

	for _, child in instance:GetChildren() do
		if child:IsA("Folder") then
			local iterateQuests = IterateQuests(child, p)

			for k, v3 in iterateQuests do
				result[k] = v3
			end
		elseif child:IsA("ModuleScript") then
			local module = require(child)

			if module then
				if module.Missions then
					local flag = true

					for _, mission in module.Missions do
						if typeof(mission.Type) == "string" and typeof(mission.Amount) == "number" and (not mission.Name or typeof(mission.Name) == "string") then
							if not mission.Title then
								mission.Title = "No title given"
							end

							if not mission.Description then
								mission.Description = "No description given"
							end

							flag = true
						else
							warn("[QUESTS] Corrupted quest, invalid mission info:", child, mission)
							flag = false
							break
						end
					end

					if flag then
						if not module.Perks then
							module.Perks = {}
						end

						if not module.Rewards then
							module.Rewards = {}
						end

						module.Name = child.Name
						module.Class = instance.Name

						if not module.Index then
							module.Index = 0
						end

						if not module.Description then
							module.Description = "No description given"
						end

						if p.AutoCollect then
							module.AutoCollect = true
						end

						result[module.Name] = module
					end
				else
					warn("[QUESTS] Corrupted quest, no missions given:", child)
				end
			end
		end
	end

	return result
end

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)

	if not module then
		continue
	end

	if not module.Index then
		module.Index = 0
	end

	module.List = IterateQuests(moduleScript, module)
	v.List[moduleScript.Name] = module
end

return table.freeze(v)