local ColorEncoder = require(game.ReplicatedStorage.Util.ColorEncoder)
local ColorSequenceUtil = require(game.ReplicatedStorage.Util.ColorSequenceUtil)
local GrayscaleToColor = require(game.ReplicatedStorage.Util.GrayscaleToColor)
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})
local ColorPaletteCache = {}

local function getClampedHSV(color: Color3)
	if color.R < 0 or color.R > 1 or color.G < 0 or color.G > 1 or color.B < 0 or color.B > 1 then
		color = Color3.new(math.clamp(color.R, 0, 1), math.clamp(color.G, 0, 1), (math.clamp(color.B, 0, 1)))
	end

	return color:ToHSV()
end

local function getColorShiftHSV(color: Color3, attribute: Color3)
	local clampedHSV, v, v2 = getClampedHSV(color)
	local clampedHSV2, v3, v4 = getClampedHSV(attribute)
	return (clampedHSV2 - clampedHSV + 1) % 1, v3 / v, v4 / v2
end

local function applyColorShiftHSV(color: Color3, X: number, Y: number, Z: number)
	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local HSV, v5, v6 = Color3.fromRGB(v2, v3, v4):ToHSV()
	local v7 = (HSV + X) % 1
	local v8 = math.clamp(v5 * Y, 0, 1)
	local v9 = math.clamp(v6 * Z, 0, 1)
	return Color3.fromHSV(v7, v8, v9 * v)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function invalidate(p)
	object[p] = nil
	local v = object2[p]

	if v then
		for _, connection in ipairs(v) do
			connection:Disconnect()
		end

		object2[p] = nil
	end
end

local function build(instance)
	local default = instance:FindFirstChild("Default")
	local shifted = instance:FindFirstChild("Shifted")

	if default == nil or shifted == nil then
		return nil
	end

	local defaultColors = {}
	local attributes = {}
	local vectors = {}
	local defaultHues = {}
	local staticTimes = {}
	local attributes2 = {}
	local flag = false

	for k, v4 in pairs(default:GetAttributes()) do
		if k == "__StableId" then
			continue
		end

		local v5 = tonumber(k:match("^Default_Color(%d+)$"))

		if v5 == nil then
			warn((`unknown index from name={k}`))
		elseif typeof(v4) == "Color3" then
			local attribute = shifted:GetAttribute("Shifted_Color" .. v5)

			if typeof(attribute) == "ColorSequence" then
				local value = attribute.Keypoints[1].Value
				local flag2 = true

				for _, keypoint in ipairs(attribute.Keypoints) do
					if keypoint.Value == value then
						continue
					end

					flag2 = false
					break
				end

				if flag2 then
					attribute = value
				else
					local attribute2 = shifted:GetAttribute("Shifted_Color" .. v5 .. "_StaticTime")
					staticTimes[v5] = typeof(attribute2) ~= "number" and 0.5 or math.clamp(attribute2, 0, 1)
					attributes2[v5] = attribute
					attribute = ColorSequenceUtil.eval(attribute, staticTimes[v5])
					flag = true
				end
			elseif typeof(attribute) ~= "Color3" then
				return nil
			end

			defaultColors[v5] = v4
			attributes[v5] = attribute
			vectors[v5] = Vector3.new(getColorShiftHSV(v4, attribute))
			defaultHues[v5] = select(1, getClampedHSV(v4))
		else
			warn((`Default_Color{v5} must be a Color3, got {typeof(v4)}`))
		end
	end

	local grayscaleToColorStrength = shifted:GetAttribute("GrayscaleToColorStrength")
	local grayscaleToColorSequence = shifted:GetAttribute("GrayscaleToColorSequence")
	local v4

	if grayscaleToColorStrength == nil or not (math.abs(grayscaleToColorStrength) > 0.0001) then
		v4 = false
	else
		v4 = typeof(grayscaleToColorSequence) == "ColorSequence"
	end

	local allColorsUnchanged = true

	for i, v7 in ipairs(defaultColors) do
		if v7 == attributes[i] then
			continue
		end

		allColorsUnchanged = false
		break
	end

	if #defaultColors ~= #attributes then
		warn("Somehow a difference in number of default colors and number of shifted colors")
		allColorsUnchanged = false
	end

	if v4 then
		allColorsUnchanged = false
	end

	if flag then
		allColorsUnchanged = false
	end

	if not flag then
		attributes2 = nil
	end

	local v7 = {
		DefaultColors = defaultColors,
		ShiftedColors = attributes,
		HSVDifferences = vectors,
		DefaultHues = defaultHues,
		ShiftedSequences = attributes2,
		StaticTimes = staticTimes,
		AllColorsUnchanged = allColorsUnchanged,
		TransformCache = {},
		SlotCache = {}
	}

	if v4 then
		v7.GrayscaleToColorStrength = grayscaleToColorStrength
		v7.GrayscaleToColorSequence = grayscaleToColorSequence
	end

	local function onPaletteChildChanged(p)
		if p.Name == "Default" or p.Name == "Shifted" then
			invalidate(instance) -- equivalent call inferred; original call site unknown
		end
	end

	object2[instance] = {
		instance.ChildAdded:Connect(onPaletteChildChanged),
		instance.ChildRemoved:Connect(onPaletteChildChanged),
		default.AttributeChanged:Connect(function()
			invalidate(instance) -- equivalent call inferred; original call site unknown
		end),
		shifted.AttributeChanged:Connect(function()
			invalidate(instance) -- equivalent call inferred; original call site unknown
		end),
		instance:GetAttributeChangedSignal("PaletteVersion"):Connect(function()
			invalidate(instance) -- equivalent call inferred; original call site unknown
		end),
		instance.Destroying:Connect(function()
			invalidate(instance) -- equivalent call inferred; original call site unknown
		end)
	}
	return v7
end

function ColorPaletteCache.get(p)
	local v = object[p]

	if v then
		return v
	end

	local v2 = build(p)

	if v2 then
		object[p] = v2
	end

	return v2
end

function ColorPaletteCache.matchSlotIndex(data, color: Color3)
	local v = string.format("%.5f,%.5f,%.5f", color.R, color.G, color.B)
	local v2 = data.SlotCache[v]

	if v2 == nil then
		local v3 = math.max(1, color.R, color.G, color.B)
		local v4 = math.floor(color.R / v3 * 255) % 256
		local v5 = math.floor(color.G / v3 * 255) % 256
		local v6 = math.floor(color.B / v3 * 255) % 256
		local v7 = select(1, Color3.fromRGB(v4, v5, v6):ToHSV())
		local v8 = 99999999999
		local v9 = nil

		for i in ipairs(data.DefaultColors) do
			local v10 = math.abs(v7 - data.DefaultHues[i])
			local v11 = math.min(v10, 1 - v10)

			if not (v11 < v8) then
				continue
			end

			v9 = i
			v8 = v11
		end

		data.SlotCache[v] = v9 or 0
		return v9, v
	else
		if v2 == 0 then
			v2 = nil
		end

		return v2, v
	end
end

function ColorPaletteCache.getGradientFor(p, color: Color3)
	local shiftedSequences = p.ShiftedSequences

	if shiftedSequences == nil then
		return nil
	end

	local matchSlotIndex = ColorPaletteCache.matchSlotIndex(p, color)

	if matchSlotIndex == nil then
		return nil
	end

	return shiftedSequences[matchSlotIndex]
end

function ColorPaletteCache.getSequenceResampleTimes(p, sequence)
	local times = nil

	for _, keypoint in sequence.Keypoints do
		if ColorEncoder.isColorDataEncoded(keypoint.Value) then
			return nil
		end

		local gradientFor = ColorPaletteCache.getGradientFor(p, keypoint.Value)

		if not gradientFor then
			continue
		end

		times = times or {}

		for _, keypoint2 in gradientFor.Keypoints do
			table.insert(times, keypoint2.Time)
		end
	end

	return times
end

function ColorPaletteCache.transformColor(data, color: Color3, p: number?)
	local matchSlotIndex, v = ColorPaletteCache.matchSlotIndex(data, color)
	local X = 0
	local Y = 1
	local Z = 1

	if matchSlotIndex == nil then
		local color2 = data.TransformCache[v]

		if color2 then
			return color2
		end
	else
		local v2

		if data.ShiftedSequences then
			v2 = data.ShiftedSequences[matchSlotIndex]
		end

		if v2 == nil then
			local color2 = data.TransformCache[v]

			if color2 then
				return color2
			end

			local hSVDifference = data.HSVDifferences[matchSlotIndex]
			X = hSVDifference.X
			Y = hSVDifference.Y
			Z = hSVDifference.Z
		else
			local v3 = math.floor(math.clamp(p or data.StaticTimes[matchSlotIndex] or 0.5, 0, 1) * 256 + 0.5) / 256
			v ..= "@" .. v3
			local color2 = data.TransformCache[v]

			if color2 then
				return color2
			end

			local defaultColor = data.DefaultColors[matchSlotIndex]
			local eval = ColorSequenceUtil.eval(v2, v3)
			local clampedHSV, v4, v5 = getClampedHSV(defaultColor)
			local clampedHSV2, v6, v7 = getClampedHSV(eval)
			X = (clampedHSV2 - clampedHSV + 1) % 1
			Y = v6 / v4
			Z = v7 / v5
		end
	end

	local color2 = applyColorShiftHSV(color, X, Y, Z)

	if data.GrayscaleToColorStrength and data.GrayscaleToColorSequence then
		color2 = GrayscaleToColor(color2, data.GrayscaleToColorSequence, data.GrayscaleToColorStrength)
	end

	local encodeColorData = ColorEncoder.encodeColorData(color2)
	data.TransformCache[v] = encodeColorData
	return encodeColorData
end

return ColorPaletteCache