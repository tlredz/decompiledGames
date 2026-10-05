local ValleyTheme = {
	Ink = Color3.fromRGB(12, 28, 30),
	InventoryInk = Color3.fromRGB(16, 31, 46),
	Paper = Color3.fromRGB(240, 236, 218),
	Muted = Color3.fromRGB(166, 187, 179),
	Gold = Color3.fromRGB(228, 203, 137),
	Mint = Color3.fromRGB(127, 217, 191),
	Blue = Color3.fromRGB(147, 208, 237),
	Purple = Color3.fromRGB(197, 151, 255),
	Border = Color3.fromRGB(92, 124, 115)
}

function ValleyTheme:surface(backgroundColor, p, value, value2)
	self.BackgroundColor3 = backgroundColor
	self.BorderSizePixel = 0
	local uIGradient = self:FindFirstChildOfClass("UIGradient")

	if uIGradient then
		uIGradient.Enabled = false
	end

	local uICorner = self:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uICorner.Name = "Corner"
	uICorner.CornerRadius = UDim.new(0, value or 5)
	uICorner.Parent = self
	local uIStroke = self:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	uIStroke.Name = "Border"
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Thickness = 1
	uIStroke.Color = p or ValleyTheme.Border
	uIStroke.Transparency = value2 or 0.62
	uIStroke.Parent = self
end

function ValleyTheme:button(p2, p3)
	ValleyTheme.surface(self, p3 or ValleyTheme.Ink:Lerp(p2, 0.1), p2, 5, 0.62)
	self.TextColor3 = ValleyTheme.Paper
	self.Font = Enum.Font.GothamBold
end

return ValleyTheme