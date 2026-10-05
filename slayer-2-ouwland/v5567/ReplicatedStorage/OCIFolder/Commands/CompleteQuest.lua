local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local isServer = RunService:IsServer()
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local QuestCompletion

if isServer then
	QuestCompletion = require(ServerStorage.SAM.Utility.QuestCompletion)
else
	QuestCompletion = nil
end

local function resolveTarget(list)
	local localPlayer = Players.LocalPlayer
	local v

	if list ~= nil then
		v = list[1] or nil
	end

	if v == nil or v == "" or v:lower() == "me" then
		return localPlayer
	end

	local lower = v:lower()
	local v2 = nil

	for _, v3 in Players:GetPlayers() do
		local name = v3.Name:lower()
		local displayName = v3.DisplayName:lower()

		if name == lower or displayName == lower then
			return v3
		end

		if not (v2 == nil and (name:sub(1, #lower) == lower or displayName:sub(1, #lower) == lower)) then
			continue
		end

		v2 = v3
	end

	return v2 or localPlayer
end

local function findChild(instance, childName: string)
	if instance == nil then
		return nil
	end

	local child = instance:FindFirstChild(childName)

	if child ~= nil then
		return child
	end

	local lower = childName:lower()

	for _, child2 in ipairs(instance:GetChildren()) do
		if child2.Name:lower() == lower then
			return child2
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function questHolder(p)
	if p == nil then
		return nil
	end

	local data = Utility.GetData(p)
	local quests = data ~= nil and data:FindFirstChild("Quests") or nil
	return quests ~= nil and quests:FindFirstChild("Holder") or nil
end

local function questNames(p)
	local names = {}
	local v = questHolder(p) -- equivalent call inferred; original call site unknown

	if v == nil then
		return names
	end

	for _, child in ipairs(v:GetChildren()) do
		if child:FindFirstChild("Tasks") ~= nil then
			table.insert(names, child.Name)
		end
	end

	return names
end

return {
	Clearance = 1,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Quest",
			Name = "Quest",
			Required = true,
			Suggester = function(p)
				return questNames(resolveTarget(p)), true
			end,
			Completer = function(value: string, p)
				if value == nil or value == "" then
					return nil
				end

				if isServer then
					return value
				end

				local lower = value:lower()
				local v = questNames(resolveTarget(p))

				for _, v2 in ipairs(v) do
					if v2:lower() == lower then
						return v2
					end
				end

				for _, v2 in ipairs(v) do
					if v2:lower():sub(1, #lower) == lower then
						return v2
					end
				end

				return value
			end
		}
	},
	Server = function(_, list, value: string)
		if type(list) ~= "table" or #list == 0 then
			error("CompleteQuest: no valid players targeted")
		end

		if type(value) ~= "string" or value == "" then
			error("CompleteQuest: pick a quest")
		end

		for _, v in ipairs(list) do
			local v3 = questHolder(v) -- equivalent call inferred; original call site unknown
			local v4 = findChild(v3, value)
			local tasks

			if v4 ~= nil then
				tasks = v4:FindFirstChild("Tasks") or nil
			end

			if tasks == nil then
				warn((`CompleteQuest: {v.Name} has no active quest "{value}"`))
			else
				for _, child in ipairs(tasks:GetChildren()) do
					local value2 = child:FindFirstChild("Value")
					local max = child:FindFirstChild("Max")

					if value2 ~= nil and max ~= nil and value2.Value < max.Value then
						value2.Value = max.Value
					end
				end

				if not QuestCompletion.TryComplete(v, v4) then
					warn((`CompleteQuest: "{value}" on {v.Name} did not complete (no countable tasks?)`))
				end
			end
		end
	end
}