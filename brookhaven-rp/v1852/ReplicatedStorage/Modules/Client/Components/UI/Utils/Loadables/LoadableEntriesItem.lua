local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local DatabaseRemoteConfigController = require(ReplicatedStorage.Modules.Client.Databases.DatabaseRemoteConfigController)
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local CategoryItem = require(ReplicatedStorage.Modules.Shared.Item.CategoryItem)
local FilterableItem = require(ReplicatedStorage.Modules.Shared.Item.FilterableItem)
require(ReplicatedStorage.Modules.Shared.Item.Item)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local v = Component.new({
	Tag = "LoadableEntriesItem"
})

local function createInstance(data, _entryValue, layoutOrder: number)
	local clone = data._template:Clone()
	clone:SetAttribute("AttachedConnection", nil)
	clone:SetAttribute("LoadableCloned", true)
	local context = ItemRenderer.GetContext(data._contextName)
	assert(context, (`unknown context {data._contextName}`))

	if not ItemRenderer.Render(context, clone, _entryValue) then
		clone:Destroy()
		return nil
	end

	for _, guiObject in clone:GetChildren() do
		if not guiObject:IsA("GuiObject") or guiObject.Visible then
			continue
		end

		guiObject:Destroy()
	end

	clone.Name = _entryValue:GetName()
	clone.LayoutOrder = layoutOrder
	clone.Visible = true
	clone.Parent = data.Instance
	return clone
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.Loaded = Signal.new()
	self.Added = Signal.new()
	self.Unloaded = Signal.new()
	self.OnTargetModuleChanged = Signal.new()
	self.CategoryChanged = Signal.new()
	self.OnFilterChanged = Signal.new()
	self._Janitor:Add(self.Loaded)
	self._Janitor:Add(self.Added)
	self._Janitor:Add(self.Unloaded)
	self._Janitor:Add(self.CategoryChanged)
	self._Janitor:Add(self.OnTargetModuleChanged)
	self._Janitor:Add(self.OnFilterChanged)
	self._contextName = self.Instance:GetAttribute("Context")
	self._registryName = self.Instance:GetAttribute("Registry")
	self._useVisibility = self.Instance:GetAttribute("LoadableEntriesUseVisibility")
	self._itemsPerBatch = self.Instance:GetAttribute("LoadableEntriesItemsPerBatch") or 30
	self._panel = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "Panel", Panel)
	self:ReloadFromModule()
	self._template = self.Instance:FindFirstChild("Template")
	self._gridLayout = self.Instance:FindFirstChild("UIGridLayout")
	self._lastCanvasPosition = nil
	self._lockedCanvasHeight = nil
	self._currentIndex = 1
	self._isFullyLoaded = false
	assert(
		self._template ~= nil,
		"Template not found in LoadableEntriesItem, was trying to load - " .. self.Instance:GetFullName()
	)
	assert(not self._template.Visible, "Template is visible in LoadableEntriesItem")
end

function v:SetParameters(contextName, registryName)
	self._contextName = contextName
	self._registryName = registryName
end

function v:ReloadFromModule()
	if self._moduleName and self._moduleName == self.loadedModule then
		return
	end

	self._entryValues = {}
	local registry = ItemRegistry.GetRegistryByName(self._registryName)
	assert(registry, (`Unknown registry {self._registryName}`))

	for _, v2 in ItemRegistry.GetRegistry(registry) do
		assert(
			Object.InstanceOf(v2, MenuItem),
			(`Item {v2:GetName()} must be a MenuItem to be used in LoadableEntriesItem`)
		)

		if not (not Object.InstanceOf(v2, CategoryItem) or v2:GetCategory() == self._currentCategory) then
			continue
		end

		table.insert(self._entryValues, v2)
	end

	self.loadedModule = self._moduleName
	self.OnTargetModuleChanged:Fire(self._moduleName)
	self.OnFilterChanged:Fire()
end

function v:GetConfigTable()
	return self._module.Entries
end

function v:Start()
	GameSdkShared:WaitForLoad()

	if self._useVisibility then
		self._Janitor:Add(self._panel.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
			if self._panel.Instance.Visible then
				self:Load()
			else
				self:Unload()
			end
		end))
	else
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
	end

	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		while self:ShouldLoadMoreEntries() do
			if self:LoadNextBatch() then
				continue
			end

			warn("Failed to load more entries")
			break
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
				if self:LoadNextBatch() then
					continue
				end

				warn("Failed to load more entries")
				break
			end

			flag = nil
		end)
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("CanvasSize"):Connect(function()
		if self._lockedCanvasHeight ~= nil and self.Instance.CanvasSize.Y.Offset < self._lockedCanvasHeight then
			self.Instance.CanvasSize = UDim2.new(0, 0, 0, self._lockedCanvasHeight)
		end
	end))

	local function redraw()
		if not self:IsLoaded() then
			self._lastCanvasPosition = Vector2.zero
			return
		end

		self.Instance.CanvasPosition = Vector2.zero
		self:Unload()
		self:Load()
	end

	self._Janitor:Add(DatabaseRemoteConfigController.OnLoaded:Connect(redraw))
	self._Janitor:Add(FeatureFlagsConfig.OverrideChanged:Connect(redraw))
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
	self:CalculateCanvasSize()

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
		return false
	end

	self._loadingBatch = true
	local v2 = math.min(self._currentIndex + self._itemsPerBatch - 1, #self._entryValues)
	local v3 = self._currentIndex - 1
	local count = 0
	local instances = {}

	for i = 1, #self._entryValues do
		local _entryValue = self._entryValues[i]

		if FeatureFlagsConfig.HasFeatureFlag(_entryValue:GetName()) and not FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(
			game.Players.LocalPlayer,
			_entryValue:GetName()
		) then
			v2 = math.min(v2 + 1, #self._entryValues)
		else
			count += 1
		end
	end

	self._possibleVisibleAmount = count

	while v3 < v2 do
		v3 += 1
		local _entryValue = self._entryValues[v3]

		if _entryValue == nil then
			v2 = math.min(v2 + 1, #self._entryValues)
		else
			if not self._isLoaded then
				return
			end

			if not FeatureFlagsConfig.HasFeatureFlag(_entryValue:GetName()) or FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(
				game.Players.LocalPlayer,
				_entryValue:GetName()
			) then
				local instance = createInstance(self, _entryValue, v3 + 1)

				if instance == nil then
					v2 = math.min(v2 + 1, #self._entryValues)
				else
					table.insert(instances, instance)
				end
			end
		end
	end

	if #self._entryValues <= v2 then
		self._isFullyLoaded = true

		if self._lockedCanvasHeight ~= nil and self._gridLayout.AbsoluteContentSize.Y ~= self._lockedCanvasHeight then
			self._lockedCanvasHeight = self._gridLayout.AbsoluteContentSize.Y
			self.Instance.CanvasSize = UDim2.new(0, 0, 0, self._lockedCanvasHeight)
		end
	end

	self._currentIndex = v2 + 1
	self.Added:Fire(instances)
	self._loadingBatch = false
	return true
end

function v:CalculateCanvasSize()
	local _possibleVisibleAmount = 0

	if self._possibleVisibleAmount then
		_possibleVisibleAmount = self._possibleVisibleAmount
	else
		for _, guiObject in self.Instance:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Visible then
				_possibleVisibleAmount += 1
			end
		end
	end

	self._lockedCanvasHeight = math.ceil(_possibleVisibleAmount / self._itemsPerBatch) * self._gridLayout.AbsoluteContentSize.Y
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, self._lockedCanvasHeight)
end

function v:SetFilter(breadcrumbsFilter)
	self.BreadcrumbsFilter = breadcrumbsFilter
	self:RefreshFilter()
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

	self:RefreshFilter()
	Platform.Select(self._panel.Instance)
end

function v:RefreshFilter()
	self._entryValues = {}
	self.Instance.CanvasPosition = Vector2.new(0, 0)

	for _, v2 in ItemRegistry.GetRegistry(assert(ItemRegistry.GetRegistryByName(self._registryName))) do
		if not (self.BreadcrumbsFilter == nil or self.BreadcrumbsFilter(v2)) then
			continue
		end

		if self._currentCategory == nil then
			if self.CategoryFilter == nil and self.GamepassFilter == nil and Object.InstanceOf(v2, CategoryItem) and v2:GetCategory() ~= self._currentCategory or self.GamepassFilter ~= nil and not self.GamepassFilter(v2) or self.CategoryFilter ~= nil and not self.CategoryFilter(v2) then
				continue
			end
		elseif not Object.InstanceOf(v2, CategoryItem) or v2:GetCategory() ~= self._currentCategory then
			continue
		end

		table.insert(self._entryValues, v2)
	end

	self:Clear()
	self:LoadNextBatch()

	while self:ShouldLoadMoreEntries() do
		if self:LoadNextBatch() then
			continue
		end

		warn("Failed to load more entries")
		break
	end

	self:CalculateCanvasSize()
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

function v:Unload()
	local _isLoaded = self._isLoaded
	self._isLoaded = false

	if _isLoaded then
		self._lastCanvasPosition = self.Instance.CanvasPosition
	end

	self:Clear()

	if _isLoaded then
		self.Unloaded:Fire()
	end
end

function v:FilterGamepasses()
	self._currentCategory = nil
	self.CategoryChanged:Fire(nil)

	function self.GamepassFilter(object2)
		if Object.InstanceOf(object2, FilterableItem) then
			return object2:IsPaid()
		end

		return nil
	end

	self.CategoryFilter = nil
	self:RefreshFilter()
end

function v.GetFilters(_)
	return nil
end

function v:FilterGroup(p)
	self._currentCategory = nil
	self.CategoryChanged:Fire(nil)
	self.GamepassFilter = nil

	if p == nil then
		self.CategoryFilter = nil
	else
		function self.CategoryFilter(object2)
			local filter

			if Object.InstanceOf(object2, FilterableItem) then
				filter = object2:GetFilter()
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