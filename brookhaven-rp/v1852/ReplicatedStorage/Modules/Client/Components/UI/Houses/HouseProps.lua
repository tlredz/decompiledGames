local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local Component = require(ReplicatedStorage.Packages.Component)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Props = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Props)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local PropCameraOverlay = require(ReplicatedStorage.Modules.Client.UI.PrivateServer.Props.PropCameraOverlay)
local LazyScrollingFrame = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.ScrollingFrames.LazyScrollingFrame)
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local PropsLimitClient = require(ReplicatedStorage.Modules.Client.Props.PropsLimitClient)
local PropsUtil = require(ReplicatedStorage.Modules.Shared.Housing.PropsUtil)
local PrivateServerPropLimits = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerPropLimits)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local v = Component.new({
	Tag = "HouseProps"
})
local entriesByName = {}

for _, entry in Props.Entries do
	if not entry.IsCategory then
		entriesByName[entry.Name] = entry
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getImageUrl(id: string)
	local v2 = entriesByName[id]

	if v2 == nil or not v2.Id then
		return ""
	end

	return "rbxthumb://type=Asset&id=" .. v2.Id .. "&w=150&h=150"
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.scope = Fusion.scoped(Fusion)
	self._props = self.scope:Value({})
	self.propLimit = self.scope:Value(PropsLimitClient.GetPropLimit(false))
end

function v:_GetCurrentLotId()
	local playerBagInstance = PlayerBagUtil.GetPlayerBagInstance(Players.LocalPlayer, "HouseNumber")

	if playerBagInstance == nil then
		return nil
	end

	local value = playerBagInstance.Value

	if value == nil or value == 0 then
		return nil
	end

	return value
end

function v:Start()
	local frame = self.Instance.OuterBox.Frame
	local scrollingFrame = frame.Props.Container.ScrollingFrame
	local template = scrollingFrame.Template
	GamepassController.WaitForGamepasses()
	self.propLimit:set(PropsLimitClient.GetPropLimit(GamepassController.IsOwned(Gamepasses.VIP)))

	local function refreshPropLimit()
		self.propLimit:set(PropsLimitClient.GetPropLimit(GamepassController.IsOwned(Gamepasses.VIP)))
	end

	self._Janitor:Add(CountableDevProductController.GetCountChangedSignal(CountableDevProducts.PUBLIC_SERVER_PROP_LIMIT):Connect(refreshPropLimit))
	self._Janitor:Add(CountableDevProductController.GetCountChangedSignal(CountableDevProducts.PRIVATE_SERVER_PROP_LIMIT):Connect(refreshPropLimit))
	self._Janitor:Add(Workspace:GetAttributeChangedSignal(PrivateServerPropLimits.WORKSPACE_ATTR):Connect(refreshPropLimit))
	self._Janitor:Add(Workspace:GetAttributeChangedSignal(PropsUtil.DEBUG_PROP_LIMIT_ATTR):Connect(refreshPropLimit))
	self._Janitor:Add(GamepassController.OnGamepassUnlocked:Connect(refreshPropLimit))
	self._sortedProps = self.scope:Computed(function(use, _)
		local _props = use(self._props)
		local _props2 = table.create(#_props)

		for _, _prop in _props do
			table.insert(_props2, _prop)
		end

		table.sort(_props2, function(a, b)
			local id = a:GetAttribute("id")
			local id2 = b:GetAttribute("id")

			if id == id2 then
				return (a:GetAttribute("PlacedAt") or 0) < (b:GetAttribute("PlacedAt") or 0)
			end

			return tostring(id) < tostring(id2)
		end)
		return _props2
	end)
	self.scope:Hydrate(frame.Props.Container.NoProps)({
		Visible = self.scope:Computed(function(use, _)
			return next(use(self._sortedProps)) == nil
		end)
	})
	self.scope:Hydrate(frame.Props.Header.TextLabel)({
		Text = self.scope:Computed(function(use, _)
			return string.format("House Prop Manager (%d/%d)", #use(self._props), use(self.propLimit))
		end)
	})
	self.scope:Hydrate(frame.Props.Header.DeleteProps)({
		[Fusion.OnEvent("Activated")] = function()
			local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")

			if not panel then
				return
			end

			local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
				panel.Instance,
				"ConfirmationPanel",
				ConfirmationPanel
			)
			PanelController.Close("MainGUIHandler", "HouseProps")
			waitForAncestorComponent:Init(
				`Remove all {#Fusion.peek(self._props)} props from this house?`,
				function(flag: boolean)
					if flag then
						local _GetCurrentLotId = self:_GetCurrentLotId()

						if _GetCurrentLotId ~= nil then
							local propertyPermissions = LotUtil.GetPropertyPermissions(_GetCurrentLotId)

							if propertyPermissions ~= nil then
								propertyPermissions:ClearProps()
							end
						end
					end

					PanelController.OpenPanelByContext("MainGUIHandler", "HouseProps")
				end
			)
		end
	})
	local uIGridLayout = scrollingFrame:FindFirstChildWhichIsA("UIGridLayout")
	self._lazyState = LazyScrollingFrame.new({
		scope = self.scope,
		scrollingFrame = scrollingFrame,
		gridLayout = uIGridLayout,
		fullData = self._sortedProps,
		itemsPerBatch = 18
	})
	self._Janitor:Add(self._lazyState.janitor)
	self.scope:Hydrate(scrollingFrame)({
		[Fusion.Children] = self.scope:ForPairs(self._lazyState.visibleData, function(_, scope, key, instance)
			local id = instance:GetAttribute("id")
			local imageUrl = getImageUrl(id) -- equivalent call inferred; original call site unknown
			local v4 = scope:Hydrate(template:Clone())({
				Visible = true,
				Parent = scrollingFrame,
				Name = id,
				LayoutOrder = key
			})
			scope:Hydrate(v4.ImageLabel)({
				Image = imageUrl
			})
			scope:Hydrate(v4.View)({
				[Fusion.OnEvent("Activated")] = function()
					self:EnterCameraMode(key)
				end
			})
			scope:Hydrate(v4.Close)({
				[Fusion.OnEvent("Activated")] = function()
					Remotes.fireServer("HS_PropDelete", instance)
				end
			})
			return v4
		end)
	})
	local flag = nil
	local flag2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateProps()
		if flag2 then
			return
		end

		flag2 = true
		task.defer(function()
			if flag then
				self._props:set({})
				flag2 = false
				flag = nil
			else
				flag = nil
				local _GetCurrentLotId = self:_GetCurrentLotId()
				local v4 = _GetCurrentLotId == nil and {} or PropsUtil.CollectHouseProps(_GetCurrentLotId)
				self._props:set(v4)

				if self._overlayPanel ~= nil and self._overlayPanel:IsOpen() then
					self._propCameraViewComponent:UpdateProps(Fusion.peek(self._sortedProps))
				end

				flag2 = false
			end
		end)
	end

	self._panel = PanelController.WaitForPanel("MainGUIHandler", "HouseProps")

	local function openFun()
		flag = false
		updateProps() -- equivalent call inferred; original call site unknown
	end

	self._panel:RegisterListener(self, self._panel.Events.Opening, openFun)

	if self._panel:IsOpen() then
		flag = false

		if not flag2 then
			flag2 = true
			task.defer(function()
				if flag then
					self._props:set({})
					flag2 = false
					flag = nil
				else
					flag = nil
					local _GetCurrentLotId = self:_GetCurrentLotId()
					local v4 = _GetCurrentLotId == nil and {} or PropsUtil.CollectHouseProps(_GetCurrentLotId)
					self._props:set(v4)

					if self._overlayPanel ~= nil and self._overlayPanel:IsOpen() then
						self._propCameraViewComponent:UpdateProps(Fusion.peek(self._sortedProps))
					end

					flag2 = false
				end
			end)
		end

		PanelController.Open("MainGUIHandler", "HouseControlPanel")
	end

	self._panel:RegisterListener(self, self._panel.Events.Closing, function(_)
		if flag == nil then
			flag = true
		end

		updateProps() -- equivalent call inferred; original call site unknown
	end)
	self._overlayPanel = PanelController.WaitForPanel("MainGUIHandler", "HousePropCameraOverlay")

	if self._overlayPanel ~= nil then
		local instance = self._overlayPanel:GetInstance()
		self._propCameraViewComponent = ComponentUtil.GetComponentFromInstance(instance, PropCameraOverlay)
	end

	local placementFolder = PropsUtil.GetPlacementFolder()

	if placementFolder ~= nil then
		self._Janitor:Add(placementFolder.ChildAdded:Connect(function(model)
			if not model:IsA("Model") then
				return
			end

			updateProps() -- equivalent call inferred; original call site unknown
		end))
		self._Janitor:Add(placementFolder.ChildRemoved:Connect(function(model)
			if not model:IsA("Model") then
				return
			end

			updateProps() -- equivalent call inferred; original call site unknown
		end))
	end
end

function v:EnterCameraMode(value: number)
	if self._overlayPanel == nil or self._overlayPanel:IsOpen() then
		return
	end

	local _sortedProps = Fusion.peek(self._sortedProps)

	if #_sortedProps == 0 then
		return
	end

	local v2 = math.clamp(value, 1, #_sortedProps)
	local _sortedProp = _sortedProps[v2]

	if _sortedProp == nil or _sortedProp.PrimaryPart == nil then
		return
	end

	local boundingBox, v3 = _sortedProp:GetBoundingBox()
	local v4 = v3.Magnitude * 1.4
	local v5 = CFrame.new(boundingBox.Position) * CFrame.new(0, 0, v4)
	CameraController.SetCustomCamera(v5)
	self._propCameraViewComponent:SetProps(_sortedProps, v2)
	PanelController.Close("MainGUIHandler", "HouseProps")
	PanelController.Open("MainGUIHandler", "HousePropCameraOverlay")
end

function v:Stop()
	self._Janitor:Destroy()
	Fusion.doCleanup(self.scope)
end

return v