local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ButtonHintStrip = require(ReplicatedStorage.Client.ButtonHintStrip)
local GUI = require(ReplicatedStorage.Client.GUI)
local GamepadBindings = require(ReplicatedStorage.Client.GamepadBindings)
local Hud = require(ReplicatedStorage.Client.Hud)
local Log = require(ReplicatedStorage.Packages.Log)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
local Preferences = require(ReplicatedStorage.Shared.Preferences)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local InputIconsConfig = require(ReplicatedStorage.Client.InputIconsConfig)
local frozen = table.freeze({ "Message", "ActivePets", "GrowingEggs" })
local frozen2 = table.freeze({
	BackpackGui = true,
	Treadmill = true,
	TreadmillScreenButtonSwapLeft = true,
	TreadmillScreenButtonSwapRight = true,
	TreadmillScreenComments = true,
	TreadmillUI = true
})
local buttonL3 = Enum.KeyCode.ButtonL3
local buttonB = Enum.KeyCode.ButtonB
local frozen3 = table.freeze({
	BackpackGui = true,
	TopbarCentered = true,
	TopbarCenteredClipped = true,
	TopbarStandard = true,
	TopbarStandardClipped = true
})
return {
	Start = function()
		local v = Log.new()
		local folder = GUI.PlayerGui()
		local v2 = {}
		local v3 = {}
		local v4 = {}
		local v5 = {}
		local v6 = nil
		local v7 = nil
		local v8 = nil
		local v9 = nil
		local v10 = {}
		local v11 = false
		local flag = false
		local flag2 = false
		local v12 = false

		local function isVisible(p)
			return GamepadBindings.IsOnScreen(p)
		end

		local function isModalDialog(instance)
			return instance ~= nil and instance:GetAttribute("ModalDialog") == true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function settleSelection(selectedObject)
			if GuiService.SelectedObject ~= selectedObject then
				GuiService.SelectedObject = selectedObject
			end

			GuiService.GuiNavigationEnabled = selectedObject ~= nil
		end

		local function priorityScreen()
			for _, v13 in frozen do
				local screenGui = GUI.Get(v13)
				assert(screenGui:IsA("ScreenGui"), (`{v13} must be a ScreenGui`))

				if screenGui.Enabled then
					return screenGui
				end
			end

			local active = Tabs.Active()

			if active ~= nil then
				local screenGui = GUI.Get(active)
				assert(screenGui:IsA("ScreenGui"), (`Tab {active} must be a ScreenGui`))

				if screenGui.Enabled then
					return screenGui
				end
			end

			if not v12 then
				return nil
			end

			local screenGui = GUI.HUD()
			assert(screenGui:IsA("ScreenGui"), "HUD must be a ScreenGui")

			if screenGui.Enabled then
				return screenGui
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setHudNavigation(flag3: boolean, formatted: string)
			if v12 == flag3 then
				return
			end

			v12 = flag3
			GamepadBindings.EnableMarkers(not flag3)
			v:AtDebug():Log((`HUD navigation {flag3 and "ON" or "OFF"} ({formatted}); toggle key is {buttonL3.Name}`))
		end

		local function isCursorScopeMember(screenGui, ancestor)
			if screenGui == ancestor or screenGui:IsDescendantOf(ancestor) then
				return true
			end

			local v13 = v6
			local v14

			if v13 == nil then
				v14 = false
			else
				v14 = v13:GetAttribute("ModalDialog") == true
			end

			if v14 or v9 and v9.Modal then
				return false
			end

			if not screenGui:IsA("ScreenGui") then
				screenGui = screenGui:FindFirstAncestorOfClass("ScreenGui")
			end

			return screenGui ~= nil and screenGui:IsDescendantOf(folder) and (screenGui.Name == "HUD" or frozen3[screenGui.Name] == true)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function restoreSelectableButtons(root, flag3: boolean?)
			for k in v3 do
				if not (not root or k ~= root and not (k:IsDescendantOf(root) or flag3 and isCursorScopeMember(k, root))) then
					continue
				end

				if k.Parent ~= nil then
					k.Selectable = v2[k]
				end

				v3[k] = nil
				v2[k] = nil
			end
		end

		local function focusRank(instance)
			local v13 = instance:GetAttribute("DefaultFocus") == true and 0 or 2
			local v14 = instance.Name == "Close" and 1 or 0
			local absolutePosition = instance.AbsolutePosition
			return v13 + v14, instance.LayoutOrder, absolutePosition.Y, absolutePosition.X
		end

		local function outranks(instance, instance2)
			local v13 = instance:GetAttribute("DefaultFocus") == true and 0 or 2
			local v14 = instance.Name == "Close" and 1 or 0
			local absolutePosition = instance.AbsolutePosition
			local v15 = v13 + v14
			local layoutOrder = instance.LayoutOrder
			local Y = absolutePosition.Y
			local X = absolutePosition.X
			local v16 = instance2:GetAttribute("DefaultFocus") == true and 0 or 2
			local v17 = instance2.Name == "Close" and 1 or 0
			local absolutePosition2 = instance2.AbsolutePosition
			local v18 = v16 + v17
			local layoutOrder2 = instance2.LayoutOrder
			local Y2 = absolutePosition2.Y
			local X2 = absolutePosition2.X

			if v15 ~= v18 then
				return v15 < v18
			end

			if layoutOrder ~= layoutOrder2 then
				return layoutOrder < layoutOrder2
			end

			if Y == Y2 then
				return X < X2
			end

			return Y < Y2
		end

		local function projectSelectableButtons(folder2)
			local v13 = nil

			for _, button in folder2:GetDescendants() do
				if not button:IsA("GuiButton") then
					continue
				end

				local selectable = button.Active and button.Interactable and GamepadBindings.IsOnScreen(button) and button:GetAttribute("ConsoleNavigationDisabled") ~= true

				if v2[button] == nil then
					v2[button] = button.Selectable
				end

				if button.Selectable ~= selectable then
					button.Selectable = selectable
				end

				v3[button] = true

				if not selectable then
					continue
				end

				if v13 ~= nil then
					local v15 = button:GetAttribute("DefaultFocus") == true and 0 or 2
					local v16 = button.Name == "Close" and 1 or 0
					local absolutePosition = button.AbsolutePosition
					local v17 = v15 + v16
					local layoutOrder = button.LayoutOrder
					local Y = absolutePosition.Y
					local X = absolutePosition.X
					local v18 = v13:GetAttribute("DefaultFocus") == true and 0 or 2
					local v19 = v13.Name == "Close" and 1 or 0
					local absolutePosition2 = v13.AbsolutePosition
					local v20 = v18 + v19
					local layoutOrder2 = v13.LayoutOrder
					local Y2 = absolutePosition2.Y
					local X2 = absolutePosition2.X
					local v21

					if v17 == v20 then
						if layoutOrder == layoutOrder2 then
							if Y == Y2 then
								v21 = X < X2
							else
								v21 = Y < Y2
							end
						else
							v21 = layoutOrder < layoutOrder2
						end
					else
						v21 = v17 < v20
					end

					if not v21 then
						continue
					end
				end

				v13 = button
			end

			return v13
		end

		local function projectSelectionContainers(folder2, flag3: boolean)
			local function project(instance)
				if not instance:IsA("GuiObject") or instance:IsA("GuiButton") or instance:IsA("TextBox") then
					return
				end

				if v2[instance] == nil then
					if not instance.Selectable then
						return
					end

					v2[instance] = instance.Selectable
				end

				local selectable = not flag3 and v2[instance]

				if instance.Selectable ~= selectable then
					instance.Selectable = selectable
				end

				v3[instance] = true
			end

			project(folder2)

			for _, descendant in folder2:GetDescendants() do
				project(descendant)
			end
		end

		local function isEligibleSelection(ancestor, instance)
			local interactable

			if instance == nil then
				interactable = false
			else
				interactable = instance:IsDescendantOf(ancestor) and (instance:IsA("GuiButton") or instance:IsA("TextBox")) and instance.Selectable and instance.Active and instance.Interactable

				if interactable then
					if instance:GetAttribute("ConsoleNavigationDisabled") == true then
						interactable = false
					else
						interactable = GamepadBindings.IsOnScreen(instance)
					end
				end
			end

			return interactable
		end

		local function scrollTarget(value: number, p: number, p2: number, p3: number, p4: number)
			local v13 = value + p + p2 - p3
			local v14 = value + p

			if not (v14 < v13) then
				v14 = math.clamp(value, v13, v14)
			end

			return (math.clamp(v14, 0, (math.max(p4, 0))))
		end

		local function revealSelection(selectedObject)
			local parent = selectedObject.Parent

			while parent do
				if parent:IsA("ScrollingFrame") and parent.ScrollingEnabled then
					local v13 = selectedObject.AbsolutePosition - parent.AbsolutePosition
					local absoluteSize = selectedObject.AbsoluteSize
					local absoluteWindowSize = parent.AbsoluteWindowSize
					local canvasPosition = parent.CanvasPosition
					local v14 = parent.AbsoluteCanvasSize - absoluteWindowSize
					local scrollingDirection = parent.ScrollingDirection
					local X

					if scrollingDirection == Enum.ScrollingDirection.Y then
						X = canvasPosition.X
					else
						local X2 = canvasPosition.X
						local X3 = v13.X
						local X4 = absoluteSize.X
						local X5 = absoluteWindowSize.X
						local X6 = v14.X
						local v15 = X2 + X3 + X4 - X5
						local v16 = X2 + X3

						if not (v16 < v15) then
							v16 = math.clamp(X2, v15, v16)
						end

						X = math.clamp(v16, 0, (math.max(X6, 0)))
					end

					local Y

					if scrollingDirection == Enum.ScrollingDirection.X then
						Y = canvasPosition.Y
					else
						local Y2 = canvasPosition.Y
						local Y3 = v13.Y
						local Y4 = absoluteSize.Y
						local Y5 = absoluteWindowSize.Y
						local Y6 = v14.Y
						local v15 = Y2 + Y3 + Y4 - Y5
						local v16 = Y2 + Y3

						if not (v16 < v15) then
							v16 = math.clamp(Y2, v15, v16)
						end

						Y = math.clamp(v16, 0, (math.max(Y6, 0)))
					end

					local vector = Vector2.new(X, Y)

					if vector ~= canvasPosition then
						parent.CanvasPosition = vector
					end
				end

				parent = parent.Parent
			end
		end

		local function isExternalNavigationSelection(instance)
			if instance == nil then
				return false
			end

			local layerCollector = instance:FindFirstAncestorWhichIsA("LayerCollector")
			return layerCollector ~= nil and frozen3[layerCollector.Name] == true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function restorePointerButtons(p)
			for k, interactable in v10 do
				if not (not p or not k.Parent or isCursorScopeMember(k, p)) then
					continue
				end

				if k.Parent and k.Interactable ~= interactable then
					k.Interactable = interactable
				end

				v10[k] = nil
			end
		end

		local function scopePointerButtons(root)
			for _, button in folder:GetDescendants() do
				if not button:IsA("GuiButton") or isCursorScopeMember(button, root) or not button.Interactable then
					continue
				end

				v10[button] = true
				button.Interactable = false
			end
		end

		local function updateNavigationHints(screenGui)
			if screenGui == nil then
				ButtonHintStrip.Retract("NavigationSwitch")
				ButtonHintStrip.Retract("NavigationMode")
				ButtonHintStrip.SetNavigationLayer(nil)
			else
				local isCursorActive = MenuNavigation.IsCursorActive()
				ButtonHintStrip.SetNavigationLayer(screenGui.DisplayOrder)
				ButtonHintStrip.PresentStatus(
					"NavigationMode",
					isCursorActive and "Navigation: Cursor" or "Navigation: Buttons"
				)
				ButtonHintStrip.Present(
					"NavigationSwitch",
					MenuNavigation.SwitchKey,
					isCursorActive and "Use Button Navigation" or "Use Cursor"
				)

				if not (v11 or Preferences.IsOn("SeenNavigationHint")) then
					v11 = true
					Toast.Show({
						Text = "Prefer a cursor in menus? Press the right stick to switch. Your choice is saved.",
						Image = InputIconsConfig.Image(MenuNavigation.SwitchKey),
						Seconds = 12,
						WrapText = true
					})
					task.delay(12, function()
						Preferences.Set("SeenNavigationHint", true)
					end)
				end
			end
		end

		local function reconcile()
			if flag2 then
				return
			end

			flag2 = true
			local v13 = v8
			v8 = nil

			if MenuNavigation.IsSuspended() then
				for k in v3 do
					if k.Parent ~= nil then
						k.Selectable = v2[k]
					end

					v3[k] = nil
					v2[k] = nil
				end

				restorePointerButtons(false) -- equivalent call inferred; original call site unknown
				MenuNavigation.Release()
				ButtonHintStrip.Retract("NavigationSwitch")
				ButtonHintStrip.Retract("NavigationMode")
				ButtonHintStrip.SetNavigationLayer(nil)
				ButtonHintStrip.Retract("HudNavigation")

				if not (PlatformController.IsConsole() and UserInputService.GamepadEnabled) and v12 ~= false then
					v12 = false
					GamepadBindings.EnableMarkers(true)
					v:AtDebug():Log((`HUD navigation OFF (left console platform); toggle key is {buttonL3.Name}`))
				end

				v6 = nil
				v7 = nil
				v9 = nil
				GamepadBindings.FocusScreen(nil)

				if not GuiService.MenuIsOpen then
					settleSelection(nil) -- equivalent call inferred; original call site unknown
				end

				flag2 = false
			else
				local screenGui = priorityScreen()
				local topOverride = MenuNavigation.TopOverride()

				if topOverride and (screenGui == nil or screenGui.Name == "HUD" or topOverride.Priority >= 1000) then
					if screenGui == nil then
						screenGui = topOverride.Root:FindFirstAncestorOfClass("ScreenGui")
					else
						local v14

						if screenGui == nil then
							v14 = false
						else
							v14 = screenGui:GetAttribute("ModalDialog") == true
						end

						if v14 and not (topOverride.Priority >= 2000) then
							topOverride = nil
						else
							screenGui = topOverride.Root:FindFirstAncestorOfClass("ScreenGui")
						end
					end
				else
					topOverride = nil
				end

				local root

				if topOverride then
					root = topOverride.Root
				else
					root = screenGui
				end

				v9 = topOverride
				v7 = root
				v6 = screenGui
				restoreSelectableButtons(root, MenuNavigation.PrefersCursor())
				local v15

				if MenuNavigation.PrefersCursor() then
					v15 = root
				end

				restorePointerButtons(v15)

				if screenGui ~= nil and screenGui.Name ~= "HUD" then
					local formatted = `{screenGui.Name} took focus`

					if v12 ~= false then
						v12 = false
						GamepadBindings.EnableMarkers(true)
						v:AtDebug():Log((`HUD navigation OFF ({formatted}); toggle key is {buttonL3.Name}`))
					end
				end

				if screenGui == nil or screenGui.Name == "HUD" then
					ButtonHintStrip.Present("HudNavigation", buttonL3, v12 and "Close Menus" or "Menus")
				else
					ButtonHintStrip.Retract("HudNavigation")
				end

				v6 = screenGui
				GamepadBindings.FocusScreen(screenGui, root)

				if screenGui == nil then
					MenuNavigation.SetContext(nil, nil)
					ButtonHintStrip.Retract("NavigationSwitch")
					ButtonHintStrip.Retract("NavigationMode")
					ButtonHintStrip.SetNavigationLayer(nil)
					local selectedObject = GuiService.SelectedObject
					local v16

					if selectedObject == nil then
						v16 = false
					else
						local layerCollector = selectedObject:FindFirstAncestorWhichIsA("LayerCollector")

						if layerCollector == nil then
							v16 = false
						else
							v16 = frozen3[layerCollector.Name] == true
						end
					end

					if v16 then
						GuiService.GuiNavigationEnabled = true
					else
						settleSelection(nil) -- equivalent call inferred; original call site unknown
					end

					flag2 = false
				else
					assert(root)
					local v16 = projectSelectableButtons(root)
					local selectedObject

					if v13 then
						selectedObject = v4[root]
					else
						selectedObject = GuiService.SelectedObject
					end

					if not isEligibleSelection(root, selectedObject) then
						selectedObject = v4[root]

						if not isEligibleSelection(root, selectedObject) then
							if topOverride and isEligibleSelection(root, topOverride.Initial) then
								selectedObject = topOverride.Initial
							else
								selectedObject = v16
							end
						end
					end

					if MenuNavigation.PrefersCursor() then
						if v13 ~= root then
							if selectedObject then
								v4[root] = selectedObject
							end

							GuiService.SelectedObject = nil
						end

						GuiService.GuiNavigationEnabled = true
					end

					if MenuNavigation.SetContext(root, selectedObject) then
						v8 = root
						projectSelectionContainers(root, false)

						for _, screenGui2 in folder:GetChildren() do
							if not (screenGui2:IsA("ScreenGui") and screenGui2.Enabled and screenGui2 ~= root and isCursorScopeMember(
								screenGui2,
								root
							)) then
								continue
							end

							projectSelectableButtons(screenGui2)
						end

						scopePointerButtons(root)
						updateNavigationHints(screenGui)
						flag2 = false
					else
						restorePointerButtons(false) -- equivalent call inferred; original call site unknown
						restoreSelectableButtons(root, false) -- equivalent call inferred; original call site unknown
						projectSelectionContainers(root, true)
						updateNavigationHints(screenGui)
						local v17

						if screenGui == nil then
							v17 = false
						else
							v17 = screenGui:GetAttribute("ModalDialog") == true
						end

						if v17 then
							selectedObject = nil
						end

						if selectedObject then
							v4[root] = selectedObject
							revealSelection(selectedObject)
						end

						settleSelection(selectedObject) -- equivalent call inferred; original call site unknown
						flag2 = false
					end
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function requestReconcile()
			if flag then
				return
			end

			flag = true
			task.defer(function()
				flag = false
				reconcile()
			end)
		end

		local function observe(instance)
			if v5[instance] then
				return
			end

			v5[instance] = true
			local screenGui

			if instance:IsA("ScreenGui") then
				screenGui = instance
			else
				screenGui = instance:FindFirstAncestorOfClass("ScreenGui")
			end

			if screenGui == nil or not frozen2[screenGui.Name] then
				GamepadBindings.Inspect(instance)
			end

			if instance:IsA("ScreenGui") then
				instance:GetPropertyChangedSignal("Enabled"):Connect(requestReconcile)

				if instance.Name == "PendingPurchase" then
					-- equivalent calls inferred from this helper; original call sites unknown
					local function purchaseChanged()
						MenuNavigation.Suspend("Purchase", instance.Enabled)
					end

					instance:GetPropertyChangedSignal("Enabled"):Connect(purchaseChanged)
					purchaseChanged() -- equivalent call inferred; original call site unknown
				end
			elseif instance:IsA("GuiObject") then
				instance:GetPropertyChangedSignal("Visible"):Connect(requestReconcile)

				if instance:IsA("GuiButton") or instance:IsA("TextBox") then
					instance:GetPropertyChangedSignal("Active"):Connect(requestReconcile)
					instance:GetPropertyChangedSignal("Interactable"):Connect(function()
						if not flag2 then
							requestReconcile() -- equivalent call inferred; original call site unknown
						end
					end)
					instance:GetAttributeChangedSignal("ConsoleNavigationDisabled"):Connect(requestReconcile)
				end

				instance:GetPropertyChangedSignal("Selectable"):Connect(function()
					if not flag2 then
						requestReconcile() -- equivalent call inferred; original call site unknown
					end
				end)
				instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
					if GuiService.SelectedObject == instance and not MenuNavigation.IsCursorActive() then
						requestReconcile() -- equivalent call inferred; original call site unknown
					end
				end)
			end

			instance.Destroying:Once(function()
				v5[instance] = nil

				if instance:IsA("ScreenGui") then
					v4[instance] = nil
				elseif instance:IsA("GuiObject") then
					v2[instance] = nil
					v3[instance] = nil

					if instance:IsA("GuiButton") then
						v10[instance] = nil
					end
				end

				if instance:IsA("GuiObject") then
					for k, v13 in v4 do
						if v13 == instance then
							v4[k] = nil
						end
					end
				end

				requestReconcile() -- equivalent call inferred; original call site unknown
			end)
		end

		for _, v13 in {
			"ShopButton",
			"IndexButton",
			"EggsButton",
			"PetsButton",
			"QuestlineButton"
		} do
			local v14 = Hud.Find(v13, "Game")
			local parent = Hud.Find(v13, "Treadmill")
			local gamepadGlyph

			if v14 then
				gamepadGlyph = v14:FindFirstChild("GamepadGlyph")
			end

			if not gamepadGlyph or not parent or parent:FindFirstChild("GamepadGlyph") then
				continue
			end

			local clone = gamepadGlyph:Clone()
			clone.Parent = parent
		end

		for _, descendant in folder:GetDescendants() do
			observe(descendant)
		end

		for _, child in folder:GetChildren() do
			observe(child)
		end

		folder.DescendantAdded:Connect(function(descendant)
			observe(descendant)
			requestReconcile() -- equivalent call inferred; original call site unknown
		end)
		folder.DescendantRemoving:Connect(requestReconcile)
		GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
			if flag2 or MenuNavigation.IsSuspended() then
				return
			end

			local v13 = v7
			local selectedObject = GuiService.SelectedObject

			if MenuNavigation.IsCursorActive() then
				if selectedObject and (v13 == nil or not isCursorScopeMember(selectedObject, v13) or not selectedObject.Selectable or not selectedObject.Interactable or not GamepadBindings.IsOnScreen(selectedObject) or selectedObject:GetAttribute("ConsoleNavigationDisabled") == true or selectedObject:IsA("GuiButton") and not selectedObject.Active) then
					GuiService.SelectedObject = nil
				end

				GuiService.GuiNavigationEnabled = true
			elseif v13 == nil or not isEligibleSelection(v13, selectedObject) then
				if v13 ~= nil then
					local v14 = v6
					local v15

					if v14 == nil then
						v15 = false
					else
						v15 = v14:GetAttribute("ModalDialog") == true
					end

					if not v15 then
						if flag then
							return
						end

						flag = true
						task.defer(function()
							flag = false
							reconcile()
						end)
						return
					end
				end

				if PlatformController.IsConsole() and v13 == nil then
					local v14 = GuiService
					local guiNavigationEnabled

					if selectedObject == nil then
						guiNavigationEnabled = false
					else
						local layerCollector = selectedObject:FindFirstAncestorWhichIsA("LayerCollector")

						if layerCollector == nil then
							guiNavigationEnabled = false
						else
							guiNavigationEnabled = frozen3[layerCollector.Name] == true
						end
					end

					v14.GuiNavigationEnabled = guiNavigationEnabled
				end
			else
				v4[v13] = selectedObject
				revealSelection(selectedObject)
			end
		end)
		MenuNavigation.Changed:Connect(requestReconcile)
		MenuNavigation.SaveFailed:Connect(function()
			Toast.Show({
				Text = "Navigation changed for this session, but could not be saved. Please try again in Settings.",
				Seconds = 6,
				WrapText = true
			})
		end)
		MenuNavigation.CursorFailed:Connect(function()
			Toast.Show({
				Text = "Cursor unavailable. Button navigation is still available.",
				Seconds = 5
			})
		end)
		PlatformController.Changed:Connect(requestReconcile)
		Tabs.Activated:Connect(requestReconcile)
		Tabs.Deactivated:Connect(requestReconcile)
		UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
			if MenuNavigation.IsSuspended() or gameProcessed then
				return
			end

			if input.KeyCode == buttonL3 then
				setHudNavigation(not v12, `pressed {input.KeyCode.Name}`) -- equivalent call inferred; original call site unknown
				requestReconcile() -- equivalent call inferred; original call site unknown
			elseif input.KeyCode == buttonB and v12 then
				local formatted = `pressed {input.KeyCode.Name}`

				if v12 ~= false then
					v12 = false
					GamepadBindings.EnableMarkers(true)
					v:AtDebug():Log((`HUD navigation OFF ({formatted}); toggle key is {buttonL3.Name}`))
				end

				requestReconcile() -- equivalent call inferred; original call site unknown
			end
		end)
		local v13 = {}
		local v14 = {}

		local function switchNavigation(p)
			if p.KeyCode ~= MenuNavigation.SwitchKey or v7 == nil or MenuNavigation.IsSuspended() then
				return false
			end

			local userInputType = p.UserInputType

			if not v14[userInputType] then
				v14[userInputType] = true
				MenuNavigation.Toggle()
			end

			return true
		end

		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == MenuNavigation.SwitchKey and v7 ~= nil then
				if MenuNavigation.IsSuspended() then
					return
				end

				local userInputType = input.UserInputType

				if not v14[userInputType] then
					v14[userInputType] = true
					MenuNavigation.Toggle()
				end
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == MenuNavigation.SwitchKey then
				v14[input.UserInputType] = nil
			end
		end)
		UserInputService.GamepadDisconnected:Connect(function(p)
			v14[p] = nil
		end)
		UserInputService.WindowFocusReleased:Connect(function()
			table.clear(v14)
			table.clear(v13)
		end)
		ContextActionService:BindActionAtPriority("MenuNavigationSwitch", function(_, p, p2)
			local keyCode = p2.KeyCode

			if p == Enum.UserInputState.Cancel then
				local v15 = next(v13) ~= nil
				table.clear(v13)
				table.clear(v14)

				if v15 then
					return Enum.ContextActionResult.Sink
				end

				return Enum.ContextActionResult.Pass
			elseif p == Enum.UserInputState.Begin then
				if v7 == nil or MenuNavigation.IsSuspended() then
					return Enum.ContextActionResult.Pass
				end

				if keyCode == MenuNavigation.SwitchKey then
					v13[keyCode] = true

					if p2.KeyCode ~= MenuNavigation.SwitchKey or v7 == nil or MenuNavigation.IsSuspended() then
						return Enum.ContextActionResult.Sink
					end

					local userInputType = p2.UserInputType

					if not v14[userInputType] then
						v14[userInputType] = true
						MenuNavigation.Toggle()
					end

					return Enum.ContextActionResult.Sink
				else
					if keyCode ~= Enum.KeyCode.ButtonB then
						return Enum.ContextActionResult.Pass
					end

					if v9 and v9.Back and (MenuNavigation.IsCursorActive() or v9.BackInButtons) then
						v13[keyCode] = true
						v9.Back()
						return Enum.ContextActionResult.Sink
					elseif v12 then
						v13[keyCode] = true

						if v12 ~= false then
							v12 = false
							GamepadBindings.EnableMarkers(true)
							v:AtDebug():Log((`HUD navigation OFF (Back); toggle key is {buttonL3.Name}`))
						end

						requestReconcile() -- equivalent call inferred; original call site unknown
						return Enum.ContextActionResult.Sink
					end

					return Enum.ContextActionResult.Pass
				end
			else
				local v15 = v13[keyCode]

				if p == Enum.UserInputState.End then
					v13[keyCode] = nil

					if keyCode == MenuNavigation.SwitchKey then
						v14[p2.UserInputType] = nil
					end
				end

				if v15 then
					return Enum.ContextActionResult.Sink
				end

				return Enum.ContextActionResult.Pass
			end
		end, false, Enum.ContextActionPriority.High.Value + 250, MenuNavigation.SwitchKey, Enum.KeyCode.ButtonB)
		GuiService.AutoSelectGuiEnabled = false
		GamepadBindings.Rescan(PlatformController.Platform())
		reconcile()
		v:AtInfo():Log("Console navigation initialized")
	end
}