local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local emit = require(packages.emit)
local Net = require(ReplicatedStorage.packages.Net)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local remoteEvent = Net:RemoteEvent("EmitVfx", -1)
local v = Component.new({
	Tag = "ImmediateEmit",
	Ancestors = { Workspace }
})

function v.Construct(_) end

function v.Start(p)
	if p.Instance:GetAttribute("PlayerId") and p.Instance:GetAttribute("PlayerId") ~= localPlayer.UserId and SettingsController:GetSettingValue("shownVfx") ~= "All" then
		return
	end

	emit.emit(p.Instance)

	for _, sound in p.Instance:GetDescendants() do
		if sound:IsA("Sound") then
			sound:Play()
		end
	end
end

function v.Stop(_) end

remoteEvent.OnClientEvent:Connect(function(value)
	if typeof(value) == "Instance" then
		emit.emit(value)
	elseif typeof(value) == "table" then
		for _, item in value do
			if typeof(item) == "Instance" then
				emit.emit(item)
			end
		end
	end
end)
return v