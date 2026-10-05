local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local VehiclePersistState = {}

function VehiclePersistState.ColorToHex(color: Color3?)
	if color == nil then
		return nil
	end

	return color:ToHex()
end

function VehiclePersistState.ColorFromHex(p: string?)
	if p == nil or p == "" then
		return nil
	end

	return Color3.fromHex(p)
end

function VehiclePersistState.ColorsToHex(items)
	if items == nil then
		return nil
	end

	local result = {}

	for k, item in items do
		if t.Color3(item) then
			result[k] = item:ToHex()
		end
	end

	return result
end

function VehiclePersistState.ColorsFromHex(items)
	if items == nil then
		return nil
	end

	local colors = {}

	for k, item in items do
		if t.string(item) and item ~= "" then
			colors[k] = Color3.fromHex(item)
		end
	end

	return colors
end

function VehiclePersistState.PartColorsToHex(items)
	if items == nil then
		return nil
	end

	local result = {}

	for k, item in items do
		if t.Color3(item) then
			result[k] = item:ToHex()
		end
	end

	return result
end

function VehiclePersistState.PartColorsFromHex(items)
	if items == nil then
		return nil
	end

	local colors = {}

	for k, item in items do
		if t.string(item) and item ~= "" then
			colors[k] = Color3.fromHex(item)
		end
	end

	return colors
end

function VehiclePersistState.SoundIdNumber(value: string?)
	if value == nil or value == "" then
		return ""
	end

	local v = string.match(value, "%d+")

	if v == nil then
		return ""
	end

	return v
end

return VehiclePersistState