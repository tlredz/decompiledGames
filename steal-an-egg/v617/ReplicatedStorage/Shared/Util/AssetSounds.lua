local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.Shared.Audio)

local function sizeFactor(object, name: string, data)
	local weight

	if data then
		weight = data.weight
	end

	local baseWeight

	if data then
		baseWeight = data.baseWeight
	end

	if name == "WalkSound" and typeof(weight) == "number" and typeof(baseWeight) == "number" and baseWeight > 0 then
		return (math.max(weight / baseWeight, 0.001))
	end

	local v = (not data or typeof(data.baseModelScale) ~= "number") and 1 or data.baseModelScale
	local v2 = v <= 0 and 1 or v
	return (math.max(object:GetScale() / v2, 0.001))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaled(value: number?, value2: number, min: number, max: number)
	if typeof(value) == "number" then
		return value * math.clamp(value2, min, max)
	end

	return nil
end

local function splitMutationList(value)
	local result = {}

	if typeof(value) ~= "string" or value == "" then
		return result
	end

	for k in string.gmatch(value, "[^,]+") do
		local v = k:gsub("^%s*(.-)%s*$", "%1")

		if v ~= "" then
			table.insert(result, v)
		end
	end

	return result
end

local AssetSounds = {}

function AssetSounds.BuildSound(parent, p, p2, name: string, p3)
	if not p2 then
		return nil
	end

	local sound = Instance.new("Sound")
	sound.Name = name
	Audio.Configure(sound, p2)
	sound.RollOffMaxDistance = 40
	local v = sizeFactor(p, name, p3)

	if sound.Volume > 0 then
		local v2 = name == "WalkSound" and 3.5 or 3
		local volume = scaled(sound.Volume, v, 1, v2) -- equivalent call inferred; original call site unknown

		if volume then
			sound.Volume = volume
		end
	end

	if sound.RollOffMaxDistance > 0 then
		local rollOffMaxDistance = scaled(sound.RollOffMaxDistance, v, 0.7, 1.2) -- equivalent call inferred; original call site unknown

		if rollOffMaxDistance then
			sound.RollOffMaxDistance = rollOffMaxDistance
		end
	end

	sound.Parent = parent
	return sound
end

function AssetSounds.WeightedParams(value: number?)
	if value == nil or value <= 0 then
		return 1, 1
	end

	local v = math.clamp(value, 50, 480)
	local v2 = (math.log(v) - 3.912023005428146) / 2.2617630984737906
	local v3 = v2 * 0.5 + 2.5

	if v >= 80 and v <= 110 then
		return v3, 1
	end

	return v3, 2 - v2 * 1.5
end

function AssetSounds.ParseMutationList(p)
	return (splitMutationList(p))
end

function AssetSounds.ReadMutationState(instance, value: string?, value2: string?)
	local v = splitMutationList(instance:GetAttribute(value or "Mutations"))
	local attribute = instance:GetAttribute(value2 or "BaseMutation")

	if typeof(attribute) ~= "string" or attribute == "" then
		attribute = nil
	end

	return v, attribute
end

function AssetSounds.AttachEffects(list, parent)
	if not list then
		return nil
	end

	for _, v in ipairs(list) do
		v.Parent = parent
	end

	return list
end

function AssetSounds:StartFootsteps()
	if not self or self.IsPlaying then
		return
	end

	self.TimePosition = 0
	self.Looped = true
	self:Play()
end

function AssetSounds.StopFootsteps(object)
	if object and object.IsPlaying then
		object:Stop()
	end
end

function AssetSounds:PlayJump()
	if not self then
		return
	end

	self.TimePosition = 0
	self.Looped = false
	self:Play()
end

return AssetSounds