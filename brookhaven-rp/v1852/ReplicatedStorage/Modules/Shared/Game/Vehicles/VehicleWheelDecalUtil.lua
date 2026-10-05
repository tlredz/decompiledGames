local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WheelDecalsConfig = require(ReplicatedStorage.Modules.Shared.DB.Vehicles.WheelDecalsConfig)

-- equivalent calls inferred from this helper; original call sites unknown
local function getDecals()
	return WheelDecalsConfig.GetConfig()
end

local VehicleWheelDecalUtil = {}

function VehicleWheelDecalUtil.GetEntry(p: string)
	for _, v in WheelDecalsConfig.GetConfig() do
		if v.Image == p then
			return v
		end
	end

	return nil
end

function VehicleWheelDecalUtil.GetRandomDecal()
	local decals = getDecals() -- equivalent call inferred; original call site unknown
	return decals[math.random(1, #decals)].Image
end

function VehicleWheelDecalUtil.GetNextDecal(p: string, flag: boolean)
	local decals = getDecals() -- equivalent call inferred; original call site unknown
	local v = 0

	for k, decal in decals do
		if decal.Image ~= p then
			continue
		end

		v = k
		break
	end

	for i = 1, #decals do
		local decal = decals[(v + i - 1) % #decals + 1]

		if flag or decal.Gamepass == nil then
			return decal.Image
		end
	end

	return decals[1].Image
end

return VehicleWheelDecalUtil