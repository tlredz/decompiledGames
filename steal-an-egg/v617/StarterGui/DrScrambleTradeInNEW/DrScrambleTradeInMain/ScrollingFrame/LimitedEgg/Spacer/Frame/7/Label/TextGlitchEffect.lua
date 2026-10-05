local parent = script.Parent
assert(parent:IsA("TextLabel"), "Put this LocalScript inside the MECHA TextLabel")
local random = Random.new()
local v = {
	BurstIntervalMin = 1.2,
	BurstIntervalMax = 3.5,
	BurstDurationMin = 0.12,
	BurstDurationMax = 0.35,
	TickRate = 0.03,
	JitterX = 4,
	JitterY = 3,
	RotationJitter = 2,
	ScrambleChance = 0.65,
	MaxScrambledChars = 2,
	GlitchChars = {
		"#",
		"%",
		"&",
		"$",
		"@",
		"/",
		"\\",
		"0",
		"1",
		"7",
		"X",
		"?",
		"▓",
		"▒",
		"░"
	},
	AberrationEnabled = true,
	AberrationOffset = 3,
	AberrationColorA = Color3.fromRGB(255, 0, 110),
	AberrationColorB = Color3.fromRGB(0, 225, 255),
	AberrationTransparency = 0.25,
	FlickerChance = 0.12,
	StrokeFlashChance = 0.5,
	StrokeFlashColors = { Color3.fromRGB(0, 229, 255), Color3.fromRGB(255, 238, 0), Color3.fromRGB(255, 0, 128) },
	GradientSlide = true
}
local text = parent.Text
local position = parent.Position
local rotation = parent.Rotation
local textTransparency = parent.TextTransparency
local uIStroke = parent:FindFirstChildOfClass("UIStroke")
local color = uIStroke and uIStroke.Color
local uIGradient = parent:FindFirstChildOfClass("UIGradient")
local offset = uIGradient and uIGradient.Offset
local clones = {}

if v.AberrationEnabled then
	parent.ZIndex = math.max(parent.ZIndex, 2)

	for _, textColor in { v.AberrationColorA, v.AberrationColorB } do
		local clone = parent:Clone()
		clone:ClearAllChildren()
		clone.Name = "GlitchGhost"
		clone.TextColor3 = textColor
		clone.TextTransparency = 1
		clone.BackgroundTransparency = 1
		clone.ZIndex = parent.ZIndex - 1
		clone.Parent = parent.Parent
		table.insert(clones, clone)
	end
end

local function scrambleText()
	local v2 = {}

	for i = 1, #text do
		v2[i] = string.sub(text, i, i)
	end

	for _ = 1, random:NextInteger(1, v.MaxScrambledChars) do
		local integer = random:NextInteger(1, #v2)

		if v2[integer] ~= " " then
			v2[integer] = v.GlitchChars[random:NextInteger(1, #v.GlitchChars)]
		end
	end

	return table.concat(v2)
end

local function setGhosts(p, integer, integer2)
	for k, v2 in clones do
		if p then
			local v3 = k == 1 and 1 or -1
			v2.Text = parent.Text
			v2.Rotation = parent.Rotation
			v2.TextTransparency = v.AberrationTransparency
			v2.Position = position + UDim2.fromOffset(
				integer + v3 * v.AberrationOffset,
				integer2 + v3 * math.ceil(v.AberrationOffset / 2)
			)
		else
			v2.TextTransparency = 1
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restore()
	parent.Text = text
	parent.Position = position
	parent.Rotation = rotation
	parent.TextTransparency = textTransparency

	if uIStroke then
		uIStroke.Color = color
	end

	if uIGradient then
		uIGradient.Offset = offset
	end

	for _, v2 in clones do
		v2.TextTransparency = 1
	end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v2 = require(ReplicatedStorage.Client.UIEffects.GuiVisibility).Watch(parent, function(p)
	if not p then
		restore() -- equivalent call inferred; original call site unknown
	end
end, script)

local function doBurst()
	local number = random:NextNumber(v.BurstDurationMin, v.BurstDurationMax)
	local total = 0

	while total < number do
		if not v2.IsVisible() then
			return
		end

		local integer = random:NextInteger(-v.JitterX, v.JitterX)
		local integer2 = random:NextInteger(-v.JitterY, v.JitterY)
		parent.Position = position + UDim2.fromOffset(integer, integer2)
		parent.Rotation = rotation + random:NextNumber(-v.RotationJitter, v.RotationJitter)

		if random:NextNumber() < v.ScrambleChance then
			parent.Text = scrambleText()
		else
			parent.Text = text
		end

		parent.TextTransparency = random:NextNumber() < v.FlickerChance and 1 or textTransparency

		if uIStroke then
			if random:NextNumber() < v.StrokeFlashChance then
				uIStroke.Color = v.StrokeFlashColors[random:NextInteger(1, #v.StrokeFlashColors)]
			else
				uIStroke.Color = color
			end
		end

		if uIGradient and v.GradientSlide then
			uIGradient.Offset = Vector2.new(random:NextNumber(-0.5, 0.5), 0)
		end

		setGhosts(true, integer, integer2)
		total += task.wait(v.TickRate)
	end

	restore() -- equivalent call inferred; original call site unknown
end

task.spawn(function()
	while parent.Parent and v2.WaitUntilVisible() do
		task.wait(random:NextNumber(v.BurstIntervalMin, v.BurstIntervalMax))

		if v2.IsVisible() then
			doBurst()
		end
	end

	v2.Destroy()
end)