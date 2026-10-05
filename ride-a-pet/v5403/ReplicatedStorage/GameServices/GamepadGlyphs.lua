local UserInputService = game:GetService("UserInputService")
local GamepadGlyphs = {
	XboxImage = {
		[Enum.KeyCode.ButtonA] = "rbxasset://textures/ui/Controls/xboxA.png",
		[Enum.KeyCode.ButtonB] = "rbxasset://textures/ui/Controls/xboxB.png",
		[Enum.KeyCode.ButtonX] = "rbxasset://textures/ui/Controls/xboxX.png",
		[Enum.KeyCode.ButtonY] = "rbxasset://textures/ui/Controls/xboxY.png",
		[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/xboxLS.png",
		[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/xboxRS.png",
		[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxmenu.png",
		[Enum.KeyCode.DPadLeft] = "rbxasset://textures/ui/Controls/dpadLeft.png",
		[Enum.KeyCode.DPadRight] = "rbxasset://textures/ui/Controls/dpadRight.png",
		[Enum.KeyCode.DPadUp] = "rbxasset://textures/ui/Controls/dpadUp.png",
		[Enum.KeyCode.DPadDown] = "rbxasset://textures/ui/Controls/dpadDown.png"
	},
	PlayStationImage = {},
	PlayStationSymbol = {
		[Enum.KeyCode.ButtonA] = "✕",
		[Enum.KeyCode.ButtonB] = "○",
		[Enum.KeyCode.ButtonX] = "□",
		[Enum.KeyCode.ButtonY] = "△",
		[Enum.KeyCode.ButtonL1] = "L1",
		[Enum.KeyCode.ButtonR1] = "R1",
		[Enum.KeyCode.ButtonL3] = "L3"
	}
}
local v3 = nil

function GamepadGlyphs.IsPlayStation()
	if v3 ~= nil then
		return v3
	end

	local stringForKeyCode = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA)
	v3 = stringForKeyCode ~= nil and stringForKeyCode ~= "" and stringForKeyCode ~= "ButtonA" and string.find(
		stringForKeyCode,
		"A",
		1,
		true
	) == nil
	return v3
end

UserInputService.GamepadConnected:Connect(function()
	v3 = nil
end)

function GamepadGlyphs.For(p)
	local success, imageForKeyCode = pcall(UserInputService.GetImageForKeyCode, UserInputService, p)

	if success and imageForKeyCode and imageForKeyCode ~= "" then
		return imageForKeyCode, nil
	end

	if not GamepadGlyphs.IsPlayStation() then
		return GamepadGlyphs.XboxImage[p], nil
	end

	local v4 = GamepadGlyphs.PlayStationImage[p]

	if v4 then
		return v4, nil
	end

	return nil, GamepadGlyphs.PlayStationSymbol[p]
end

GamepadGlyphs.XboxText = {
	[Enum.KeyCode.ButtonA] = "A",
	[Enum.KeyCode.ButtonB] = "B",
	[Enum.KeyCode.ButtonX] = "X",
	[Enum.KeyCode.ButtonY] = "Y",
	[Enum.KeyCode.ButtonL1] = "LB",
	[Enum.KeyCode.ButtonR1] = "RB",
	[Enum.KeyCode.ButtonL2] = "LT",
	[Enum.KeyCode.ButtonR2] = "RT",
	[Enum.KeyCode.ButtonL3] = "LS"
}

function GamepadGlyphs.Text(p)
	if not GamepadGlyphs.IsPlayStation() then
		return GamepadGlyphs.XboxText[p] or p.Name
	end

	local v5 = GamepadGlyphs.PlayStationSymbol[p]

	if v5 then
		return v5
	end

	if p == Enum.KeyCode.ButtonL2 then
		return "L2"
	end

	if p == Enum.KeyCode.ButtonR2 then
		return "R2"
	end

	return GamepadGlyphs.XboxText[p] or p.Name
end

local uDim = UDim2.fromScale(0.42, 0.42)
local uDim2 = UDim2.fromScale(1, 0)
local vector = Vector2.new(1, 0)
local color = Color3.fromRGB(15, 15, 15)
local uDim3 = UDim.new(0.22, 0)

function GamepadGlyphs.CreateBadge(parent, p, flag: boolean?)
	local gamepadBadge = parent:FindFirstChild("GamepadBadge")

	if gamepadBadge then
		gamepadBadge:Destroy()
	end

	local image, text = GamepadGlyphs.For(p)

	if not (image or text) then
		text = GamepadGlyphs.Text(p)
	end

	local frame = Instance.new("Frame")
	frame.Name = "GamepadBadge"
	frame.Size = uDim
	frame.Position = uDim2
	frame.AnchorPoint = vector

	if flag then
		frame.Position = UDim2.new(1 - uDim2.X.Scale, -uDim2.X.Offset, uDim2.Y.Scale, uDim2.Y.Offset)
		frame.AnchorPoint = Vector2.new(1 - vector.X, vector.Y)
	end

	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = 0.05
	frame.BorderSizePixel = 0
	frame.ZIndex = parent.ZIndex + 5
	frame.Active = false
	frame.Selectable = false
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = uDim3
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.fromRGB(255, 255, 255)
	uIStroke.Thickness = 1.5
	uIStroke.Transparency = 0.6
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Parent = frame
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = frame
	local v7

	if image then
		v7 = Instance.new("ImageLabel")
		v7.Image = image
		v7.ScaleType = Enum.ScaleType.Fit
	else
		v7 = Instance.new("TextLabel")
		v7.Text = text
		v7.TextScaled = true
		v7.Font = Enum.Font.GothamBold
		v7.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	v7.Name = "Glyph"
	v7.BackgroundTransparency = 1
	v7.BorderSizePixel = 0
	v7.Size = UDim2.fromScale(0.76, 0.76)
	v7.Position = UDim2.fromScale(0.5, 0.5)
	v7.AnchorPoint = Vector2.new(0.5, 0.5)
	v7.ZIndex = frame.ZIndex + 1
	v7.Active = false
	v7.Selectable = false
	v7.Parent = frame
	frame.Parent = parent
	return frame
end

return GamepadGlyphs