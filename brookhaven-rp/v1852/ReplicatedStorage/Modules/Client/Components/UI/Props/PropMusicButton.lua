local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropMusicButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
	local props = LegacyGame8Settings.Props
	local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
	local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)

	if self.Instance:IsA("ImageButton") then
		self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
			MusicController.OpenMusicMenu("PropMusicButton", AdFeatures.PROP_MUSIC)
		end))
		self._Janitor:Add(props.OnClientEvent:Connect(function(p2)
			if p2 == "ShowPropMusicButton" then
				self.Instance.Visible = true
			elseif p2 == "HidePropMusicButton" then
				self.Instance.Visible = false
			end
		end))
	elseif self.Instance:IsA("ClickDetector") then
		self._Janitor:Add(self.Instance.MouseClick:Connect(function()
			MusicController.OpenMusicMenu("PropMusicButton", AdFeatures.PROP_MUSIC)
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v