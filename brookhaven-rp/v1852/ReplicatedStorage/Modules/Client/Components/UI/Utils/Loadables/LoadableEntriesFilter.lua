local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local DatabaseRemoteConfigController = require(ReplicatedStorage.Modules.Client.Databases.DatabaseRemoteConfigController)
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local FilterableItem = require(ReplicatedStorage.Modules.Shared.Item.FilterableItem)
local Item = require(ReplicatedStorage.Modules.Shared.Item.Item)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local loadableEntries = ReplicatedStorage.Modules.Client.UI.LoadableEntries
local v = nil
local v2 = false
local v3 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function fetchNewPropUiEnabled()
	if v ~= nil then
		return
	end

	local v4, v5 = ABTest.GetExperimentVariable("prop-ui-names-images", "enabled"):timeout(10):await()

	if v4 == true then
		v = v5 == true
	else
		warn("Failed to fetch prop-ui-names-images experiment: " .. tostring(v5))
	end
end

local function getLoadableModuleName(p: string)
	if p ~= "Props" then
		return p
	end

	if v == true then
		return "Props"
	end

	if v == false or v2 then
		return "PropsOld"
	end

	return "Props"
end

local v4 = Component.new({
	Tag = "LoadableEntriesFilter"
})
v4.OnPropsModuleResolved = Signal.new()

function v4.ResolveBreadcrumbItemType(p: string)
	if p ~= "Props" then
		return p
	end

	if v == true then
		return "Props"
	end

	if v == false or v2 then
		return "PropsOld"
	end

	return "Props"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function usesCategoryTemplate(p)
	return p.loadedModule ~= "PropsOld" and p._module ~= nil and p._module.GetTemplate ~= nil
end

local function getTemplate(data, p)
	local v5

	if data.loadedModule == "PropsOld" or data._module == nil then
		v5 = false
	else
		v5 = data._module.GetTemplate ~= nil
	end

	if v5 then
		local template = data._module.GetTemplate(data.Instance, p)

		if template ~= nil then
			return template
		end
	end

	return data._template
end

local function isCategoryMode(p)
	return p._currentCategory == nil and p.GamepassFilter == nil
end

local function isCategoryTemplateMode(data)
	local v5 = false
	local v6

	if data._currentCategory == nil then
		v6 = data.GamepassFilter == nil
	else
		v6 = false
	end

	return v6 == true and usesCategoryTemplate(data) == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyGridLayoutProps(_gridLayout, _entryGridLayout)
	if _entryGridLayout.CellSize ~= nil then
		_gridLayout.CellSize = _entryGridLayout.CellSize
	end

	if _entryGridLayout.CellPadding ~= nil then
		_gridLayout.CellPadding = _entryGridLayout.CellPadding
	end

	if _entryGridLayout.FillDirectionMaxCells ~= nil then
		_gridLayout.FillDirectionMaxCells = _entryGridLayout.FillDirectionMaxCells
	end
end

local function readUDim2Attribute(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "UDim2" then
		return attribute
	end

	return nil
end

local function readNumberAttribute(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return nil
end

local function hasCategoryLayout(instance)
	local categoryCellSize = instance:GetAttribute("CategoryCellSize")

	if typeof(categoryCellSize) ~= "UDim2" then
		categoryCellSize = nil
	end

	local categoryCellPadding = instance:GetAttribute("CategoryCellPadding")

	if typeof(categoryCellPadding) ~= "UDim2" then
		categoryCellPadding = nil
	end

	local categoryFillDirectionMaxCells = instance:GetAttribute("CategoryFillDirectionMaxCells")

	if typeof(categoryFillDirectionMaxCells) ~= "number" then
		categoryFillDirectionMaxCells = nil
	end

	return categoryCellSize ~= nil or categoryCellPadding ~= nil or categoryFillDirectionMaxCells ~= nil
end

local function getCategoryGridLayout(instance)
	local categoryCellSize = instance:GetAttribute("CategoryCellSize")

	if typeof(categoryCellSize) ~= "UDim2" then
		categoryCellSize = nil
	end

	local categoryCellPadding = instance:GetAttribute("CategoryCellPadding")

	if typeof(categoryCellPadding) ~= "UDim2" then
		categoryCellPadding = nil
	end

	local categoryFillDirectionMaxCells = instance:GetAttribute("CategoryFillDirectionMaxCells")

	if typeof(categoryFillDirectionMaxCells) ~= "number" then
		categoryFillDirectionMaxCells = nil
	end

	return {
		CellSize = categoryCellSize,
		CellPadding = categoryCellPadding,
		FillDirectionMaxCells = categoryFillDirectionMaxCells
	}
end

local function applyGridLayout(object)
	if object._gridLayout ~= nil then
		local instance = object.Instance
		local categoryCellSize = instance:GetAttribute("CategoryCellSize")

		if typeof(categoryCellSize) ~= "UDim2" then
			categoryCellSize = nil
		end

		local categoryCellPadding = instance:GetAttribute("CategoryCellPadding")

		if typeof(categoryCellPadding) ~= "UDim2" then
			categoryCellPadding = nil
		end

		local categoryFillDirectionMaxCells = instance:GetAttribute("CategoryFillDirectionMaxCells")

		if typeof(categoryFillDirectionMaxCells) ~= "number" then
			categoryFillDirectionMaxCells = nil
		end

		local v5

		if categoryCellSize == nil and categoryCellPadding == nil then
			v5 = categoryFillDirectionMaxCells == nil
		else
			v5 = false
		end

		if not v5 then
			local v6 = false
			local v7

			if object._currentCategory == nil then
				v7 = object.GamepassFilter == nil
			else
				v7 = false
			end

			if v7 == true then
				v6 = usesCategoryTemplate(object) == true
			end

			local _entryGridLayout

			if v6 then
				_entryGridLayout = getCategoryGridLayout(object.Instance)
			end

			if _entryGridLayout == nil then
				_entryGridLayout = object._entryGridLayout
			end

			if _entryGridLayout == nil then
				return
			end

			applyGridLayoutProps(object._gridLayout, _entryGridLayout) -- equivalent call inferred; original call site unknown
			local _gridAspectRatioConstraint = object._gridAspectRatioConstraint

			if _gridAspectRatioConstraint ~= nil then
				local v8 = false
				local v9

				if object._currentCategory == nil then
					v9 = object.GamepassFilter == nil
				else
					v9 = false
				end

				if v9 == true then
					v8 = usesCategoryTemplate(object) == true
				end

				local categoryAspectRatio

				if v8 then
					categoryAspectRatio = object.Instance:GetAttribute("CategoryAspectRatio")

					if typeof(categoryAspectRatio) ~= "number" then
						categoryAspectRatio = nil
					end
				end

				if categoryAspectRatio == nil then
					local v10 = false
					local v11

					if object._currentCategory == nil then
						v11 = object.GamepassFilter == nil
					else
						v11 = false
					end

					if v11 == true then
						v10 = usesCategoryTemplate(object) == true
					end

					if v10 then
						_gridAspectRatioConstraint.Parent = nil
					else
						_gridAspectRatioConstraint.Parent = object._gridLayout

						if object._defaultAspectRatio ~= nil then
							_gridAspectRatioConstraint.AspectRatio = object._defaultAspectRatio
						end
					end
				else
					_gridAspectRatioConstraint.Parent = object._gridLayout
					_gridAspectRatioConstraint.AspectRatio = categoryAspectRatio
				end
			end

			object._lockedCanvasHeight = nil
		end
	end
end

local function createInstance(data, _entryValue, layoutOrder: number)
	local v5

	if data.loadedModule == "PropsOld" or data._module == nil then
		v5 = false
	else
		v5 = data._module.GetTemplate ~= nil
	end

	local _template

	if v5 then
		_template = data._module.GetTemplate(data.Instance, _entryValue)

		if _template == nil then
			_template = data._template
		end
	else
		_template = data._template
	end

	local clone = _template:Clone()
	clone:SetAttribute("AttachedConnection", nil)
	clone:SetAttribute("LoadableCloned", true)
	local item = _entryValue.Item

	if item ~= nil then
		local item2 = ItemRegistry.GetItem(item, Item)

		if item2 then
			local renderContext = data._module.GetRenderContext()

			if item2 == nil then
				warn("Cannot render unknown item " .. item)
			elseif renderContext ~= nil and not ItemRenderer.Render(renderContext, clone, item2) then
				clone:Destroy()
				return nil
			end
		else
			warn("Item not found in item registry: " .. item)
			clone:Destroy()
			return nil
		end
	end

	if data._module.Setup == nil then
		clone.Name = _entryValue.Name
	else
		data._module.Setup(clone, _entryValue)
	end

	clone.LayoutOrder = layoutOrder
	clone.Visible = true
	clone.Parent = data.Instance
	return clone
end

function v4:Construct()
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
	self._moduleName = self.Instance:GetAttribute("LoadableEntriesModuleName")
	self._useVisibility = self.Instance:GetAttribute("LoadableEntriesUseVisibility")
	self._itemsPerBatch = self.Instance:GetAttribute("LoadableEntriesItemsPerBatch") or 30
	self._panel = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "Panel", Panel)
	self:ReloadFromModule()
	self._template = self.Instance:FindFirstChild("Template")
	self._categoryTemplate = self.Instance:FindFirstChild("CategoryTemplate")
	self._gridLayout = self.Instance:FindFirstChild("UIGridLayout")

	if self._gridLayout ~= nil then
		self._entryGridLayout = {
			CellSize = self._gridLayout.CellSize,
			CellPadding = self._gridLayout.CellPadding,
			FillDirectionMaxCells = self._gridLayout.FillDirectionMaxCells
		}
		self._gridAspectRatioConstraint = self._gridLayout:FindFirstChildOfClass("UIAspectRatioConstraint")
		local defaultAspectRatio

		if self._gridAspectRatioConstraint ~= nil then
			defaultAspectRatio = self._gridAspectRatioConstraint.AspectRatio
		end

		self._defaultAspectRatio = defaultAspectRatio
	end

	self._lastCanvasPosition = nil
	self._lockedCanvasHeight = nil
	self._currentIndex = 1
	self._isFullyLoaded = false
	assert(
		self._template ~= nil,
		"Template not found in LoadableEntriesFilter, was trying to load - " .. self._moduleName
	)
	assert(not self._template.Visible, "Template is visible in LoadableEntriesFilter")

	if self._categoryTemplate ~= nil then
		assert(not self._categoryTemplate.Visible, "CategoryTemplate is visible in LoadableEntriesFilter")
	end
end

function v4:SetTargetModule(moduleName: string)
	self._moduleName = moduleName
end

function v4:ReloadFromModule()
	local _moduleName = self._moduleName

	if _moduleName == "Props" then
		_moduleName = v == true and "Props" or (v == false or v2) and "PropsOld" or "Props"
	end

	if _moduleName ~= nil and _moduleName == self.loadedModule then
		return
	end

	local child = loadableEntries:FindFirstChild(_moduleName)

	if child == nil then
		error("LoadableEntriesFilter module name " .. _moduleName .. " not found")
	end

	self._module = require(child)
	self:RebuildEntryValues()
	self.loadedModule = _moduleName
	self.OnTargetModuleChanged:Fire(_moduleName)
	self.OnFilterChanged:Fire()
end

function v4:GetConfigTable()
	return self._module.Entries
end

function v4:Start()
	GameSdkShared:WaitForLoad()

	if self._moduleName == "Props" then
		fetchNewPropUiEnabled() -- equivalent call inferred; original call site unknown
		v2 = true
		self:ReloadFromModule()

		if not v3 then
			v3 = true
			v4.OnPropsModuleResolved:Fire()
		end
	end

	local v5, v6 = ABTest.GetExperimentVariable("lazy-loading-all", "enabled"):timeout(10):await()
	self._isABTestEnabled = v5 and v6

	if v5 and v6 then
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

		local v7 = false
		self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(p: string)
			if not self:IsLoaded() then
				return
			end

			for _, _entryValue in self._entryValues do
				if _entryValue.Name ~= p then
					continue
				end

				v7 = true
				break
			end
		end))
		self._panel:RegisterListener(self, self._panel.Events.Opening, function()
			if self:IsLoaded() and v7 then
				self:Load()

				while self._currentIndex <= #self._entryValues do
					self:LoadNextBatch()
				end
			end
		end)
	end

	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("CategoryAspectRatio"):Connect(function()
		applyGridLayout(self)

		if self:IsLoaded() == true then
			self:CalculateCanvasSize()
		end
	end))
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

function v4:Stop()
	self:Unload()
	self._Janitor:Destroy()
end

function v4:Load()
	self:Unload()
	self._isLoaded = true
	self._currentIndex = 1
	applyGridLayout(self)
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

function v4:IsLoaded()
	return self._isLoaded
end

function v4:ShouldLoadMoreEntries()
	if not self._isLoaded or self._currentIndex > #self._entryValues then
		return false
	end

	local instance = self.Instance
	return instance.AbsoluteSize.Y + instance.CanvasPosition.Y >= self._gridLayout.AbsoluteContentSize.Y - 200
end

function v4:LoadNextBatch()
	if not self._isLoaded or self._loadingBatch or self._currentIndex > #self._entryValues then
		return
	end

	self._loadingBatch = true
	local v5 = math.min(self._currentIndex + self._itemsPerBatch - 1, #self._entryValues)
	local v6 = self._currentIndex - 1
	local count = 0
	local instances = {}

	for i = 1, #self._entryValues do
		local _entryValue = self._entryValues[i]

		if FeatureFlagsConfig.HasFeatureFlag(_entryValue.Name) and not FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(
			game.Players.LocalPlayer,
			_entryValue.Name
		) then
			v5 = math.min(v5 + 1, #self._entryValues)
		else
			local item = _entryValue.Item

			if item ~= nil then
				local item2 = ItemRegistry.GetItem(item, Item)

				if not item2 then
					warn("Item not found in item registry: " .. item)
					continue
				end

				local renderContext = self._module.GetRenderContext()

				if item2 == nil then
					warn("Cannot render unknown item " .. item)
				elseif renderContext == nil then
					continue
				end
			end

			count += 1
		end
	end

	self._possibleVisibleAmount = count

	while v6 < v5 do
		v6 += 1
		local _entryValue = self._entryValues[v6]

		if _entryValue == nil then
			v5 = math.min(v5 + 1, #self._entryValues)
		else
			if not self._isLoaded then
				return
			end

			if FeatureFlagsConfig.HasFeatureFlag(_entryValue.Name) and not FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(
				game.Players.LocalPlayer,
				_entryValue.Name
			) then
				v5 = math.min(v5 + 1, #self._entryValues)
			else
				local instance = createInstance(self, _entryValue, v6 + 1)

				if instance == nil then
					v5 = math.min(v5 + 1, #self._entryValues)
				else
					table.insert(instances, instance)
				end
			end
		end
	end

	if #self._entryValues <= v5 then
		self._isFullyLoaded = true

		if self._lockedCanvasHeight ~= nil and self._gridLayout.AbsoluteContentSize.Y ~= self._lockedCanvasHeight then
			self._lockedCanvasHeight = self._gridLayout.AbsoluteContentSize.Y
			self.Instance.CanvasSize = UDim2.new(0, 0, 0, self._lockedCanvasHeight)
		end
	end

	self._currentIndex = v5 + 1
	self.Added:Fire(instances)
	self._loadingBatch = false
end

function v4:CalculateCanvasSize()
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

function v4:RebuildEntryValues()
	if self._module ~= nil and self._module.FilterEntryValues ~= nil then
		self._entryValues = self._module.FilterEntryValues({
			BreadcrumbsFilter = self.BreadcrumbsFilter,
			CurrentCategory = self._currentCategory,
			CategoryFilter = self.CategoryFilter,
			GamepassFilter = self.GamepassFilter
		})
		return
	end

	self._entryValues = {}

	for _, entry in self._module.Entries do
		if entry.Category == self._currentCategory then
			table.insert(self._entryValues, entry)
		end
	end
end

function v4:SetFilter(breadcrumbsFilter)
	self.BreadcrumbsFilter = breadcrumbsFilter

	if breadcrumbsFilter ~= nil and self._currentCategory ~= nil and self._moduleName == "Props" then
		self._currentCategory = nil
		self.CategoryChanged:Fire(nil)
	end

	self:RefreshFilter()
end

function v4:GetCurrentCategory()
	return self._currentCategory
end

function v4:SetCategory(currentCategory: string?)
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

function v4:RefreshFilter()
	self._loadingBatch = false
	self._isLoaded = true
	self.Instance.CanvasPosition = Vector2.new(0, 0)
	self:RebuildEntryValues()
	self:Clear()
	applyGridLayout(self)

	if self._isABTestEnabled == true then
		self:LoadNextBatch()

		while self:ShouldLoadMoreEntries() do
			local _currentIndex = self._currentIndex
			self:LoadNextBatch()

			if self._currentIndex == _currentIndex then
				break
			end
		end
	else
		while self._currentIndex <= #self._entryValues do
			local _currentIndex = self._currentIndex
			self:LoadNextBatch()

			if self._currentIndex == _currentIndex then
				break
			end
		end
	end

	self:CalculateCanvasSize()
end

function v4:Clear()
	self._isFullyLoaded = false
	self._currentIndex = 1
	self._loadingBatch = false

	for _, guiObject in self.Instance:GetChildren() do
		if not (guiObject ~= self._template and guiObject ~= self._categoryTemplate and guiObject:IsA("GuiObject") and guiObject:GetAttribute("LoadableCloned") ~= nil) then
			continue
		end

		guiObject:Destroy()
	end
end

function v4:Unload()
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

function v4:FilterGamepasses()
	self._currentCategory = nil
	self.CategoryChanged:Fire(nil)

	function self.GamepassFilter(p)
		if self._module.IsGamepass ~= nil and self._module.IsGamepass(p) then
			return true
		end

		if p.Item then
			local item = ItemRegistry.GetItem(p.Item, FilterableItem)

			if item ~= nil then
				return item:IsPaid()
			end
		end

		return false
	end

	self.CategoryFilter = nil
	self:RefreshFilter()
end

function v4:GetFilters()
	if self._module.GetFilters then
		return self._module.GetFilters()
	end

	return nil
end

function v4:FilterGroup(p)
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

return v4