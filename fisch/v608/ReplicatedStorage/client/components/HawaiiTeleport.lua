local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local remoteFunction = Net:RemoteFunction("HawaiiTeleport/Request")
local module = require("../legacyControllers/HudController")
local module2 = require("../legacyControllers/PlayerController")
local v = Component.new({
	Tag = "HawaiiTeleport",
	Ancestors = { workspace }
})
local flag = false

function v:Construct()
	self.Trove = Trove.new()
end

function v.Start(p)
	p.Trove:Add(p.Instance.Touched:Connect(function(otherPart)
		local child = workspace.active.boats:FindFirstChild(localPlayer.Name)

		if not localPlayer.Character or otherPart.Parent ~= localPlayer.Character and not (child and otherPart:IsDescendantOf(child)) then
			return
		end

		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return
		end

		local currentCamera = workspace.CurrentCamera

		if not currentCamera or flag then
			return
		end

		flag = true
		local screenGui = Instance.new("ScreenGui")
		screenGui.ClipToDeviceSafeArea = false
		screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
		screenGui.ScreenInsets = Enum.ScreenInsets.None
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 999999999
		screenGui.Name = "fadeOverlay"
		local frame = Instance.new("Frame")
		frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 1)
		frame.Parent = screenGui
		screenGui.Parent = module:GetPlayerGui()
		TweenService:Create(frame, TweenInfo.new(2, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 0
		}):Play()
		TweenService:Create(currentCamera, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			FieldOfView = 40
		}):Play()
		currentCamera.CameraType = Enum.CameraType.Scriptable

		if not (p.Instance:FindFirstChild("EnterSwimEnd") and p.Instance.EnterSwimEnd.WorldPositoin) then
			local _ = p.Instance.Position
		end

		local hud = module:GetHud()
		hud.Enabled = false
		local deviceInsetGui = module:GetDeviceInsetGui()
		deviceInsetGui.Enabled = false
		local backpackGui = module:GetBackpackGui()
		backpackGui.Enabled = false
		humanoid:UnequipTools()
		task.wait(2)
		GuiService:SetGameplayPausedNotificationEnabled(false)

		if remoteFunction:InvokeServer(p.Instance) then
			task.wait(1)
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.FieldOfView = 70
			TweenService:Create(frame, TweenInfo.new(3, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 1
			}):Play()
			GuiService:SetGameplayPausedNotificationEnabled(true)
			task.wait(3)
			local hud_2 = module:GetHud()
			hud_2.Enabled = true
			local deviceInsetGui_2 = module:GetDeviceInsetGui()
			deviceInsetGui_2.Enabled = true
			local backpackGui_2 = module:GetBackpackGui()
			backpackGui_2.Enabled = true
			task.wait(2)
		else
			screenGui:Destroy()
			GuiService:SetGameplayPausedNotificationEnabled(true)
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.FieldOfView = 70
			module2:ToggleControls(true)
			local hud_3 = module:GetHud()
			hud_3.Enabled = true
			local deviceInsetGui_3 = module:GetDeviceInsetGui()
			deviceInsetGui_3.Enabled = true
			local backpackGui_3 = module:GetBackpackGui()
			backpackGui_3.Enabled = true
			task.wait(3)
		end

		flag = false
	end))
end

function v.Stop(p)
	p.Trove:Clean()
end

return v