local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local PropsUtil = require(ReplicatedStorage.Modules.Shared.Housing.PropsUtil)
local VehicleAttachedProps = require(ReplicatedStorage.Modules.Shared.Game.Vehicles.VehicleAttachedProps)
local v = Component.new({
	Tag = "VehicleProps"
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
end

function v:Start()
	local frame = self.Instance.OuterBox.Frame
	local scrollingFrame = frame.Props.Container.ScrollingFrame
	local template = scrollingFrame.Template
	self._sortedProps = self.scope:Computed(function(use, _)
		local _props = use(self._props)
		local _props2 = table.create(#_props)

		for _, _prop in _props do
			table.insert(_props2, _prop)
		end

		return _props2
	end)
	self.scope:Hydrate(frame.Props.Container.NoProps)({
		Visible = self.scope:Computed(function(use, _)
			return next(use(self._sortedProps)) == nil
		end)
	})
	self.scope:Hydrate(frame.Props.Header.TextLabel)({
		Text = self.scope:Computed(function(use, _)
			return string.format("Vehicle Prop Manager (%d)", #use(self._props))
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
			PanelController.Close("MainGUIHandler", "VehicleProps")
			waitForAncestorComponent:Init(
				`Remove all {#Fusion.peek(self._props)} props from your vehicles?`,
				function(flag: boolean)
					if flag then
						Remotes.fireServer("VS_PropDeleteAll")
					end

					PanelController.OpenPanelByContext("MainGUIHandler", "VehicleProps")
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
					Remotes.fireServer("VS_PropDelete", instance)
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
				self._props:set(VehicleAttachedProps.CollectOwnedVehicleProps(Players.LocalPlayer))

				if self._overlayPanel ~= nil and self._overlayPanel:IsOpen() and self._propCameraViewComponent ~= nil then
					self._propCameraViewComponent:UpdateProps(Fusion.peek(self._sortedProps))
				end

				flag2 = false
			end
		end)
	end

	self._panel = PanelController.WaitForPanel("MainGUIHandler", "VehicleProps")

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
					self._props:set(VehicleAttachedProps.CollectOwnedVehicleProps(Players.LocalPlayer))

					if self._overlayPanel ~= nil and self._overlayPanel:IsOpen() and self._propCameraViewComponent ~= nil then
						self._propCameraViewComponent:UpdateProps(Fusion.peek(self._sortedProps))
					end

					flag2 = false
				end
			end)
		end
	end

	self._panel:RegisterListener(self, self._panel.Events.Closing, function(_)
		if flag == nil then
			flag = true
		end

		updateProps() -- equivalent call inferred; original call site unknown
	end)
	self._overlayPanel = PanelController.WaitForPanel("MainGUIHandler", "VehiclePropCameraOverlay")

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
	if self._overlayPanel == nil or self._overlayPanel:IsOpen() or self._propCameraViewComponent == nil then
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
	PanelController.Close("MainGUIHandler", "VehicleProps")
	PanelController.Open("MainGUIHandler", "VehiclePropCameraOverlay")
end

function v:Stop()
	self._Janitor:Destroy()
	Fusion.doCleanup(self.scope)
end

return v