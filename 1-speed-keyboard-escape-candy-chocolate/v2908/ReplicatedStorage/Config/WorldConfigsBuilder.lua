local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtils = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("TableUtils"))
local WorldConfigsBuilder = {}
local PlaceRegistry = require(script.Parent:WaitForChild("PlaceRegistry"))
local shared = script.Parent:WaitForChild("Shared")
local GameplayDefaults = require(shared:WaitForChild("GameplayDefaults"))
local Galaxies = require(script.Parent:WaitForChild("Galaxies"))
local progression = shared:WaitForChild("Progression")
local worlds = script.Parent:WaitForChild("Worlds")
local v = { "STEP_AWARDS", "WIN_AMOUNTS", "WIN_MIN_TIMES" }

-- equivalent calls inferred from this helper; original call sites unknown
local function getWorldGalaxyIndex(i: number)
	local module = require(worlds["World" .. i])
	return module.GALAXY_INDEX
end

local function mergeWinsProgression(p: number, INDEX: number)
	local result = {}

	for _, v2 in ipairs(v) do
		result[v2] = {}
	end

	for i = 1, p do
		if getWorldGalaxyIndex(i) ~= INDEX then
			continue
		end

		local module = require(progression["WinBlocks_World" .. i])

		for _, v2 in ipairs(v) do
			for k, v3 in pairs(module[v2]) do
				result[v2][k] = v3
			end
		end
	end

	return result
end

local function attachHelpers(copy, p)
	function copy.IsWorld(_, p2: number)
		return copy.WORLD == p2
	end

	function copy.GetXPRequired(p2: number)
		if p2 <= 0 then
			return 0
		end

		return (math.round(copy.BASE_XP * copy.XP_GROWTH ^ (p2 - 1)))
	end

	function copy.GetRebirthProductId(value: number?)
		local v2 = (value or 0) + 1

		if v2 <= 7 then
			return copy.DEV_PRODUCTS.INSTANT_REBIRTH_T1
		end

		if v2 <= 13 then
			return copy.DEV_PRODUCTS.INSTANT_REBIRTH_T2
		end

		if v2 <= 20 then
			return copy.DEV_PRODUCTS.INSTANT_REBIRTH_T3
		end

		return copy.DEV_PRODUCTS.INSTANT_REBIRTH_T4
	end

	local FLAT_BELOW_LEVEL = p.SPEED_FORMULA and p.SPEED_FORMULA.FLAT_BELOW_LEVEL

	function copy.CalculateMaxSpeed(p2: number)
		if FLAT_BELOW_LEVEL and p2 < FLAT_BELOW_LEVEL then
			return copy.DEFAULT_WALKSPEED
		end

		if FLAT_BELOW_LEVEL then
			p2 -= FLAT_BELOW_LEVEL
		end

		return (math.min(copy.DEFAULT_WALKSPEED + p2 * copy.SPEED_GAIN_PER_LEVEL, copy.MAX_LEVEL_SPEED_CAP))
	end

	function copy.GetEventDataKey()
		return copy.EVENT_DATA and copy.EVENT_DATA.Key or nil
	end

	function copy.GetWinsLabel(p2: number?)
		local winsLabel = copy.DISPLAY and copy.DISPLAY.WinsLabel

		if winsLabel then
			return winsLabel
		end

		if p2 == 1 then
			return "Win"
		end

		return "Wins"
	end

	function copy.GetSpeedLabel()
		return copy.DISPLAY and copy.DISPLAY.SpeedLabel or "Speed"
	end

	local function normalizeIcon(value)
		if type(value) == "number" then
			return "rbxassetid://" .. tostring(value)
		end

		if type(value) == "string" and value ~= "" then
			return value
		end

		return nil
	end

	function copy.GetWinsIcon()
		local winsIcon = copy.DISPLAY and copy.DISPLAY.WinsIcon

		if type(winsIcon) == "number" then
			return "rbxassetid://" .. tostring(winsIcon)
		end

		if type(winsIcon) == "string" and winsIcon ~= "" then
			return winsIcon
		end

		return nil
	end

	function copy.GetSpeedIcon()
		local speedIcon = copy.DISPLAY and copy.DISPLAY.SpeedIcon

		if type(speedIcon) == "number" then
			return "rbxassetid://" .. tostring(speedIcon)
		end

		if type(speedIcon) == "string" and speedIcon ~= "" then
			return speedIcon
		end

		return nil
	end

	function copy.GetAscensionXpMultiplier(items)
		local v2 = 1

		for _, item in pairs(items) do
			if item > 0 then
				v2 *= copy.ASCENSION_TIERS[item].xpMultiplier
			end
		end

		return v2
	end
end

local function buildFromWorld(copy, p: number)
	local v2 = Galaxies.get(copy.GALAXY_INDEX)
	local copy2 = TableUtils.Copy(GameplayDefaults, true)
	local v3 = mergeWinsProgression(p, v2.INDEX)

	for k, v4 in pairs(v3) do
		copy2[k] = v4
	end

	for k, v4 in pairs(copy) do
		copy2[k] = v4
	end

	copy2.GALAXY_INDEX = v2.INDEX
	copy2.GALAXY_WORLD_INDEX = copy.GALAXY_WORLD_INDEX
	copy2.GALAXY_NAME = v2.NAME
	copy2.GALAXY_SHORT_NAME = v2.SHORT_NAME
	copy2.GALAXY_XP_MULTIPLIER = v2.XP_MULTIPLIER
	attachHelpers(copy2, copy)
	return copy2
end

function WorldConfigsBuilder.build(p: number)
	local copy = TableUtils.Copy
	local module = require(worlds["World" .. p])
	return (buildFromWorld(copy(module, true), p))
end

function WorldConfigsBuilder.buildSpecial(p: string)
	local copy = TableUtils.Copy
	local module = require(worlds[p])
	local copy2 = copy(module, true)
	local BASED_ON_WORLD = copy2.BASED_ON_WORLD
	local copy3 = TableUtils.Copy
	local module2 = require(worlds["World" .. BASED_ON_WORLD])
	local copy4 = copy3(module2, true)

	for k, v2 in pairs(copy2) do
		copy4[k] = v2
	end

	return (buildFromWorld(copy4, BASED_ON_WORLD))
end

function WorldConfigsBuilder.buildForPlace(p: number?)
	local specialPlaceKey = PlaceRegistry.getSpecialPlaceKey(p)

	if specialPlaceKey then
		return WorldConfigsBuilder.buildSpecial(specialPlaceKey)
	end

	return WorldConfigsBuilder.build(PlaceRegistry.getWorldIndex(p))
end

function WorldConfigsBuilder.buildAll()
	local result = {}

	for i = 1, PlaceRegistry.getWorldCount() do
		table.insert(result, {
			key = i,
			config = WorldConfigsBuilder.build(i)
		})
	end

	for _, v2 in ipairs(PlaceRegistry.getSpecialPlaceKeys()) do
		table.insert(result, {
			key = v2,
			config = WorldConfigsBuilder.buildSpecial(v2)
		})
	end

	return result
end

return WorldConfigsBuilder