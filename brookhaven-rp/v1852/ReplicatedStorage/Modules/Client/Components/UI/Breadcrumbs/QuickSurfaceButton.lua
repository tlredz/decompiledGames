local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "QuickSurfaceButton"
})
local BreadcrumbListTracker = require(ReplicatedStorage.Modules.Client.Components.UI.Breadcrumbs.BreadcrumbListTracker)
local EmotesList = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.EmotesList)
local LoadableEntries = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableEntries)
local LoadableEntriesFilter = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableEntriesFilter)
local LoadableEntriesItem = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableEntriesItem)
local LoadableToolEntriesFilter = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableToolEntriesFilter)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local BreadcrumbConfig = require(ReplicatedStorage.Modules.Shared.DB.Breadcrumbs.BreadcrumbConfig)
local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
local DatabaseRemoteConfigController = require(ReplicatedStorage.Modules.Client.Databases.DatabaseRemoteConfigController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local GamepassItem = require(ReplicatedStorage.Modules.Shared.Item.Items.GamepassItem)

-- equivalent calls inferred from this helper; original call sites unknown
local function getBreadcrumbTypeConfig(p: string)
	local breadcrumbItemType = LoadableEntriesFilter.ResolveBreadcrumbItemType(p)
	return BreadcrumbConfig.GetConfig()[breadcrumbItemType]
end

local v2 = {
	"BreadcrumbListTracker",
	"LoadableEntries",
	"LoadableToolEntriesFilter",
	"LoadableEntriesFilter",
	"LoadableEntriesItem",
	"EmotesList"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isScrollingFrameConnection(objectValue)
	return objectValue:IsA("ObjectValue") and (objectValue.Name == "ScrollIngFrameConnection" or objectValue.Name == "ScrollingFrameConnection")
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._breadcrumbJanitor = Janitor.new()
	self.deferredThread = nil
	self.scrollingFrames = {}
	self.framesToIsolate = {}
	self.framesToHide = {}
	self.breadcrumbListTrackersToForceValidate = {}

	if not self.Instance:GetAttribute("ItemType") then
		warn("QuickSurfaceButton has no ItemType attribute")
		return
	end

	self.Instance.Visible = false
	task.defer(function()
		self:RefreshVisibility()

		local function refresh()
			self:RefreshVisibility()
			self:ReconcileIsolation()
		end

		self._Janitor:Add(DatabaseRemoteConfigController.OnLoaded:Connect(refresh))
		self._Janitor:Add(FeatureFlagsConfig.OverrideChanged:Connect(refresh))
		self._Janitor:Add(LoadableEntriesFilter.OnPropsModuleResolved:Connect(refresh))
	end)

	for _, v3 in v2 do
		self._Janitor:Add(CollectionService:GetInstanceAddedSignal(v3):Connect(function(instance)
			for _, objectValue in self.Instance:GetChildren() do
				if not (objectValue:IsA("ObjectValue") and objectValue:IsA("ObjectValue") and (objectValue.Name == "ScrollIngFrameConnection" or objectValue.Name == "ScrollingFrameConnection")) then
					continue
				end

				local value = objectValue.Value

				if value and (instance:IsDescendantOf(value) or instance == value) then
					self:RefreshVisibility()
				end
			end
		end))
	end

	if self.Instance then
		if self:HasFramesToIsolate() then
			self.Instance.Visible = true
		else
			self.Instance.Visible = false
		end
	end

	if #self.scrollingFrames ~= 0 then
		return
	end

	warn("QuickSurfaceButton has no scrolling frames")
end

function v:_BindScrollingFrame(scrollingFrame)
	if not scrollingFrame:IsA("ScrollingFrame") then
		return
	end

	for _, scrollingFrame2 in self.scrollingFrames do
		if scrollingFrame2.scrollingFrame == scrollingFrame then
			return
		end
	end

	local v3 = {
		scrollingFrame = scrollingFrame,
		breadcrumbListTracker = nil,
		loadableEntries = nil
	}
	local breadcrumbListTracker = scrollingFrame:HasTag("BreadcrumbListTracker") and ComponentUtil.GetComponentFromInstance(
		scrollingFrame,
		BreadcrumbListTracker,
		5
	)

	if breadcrumbListTracker then
		v3.breadcrumbListTracker = breadcrumbListTracker
	end

	if scrollingFrame:HasTag("LoadableEntries") then
		local component = ComponentUtil.GetComponentFromInstance(scrollingFrame, LoadableEntries, 5)

		if component ~= nil then
			v3.loadableEntries = component
		end
	end

	if scrollingFrame:HasTag("LoadableToolEntriesFilter") then
		local component = ComponentUtil.GetComponentFromInstance(scrollingFrame, LoadableToolEntriesFilter, 5)

		if component ~= nil then
			v3.loadableEntries = component
		end
	end

	if scrollingFrame:HasTag("LoadableEntriesFilter") then
		local component = ComponentUtil.GetComponentFromInstance(scrollingFrame, LoadableEntriesFilter, 5)

		if component ~= nil then
			v3.loadableEntries = component
		end
	end

	if scrollingFrame:HasTag("LoadableEntriesItem") then
		local component = ComponentUtil.GetComponentFromInstance(scrollingFrame, LoadableEntriesItem, 5)

		if component ~= nil then
			v3.loadableEntries = component
		end
	end

	if scrollingFrame:HasTag("EmotesList") then
		local component = ComponentUtil.GetComponentFromInstance(scrollingFrame, EmotesList, 5)

		if component ~= nil then
			v3.loadableEntries = component
		end
	end

	table.insert(self.scrollingFrames, v3)
end

function v:RefreshVisibility()
	self.scrollingFrames = {}

	for _, objectValue in self.Instance:GetChildren() do
		if isScrollingFrameConnection(objectValue) and objectValue.Value ~= nil then
			self:_BindScrollingFrame(objectValue.Value)
		end
	end

	if #self.scrollingFrames == 0 then
		local parent = self.Instance.Parent

		while parent ~= nil do
			for _, scrollingFrame in parent:GetDescendants() do
				if scrollingFrame:IsA("ScrollingFrame") and scrollingFrame:HasTag("LoadableEntriesFilter") then
					self:_BindScrollingFrame(scrollingFrame)
				end
			end

			if parent:HasTag("Panel") then
				break
			else
				parent = parent.Parent
			end
		end
	end

	if self:HasFramesToIsolate() then
		self.Instance.Visible = true
	else
		self.Instance.Visible = false
	end
end

function v:SetupFramesToIsolate()
	local itemType = self.Instance:GetAttribute("ItemType")
	self.deferredThread = nil
	self.framesToIsolate = {}
	self.framesToHide = {}
	self.breadcrumbListTrackersToForceValidate = {}
	local breadcrumbTypeConfig = getBreadcrumbTypeConfig(itemType) -- equivalent call inferred; original call site unknown
	local mansions

	if itemType == "Houses" then
		mansions = BreadcrumbConfig.GetConfig().Mansions
	end

	for _, scrollingFrame in self.scrollingFrames do
		if not scrollingFrame.scrollingFrame.Visible then
			continue
		end

		if scrollingFrame.breadcrumbListTracker then
			table.insert(self.breadcrumbListTrackersToForceValidate, scrollingFrame.breadcrumbListTracker)
		end

		for _, guiObject in scrollingFrame.scrollingFrame:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			if (breadcrumbTypeConfig and breadcrumbTypeConfig[guiObject.Name] or mansions and mansions[guiObject.Name]) and guiObject.Visible then
				table.insert(self.framesToIsolate, guiObject)
			elseif guiObject.Visible then
				table.insert(self.framesToHide, guiObject)
			end
		end
	end

	self.hasPreppedFrames = true
end

function v:HasFramesToIsolate()
	local itemType = self.Instance:GetAttribute("ItemType")
	local breadcrumbTypeConfig = getBreadcrumbTypeConfig(itemType) -- equivalent call inferred; original call site unknown
	local mansions

	if itemType == "Houses" then
		mansions = BreadcrumbConfig.GetConfig().Mansions
	end

	if itemType and (breadcrumbTypeConfig or mansions) then
		local function checkConfig(items)
			if not items then
				return false
			end

			for k, _ in items do
				if FeatureFlagsConfig.HasFeatureFlag(k) then
					if FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(game.Players.LocalPlayer, k) then
						return true
					end
				else
					local item = ItemRegistry.GetItem(k, GamepassItem)

					if item == nil or item:IsAlwaysVisible() or item:IsUnlockedClient() then
						return true
					end
				end
			end

			return false
		end

		return checkConfig(breadcrumbTypeConfig) or checkConfig(mansions)
	else
		return false
	end
end

function v:ReconcileIsolation()
	if not self.isIsolated then
		return
	end

	if self:HasFramesToIsolate() then
		self:IsolateBreadcrumbs()
	else
		self:ToggleOff()
	end
end

function v:IsolateBreadcrumbs(flag: boolean?)
	self._breadcrumbJanitor:Cleanup()
	local itemType = self.Instance:GetAttribute("ItemType")
	local v3 = itemType == "Houses"

	local function isBreadcrumbedName(p: string)
		local breadcrumbTypeConfig = getBreadcrumbTypeConfig(itemType) -- equivalent call inferred; original call site unknown

		if breadcrumbTypeConfig ~= nil and breadcrumbTypeConfig[p] ~= nil then
			return true
		end

		if v3 then
			local mansions = BreadcrumbConfig.GetConfig().Mansions

			if mansions ~= nil and mansions[p] ~= nil then
				return true
			end
		end

		return false
	end

	local flag2 = false

	for _, scrollingFrame in self.scrollingFrames do
		local loadableEntries = scrollingFrame.loadableEntries

		if loadableEntries == nil then
			continue
		end

		flag2 = true

		if not flag then
			loadableEntries:SetFilter(function(value)
				local name = nil

				if typeof(value) == "Instance" then
					name = value.Name
				elseif typeof(value) == "table" then
					if typeof(value.GetName) == "function" then
						name = value:GetName()
					elseif typeof(value.Name) == "string" then
						name = value.Name
					end
				end

				if name == nil then
					return false
				end

				local breadcrumbTypeConfig = getBreadcrumbTypeConfig(itemType) -- equivalent call inferred; original call site unknown

				if breadcrumbTypeConfig ~= nil and breadcrumbTypeConfig[name] ~= nil then
					return true
				end

				if v3 then
					local mansions = BreadcrumbConfig.GetConfig().Mansions

					if mansions ~= nil and mansions[name] ~= nil then
						return true
					end
				end

				return false
			end)
		end
	end

	if flag2 then
		self.framesToIsolate = {}
		self.framesToHide = {}
		self.breadcrumbListTrackersToForceValidate = {}
	else
		self:SetupFramesToIsolate()

		for _, v4 in self.framesToHide do
			v4.Visible = false
		end

		for _, v4 in self.framesToIsolate do
			v4.Visible = true
		end

		for _, scrollingFrame in self.scrollingFrames do
			if scrollingFrame.scrollingFrame and not self.isIsolated then
				scrollingFrame.scrollingFrame.CanvasPosition = Vector2.zero
			end

			self._breadcrumbJanitor:Add(scrollingFrame.scrollingFrame.ChildAdded:Once(function(_)
				if self.deferredThread then
					return
				end

				self.deferredThread = task.defer(function()
					if not self.isIsolated then
						return
					end

					self:IsolateBreadcrumbs(true)
				end)
			end))
			self._breadcrumbJanitor:Add(scrollingFrame.scrollingFrame.ChildRemoved:Once(function(_)
				if self.deferredThread then
					return
				end

				self.deferredThread = task.defer(function()
					if not self.isIsolated then
						return
					end

					self:IsolateBreadcrumbs(true)
				end)
			end))
		end

		for _, v4 in self.breadcrumbListTrackersToForceValidate do
			v4:ForceValidateBreadcrumbs()
		end
	end
end

function v:RemoveBreadcrumbs()
	self._breadcrumbJanitor:Cleanup()

	for _, scrollingFrame in self.scrollingFrames do
		local loadableEntries = scrollingFrame.loadableEntries

		if loadableEntries == nil then
			continue
		end

		loadableEntries:SetFilter(nil)

		if loadableEntries.LoadNextBatch ~= nil then
			loadableEntries:LoadNextBatch()
		end
	end

	for _, v3 in self.framesToHide or {} do
		v3.Visible = true
	end

	for _, v3 in self.framesToIsolate or {} do
		v3.Visible = true
	end

	for _, scrollingFrame in self.scrollingFrames do
		if not scrollingFrame.scrollingFrame then
			continue
		end

		local uIGridLayout = scrollingFrame.scrollingFrame:FindFirstChild("UIGridLayout")

		if not uIGridLayout then
			continue
		end

		local absoluteContentSize = uIGridLayout.AbsoluteContentSize
		local uDim = UDim2.new(0, 0, 0, absoluteContentSize.Y)
		scrollingFrame.scrollingFrame.CanvasSize = uDim
	end

	self.framesToIsolate = {}
	self.framesToHide = {}
	self.breadcrumbListTrackersToForceValidate = {}
end

function v.IsActiveIsolating(p)
	return p.isIsolated
end

function v:ToggleOff()
	self.Instance:RemoveTag("Checked")
	task.spawn(function()
		local v3

		if self.Instance:GetAttribute("NotifyCenter") then
			v3 = NotificationController.NotifyCenterSmall
		else
			v3 = NotificationController.Notify
		end

		v3("Filter: All Items", 1)
	end)
	self:RefreshVisibility()
	self:RemoveBreadcrumbs()

	if self.altQuickSurfaceButton then
		self.altQuickSurfaceButton:ToggleOff()
	end

	self.isIsolated = false
end

function v:ToggleOn()
	self.Instance:AddTag("Checked")
	task.spawn(function()
		local v3

		if self.Instance:GetAttribute("NotifyCenter") then
			v3 = NotificationController.NotifyCenterSmall
		else
			v3 = NotificationController.Notify
		end

		v3("Filter: New Items ONLY", 1)
	end)
	self:RefreshVisibility()
	self:IsolateBreadcrumbs()

	if self.altQuickSurfaceButton then
		self.altQuickSurfaceButton:ToggleOn()
	end

	self.isIsolated = true
end

function v:Start()
	if not self.Instance.Parent then
		return
	end

	self.isIsolated = false
	local altQuickSurfaceButton = self.Instance:FindFirstChild("AltQuickSurfaceButton")
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		if altQuickSurfaceButton then
			self.altQuickSurfaceButton = self.altQuickSurfaceButton or v:WaitForInstance(altQuickSurfaceButton.Value):expect()
		end

		if self.isIsolated then
			self:ToggleOff()
		else
			self:ToggleOn()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
	self._breadcrumbJanitor:Destroy()
end

return v