local UserInputService = game:GetService("UserInputService")
local mouseLocation = nil
local palette = script.Parent:WaitForChild("Palette")
local selectedColor = script.Parent:WaitForChild("SelectedColor")
local selectedColorText = script.Parent:WaitForChild("SelectedColorText")
local selectedBrickColorText = script.Parent:WaitForChild("SelectedBrickColorText")
local darkness = script.Parent:WaitForChild("Darkness")
local darknessAppearance = script.Parent:WaitForChild("DarknessAppearance")
local uIGradient = darknessAppearance:WaitForChild("UIGradient")
local darknessPointer = darknessAppearance:WaitForChild("DarknessPointer")
local colorPaletteCrosshairs = palette:WaitForChild("ColorPaletteCrosshairs")
local basicColors = script.Parent:WaitForChild("BasicColors")
local v = nil
local v2 = nil
local v3 = 0.16666666666666666 * palette.AbsoluteSize.X
local _ = v3 * 2
local _ = v3 * 3
local _ = v3 * 4
local _ = v3 * 5
local v4 = 0
local v5 = 0
local v6 = 0
local Y = palette.AbsoluteSize.Y
local flag = false

function UpdateSelectedColor()
	if selectedColor.Text == "Color" then
		selectedColor.BackgroundColor3 = Color3.fromHSV(v4, v5, v6)
	else
		selectedColor.BackgroundColor3 = BrickColor.new(Color3.fromHSV(v4, v5, v6)).Color
	end

	selectedColorText.Text = "r,g,b:  " .. tostring((math.floor(selectedColor.BackgroundColor3.R * 255))) .. ", " .. tostring((math.floor(selectedColor.BackgroundColor3.G * 255))) .. ", " .. tostring((math.floor(selectedColor.BackgroundColor3.B * 255)))
	selectedBrickColorText.Text = tostring(BrickColor.new(selectedColor.BackgroundColor3))
end

palette.MouseButton1Down:Connect(function()
	flag = true

	while flag do
		mouseLocation = UserInputService:GetMouseLocation()
		v = mouseLocation.X - palette.AbsolutePosition.X
		v2 = mouseLocation.y - palette.AbsolutePosition.Y + script.Parent.Parent.AbsolutePosition.Y
		v = math.clamp(v, 0, palette.AbsoluteSize.X)
		v2 = math.clamp(v2, 0, Y)
		local v7 = 1 - v / 220
		local v8 = 1 - v2 / 200
		local v9 = 1 - (darknessPointer.Position.Y.Offset + 6) / 200
		v4 = v7
		v5 = v8
		v6 = v9
		colorPaletteCrosshairs.Position = UDim2.new(0, v - 14, 0, v2 - 14)
		uIGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(v4, v5, 1))
		UpdateSelectedColor()
		task.wait(0.1)
	end
end)
local flag2 = false
darkness.MouseButton1Down:Connect(function()
	flag2 = true

	while flag2 do
		mouseLocation = UserInputService:GetMouseLocation()
		v2 = mouseLocation.y - darknessAppearance.AbsolutePosition.Y - 36
		v2 = math.clamp(v2, 0, Y)
		darknessPointer.Position = UDim2.new(0, 14, 0, v2 - 6)
		v6 = 1 - v2 / 200
		UpdateSelectedColor()
		task.wait(0.1)
	end
end)
UserInputService.InputEnded:Connect(function()
	flag = false
	flag2 = false
end)

for _, child in pairs(basicColors:GetChildren()) do
	local v7 = child
	child.MouseButton1Click:Connect(function()
		if selectedColor.Text == "Color" then
			selectedColor.BackgroundColor3 = v7.BackgroundColor3
		else
			selectedColor.BackgroundColor3 = BrickColor.new(v7.BackgroundColor3).Color
		end

		selectedColorText.Text = "r,g,b:  " .. tostring((math.floor(selectedColor.BackgroundColor3.R * 255))) .. ", " .. tostring((math.floor(selectedColor.BackgroundColor3.G * 255))) .. ", " .. tostring((math.floor(selectedColor.BackgroundColor3.B * 255)))
		selectedBrickColorText.Text = tostring(BrickColor.new(selectedColor.BackgroundColor3))
		v4, v5, v6 = selectedColor.BackgroundColor3:ToHSV()
		colorPaletteCrosshairs.Position = UDim2.new(0, 220 - v4 * 220 - 14, 0, 200 - v5 * 200 - 14)
		darknessPointer.Position = UDim2.new(0, 14, 0, 200 - v6 * 200 - 6)
		uIGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(v4, v5, 1))
	end)
end