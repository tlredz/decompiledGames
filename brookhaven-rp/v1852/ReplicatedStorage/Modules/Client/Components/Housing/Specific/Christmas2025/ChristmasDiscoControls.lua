local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local PropertyPermissions = require(ReplicatedStorage.Modules.Client.Components.Housing.PropertyPermissions)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local v = Component.new({
	Tag = "ChristmasDiscoControls"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local openMusicMenu = self.Instance:WaitForChild("ControlPanel"):WaitForChild("OpenMusicMenu")
	self.debounce = false
	self._Janitor:Add(openMusicMenu:WaitForChild("ClickDetector").MouseClick:Connect(function(p)
		if self.debounce then
			return
		end

		self.debounce = true
		task.delay(0.2, function()
			self.debounce = false
		end)
		local component = ComponentUtil.FindComponentByAncestor(
			self.Instance,
			"PropertyPermissions",
			PropertyPermissions
		)

		if component and not component:HasAnyRole(p, "Owner", "Roommate") then
			NotificationController.NotifyCenter("You don't have permission to do that")
			return
		end

		if PanelController.IsOpen("MainGUIHandler", "MainAudio") then
			PanelController.Close("MainGUIHandler", "MainAudio")
			return
		end

		if PanelController.IsRegistered("MainGUIHandler", "HouseSign") then
			PanelController.ToggleGroup("HousePanels", false)
		end

		local POI_AUDIO = self.Instance:FindFirstChild("POI_AUDIO")

		if POI_AUDIO then
			MusicController.OpenMusicMenu("ChristmasDisco", AdFeatures.HOUSE_MUSIC, "GenericBoombox", POI_AUDIO.Sound)
		else
			MusicController.OpenMusicMenu("ChristmasDisco", AdFeatures.HOUSE_MUSIC)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v