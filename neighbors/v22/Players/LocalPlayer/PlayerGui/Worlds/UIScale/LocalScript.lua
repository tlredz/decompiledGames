local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(ReplicatedStorage.Modules.UI)
local frame = script.Parent.Parent.Frame

if UI:GetDeviceType() == "Mobile" then
	UI:FillFrameToMaxHeight(frame, frame.UIScale, 10)
else
	UI:RegisterUIScale(script.Parent, {
		PC = 1.6,
		Mobile = 1.515625,
		Tablet = 1.8
	})
end