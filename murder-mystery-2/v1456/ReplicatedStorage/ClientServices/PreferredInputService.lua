local PreferredInputService = {}
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local v = nil
local large = nil
local v2 = {
	Small = "Small",
	Medium = "Medium",
	Large = "Large"
}
local _ = {
	KeyboardAndMouse = "KeyboardAndMouse",
	Gamepad = "Gamepad",
	Touch = "Touch"
}
PreferredInputService.DeviceUpdated = Instance.new("BindableEvent")

function PreferredInputService.GetDeviceInfo(_)
	return v, large
end

local function updateScreenSize()
	if GuiService:IsTenFootInterface() then
		large = "Large"
	elseif workspace.CurrentCamera.ViewportSize.Y >= 600 then
		large = "Medium"
	else
		large = "Small"
	end
end

local function onPreferredInputChanged()
	if GuiService:IsTenFootInterface() then
		large = v2.Large
	elseif workspace.CurrentCamera.ViewportSize.Y >= 600 then
		large = v2.Medium
	else
		large = v2.Small
	end

	local preferredInput = UserInputService.PreferredInput

	if isStudio and UserInputService.TouchEnabled then
		v = "Touch"
	elseif preferredInput == Enum.PreferredInput.KeyboardAndMouse then
		v = "KeyboardAndMouse"
	elseif preferredInput == Enum.PreferredInput.Gamepad then
		v = "Gamepad"
	elseif preferredInput == Enum.PreferredInput.Touch then
		v = "Touch"
	end

	PreferredInputService.DeviceUpdated:Fire()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onInitialize()
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(onPreferredInputChanged)
	onPreferredInputChanged()
end

onInitialize() -- equivalent call inferred; original call site unknown
return PreferredInputService