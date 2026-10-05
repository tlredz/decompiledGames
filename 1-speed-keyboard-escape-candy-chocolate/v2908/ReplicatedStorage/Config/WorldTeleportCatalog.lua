local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaceRegistry = require(script.Parent:WaitForChild("PlaceRegistry"))
local WorldConfigsBuilder = require(script.Parent:WaitForChild("WorldConfigsBuilder"))
local v = {}
local v2 = {}

local function compareCatalogEntries(data, data2)
	if data.galaxyIndex ~= data2.galaxyIndex then
		return data.galaxyIndex < data2.galaxyIndex
	end

	if data.special ~= data2.special then
		return data2.special
	end

	if data.special or data.galaxyWorldIndex == data2.galaxyWorldIndex then
		return data.order < data2.order
	end

	return data.galaxyWorldIndex < data2.galaxyWorldIndex
end

local function buildCache()
	if #v > 0 then
		return
	end

	for _, v3 in ipairs(WorldConfigsBuilder.buildAll()) do
		local config = v3.config
		local DISPLAY = config.DISPLAY
		local v4 = {
			index = v3.key,
			galaxyIndex = config.GALAXY_INDEX,
			galaxyWorldIndex = config.GALAXY_WORLD_INDEX,
			galaxyName = config.GALAXY_NAME,
			name = DISPLAY.NAME,
			entryLevel = config.ENTRY.LEVEL,
			color = DISPLAY.COLOR,
			icon = DISPLAY.ICON,
			hasPlace = PlaceRegistry.getPlaceIdInCurrentGroup(v3.key) ~= nil,
			devOnly = DISPLAY.TELEPORT_DEV_ONLY == true,
			teleportEnabled = DISPLAY.TELEPORT_ENABLED ~= false,
			revealName = DISPLAY.REVEAL_NAME,
			special = PlaceRegistry.isSpecialPlaceKey(v3.key),
			order = #v + 1
		}
		v2[v3.key] = v4
		table.insert(v, v4)
	end

	table.sort(v, compareCatalogEntries)
end

local WorldTeleportCatalog = {}

function WorldTeleportCatalog.getEntryLevel(p)
	buildCache()
	return v2[p].entryLevel
end

function WorldTeleportCatalog.getGalaxyIndex(p)
	buildCache()
	return v2[p].galaxyIndex
end

function WorldTeleportCatalog.isDevOnly(p)
	buildCache()
	return v2[p].devOnly
end

function WorldTeleportCatalog.isTeleportEnabled(p)
	buildCache()
	return v2[p].teleportEnabled
end

function WorldTeleportCatalog.getEntries()
	buildCache()
	local Config = require(ReplicatedStorage:WaitForChild("Config"))
	local WORLD = Config.WORLD
	local galaxyIndex = nil
	local result = {}

	for _, v3 in ipairs(v) do
		if not v3.teleportEnabled then
			continue
		end

		if v3.galaxyIndex ~= galaxyIndex then
			table.insert(result, {
				kind = "header",
				text = v3.galaxyName
			})
			galaxyIndex = v3.galaxyIndex
		end

		table.insert(result, {
			kind = "world",
			index = v3.index,
			galaxyIndex = v3.galaxyIndex,
			galaxyWorldIndex = v3.galaxyWorldIndex,
			name = v3.name,
			entryLevel = v3.entryLevel,
			color = v3.color,
			icon = v3.icon,
			hasPlace = v3.hasPlace,
			devOnly = v3.devOnly,
			isCurrent = v3.index == WORLD,
			revealName = v3.revealName
		})
	end

	if #result > 0 then
		table.insert(result, {
			kind = "spacer"
		})
	end

	return result
end

return WorldTeleportCatalog