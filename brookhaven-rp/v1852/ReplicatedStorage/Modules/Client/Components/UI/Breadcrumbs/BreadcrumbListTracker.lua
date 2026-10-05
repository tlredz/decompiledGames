local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "BreadcrumbListTracker"
})
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
require(GameSdkShared.Modules.ABTest)
local v2 = false
local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
local v3 = false
local v4 = false
local BreadcrumbConfig = require(ReplicatedStorage.Modules.Shared.DB.Breadcrumbs.BreadcrumbConfig)
local LoadableEntriesFilter = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableEntriesFilter)
local breadcrumbTemplate = nil

function v:Construct()
	self._Janitor = Janitor.new()
	self._breadcrumbJanitor = Janitor.new()
	breadcrumbTemplate = ReplicatedStorage:WaitForChild("UiClone"):WaitForChild("BreadcrumbTemplate")

	if not self.Instance:GetAttribute("ItemType") then
		warn("No item type found in the instance", self.Instance)
		return
	end

	self.OnValidateBreadcrumbs = Signal.new()
	self._Janitor:Add(self.OnValidateBreadcrumbs)
	self.markedItems = {}
	self.neverShowItems = {}
	v2 = v2 or require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
	v3 = v3 or require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v4 = v4 or require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
	local ancestorPanel = v3.GetAncestorPanelByInstance(self.Instance)

	if ancestorPanel then
		self._panel = ancestorPanel
	else
		warn("No panel found in the ancestry of the instance", self.Instance)
	end
end

function v.MarkItemViewed(p, p2: string)
	p.markedItems[p2] = true
	p.neverShowItems[p2] = true
end

function v:ApplyBreadcrumbs()
	self._breadcrumbJanitor:Cleanup()
	local breadcrumbItemType = LoadableEntriesFilter.ResolveBreadcrumbItemType(self.Instance:GetAttribute("ItemType"))
	local v5 = BreadcrumbConfig.GetConfig()[breadcrumbItemType]

	if not v5 then
		warn("No config found for item type", breadcrumbItemType)
		return
	end

	local v6 = v2.GetReplicatedDataPromise():andThen(function(p)
		if not p.breadcrumbs then
			return
		end

		for childName, _ in v5 do
			if self.neverShowItems[childName] or p.breadcrumbs[childName] then
				continue
			end

			local child = self.Instance:FindFirstChild(childName)

			if not (child and (not FeatureFlagsConfig.HasFeatureFlag(childName) or FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(
				game.Players.LocalPlayer,
				childName
			))) then
				continue
			end

			local clone = breadcrumbTemplate:Clone()
			clone.Name = childName
			clone:AddTag("Breadcrumb")
			clone.Parent = child
			self._breadcrumbJanitor:Add(clone)
		end

		local instance = self.Instance

		if instance then
			local total = 0
			local canvasPosition = instance.CanvasPosition
			local canvasPosition2 = canvasPosition
			local thread = nil
			self._breadcrumbJanitor:Add(instance.ChildAdded:Connect(function()
				if thread then
					return
				end

				thread = task.defer(function()
					self.OnValidateBreadcrumbs:Fire()
				end)
			end))
			self._breadcrumbJanitor:Add(instance.ChildRemoved:Connect(function()
				if thread then
					return
				end

				thread = task.defer(function()
					self.OnValidateBreadcrumbs:Fire()
				end)
			end))
			self._breadcrumbJanitor:Add(RunService.Stepped:Connect(function(_, dt)
				if canvasPosition == instance.CanvasPosition then
					return
				end

				if canvasPosition2 ~= instance.CanvasPosition then
					total = 0
					canvasPosition2 = instance.CanvasPosition
				end

				total += dt

				if total > 0.2 then
					self.OnValidateBreadcrumbs:Fire()
					total = 0
					canvasPosition = instance.CanvasPosition
				end
			end))
		end
	end)
	self._breadcrumbJanitor:AddPromise(v6)
end

function v.ForceValidateBreadcrumbs(p)
	p.OnValidateBreadcrumbs:Fire()
end

function v:RemoveBreadcrumbs()
	self._breadcrumbJanitor:Cleanup()

	if not next(self.markedItems) then
		return
	end

	Remotes.fireServer("MarkBreadcrumbsAsViewed", self.markedItems)
	self.markedItems = {}
end

function v:Start()
	if not self._panel then
		return
	end

	if self._panel:IsOpen() then
		self:ApplyBreadcrumbs()
	end

	self._panel:RegisterListener(self, "Opening", function()
		self:ApplyBreadcrumbs()
	end)
	self._Janitor:Add(LoadableEntriesFilter.OnPropsModuleResolved:Connect(function()
		if self.Instance:GetAttribute("ItemType") ~= "Props" then
			return
		end

		if self._panel:IsOpen() then
			self:ApplyBreadcrumbs()
		end
	end))
	self._panel:RegisterListener(self, "Closing", function()
		self:RemoveBreadcrumbs()
	end)
end

function v:Stop()
	if self._panel then
		self._panel:UnregisterListener(self, "Opening")
		self._panel:UnregisterListener(self, "Closing")
	end

	self._Janitor:Destroy()
	self._breadcrumbJanitor:Destroy()
end

return v