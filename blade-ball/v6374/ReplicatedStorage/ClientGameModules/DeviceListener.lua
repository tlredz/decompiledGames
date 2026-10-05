local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local v2 = require3(ReplicatedStorage3.Shared.Statable)
local v3 = require3(ReplicatedStorage3.Packages.Signal)
local currentCamera = workspace.CurrentCamera
local playerGui = Players.LocalPlayer.PlayerGui
local DeviceListener = {
	Device = "PC",
	State = v2.State("PC"),
	OnChange = v3.new(),
	IsMobile = function(p)
		return p.Device == "Tablet" or p.Device == "Phone"
	end,
	RegisterDeviceChanged = function(p, onOnChange)
		assert(typeof(onOnChange) == "function", "Argument \"callback\" must be a function!")
		return p.OnChange:Connect(onOnChange)
	end,
	Observe = function(p, onOnChange)
		assert(typeof(onOnChange) == "function", "Argument \"callback\" must be a function!")
		task.spawn(onOnChange, p.Device)
		return p.OnChange:Connect(onOnChange)
	end
}

local function getDevice()
	local lastInputType = v:GetLastInputType()

	if lastInputType.Name:find("Gamepad") or GuiService:IsTenFootInterface() then
		return "Console"
	end

	if v.MouseEnabled and v.KeyboardEnabled then
		return "PC"
	end

	if GuiService.TouchControlsEnabled or v.TouchEnabled then
		if currentCamera.ViewportSize.Y <= 500 or playerGui.ScreenOrientation == Enum.ScreenOrientation.Portrait then
			return "Phone"
		end

		if v.TouchEnabled and not (v.KeyboardEnabled or v.GamepadEnabled or GuiService:IsTenFootInterface()) or v.TouchEnabled and lastInputType == Enum.UserInputType.Touch then
			return "Tablet"
		end
	end

	if not v.TouchEnabled then
		return "PC"
	end

	if currentCamera.ViewportSize.Y <= 500 then
		return "Phone"
	end

	return "Tablet"
end

local function updateDevice()
	local device = getDevice()

	if device ~= DeviceListener.Device then
		DeviceListener.Device = device
		DeviceListener.State:Set(device)
		DeviceListener.OnChange:Fire(device)
	end
end

v.LastInputTypeChanged:Connect(updateDevice)
currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateDevice)
playerGui:GetPropertyChangedSignal("ScreenOrientation"):Connect(updateDevice)
task.spawn(updateDevice)
return DeviceListener