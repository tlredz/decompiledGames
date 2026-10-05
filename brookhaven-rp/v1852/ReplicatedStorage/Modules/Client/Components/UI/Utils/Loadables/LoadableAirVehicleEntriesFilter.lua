local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
local DatabaseRemoteConfigController = require(ReplicatedStorage.Modules.Client.Databases.DatabaseRemoteConfigController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local AirVehiclesConfig = require(ReplicatedStorage.Modules.Shared.DB.Vehicles.AirVehiclesConfig)
local v = Component.new({
	Tag = "LoadableAirVehicleEntriesFilter"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function convertToDisplayString(passRequired: string)
	return (passRequired:gsub("_", " "):lower():gsub("(%a)([%w_']*)", function(value, p)
		return value:upper() .. p
	end))
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.Loaded = Signal.new()
	self.Added = Signal.new()
	self.Unloaded = Signal.new()
	self.CategoryChanged = Signal.new()
	self.EntryClicked = Signal.new()
	self._Janitor:Add(self.Loaded)
	self._Janitor:Add(self.Added)
	self._Janitor:Add(self.Unloaded)
	self._Janitor:Add(self.EntryClicked)
	self._currentCategory = nil
	self._itemsPerBatch = self.Instance:GetAttribute("LoadableVehicleEntriesItemsPerBatch") or 30
	self._panel = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "Panel", Panel)
	self._entryValues = {}

	for _, v2 in AirVehiclesConfig.GetConfig() do
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
	assert(self._template ~= nil, "Template not found in LoadableAirVehicleEntriesFilter")
	assert(not self._template.Visible, "Template is visible in LoadableAirVehicleEntriesFilter")
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

	self._entryValues = {}

	for _, v2 in AirVehiclesConfig.GetConfig() do
		if v2.Category == self._currentCategory then
			table.insert(self._entryValues, v2)
		end
	end

	table.sort(self._entryValues, function(a, b)
		return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
	end)
	self:RefreshFilter()
	Platform.Select(self._panel.Instance)
end

function v:RefreshFilter()
	self.Instance.CanvasPosition = Vector2.new(0, 0)
	self._entryValues = {}

	for _, v2 in AirVehiclesConfig.GetConfig() do
		if not (self.BreadcrumbsFilter == nil or self.BreadcrumbsFilter(v2)) then
			continue
		end

		if self._currentCategory == nil then
			if self.CategoryFilter == nil and self.GamepassFilter == nil and v2.Category ~= self._currentCategory or self.GamepassFilter ~= nil and not self.GamepassFilter(v2) or self.CategoryFilter ~= nil and not self.CategoryFilter(v2) then
				continue
			end
		elseif v2.Category ~= self._currentCategory then
			continue
		end

		table.insert(self._entryValues, v2)
	end

	table.sort(self._entryValues, function(a, b)
		return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
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
			return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
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

		if _entryValue.HideInUI or not (not FeatureFlagsConfig.HasFeatureFlag(_entryValue.Name) or FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(
			Players.LocalPlayer,
			_entryValue.Name
		)) then
			continue
		end

		local clone = self._template:Clone()
		clone:SetAttribute("LoadableCloned", true)
		clone.Name = _entryValue.Name
		clone.Icon.Image = `rbxassetid://{_entryValue.Icon}`

		if _entryValue.CornerIcon then
			clone.CornerIcon.Image = `rbxassetid://{_entryValue.CornerIcon}`
		elseif _entryValue.PassRequired == "PREMIUM" then
			clone.CornerIcon.Image = "rbxassetid://6010710098"
		elseif _entryValue.PassRequired == "VIP" then
			clone.CornerIcon.Image = "rbxassetid://18248037214"
		end

		local v3 = _entryValue
		self._Janitor:Add(clone.Activated:Connect(function()
			if not v3.PassRequired then
				self.EntryClicked:Fire(v3)
				return
			end

			local gamepass = Gamepasses[v3.PassRequired]
			local adFeature = AdFeatures[v3.AdFeature]
			local v5 = convertToDisplayString(v3.PassRequired) -- equivalent call inferred; original call site unknown
			local showAds = v3.ShowAds

			if not adFeature and gamepass and UnlockableController.IsFeatureUnlocked(v3.Name, gamepass) then
				self.EntryClicked:Fire(v3)
			elseif adFeature and gamepass and UnlockableController.IsFeatureUnlocked(adFeature.id, gamepass) then
				self.EntryClicked:Fire(v3)
			else
				GamepassController.Show(
					gamepass,
					clone.CornerIcon.Image,
					"air vehicle",
					nil,
					showAds and adFeature or nil,
					`You need to buy {v5} to use this!`,
					"Air Vehicle Inventory",
					v3.Name,
					function()
						if clone.Parent == nil then
							return
						end

						self.EntryClicked:Fire(v3)
					end
				)
			end
		end))
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
	self.GamepassFilter = AirVehiclesConfig.IsGamepass
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
			if p2.Filter == nil then
				return false
			end

			if typeof(p2.Filter) == "string" then
				return p2.Filter == p
			end

			return table.find(p2.Filter, p) ~= nil
		end
	end

	self:RefreshFilter()
end

return v