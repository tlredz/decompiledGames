local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
local v = Component.new({
	Tag = "MusicNoMotorVehicle",
	Extensions = {
		{
			ShouldConstruct = function(p)
				local character = Players.LocalPlayer.Character

				if not character then
					return false
				end

				if p.Instance:IsDescendantOf(character) then
					return true
				end

				local playerObject = p.Instance:WaitForChild("PlayerObject", 4)

				if playerObject then
					return playerObject.Value == Players.LocalPlayer
				end

				return false
			end
		}
	}
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._vehicleName = self.Instance:GetAttribute("vehicleName")
end

function v:Start()
	MusicController.EnableSettingsUI(self._vehicleName)
end

function v:Stop()
	MusicController.DisableSettingsUI(self._vehicleName)
	self._Janitor:Destroy()
end

return v