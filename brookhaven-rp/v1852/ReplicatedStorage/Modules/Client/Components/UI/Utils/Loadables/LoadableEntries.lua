local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local loadableEntries = ReplicatedStorage.Modules.Client.UI.LoadableEntries
local DatabaseRemoteConfigController = require(ReplicatedStorage.Modules.Client.Databases.DatabaseRemoteConfigController)
local v = Component.new({
	Tag = "LoadableEntries"
})

local function createInstance(data, _entryValue, layoutOrder: number)
	local clone = data._template:Clone()
	clone:SetAttribute("AttachedConnection", nil)
	clone:SetAttribute("LoadableCloned", true)

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

function v:Construct()
	self._Janitor = Janitor.new()
	self.Loaded = Signal.new()
	self.Added = Signal.new()
	self.Unloaded = Signal.new()
	self._Janitor:Add(self.Loaded)
	self._Janitor:Add(self.Added)
	self._Janitor:Add(self.Unloaded)
	self._moduleName = self.Instance:GetAttribute("LoadableEntriesModuleName")
	self._useVisibility = self.Instance:GetAttribute("LoadableEntriesUseVisibility")
	self._itemsPerBatch = self.Instance:GetAttribute("LoadableEntriesItemsPerBatch") or 30
	self._panel = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "Panel", Panel)
	local child = loadableEntries:FindFirstChild(self._moduleName)

	if child == nil then
		error("LoadableEntries module name " .. self._moduleName .. " not found")
	end

	self._module = require(child)
	self._entryValues = self._module.Entries
	self._template = self.Instance:FindFirstChild("Template")
	self._gridLayout = self.Instance:FindFirstChild("UIGridLayout")
	self._lastCanvasPosition = nil
	self._lockedCanvasHeight = nil
	self._currentIndex = 1
	self._isFullyLoaded = false
	assert(self._template ~= nil, "Template not found in LoadableEntries, was trying to load - " .. self._moduleName)
	assert(not self._template.Visible, "Template is visible in LoadableEntries")
end

function v:Start()
	GameSdkShared:WaitForLoad()
	local v2, v3 = ABTest.GetExperimentVariable("lazy-loading-all", "enabled"):timeout(10):await()
	self._isABTestEnabled = v2 and v3

	if v2 and v3 then
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
		return
	end

	self._loadingBatch = true
	local v2 = math.min(self._currentIndex + self._itemsPerBatch - 1, #self._entryValues)
	local v3 = {}

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

		table.insert(v3, (createInstance(self, _entryValue, i + 1)))
	end

	if #self._entryValues <= v2 then
		self._isFullyLoaded = true

		if self._lockedCanvasHeight ~= nil and self._gridLayout.AbsoluteContentSize.Y ~= self._lockedCanvasHeight then
			self._lockedCanvasHeight = self._gridLayout.AbsoluteContentSize.Y
			self.Instance.CanvasSize = UDim2.new(0, 0, 0, self._lockedCanvasHeight)
		end
	end

	self._currentIndex = v2 + 1
	self.Added:Fire(v3)
	self._loadingBatch = false
end

function v:CalculateCanvasSize()
	self._lockedCanvasHeight = math.ceil(#self._entryValues / self._itemsPerBatch) * self._gridLayout.AbsoluteContentSize.Y
	self.Instance.CanvasSize = UDim2.new(0, 0, 0, self._lockedCanvasHeight)
end

function v:SetFilter(callback)
	if callback == nil then
		self._entryValues = self._module.Entries
	else
		self._entryValues = {}

		for _, entry in self._module.Entries do
			if callback(entry) then
				table.insert(self._entryValues, entry)
			end
		end
	end

	self:Clear()
	self:LoadNextBatch()
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

return v