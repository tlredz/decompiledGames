local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Button = require(script.Parent.Button)
require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VideUtil)

local function TikfinityMobileEquipButton(data)
	return Button({
		Name = "TikfinityMobileEquipButton",
		Position = data.position,
		Size = data.size,
		ZIndex = data.zIndex,
		Text = data.text,
		Gradient = ColorSequence.new(Color3.fromRGB(90, 190, 255), Color3.fromRGB(20, 110, 200)),
		StrokeColor = Color3.fromRGB(10, 60, 120),
		OnActivated = data.onActivated
	})
end

return TikfinityMobileEquipButton