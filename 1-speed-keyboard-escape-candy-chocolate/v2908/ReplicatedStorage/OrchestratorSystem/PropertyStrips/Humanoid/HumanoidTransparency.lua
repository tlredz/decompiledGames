local RunService = game:GetService("RunService")
local parent = script.Parent.Parent.Parent
require(parent.OrchestratorState)
local PropertyStripBuilder = require(parent.PropertyStripBuilder)
local color = Color3.new(0, 0, 0)

local function ParseHighlightColor(highlightColor)
	if highlightColor == nil then
		return color, nil
	end

	if type(highlightColor) ~= "string" then
		return nil, "HumanoidTransparency HighlightColor must be a hex string."
	end

	local v = string.match(highlightColor, "^#?(%x%x%x%x%x%x)$")

	if v then
		return
			Color3.fromRGB(
				assert((tonumber(string.sub(v, 1, 2), 16))),
				assert((tonumber(string.sub(v, 3, 4), 16))),
				assert((tonumber(string.sub(v, 5, 6), 16)))
			),
			nil
	end

	return nil, "HumanoidTransparency HighlightColor must use #RRGGBB format."
end

local function ValidateTransparency(value)
	if type(value) == "number" and value == value and not (value < 0 or value > 1) then
		return true, nil
	end

	return false, "HumanoidTransparency keyframes must contain a number Value between 0 and 1."
end

local function GetHighlightColorAtTime(p)
	local _, _, _, v = PropertyStripBuilder.FindKeyframeValues(p.Strip.Keyframes, p.TimePosition)
	local v3

	if v then
		v3 = v.HighlightColor
	end

	return ParseHighlightColor(v3) or color
end

local function GetCharacter(p)
	local parent2 = p.Parent

	if parent2 and parent2:IsA("Model") then
		return parent2
	end

	return nil
end

local function IsVisualCharacterPart(p, part)
	local isA = part:IsA("BasePart")

	if isA then
		if part == p.RootPart then
			isA = false
		else
			isA = part.Name ~= "HumanoidRootPart"
		end
	end

	return isA
end

local function FindTransitionHighlight(instance)
	for _, highlight in instance:GetChildren() do
		if highlight.Name == "OrchestratorHumanoidTransparencyHighlight" and highlight:IsA("Highlight") then
			return highlight
		end
	end

	return nil
end

local function UpdateTransitionHighlight(p, value: number, color2: Color3)
	local v = math.clamp(value, 0, 1)
	local transitionHighlight = FindTransitionHighlight(p)

	if v <= 0 or v >= 1 then
		if transitionHighlight then
			transitionHighlight:Destroy()
		end
	else
		if not transitionHighlight then
			transitionHighlight = Instance.new("Highlight")
			transitionHighlight.Name = "OrchestratorHumanoidTransparencyHighlight"
			transitionHighlight.Adornee = p
			transitionHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
			transitionHighlight.Parent = p
		end

		transitionHighlight.FillColor = color2
		transitionHighlight.OutlineColor = color2
		transitionHighlight.FillTransparency = 1 - (1 - math.abs(v * 2 - 1))
		transitionHighlight.OutlineTransparency = 1
	end
end

return PropertyStripBuilder.Create({
	Type = "HumanoidTransparency",
	DisplayName = "Transparency",
	CanAutoCapture = true,
	EditableProperties = {
		{
			Path = { "Value" },
			DisplayName = "Transparency",
			ValueType = "number",
			Min = 0,
			Max = 1,
			Step = 0.01,
			Default = 1
		},
		{
			Path = { "HighlightColor" },
			DisplayName = "Highlight Color (#RRGGBB)",
			ValueType = "string",
			Default = "#000000"
		}
	},
	Supports = function(humanoid)
		local isA = humanoid:IsA("Humanoid")

		if not isA then
			return isA
		end

		local parent2 = humanoid.Parent

		if not (parent2 and parent2:IsA("Model")) then
			parent2 = nil
		end

		isA = parent2 ~= nil
		return isA
	end,
	ValidateValue = function(p: number)
		return ValidateTransparency(p)
	end,
	ValidateKeyframe = function(p)
		local value = p.Value
		local v2, v3

		if type(value) == "number" and value == value and not (value < 0 or value > 1) then
			v2 = true
		else
			v2 = false
			v3 = "HumanoidTransparency keyframes must contain a number Value between 0 and 1."
		end

		if not v2 then
			return false, v3
		end

		local _, v4 = ParseHighlightColor(p.HighlightColor)
		return v4 == nil, v4
	end,
	Capture = function(p)
		local parent2 = p.Parent

		if not (parent2 and parent2:IsA("Model")) then
			parent2 = nil
		end

		if not parent2 then
			return 1
		end

		for _, part in parent2:GetDescendants() do
			local isA = part:IsA("BasePart")

			if isA then
				if part == p.RootPart then
					isA = false
				else
					isA = part.Name ~= "HumanoidRootPart"
				end
			end

			if not isA then
				continue
			end

			local transparency = part.Transparency

			if transparency <= 0 then
				return 0
			end

			return 0.5 + transparency * 0.5
		end

		return 1
	end,
	Interpolate = function(p: number, p2: number, p3: number)
		return p + (p2 - p) * p3
	end,
	Apply = function(p, value: number, data)
		if RunService:IsRunning() and data.IsServer then
			return
		end

		local parent2 = p.Parent

		if not (parent2 and parent2:IsA("Model")) then
			parent2 = nil
		end

		if not parent2 then
			return
		end

		local v2 = math.clamp(value, 0, 1)
		local transparency = v2 >= 0.995 and 1 or v2 >= 0.5 and 0.99 or 0

		for _, part in parent2:GetDescendants() do
			local isA = part:IsA("BasePart")

			if isA then
				if part == p.RootPart then
					isA = false
				else
					isA = part.Name ~= "HumanoidRootPart"
				end
			end

			if isA then
				part.Transparency = transparency
			end
		end

		local _, _, _, v5 = PropertyStripBuilder.FindKeyframeValues(data.Strip.Keyframes, data.TimePosition)
		local v7

		if v5 then
			v7 = v5.HighlightColor
		end

		UpdateTransitionHighlight(parent2, v2, ParseHighlightColor(v7) or color)
	end
})