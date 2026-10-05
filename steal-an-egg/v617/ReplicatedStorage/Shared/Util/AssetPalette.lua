local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local t = require(ReplicatedStorage.Packages.t)
local Numeric = require(ReplicatedStorage.Shared.Utils.Numeric)
local drawWeighted = Numeric.DrawWeighted
local color = Color3.fromRGB(255, 255, 255)
local strict = t.strict(t.Color3)
local strict2 = t.strict(t.optional(t.number))
local strict3 = t.strict(t.optional(t.string))
local strict4 = t.strict(t.instanceIsA("Model"))
local strict5 = t.strict(t.number)
local strict6 = t.strict(t.string)
local AssetPalette = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function speciesEntry(p: string)
	local v = Assets.Directory[p]
	assert(v ~= nil, (`Asset catalog carries no palette named {p}`))
	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wearsIris(instance)
	return instance:GetAttribute("IsEye") == true or string.find(string.lower(instance.Name), "eye", 1, true) ~= nil
end

local function wearsBaseCoat(color2: Color3, baseModelColor: Color3)
	local HSV, v, v2 = color2:ToHSV()
	local HSV2, v3, v4 = baseModelColor:ToHSV()
	local v5 = v < 0.16

	if v3 < 0.16 then
		if not v5 then
			return v5
		end

		if v4 < 0.08 then
			return v2 <= 0.08
		end

		return math.abs(v2 - v4) <= 0.18
	else
		local v6 = math.abs(HSV - HSV2)
		local v7 = v2 / math.max(v4, 0.001)
		local v8 = not v5

		if v8 then
			if math.min(v6, 1 - v6) <= 0.08 and v7 >= 0.08 then
				return v7 <= 1.6
			else
				return false
			end
		end

		return v8
	end
end

local function tint(part, baseModelColor: Color3, modelColorAt: Color3, p: number, count: number)
	local _, _, v = part.Color:ToHSV()
	local _, _, v2 = baseModelColor:ToHSV()
	local HSV, v3, v4 = modelColorAt:ToHSV()

	if not (v2 < 0.08) then
		v4 *= v / math.max(v2, 0.001)
	end

	local v5 = v4 * Random.new(p + 7919 + count):NextNumber(0.8333333333333334, 1.2)
	part.Color = Color3.fromHSV(HSV, v3, (math.clamp(v5, 0, 1)))

	if part:IsA("UnionOperation") then
		part.UsePartColor = true
	end
end

function AssetPalette.DrawEyeColorHex(object)
	assert(t.Random(object), "An iris draw needs a generator to draw from")
	local number = object:NextNumber()
	local number2 = object:NextNumber(0.35, 0.85)
	local number3 = object:NextNumber(0.35, 0.9)
	return Color3.fromHSV(number, number2, number3):ToHex()
end

function AssetPalette.DrawColorSeed(object)
	assert(t.Random(object), "A colour seed draw needs a generator to draw from")
	return object:NextInteger(1, 2147483647)
end

function AssetPalette.DrawColorIndex(p: string, p2)
	strict6(p)
	assert(t.Random(p2), "A palette slot draw needs a generator to draw from")
	local v2 = drawWeighted((speciesEntry(p)).PossibleModelColors, p2)

	if v2 then
		return v2.Index
	end

	return 0
end

function AssetPalette.DrawFields(p: string, p2)
	strict6(p)
	assert(t.Random(p2), "A palette draw needs a generator to draw from")
	return {
		EyeColor = AssetPalette.DrawEyeColorHex(p2),
		ColorSeed = AssetPalette.DrawColorSeed(p2),
		ColorIndex = AssetPalette.DrawColorIndex(p, p2)
	}
end

function AssetPalette.SettleFields(p: string, eyeColor: string?, p3: number?, p4: number?)
	strict6(p)
	strict3(eyeColor)
	strict2(p3)
	strict2(p4)
	local colorSeed = p3 == nil and 1 or p3

	if eyeColor == nil or eyeColor == "" then
		eyeColor = AssetPalette.DrawEyeColorHex(Random.new(colorSeed))
	end

	return {
		EyeColor = eyeColor,
		ColorSeed = colorSeed,
		ColorIndex = p4 == nil and 1 or p4
	}
end

function AssetPalette.ModelColorAt(p: string, p2: number)
	strict6(p)
	strict5(p2)
	local possibleModelColors = (speciesEntry(p)).PossibleModelColors

	if #possibleModelColors == 0 or p2 <= 0 then
		return nil
	end

	if Constants.IS_STUDIO then
		assert(possibleModelColors[p2], (`Palette for {p} stops short of slot {p2}`))
	end

	local v = possibleModelColors[(p2 - 1) % #possibleModelColors + 1][1]
	strict(v)
	return v
end

function AssetPalette.PaintModel(folder, p: string, p2: string, p3: number, p4: number)
	strict4(folder)
	strict6(p)
	strict6(p2)
	strict5(p3)
	strict5(p4)
	local v = speciesEntry(p) -- equivalent call inferred; original call site unknown
	local color2 = Color3.fromHex(p2)
	local modelColorAt = AssetPalette.ModelColorAt(p, p4)
	local v2 = Random.new(p3):NextNumber() < 0.5
	local count = 0

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			part = nil
		end

		if part == nil or (part:GetAttribute("DontModify") or part.Transparency >= 1) then
			continue
		end

		count += 1

		if wearsIris(part) then
			if v2 then
				part.Color = color2
			end
		elseif modelColorAt ~= nil then
			if modelColorAt == color and v.AlbinosColorFullWhite then
				part.Color = modelColorAt
			elseif wearsBaseCoat(part.Color, v.BaseModelColor) then
				tint(part, v.BaseModelColor, modelColorAt, p3, count)
			end
		end
	end
end

return AssetPalette