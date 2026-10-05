local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseCameraButton"
})
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local HousePanel = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HousePanel)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
local Players = game:GetService("Players")
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
local localPlayer = Players.LocalPlayer
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"HousePanel",
		HousePanel
	)

	if not waitForAncestorComponent then
		return
	end

	local playerBagInstance = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber")
	local value = playerBagInstance and playerBagInstance.Value
	local v2 = value and LotUtil.GetPropertyRoot(value)

	if v2 == nil or v2:GetCameras()[1] == nil then
		self.Instance.Visible = false
		return
	end

	local function resolvePanel()
		local panel = self.Instance:FindFirstChild("Panel")

		if panel and panel:IsA("ObjectValue") and panel.Value and panel.Value:IsA("GuiObject") then
			return panel.Value
		end

		local cam = waitForAncestorComponent.Instance:FindFirstChild("Cam")

		if cam and cam:IsA("GuiObject") then
			return cam
		end

		return nil
	end

	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)
		local playerBagInstance2 = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber")
		local value2 = playerBagInstance2 and playerBagInstance2.Value
		local v3 = value2 and LotUtil.GetPropertyRoot(value2)

		if not v3 then
			warn("Property root not found")
			return
		end

		self.panel = resolvePanel()

		if not self.panel then
			warn("House camera panel not found (expected ObjectValue 'Panel' or child named 'Cam')")
			return
		end

		local v4 = v3:GetCameras()[1] ~= nil
		local v5 = false

		for _, descendant in v3.Instance:GetDescendants() do
			if not descendant:HasTag("CameraDoorbell") then
				continue
			end

			local camera = descendant:FindFirstChild("Camera")

			if not (camera ~= nil and camera:IsA("BasePart")) then
				continue
			end

			v5 = true
			break
		end

		if v4 == false and v5 == false then
			NotificationController.Notify("No cameras installed")
			return
		end

		PanelController.ToggleGroup("HousePanels", false)
		waitForAncestorComponent:SetCurrentOpenPanel(self.panel)
	end))
	self.panel = resolvePanel()

	if not self.panel then
		warn("House camera panel not found on start")
		return
	end

	self.panel:AddTag("Panel")
	self._Janitor:Add(PanelController.OnPanelClosed:Connect(function(_: string, p: string)
		if p == "HouseControlPanel" then
			CameraController.SetDefaultCamera()
			waitForAncestorComponent:CloseCurrentOpenPanel()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v