local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local worlds = ReplicatedStorage.Config.Worlds
local progression = ReplicatedStorage.Config.Shared.Progression
local v = nil

local function addWorldBlocks(p, p2: number)
	local module = require(worlds["World" .. p2])
	local module2 = require(progression["WinBlocks_World" .. p2])
	local WIN_AMOUNTS = module2.WIN_AMOUNTS
	local WIN_BLOCK_FIRST = module.PROGRESSION.WIN_BLOCK_FIRST
	local WIN_BLOCK_LAST = module.PROGRESSION.WIN_BLOCK_LAST
	local v2 = p[module.GALAXY_INDEX] or {}
	p[module.GALAXY_INDEX] = v2
	local LEVEL = module.ENTRY.LEVEL
	table.insert(v2, {
		level = module.ENTRY.LEVEL,
		amount = WIN_AMOUNTS["WinBlock" .. WIN_BLOCK_FIRST]
	})

	for k, level in module.STAGE_RECOMMENDED_LEVELS do
		local v4 = WIN_BLOCK_FIRST - 1 + k

		if WIN_BLOCK_FIRST <= v4 and v4 <= WIN_BLOCK_LAST then
			table.insert(v2, {
				level = level,
				amount = WIN_AMOUNTS["WinBlock" .. v4]
			})
		end

		if LEVEL < level then
			LEVEL = level
		end
	end

	table.insert(v2, {
		level = LEVEL,
		amount = WIN_AMOUNTS["WinBlock" .. WIN_BLOCK_LAST]
	})
end

local function collectGalaxyBlocks()
	local v2 = {}

	for _, child in worlds:GetChildren() do
		local v3 = tonumber(child.Name:match("^World(%d+)$"))

		if v3 then
			addWorldBlocks(v2, v3)
		end
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getGalaxyBlocks()
	if v then
		return v
	end

	local v2 = collectGalaxyBlocks()
	v = v2
	return v2
end

local function reachableWinAmount(GALAXY_INDEX: number, p: number)
	local galaxyBlocks = getGalaxyBlocks() -- equivalent call inferred; original call site unknown
	local galaxyBlock = galaxyBlocks[GALAXY_INDEX]

	if not (galaxyBlock and #galaxyBlock > 0) then
		error(string.format("AAEventWinAward: no win blocks for galaxy %d", GALAXY_INDEX))
		return
	end

	local amount = 0

	for _, v2 in galaxyBlock do
		if v2.level <= p and amount < v2.amount then
			amount = v2.amount
		end
	end

	return amount
end

local function findModule(instance, childName: string)
	local moduleScript = instance:FindFirstChild(childName)

	if moduleScript and moduleScript:IsA("ModuleScript") then
		return moduleScript
	end

	return nil
end

local function checkCreateReady()
	if not RunService:IsServer() then
		return false, nil, "AAEventWinAward.create is server-only"
	end

	local dataManager = ServerScriptService:FindFirstChild("DataManager")

	if not (dataManager and dataManager:IsA("ModuleScript")) then
		dataManager = nil
	end

	local boostsManager = ServerScriptService:FindFirstChild("BoostsManager")

	if not (boostsManager and boostsManager:IsA("ModuleScript")) then
		boostsManager = nil
	end

	local bonusManager = ReplicatedStorage:FindFirstChild("BonusManager")

	if not (bonusManager and bonusManager:IsA("ModuleScript")) then
		bonusManager = nil
	end

	local config = ReplicatedStorage:FindFirstChild("Config")

	if not (config and config:IsA("ModuleScript")) then
		config = nil
	end

	if dataManager and boostsManager and bonusManager and config then
		return true, {
			dataManager = require(dataManager),
			boostsManager = require(boostsManager),
			bonusManager = require(bonusManager),
			worldConfig = require(config)
		}, ""
	else
		if not dataManager then
			return false, nil, "AAEventWinAward: ServerScriptService.DataManager was not found"
		end

		if not boostsManager then
			return false, nil, "AAEventWinAward: ServerScriptService.BoostsManager was not found"
		end

		if bonusManager then
			return false, nil, "AAEventWinAward: ReplicatedStorage.Config was not found"
		end

		return false, nil, "AAEventWinAward: ReplicatedStorage.BonusManager was not found"
	end
end

local function makeAward(p, data)
	local multiplier = p.multiplier or 1
	local dataManager = data.dataManager
	local boostsManager = data.boostsManager
	local bonusManager = data.bonusManager
	local GALAXY_INDEX = data.worldConfig.GALAXY_INDEX
	return function(player, value: number?)
		local v3 = reachableWinAmount(GALAXY_INDEX, dataManager.LevelCache[player.UserId] or 1)
		local v4 = boostsManager:HasWinsBoost(player) and 2 or 1
		local winsMultiplier = bonusManager:GetWinsMultiplier(player)
		local v5 = math.max(1, (math.floor(v3 * 0.05 * multiplier * (value or 1) * v4 * winsMultiplier)))
		dataManager:IncrementStat(player, "Wins", v5, {
			source = p.source
		})
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local showWin

		if remotes then
			showWin = remotes:FindFirstChild("ShowWin")
		end

		if showWin and showWin:IsA("RemoteEvent") then
			showWin:FireClient(player, v5)
		end
	end
end

return {
	create = function(p)
		local v2, v3, v4 = checkCreateReady()

		if not (v2 and v3) then
			error(v4)
			return
		end

		local multiplier = p.multiplier or 1
		local dataManager = v3.dataManager
		local boostsManager = v3.boostsManager
		local bonusManager = v3.bonusManager
		local GALAXY_INDEX = v3.worldConfig.GALAXY_INDEX
		return function(player, value: number?)
			local v6 = reachableWinAmount(GALAXY_INDEX, dataManager.LevelCache[player.UserId] or 1)
			local v7 = boostsManager:HasWinsBoost(player) and 2 or 1
			local winsMultiplier = bonusManager:GetWinsMultiplier(player)
			local v8 = math.max(1, (math.floor(v6 * 0.05 * multiplier * (value or 1) * v7 * winsMultiplier)))
			dataManager:IncrementStat(player, "Wins", v8, {
				source = p.source
			})
			local remotes = ReplicatedStorage:FindFirstChild("Remotes")
			local showWin

			if remotes then
				showWin = remotes:FindFirstChild("ShowWin")
			end

			if showWin and showWin:IsA("RemoteEvent") then
				showWin:FireClient(player, v8)
			end
		end
	end
}