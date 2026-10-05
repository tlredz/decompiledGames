local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AdIntegrationsController = require(ReplicatedStorage.Modules.Client.Ads.AdIntegrationsController)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "AdIntegrationTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local adIntegrationName = self.Instance:GetAttribute("AdIntegrationName")

	if not adIntegrationName then
		warn("AdIntegrationTool:Start() - No integration name found")
		return
	end

	self.currentLabelHash = nil
	self._Janitor:Add(instance.Equipped:Connect(function()
		local playerFromCharacter = Players:GetPlayerFromCharacter(instance.Parent)

		if not (playerFromCharacter ~= nil and playerFromCharacter == Players.LocalPlayer) then
			return
		end

		if self.currentLabelHash then
			AdIntegrationsController.HideAdLabel(self.currentLabelHash)
			self.currentLabelHash = nil
		end

		self.currentLabelHash = AdIntegrationsController.DisplayAdLabel(adIntegrationName)
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		if self.currentLabelHash then
			AdIntegrationsController.HideAdLabel(self.currentLabelHash)
			self.currentLabelHash = nil
		end
	end))
end

function v:Stop()
	if self.currentLabelHash then
		AdIntegrationsController.HideAdLabel(self.currentLabelHash)
		self.currentLabelHash = nil
	end

	self._Janitor:Destroy()
end

return v