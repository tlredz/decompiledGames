local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(script.Parent.Parent.Parent.OrchestratorState)
local PropertyStripBuilder = require(script.Parent.Parent.Parent.PropertyStripBuilder)
local v = {
	{
		Key = "MostLeftColor",
		Tag = "Scene_CrownMostLeft",
		DisplayName = "Most Left Crown"
	},
	{
		Key = "LeftColor",
		Tag = "Scene_CrownLeft",
		DisplayName = "Left Crown"
	},
	{
		Key = "MiddleColor",
		Tag = "Scene_CrownMiddle",
		DisplayName = "Middle Crown"
	},
	{
		Key = "RightColor",
		Tag = "Scene_CrownRight",
		DisplayName = "Right Crown"
	},
	{
		Key = "MostRightColor",
		Tag = "Scene_CrownMostRight",
		DisplayName = "Most Right Crown"
	}
}

local function ParseRGB(value, displayName: string)
	if type(value) ~= "string" then
		return nil, (`{displayName} color must be an RGB string.`)
	end

	local v2, v3, v4 = string.match(value, "^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")

	if not (v2 and v3 and v4) then
		return nil, (`{displayName} color must use the R, G, B format.`)
	end

	local v5 = tonumber(v2)
	local v6 = tonumber(v3)
	local v7 = tonumber(v4)

	if v5 and v6 and v7 and not (v5 > 255 or v6 > 255 or v7 > 255) then
		return Color3.fromRGB(v5, v6, v7), nil
	end

	return nil, (`{displayName} RGB values must be integers from 0 to 255.`)
end

local function FormatRGB(color: Color3)
	return (`{math.round(color.R * 255)}, {math.round(color.G * 255)}, {math.round(color.B * 255)}`)
end

local function CaptureTaggedColor(tag: string)
	for _, part in CollectionService:GetTagged(tag) do
		if not (part:IsA("BasePart") and part:IsDescendantOf(game)) then
			continue
		end

		local color = part.Color
		return (`{math.round(color.R * 255)}, {math.round(color.G * 255)}, {math.round(color.B * 255)}`)
	end

	return "27, 42, 52"
end

local function ValidateCommand(value)
	if type(value) ~= "table" then
		return false, "Crown color events must contain a command table."
	end

	for _, v2 in v do
		local _, v3 = ParseRGB(value[v2.Key], v2.DisplayName)

		if v3 then
			return false, v3
		end
	end

	return true, nil
end

local function GetInterpolationValues(p)
	local keyframeValues, v2, v3, v4 = PropertyStripBuilder.FindKeyframeValues(p.Strip.Keyframes, p.TimePosition)

	if keyframeValues == nil or v2 == nil then
		return nil, nil, 0
	end

	local easingStyle

	if v4 then
		easingStyle = v4.EasingStyle
	end

	if v3 ~= 0 and v4 then
		v3 = easingStyle == "Constant" and 0 or TweenService:GetValue(
			v3,
			easingStyle or Enum.EasingStyle.Linear,
			v4.EasingDirection or Enum.EasingDirection.InOut
		)
	end

	return keyframeValues, v2, v3
end

local CrownColorEvent = {}
CrownColorEvent.Type = "CrownColorEvent"
CrownColorEvent.DisplayName = "Crown Colors"
CrownColorEvent.GlobalEvent = true
CrownColorEvent.CreateInitialKeyframe = false
CrownColorEvent.HasKeyframeEasing = true
CrownColorEvent.EditableProperties = {
	{
		Path = { "Value", "MostLeftColor" },
		DisplayName = "Most Left Crown (R, G, B)",
		ValueType = "string",
		Default = "27, 42, 52"
	},
	{
		Path = { "Value", "LeftColor" },
		DisplayName = "Left Crown (R, G, B)",
		ValueType = "string",
		Default = "27, 42, 52"
	},
	{
		Path = { "Value", "MiddleColor" },
		DisplayName = "Middle Crown (R, G, B)",
		ValueType = "string",
		Default = "27, 42, 52"
	},
	{
		Path = { "Value", "RightColor" },
		DisplayName = "Right Crown (R, G, B)",
		ValueType = "string",
		Default = "27, 42, 52"
	},
	{
		Path = { "Value", "MostRightColor" },
		DisplayName = "Most Right Crown (R, G, B)",
		ValueType = "string",
		Default = "27, 42, 52"
	}
}

function CrownColorEvent.Supports(p)
	return p == game
end

function CrownColorEvent.ValidateKeyframe(p)
	return ValidateCommand(p.Value)
end

function CrownColorEvent.Capture(_)
	local result = {}

	for _, v2 in v do
		result[v2.Key] = CaptureTaggedColor(v2.Tag)
	end

	return result
end

function CrownColorEvent.Evaluate(p)
	if RunService:IsRunning() and p.IsServer then
		return
	end

	local v2, v3, v4 = GetInterpolationValues(p)

	if not (v2 and v3) then
		return
	end

	for _, v5 in v do
		local v6, v7 = ParseRGB(v2[v5.Key], v5.DisplayName)

		if not v6 then
			error(v7 or `{v5.DisplayName} has an invalid starting color.`)
		end

		local v8, v9 = ParseRGB(v3[v5.Key], v5.DisplayName)

		if not v8 then
			error(v9 or `{v5.DisplayName} has an invalid ending color.`)
		end

		local lerped = v6:Lerp(v8, v4)

		for _, part in CollectionService:GetTagged(v5.Tag) do
			if part:IsA("BasePart") and part:IsDescendantOf(game) then
				part.Color = lerped
			end
		end
	end
end

return CrownColorEvent