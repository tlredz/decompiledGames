local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = false
local v2 = Component.new({
	Tag = "AdIntegrationUGCTracking"
})

function v2:Construct()
	self._Janitor = Janitor.new()
	local AdIntegrationsController = require(ReplicatedStorage.Modules.Client.Ads.AdIntegrationsController)
	v = AdIntegrationsController
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tryAddAsset(assetId: number, uGCIntegrationNames)
	if assetId == 0 then
		return
	end

	local uGCIntegrationName = v.GetUGCIntegrationName(assetId)

	if uGCIntegrationName then
		uGCIntegrationNames[assetId] = uGCIntegrationName
	end
end

function v2:Start()
	local parent = self.Instance.Parent

	if not parent then
		return
	end

	local name = Players.LocalPlayer.Name

	if parent.Name ~= name then
		return
	end

	local instance = self.Instance
	self.player = Players:GetPlayerFromCharacter(instance.Parent)
	self.currentWearingHash = {}
	self._Janitor:Add(instance.ApplyDescriptionFinished:Connect(function(object)
		local v3 = {}

		for _, v4 in object:GetAccessories(true) do
			tryAddAsset(v4.AssetId, v3) -- equivalent call inferred; original call site unknown
		end

		local shirt = object.Shirt
		local v4 = shirt ~= 0 and v.GetUGCIntegrationName(shirt)

		if v4 then
			v3[shirt] = v4
		end

		local pants = object.Pants
		local v5 = pants ~= 0 and v.GetUGCIntegrationName(pants)

		if v5 then
			v3[pants] = v5
		end

		for k, _ in self.currentWearingHash do
			if v3[k] then
				continue
			end

			local v6 = self.currentWearingHash[k]
			v.HideAdLabel(v6)
			self.currentWearingHash[k] = nil
		end

		for k, v6 in v3 do
			if self.currentWearingHash[k] then
				continue
			end

			local displayAdLabel = v.DisplayAdLabel(v6)
			self.currentWearingHash[k] = displayAdLabel
		end
	end))
end

function v2:Stop()
	self._Janitor:Destroy()

	if not self.currentWearingHash then
		return
	end

	for k, _ in self.currentWearingHash do
		local v3 = self.currentWearingHash[k]
		v.HideAdLabel(v3)
	end
end

return v2