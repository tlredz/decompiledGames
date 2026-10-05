local UserInputService = game:GetService("UserInputService")
local UI = require(game.ReplicatedStorage.Modules.UI)
local parent = script.Parent

local function update()
	local deviceType = UI:GetDeviceType()

	if deviceType == "Tablet" then
		parent.Scale = 1.2
	elseif deviceType == "Mobile" then
		parent.Scale = 1.4
	else
		parent.Scale = 1
	end
end

local deviceType = UI:GetDeviceType()

if deviceType == "Tablet" then
	parent.Scale = 1.2
elseif deviceType == "Mobile" then
	parent.Scale = 1.4
else
	parent.Scale = 1
end

UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(update)