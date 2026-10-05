local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local ServerStorage = isServer and game:GetService("ServerStorage") or nil
local v = nil
local v2 = false
local v3 = nil

local function ensureServerDeps()
	if v3 or not isServer then
		return
	end

	local SAM = ServerStorage and ServerStorage:FindFirstChild("SAM") or nil
	local services = SAM and SAM:FindFirstChild("Services") or nil
	local chestService = services and services:FindFirstChild("ChestService") or nil

	if chestService == nil then
		return
	end

	local module = require(chestService)
	v3 = module
end

local function resolveCharacterFrame(player)
	local character = player.Character

	if character == nil then
		return nil, nil
	end

	local pivot = character:GetPivot()
	return pivot.Position, pivot
end

local function collectClientIds()
	if not v2 then
		v2 = true
		local success, chestController = pcall(require, ReplicatedStorage.CAM.Client.Controllers.ChestController)

		if success then
			v = chestController
		end
	end

	if v and v.getChestIds then
		local chestIds = v.getChestIds()

		if typeof(chestIds) == "table" and #chestIds > 0 then
			return chestIds
		end
	end

	return {}
end

local function collectServerIds()
	if v3 and v3.GetAllConfigs then
		local success, allConfigs = pcall(v3.GetAllConfigs)

		if success and typeof(allConfigs) == "table" then
			local result = {}

			for k in allConfigs do
				result[#result + 1] = k
			end

			table.sort(result)
			return result
		end
	end

	return {}
end

local function chestIdSuggester()
	local selected

	if isServer then
		selected = collectServerIds()
	else
		selected = collectClientIds()
	end

	if #selected == 0 then
		return { "Common Chest" }, true
	end

	return selected, true
end

return {
	Clearance = 1,
	Keys = {
		{
			Type = "Player",
			Name = "Player",
			Required = true
		},
		{
			Type = "String",
			Name = "ChestId",
			Required = true,
			Suggester = chestIdSuggester,
			Completer = function(value: string)
				if value == nil or value == "" then
					return nil
				end

				local lower = value:lower()
				local v4

				if isServer then
					v4 = collectServerIds()
				else
					v4 = collectClientIds()
				end

				if #v4 == 0 then
					v4 = { "Common Chest" }
				end

				for _, v7 in v4, true, nil do
					if v7:lower() == lower then
						return v7
					end
				end

				return value
			end
		}
	},
	Server = function(_, player, p: string)
		ensureServerDeps()

		if v3 == nil then
			error("ChestService unavailable on server")
		end

		if not player or not p or p == "" then
			error("Player and chest id are required")
		end

		local character = player.Character
		local position, pivot

		if character ~= nil then
			pivot = character:GetPivot()
			position = pivot.Position
		end

		if not (position and pivot) then
			error("Player has no valid character position")
		end

		local position2 = (pivot * CFrame.new(0, 0, -5)).Position

		if v3.GetChestConfig and not v3.GetChestConfig(p) then
			error((`Chest config '{p}' not found`))
		end

		local v4 = v3.Spawn(p, position2, {
			snapToGround = true,
			despawnAfter = 60,
			distributionMode = "FreeLoot",
			maxWinners = nil,
			range = nil,
			holdDuration = nil,
			promptText = nil,
			pivotOrientation = pivot
		})

		if not v4 then
			error("Chest failed to spawn")
		end

		return {
			Content = `Spawned chest '{p}' at {player.Name}'s position (guid: {v4})`,
			BgColor = Color3.fromRGB(32, 143, 70),
			FgColor = Color3.new(1, 1, 1)
		}
	end
}