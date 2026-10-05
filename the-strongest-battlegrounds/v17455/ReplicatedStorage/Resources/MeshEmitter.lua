local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local class = {}
class.__index = class

-- equivalent calls inferred from this helper; original call sites unknown
local function trim(value: string)
	return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function splitNums(value: string)
	local result = {}

	for k in string.gmatch(value, "([^,]+)") do
		local v = tonumber((k:gsub("^%s+", ""):gsub("%s+$", "")))

		if v ~= nil then
			table.insert(result, v)
		end
	end

	return result
end

local function parseBoolean(p: string)
	return p == "true"
end

local function parseParams(value: string)
	local result = {}

	for k in string.gmatch(value, "([^,]+)") do
		local v = trim(k) -- equivalent call inferred; original call site unknown

		if not (#v > 0) then
			continue
		end

		local v2 = string.find(v, "=", 1, true)

		if not v2 then
			continue
		end

		local v3 = trim(string.sub(v, 1, v2 - 1)) -- equivalent call inferred; original call site unknown
		local v4 = trim(string.sub(v, v2 + 1)) -- equivalent call inferred; original call site unknown

		if #v4 >= 2 and (v4:sub(1, 1) == "\"" and v4:sub(-1) == "\"" or v4:sub(1, 1) == "'" and v4:sub(-1) == "'") then
			v4 = v4:sub(2, -2)
		end

		local v5 = tonumber(v4)

		if v5 == nil then
			if v4 == "true" or v4 == "false" then
				result[v3] = v4 == "true"
			else
				result[v3] = v4
			end
		else
			result[v3] = v5
		end
	end

	return result
end

local function parseExternalKeyPath(value: string)
	local result = {}
	local result2 = {}

	local function parseSeg(value2: string)
		local v = trim(value2) -- equivalent call inferred; original call site unknown
		local v2 = string.find(v, "<", 1, true)
		local v3

		if v2 then
			v3 = string.find(v, ">", v2 + 1, true) or nil
		end

		if not (v2 and v3 and v2 < v3) then
			return v, nil
		end

		local v4 = trim(string.sub(v, 1, v2 - 1)) -- equivalent call inferred; original call site unknown
		local v5 = trim(string.sub(v, v2 + 1, v3 - 1)) -- equivalent call inferred; original call site unknown

		if v5 == "" or not v5 then
			v5 = nil
		end

		return v4, v5
	end

	local v = tostring(value or "")

	if v ~= "" then
		local v2 = 1
		local v3 = {}

		while true do
			local v4 = string.find(v, " > ", v2, true)

			if not v4 then
				break
			end

			table.insert(v3, (string.sub(v, v2, v4 - 1)))
			v2 = v4 + 3
		end

		table.insert(v3, (string.sub(v, v2)))

		for _, v4 in ipairs(v3) do
			local v5, v6 = parseSeg(v4)
			table.insert(result, v5)
			table.insert(result2, v6 or "")
		end
	end

	local v2

	if #result > 0 then
		v2 = result[#result] or nil
	end

	local v3

	if #result2 > 0 and result2[#result2] ~= "" then
		v3 = result2[#result2]
	end

	return result, result2, v2, v3
end

local function resolveOrCreateUnder(parent, _externalPathNames, _externalPathTypes)
	if not parent or typeof(parent) ~= "Instance" or (type(_externalPathNames) ~= "table" or #_externalPathNames == 0) then
		return nil
	end

	local v = 1

	for i, v3 in ipairs(_externalPathNames) do
		if string.lower((tostring(v3))) ~= "lighting" then
			continue
		end

		v = i + 1
		break
	end

	local v3 = v == 1 and 1 or v

	if #_externalPathNames < v3 then
		return parent
	end

	for i = v3, #_externalPathNames do
		local name = tostring(_externalPathNames[i])
		local v5 = type(_externalPathTypes) ~= "table" and "" or tostring(_externalPathTypes[i] or "") or ""
		local v6 = v5 == "" and "" or v5
		local result = parent:FindFirstChild(name)

		if result and v6 ~= "" and result.ClassName ~= v6 then
			result = nil
		end

		if not result then
			if v6 == "" then
				return nil
			end

			local success
			success, result = pcall(function()
				return Instance.new(v6)
			end)

			if success and result then
				result.Name = name
				result.Parent = parent
			else
				return nil
			end
		end

		parent = result
	end

	return parent
end

local function toVector2(list)
	return Vector2.new(list[1], list[2])
end

local function toVector3(list)
	return (Vector3.new(list[1], list[2], list[3]))
end

local function toColor3(list)
	return Color3.new(list[1], list[2], list[3])
end

local function toUDim(list)
	return UDim.new(list[1], list[2])
end

local function toUDim2(list)
	return UDim2.new(list[1], list[2], list[3], list[4])
end

local function toCFrame(list)
	return CFrame.new(table.unpack(list, 1, 12))
end

local function toNumberRange(list)
	return NumberRange.new(list[1], list[2])
end

local function toNumberSequence(list)
	local numberSequenceKeypoints = {}

	for i = 1, #list, 2 do
		local v = list[i]
		local v2 = list[i + 1]

		if v ~= nil and v2 ~= nil then
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v, v2))
		end
	end

	local v = #numberSequenceKeypoints == 0 and { NumberSequenceKeypoint.new(0, 0) } or numberSequenceKeypoints
	return NumberSequence.new(v)
end

local function toColorSequence(list)
	local colorSequenceKeypoints = {}

	for i = 1, #list, 4 do
		local v = list[i]
		local v2 = list[i + 1]
		local v3 = list[i + 2]
		local v4 = list[i + 3]

		if v ~= nil and v2 ~= nil and v3 ~= nil and v4 ~= nil then
			table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v, Color3.new(v2, v3, v4)))
		end
	end

	local v = #colorSequenceKeypoints == 0 and { ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)) } or colorSequenceKeypoints
	return ColorSequence.new(v)
end

local function expectTypeFor(instance, p: string)
	if instance:IsA("Model") then
		if p == "Scale" then
			return "number"
		elseif p == "CFrame" then
			return "CFrame"
		end
	end

	if instance.ClassName == "Lighting" then
		if p == "Ambient" then
			return "Color3"
		elseif p == "OutdoorAmbient" then
			return "Color3"
		elseif p == "FogColor" then
			return "Color3"
		elseif p == "ColorShift_Top" then
			return "Color3"
		elseif p == "ColorShift_Bottom" then
			return "Color3"
		elseif p == "Brightness" then
			return "number"
		elseif p == "ClockTime" then
			return "number"
		elseif p == "FogStart" then
			return "number"
		elseif p == "FogEnd" then
			return "number"
		elseif p == "GeographicLatitude" then
			return "number"
		elseif p == "ExposureCompensation" then
			return "number"
		elseif p == "EnvironmentDiffuseScale" then
			return "number"
		elseif p == "EnvironmentSpecularScale" then
			return "number"
		elseif p == "ShadowSoftness" then
			return "number"
		elseif p == "GlobalShadows" then
			return "boolean"
		end
	end

	if instance:IsA("Atmosphere") then
		if p == "Color" then
			return "Color3"
		elseif p == "Decay" then
			return "Color3"
		end

		if p == "Density" or p == "Offset" or p == "Haze" or p == "Glare" then
			return "number"
		end
	end

	if instance:IsA("Light") then
		if p == "Brightness" then
			return "number"
		elseif p == "Enabled" then
			return "boolean"
		elseif p == "Range" then
			return "number"
		elseif p == "Shadows" then
			return "boolean"
		elseif p == "Color" then
			return "Color3"
		end
	end

	if instance:IsA("ParticleEmitter") then
		if p == "Color" then
			return "ColorSequence"
		elseif p == "Transparency" then
			return "NumberSequence"
		elseif p == "Size" then
			return "NumberSequence"
		elseif p == "Texture" then
			return "string"
		elseif p == "Enabled" then
			return "boolean"
		end
	end

	if instance:IsA("GuiObject") then
		if p == "Position" or p == "Size" then
			return "UDim2"
		end

		if p == "AnchorPoint" or p == "CanvasPosition" then
			return "Vector2"
		end

		if p == "Rotation" or (p == "BackgroundTransparency" or p == "ImageTransparency" or p == "TextTransparency") then
			return "number"
		end

		if p == "BackgroundColor3" or p == "ImageColor3" or p == "TextColor3" then
			return "Color3"
		end

		if p == "Visible" then
			return "boolean"
		end
	end

	if instance:IsA("BlurEffect") then
		if p == "Size" then
			return "number"
		elseif p == "Enabled" then
			return "boolean"
		end
	end

	if instance:IsA("BloomEffect") then
		if p == "Intensity" or p == "Size" or p == "Threshold" then
			return "number"
		end

		if p == "Enabled" then
			return "boolean"
		end
	end

	if instance:IsA("ColorCorrectionEffect") then
		if p == "Brightness" or p == "Contrast" or p == "Saturation" then
			return "number"
		end

		if p == "TintColor" then
			return "Color3"
		elseif p == "Enabled" then
			return "boolean"
		end
	end

	if instance:IsA("SunRaysEffect") then
		if p == "Intensity" or p == "Spread" then
			return "number"
		end

		if p == "Enabled" then
			return "boolean"
		end
	end

	if instance:IsA("DepthOfFieldEffect") then
		if p == "FarIntensity" or p == "NearIntensity" or p == "InFocusRadius" then
			return "number"
		end

		if p == "FocusDistance" then
			return "number"
		elseif p == "Enabled" then
			return "boolean"
		end
	end

	if p == "CFrame" then
		return "CFrame"
	end

	if instance:IsA("BasePart") then
		if p == "Position" or p == "Orientation" or p == "Size" then
			return "Vector3"
		end

		if p == "Color" then
			return "Color3"
		elseif p == "Transparency" then
			return "number"
		end
	end

	if instance:IsA("Attachment") and (p == "Position" or p == "Orientation") then
		return "Vector3"
	end

	if instance:IsA("Highlight") then
		if p == "FillColor" then
			return "Color3"
		elseif p == "OutlineColor" then
			return "Color3"
		elseif p == "FillTransparency" then
			return "number"
		elseif p == "OutlineTransparency" then
			return "number"
		elseif p == "Enabled" then
			return "boolean"
		elseif p == "Adornee" then
			return "string"
		elseif p == "DepthMode" then
			return "string"
		end
	end

	if p == "Color" then
		return "Color3"
	elseif p == "Transparency" then
		return "number"
	elseif p == "Enabled" then
		return "boolean"
	elseif p == "Texture" then
		return "string"
	elseif p == "NumberSequence" then
		return "NumberSequence"
	elseif p == "ColorSequence" then
		return "ColorSequence"
	end

	if p == "Range" or p == "NumberRange" then
		return "NumberRange"
	end

	return nil
end

local function deserialize(value: string, p: string?)
	if p == "boolean" then
		return value == "true"
	elseif p == "number" then
		return (tonumber(value))
	elseif p == "string" then
		return value
	end

	local v = splitNums(value)

	if p == "Vector3" then
		return (Vector3.new(v[1], v[2], v[3]))
	elseif p == "Vector2" then
		return toVector2(v)
	elseif p == "Color3" then
		return toColor3(v)
	elseif p == "UDim" then
		return toUDim(v)
	elseif p == "UDim2" then
		return toUDim2(v)
	elseif p == "CFrame" then
		return toCFrame(v)
	elseif p == "NumberRange" then
		return toNumberRange(v)
	elseif p == "NumberSequence" then
		return toNumberSequence(v)
	elseif p == "ColorSequence" then
		return toColorSequence(v)
	end

	if #v == 12 then
		return toCFrame(v)
	end

	if #v == 4 then
		return toUDim2(v)
	end

	if #v == 3 then
		return (Vector3.new(v[1], v[2], v[3]))
	end

	if #v == 2 then
		return toVector2(v)
	end

	if #v == 1 then
		return v[1]
	end

	local v2 = tonumber(value)

	if not v2 then
		if value == "true" or value == "false" then
			return value == "true" or value
		else
			return value
		end
	end

	return v2
end

local function typeofStr(instance)
	local typeName = typeof(instance)

	if typeName == "Instance" then
		return instance.ClassName
	end

	return typeName
end

local easingStyle = Enum.EasingStyle
local easingDirection = Enum.EasingDirection

local function easeInOut(callback)
	return function(p)
		if p < 0.5 then
			return 0.5 * callback(p * 2)
		end

		return 1 - 0.5 * callback((1 - p) * 2)
	end
end

local function makeBack(p: number)
	return function(p2)
		return p2 * p2 * ((p + 1) * p2 - p)
	end
end

local function makeElastic(p: number, p2: number)
	return function(p3)
		if p3 == 0 or p3 == 1 then
			return p3
		end

		return -2 ^ (10 * (p3 - 1)) * math.sin((p3 - 1 - p2) * 6.283185307179586 / p)
	end
end

local function bounceOut(p: number)
	if p < 0.36363636363636365 then
		return p * 7.5625 * p
	end

	if p < 0.7272727272727273 then
		local v = p - 0.5454545454545454
		return v * 7.5625 * v + 0.75
	end

	if p < 0.9090909090909091 then
		local v = p - 0.8181818181818182
		return v * 7.5625 * v + 0.9375
	end

	local v = p - 0.9545454545454546
	return v * 7.5625 * v + 0.984375
end

local function bounceIn(p: number)
	local v = 1 - p
	local v2

	if v < 0.36363636363636365 then
		v2 = v * 7.5625 * v
	elseif v < 0.7272727272727273 then
		local v3 = v - 0.5454545454545454
		v2 = v3 * 7.5625 * v3 + 0.75
	elseif v < 0.9090909090909091 then
		local v3 = v - 0.8181818181818182
		v2 = v3 * 7.5625 * v3 + 0.9375
	else
		local v3 = v - 0.9545454545454546
		v2 = v3 * 7.5625 * v3 + 0.984375
	end

	return 1 - v2
end

local v = {
	[easingStyle.Linear] = function(p)
		return p
	end,
	[easingStyle.Sine] = function(p)
		return 1 - math.cos(p * 3.141592653589793 / 2)
	end,
	[easingStyle.Quad] = function(p)
		return p * p
	end,
	[easingStyle.Cubic] = function(p)
		return p * p * p
	end,
	[easingStyle.Quart] = function(p)
		return p * p * p * p
	end,
	[easingStyle.Quint] = function(p)
		return p * p * p * p * p
	end,
	[easingStyle.Exponential] = function(p)
		if p == 0 then
			return 0
		end

		return 2 ^ (10 * p - 10)
	end,
	[easingStyle.Circular] = function(p)
		return 1 - math.sqrt(1 - p * p)
	end
}
local v2 = 1.70158

v[easingStyle.Back] = function(p)
	return p * p * ((v2 + 1) * p - v2)
end

v[easingStyle.Bounce] = bounceIn
local v3 = 0.075
local v4 = 0.3

v[easingStyle.Elastic] = function(p)
	if p == 0 or p == 1 then
		return p
	end

	return -2 ^ (10 * (p - 1)) * math.sin((p - 1 - v3) * 6.283185307179586 / v4)
end

local v5 = {
	Linear = easingStyle.Linear,
	Sine = easingStyle.Sine,
	Quad = easingStyle.Quad,
	Cubic = easingStyle.Cubic,
	Quart = easingStyle.Quart,
	Quint = easingStyle.Quint,
	Expo = easingStyle.Exponential,
	Exponential = easingStyle.Exponential,
	Circle = easingStyle.Circular,
	Circular = easingStyle.Circular,
	Back = easingStyle.Back,
	Bounce = easingStyle.Bounce,
	Elastic = easingStyle.Elastic
}
local v6 = {
	In = easingDirection.In,
	Out = easingDirection.Out,
	InOut = easingDirection.InOut
}

local function applyDirection(callback, p)
	if p == easingDirection.In then
		return callback
	end

	if p == easingDirection.Out then
		return function(p2)
			return 1 - callback(1 - p2)
		end
	end

	return function(p2)
		if p2 < 0.5 then
			return 0.5 * callback(p2 * 2)
		end

		return 1 - 0.5 * callback((1 - p2) * 2)
	end
end

local function easingFromNames(value: string?, value2: string?)
	if value == "None" then
		return function(p)
			if p >= 1 then
				return 1
			end

			return 0
		end
	end

	local v7 = v5[value or "Linear"] or easingStyle.Linear
	local v8 = v6[value2 or "In"] or easingDirection.In
	local selected = v[v7] or v[easingStyle.Linear]

	if v8 == easingDirection.In then
		return selected
	end

	if v8 == easingDirection.Out then
		return function(p)
			return 1 - selected(1 - p)
		end
	end

	return function(p)
		if p < 0.5 then
			return 0.5 * selected(p * 2)
		end

		return 1 - 0.5 * selected((1 - p) * 2)
	end
end

local v7 = {}

local function getCachedEasing(value: string?, value2: string?)
	local v8 = (value or "Linear") .. "|" .. (value2 or "In")
	local v9 = v7[v8]

	if v9 then
		return v9
	end

	local v10 = easingFromNames(value, value2)
	v7[v8] = v10
	return v10
end

local v8 = {
	number = function(p, p2, p3: number)
		return p + (p2 - p) * p3
	end,
	Vector2 = function(p, p2, p3: number)
		return p + (p2 - p) * p3
	end,
	Vector3 = function(p, p2, p3: number)
		return p:Lerp(p2, p3)
	end,
	Color3 = function(p, p2, p3: number)
		return p:Lerp(p2, p3)
	end,
	UDim = function(p, p2, p3: number)
		return UDim.new(p.Scale + (p2.Scale - p.Scale) * p3, (math.floor(p.Offset + (p2.Offset - p.Offset) * p3)))
	end,
	UDim2 = function(p, p2, p3: number)
		return UDim2.new(
			p.X.Scale + (p2.X.Scale - p.X.Scale) * p3,
			math.floor(p.X.Offset + (p2.X.Offset - p.X.Offset) * p3),
			p.Y.Scale + (p2.Y.Scale - p.Y.Scale) * p3,
			(math.floor(p.Y.Offset + (p2.Y.Offset - p.Y.Offset) * p3))
		)
	end,
	CFrame = function(p, p2, p3: number)
		return p:Lerp(p2, p3)
	end
}

local function buildInstanceTrack(descendant)
	local meshEmitter = descendant:GetAttribute("MeshEmitter")

	if not meshEmitter then
		return nil
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(meshEmitter)
	end)

	if not success or type(result) ~= "table" then
		return nil
	end

	local tracks = {}

	for k, keys in pairs(result) do
		if not (type(keys) == "table" and #keys > 0) then
			continue
		end

		table.sort(keys, function(a, b)
			return (a.Time or 0) < (b.Time or 0)
		end)
		tracks[k] = {
			property = k,
			keys = keys
		}
	end

	return {
		instance = descendant,
		groupType = descendant:GetAttribute("GroupType"),
		tracks = tracks,
		_cache = {},
		_firedEmitIdx = {},
		_swapOrig = nil,
		_isExternal = false
	}
end

local function collectTracks(folder)
	local result = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if not descendant:GetAttribute("MeshEmitter") then
			continue
		end

		local instanceTrack = buildInstanceTrack(descendant)

		if instanceTrack then
			table.insert(result, instanceTrack)
		end
	end

	local meshEmitterExternalTracks = folder:GetAttribute("MeshEmitterExternalTracks") or folder:GetAttribute("MeshEmitterExternal")

	if meshEmitterExternalTracks then
		local success, result2 = pcall(function()
			return HttpService:JSONDecode(meshEmitterExternalTracks)
		end)

		if success and type(result2) == "table" then
			for k, v9 in pairs(result2) do
				if type(k) == "string" and type(v9) == "table" and #v9 > 0 and (k == "Lighting" or k == "Workspace" or k == "CoreGui" or k == "Camera") then
					for _, v10 in ipairs(v9) do
						if type(v10) ~= "table" then
							continue
						end

						local tracks = v10.Tracks
						local instanceNames = v10.InstanceNames
						local instanceTypes = v10.InstanceTypes

						if not (type(tracks) == "table" and type(instanceNames) == "table") then
							continue
						end

						local tracks2 = {}

						for k2, track in pairs(tracks) do
							if not (type(track) == "table" and #track > 0) then
								continue
							end

							table.sort(track, function(a, b)
								return (a.Time or 0) < (b.Time or 0)
							end)
							tracks2[k2] = {
								property = k2,
								keys = track
							}
						end

						if next(tracks2) == nil then
							continue
						end

						local externalPathNames = {}
						local externalPathTypes = {}
						local v14 = nil
						local externalClass = nil

						for i = 1, #instanceNames do
							table.insert(externalPathNames, (tostring(instanceNames[i])))
							table.insert(
								externalPathTypes,
								type(instanceTypes) ~= "table" and "" or tostring(instanceTypes[i] or "")
							)
						end

						if #externalPathNames > 0 then
							v14 = externalPathNames[#externalPathNames]
						end

						if #externalPathTypes > 0 and externalPathTypes[#externalPathTypes] ~= "" then
							externalClass = externalPathTypes[#externalPathTypes]
						end

						local formatted = ("GROUP:%s:%s"):format(k, table.concat(externalPathNames, " > "))
						table.insert(result, {
							instance = nil,
							groupType = k,
							tracks = tracks2,
							_cache = {},
							_firedEmitIdx = {},
							_swapOrig = nil,
							_externalId = formatted,
							_externalName = v14 or formatted,
							_externalClass = externalClass,
							_isExternal = true,
							_externalPathNames = externalPathNames,
							_externalPathTypes = externalPathTypes
						})
					end
				elseif type(k) == "string" and type(v9) == "table" then
					local tracks = {}

					for k2, keys in pairs(v9) do
						if not (type(keys) == "table" and #keys > 0) then
							continue
						end

						table.sort(keys, function(a, b)
							return (a.Time or 0) < (b.Time or 0)
						end)
						tracks[k2] = {
							property = k2,
							keys = keys
						}
					end

					if next(tracks) ~= nil then
						local externalPathNames, externalPathTypes, v13, externalClass = parseExternalKeyPath(k)
						table.insert(result, {
							instance = nil,
							groupType = "External",
							tracks = tracks,
							_cache = {},
							_firedEmitIdx = {},
							_swapOrig = nil,
							_externalId = k,
							_externalName = v13 or k,
							_externalClass = externalClass,
							_isExternal = true,
							_externalPathNames = externalPathNames,
							_externalPathTypes = externalPathTypes
						})
					end
				end
			end
		end
	end

	for _, v9 in ipairs(result) do
		local tracks = {}

		for k, track in pairs(v9.tracks) do
			if v9._cache[k] == nil then
				v9._cache[k] = {}
			end

			track._cache = v9._cache[k]

			if k == "Emit" then
				v9._emitTrack = track
			else
				table.insert(tracks, track)
			end
		end

		v9.trackList = tracks
	end

	return result
end

local function findSegment(keys, p: number)
	local count = #keys

	if count == 0 then
		return
	end

	if p <= keys[1].Time then
		return 1, 1, keys[1], keys[1], 0
	end

	if keys[count].Time <= p then
		return count, count, keys[count], keys[count], 1
	end

	local v9 = count - 1
	local v10 = 1

	while v10 < v9 do
		local v11 = v10 + math.floor((v9 - v10 + 1) / 2)

		if keys[v11].Time <= p then
			v10 = v11
		else
			v9 = v11 - 1
		end
	end

	local v11 = keys[v10]
	local v12 = keys[v10 + 1]
	local v13 = math.max(1e-6, v12.Time - v11.Time)
	local v14 = (p - v11.Time) / v13
	return v10, v10 + 1, v11, v12, v14
end

local function getCachedValue(p, p2: number, p3, p4: string?, p5, p6: string)
	if p[p2] ~= nil then
		return p[p2]
	end

	local v9 = p4 or expectTypeFor(p5, p6)
	local v10 = deserialize(p3.Value, v9)
	p[p2] = v10
	return v10
end

local function processEmitBursts(_track, p: number, p2: number)
	local instance = _track.instance

	if not instance then
		return
	end

	local _emitTrack = _track._emitTrack

	if not (_emitTrack and instance:IsA("ParticleEmitter")) then
		return
	end

	local keys = _emitTrack.keys

	for i = math.max(1, (_track._firedEmitIdx.Emit or 0) + 1), #keys do
		local key = keys[i]

		if key.Time and key.Time <= p and p2 < key.Time then
			local v9 = tonumber(deserialize(key.Value, "number")) or 0

			if v9 > 0 then
				instance:Emit(v9)
			end

			_track._firedEmitIdx.Emit = i
		elseif key.Time and p < key.Time then
			break
		end
	end
end

local function scaleCFrameOffset(cframe: CFrame, p: number)
	if p == 1 then
		return cframe
	end

	local v9 = cframe.Position * p
	return CFrame.fromMatrix(v9, cframe.XVector, cframe.YVector, cframe.ZVector)
end

local function scaleNumberSequence(sequence, p: number)
	if p == 1 then
		return sequence
	end

	local keypoints = sequence.Keypoints
	local numberSequenceKeypoints = table.create(#keypoints)

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function scaleNumberSequenceStatic(p, p2: number)
	return scaleNumberSequence(p, p2)
end

local function isEffect(instance)
	return instance:IsA("ColorCorrectionEffect") or instance:IsA("BloomEffect") or instance:IsA("BlurEffect") or instance:IsA("DepthOfFieldEffect") or instance:IsA("SunRaysEffect")
end

local function getScreenGuiRoot(parent)
	while parent and parent ~= game and parent.Parent do
		if parent:IsA("ScreenGui") then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

local function buildPath(screenGuiRoot, parent)
	local result = {}

	while parent and parent ~= screenGuiRoot do
		table.insert(result, 1, parent.Name)
		parent = parent.Parent
	end

	return result
end

local function followPath(child, path)
	for _, childName in ipairs(path) do
		child = child:FindFirstChild(childName)

		if not child then
			return nil
		end
	end

	return child
end

function class.new(model)
	assert(model and model:IsA("Model"), "MeshEmitterPlayer.new expects a Model")
	local object = setmetatable({}, class)
	object.Model = model
	object.Primary = model.PrimaryPart
	object.AnchorCFrame = object.Primary and object.Primary.CFrame or CFrame.new()
	object.FPS = 60
	object.Speed = 1
	object.Scale = 1
	object._tracks = collectTracks(model)
	object._running = false
	object._paused = false
	object._t = 0
	object._lastT = 0
	object._len = 0
	object._conn = nil
	object._onCompleted = {}
	object._onEvent = {}
	object._named = {}
	object._events = {}
	object._eventIdx = 0
	object._Offsets = {}
	object._offsetsByName = {}
	object._userEvents = {}
	object._userEvtIdx = 0
	object._tracksByInstance = {}
	object._externalById = {}
	object._externalByName = {}

	for _, _track in ipairs(object._tracks) do
		if _track._isExternal then
			local _externalId = _track._externalId or ""

			if _externalId ~= "" then
				object._externalById[_externalId] = _track
			end

			local _externalName = _track._externalName

			if _externalName and _externalName ~= "" then
				object._externalByName[_externalName] = object._externalByName[_externalName] or {}
				table.insert(object._externalByName[_externalName], _track)
			end
		elseif _track.instance then
			object._tracksByInstance[_track.instance] = _track
		end
	end

	object._origPartSize = {}
	object._origMeshScale = {}
	object._origParticleSize = {}

	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			object._origPartSize[descendant] = descendant.Size

			for _, specialMesh in ipairs(descendant:GetChildren()) do
				if specialMesh:IsA("SpecialMesh") then
					object._origMeshScale[specialMesh] = specialMesh.Scale
				end
			end
		elseif descendant:IsA("ParticleEmitter") then
			object._origParticleSize[descendant] = descendant.Size
		end
	end

	object._lastAppliedStaticScale = 1

	for _, _track in ipairs(object._tracks) do
		for _, track in pairs(_track.tracks) do
			local key = track.keys[#track.keys]

			if key and key.Time and key.Time > object._len then
				object._len = key.Time
			end
		end
	end

	local meshEmitterEvents = model:GetAttribute("MeshEmitterEvents")

	if meshEmitterEvents then
		local success, result = pcall(function()
			return HttpService:JSONDecode(meshEmitterEvents)
		end)

		if success and type(result) == "table" then
			table.sort(result, function(a, b)
				return (a.Time or 0) < (b.Time or 0)
			end)
			object._events = result
		end
	end

	object._spawnedVisuals = false
	object._liveEffects = {}
	object._liveGuis = {}
	object._uiRoots = {}
	return object
end

function class:AssignExternal(value: string, instance)
	local v9 = tostring(value or "")

	if v9 == "" then
		return self
	end

	if string.lower(v9) == "lighting" then
		local v10 = {
			Ambient = true,
			OutdoorAmbient = true,
			FogColor = true,
			ColorShift_Top = true,
			ColorShift_Bottom = true,
			Brightness = true,
			ClockTime = true,
			FogStart = true,
			FogEnd = true,
			GeographicLatitude = true,
			ExposureCompensation = true,
			EnvironmentDiffuseScale = true,
			EnvironmentSpecularScale = true,
			ShadowSoftness = true,
			GlobalShadows = true
		}

		local function isLightingExternal(_track)
			if _track.groupType and string.lower((tostring(_track.groupType))) == "lighting" then
				return true
			end

			if _track._externalId and string.find(string.lower((tostring(_track._externalId))), "lighting", 1, true) then
				return true
			end

			if _track._externalPathNames then
				for _, _externalPathName in ipairs(_track._externalPathNames) do
					if string.lower((tostring(_externalPathName))) == "lighting" then
						return true
					end
				end
			end

			return false
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function wantsLightingService(_track)
			for k, _ in pairs(_track.tracks) do
				if v10[k] then
					return true
				end
			end

			return false
		end

		for _, _track in ipairs(self._tracks) do
			if not (_track._isExternal and isLightingExternal(_track)) then
				continue
			end

			local v11 = wantsLightingService(_track) -- equivalent call inferred; original call site unknown
			local instance2

			if v11 then
				instance2 = instance
			else
				instance2 = resolveOrCreateUnder(instance, _track._externalPathNames, _track._externalPathTypes)
			end

			if not instance2 then
				continue
			end

			_track.instance = instance2
			self._tracksByInstance[instance2] = _track
		end

		self:_evalAndApplyAt(self._t, self._t)
		return self
	else
		local v10 = self._externalById[v9]

		if not v10 then
			local v11 = self._externalByName[v9]

			if v11 and #v11 > 0 then
				v10 = v11[1]
			end
		end

		if not v10 then
			warn(("[MeshEmitterPlayer] AssignExternal: no external track found for key '%s'"):format(v9))
			return self
		end

		v10.instance = instance
		self._tracksByInstance[instance] = v10
		return self
	end
end

function class:AssignExternalByName(p: string, p2)
	return self:AssignExternal(p, p2)
end

function class:AssignAllExternalByClass(p2: string, callback)
	for _, _track in ipairs(self._tracks) do
		if not (_track._isExternal and _track._externalClass == p2) then
			continue
		end

		local v10 = {
			Id = _track._externalId or "",
			Name = _track._externalName,
			ClassName = _track._externalClass,
			GroupType = _track.groupType,
			Tracks = {}
		}
		local success, result = pcall(function()
			return callback(v10)
		end)

		if not (success and result and typeof(result) == "Instance") then
			continue
		end

		_track.instance = result
		self._tracksByInstance[result] = _track
	end

	return self
end

function class:SetAnchor(anchorCFrame: CFrame)
	self.AnchorCFrame = anchorCFrame
	return self
end

function class:SetSpeed(value: number)
	self.Speed = math.max(0, value or 1)
	return self
end

function class:SetScale(value: number)
	self.Scale = math.max(0, value or 1)
	self:_applyStaticScaleIfNeeded(true)
	return self
end

function class.GetScale(p)
	return p.Scale
end

function class:OnCompleted(callback)
	table.insert(self._onCompleted, callback)
	return self
end

function class:OnEvent(callback)
	table.insert(self._onEvent, callback)
	return self
end

function class:Bind(p2: string, callback)
	self._named[p2] = self._named[p2] or {}
	table.insert(self._named[p2], callback)
	return self
end

function class:AddTimeEvent(callback, p: number)
	local v9 = {
		Time = math.max(0, p),
		Callback = callback
	}
	local v10 = false

	for i = 1, #self._userEvents do
		if not (v9.Time < self._userEvents[i].Time) then
			continue
		end

		table.insert(self._userEvents, i, v9)
		v10 = true
		break
	end

	if not v10 then
		table.insert(self._userEvents, v9)
	end

	if v9.Time <= self._t then
		self._userEvtIdx += 1
	end

	return self
end

function class:AddFrameEvent(callback, value: number)
	return self:AddTimeEvent(callback, (value or 0) / (not (self.FPS > 0) and 60 or self.FPS or 60))
end

function class:AddOffset(p)
	table.insert(self._Offsets, p)
	self:_rebuildOffsetIndex()
end

function class:_rebuildOffsetIndex()
	local anchorsByPart = {}

	for _, _Offset in pairs(self._Offsets) do
		if not (_Offset.Parts and _Offset.Anchor) then
			continue
		end

		for _, part in pairs(_Offset.Parts) do
			anchorsByPart[part] = _Offset.Anchor
		end
	end

	self._offsetsByName = anchorsByPart
end

function class:AddFrameNamedEvent(p: string, value: number, p2: string?)
	local v9 = {
		Time = (value or 0) / (not (self.FPS > 0) and 60 or self.FPS or 60),
		String = p .. (p2 and ": " .. p2 or ""),
		Kind = "User"
	}
	local v10 = false

	for i = 1, #self._events do
		if not (v9.Time < self._events[i].Time) then
			continue
		end

		table.insert(self._events, i, v9)
		v10 = true
		break
	end

	if not v10 then
		table.insert(self._events, v9)
	end

	if v9.Time <= self._t then
		self._eventIdx += 1
	end

	return self
end

function class:_fireEvent(data)
	for _, callback in ipairs(self._onEvent) do
		task.spawn(callback, data, self)
	end

	local string2 = tostring(data.String or "")
	local v9 = string.find(string2, ":", 1, true)
	local name

	if v9 and v9 > 1 then
		name = string.sub(string2, 1, v9 - 1):gsub("^%s+", ""):gsub("%s+$", "")
		string2 = string.sub(string2, v9 + 1):gsub("^%s+", ""):gsub("%s+$", "")
	end

	if name and self._named[name] then
		local v11 = {
			Time = data.Time,
			Name = name,
			Payload = string2,
			Params = parseParams(string2 or ""),
			Kind = data.Kind,
			String = data.String
		}

		for _, callback in ipairs(self._named[name]) do
			task.spawn(callback, v11, self)
		end
	end
end

function class:_applyStaticScaleIfNeeded(flag: boolean?)
	if not flag and self._lastAppliedStaticScale == self.Scale then
		return
	end

	local scale = self.Scale

	local function hasTrack(p, p2: string)
		local v9 = self._tracksByInstance[p]
		return v9 ~= nil and v9.tracks[p2] ~= nil and #v9.tracks[p2].keys > 0
	end

	for k, v9 in pairs(self._origPartSize) do
		if k.Parent then
			local v10 = self._tracksByInstance[k]
			local v11

			if v10 == nil or v10.tracks.Size == nil then
				v11 = false
			else
				v11 = #v10.tracks.Size.keys > 0
			end

			if not v11 then
				k.Size = v9 * scale
			end
		end

		for _, specialMesh in ipairs(k:GetChildren()) do
			if not specialMesh:IsA("SpecialMesh") then
				continue
			end

			local v10 = self._origMeshScale[specialMesh]

			if not (v10 and specialMesh.Parent) then
				continue
			end

			local v11 = self._tracksByInstance[specialMesh]
			local v12

			if v11 == nil or v11.tracks.Scale == nil then
				v12 = false
			else
				v12 = #v11.tracks.Scale.keys > 0
			end

			if not v12 then
				specialMesh.Scale = v10 * scale
			end
		end
	end

	for k, v9 in pairs(self._origParticleSize) do
		if not k.Parent then
			continue
		end

		local v10 = self._tracksByInstance[k]
		local v11

		if v10 == nil or v10.tracks.Size == nil then
			v11 = false
		else
			v11 = #v10.tracks.Size.keys > 0
		end

		if not v11 then
			k.Size = scaleNumberSequence(v9, scale)
		end
	end

	self._lastAppliedStaticScale = scale
end

local v9 = {
	BasePart_CFrame = function(p, _, cframe, p2, p3)
		if p3 ~= 1 then
			local v10 = cframe.Position * p3
			cframe = CFrame.fromMatrix(v10, cframe.XVector, cframe.YVector, cframe.ZVector)
		end

		p.CFrame = p2 * cframe
	end,
	Attachment_CFrame = function(p, _, cframe, p2, p3)
		if p3 ~= 1 then
			local v10 = cframe.Position * p3
			cframe = CFrame.fromMatrix(v10, cframe.XVector, cframe.YVector, cframe.ZVector)
		end

		p.WorldCFrame = p2 * cframe
	end,
	Model_CFrame = function(instance, _, cframe, p, p2)
		if p2 ~= 1 then
			local v10 = cframe.Position * p2
			cframe = CFrame.fromMatrix(v10, cframe.XVector, cframe.YVector, cframe.ZVector)
		end

		instance:PivotTo(p * cframe)
	end,
	BasePart_Size = function(p, _, p2, _, p3)
		p.Size = p2 * p3
	end,
	Attachment_Position = function(p, p2, p3, _, p4)
		p[p2] = p3 * p4
	end,
	ParticleEmitter_Size = function(p, _, p2, _, p3)
		p.Size = scaleNumberSequence(p2, p3)
	end,
	Model_Scale = function(instance, _, max, _, _)
		local v10 = nil

		if typeof(max) ~= "number" then
			if typeof(max) == "NumberRange" then
				max = max.Max
			elseif typeof(max) == "Vector2" then
				max = max.Y
			elseif typeof(max) == "Vector3" then
				max = max.X
			else
				max = tonumber((tostring(max))) or v10
			end
		end

		if max ~= nil then
			instance:ScaleTo(max)
		end
	end,
	Model_Transparency = function(folder, _, transparency, _, _)
		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BasePart") or descendant:IsA("Decal") then
				descendant.Transparency = transparency
			end
		end
	end,
	Generic = function(p, p2, p3, _, _)
		pcall(function()
			p[p2] = p3
		end)
	end
}

local function classifyApply(instance, property: string, p)
	if property == "CFrame" and typeof(p) == "CFrame" then
		if instance:IsA("BasePart") then
			return v9.BasePart_CFrame
		end

		if instance:IsA("Attachment") then
			return v9.Attachment_CFrame
		end

		if instance:IsA("Model") then
			return v9.Model_CFrame
		end
	end

	if typeof(p) == "Vector3" then
		if property == "Size" and instance:IsA("BasePart") then
			return v9.BasePart_Size
		end

		if property == "Position" and instance:IsA("Attachment") then
			return v9.Attachment_Position
		end
	end

	if instance:IsA("ParticleEmitter") and property == "Size" and typeof(p) == "NumberSequence" then
		return v9.ParticleEmitter_Size
	end

	if not instance:IsA("Model") then
		return v9.Generic
	end

	if property == "Scale" then
		return v9.Model_Scale
	elseif property == "Transparency" then
		return v9.Model_Transparency
	end

	return v9.Generic
end

function class:_spawnRuntimeVisualsIfNeeded()
	if self._spawnedVisuals then
		return
	end

	self._spawnedVisuals = true

	for _, _track in ipairs(self._tracks) do
		local instance = _track.instance

		if not (instance and isEffect(instance)) then
			continue
		end

		local instance2 = instance
		local success, result = pcall(function()
			return instance2:Clone()
		end)

		if not (success and result) then
			continue
		end

		local currentCamera

		if instance.Parent and instance.Parent:IsA("Camera") and RunService:IsClient() then
			currentCamera = workspace.CurrentCamera
		end

		if currentCamera then
			result.Parent = currentCamera
		else
			result.Parent = Lighting
		end

		self._tracksByInstance[_track.instance] = nil
		_track._swapOrig = _track.instance
		_track.instance = result
		self._tracksByInstance[_track.instance] = _track
		table.insert(self._liveEffects, result)
	end

	if RunService:IsClient() then
		local v10 = {}

		for _, _track in ipairs(self._tracks) do
			local instance = _track.instance

			if not (instance and instance.Parent and instance:IsA("GuiObject")) then
				continue
			end

			local screenGuiRoot = getScreenGuiRoot(instance)

			if not screenGuiRoot or not screenGuiRoot:IsDescendantOf(self.Model) or v10[screenGuiRoot] then
				continue
			end

			v10[screenGuiRoot] = true
			local localPlayer = Players.LocalPlayer
			local playerGui

			if localPlayer then
				playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			end

			if not playerGui then
				local success, result = pcall(function()
					return game:GetService("CoreGui")
				end)

				if success then
					playerGui = result
				end
			end

			if not playerGui then
				continue
			end

			local v11 = screenGuiRoot
			local success, result = pcall(function()
				return v11:Clone()
			end)

			if not (success and result) then
				continue
			end

			result.ResetOnSpawn = false
			result.Parent = playerGui
			table.insert(self._liveGuis, result)
			table.insert(self._uiRoots, screenGuiRoot)

			for _, _track2 in ipairs(self._tracks) do
				local instance2 = _track2.instance

				if not (instance2 and instance2:IsDescendantOf(screenGuiRoot)) then
					continue
				end

				local instance3 = followPath(result, buildPath(screenGuiRoot, instance2))

				if not instance3 then
					continue
				end

				self._tracksByInstance[_track2.instance] = nil
				_track2._swapOrig = _track2.instance
				_track2.instance = instance3
				self._tracksByInstance[instance3] = _track2
			end
		end
	end
end

function class:_cleanupRuntimeVisuals()
	for _, _track in ipairs(self._tracks) do
		if not _track._swapOrig then
			continue
		end

		if _track.instance then
			self._tracksByInstance[_track.instance] = nil
		end

		_track.instance = _track._swapOrig
		self._tracksByInstance[_track.instance] = _track
		_track._swapOrig = nil
	end

	for _, _liveEffect in ipairs(self._liveEffects) do
		if _liveEffect and _liveEffect.Parent then
			_liveEffect:Destroy()
		end
	end

	self._liveEffects = {}

	for _, v10 in ipairs(self._liveGuis) do
		if v10 and v10.Parent then
			v10:Destroy()
		end
	end

	self._liveGuis = {}
	self._uiRoots = {}
	self._spawnedVisuals = false
end

function class:_processEmbeddedEvents(p: number, p2: number)
	local _events = self._events

	if #_events == 0 then
		return
	end

	local eventIdx = self._eventIdx + 1

	while eventIdx <= #_events do
		local _event = _events[eventIdx]
		local time = tonumber(_event.Time) or 0

		if time <= p and p2 < time then
			self:_fireEvent(_event)
			self._eventIdx = eventIdx
		else
			if p < time then
				break
			end

			if self._eventIdx < eventIdx then
				self._eventIdx = eventIdx
			end
		end

		eventIdx += 1
	end
end

function class:_processUserEvents(p: number, p2: number)
	if #self._userEvents == 0 then
		return
	end

	local userEvtIdx = self._userEvtIdx + 1

	while userEvtIdx <= #self._userEvents do
		local _userEvent = self._userEvents[userEvtIdx]

		if _userEvent.Time <= p and p2 < _userEvent.Time then
			if typeof(_userEvent.Callback) == "function" then
				task.spawn(_userEvent.Callback, self)
			end

			self._userEvtIdx = userEvtIdx
		else
			if p < _userEvent.Time then
				break
			end

			if self._userEvtIdx < userEvtIdx then
				self._userEvtIdx = userEvtIdx
			end
		end

		userEvtIdx += 1
	end
end

function class:_evalAndApplyAt(p: number, p2: number)
	self:_applyStaticScaleIfNeeded(false)
	self:_processEmbeddedEvents(p, p2)
	self:_processUserEvents(p, p2)
	local _offsetsByName = self._offsetsByName
	local anchorCFrame = self.AnchorCFrame
	local scale = self.Scale

	for _, _track in ipairs(self._tracks) do
		local instance = _track.instance

		if not (instance and instance.Parent) then
			continue
		end

		processEmitBursts(_track, p, p2)
		local v10 = _offsetsByName[instance.Name]
		local v11

		if v10 then
			v11 = anchorCFrame * v10 or anchorCFrame
		else
			v11 = anchorCFrame
		end

		local trackList = _track.trackList

		for _, v12 in ipairs(trackList) do
			local property = v12.property
			local segment, v13, v14, v15, v16 = findSegment(v12.keys, p)

			if not segment then
				continue
			end

			local _easing = v14._easing

			if not _easing then
				local style = v14.Style
				local direction = v14.Direction
				local v17 = (style or "Linear") .. "|" .. (direction or "In")
				_easing = v7[v17]

				if not _easing then
					_easing = easingFromNames(style, direction)
					v7[v17] = _easing
				end

				v14._easing = _easing
			end

			local v17 = _easing(v16)
			local _cache = v12._cache
			local v18

			if _cache[segment] == nil then
				local v19 = expectTypeFor(instance, property)
				v18 = deserialize(v14.Value, v19)
				_cache[segment] = v18
			else
				v18 = _cache[segment]
			end

			local v19

			if _cache[v13] == nil then
				local v20 = expectTypeFor(instance, property)
				v19 = deserialize(v15.Value, v20)
				_cache[v13] = v19
			else
				v19 = _cache[v13]
			end

			local typeName = typeof(v18)

			if typeName == "Instance" then
				typeName = v18.ClassName
			end

			local typeName2 = typeof(v19)

			if typeName2 == "Instance" then
				typeName2 = v19.ClassName
			end

			if typeName2 == typeName then
				local v20 = v8[typeName]

				if v20 then
					v18 = v20(v18, v19, v17)
				elseif v16 >= 1 then
					v18 = v19 or v18
				end
			elseif v16 >= 1 then
				v18 = v19 or v18
			end

			local _applyFn = v12._applyFn

			if v12._applyFor ~= instance then
				_applyFn = classifyApply(instance, property, v18)
				v12._applyFn = _applyFn
				v12._applyFor = instance
			end

			_applyFn(instance, property, v18, v11, scale)
		end
	end
end

function class:Play(p: number?)
	if self._running then
		self._paused = false
		return self
	end

	if p ~= nil then
		self:SetTime(p)
	end

	if not pcall(function()
		self:_spawnRuntimeVisualsIfNeeded()
	end) then
		warn("[MeshEmitterPlayer] Visuals spawn skipped (non-fatal).")
	end

	self._running = true
	self._paused = false
	self._conn = RunService.Heartbeat:Connect(function(dt)
		if not self._running or self._paused then
			return
		end

		local _t = self._t
		self._t += dt * self.Speed

		if self._t >= self._len then
			self._t = self._len
		end

		self:_evalAndApplyAt(self._t, _t)

		if self._t >= self._len then
			self:_cleanupRuntimeVisuals()
			self._running = false

			if self._conn then
				self._conn:Disconnect()
				self._conn = nil
			end

			for _, callback in ipairs(self._onCompleted) do
				task.spawn(callback)
			end
		end

		self._lastT = self._t
	end)
	return self
end

function class:Pause()
	self._paused = true
	return self
end

function class:Stop(flag: boolean?)
	self._running = false
	self._paused = false

	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end

	self:_cleanupRuntimeVisuals()

	if not flag then
		return self
	end

	self._t = 0
	self._lastT = 0
	self._eventIdx = 0
	self._userEvtIdx = 0
	self:_applyStaticScaleIfNeeded(true)
	self:_evalAndApplyAt(self._t, 0)
	return self
end

function class:SetTime(value: number)
	local lastT = math.clamp(value, 0, self._len)
	self._lastT = lastT
	self._t = lastT

	if #self._events > 0 then
		local eventIdx = 0

		for i, _event in ipairs(self._events) do
			if (_event.Time or 0) <= lastT then
				eventIdx = i
			else
				break
			end
		end

		self._eventIdx = eventIdx
	end

	if #self._userEvents > 0 then
		local userEvtIdx = 0

		for i, _userEvent in ipairs(self._userEvents) do
			if (_userEvent.Time or 0) <= lastT then
				userEvtIdx = i
			else
				break
			end
		end

		self._userEvtIdx = userEvtIdx
	end

	self:_applyStaticScaleIfNeeded(false)
	self:_evalAndApplyAt(self._t, self._t)
	return self
end

class.Seek = class.SetTime

function class:Destroy()
	self:Stop()
	self._tracks = {}
	self._onEvent = {}
	self._named = {}
	self._events = {}
	self._userEvents = {}
end

return {
	new = function(p)
		return class.new(p)
	end
}