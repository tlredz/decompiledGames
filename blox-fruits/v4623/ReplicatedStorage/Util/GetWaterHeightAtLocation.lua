local Realm = require(game.ReplicatedStorage.Util.Realm)
local Global = require(game.ReplicatedStorage.Global)
local Water = require(game.ReplicatedStorage.Modules.World.Water)
local WaterVolumes = require(script.WaterVolumes)
local Legacy = require(script.Legacy)

local function GET_VARIABLE_WATER_ENABLED()
	return script:GetAttribute("Enabled")
end

Global.GLOBAL_WATER_HEIGHT_BONUS = 0

local function lookup(position)
	if typeof(position) == "CFrame" then
		position = position.Position
	end

	local query = WaterVolumes.query(position)

	if query then
		return WaterVolumes.getSurfaceHeight(query, position), true, query.BodyName, query
	end

	local GLOBAL_WATER_HEIGHT_BONUS = Global.GLOBAL_WATER_HEIGHT_BONUS or 0
	local height, v = Legacy.getHeight(position.X, position.Y, position.Z)

	if height then
		return height + GLOBAL_WATER_HEIGHT_BONUS, true, v, nil
	end

	return Water.SEA_LEVEL + GLOBAL_WATER_HEIGHT_BONUS, false, nil, nil
end

local function getWaterHeightAtLocation(p)
	return lookup(p)
end

local function getWaterHeightAtLocationRaw(p)
	return (lookup(p))
end

if Realm.getIfCurrentRealmHasTagAsync("IsCelebrationEvent") then
	getWaterHeightAtLocation = function(...)
		local waterHeightAtLocation, v, v2, v3 = getWaterHeightAtLocation(...)

		if v2 then
			return waterHeightAtLocation, v, v2, v3
		end

		return -9999, true, "Celebration", nil
	end

	getWaterHeightAtLocationRaw = function()
		return -9999
	end
elseif workspace:GetAttribute("MAP") == "Dungeons" then
	getWaterHeightAtLocation = function(...)
		local waterHeightAtLocation, v, v2, v3 = getWaterHeightAtLocation(...)

		if v2 then
			return waterHeightAtLocation, v, v2, v3
		end

		return -9999, true, "Dungeon", nil
	end

	getWaterHeightAtLocationRaw = function()
		return -9999
	end
end

local object = setmetatable({
	getWaterHeightAtLocation = getWaterHeightAtLocation,
	isAboveWater = function(position)
		if typeof(position) == "CFrame" then
			position = position.Position
		end

		return position.Y >= getWaterHeightAtLocationRaw(position)
	end
}, {
	__call = function(_, ...)
		return getWaterHeightAtLocation(...)
	end
})
Global.getWaterHeightAtVector = getWaterHeightAtLocationRaw
Global.isVectorAboveWater = object.isAboveWater

function Global.isVectorBelowWater(p)
	return not object.isAboveWater(p)
end

return object