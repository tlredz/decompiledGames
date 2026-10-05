local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdService = game:GetService("AdService")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local GameConstants = require(ReplicatedStorage.Modules.Shared.Game.GameConstants)
local v = Component.new({
	Tag = "AdDisclosureButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
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

function v:Start()
	local campaignID = self.Instance:GetAttribute("CampaignID")
	local placementID = self.Instance:GetAttribute("PlacementID")
	local instance = self.Instance

	-- equivalent call inferred; original call site unknown
	if isCampaignEligible(campaignID) then
		self.isCampaignEligible = true
		Promise.new(function(callback)
			AdService:RegisterDisclosureButton(instance, placementID)
			callback()
		end):andThen(function() end):catch(function(p)
			warn((`AdDisclosureButton: Failed to register disclosure button for campaign {campaignID} and ad placement {placementID}: {p}`))
		end)
	else
		self._Janitor:Add(instance.Activated:Connect(function()
			if GameConstants.PlaceIds.Live.Live == game.PlaceId then
				warn("Ad integrations are only available in the live experience.")
			else
				NotificationController.NotifyCenter("Ad integrations are only available in the live experience.")
			end
		end))
		RunService:IsStudio()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v