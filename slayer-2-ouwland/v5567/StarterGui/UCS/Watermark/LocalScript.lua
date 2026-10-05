local RunService = game:GetService("RunService")

if RunService:IsStudio() then
	return
end

for i = 1, 7 do
	for i2 = 1, 10 do
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.fromScale(0.15, 0.1)
		textLabel.Position = UDim2.fromScale((i - 1) * 0.15, (i2 - 1) * 0.1)
		textLabel.Parent = script.Parent
		textLabel.BackgroundTransparency = 1
		textLabel.TextScaled = true
		textLabel.Text = game.Players.LocalPlayer.Name
		textLabel.Rotation = 5
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextTransparency = 0.95
		textLabel.TextStrokeTransparency = 0.98
	end
end