local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HousePartySelectionButton"
})
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local Players2 = game:GetService("Players")
	local localPlayer = Players2.LocalPlayer
	local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
	local HouseUtil = require(ReplicatedStorage.Modules.Shared.Game.HouseUtil)
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
	local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
	local value = PlayerBagUtil.GetPlayerBagInstance(localPlayer, "HouseNumber").Value

	if HouseUtil.GetHouseType(value) ~= "House" then
		self.Instance.Visible = false
		return
	end

	local propertyRoot = LotUtil.GetPropertyRoot(value)

	if propertyRoot == nil then
		self.Instance.Visible = false
		return
	end

	local instance = propertyRoot.Instance

	if not instance:FindFirstChild("InsertedAfterSpawn") then
		self.Instance.Visible = false
		return
	end

	if not instance.InsertedAfterSpawn:FindFirstChild("ThemeLayers") then
		self.Instance.Visible = false
		return
	end

	if not propertyRoot.Instance.InsertedAfterSpawn.ThemeLayers:FindFirstChild("Party") then
		self.Instance.Visible = false
		return
	end

	PanelController.LoadLazy("MainGUIHandler", "PartyStart", false)
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)

		if PanelController.IsOpen("MainGUIHandler", "PartySelect") then
			PanelController.Close("MainGUIHandler", "PartySelect")
		elseif PanelController.IsOpen("MainGUIHandler", "PartyStart") then
			PanelController.Close("MainGUIHandler", "PartyStart")
		elseif ReplicatedDataController.GetSessionReplicaPromise():expect().Data.Party then
			ComponentUtil.FindAndWaitForComponentByTag(nil, "PartySelect", false):WaitForInstance(Players.LocalPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("PartySelect")):expect():SetPreviousPanel(nil)
			PanelController.ToggleGroup("HousePanels", false)
			PanelController.OpenPanelByContext("MainGUIHandler", "PartySelect")
		else
			PanelController.ToggleGroup("HousePanels", false)
			PanelController.OpenPanelByContext("MainGUIHandler", "PartyStart")
		end
	end))
	self._Janitor:Add(PanelController.OnPanelOpened:Connect(function(p: string, p2: string)
		if p == "MainGUIHandler" and (p2 == "PartyStart" or p2 == "PartySelect") then
			self.Instance.GreenCheckMark.Visible = true
		end
	end))
	self._Janitor:Add(PanelController.OnPanelClosed:Connect(function(p: string, p2: string)
		if p == "MainGUIHandler" and (p2 == "PartyStart" or p2 == "PartySelect") then
			self.Instance.GreenCheckMark.Visible = false
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v