local ButtonFX = require(script.Parent.ButtonFX)
local _ = {
	peakScale = 1.045,
	pressedScale = 0.965,
	cueGain = 1.75,
	hitAreaName = "PressSurface",
	hitAreaLift = 64
}

local function hitAreaOf(button)
	if button:IsA("GuiButton") then
		return button, false
	end

	local pressSurface = button:FindFirstChild("PressSurface")

	if pressSurface and pressSurface:IsA("GuiButton") then
		return pressSurface, false
	end

	local textButton = Instance.new("TextButton")
	textButton.Name = "PressSurface"
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.BackgroundTransparency = 1
	textButton.ZIndex = button.ZIndex + 64
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.Parent = button
	return textButton, true
end

return function(host, value: number?, onActivate)
	host.Active = true
	local input, ownsInput = hitAreaOf(host)
	return ButtonFX({
		host = host,
		input = input,
		ownsInput = ownsInput,
		peakScale = value or 1.045,
		pressedScale = 0.965,
		cueGain = 1.75,
		onActivate = onActivate
	})
end