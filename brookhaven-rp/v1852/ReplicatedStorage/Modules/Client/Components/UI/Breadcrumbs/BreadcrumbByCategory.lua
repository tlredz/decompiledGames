local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "BreadcrumbByCategory"
})
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v2 = false
local v3 = false
local v4 = false
local BreadcrumbConfig = require(ReplicatedStorage.Modules.Shared.DB.Breadcrumbs.BreadcrumbConfig)
local LoadableEntriesFilter = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableEntriesFilter)
local breadcrumbTemplate = nil

function v:Construct()
	self._Janitor = Janitor.new()
	self._breadcrumbJanitor = Janitor.new()
	breadcrumbTemplate = ReplicatedStorage:WaitForChild("UiClone"):WaitForChild("BreadcrumbTemplate")
	local itemType = self.Instance:GetAttribute("ItemType")

	if not itemType then
		warn("No item type found in the instance", self.Instance)
		return
	end

	task.defer(function()
		local v5, v6 = ABTest.GetExperimentVariable("item-surfacing", "breadcrumbs-enabled"):timeout(3):await()

		if v5 and not v6 then
			self.Instance:RemoveTag("BreadcrumbByCategory")
			return
		end

		local breadcrumbItemType = LoadableEntriesFilter.ResolveBreadcrumbItemType(itemType)
		local v7 = BreadcrumbConfig.GetConfig()[breadcrumbItemType]

		if v7 and not next(v7) then
			self.Instance:RemoveTag("BreadcrumbByCategory")
		end
	end)
	self.OnValidateBreadcrumbs = Signal.new()
	self._Janitor:Add(self.OnValidateBreadcrumbs)
	self.markedItems = {}
	self.neverShowItems = {}
	v2 = v2 or require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
	v3 = v3 or require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v4 = v4 or require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
	local ancestorPanel = v3.GetAncestorPanelByInstance(self.Instance)

	if not ancestorPanel then
		return
	end

	self._panel = ancestorPanel
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

		local flag = false

		for k, _ in v5 do
			if self.neverShowItems[k] or p.breadcrumbs[k] then
				continue
			end

			flag = true
			break
		end

		if flag then
			local clone = breadcrumbTemplate:Clone()
			clone.Name = breadcrumbItemType .. "Breadcrumb"
			clone:AddTag("Breadcrumb")
			clone.Parent = self.Instance
			self._breadcrumbJanitor:Add(clone)
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
	self._Janitor:Add(LoadableEntriesFilter.OnPropsModuleResolved:Connect(function()
		if self.Instance:GetAttribute("ItemType") ~= "Props" then
			return
		end

		if not self._panel or self._panel:IsOpen() then
			self:ApplyBreadcrumbs()
		end
	end))

	if not self._panel then
		self:ApplyBreadcrumbs()
		return
	end

	if self._panel and self._panel:IsOpen() then
		self:ApplyBreadcrumbs()
	end

	if self._panel then
		self._panel:RegisterListener(self, "Opening", function()
			self:ApplyBreadcrumbs()
		end)
		self._panel:RegisterListener(self, "Closing", function()
			self:RemoveBreadcrumbs()
		end)
	end
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