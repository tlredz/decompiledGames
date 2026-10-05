local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local isServer = RunService:IsServer()
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
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

local function taskLabels(p)
	local result = {}
	local v = questHolder(p) -- equivalent call inferred; original call site unknown

	if v == nil then
		return result
	end

	for _, child in ipairs(v:GetChildren()) do
		local tasks = child:FindFirstChild("Tasks")

		if tasks == nil then
			continue
		end

		for _, child2 in ipairs(tasks:GetChildren()) do
			if not (child2:FindFirstChild("Value") ~= nil and child2:FindFirstChild("Max") ~= nil) then
				continue
			end

			table.insert(result, child.Name .. " / " .. child2.Name)
		end
	end

	return result
end

return {
	Clearance = 1,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Task",
			Name = "Quest / Task",
			Required = true,
			Suggester = function(p)
				return taskLabels(resolveTarget(p)), true
			end,
			Completer = function(value: string, p)
				if value == nil or value == "" then
					return nil
				end

				if isServer then
					return value
				end

				local lower = value:lower()
				local v = taskLabels(resolveTarget(p))

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
			error("CompleteTask: no valid players targeted")
		end

		if type(value) ~= "string" or value == "" then
			error("CompleteTask: pick a task as \"<Quest> / <Task>\"")
		end

		local v = value:find(" / ", 1, true)

		if v == nil then
			error((`CompleteTask: "{value}" is not a "<Quest> / <Task>" label`))
		end

		local v2 = value:sub(1, v - 1)
		local v3 = value:sub(v + 3)

		for _, v4 in ipairs(list) do
			local v6 = questHolder(v4) -- equivalent call inferred; original call site unknown
			local v7 = findChild(v6, v2)
			local v9

			if v7 ~= nil then
				v9 = v7:FindFirstChild("Tasks") or nil
			end

			local v10 = findChild(v9, v3)
			local value2

			if v10 ~= nil then
				value2 = v10:FindFirstChild("Value") or nil
			end

			local max

			if v10 ~= nil then
				max = v10:FindFirstChild("Max") or nil
			end

			if v7 == nil or value2 == nil or max == nil then
				warn((`CompleteTask: {v4.Name} has no active task "{value}"`))
			else
				if value2.Value < max.Value then
					value2.Value = max.Value
					local questString = v7:FindFirstChild("QuestString")
					local questInfo = Quests.GetQuestInfo(questString ~= nil and questString.Value or v7.Name)
					local v11

					if not (questInfo == nil or questInfo.TaskSpecs == nil) then
						v11 = questInfo.TaskSpecs[v10.Name] or nil
					end

					if v11 ~= nil then
						QuestCompletion.Notify(v4, v11.CompletionNotify)
					end
				end

				QuestCompletion.TryComplete(v4, v7)
			end
		end
	end
}