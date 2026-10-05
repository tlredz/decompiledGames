local vector = Vector2.new(768, 1024)
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local KeybindImages = require(script:WaitForChild("KeybindImages"))
local v = {
	Large = "Large",
	Medium = "Medium",
	Small = "Small"
}
local large = "Medium"
local keyboardAndMouse = Enum.PreferredInput.KeyboardAndMouse
local v2 = nil

local function GetScreenSize()
	if GuiService:IsTenFootInterface() then
		return "Large"
	end

	if mouse.ViewSizeX >= vector.X and mouse.ViewSizeY >= vector.Y then
		return "Medium"
	end

	return "Small"
end

local function onPreferredInputChanged()
	keyboardAndMouse = UserInputService.PreferredInput

	if keyboardAndMouse == Enum.PreferredInput.Touch and v2 == nil then
		task.spawn(function()
			v2 = localPlayer.PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton").Size == UDim2.new(
				0,
				120,
				0,
				120
			)
		end)
	end

	if keyboardAndMouse == Enum.PreferredInput.KeyboardAndMouse then
		local tagged = CollectionService:GetTagged("KeybindIcon")

		for _, v3 in tagged do
			v3.Image = KeybindImages.KeyboardButton
			v3.TextLabel.Visible = true
		end
	elseif keyboardAndMouse == Enum.PreferredInput.Gamepad then
		local tagged = CollectionService:GetTagged("KeybindIcon")

		for _, v3 in tagged do
			v3.Image = KeybindImages[UserInputService:GetStringForKeyCode(v3:GetAttribute("Keybind_Gamepad"))]
			v3.TextLabel.Visible = false
		end
	end
end

local DeviceService = {
	IsMobileDevice = function(_)
		return keyboardAndMouse == Enum.PreferredInput.Touch
	end,
	GetDeviceInfo = function(_)
		return keyboardAndMouse, large
	end
}

local function onInitialize()
	local large2

	if GuiService:IsTenFootInterface() then
		large2 = v.Large
	elseif mouse.ViewSizeX >= vector.X and mouse.ViewSizeY >= vector.Y then
		large2 = v.Medium
	else
		large2 = v.Small
	end

	large = large2
	onPreferredInputChanged()
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(onPreferredInputChanged)
end

if GuiService:IsTenFootInterface() then
	large = v.Large
elseif mouse.ViewSizeX >= vector.X and mouse.ViewSizeY >= vector.Y then
	large = v.Medium
else
	large = v.Small
end

onPreferredInputChanged()
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(onPreferredInputChanged)
return DeviceService