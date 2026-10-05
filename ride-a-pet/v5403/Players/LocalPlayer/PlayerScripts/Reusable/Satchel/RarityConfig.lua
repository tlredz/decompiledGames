local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function ConvertOneColorToGradient(color: Color3)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, color:Lerp(Color3.fromRGB(255, 255, 255), 0.5)),
		ColorSequenceKeypoint.new(0.5, color),
		ColorSequenceKeypoint.new(1, color:Lerp(Color3.new(), 0.5))
	})
end

local RarityConfig = {
	Gradients = {}
}

for _, uIGradient in ReplicatedStorage:WaitForChild("Assets"):WaitForChild("RarityGradients"):GetChildren() do
	if uIGradient:IsA("UIGradient") then
		RarityConfig.Gradients[uIGradient.Name] = uIGradient.Color
	end
end

return RarityConfig