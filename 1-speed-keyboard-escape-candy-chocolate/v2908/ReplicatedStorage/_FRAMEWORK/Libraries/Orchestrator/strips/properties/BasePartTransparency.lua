local TweenService = game:GetService("TweenService")
require(script.Parent.Parent.Parent.types.Property)
local quad = Enum.EasingStyle.Quad
local out = Enum.EasingDirection.Out
local names = { "Constant" }
local v = {}
local names2 = {}
local v2 = {}

for _, v4 in Enum.EasingStyle:GetEnumItems() do
	table.insert(names, v4.Name)
	v[v4.Name] = v4
end

for _, v4 in Enum.EasingDirection:GetEnumItems() do
	table.insert(names2, v4.Name)
	v2[v4.Name] = v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEasingStyleName(p)
	if p == "Constant" then
		return "Constant"
	end

	return p.Name
end

local function getEasedAlpha(data, p: number)
	if data.easingStyle == "Constant" then
		return 0
	end

	return TweenService:GetValue(p, data.easingStyle, data.easingDirection)
end

local function supportsTransparency(instance)
	return instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") or instance:IsA("ImageLabel") or instance:IsA("ImageButton")
end

local function getNumberSequenceValue(sequence)
	local keypoints = sequence.Keypoints
	local value = keypoints[1].Value

	for _, keypoint in keypoints do
		if math.abs(keypoint.Value - value) > 1e-6 then
			return 0
		end
	end

	return value
end

local function captureValue(instance)
	if instance:IsA("BasePart") then
		return instance.LocalTransparencyModifier
	end

	if instance:IsA("Decal") then
		return instance.Transparency
	end

	if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
		local keypoints = instance.Transparency.Keypoints
		local value = keypoints[1].Value

		for _, keypoint in keypoints do
			if math.abs(keypoint.Value - value) > 1e-6 then
				return 0
			end
		end

		return value
	else
		if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
			return instance.TextTransparency
		end

		if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
			return instance.ImageTransparency
		end

		return nil
	end
end

local function applyValue(instance, p: number)
	if instance:IsA("BasePart") then
		instance.LocalTransparencyModifier = p
	elseif instance:IsA("Decal") then
		instance.Transparency = p
	elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
		instance.Transparency = NumberSequence.new(p)
	elseif instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		instance.TextTransparency = p
	elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		instance.ImageTransparency = p
	end
end

local function visitSupported(folder, fn)
	local v4

	if supportsTransparency(folder) then
		fn(folder)
		v4 = true
	else
		v4 = false
	end

	for _, descendant in folder:GetDescendants() do
		if not supportsTransparency(descendant) then
			continue
		end

		fn(descendant)
		v4 = true
	end

	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function captureActor(p)
	local v4 = 0
	local v5 = false
	visitSupported(p, function(p2)
		if not v5 then
			v4 = captureValue(p2) or 0
			v5 = true
		end
	end)
	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyActor(p, value: number)
	visitSupported(p, function(p2)
		applyValue(p2, value)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isActorApplied(p, value: number)
	local v4 = true
	visitSupported(p, function(p2)
		local v5 = captureValue(p2)

		if v5 == nil or math.abs(v5 - value) > 1e-6 then
			v4 = false
		end
	end)
	return v4
end

local BasePartTransparency = {}
BasePartTransparency.stripType = "property"
BasePartTransparency.playbackMode = "continuous"
BasePartTransparency.propertyName = "Transparency"
BasePartTransparency.context = "client"
BasePartTransparency.catchUpPolicies = { "latest" }
BasePartTransparency.dataTemplate = {
	value = 0,
	easingStyle = quad,
	easingDirection = out
}
BasePartTransparency.supportsGlobal = false

function BasePartTransparency.buildEditor(p, state, _)
	p.Components:AddNumberField(function(object)
		object:SetText("Local Transparency"):SetValue(state.value):SetNumberFilter(0, 1):SetOnChangedUnfocus(function(p2: number)
			state.value = p2
		end)
	end)
	p.Components:AddDropdown(function(object)
		object:SetText("Easing Style"):SetChoiceList(names):SetSelected(getEasingStyleName(state.easingStyle)):SetOnChanged(function(p2: string)
			if p2 == "Constant" then
				state.easingStyle = "Constant"
			else
				state.easingStyle = v[p2] or quad
			end
		end)
	end)
	p.Components:AddDropdown(function(object)
		object:SetText("Easing Direction"):SetChoiceList(names2):SetSelected(state.easingDirection.Name):SetOnChanged(function(p2: string)
			state.easingDirection = v2[p2] or out
		end)
	end)
end

function BasePartTransparency.supports(p)
	return (visitSupported(p, function() end))
end

function BasePartTransparency.capture(p, _)
	return {
		value = captureActor(p),
		easingStyle = quad,
		easingDirection = out
	}
end

function BasePartTransparency.interpolate(data, p, p2: number)
	return {
		value = math.lerp(data.value, p.value, getEasedAlpha(data, p2)),
		easingStyle = data.easingStyle,
		easingDirection = data.easingDirection
	}
end

function BasePartTransparency.apply(p, p2)
	applyActor(p, p2.value) -- equivalent call inferred; original call site unknown
end

function BasePartTransparency.isApplied(p, p2, _)
	return isActorApplied(p, p2.value)
end

return BasePartTransparency