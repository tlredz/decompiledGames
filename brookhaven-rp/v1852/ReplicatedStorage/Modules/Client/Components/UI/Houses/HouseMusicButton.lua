local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HouseTelemetry = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseTelemetry)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseMusicButton"
})
local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	local visible = false
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		HouseTelemetry.Click(self.Tag)

		if PanelController.IsOpen("MainGUIHandler", "MainAudio") then
			PanelController.Close("MainGUIHandler", "MainAudio")
			return
		end

		visible = true
		PanelController.ToggleGroup("HousePanels", false)
		MusicController.OpenMusicMenu("HouseMusicButton", AdFeatures.HOUSE_MUSIC)
	end))
	local greenCheckMark = self.Instance:FindFirstChild("GreenCheckMark")

	if not greenCheckMark then
		return
	end

	local v3 = PanelController.WaitForPanel("MainGUIHandler", "MainAudio")
	self._Janitor:Add(v3.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if v3.Visible then
			return
		end

		greenCheckMark.Visible = v3.Visible
	end))
	self._Janitor:Add(PanelController.OnPanelOpened:Connect(function(_: string, p: string)
		if p == "MainAudio" then
			greenCheckMark.Visible = visible
			visible = false
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v