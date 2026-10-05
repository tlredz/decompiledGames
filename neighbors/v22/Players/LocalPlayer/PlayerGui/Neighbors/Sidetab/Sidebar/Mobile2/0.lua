local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(ReplicatedStorage.Modules.UI)
local parent = script.Parent
local uIListLayout = parent.Tabs.UIListLayout

if UI:GetDeviceType() == "Mobile" or UI:GetDeviceType() == "Tablet" then
	if UI:GetDeviceType() == "Tablet" then
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		parent.Position = UDim2.new(parent.Position.X.Scale, parent.Position.X.Offset, 0.5, 0)
		parent.AnchorPoint = Vector2.new(1, 0.5)
	else
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		parent.Position = UDim2.new(parent.Position.X.Scale, parent.Position.X.Offset, 0, 10)
		parent.AnchorPoint = Vector2.new(1, 0)
	end

	UI:RegisterConstantUIScale(parent.UIScale, {
		PC = 1,
		Mobile = 1.1,
		Tablet = 1.1
	})
end