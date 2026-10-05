local CONSTANTS = require(game.ReplicatedStorage.Util.LevelCap.CONSTANTS)
local THEORETICAL_MAX = CONSTANTS.LEVEL_CAP.THEORETICAL_MAX
local object = setmetatable({}, {
	__mode = "k"
})
local RaceDamageLevel = {}

function RaceDamageLevel.isEqualizedEnemy(data)
	if data == nil then
		return false
	end

	local success, result = pcall(function()
		if data.getSession ~= nil or data.isBoat then
			return false
		end

		local data2 = data.Data

		if data2 ~= nil and data2.Equalized or data.Equalized then
			return true
		end

		local spawnData = data.SpawnData
		return spawnData ~= nil and spawnData.Equalized == true
	end)
	return success and result == true
end

function RaceDamageLevel.level(value: number?, data)
	if typeof(value) ~= "number" then
		return 1
	end

	local v

	if data == nil then
		v = false
	else
		local success, result = pcall(function()
			if data.getSession ~= nil or data.isBoat then
				return false
			end

			local data2 = data.Data

			if data2 ~= nil and data2.Equalized or data.Equalized then
				return true
			end

			local spawnData = data.SpawnData
			return spawnData ~= nil and spawnData.Equalized == true
		end)
		v = success and result == true
	end

	if v then
		return (math.clamp(value, 1, THEORETICAL_MAX))
	end

	return value
end

function RaceDamageLevel.cap(value: number, object2)
	if typeof(value) ~= "number" or value <= 0 then
		return value
	end

	local v

	if object2 == nil then
		v = false
	else
		local success, result = pcall(function()
			if object2.getSession ~= nil or object2.isBoat then
				return false
			end

			local data = object2.Data

			if data ~= nil and data.Equalized or object2.Equalized then
				return true
			end

			local spawnData = object2.SpawnData
			return spawnData ~= nil and spawnData.Equalized == true
		end)
		v = success and result == true
	end

	if not v then
		return value
	end

	local success, result = pcall(function()
		return object2.getHum and object2:getHum()
	end)

	if not (success and result) then
		return value
	end

	local maxHealth = result.MaxHealth

	if typeof(maxHealth) ~= "number" or maxHealth <= 0 then
		return value
	end

	local v2 = math.min(value, maxHealth * 0.08)
	local now = os.clock()
	local v3 = object[object2]

	if not v3 or v3.Until <= now then
		v3 = {
			Until = now + 1,
			Spent = 0
		}
		object[object2] = v3
	end

	local v4 = math.min(v2, (math.max(maxHealth * 0.1 - v3.Spent, 0)))
	v3.Spent += v4
	return v4
end

return RaceDamageLevel