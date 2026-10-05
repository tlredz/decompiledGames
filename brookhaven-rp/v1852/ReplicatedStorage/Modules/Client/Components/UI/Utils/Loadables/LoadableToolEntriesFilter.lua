local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local ToolsConfig = require(ReplicatedStorage.Modules.Shared.DB.Tools.ToolsConfig)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local DatabaseRemoteConfigController = require(ReplicatedStorage.Modules.Client.Databases.DatabaseRemoteConfigController)
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local FilterableItem = require(ReplicatedStorage.Modules.Shared.Item.FilterableItem)
local Item = require(ReplicatedStorage.Modules.Shared.Item.Item)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local BreadcrumbListTracker = require(ReplicatedStorage.Modules.Client.Components.UI.Breadcrumbs.BreadcrumbListTracker)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local v = Component.new({
	Tag = "LoadableToolEntriesFilter"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.Loaded = Signal.new()
	self.Added = Signal.new()
	self.Unloaded = Signal.new()
	self.CategoryChanged = Signal.new()
	self._Janitor:Add(self.Loaded)
	self._Janitor:Add(self.Added)
	self._Janitor:Add(self.Unloaded)
	self._Janitor:Add(self.CategoryChanged)
	self._currentCategory = nil
	self._itemsPerBatch = self.Instance:GetAttribute("LoadableToolEntriesFilterItemsPerBatch") or 30
	self._panel = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "Panel", Panel)
	self.Config = ToolsConfig.GetConfig()
	self._entryValues = {}

	for _, v2 in self.Config do
		if v2.Category == self._currentCategory then
			table.insert(self._entryValues, v2)
		end
	end

	self._gridLayout = self.Instance:FindFirstChild("UIGridLayout")
	self._template = self.Instance:FindFirstChild("Template")
	self._lastCanvasPosition = nil
	self._lockedCanvasHeight = nil
	self._currentIndex = 1
	self._isFullyLoaded = false
	assert(self._template ~= nil, "Template not found in LoadableToolEntriesFilter")
	assert(not self._template.Visible, "Template is visible in LoadableToolEntriesFilter")
end

function v:SetCategory(currentCategory: string?)
	self._currentCategory = currentCategory
	self.CategoryChanged:Fire(currentCategory)

	if self._currentCategory == nil then
		task.defer(function()
			self.Instance.CanvasPosition = self._storedPosition or Vector2.new(0, 0)
		end)
	else
		self._storedPosition = self.Instance.CanvasPosition
		self.Instance.CanvasPosition = Vector2.new(0, 0)
	end

	self._entryValues = {}

	for _, v2 in self.Config do
		if v2.Category == self._currentCategory then
			table.insert(self._entryValues, v2)
		end
	end

	table.sort(self._entryValues, function(a, b)
		return (a.Order or 0) < (b.Order or 0)
	end)
	self:RefreshFilter()
	Platform.Select(self._panel.Instance)
end

function v:SetFilter(breadcrumbsFilter)
	self.BreadcrumbsFilter = breadcrumbsFilter

	if breadcrumbsFilter ~= nil and self._currentCategory ~= nil then
		self._currentCategory = nil
		self.CategoryChanged:Fire(nil)
	end

	self:RefreshFilter()
end

function v:RefreshFilter()
	self._entryValues = {}
	self.Instance.CanvasPosition = Vector2.new(0, 0)
	local v2 = self.BreadcrumbsFilter ~= nil

	for _, v3 in self.Config do
		if not (self.BreadcrumbsFilter == nil or self.BreadcrumbsFilter(v3)) then
			continue
		end

		if v2 then
			if v3.IsCategory == true or self.GamepassFilter ~= nil and not self.GamepassFilter(v3) then
				continue
			end
		elseif self._currentCategory == nil then
			if self.CategoryFilter == nil and self.GamepassFilter == nil and v3.Category ~= self._currentCategory or self.GamepassFilter ~= nil and not self.GamepassFilter(v3) or self.CategoryFilter ~= nil and not self.CategoryFilter(v3) then
				continue
			end
		elseif v3.Category ~= self._currentCategory then
			continue
		end

		table.insert(self._entryValues, v3)
	end

	table.sort(self._entryValues, function(a, b)
		return (a.Order or 0) < (b.Order or 0)
	end)
	self:Clear()
	self:LoadNextBatch()
	self:CalculateCanvasSize()
end

function v:CalculateCanvasSize()
	self._lockedCanvasHeight = math.ceil(#self._entryValues / self._itemsPerBatch) * self._gridLayout.AbsoluteContentSize.Y
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, self._lockedCanvasHeight)
end

function v:Clear()
	self._isFullyLoaded = false
	self._currentIndex = 1

	for _, child in self.Instance:GetChildren() do
		if not (child.ClassName == self._template.ClassName and child ~= self._template and child:GetAttribute("LoadableCloned") ~= nil) then
			continue
		end

		child:Destroy()
	end
end

function v:Start()
	GameSdkShared:WaitForLoad()
	local v2, v3 = ABTest.GetExperimentVariable("lazy-loading-all", "enabled"):timeout(10):await()

	if v2 and v3 then
		table.sort(self._entryValues, function(a, b)
			return (a.Order or 0) < (b.Order or 0)
		end)
		self._panel:RegisterListener(self, self._panel.Events.Opening, function()
			self:Load()
		end)
		self._panel:RegisterListener(self, self._panel.Events.Closing, function()
			self:Unload()
		end)
		self._Janitor:Add(function()
			self._panel:UnregisterListener(self, self._panel.Events.Opening)
			self._panel:UnregisterListener(self, self._panel.Events.Closing)
		end, true)
		self._Janitor:Add(self.Instance:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			while self:ShouldLoadMoreEntries() do
				self:LoadNextBatch()
			end
		end))
		local currentCamera = workspace.CurrentCamera
		local flag = nil
		self._Janitor:Add(currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if flag then
				return
			end

			task.delay(0.05, function()
				flag = true

				while self:ShouldLoadMoreEntries() do
					self:LoadNextBatch()
				end

				flag = nil
			end)
		end))
		self._Janitor:Add(self.Instance:GetPropertyChangedSignal("CanvasSize"):Connect(function()
			if self._lockedCanvasHeight ~= nil and self.Instance.CanvasSize.Y.Offset < self._lockedCanvasHeight then
				self.Instance.CanvasSize = UDim2.new(0, 0, 0, self._lockedCanvasHeight)
			end
		end))
	else
		self:Load()

		while self._currentIndex <= #self._entryValues do
			self:LoadNextBatch()
		end

		local v4 = false
		self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(p: string)
			if not self:IsLoaded() then
				return
			end

			for _, _entryValue in self._entryValues do
				if _entryValue.Name ~= p then
					continue
				end

				v4 = true
				break
			end
		end))
		self._panel:RegisterListener(self, self._panel.Events.Opening, function()
			if self:IsLoaded() and v4 then
				self:Load()

				while self._currentIndex <= #self._entryValues do
					self:LoadNextBatch()
				end
			end
		end)
	end

	self._Janitor:Add(DatabaseRemoteConfigController.OnLoaded:Connect(function()
		if not self:IsLoaded() then
			self._lastCanvasPosition = Vector2.zero
			return
		end

		self.Instance.CanvasPosition = Vector2.zero
		self:Unload()
		self:Load()
	end))
end

function v:Stop()
	self:Unload()
	self._Janitor:Destroy()
end

function v:Load()
	self:Unload()
	self._isLoaded = true
	self._currentIndex = 1
	self:LoadNextBatch()
	self._lockedCanvasHeight = math.ceil(#self._entryValues / self._itemsPerBatch) * self._gridLayout.AbsoluteContentSize.Y
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, self._lockedCanvasHeight)

	if self._lastCanvasPosition ~= nil then
		self.Instance.CanvasPosition = self._lastCanvasPosition
		self._lastCanvasPosition = nil
	end

	while self:ShouldLoadMoreEntries() do
		self:LoadNextBatch()
	end

	self.Loaded:Fire()
end

function v:IsLoaded()
	return self._isLoaded
end

function v:ShouldLoadMoreEntries()
	if not self._isLoaded or self._currentIndex > #self._entryValues then
		return false
	end

	local instance = self.Instance
	return instance.AbsoluteSize.Y + instance.CanvasPosition.Y >= self._gridLayout.AbsoluteContentSize.Y - 200
end

function v:LoadNextBatch()
	if not self._isLoaded or self._loadingBatch or self._currentIndex > #self._entryValues then
		return
	end

	self._loadingBatch = true
	local v2 = math.min(self._currentIndex + self._itemsPerBatch - 1, #self._entryValues)
	local clones = {}

	for i = self._currentIndex, v2 do
		local _entryValue = self._entryValues[i]

		if _entryValue == nil then
			continue
		end

		if not self._isLoaded then
			return
		end

		if not (not FeatureFlagsConfig.HasFeatureFlag(_entryValue.Name) or FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(
			game.Players.LocalPlayer,
			_entryValue.Name
		)) then
			continue
		end

		local clone = self._template:Clone()
		clone.Icon.Image = _entryValue.Icon or ""

		if _entryValue.Item then
			local item = ItemRegistry.GetItem(_entryValue.Item, Item)

			if item and not ItemRenderer.Render(ItemRenderer.TOOLS_CONTEXT, clone, item) then
				clone:Destroy()
				continue
			end
		end

		clone:SetAttribute("AttachedConnection", nil)
		clone:SetAttribute("LoadableCloned", true)

		if _entryValue.Order == nil then
			clone.LayoutOrder = 0
		else
			clone.LayoutOrder = _entryValue.Order
		end

		clone.Name = _entryValue.Name
		local conditionIcon = clone:FindFirstChild("ConditionIcon")

		if conditionIcon and _entryValue.CornerIcon then
			conditionIcon.Image = _entryValue.CornerIcon
			conditionIcon.Visible = true
		elseif conditionIcon and not conditionIcon.Visible then
			conditionIcon:Destroy()
		end

		clone.Visible = true
		clone.Parent = self.Instance
		table.insert(clones, clone)
	end

	if #self._entryValues <= v2 then
		self._isFullyLoaded = true

		if self._lockedCanvasHeight ~= nil and self._gridLayout.AbsoluteContentSize.Y ~= self._lockedCanvasHeight then
			self._lockedCanvasHeight = self._gridLayout.AbsoluteContentSize.Y
			self.Instance.CanvasSize = UDim2.new(0, 0, 0, self._lockedCanvasHeight)
		end
	end

	self._currentIndex = v2 + 1
	local v3 = BreadcrumbListTracker:FromInstance(self.Instance)

	if v3 then
		v3:ApplyBreadcrumbs()
	end

	self.Added:Fire(clones)
	self._loadingBatch = false
end

function v:Unload()
	local _isLoaded = self._isLoaded
	self._isLoaded = false
	self._isFullyLoaded = false

	if _isLoaded then
		self._lastCanvasPosition = self.Instance.CanvasPosition
	end

	for _, child in self.Instance:GetChildren() do
		if not (child.ClassName == self._template.ClassName and child ~= self._template and child:GetAttribute("LoadableCloned") ~= nil) then
			continue
		end

		child:Destroy()
	end

	if _isLoaded then
		self.Unloaded:Fire()
	end
end

function v:FilterGamepasses()
	self._currentCategory = nil
	self.CategoryChanged:Fire(nil)

	function self.GamepassFilter(p)
		local filter = p.Filter

		if filter == nil and p.Item then
			local item = ItemRegistry.GetItem(p.Item, FilterableItem)

			if item ~= nil then
				return item:IsPaid()
			end
		end

		if filter == nil then
			return false
		end

		if typeof(filter) == "string" then
			return filter == "Gamepass"
		end

		return table.find(filter, "Gamepass") ~= nil
	end

	self.CategoryFilter = nil
	self:RefreshFilter()
end

function v:FilterGroup(p)
	self._currentCategory = nil
	self.CategoryChanged:Fire(nil)
	self.GamepassFilter = nil

	if p == nil then
		self.CategoryFilter = nil
	else
		function self.CategoryFilter(p2)
			local filter = p2.Filter

			if filter == nil and p2.Item then
				local item = ItemRegistry.GetItem(p2.Item, FilterableItem)

				if item ~= nil then
					filter = item:GetFilter()
				end
			end

			if filter == nil then
				return false
			end

			if typeof(filter) == "string" then
				return filter == p
			end

			return table.find(filter, p) ~= nil
		end
	end

	self:RefreshFilter()
end

return v