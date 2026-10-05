local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Modules.TreadmillMediaIdentity.Types.Interface)
local t = require(ReplicatedStorage.Packages.t)
require(ReplicatedStorage.Shared.TreadmillVideoController.Types.Interface)
local TreadmillMediaIdentity = {}

local function extractAssetId(value: string)
	local v = string.match(value, "%d+")
	local v2

	if v == nil then
		v2 = false
	else
		v2 = v ~= ""
	end

	assert(v2, (`Invalid treadmill media asset id "{value}"`))
	return v
end

function TreadmillMediaIdentity.GetMediaKey(data)
	t.strict(t.table)(data)

	if data.Kind == "Video" then
		local video = data.Video
		local v2 = string.match(video, "%d+")
		local v3

		if v2 == nil then
			v3 = false
		else
			v3 = v2 ~= ""
		end

		assert(v3, (`Invalid treadmill media asset id "{video}"`))
		return (`Video:{v2}`)
	else
		local image = data.Image
		local v2 = string.match(image, "%d+")
		local v3

		if v2 == nil then
			v3 = false
		else
			v3 = v2 ~= ""
		end

		assert(v3, (`Invalid treadmill media asset id "{image}"`))
		return (`Image:{v2}`)
	end
end

function TreadmillMediaIdentity.BuildMediaKeys(list)
	t.strict(t.table)(list)
	local result = {}
	local mediaKeys = {}

	for _, v in ipairs(list) do
		local mediaKey = TreadmillMediaIdentity.GetMediaKey(v)

		if result[mediaKey] then
			continue
		end

		result[mediaKey] = true
		table.insert(mediaKeys, mediaKey)
	end

	return mediaKeys, result
end

function TreadmillMediaIdentity.GetMediaKeyShardIndex(value, p: number)
	t.strict(t.string)(value)
	t.strict(t.intersection(t.integer, t.numberPositive))(p)
	local v = 0

	for i = 1, #value do
		v = (v * 33 + string.byte(value, i)) % p
	end

	return v
end

return TreadmillMediaIdentity