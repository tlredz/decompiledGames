require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local module = require("@game/ReplicatedStorage/Omni/Utils/Number")
local v = {
	["Trial Easy"] = {
		Data = "Highest Trial Easy Wave",
		Desc = "Reach wave %* in Trial Easy",
		Category = "Gamemodes",
		TypeDesc = "Reach the highest wave in Trial Easy",
		Icon = "rbxassetid://78701720672609"
	},
	["Dungeon Easy"] = {
		Data = "Highest Dungeon Easy Wave",
		Desc = "Clear %* rooms in Dungeon Easy",
		Category = "Gamemodes",
		TypeDesc = "Clear rooms in a single dungeon run",
		Icon = "rbxassetid://108902719151872"
	},
	["Culling Game Easy"] = {
		Data = "Highest Culling Game Easy Wave",
		Desc = "Reach wave %* in Culling Game Easy",
		Category = "Gamemodes",
		TypeDesc = "Reach the highest wave in Culling Game Easy",
		Icon = "rbxassetid://102942968227299"
	},
	["Culling Game Medium"] = {
		Data = "Highest Culling Game Medium Wave",
		Desc = "Reach wave %* in Culling Game Medium",
		Category = "Gamemodes",
		TypeDesc = "Reach the highest wave in Culling Game Medium",
		Icon = "rbxassetid://102942968227299"
	},
	["Culling Game Hard"] = {
		Data = "Highest Culling Game Hard Wave",
		Desc = "Reach wave %* in Culling Game Hard",
		Category = "Gamemodes",
		TypeDesc = "Reach the highest wave in Culling Game Hard",
		Icon = "rbxassetid://102942968227299"
	},
	["Star Open"] = {
		Data = "Total Stars Opened",
		Desc = "Open %* stars",
		Category = "Worlds",
		TypeDesc = "Master the art of star opening",
		Icon = "rbxassetid://95235816548276"
	},
	["Defeated Enemies"] = {
		Data = "Defeated Enemies",
		Desc = "Defeat %* enemies",
		Category = "Worlds",
		TypeDesc = "Be the best at defeating enemies",
		Icon = "rbxassetid://117365503025959"
	},
	["Highest Power"] = {
		Data = "Highest Power",
		Desc = "Reach %* Power",
		Category = "Worlds",
		TypeDesc = "Reach the highest power levels",
		Icon = "rbxassetid://130585331881625"
	},
	["Damage Dealt"] = {
		Data = "Damage Dealt",
		Desc = "Deal %* Damage",
		Category = "Worlds",
		TypeDesc = "Deal the most damage to enemies",
		Icon = "rbxassetid://81941152561733"
	},
	["Time Played"] = {
		Time = true,
		Data = "Time Played",
		Desc = "Play for %*",
		Category = "Worlds",
		TypeDesc = "Play the longest as possible",
		Icon = "rbxassetid://120408004048095"
	}
}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {
	List = {},
	GetInfo = function(p: string)
		return v2[p]
	end,
	GetTypesFromCategory = function(p: string)
		local result = {}

		for k, v6 in v do
			if (v6.Category or "World") == p then
				table.insert(result, k)
			end
		end

		return result
	end,
	GetTypesFromStat = function(p: string)
		return v4[p]
	end,
	GetTypeDescription = function(p: string)
		local v6 = v[p]
		return v6 and v6.TypeDesc or "No description given"
	end,
	GetTypeIcon = function(p: string)
		local v6 = v[p]
		return v6 and v6.Icon or ""
	end,
	GetProgress = function(p, p2)
		local v6 = v[p2.Mission.Type]

		if not v6 then
			return 0, 0, 0, false
		end

		local v7 = p.Profile.Stats[v6.Data] or 0
		local v8 = v3[p2] or module:Unformat(p2.Mission.Amount)

		if v6.Time then
			v7 /= 60
		end

		local time = v6.Time == true
		return v7, v8, math.clamp((v7 or 0) / v8, 0, 1), time
	end
}

function v5.GetInformation(p, p2)
	local v6 = v[p2.Mission.Type]

	if not v6 then
		return 0, 0, 0, "", false
	end

	local progress, v7, v8, v9 = v5.GetProgress(p, p2)
	local v10 = v9 and module:Time2(v7 * 60) or module:Format(v7)
	return progress, v7, v8, string.format(v6.Desc, v10), v9
end

function v5.GetAchievementMultiplier(p: string, p2: string)
	local v6 = {}
	local info = v5.GetInfo(p2)
	local v7 = info and info.Perks[p]

	if v7 then
		table.insert(v6, v7)
	end

	return v6
end

function v5.GetAllAchievementMultipliers(p: string)
	local v6 = {}
	local result = {}
	local info = v5.GetInfo(p)

	if not info then
		return result
	end

	for k, _ in info.Perks do
		v6[k] = true
	end

	for k, _ in v6 do
		result[k] = v5.GetAchievementMultiplier(k, p)
	end

	return result
end

function v5.SystemSolver(p: string, p2)
	local result = {}

	for k, _ in p2.Achievements do
		local v6 = v2[k]
		local v7 = v6 and v6.Perks[p]

		if v7 then
			table.insert(result, v7)
		end
	end

	return result
end

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module2, v6, v7 = require(moduleScript)
	local v8 = {}

	for k, v9 in module2, v6, v7 do
		local roman = module:ToRoman(k)
		local name = string.format("%* %*", moduleScript.Name, (tostring(roman)))
		v9.Name = name
		v8[k] = v9
		v2[name] = v9
		local mission = v9.Mission

		if typeof(mission) == "table" and mission.Amount ~= nil then
			v3[v9] = module:Unformat(mission.Amount)
		end

		local v11

		if typeof(mission) == "table" then
			v11 = v[mission.Type]
		else
			v11 = false
		end

		if not v11 then
			continue
		end

		local names = v4[v11.Data] or {}
		v4[v11.Data] = names

		if not table.find(names, moduleScript.Name) then
			table.insert(names, moduleScript.Name)
		end
	end

	v5.List[moduleScript.Name] = v8
end

return table.freeze(v5)