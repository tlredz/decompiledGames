_G.MobileShiftlock = false
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local UserInputService = game:GetService("UserInputService")
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local _ = workspace.CurrentCamera
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local parent = script.Parent
local lockIcon = script.Parent.Parent.MiddleFrame.LockIcon
local v = 1
local cframe = CFrame.new(1.75, 0, 0)
CFrame.new(-1.75, 0, 0)
local _ = {
	Off = "rbxasset://textures/ui/mouseLock_off@2x.png",
	On = "rbxasset://textures/ui/mouseLock_on@2x.png",
	Lock = "rbxasset://textures/MouseLockedCursor.png"
}
local v2 = {
	White = Color3.new(1, 1, 1),
	Green = Color3.new(0.333333, 1, 0),
	Purple = Color3.new(0.666667, 0.333333, 1)
}
parent.Image = "rbxasset://textures/ui/mouseLock_off@2x.png"
parent.ImageColor3 = v2.White
lockIcon.Visible = false

if UserInputService.TouchEnabled == false then
	return
end

local function UpdateAutoRotate(autoRotate)
	humanoid.AutoRotate = autoRotate
end

parent.Activated:Connect(function()
	if v < 3 then
		v += 1
	else
		v = 1
	end

	if v == 1 then
		parent.Image = "rbxasset://textures/ui/mouseLock_off@2x.png"
		parent.ImageColor3 = v2.White
		lockIcon.Visible = false
	end

	if v == 2 then
		parent.Image = "rbxasset://textures/ui/mouseLock_on@2x.png"
		lockIcon.Visible = false
	end

	if v == 3 then
		parent.Image = "rbxasset://textures/ui/mouseLock_off@2x.png"
		parent.ImageColor3 = v2.Purple
		lockIcon.Visible = true
	end
end)
RunService:BindToRenderStep("Mobile_Shiftlock", Enum.RenderPriority.Camera.Value + 1, function()
	if v >= 2 then
		UserGameSettings.RotationType = Enum.RotationType.CameraRelative
		local currentCamera = workspace.CurrentCamera

		if currentCamera and (currentCamera.Focus.Position - currentCamera.CFrame.Position).Magnitude >= 0.99 then
			currentCamera.CFrame *= cframe
			currentCamera.Focus = CFrame.fromMatrix(
				currentCamera.Focus.Position,
				currentCamera.CFrame.RightVector,
				currentCamera.CFrame.UpVector
			) * cframe
		end

		if v == 3 and _G.MobileShiftlock == false then
			_G.MobileShiftlock = true
		end
	else
		if _G.MobileShiftlock == true then
			_G.MobileShiftlock = false
		end

		UserGameSettings.RotationType = Enum.RotationType.MovementRelative
	end
end)