local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local HouseCameraView = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseCameraView)
local DoorbellRingPrompt = require(ReplicatedStorage.Modules.Client.UI.Houses.DoorbellRingPrompt)
local v = Component.new({
	Tag = "CameraDoorbell"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.SetSharedViewEffects(enabled: boolean)
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

	if playerGui ~= nil then
		local doorbellCameraVignette = playerGui:FindFirstChild("DoorbellCameraVignette")

		if doorbellCameraVignette ~= nil and doorbellCameraVignette:IsA("ScreenGui") then
			doorbellCameraVignette.Enabled = enabled
		end
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera ~= nil then
		currentCamera.FieldOfView = enabled and 120 or 70
	end
end

function v:Start()
	self.camera = self.Instance:WaitForChild("Camera")
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "DoorbellRing", function(p: number)
		if DoorbellRingPrompt.AreNotificationsHidden() == true then
			return
		end

		local v2 = DoorbellRingPrompt:GetAll()[1]

		if v2 == nil then
			return
		end

		v2:Show(p, function()
			HouseCameraView.OpenWithCamera(self.camera, function()
				v.SetSharedViewEffects(false)
			end)
		end)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v