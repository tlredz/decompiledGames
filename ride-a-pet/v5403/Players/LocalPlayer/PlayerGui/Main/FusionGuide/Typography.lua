local parent = script.Parent

local function ResizeText()
	local step1 = parent:WaitForChild("Step1")
	local uITextSizeConstraint = step1.Instruction:FindFirstChildOfClass("UITextSizeConstraint")
	local uITextSizeConstraint2 = step1.Heading:FindFirstChildOfClass("UITextSizeConstraint")
	local textSize = math.max(
		1,
		(math.min(uITextSizeConstraint.MaxTextSize, (math.floor(step1.Instruction.AbsoluteSize.Y / 2.6))))
	)
	local textSize2 = math.max(
		1,
		(math.min(uITextSizeConstraint2.MaxTextSize, (math.floor(step1.Heading.AbsoluteSize.Y / 1.2))))
	)
	local v3 = parent["Step" .. 1]
	v3.Instruction.TextSize = textSize
	v3.Heading.TextSize = textSize2
	local v4 = parent["Step" .. 2]
	v4.Instruction.TextSize = textSize
	v4.Heading.TextSize = textSize2
	local v5 = parent["Step" .. 3]
	v5.Instruction.TextSize = textSize
	v5.Heading.TextSize = textSize2
	local v6 = parent["Step" .. 4]
	v6.Instruction.TextSize = textSize
	v6.Heading.TextSize = textSize2
end

parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeText)
parent:WaitForChild("Step1").Instruction:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeText)
ResizeText()