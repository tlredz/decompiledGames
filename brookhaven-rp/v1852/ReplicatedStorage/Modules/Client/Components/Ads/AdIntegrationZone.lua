local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AdIntegrationsController = require(ReplicatedStorage.Modules.Client.Ads.AdIntegrationsController)
local Timer = require(ReplicatedStorage.Packages.Timer)
local BasePartUtil = require(ReplicatedStorage.Modules.Shared.Utils.BasePartUtil)
local v = Component.new({
	Tag = "AdIntegrationZone"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function isLocalPlayerInZone(instance)
	local character = Players.LocalPlayer.Character

	if character == nil then
		return false
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	return BasePartUtil.isPointInPart(instance, humanoidRootPart.Position)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.integrationName = self.Instance:GetAttribute("Name")
	self._timer = Timer.new(1)
	self.isPlayerInZone = false
	self.currentLabelHash = nil
	self._Janitor:Add(self._timer.Tick:Connect(function()
		local localPlayerInZone = isLocalPlayerInZone(self.Instance) -- equivalent call inferred; original call site unknown

		if localPlayerInZone == self.isPlayerInZone then
			return
		end

		self.isPlayerInZone = localPlayerInZone

		if localPlayerInZone then
			if not self.currentLabelHash then
				self.currentLabelHash = AdIntegrationsController.DisplayAdLabel(self.integrationName)
			end
		else
			AdIntegrationsController.HideAdLabel(self.currentLabelHash)
			self.currentLabelHash = nil
		end
	end))
	self._Janitor:Add(self._timer)
	self._timer:Start()
end

function v:Stop()
	if self.currentLabelHash then
		AdIntegrationsController.HideAdLabel(self.currentLabelHash)
	end

	self._Janitor:Destroy()
end

return v