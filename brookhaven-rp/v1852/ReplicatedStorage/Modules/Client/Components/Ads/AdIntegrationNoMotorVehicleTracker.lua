local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AdIntegrationsController = require(ReplicatedStorage.Modules.Client.Ads.AdIntegrationsController)
local v = Component.new({
	Tag = "AdIntegrationNoMotorVehicleTracker",
	Extensions = {
		{
			ShouldConstruct = function(p)
				return p.Instance:WaitForChild("PlayerObject").Value == Players.LocalPlayer
			end
		}
	}
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local integrationName = self.Instance:GetAttribute("integrationName")

	if not integrationName then
		return
	end

	self.hashAdIntegration = AdIntegrationsController.DisplayAdLabel(integrationName)
end

function v:Stop()
	if self.hashAdIntegration then
		AdIntegrationsController.HideAdLabel(self.hashAdIntegration)
		self.hashAdIntegration = nil
	end

	self._Janitor:Destroy()
end

return v