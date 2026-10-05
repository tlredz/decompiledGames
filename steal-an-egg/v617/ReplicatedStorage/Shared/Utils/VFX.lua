local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local random = Random.new()
local v = {
	Discard = function(p, p2: number?)
		Debris:AddItem(p, (p2 == nil or not (p2 > 0)) and 0 or p2)
	end
}

local function numberAttribute(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if type(attribute) == "number" then
		return attribute
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stochasticRound(rate: number)
	return (math.floor(rate + random:NextNumber()))
end

local function thinForHandheld(p: number, value)
	if value and Constants.IS_MOBILE and not (p <= 1) then
		return (math.max(1, (math.round(p * (type(value) ~= "number" and 0.1 or value)))))
	end

	return p
end

local function isPlaying(p)
	return p.TimeScale > 0
end

local function isHandFired(p: number)
	return not (p < 1e999)
end

local function cueFor(instance, value)
	local emitDelay = instance:GetAttribute("EmitDelay")
	local v2 = type(emitDelay) ~= "number" and 0 or emitDelay

	if not (instance.TimeScale > 0 and v2 < 1e999) then
		return nil
	end

	local rate = instance.Rate
	local emitCount = instance:GetAttribute("EmitCount")

	if type(emitCount) == "number" then
		rate = emitCount
	end

	local pieces = stochasticRound(rate) -- equivalent call inferred; original call site unknown

	if value and Constants.IS_MOBILE and not (pieces <= 1) then
		pieces = math.max(1, (math.round(pieces * (type(value) ~= "number" and 0.1 or value))))
	end

	if pieces < 1 then
		return nil
	end

	return {
		emitter = instance,
		pieces = pieces,
		at = math.max(v2, 0)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lifetimeSeconds(p)
	return p.Lifetime.Max / p.TimeScale
end

-- equivalent calls inferred from this helper; original call sites unknown
local function settleSeconds(p)
	return p.at + lifetimeSeconds(p.emitter)
end

local function byCueTime(p, p2)
	return p.at < p2.at
end

local function playTimeline(list)
	table.sort(list, byCueTime)
	local v2 = 0

	for _, v3 in list do
		v2 = math.max(v2, settleSeconds(v3))
	end

	local v3 = 1

	while v3 <= #list and list[v3].at <= 0 do
		local v4 = list[v3]
		v4.emitter:Emit(v4.pieces)
		v3 += 1
	end

	if v3 <= #list then
		task.spawn(function()
			local total = 0

			for i = v3, #list do
				local v4 = list[i]

				if total < v4.at then
					total += task.wait(v4.at - total)
				end

				if v4.emitter:IsDescendantOf(game) then
					v4.emitter:Emit(v4.pieces)
				end
			end
		end)
	end

	return v2
end

local function collectEmitters(emitter)
	local emitters = {}

	if emitter:IsA("ParticleEmitter") then
		table.insert(emitters, emitter)
	end

	for _, emitter2 in emitter:GetDescendants() do
		if emitter2:IsA("ParticleEmitter") then
			table.insert(emitters, emitter2)
		end
	end

	return emitters
end

local function cuesFor(items, p)
	local result = {}

	for _, item in items do
		local v2 = cueFor(item, p)

		if v2 then
			table.insert(result, v2)
		end
	end

	return result
end

function v.EmitOne(emitter, p2)
	local v2 = cueFor(emitter, p2)

	if v2 == nil then
		return 0
	end

	return (playTimeline({ v2 }))
end

function v.EmitTree(p, p2)
	return (playTimeline(cuesFor(collectEmitters(p), p2)))
end

local function scaleSequence(size, p: number)
	local numberSequenceKeypoints = table.create(#size.Keypoints)

	for k, keypoint in size.Keypoints do
		numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function v:Rescale(p: number)
	self.Acceleration *= p
	self.Size = scaleSequence(self.Size, p)
	self.Speed = NumberRange.new(self.Speed.Min * p, self.Speed.Max * p)
end

local v2 = {
	Anchored = true,
	CanCollide = false,
	CanQuery = false,
	CanTouch = false,
	CastShadow = false,
	Locked = true,
	Massless = true,
	Name = "EffectAnchor",
	Size = vector.create(0, 0, 0),
	Transparency = 1
}

local function newAnchorPart(cframe: CFrame)
	local part = Instance.new("Part")

	for k, v3 in v2 do
		part[k] = v3
	end

	part:PivotTo(cframe)
	part.Parent = Workspace:WaitForChild("Transient")
	return part
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hostOfInstance(model)
	if not model:IsA("Model") then
		return model
	end

	local primaryPart = model.PrimaryPart
	assert(primaryPart, (`{model:GetFullName()} needs a PrimaryPart to anchor effects`))
	return primaryPart
end

local v3 = {
	CFrame = function(cframe)
		local part = Instance.new("Part")

		for k, v4 in v2 do
			part[k] = v4
		end

		part:PivotTo(cframe)
		part.Parent = Workspace:WaitForChild("Transient")
		return part, part
	end,
	Instance = function(model)
		local v4 = hostOfInstance(model) -- equivalent call inferred; original call site unknown
		return v4, nil
	end,
	Vector3 = function(position)
		local cframe = CFrame.new(position)
		local part = Instance.new("Part")

		for k, v4 in v2 do
			part[k] = v4
		end

		part:PivotTo(cframe)
		part.Parent = Workspace:WaitForChild("Transient")
		return part, part
	end
}

local function anchorFor(p)
	local v4 = v3[typeof(p)]

	if v4 == nil then
		error((`effects cannot be placed at a {typeof(p)}`))
	end

	return v4(p)
end

function v.EmitAt(p, items, callback)
	local v4 = v3[typeof(p)]

	if v4 == nil then
		error((`effects cannot be placed at a {typeof(p)}`))
	end

	local parent, v6 = v4(p)
	local clones = {}
	local v7 = {}

	local function stageClone(emitter)
		local clone = emitter:Clone()
		clone.Enabled = false

		if callback then
			callback(clone)
		end

		clone.Parent = parent
		local v8 = cueFor(clone, true)

		if v8 == nil then
			clone:Destroy()
			return
		end

		table.insert(clones, clone)
		table.insert(v7, v8)

		if v6 == nil then
			v.Discard(clone, settleSeconds(v8))
		end
	end

	for _, emitter in items do
		if emitter:IsA("ParticleEmitter") and emitter.TimeScale > 0 then
			stageClone(emitter)
		end
	end

	local settleSeconds2 = playTimeline(v7)

	if v6 then
		v.Discard(v6, settleSeconds2)
	end

	return {
		clones = clones,
		settleSeconds = settleSeconds2
	}
end

return table.freeze(v)