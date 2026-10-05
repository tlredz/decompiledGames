local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdService = game:GetService("AdService")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
require(ReplicatedStorage.Modules.Shared.DB.AdIntegrations.AdIntegrationsConfig)
local Promise = require(ReplicatedStorage.Packages.Promise)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local GameConstants = require(ReplicatedStorage.Modules.Shared.Game.GameConstants)
local v = Component.new({
	Tag = "AdIntegrationLabel"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._InitJanitor = Janitor.new()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isCampaignEligible(campaignID: string)
	if not campaignID then
		return false
	end

	local success, campaignEligibilityAsync = pcall(AdService.GetCampaignEligibilityAsync, AdService, campaignID)

	if not success then
		return false
	end

	if campaignEligibilityAsync.IsEligible then
		return true
	end

	return false
end

function v:SetupLabel()
	if self.isInitialized then
		return
	end

	self.isInitialized = true
	self.icon = self.Instance:WaitForChild("Icon")
	self.adButton = self.Instance:WaitForChild("Ad"):WaitForChild("AdButton")
	self.adButton.Visible = false
end

function v:Start()
	self:SetupLabel()
end

function v:Init(name: string, config)
	self.name = name
	self.config = config
	self:SetupLabel()
	self.icon.Image = config.Icon

	if self.tempAdButton then
		self.tempAdButton:Destroy()
	end

	self._InitJanitor:Cleanup()
	self.tempAdButton = self.adButton:Clone()
	self.tempAdButton.Parent = self.adButton.Parent
	self.tempAdButton.Visible = true
	self.isCampaignEligible = false

	-- equivalent call inferred; original call site unknown
	if isCampaignEligible(self.config.CampaignID) then
		self.isCampaignEligible = true
		Promise.new(function(callback)
			AdService:RegisterDisclosureButton(self.tempAdButton, self.config.PlacementID)
			callback()
		end):andThen(function() end):catch(function(p)
			warn((`AdIntegrationLabel: Failed to register disclosure button for campaign {self.config.CampaignID} and ad placement {self.config.PlacementID}: {p}`))
		end)
	else
		self._InitJanitor:Add(self.tempAdButton.Activated:Connect(function()
			if not GameConstants.PlaceIds.Live[game.PlaceId] then
				NotificationController.NotifyCenter("Ad integrations are only available in the live experience.")
			end
		end))
		RunService:IsStudio()
	end
end

function v:Stop()
	self._Janitor:Destroy()
	self._InitJanitor:Destroy()
end

return v