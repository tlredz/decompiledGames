local v = { "Transparency" }
local v2 = {
	BasePart = v,
	Beam = v,
	Decal = v,
	GuiObject = {
		"BackgroundTransparency",
		"ImageTransparency",
		"TextStrokeTransparency",
		"TextTransparency"
	},
	ParticleEmitter = v,
	Trail = v,
	UIStroke = v
}
local v3 = {}

for k in v2 do
	table.insert(v3, k)
end

table.sort(v3)
local v4 = {}

local function channelsOf(instance)
	local v5 = v4[instance.ClassName]

	if v5 then
		return v5
	end

	local result = {}

	for _, className in v3 do
		if not instance:IsA(className) then
			continue
		end

		for _, v7 in v2[className] do
			local v8 = v7

			if not pcall(function()
				return instance[v8]
			end) then
				continue
			end

			table.insert(result, v7)
		end

		break
	end

	v4[instance.ClassName] = result
	return result
end

local function asOpacity(sequence)
	if typeof(sequence) ~= "NumberSequence" then
		return 1 - sequence
	end

	local result = {}

	for _, keypoint in sequence.Keypoints do
		table.insert(result, {
			at = keypoint.Time,
			opacity = 1 - keypoint.Value,
			spread = keypoint.Envelope
		})
	end

	return result
end

local function toward(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function transparencyOf(opacity, p: number, p2: number)
	if type(opacity) == "number" then
		return 1 - (opacity + (p - opacity) * p2)
	end

	local numberSequenceKeypoints = table.create(#opacity)

	for k, v5 in opacity do
		local opacity2 = v5.opacity
		local v6 = opacity2 + (p - opacity2) * p2
		local v7 = math.max(0, (math.min(v6, 1 - v6)))
		numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(v5.at, 1 - v6, (math.clamp(v5.spread, 0, v7)))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local class = {}
class.__index = class

local function looksOf(p, p2)
	local look = p.looks[p2]

	if look ~= nil then
		return look
	end

	look = {}

	for _, property in channelsOf(p2) do
		table.insert(look, {
			property = property,
			opacity = asOpacity(p2[property])
		})
	end

	p.looks[p2] = look
	return look
end

local function skipped(parent, folder, list)
	if list == nil then
		return false
	end

	while parent ~= nil do
		if table.find(list, parent.ClassName) ~= nil then
			return true
		end

		if parent == folder then
			break
		else
			parent = parent.Parent
		end
	end

	return false
end

local function subjectsUnder(folder, p)
	local result = {}

	if not skipped(folder, folder, p) then
		table.insert(result, folder)
	end

	for _, descendant in folder:GetDescendants() do
		if not skipped(descendant, folder, p) then
			table.insert(result, descendant)
		end
	end

	return result
end

function class.Blend(p, p2, p3: number, p4: number, p5)
	for _, v5 in subjectsUnder(p2, p5) do
		for _, v6 in looksOf(p, v5) do
			v5[v6.property] = transparencyOf(v6.opacity, p3, p4)
		end
	end
end

function class.Hide(p, p2, p3: number, p4)
	class.Blend(p, p2, 0, p3, p4)
end

return table.freeze({
	Fader = function()
		return (setmetatable({
			looks = setmetatable({}, {
				__mode = "k"
			})
		}, class))
	end
})