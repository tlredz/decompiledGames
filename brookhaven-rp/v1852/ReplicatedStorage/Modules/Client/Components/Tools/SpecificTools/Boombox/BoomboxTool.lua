local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local MusicController = require(ReplicatedStorage.Modules.Client.Music.MusicController)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "BoomboxTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("Tool") then
		warn("BoomboxTool component not on Tool!")
		return
	end

	self._Janitor:Add(instance.Equipped:Connect(function()
		if instance.Parent == localPlayer.Backpack or instance.Parent == localPlayer.Character then
			MusicController.EnableSettingsUI("Boombox")
		end
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		if instance.Parent == localPlayer.Backpack or instance.Parent == localPlayer.Character then
			MusicController.DisableSettingsUI("Boombox")
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v