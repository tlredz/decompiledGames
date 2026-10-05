local parent = script.Parent
local progress = parent:WaitForChild("Progress")
local uIGradient = parent:WaitForChild("LHalf"):WaitForChild("Circle"):WaitForChild("UIGradient")
local uIGradient2 = parent:WaitForChild("RHalf"):WaitForChild("Circle"):WaitForChild("UIGradient")
local progressLabel = parent:WaitForChild("ProgressLabel")

local function Update()
	local value = progress:GetAttribute("Value")
	progressLabel.Text = tostring((math.floor(value * 100))) .. "%"
	uIGradient2.Rotation = math.clamp(value * 360, 0, 180)
	uIGradient.Rotation = math.clamp(value * 360, 180, 360)
end

progress:GetAttributeChangedSignal("Value"):Connect(Update)