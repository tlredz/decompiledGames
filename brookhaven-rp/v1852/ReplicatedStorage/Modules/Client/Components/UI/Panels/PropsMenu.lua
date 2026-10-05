game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoadableEntriesFilter = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableEntriesFilter)
local ExclusionController = require(ReplicatedStorage.Modules.Client.Exclusion.ExclusionController)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local ExclusionConfig = require(ReplicatedStorage.Modules.Shared.DB.Exclusion.ExclusionConfig)
local FeatureFlagsConfig = require(ReplicatedStorage.Modules.Shared.DB.FeatureFlags.FeatureFlagsConfig)
local InteractableItem = require(ReplicatedStorage.Modules.Shared.Item.InteractableItem)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local RequirementBehaviors = require(ReplicatedStorage.Modules.Shared.RequirementBehaviors)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local ConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.ConfirmationPanel)
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local clearTools = LegacyGame8Settings.ClearTools
local props = LegacyGame8Settings.Props
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Component = require(ReplicatedStorage.Packages.Component)
local PlayerLocalizationController = require(ReplicatedStorage.Modules.Client.Player.PlayerLocalizationController)
local v = Component.new({
	Tag = "PropsMenu"
})
local uDim = UDim2.fromScale(0.156, 1)
local uDim2 = UDim2.fromScale(0.132, 1)

function v:SetCategory(p2: string)
	self._loadableEntries:SetCategory(p2)
	local uIGridLayout = self.Instance.Catalog.Header.CategoryTabs.UIGridLayout
	local cellSize

	if p2 == "Building Basics" or p2 == "Building" then
		cellSize = uDim2
	else
		cellSize = uDim
	end

	uIGridLayout.CellSize = cellSize
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	self._loadableEntries = ComponentUtil.GetComponentFromInstance(
		instance:WaitForChild("Catalog"):WaitForChild("Container"):WaitForChild("ScrollingFrame"),
		LoadableEntriesFilter
	)
	local v2 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rebuildConfig()
		table.clear(v2)

		for _, v3 in self._loadableEntries:GetConfigTable() do
			v2[v3.Name] = v3
		end
	end

	rebuildConfig() -- equivalent call inferred; original call site unknown
	self._Janitor:Add(self._loadableEntries.OnTargetModuleChanged:Connect(rebuildConfig))
	local backButton = instance.Catalog.Header.CategoryTabs.BackButton
	local v3 = nil

	local function unbindBackAction()
		if not v3 then
			return
		end

		v3()
		v3 = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bindBackAction()
		if v3 then
			return
		end

		v3 = BackActionRouter.Bind(function()
			self:SetCategory(nil)
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBackActionBinding()
		if instance.Visible and backButton.Visible then
			bindBackAction() -- equivalent call inferred; original call site unknown
		else
			if not v3 then
				return
			end

			v3()
			v3 = nil
		end
	end

	self._Janitor:Add(unbindBackAction)
	local instance2 = PanelController.GetPanel("NoResetGUIHandler", "AvatarEditorMenu").Instance
	clearTools.OnClientEvent:Connect(function(p)
		if p == "OpenPropMenu" and instance2.Visible == false then
			PanelController.ToggleGroup("MainView", false)
			PanelController.Open("NoResetGUIHandler", "PropMenuFilter")
		elseif p == "ClosePropMenu" then
			PanelController.Close("NoResetGUIHandler", "PropMenuFilter")
		end
	end)
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ClearSelectedProps()
		for _, descendant in instance.Catalog.Container.ScrollingFrame:GetDescendants() do
			if descendant.Name == "Selected" then
				descendant.Visible = false
			end
		end
	end

	local v4 = nil
	ExclusionController.OnPlayerExclusionGroupsChanged:Connect(function()
		if not v4 then
			return
		end

		local group = ExclusionConfig.GetGroupById(v4.Name)

		if not (group and ExclusionController.IsGroupExcluded(group) and v4.Parent ~= nil) then
			return
		end

		local selected = v4:FindFirstChild("Selected")
		selected.Visible = false
		clearTools:FireServer("ClearPropSelection")
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function deselectCurrentProp()
		ClearSelectedProps() -- equivalent call inferred; original call site unknown
		v4 = nil
		clearTools:FireServer("ClearPropSelection")
		local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

		if currentSelectedPropEditable ~= nil then
			currentSelectedPropEditable:Deselect()
		end
	end

	instance.Catalog.Header.CategoryTabs.BackButton.MouseButton1Click:Connect(function()
		self:SetCategory(nil)
	end)
	instance.Catalog.Header.CategoryTabs.PropOnProp.MouseButton1Click:Connect(function()
		if instance.Catalog.Header.CategoryTabs.PropOnProp.GreenCheckMark.Visible == false then
			instance.Catalog.Header.CategoryTabs.PropOnProp.GreenCheckMark.Visible = true
			props:FireServer("PropOnPropOn")
		else
			instance.Catalog.Header.CategoryTabs.PropOnProp.GreenCheckMark.Visible = false
			props:FireServer("PropOnPropOff")
		end
	end)
	instance.Catalog.Header.CategoryTabs.ClearTools.MouseButton1Click:Connect(function()
		local panel = PanelController.GetPanel("NoResetGUIHandler", "ConfirmationPanel")

		if not panel then
			return
		end

		ComponentUtil.FindAndWaitForAncestorComponent(panel.Instance, "ConfirmationPanel", ConfirmationPanel):Init(
			"Are you sure you want to clear all props?",
			function(flag: boolean)
				if flag then
					clearTools:FireServer("ClearAllProps")
					instance.PropsColor.ColorPicks.ColorPicksFrame.FinalColorA.Visible = false
					instance.PropsColor.ColorPicks.ColorPicksFrame.PaletteB.Visible = false
					instance.PropsColor.ColorPicks.ColorPicksFrame.BlockerC.Visible = false
					instance.PropsColor.ColorPicks.ColorPicksFrame.DarknessBarD.Visible = false
					instance.PropsColor.ColorPicks.ColorPicksFrame.PicksE.Visible = false
					instance.PropsModMenu.Visible = false
					ClearSelectedProps() -- equivalent call inferred; original call site unknown
				end
			end
		)
	end)

	for _, button in instance.Catalog.Header.CategoryTabs:GetChildren() do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.SelectionOrder = 2000
		end
	end

	local maid = Janitor.new()

	local function PropButtonAdded(button)
		if not (button:IsA("ImageButton") and button:GetAttribute("AttachedConnection") == nil) then
			return
		end

		local v5 = v2[button.Name]

		if not v5 then
			return
		end

		button:SetAttribute("AttachedConnection", true)

		if FeatureFlagsConfig.HasFeatureFlag(button.Name) and not FeatureFlagsConfig.IsPlayerEligibleForFeatureFlag(
			localPlayer,
			button.Name
		) then
			button.Visible = false
			return
		end

		if v5.IsCategory then
			local v6 = false

			for _, v8 in v2 do
				if v8.Category ~= v5.Name then
					continue
				end

				if not (v8.RequirementBehaviorData == nil or RequirementBehaviors.IsVisible(
					localPlayer,
					v8.RequirementBehaviorData.Behavior,
					unpack(v8.RequirementBehaviorData.Arguments)
				) or RequirementBehaviors.PassesRequirementCheck(
					localPlayer,
					v8.RequirementBehaviorData.Behavior,
					unpack(v8.RequirementBehaviorData.Arguments)
				)) then
					continue
				end

				v6 = true
				break
			end

			if not v6 then
				button.Visible = false
				return
			end
		elseif v5.RequirementBehaviorData and not (RequirementBehaviors.IsVisible(
			localPlayer,
			v5.RequirementBehaviorData.Behavior,
			unpack(v5.RequirementBehaviorData.Arguments)
		) or RequirementBehaviors.PassesRequirementCheck(
			localPlayer,
			v5.RequirementBehaviorData.Behavior,
			unpack(v5.RequirementBehaviorData.Arguments)
		)) then
			button.Visible = false
			return
		end

		button.MouseButton1Click:Connect(function()
			local currentFilter = button.Parent:GetAttribute("CurrentFilter")
			TelemetryController.SendClientInteraction("filterClick", {
				filter = button.Parent:GetAttribute("CurrentFilter"),
				itemType = button.Parent:GetAttribute("ItemType"),
				name = button.Name
			})

			if v5.IsCategory then
				if v5.CategoryDisclaimer and (not v5.USOnlyDisclaimer or PlayerLocalizationController.GetCountryRegion() == "US") then
					instance.Catalog.Container.Disclaimer.Visible = true
					instance.Catalog.Container.Disclaimer.DisclaimerText.Text = v5.CategoryDisclaimer
				end

				self:SetCategory(v5.Name)
			else
				local selected = button:FindFirstChild("Selected")

				if selected == nil or not (selected:IsA("GuiObject") and selected.Visible) then
					if v5.Item then
						local function selectItemProp()
							if button.Parent == nil or not PanelController.IsOpen("NoResetGUIHandler", "PropMenuFilter") then
								return
							end

							ClearSelectedProps() -- equivalent call inferred; original call site unknown
							local selected = button:WaitForChild("Selected")
							selected.Visible = true
							clearTools:FireServer("RequestingPropFeatureName", v5.Name, v5.Category, currentFilter)
						end

						local item = ItemRegistry.GetItem(v5.Item, InteractableItem)

						if item:IsUnlockedClient() then
							selectItemProp()
						else
							item:OnDenied(function(p)
								task.spawn(NotificationController.NotifyCenter, p, 3)
							end, "PropsMenu", selectItemProp)
						end
					elseif v5.RequirementBehaviourData then
						if RequirementBehaviors.PassesRequirementCheck(
							localPlayer,
							v5.RequirementBehaviorData.Behavior,
							unpack(v5.RequirementBehaviorData.Arguments)
						) then
							ClearSelectedProps() -- equivalent call inferred; original call site unknown
							local selected_2 = button:WaitForChild("Selected")
							selected_2.Visible = true
							clearTools:FireServer("RequestingPropFeatureName", v5.Name, v5.Category, currentFilter)
						else
							local deniedMessage = RequirementBehaviors.GetDeniedMessage(
								localPlayer,
								v5.RequirementBehaviorData.Behavior,
								unpack(v5.RequirementBehaviorData.Arguments)
							)
							task.spawn(NotificationController.NotifyCenter, deniedMessage, 3)
						end
					elseif v5.PropVIP or v5.PassRequired ~= nil then
						if v5.PropVIP then
							local function selectVipProp()
								if button.Parent == nil or not PanelController.IsOpen(
									"NoResetGUIHandler",
									"PropMenuFilter"
								) then
									return
								end

								ClearSelectedProps() -- equivalent call inferred; original call site unknown
								local selected = button:WaitForChild("Selected")
								selected.Visible = true
								clearTools:FireServer("RequestingPropVIPName", v5.Name, v5.Category, currentFilter)
							end

							if UnlockableController.IsFeatureUnlocked("Prop_" .. v5.Name, Gamepasses.VIP) then
								selectVipProp()
								return
							end

							local v6 = "rbxthumb://type=Asset&id=" .. v5.Id .. "&w=150&h=150"
							GamepassController.Show(
								Gamepasses.VIP,
								v6,
								"vip prop",
								nil,
								AdFeatures.Props()["Prop_" .. v5.Name],
								nil,
								"Prop Inventory",
								v5.Name,
								selectVipProp
							)
						elseif v5.PassRequired ~= nil then
							local function selectPassProp()
								if button.Parent == nil or not PanelController.IsOpen(
									"NoResetGUIHandler",
									"PropMenuFilter"
								) then
									return
								end

								ClearSelectedProps() -- equivalent call inferred; original call site unknown
								local selected = button:WaitForChild("Selected")
								selected.Visible = true
								clearTools:FireServer(
									"RequestingPropPassRequiredName",
									v5.Name,
									v5.Category,
									currentFilter
								)
							end

							local v6 = Gamepasses.All[v5.PassRequired]

							if UnlockableController.IsFeatureUnlocked("Prop_" .. v5.Name, v6) then
								selectPassProp()
							else
								local v7 = "rbxthumb://type=Asset&id=" .. v5.Id .. "&w=150&h=150"
								GamepassController.Show(
									v6,
									v7,
									`{v5.PassRequired} prop`,
									nil,
									AdFeatures.Props()["Prop_" .. v5.Name],
									nil,
									"Prop Inventory",
									v5.Name,
									selectPassProp
								)
							end
						end
					else
						local group = ExclusionConfig.GetGroupById(v5.Name)

						if group and ExclusionController.IsGroupExcluded(group) then
							local exclusionMessage = ExclusionController.GetExclusionMessage("You are not allowed to place this prop here.")
							NotificationController.Notify(exclusionMessage)
						else
							ClearSelectedProps() -- equivalent call inferred; original call site unknown
							v4 = button
							local selected_3 = button:WaitForChild("Selected")
							selected_3.Visible = true
							clearTools:FireServer("RequestingPropName", v5.Name, v5.Category, currentFilter)
						end
					end
				else
					deselectCurrentProp() -- equivalent call inferred; original call site unknown
				end
			end
		end)
	end

	self._Janitor:Add(self._loadableEntries.Loaded:Connect(function()
		for _, child in instance.Catalog.Container.ScrollingFrame:GetChildren() do
			PropButtonAdded(child)
		end

		maid:Add(instance.Catalog.Container.ScrollingFrame.ChildAdded:Connect(PropButtonAdded))
	end))

	if self._loadableEntries:IsLoaded() then
		for _, child in instance.Catalog.Container.ScrollingFrame:GetChildren() do
			child:SetAttribute("AttachedConnection", nil)
			PropButtonAdded(child)
		end

		maid:Add(instance.Catalog.Container.ScrollingFrame.ChildAdded:Connect(PropButtonAdded))
	end

	self._Janitor:Add(self._loadableEntries.Added:Connect(function(items)
		for _, item in items do
			PropButtonAdded(item)
		end
	end))
	self._Janitor:Add(self._loadableEntries.Unloaded:Connect(function()
		maid:Cleanup()

		for _, child in instance.Catalog.Container.ScrollingFrame:GetChildren() do
			child:SetAttribute("AttachedConnection", nil)
		end
	end))
	self._Janitor:Add(self._loadableEntries.CategoryChanged:Connect(function(p)
		instance.Catalog.Header.CategoryTabs.BackButton.Visible = p ~= nil
		local uIGridLayout = instance.Catalog.Header.CategoryTabs.UIGridLayout
		local cellSize

		if p == "Building" then
			cellSize = uDim2
		else
			cellSize = uDim
		end

		uIGridLayout.CellSize = cellSize
		updateBackActionBinding() -- equivalent call inferred; original call site unknown
		local v6 = v2[p]

		if v6 and v6.CategoryDisclaimer and (not v6.USOnlyDisclaimer or PlayerLocalizationController.GetCountryRegion() == "US") then
			instance.Catalog.Container.Disclaimer.Visible = true
			instance.Catalog.Container.Disclaimer.DisclaimerText.Text = v6.CategoryDisclaimer
			instance.Catalog.Container.PropCount.Visible = false
		else
			instance.Catalog.Container.Disclaimer.Visible = false
			instance.Catalog.Container.PropCount.Visible = true
		end
	end))
	self._Janitor:Add(instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if instance.Visible and backButton.Visible then
			bindBackAction() -- equivalent call inferred; original call site unknown
		else
			if not v3 then
				return
			end

			v3()
			v3 = nil
		end
	end))

	if instance.Visible and backButton.Visible then
		if not v3 then
			v3 = BackActionRouter.Bind(function()
				self:SetCategory(nil)
			end)
		end
	elseif v3 then
		v3()
		v3 = nil
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v