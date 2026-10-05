local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseViewCamera = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseViewCamera)
local YoungRoddoController = require(ReplicatedStorage.Modules.Client.LiveOps.YoungRoddoController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local YoungRoddoUtil = require(ReplicatedStorage.Modules.Shared.LiveOps.YoungRoddoUtil)
local v = nil
local v2 = Component.new({
	Tag = "YoungRoddoInvite"
})

function v2:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function v2:Start()
	local outerBox = self.Instance:WaitForChild("OuterBox")
	local frame = outerBox:WaitForChild("Items"):WaitForChild("Frame")
	local teleport = frame:WaitForChild("Teleport")
	local decline = frame:WaitForChild("Decline")
	self._Janitor:Add(teleport.Activated:Connect(function()
		TelemetryController.SendClientInteraction("youngRoddoInvite", {
			accepted = true
		})
		HouseViewCamera.TeleportLot(YoungRoddoUtil.Config.LOT)
		v.Close("MainGUIHandler", "YoungRoddoInvite")
	end))
	local box = outerBox:WaitForChild("HideInvites"):WaitForChild("Box")
	self._Janitor:Add(box.Activated:Connect(function()
		YoungRoddoController.SuppressInvites = not YoungRoddoController.SuppressInvites

		if YoungRoddoController.SuppressInvites then
			box:AddTag("Checked")
		else
			box:RemoveTag("Checked")
		end
	end))
	self._Janitor:Add(decline.Activated:Connect(function()
		TelemetryController.SendClientInteraction("youngRoddoInvite", {
			accepted = false
		})
		v.Close("MainGUIHandler", "YoungRoddoInvite")
	end))
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2