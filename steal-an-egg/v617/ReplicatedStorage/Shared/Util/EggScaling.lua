local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventEggCategories = require(ReplicatedStorage.Shared.Util.EventEggCategories)
local t = require(ReplicatedStorage.Packages.t)
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))

local function finiteVector3(data)
	if typeof(data) == "Vector3" then
		return intersection(data.X) and intersection(data.Y) and intersection(data.Z)
	end

	return false
end

local strict = t.strict(intersection)
local strict2 = t.strict(finiteVector3)
local strict3 = t.strict(t.optional(t.string))
local strict4 = t.strict(t.instanceIsA("Model"))
local EggScaling = {
	ClampSaved = function(value: number)
		strict(value)
		return (math.clamp(value, 0.002, 200))
	end,
	FloorForCategory = function(p: number, p2: string?)
		strict(p)
		strict3(p2)

		if EventEggCategories.IsEventEgg(p2) then
			return p * 1
		end

		return p * 0.6
	end,
	RawVisual = function(p: number, p2: number)
		strict(p)
		strict(p2)
		return p * math.max(p2, 0.002)
	end
}

function EggScaling.LiftToFloor(p: number, p2: number, p3: string?)
	strict(p)
	strict(p2)
	return (math.max(EggScaling.FloorForCategory(p, p3), p2))
end

function EggScaling.PreGrowthVisual(p: number, p2: number, p3: string?)
	return (math.clamp(EggScaling.RawVisual(p, p2), EggScaling.FloorForCategory(p, p3), p * 8))
end

function EggScaling.PlacedStart(p: number, p2: number, p3: string?)
	return EggScaling.PreGrowthVisual(p, p2, p3)
end

function EggScaling.PlacedTarget(p: number, p2: number, p3: string?)
	local rawVisual = EggScaling.RawVisual(p, p2)
	local floorForCategory = EggScaling.FloorForCategory(p, p3)

	if rawVisual < floorForCategory then
		return floorForCategory
	end

	return rawVisual * 3
end

function EggScaling.FitInside(object, vector: Vector3)
	strict4(object)
	strict2(vector)
	local _, v = ModelBounds(object)
	local v2 = math.min(
		vector.X / math.max(v.X, 0.002),
		vector.Y / math.max(v.Y, 0.002),
		vector.Z / math.max(v.Z, 0.002)
	) * 0.92
	return EggScaling.ClampSaved(object:GetScale() * v2)
end

EggScaling.MIN_EGG_SCALE = 0.8
EggScaling.MAX_EGG_SCALE = 3
EggScaling.MIN_ICON_SCALE = 0.5
EggScaling.MAX_ICON_SCALE = 1.1

function EggScaling.IconScaleFor(value: number?)
	if typeof(value) ~= "number" then
		return 1.1
	end

	if value == value and not (value <= 0) then
		return (math.clamp(value, 0.8, 3) - 0.8) / 2.2 * 0.6000000000000001 + 0.5
	end

	return 1.1
end

function EggScaling:FitIconToEgg(p2: number?)
	local iconScaleFor = EggScaling.IconScaleFor(p2)
	self.Size = UDim2.fromScale(iconScaleFor, iconScaleFor)
end

return EggScaling