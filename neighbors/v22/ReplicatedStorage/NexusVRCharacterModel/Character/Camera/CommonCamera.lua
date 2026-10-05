local Workspace = game:GetService("Workspace")
local VRService = game:GetService("VRService")
local parent = script.Parent.Parent.Parent
local Settings = require(parent:WaitForChild("State"):WaitForChild("Settings"))
local instance = Settings.GetInstance()
local CommonCamera = {}
CommonCamera.__index = CommonCamera

function CommonCamera.new()
	return (setmetatable({}, CommonCamera))
end

function CommonCamera.Enable(_) end

function CommonCamera.Disable(_) end

function CommonCamera.UpdateCamera(_, _: CFrame) end

function CommonCamera.SetCFrame(_, cframe: CFrame)
	local currentCamera = Workspace.CurrentCamera

	if instance:GetSetting("Camera.DisableHeadLocked") ~= false then
		currentCamera.HeadLocked = false
	end

	if currentCamera.HeadLocked then
		local userCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
		cframe *= (CFrame.new(userCFrame.Position * (Workspace.CurrentCamera.HeadScale - 1)) * userCFrame):Inverse()
		currentCamera.VRTiltAndRollEnabled = true
	end

	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = cframe
	currentCamera.Focus = cframe
end

return CommonCamera