local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local Component = require(ReplicatedStorage.Packages.Component)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Props = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.Props)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local PropCameraOverlay = require(ReplicatedStorage.Modules.Client.UI.PrivateServer.Props.PropCameraOverlay)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local LazyScrollingFrame = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.ScrollingFrames.LazyScrollingFrame)
local CountableDevProductController = require(ReplicatedStorage.Modules.Client.Monetization.CountableDevProductController)
local CountableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.CountableDevProducts)
local PrivateServerBuildConstants = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerBuildConstants)
local PropsLimitClient = require(ReplicatedStorage.Modules.Client.Props.PropsLimitClient)
local PropLimitPurchaseController = require(ReplicatedStorage.Modules.Client.Props.PropLimitPurchaseController)
local PrivateServerPropLimits = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerPropLimits)
local PropsUtil = require(ReplicatedStorage.Modules.Shared.Housing.PropsUtil)
local v = Component.new({
	Tag = "PrivateServerProps"
})
local _001_TrafficCones = game.Workspace.WorkspaceCom:FindFirstChild("001_TrafficCones")
local color = Color3.fromRGB(0, 0, 0)
local color2 = Color3.fromRGB(100, 100, 100)
local color3 = Color3.fromRGB(255, 255, 255)
local localPlayer = Players.LocalPlayer
local entriesByName = {}

for _, entry in Props.Entries do
	if not entry.IsCategory then
		entriesByName[entry.Name] = entry
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getImageUrl(id: string)
	local v2 = entriesByName[id]

	if v2 and v2.Id then
		return "rbxthumb://type=Asset&id=" .. v2.Id .. "&w=150&h=150"
	end

	return ""
end

local function getPropsStatus()
	local count = 0

	for _, model in _001_TrafficCones:GetChildren() do
		if model:IsA("Model") then
			count += 1
		end
	end

	return count
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.scope = Fusion.scoped(Fusion)
	self._props = self.scope:Value({})
	self.selected = self.scope:Value(nil)
	self.dropdown = self.scope:Value(false)
	self.purchasedBuildSlotCount = self.scope:Value(CountableDevProductController.GetCount(CountableDevProducts.PLUS_ONE_PS_PROPS_SLOT))
	self.propLimit = self.scope:Value(PropsLimitClient.GetPropLimit(false))
	local privateServerOwner = GameUtil.GetPrivateServerOwner()
	self.players = self.scope:Computed(function(use, _)
		local v2 = {}

		for _, v3 in use(self._props) do
			local placedAt = v3:GetAttribute("PlacedAt")
			local player = v3:GetAttribute("Player")

			if v2[player] == nil then
				v2[player] = placedAt
			else
				v2[player] = math.max(v2[player], placedAt)
			end
		end

		local result = {}

		for k, _ in v2 do
			table.insert(result, k)
		end

		table.sort(result, function(a, b)
			if a == privateServerOwner == (b == privateServerOwner) then
				return v2[a] > v2[b]
			end

			return a == privateServerOwner
		end)
		return result
	end)
end

function v:Start()
	local frame = self.Instance.OuterBox.Frame
	local scrollingFrame = frame.Props.Container.ScrollingFrame
	local template = scrollingFrame.Template
	local scrollingFrame2 = frame.Props.Header.ScrollingFrame
	local template2 = scrollingFrame2.Template
	self._filteredProps = self.scope:Computed(function(use, _)
		local selected = use(self.selected)
		local _props = use(self._props)
		local _props2

		if selected == nil then
			_props2 = _props
		else
			_props2 = {}

			for _, _prop in _props do
				if _prop:GetAttribute("Player") == selected.id then
					table.insert(_props2, _prop)
				end
			end
		end

		table.sort(_props2, function(a, b)
			local id = a:GetAttribute("id")
			local id2 = b:GetAttribute("id")

			if id == id2 then
				return a:GetAttribute("PlacedAt") < b:GetAttribute("PlacedAt")
			end

			return id < id2
		end)
		return _props2
	end)
	self.scope:Hydrate(frame.Props.Container.NoProps)({
		Visible = self.scope:Computed(function(use, _)
			return next(use(self._filteredProps)) == nil
		end)
	})
	self.scope:Hydrate(frame.Props.Header.TextLabel)({
		Text = self.scope:Computed(function(use, _)
			return string.format("Server Prop Manager (%d/%d)", #use(self._props), use(self.propLimit))
		end)
	})
	self._Janitor:Add(workspace:GetAttributeChangedSignal(PrivateServerPropLimits.WORKSPACE_ATTR):Connect(function()
		self.propLimit:set(PropsLimitClient.GetPropLimit(false))
	end))
	self._Janitor:Add(workspace:GetAttributeChangedSignal(PropsUtil.DEBUG_PROP_LIMIT_ATTR):Connect(function()
		self.propLimit:set(PropsLimitClient.GetPropLimit(false))
	end))
	self._Janitor:Add(CountableDevProductController.GetCountChangedSignal(CountableDevProducts.PRIVATE_SERVER_PROP_LIMIT):Connect(function()
		self.propLimit:set(PropsLimitClient.GetPropLimit(false))
	end))
	local increaseLimit = frame.Props.Header.IncreaseLimit
	local backgroundColor3 = increaseLimit.BackgroundColor3
	local computed = self.scope:Computed(function(use, _)
		use(self.propLimit)
		return PropsLimitClient.IsAtPrivateServerMax()
	end)
	self.scope:Hydrate(increaseLimit)({
		Visible = GameUtil.IsPrivateServerOwner(localPlayer),
		Interactable = self.scope:Computed(function(use, _)
			return not use(computed)
		end),
		BackgroundColor3 = self.scope:Computed(function(use, _)
			if use(computed) then
				return color2
			end

			return backgroundColor3
		end),
		[Fusion.OnEvent("Activated")] = function()
			PropLimitPurchaseController.PromptIncrease("PrivateServerProps:IncreaseLimit")
		end
	})
	self.scope:Hydrate(frame.Props.Header.Selection)({
		[Fusion.OnEvent("Activated")] = function()
			self.dropdown:set(not Fusion.peek(self.dropdown))
		end
	})
	self.scope:Hydrate(frame.Props.Header.Selection.ImageLabel)({
		Image = self.scope:Computed(function(use, _)
			local selected = use(self.selected)

			if selected == nil then
				return "rbxassetid://105412920426020"
			end

			return selected.icon
		end)
	})
	self.scope:Hydrate(frame.Props.Header.Selection.TextLabel)({
		Text = self.scope:Computed(function(use, _)
			local selected = use(self.selected)

			if selected == nil then
				return "All Players"
			end

			return selected.name
		end)
	})
	local getMoreSlots = frame.Builds.Frame.GetMoreSlots
	local backgroundColor32 = getMoreSlots.BackgroundColor3
	local text = getMoreSlots.Text
	local computed2 = self.scope:Computed(function(use, _)
		return use(self.purchasedBuildSlotCount) >= CountableDevProducts.GetMax(CountableDevProducts.PLUS_ONE_PS_PROPS_SLOT)
	end)
	self.scope:Hydrate(getMoreSlots)({
		Text = self.scope:Computed(function(use, _)
			if use(computed2) then
				return "Max Save Slots Reached"
			end

			return text
		end),
		BackgroundColor3 = self.scope:Computed(function(use, _)
			if use(computed2) then
				return color2
			end

			return backgroundColor32
		end),
		TextColor3 = self.scope:Computed(function(use, _)
			if use(computed2) then
				return color3
			end

			return color
		end),
		Interactable = self.scope:Computed(function(use, _)
			return not use(computed2)
		end),
		[Fusion.OnEvent("Activated")] = function()
			if Fusion.peek(computed2) then
				return
			end

			if CountableDevProductController.PromptPurchase(
				CountableDevProducts.PLUS_ONE_PS_PROPS_SLOT,
				"PrivateServerProps:GetMoreSlots"
			) == "BACKEND_ERROR" then
				task.spawn(NotificationController.Notify, "Something went wrong, please try again.")
			end
		end
	})
	local userThumbnailAsyncs = {}
	local v5 = {}
	self.scope:Hydrate(scrollingFrame2.AllPlayers)({
		[Fusion.OnEvent("Activated")] = function()
			self.selected:set(nil)
			self.dropdown:set(false)
		end
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
			PanelController.Close("MainGUIHandler", "PrivateServerProps")
			waitForAncestorComponent:Init(
				`Remove all {getPropsStatus()} props from the server?`,
				function(flag: boolean)
					if flag then
						Remotes.fireServer("PS_PropDeleteAll")
					end

					PanelController.OpenPanelByContext("MainGUIHandler", "PrivateServerProps")
				end
			)
		end
	})
	self.scope:Hydrate(scrollingFrame2)({
		Visible = self.dropdown,
		[Fusion.Children] = self.scope:ForPairs(self.players, function(_, scope, key, value)
			local v10 = scope:Hydrate(template2:Clone())({
				Visible = true,
				Parent = scrollingFrame2,
				Name = value,
				LayoutOrder = key,
				[Fusion.OnEvent("Activated")] = function()
					self.selected:set({
						name = v5[value] or "",
						icon = userThumbnailAsyncs[value] or "",
						id = value
					})
					self.dropdown:set(false)
				end
			})

			if v5[value] == nil then
				local success, result = pcall(function()
					return Players:GetNameFromUserIdAsync(value)
				end)

				if success then
					v5[value] = result
				end
			end

			scope:Hydrate(v10.TextLabel)({
				Text = v5[value] or ""
			})
			local headShot = Enum.ThumbnailType.HeadShot
			local size60x60 = Enum.ThumbnailSize.Size60x60

			if userThumbnailAsyncs[value] == nil then
				local success, userThumbnailAsync, v11 = pcall(
					Players.GetUserThumbnailAsync,
					Players,
					value,
					headShot,
					size60x60
				)

				if success and v11 then
					userThumbnailAsyncs[value] = userThumbnailAsync
				end
			end

			scope:Hydrate(v10.ImageLabel)({
				Image = userThumbnailAsyncs[value] or ""
			})
			return v10
		end)
	})
	local uIGridLayout = scrollingFrame:FindFirstChildWhichIsA("UIGridLayout")
	self._lazyState = LazyScrollingFrame.new({
		scope = self.scope,
		scrollingFrame = scrollingFrame,
		gridLayout = uIGridLayout,
		fullData = self._filteredProps,
		itemsPerBatch = 18
	})
	self._Janitor:Add(self._lazyState.janitor)
	self.scope:Hydrate(scrollingFrame)({
		[Fusion.Children] = self.scope:ForPairs(self._lazyState.visibleData, function(_, scope, key, instance)
			local id = instance:GetAttribute("id")
			local imageUrl = getImageUrl(id) -- equivalent call inferred; original call site unknown
			local v10 = scope:Hydrate(template:Clone())({
				Visible = true,
				Parent = scrollingFrame,
				Name = id,
				LayoutOrder = key
			})
			scope:Hydrate(v10.ImageLabel)({
				Image = imageUrl
			})
			scope:Hydrate(v10.View)({
				[Fusion.OnEvent("Activated")] = function()
					self:EnterCameraMode(key)
				end
			})
			scope:Hydrate(v10.Close)({
				[Fusion.OnEvent("Activated")] = function()
					Remotes.fireServer("PS_PropDelete", instance)
				end
			})
			return v10
		end)
	})
	local list = frame.Builds.List
	local template3 = list.Template
	template3.Visible = false
	local uIListLayout = list:FindFirstChild("UIListLayout")
	local uIPadding = list:FindFirstChild("UIPadding")
	assert(uIListLayout, "PrivateServerProps: missing UIListLayout on Builds.List")
	assert(uIPadding, "PrivateServerProps: missing UIPadding on Builds.List")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBuildsListCanvasSize()
		local offset = uIPadding.PaddingBottom.Offset
		list.CanvasSize = UDim2.fromOffset(0, uIListLayout.AbsoluteContentSize.Y + offset)
	end

	updateBuildsListCanvasSize() -- equivalent call inferred; original call site unknown
	self._Janitor:Add(uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateBuildsListCanvasSize))
	local v10 = Remotes.invokeServer("PS_PropBuildNames") or {}
	local v11 = {}
	local clones = {}

	local function getOrCreateBuildSlot(name: string)
		local v12 = clones[name]

		if v12 ~= nil then
			return v12
		end

		local slotIndex = PrivateServerBuildConstants.GetSlotIndex(name)

		if slotIndex == nil then
			return nil
		end

		local clone = template3:Clone()
		clone.Name = name
		clone.Visible = true
		clone.LayoutOrder = slotIndex
		clone.Parent = list
		clones[name] = clone
		return clone
	end

	local function initBuildSlotText(p: string, clone)
		local textBox = clone.Edit.TextBox

		if textBox:GetAttribute("Renaming") then
			return
		end

		local text2 = v10[p]

		if text2 == nil then
			local slotIndex = PrivateServerBuildConstants.GetSlotIndex(p)

			if slotIndex ~= nil then
				text2 = "Build #" .. tostring(slotIndex)
			end
		end

		if text2 == nil then
			return
		end

		textBox.Text = text2
		textBox.TextEditable = false
		textBox.Interactable = false
		textBox:SetAttribute("Renaming", nil)
		textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		textBox.PlaceholderText = "Loading..."
	end

	local function setupBuildSlot(p: string, clone)
		if v11[p] then
			return
		end

		local load = clone.Load
		local save = clone.Save
		local edit = clone.Edit
		local textBox = edit.TextBox
		v11[p] = true
		local size = clone.Size
		self.scope:Hydrate(clone)({
			Visible = self.scope:Computed(function(use, _)
				return PrivateServerBuildConstants.IsSlotUnlocked(p, use(self.purchasedBuildSlotCount))
			end),
			Size = self.scope:Computed(function(use, _)
				local v12 = PrivateServerBuildConstants.GetUnlockedSlotCount(use(self.purchasedBuildSlotCount)) > PrivateServerBuildConstants.FREE_SLOTS and 0.045 or size.Y.Scale
				return UDim2.new(size.X.Scale, size.X.Offset, v12, size.Y.Offset)
			end)
		})
		local flag = false
		self.scope:Hydrate(load)({
			[Fusion.OnEvent("Activated")] = function()
				if flag then
					return
				end

				local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")

				if not panel then
					return
				end

				local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
					panel.Instance,
					"ConfirmationPanel",
					ConfirmationPanel
				)
				PanelController.Close("MainGUIHandler", "PrivateServerProps")
				local houseSpinner = localPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("HouseSpinner")
				local loadingBool = localPlayer.PlayerGui:WaitForChild("Player8Handler"):WaitForChild("LoadingBool")
				local spinner = houseSpinner:WaitForChild("Spinner")

				local function LoadingGui()
					while loadingBool.Value ~= false do
						task.wait(0.05)
						spinner.Rotation += 30
					end
				end

				waitForAncestorComponent:Init(
					"Importing a build will REMOVE ALL props currently spawned!",
					function(flag2: boolean)
						if flag2 and not flag then
							flag = true
							pcall(function()
								if loadingBool.Value == false then
									loadingBool.Value = true
									houseSpinner.Visible = true
									task.spawn(LoadingGui)
								end

								local v13 = Remotes.invokeServer("PS_PropBuildLoad", p)

								if v13 then
									task.spawn(NotificationController.Notify, "Loaded props")
								elseif v13 == nil then
									task.spawn(
										NotificationController.Notify,
										"Build has no props; save something first!"
									)
								else
									task.spawn(NotificationController.Notify, "Error loading props, please try again")
								end
							end)
							flag = false
							loadingBool.Value = false
							houseSpinner.Visible = false
						end

						if not flag2 then
							PanelController.OpenPanelByContext("MainGUIHandler", "PrivateServerProps")
						end
					end
				)
			end
		})
		self.scope:Hydrate(save)({
			[Fusion.OnEvent("Activated")] = function()
				if flag then
					return
				end

				local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")

				if not panel then
					return
				end

				local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
					panel.Instance,
					"ConfirmationPanel",
					ConfirmationPanel
				)
				PanelController.Close("MainGUIHandler", "PrivateServerProps")
				local propsStatus = getPropsStatus()
				waitForAncestorComponent:Init(
					`Overwite {v10[p] or p} with {propsStatus} props? Props on houses or vehicles will NOT be saved!`,
					function(flag2: boolean)
						if flag2 and not flag then
							flag = true
							pcall(function()
								local v14 = Remotes.invokeServer("PS_PropBuildSave", p)

								if v14 then
									task.spawn(NotificationController.Notify, "Saved props")
								elseif v14 == nil then
									task.spawn(NotificationController.Notify, "No props to save; add some props!")
								else
									task.spawn(NotificationController.Notify, "Error saving props, please try again")
								end
							end)
							flag = false
						end

						PanelController.OpenPanelByContext("MainGUIHandler", "PrivateServerProps")
					end
				)
			end
		})
		self.scope:Hydrate(edit)({
			[Fusion.OnEvent("Activated")] = function()
				textBox:ReleaseFocus(true)

				if textBox:GetAttribute("Renaming") then
					return
				end

				textBox.TextEditable = true
				textBox.PlaceholderText = "Enter build name..."
				textBox.Interactable = true
				textBox:CaptureFocus()
			end
		})
		self.scope:Hydrate(textBox)({
			[Fusion.OnEvent("FocusLost")] = function()
				textBox.TextEditable = false
				textBox.Interactable = false
				textBox:SetAttribute("Renaming", true)
				textBox.TextColor3 = Color3.fromRGB(178, 178, 178)
				local v16 = Remotes.invokeServer("PS_PropBuildRename", p, textBox.Text)
				textBox:SetAttribute("Renaming", nil)
				textBox.TextColor3 = Color3.fromRGB(255, 255, 255)

				if v16 ~= nil then
					v10[p] = v16
				end

				textBox.Text = v10[p] or v16 or textBox.Text
			end
		})
	end

	local function refreshBuildNames()
		local v12 = Remotes.invokeServer("PS_PropBuildNames")

		if v12 == nil then
			return
		end

		for k, v13 in v12 do
			v10[k] = v13
			local clone = clones[k]

			if clone == nil then
				local slotIndex = PrivateServerBuildConstants.GetSlotIndex(k)

				if slotIndex == nil then
					clone = nil
				else
					clone = template3:Clone()
					clone.Name = k
					clone.Visible = true
					clone.LayoutOrder = slotIndex
					clone.Parent = list
					clones[k] = clone
				end
			end

			if clone ~= nil then
				initBuildSlotText(k, clone)
			end
		end
	end

	local function ensureBuildSlotsSetup(p: number)
		for _, name in PrivateServerBuildConstants.GetUnlockedSlotNames(p) do
			local clone = clones[name]

			if clone == nil then
				local slotIndex = PrivateServerBuildConstants.GetSlotIndex(name)

				if slotIndex == nil then
					clone = nil
				else
					clone = template3:Clone()
					clone.Name = name
					clone.Visible = true
					clone.LayoutOrder = slotIndex
					clone.Parent = list
					clones[name] = clone
				end
			end

			if clone == nil then
				continue
			end

			initBuildSlotText(name, clone)
			setupBuildSlot(name, clone)
		end
	end

	for _, name in PrivateServerBuildConstants.GetUnlockedSlotNames(Fusion.peek(self.purchasedBuildSlotCount)) do
		local clone = clones[name]

		if clone == nil then
			local slotIndex = PrivateServerBuildConstants.GetSlotIndex(name)

			if slotIndex == nil then
				clone = nil
			else
				clone = template3:Clone()
				clone.Name = name
				clone.Visible = true
				clone.LayoutOrder = slotIndex
				clone.Parent = list
				clones[name] = clone
			end
		end

		if clone == nil then
			continue
		end

		initBuildSlotText(name, clone)
		setupBuildSlot(name, clone)
	end

	self._Janitor:Add(CountableDevProductController.GetCountChangedSignal(CountableDevProducts.PLUS_ONE_PS_PROPS_SLOT):Connect(function(p: number)
		self.purchasedBuildSlotCount:set(p)
		refreshBuildNames()
		ensureBuildSlotsSetup(p)
	end))
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
				local models = {}

				for _, model in _001_TrafficCones:GetChildren() do
					if model:IsA("Model") then
						table.insert(models, model)
					end
				end

				table.sort({ 1, 2 }, function(a, b)
					self._props:set(models)

					if self._overlayPanel ~= nil and self._overlayPanel:IsOpen() then
						self._propCameraViewComponent:UpdateProps(Fusion.peek(self._filteredProps))
					end

					return b < a
				end)
				flag2 = false
			end
		end)
	end

	self._panel = PanelController.WaitForPanel("MainGUIHandler", "PrivateServerProps")

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
					local models = {}

					for _, model in _001_TrafficCones:GetChildren() do
						if model:IsA("Model") then
							table.insert(models, model)
						end
					end

					table.sort({ 1, 2 }, function(a, b)
						self._props:set(models)

						if self._overlayPanel ~= nil and self._overlayPanel:IsOpen() then
							self._propCameraViewComponent:UpdateProps(Fusion.peek(self._filteredProps))
						end

						return b < a
					end)
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
	self._overlayPanel = PanelController.WaitForPanel("MainGUIHandler", "PropCameraOverlay")
	local instance = self._overlayPanel:GetInstance()
	self._propCameraViewComponent = ComponentUtil.GetComponentFromInstance(instance, PropCameraOverlay)
	self._Janitor:Add(_001_TrafficCones.ChildAdded:Connect(function(model)
		if not model:IsA("Model") then
			return
		end

		updateProps() -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(_001_TrafficCones.ChildRemoved:Connect(function(model)
		if not model:IsA("Model") then
			return
		end

		updateProps() -- equivalent call inferred; original call site unknown
	end))
end

function v:EnterCameraMode(value: number)
	if self._overlayPanel == nil or self._overlayPanel:IsOpen() then
		return
	end

	local _filteredProps = Fusion.peek(self._filteredProps)

	if #_filteredProps == 0 then
		return
	end

	local v2 = math.clamp(value, 1, #_filteredProps)
	local _filteredProp = _filteredProps[v2]

	if not (_filteredProp and _filteredProp.PrimaryPart) then
		return
	end

	local boundingBox, v3 = _filteredProp:GetBoundingBox()
	local v4 = v3.Magnitude * 1.4
	local v5 = CFrame.new(boundingBox.Position) * CFrame.new(0, 0, v4)
	CameraController.SetCustomCamera(v5)
	self._propCameraViewComponent:SetProps(_filteredProps, v2)
	PanelController.Close("MainGUIHandler", "PrivateServerProps")
	PanelController.Open("MainGUIHandler", "PropCameraOverlay")
end

function v:Stop()
	self._Janitor:Destroy()
	Fusion.doCleanup(self.scope)
end

return v