local parent = script.Parent.Parent.Parent
local PropertyStripBuilder = require(parent.PropertyStripBuilder)

local function GetModelCaptureValue(folder)
	local primaryPart = folder.PrimaryPart

	if primaryPart and primaryPart:IsDescendantOf(folder) then
		return primaryPart.LocalTransparencyModifier
	end

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			return part.LocalTransparencyModifier
		end
	end

	return 0
end

local function ApplyValue(part, p: number)
	if part:IsA("BasePart") then
		part.LocalTransparencyModifier = p
		return
	end

	for _, instance in part:QueryDescendants("BasePart, Fire, Sparkles, Smoke, ParticleEmitter, Decal, Texture, Beam, TextLabel") do
		if instance:IsA("TextLabel") then
			instance.TextTransparency = p
		elseif instance:IsA("Beam") then
			instance.Brightness = 1 - p
		else
			instance.LocalTransparencyModifier = p
		end
	end
end

return PropertyStripBuilder.Create({
	Type = "BasePartLocalTransparencyModifier",
	DisplayName = "Local Transparency Modifier",
	CanAutoCapture = true,
	EditableProperties = {
		{
			Path = { "Value" },
			DisplayName = "Local Transparency Modifier",
			ValueType = "number",
			Min = 0,
			Max = 1,
			Step = 0.01
		}
	},
	Supports = function(instance)
		return instance:IsA("BasePart") or instance:IsA("Model")
	end,
	ValidateValue = function(value: number)
		if type(value) == "number" and value == value and not (value < 0 or value > 1) then
			return true, nil
		end

		return false, "BasePartLocalTransparencyModifier keyframes must contain a number Value between 0 and 1."
	end,
	Capture = function(part)
		if part:IsA("BasePart") then
			return part.LocalTransparencyModifier
		end

		return (GetModelCaptureValue(part))
	end,
	Interpolate = function(p: number, p2: number, p3: number)
		return p + (p2 - p) * p3
	end,
	Apply = function(p, p2: number, _)
		ApplyValue(p, p2)
	end,
	OnSuppressed = function(p)
		ApplyValue(p.Target, 1)
	end
})