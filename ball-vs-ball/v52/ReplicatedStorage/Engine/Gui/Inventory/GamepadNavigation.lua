local GamepadPages = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ButtonHints = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonHints)
local PageControls = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.PageControls)
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local GamepadSupport = require(game.ReplicatedStorage.Engine.Service.GamepadSupport)
local v = {
	"ball",
	"explosion",
	"flyer",
	"fusion"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function visible(button)
	return button and button.Parent and button:IsA("GuiButton") and GamepadSupport.CanActivate(button)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function key(selectedObject)
	return selectedObject:GetAttribute("InventoryNavigationKey") or selectedObject:GetAttribute("PointDay")
end

local function reveal(instance)
	local scrollingFrame = instance:FindFirstAncestorWhichIsA("ScrollingFrame")

	if not scrollingFrame then
		return
	end

	local v2 = instance.AbsolutePosition - scrollingFrame.AbsolutePosition
	local absoluteSize = instance.AbsoluteSize
	local absoluteWindowSize = scrollingFrame.AbsoluteWindowSize

	local function shift(p, p2, p3)
		if p < 0 then
			return p
		end

		if p3 < p + p2 then
			return p + p2 - p3
		end

		return 0
	end

	local v3 = scrollingFrame.AbsoluteCanvasSize - absoluteWindowSize
	local canvasPosition = scrollingFrame.CanvasPosition
	local X = canvasPosition.X
	local X2 = v2.X
	local X3 = absoluteSize.X
	local X4 = absoluteWindowSize.X

	if not (X2 < 0) then
		X2 = not (X4 < X2 + X3) and 0 or X2 + X3 - X4
	end

	local v4 = math.clamp(X + X2, 0, (math.max(0, v3.X)))
	local Y = canvasPosition.Y
	local Y2 = v2.Y
	local Y3 = absoluteSize.Y
	local Y4 = absoluteWindowSize.Y

	if not (Y2 < 0) then
		Y2 = not (Y4 < Y2 + Y3) and 0 or Y2 + Y3 - Y4
	end

	scrollingFrame.CanvasPosition = Vector2.new(v4, (math.clamp(Y + Y2, 0, (math.max(0, v3.Y)))))
end

local function cells(instance)
	local buttons = {}

	for _, button in instance:GetChildren() do
		if not (button:IsA("GuiButton") and button.Visible and (button:GetAttribute("InventoryGeneratedSlot") or button:GetAttribute("FusionGeneratedSlot"))) then
			continue
		end

		button.Selectable = true
		table.insert(buttons, button)
	end

	table.sort(buttons, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	return buttons
end

return {
	new = function(self)
		local v2 = {
			active = false,
			dirty = true,
			remembered = {},
			previous = nil,
			buttons = {},
			lastGroup = nil,
			lastKey = nil,
			lastOrder = 1,
			historyFocus = nil
		}
		GamepadPages.Observe(self.panel, {
			available = function()
				return v2.active
			end,
			defaultButton = self.tabs[1]
		})
		local v3 = ButtonHints.Ensure(self.close, "B")

		local function updateCloseShortcut()
			local button = self.fusionHeader["返回按钮"]
			local visible2 = visible(self.copiesBack) or self.getTab() == "fusion" and visible(button)

			if not visible2 then
				visible2 = self.history.Visible

				if visible2 then
					visible2 = visible(self.back)
				end
			end

			v3.Name = visible2 and "关闭快捷键提示" or "手柄B"

			if visible2 then
				v3.Visible = false
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function usable()
			return GamepadPages.CanRestoreFocus(self.panel) and v2.active and GamepadSupport.IsGamepad() and GamepadSupport.IsVisible(self.panel) and not GamepadSupport.IsBlocked()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function tabIndex()
			for k, v4 in v do
				if v4 == self.getTab() then
					return k
				end
			end

			return 1
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function tab()
			local tabs = self.tabs
			local v4 = tabIndex() -- equivalent call inferred; original call site unknown
			return tabs[v4]
		end

		local v4 = PageControls.FromHint(self.panel, "上一分类手柄提示", "L1", function()
			local onTab = self.onTab
			local v6 = tabIndex() -- equivalent call inferred; original call site unknown
			onTab(v[(v6 - 2) % #v + 1])
		end)
		local v5 = PageControls.FromHint(self.panel, "下一分类手柄提示", "R1", function()
			local onTab = self.onTab
			local v7 = tabIndex() -- equivalent call inferred; original call site unknown
			onTab(v[v7 % #v + 1])
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function focus(button)
			if visible(button) and button.Selectable then
				GuiService.SelectedObject = button
				reveal(button)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function allow(button)
			if not (button and button:IsA("GuiButton")) then
				return
			end

			button.Selectable = true

			if visible(button) then
				table.insert(v2.buttons, button)
			end
		end

		local function grid(items, instance, button, p, button2, p2)
			local uIGridLayout = instance:FindFirstChildOfClass("UIGridLayout")
			local navigationColumns = instance:GetAttribute("NavigationColumns") or not uIGridLayout and 1 or math.max(
				1,
				uIGridLayout.AbsoluteCellCount.X
			)

			for k, button3 in items do
				local v6 = (k - 1) % navigationColumns
				local nextSelectionLeft

				if v6 > 0 then
					nextSelectionLeft = items[k - 1]
				else
					nextSelectionLeft = button or button3
				end

				button3.NextSelectionLeft = nextSelectionLeft
				local nextSelectionRight

				if v6 < navigationColumns - 1 and items[k + 1] then
					nextSelectionRight = items[k + 1]
				else
					nextSelectionRight = p or button3
				end

				button3.NextSelectionRight = nextSelectionRight
				button3.NextSelectionUp = items[k - navigationColumns] or button2 or button3
				button3.NextSelectionDown = items[k + navigationColumns] or p2 or button3

				if not (button3 and button3:IsA("GuiButton")) then
					continue
				end

				button3.Selectable = true

				if visible(button3) then
					table.insert(v2.buttons, button3)
				end
			end
		end

		local function restore()
			if not usable() then
				return
			end

			local selectedObject = GuiService.SelectedObject

			if selectedObject and table.find(v2.buttons, selectedObject) and visible(selectedObject) then
				return
			end

			local back = nil

			if v2.lastGroup then
				local v6 = 1e999

				for _, button in v2.buttons do
					if button.Parent ~= v2.lastGroup then
						continue
					end

					if key(button) == v2.lastKey then
						back = button
						break
					else
						local v8 = math.abs(button.LayoutOrder - v2.lastOrder)

						if v8 < v6 then
							back = button
							v6 = v8
						end
					end
				end
			end

			if not back then
				if self.history.Visible then
					back = self.back
				else
					back = tab()
				end
			end

			focus(back) -- equivalent call inferred; original call site unknown
		end

		local function rebuild()
			if self.getUpgrade then
				self.upgrade = self.getUpgrade()
			end

			v2.dirty = false
			v2.buttons = {}
			updateCloseShortcut()

			if self.isUpgrade() then
				local upgradePage = self.upgradePage
				local v6 = upgradePage["左框"]
				local v7 = upgradePage["右框"]
				local v8 = v6["顶部栏"]["返回按钮"]
				local button = v6["不可交易优先按钮"]
				local v9 = v6["可交易优先按钮"]
				local nextSelectionRight = v7["确认升级按钮"]
				local v11 = cells(v6["列表"])

				for _, button2 in {
					v8,
					button,
					v9,
					nextSelectionRight,
					self.close
				} do
					if not (button2 and button2:IsA("GuiButton")) then
						continue
					end

					button2.Selectable = true

					if visible(button2) then
						table.insert(v2.buttons, button2)
					end
				end

				v8.NextSelectionRight = button
				v8.NextSelectionDown = button
				v8.NextSelectionUp = self.close
				button.NextSelectionLeft = v8
				button.NextSelectionRight = v9
				button.NextSelectionDown = v11[1] or nextSelectionRight
				button.NextSelectionUp = v8
				v9.NextSelectionLeft = button
				v9.NextSelectionRight = nextSelectionRight
				v9.NextSelectionDown = v11[1] or nextSelectionRight
				v9.NextSelectionUp = v8
				grid(v11, v6["列表"], button, nextSelectionRight, button, nextSelectionRight)
				nextSelectionRight.NextSelectionLeft = v11[#v11] or v9
				nextSelectionRight.NextSelectionUp = v9
				nextSelectionRight.NextSelectionDown = v8
				self.close.NextSelectionDown = v8
				self.close.NextSelectionLeft = v8
				restore()

				if usable() and not table.find(v2.buttons, GuiService.SelectedObject) and visible(button) and button.Selectable then
					GuiService.SelectedObject = button
					reveal(button)
				end
			elseif self.history.Visible then
				allow(self.back) -- equivalent call inferred; original call site unknown
				allow(self.close) -- equivalent call inferred; original call site unknown
				local buttons = {}

				for _, button in self.history:GetDescendants() do
					if not button:IsA("GuiButton") then
						continue
					end

					if button:GetAttribute("PointDay") and visible(button) then
						table.insert(buttons, button)
					elseif button ~= self.back then
						button.Selectable = false
					end
				end

				table.sort(buttons, function(a, b)
					return a:GetAttribute("PointDay") < b:GetAttribute("PointDay")
				end)
				self.back.NextSelectionRight = buttons[1] or self.close
				self.back.NextSelectionUp = self.close
				self.back.NextSelectionDown = self.back
				self.back.NextSelectionLeft = self.back
				self.close.NextSelectionDown = self.back
				self.close.NextSelectionLeft = self.back

				for k, v6 in buttons do
					allow(v6) -- equivalent call inferred; original call site unknown
					v6.NextSelectionLeft = buttons[k - 1] or self.back
					v6.NextSelectionRight = buttons[k + 1] or v6
					v6.NextSelectionUp = self.back
					v6.NextSelectionDown = self.back
				end

				restore()
			else
				for k, tab2 in self.tabs do
					allow(tab2) -- equivalent call inferred; original call site unknown
					tab2.NextSelectionLeft = self.tabs[k - 1] or tab2
					tab2.NextSelectionRight = self.tabs[k + 1] or tab2
					tab2.NextSelectionUp = self.close
				end

				allow(self.close) -- equivalent call inferred; original call site unknown
				allow(self.starter) -- equivalent call inferred; original call site unknown
				allow(self.invite) -- equivalent call inferred; original call site unknown
				local nextSelectionLeft

				if self.getTab() == "fusion" then
					local fusionHome

					if GamepadSupport.IsVisible(self.fusionHome) then
						fusionHome = self.fusionHome
					else
						fusionHome = self.fusionInventory
					end

					local fusionSelected = self.getFusionSelected()
					local v7 = cells(fusionHome)
					local v8 = cells(fusionSelected)
					local fusionHeader = self.fusionHeader
					local v9 = {
						fusionHeader["返回按钮"],
						fusionHeader["全部筛选"],
						fusionHeader["经典筛选"],
						fusionHeader["闪光筛选"],
						fusionHeader["彩虹筛选"]
					}

					for k, v10 in v9 do
						allow(v10) -- equivalent call inferred; original call site unknown
						v10.NextSelectionLeft = v9[k - 1] or self.fusionTabs[1]
						v10.NextSelectionRight = v9[k + 1] or self.compose
						v10.NextSelectionUp = tab()
						v10.NextSelectionDown = v7[1] or self.compose
					end

					local compose2

					if visible(self.compose) then
						compose2 = self.compose
					else
						compose2 = self.unavailable
					end

					allow(compose2) -- equivalent call inferred; original call site unknown

					for k, fusionTab in self.fusionTabs do
						allow(fusionTab) -- equivalent call inferred; original call site unknown
						local fusionTab2 = self.fusionTabs[k - 1]

						if not fusionTab2 then
							fusionTab2 = tab()
						end

						fusionTab.NextSelectionUp = fusionTab2
						fusionTab.NextSelectionDown = self.fusionTabs[k + 1] or fusionTab
						fusionTab.NextSelectionLeft = fusionTab
						fusionTab.NextSelectionRight = v7[1] or v8[1] or compose2
					end

					local fusionTab = self.fusionTabs[1]
					local v11 = v8[1] or compose2
					local v12, v13

					if GamepadSupport.IsVisible(fusionHeader) then
						v12 = fusionHeader["全部筛选"]
						v13 = v7
					else
						local tabs = self.tabs
						v13 = v7
						local v14 = tabIndex() -- equivalent call inferred; original call site unknown
						v12 = tabs[v14]
					end

					grid(v13, fusionHome, fusionTab, v11, v12, compose2)
					local v15 = v7[1] or self.fusionTabs[1]
					local tabs = self.tabs
					local v18 = tabIndex() -- equivalent call inferred; original call site unknown
					grid(v8, fusionSelected, v15, compose2, tabs[v18], compose2)
					compose2.NextSelectionLeft = v8[#v8] or v7[#v7] or self.fusionTabs[1]
					local nextSelectionUp = v8[#v8]

					if not nextSelectionUp then
						nextSelectionUp = v7[#v7]

						if not nextSelectionUp then
							nextSelectionUp = tab()
						end
					end

					compose2.NextSelectionUp = nextSelectionUp
					compose2.NextSelectionDown = compose2
					compose2.NextSelectionRight = compose2
					nextSelectionLeft = v7[1] or self.fusionTabs[1]
				else
					local v7 = cells(self.owned)
					local v8 = cells(self.unowned)
					local copies2

					if visible(self.copies) then
						copies2 = self.copies
					elseif visible(self.equip) then
						copies2 = self.equip
					elseif visible(self.unequip) then
						copies2 = self.unequip
					elseif visible(self.copiesBack) then
						copies2 = self.copiesBack
					else
						copies2 = self.info
					end

					for _, button in {
						self.equip,
						self.unequip,
						self.price,
						self.info,
						self.copies,
						self.copiesBack,
						self.upgrade
					} do
						if not (button and button:IsA("GuiButton")) then
							continue
						end

						button.Selectable = true

						if visible(button) then
							table.insert(v2.buttons, button)
						end
					end

					local owned = self.owned
					local tabs = self.tabs
					local v11 = tabIndex() -- equivalent call inferred; original call site unknown
					local tab2 = tabs[v11]
					local tabs2 = self.tabs
					local v13 = tabIndex() -- equivalent call inferred; original call site unknown
					grid(v7, owned, tab2, copies2, tabs2[v13], v8[1])
					local unowned = self.unowned
					local tabs3 = self.tabs
					local v16 = tabIndex() -- equivalent call inferred; original call site unknown
					local tab3 = tabs3[v16]
					local v17 = v7[#v7]
					local v18

					if v17 then
						v18 = copies2
					else
						local tabs4 = self.tabs
						v18 = copies2
						local v19 = tabIndex() -- equivalent call inferred; original call site unknown
						v17 = tabs4[v19]
					end

					grid(v8, unowned, tab3, v18, v17)

					for _, nextSelectionRight in {
						self.equip,
						self.unequip,
						self.price,
						self.info,
						self.copies,
						self.copiesBack,
						self.upgrade
					} do
						local nextSelectionLeft2 = v7[1]

						if not nextSelectionLeft2 then
							nextSelectionLeft2 = v8[1]

							if not nextSelectionLeft2 then
								nextSelectionLeft2 = tab()
							end
						end

						nextSelectionRight.NextSelectionLeft = nextSelectionLeft2
						nextSelectionRight.NextSelectionUp = tab()
						local equip

						if nextSelectionRight == self.price then
							if visible(self.equip) then
								equip = self.equip
							elseif visible(self.unequip) then
								equip = self.unequip
							else
								equip = nextSelectionRight
							end
						else
							equip = nextSelectionRight
						end

						nextSelectionRight.NextSelectionDown = equip
						nextSelectionRight.NextSelectionRight = nextSelectionRight
					end

					if visible(self.price) and visible(self.info) then
						self.price.NextSelectionDown = self.info
						self.info.NextSelectionUp = self.price
					end

					if visible(self.copies) then
						local copies4 = self.copies
						copies4.NextSelectionUp = tab()
						local copies5 = self.copies
						local nextSelectionDown

						if visible(self.upgrade) then
							nextSelectionDown = self.upgrade
						else
							nextSelectionDown = self.copies
						end

						copies5.NextSelectionDown = nextSelectionDown
						self.upgrade.NextSelectionUp = self.copies
					end

					if visible(self.copiesBack) then
						local copiesBack2 = self.copiesBack
						copiesBack2.NextSelectionUp = tab()
						local copiesBack3 = self.copiesBack
						local nextSelectionDown = v7[1]

						if not nextSelectionDown then
							nextSelectionDown = tab()
						end

						copiesBack3.NextSelectionDown = nextSelectionDown
						local copiesBack4 = self.copiesBack
						local nextSelectionRight = v7[1]

						if not nextSelectionRight then
							nextSelectionRight = tab()
						end

						copiesBack4.NextSelectionRight = nextSelectionRight

						if visible(self.equip) then
							self.equip.NextSelectionUp = self.copiesBack
						end
					end

					if self.isCopies() then
						local buttons = {}

						for _, button in self.copiesFilters do
							if visible(button) then
								table.insert(buttons, button)
							end
						end

						local equip2

						if visible(self.equip) then
							equip2 = self.equip
						elseif visible(self.unequip) then
							equip2 = self.unequip
						else
							equip2 = self.copiesBack
						end

						for k, v19 in buttons do
							allow(v19) -- equivalent call inferred; original call site unknown
							v19.NextSelectionLeft = buttons[k - 1] or self.copiesBack
							v19.NextSelectionRight = buttons[k + 1] or equip2
							v19.NextSelectionUp = tab()
							v19.NextSelectionDown = v7[1] or equip2
						end

						self.copiesBack.NextSelectionRight = buttons[1] or equip2

						for k, v19 in v7 do
							if k <= 3 then
								v19.NextSelectionUp = buttons[math.min(k, #buttons)] or self.copiesBack
							end
						end

						equip2.NextSelectionUp = buttons[#buttons] or self.copiesBack
						local nextSelectionDown

						if visible(self.upgrade) then
							nextSelectionDown = self.upgrade
						else
							nextSelectionDown = equip2
						end

						equip2.NextSelectionDown = nextSelectionDown
						local upgrade2 = self.upgrade
						local nextSelectionUp

						if visible(self.equip) then
							nextSelectionUp = self.equip
						else
							nextSelectionUp = buttons[#buttons] or self.copiesBack
						end

						upgrade2.NextSelectionUp = nextSelectionUp
					end

					nextSelectionLeft = v7[1] or v8[1] or copies2

					for _, v19 in { v7, v8 } do
						for _, v20 in v19 do
							if key(v20) ~= v2.remembered[self.getTab()] then
								continue
							end

							nextSelectionLeft = v20
						end
					end
				end

				for _, tab2 in self.tabs do
					tab2.NextSelectionDown = nextSelectionLeft or tab2
				end

				self.close.NextSelectionLeft = self.tabs[#self.tabs]
				local close2 = self.close
				close2.NextSelectionDown = tab()
				self.close.NextSelectionUp = self.close
				self.close.NextSelectionRight = self.close
				local starter2 = self.starter
				starter2.NextSelectionUp = tab()
				local starter3 = self.starter
				local nextSelectionLeft3

				if nextSelectionLeft then
					nextSelectionLeft3 = nextSelectionLeft
				else
					nextSelectionLeft3 = tab()
				end

				starter3.NextSelectionLeft = nextSelectionLeft3
				local starter4 = self.starter
				local nextSelectionDown2

				if visible(self.invite) then
					nextSelectionDown2 = self.invite
				else
					nextSelectionDown2 = self.starter
				end

				starter4.NextSelectionDown = nextSelectionDown2

				if visible(self.starter) then
					self.tabs[#self.tabs].NextSelectionRight = self.starter
				end

				local invite3 = self.invite

				if not nextSelectionLeft then
					nextSelectionLeft = tab()
				end

				invite3.NextSelectionLeft = nextSelectionLeft
				local invite4 = self.invite
				local nextSelectionUp2

				if visible(self.starter) then
					nextSelectionUp2 = self.starter
				else
					nextSelectionUp2 = tab()
				end

				invite4.NextSelectionUp = nextSelectionUp2

				if visible(self.invite) and not visible(self.starter) then
					self.tabs[#self.tabs].NextSelectionRight = self.invite
				end

				restore()
			end
		end

		function v2:Refresh()
			self.dirty = true
		end

		function v2.SetTab(p)
			p.lastGroup = nil
			p.lastKey = nil
			p.dirty = true

			if usable() then
				local selectedObject = tab() -- equivalent call inferred; original call site unknown
				focus(selectedObject) -- equivalent call inferred; original call site unknown
			end
		end

		function v2.Open(p)
			if not p.active then
				p.previous = GuiService.SelectedObject
			end

			p.active = true
			p.dirty = true

			if usable() then
				rebuild()
				local selectedObject = tab() -- equivalent call inferred; original call site unknown
				focus(selectedObject) -- equivalent call inferred; original call site unknown
			end
		end

		function v2.Close(p)
			p.active = false

			if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(self.panel) then
				GuiService.SelectedObject = nil

				if not GamepadSupport.IsBlocked() and p.previous and p.previous.Parent and p.previous.Selectable and GamepadSupport.IsVisible(p.previous) then
					GuiService.SelectedObject = p.previous
				end
			end

			p.previous = nil
			p.lastGroup = nil
			p.lastKey = nil
		end

		GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
			if not usable() then
				return
			end

			local selectedObject = GuiService.SelectedObject

			if selectedObject and selectedObject:IsDescendantOf(self.panel) and visible(selectedObject) then
				local lastKey = key(selectedObject) -- equivalent call inferred; original call site unknown

				if lastKey then
					v2.lastGroup = selectedObject.Parent
					v2.lastKey = lastKey
					v2.lastOrder = selectedObject.LayoutOrder
					v2.remembered[self.getTab()] = lastKey
				end

				reveal(selectedObject)
			end
		end)

		local function watch(guiObject)
			if guiObject:IsA("ScrollingFrame") then
				guiObject.Selectable = false
			end

			if guiObject:IsA("GuiObject") then
				guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
					v2.dirty = true
				end)
			end
		end

		for _, descendant in self.panel:GetDescendants() do
			watch(descendant)
		end

		self.panel.DescendantAdded:Connect(function(descendant)
			watch(descendant)
			v2.dirty = true
		end)
		self.panel.DescendantRemoving:Connect(function()
			v2.dirty = true
		end)
		self.panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			v2.dirty = true
		end)
		self.history:GetPropertyChangedSignal("Visible"):Connect(function()
			if self.history.Visible then
				v2.historyFocus = GuiService.SelectedObject
				v2.lastGroup = nil

				if usable() then
					focus(self.back) -- equivalent call inferred; original call site unknown
				end
			else
				if usable() then
					local historyFocus = v2.historyFocus or self.price
					focus(historyFocus) -- equivalent call inferred; original call site unknown
				end

				v2.historyFocus = nil
			end

			v2.dirty = true
		end)
		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			if usable() then
				v2.dirty = true
			end
		end)
		local total = 0
		RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total < 0.1 then
				return
			end

			total = 0

			if not (v2.active and GamepadSupport.IsGamepad()) then
				return
			end

			if v2.dirty then
				rebuild()
			end

			restore()
			updateCloseShortcut()
			v4.Visible = not (self.history.Visible or self.isUpgrade())
			v5.Visible = v4.Visible
		end)
		return v2
	end
}