local GamepadPages = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonHints)
local PageControls = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.PageControls)
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local GamepadSupport = require(game.ReplicatedStorage.Engine.Service.GamepadSupport)

local function reveal(selectedObject)
	local parent = selectedObject and selectedObject.Parent

	if parent and parent:IsA("Frame") then
		parent = parent.Parent
	end

	if not (parent and parent:IsA("ScrollingFrame")) then
		return
	end

	local v = selectedObject.AbsolutePosition - parent.AbsolutePosition
	local absoluteSize = selectedObject.AbsoluteSize
	local absoluteWindowSize = parent.AbsoluteWindowSize

	local function delta(p, p2, p3)
		if p < 0 then
			return p
		end

		return (math.max(0, p + p2 - p3))
	end

	local v2 = parent.AbsoluteCanvasSize - absoluteWindowSize
	local X = parent.CanvasPosition.X
	local X2 = v.X
	local X3 = absoluteSize.X
	local X4 = absoluteWindowSize.X

	if not (X2 < 0) then
		X2 = math.max(0, X2 + X3 - X4)
	end

	local v3 = math.clamp(X + X2, 0, (math.max(0, v2.X)))
	local Y = parent.CanvasPosition.Y
	local Y2 = v.Y
	local Y3 = absoluteSize.Y
	local Y4 = absoluteWindowSize.Y

	if not (Y2 < 0) then
		Y2 = math.max(0, Y2 + Y3 - Y4)
	end

	parent.CanvasPosition = Vector2.new(v3, (math.clamp(Y + Y2, 0, (math.max(0, v2.Y)))))
end

return {
	new = function(self)
		local v = {
			active = false,
			dirty = true,
			previous = nil,
			memory = nil,
			nodes = {}
		}
		local connections = {}
		local v2 = false
		local v3 = self.panel:WaitForChild("选择栏")
		GamepadPages.Observe(self.panel, {
			available = function()
				return v.active
			end,
			defaultButton = self.tabs[1]
		})
		PageControls.FromHint(v3, "上一分类手柄提示", "L1", function()
			self.onCategory((self.getCategoryIndex() - 2) % #self.tabs + 1)
		end)
		PageControls.FromHint(v3, "下一分类手柄提示", "R1", function()
			self.onCategory(self.getCategoryIndex() % #self.tabs + 1)
		end)
		local diamonds = self.diamonds
		self.diamonds = PageControls.FromHint(diamonds, "钻石输入手柄提示", "A", function()
			diamonds:CaptureFocus()
		end)

		local function connect(object, p)
			table.insert(connections, object:Connect(p))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function usable()
			return GamepadPages.CanRestoreFocus(self.panel) and v.active and GamepadSupport.IsGamepad() and GamepadSupport.IsVisible(self.panel) and not GamepadSupport.IsBlocked()
		end

		local function refreshHints() end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function focus(selectedObject)
			if selectedObject and selectedObject.Parent and selectedObject.Selectable and GamepadSupport.IsVisible(selectedObject) then
				GuiService.SelectedObject = selectedObject
				reveal(selectedObject)
			end
		end

		local function remember(selectedObject)
			if not (selectedObject and selectedObject:IsDescendantOf(self.panel)) then
				return
			end

			local v4 = v
			local parent

			if selectedObject.Parent:IsA("Frame") then
				parent = selectedObject.Parent.Parent
			else
				parent = selectedObject.Parent
			end

			v4.memory = {
				node = selectedObject,
				parent = parent,
				key = selectedObject:GetAttribute("TradeNavigationKey"),
				order = selectedObject.LayoutOrder
			}
		end

		local function cells(instance)
			instance.Selectable = false
			local buttons = {}

			for _, guiObject in instance:GetChildren() do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local button

				if instance:GetAttribute("InventoryVirtualGrid") and guiObject:IsA("GuiButton") then
					button = guiObject
				else
					button = guiObject:FindFirstChild("物品卡片")
				end

				if guiObject:IsA("Frame") then
					guiObject.Selectable = false
				end

				if not (button and button:IsA("GuiButton")) then
					continue
				end

				button.Selectable = guiObject.Visible and guiObject:GetAttribute("TradeGenerated") == true
				button.LayoutOrder = guiObject.LayoutOrder
				button:SetAttribute("TradeNavigationKey", guiObject:GetAttribute("TradeNavigationKey"))

				if button.Selectable then
					table.insert(buttons, button)
				end
			end

			table.sort(buttons, function(a, b)
				return a.LayoutOrder < b.LayoutOrder
			end)
			return buttons
		end

		local function refresh()
			v.dirty = false
			v2 = true
			v.nodes = {}
			local categoryIndex = self.getCategoryIndex()
			local tab = self.tabs[categoryIndex]
			local v4 = cells(self.inventoryList)
			local v5 = cells(self.ownList)
			local v6 = cells(self.otherList)
			local accept

			if GamepadSupport.IsVisible(self.accept) then
				accept = self.accept
			else
				accept = self.decline
			end

			self.countdown.Selectable = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function add(p)
				p.Selectable = true
				table.insert(v.nodes, p)
			end

			local function grid(items, instance, p, p2, tab2, p3)
				local uIGridLayout = instance:FindFirstChildOfClass("UIGridLayout")
				local navigationColumns = instance:GetAttribute("NavigationColumns") or not uIGridLayout and 1 or math.max(
					1,
					uIGridLayout.AbsoluteCellCount.X
				)

				for k, item in items do
					add(item) -- equivalent call inferred; original call site unknown
					local v7 = (k - 1) % navigationColumns
					local nextSelectionLeft

					if v7 > 0 then
						nextSelectionLeft = items[k - 1]
					else
						nextSelectionLeft = p or item
					end

					item.NextSelectionLeft = nextSelectionLeft
					local nextSelectionRight

					if v7 < navigationColumns - 1 and items[k + 1] then
						nextSelectionRight = items[k + 1]
					else
						nextSelectionRight = p2 or item
					end

					item.NextSelectionRight = nextSelectionRight
					item.NextSelectionUp = items[k - navigationColumns] or tab2 or item
					item.NextSelectionDown = items[k + navigationColumns] or p3 or item
				end
			end

			for k, tab2 in self.tabs do
				add(tab2) -- equivalent call inferred; original call site unknown
				tab2.NextSelectionLeft = self.tabs[k - 1] or tab2
				tab2.NextSelectionRight = self.tabs[k + 1] or tab2
				tab2.NextSelectionUp = tab2
				tab2.NextSelectionDown = v4[1] or self.diamonds
			end

			grid(v4, self.inventoryList, tab, v5[1] or self.diamonds, tab, self.diamonds)
			grid(v5, self.ownList, v4[1] or tab, v6[1] or accept, tab, self.diamonds)
			grid(v6, self.otherList, v5[1] or v4[1] or tab, accept, tab, accept)
			add(self.diamonds) -- equivalent call inferred; original call site unknown
			add(self.decline) -- equivalent call inferred; original call site unknown

			if accept == self.accept then
				add(self.accept) -- equivalent call inferred; original call site unknown
			end

			self.diamonds.NextSelectionLeft = v4[1] or tab
			self.diamonds.NextSelectionRight = accept
			self.diamonds.NextSelectionUp = v5[1] or v4[1] or tab
			self.diamonds.NextSelectionDown = accept
			self.decline.NextSelectionLeft = self.diamonds
			self.decline.NextSelectionRight = accept
			self.decline.NextSelectionUp = v6[1] or v5[1] or self.diamonds
			self.decline.NextSelectionDown = self.decline
			self.accept.NextSelectionLeft = self.decline
			self.accept.NextSelectionRight = self.accept
			self.accept.NextSelectionUp = v6[1] or self.diamonds
			self.accept.NextSelectionDown = self.accept

			if usable() and not table.find(v.nodes, GuiService.SelectedObject) then
				local diamonds3 = nil
				local v7 = nil
				local memory = v.memory

				if memory then
					for _, node in v.nodes do
						if node == memory.node then
							diamonds3 = node
							break
						elseif (node.Parent == memory.parent or node.Parent.Parent == memory.parent) and memory.key then
							if node:GetAttribute("TradeNavigationKey") == memory.key then
								diamonds3 = node
								break
							else
								local v9 = math.abs(node.LayoutOrder - memory.order)

								if not v7 or v9 < v7 then
									diamonds3 = node
									v7 = v9
								end
							end
						end
					end

					if memory.node == self.accept then
						diamonds3 = self.diamonds
					end
				end

				focus(diamonds3 or tab) -- equivalent call inferred; original call site unknown
			end

			v2 = false
		end

		function v:Refresh()
			self.dirty = true
		end

		function v:Open()
			if not self.active then
				self.previous = GuiService.SelectedObject
				self.memory = nil
			end

			self.active = true
			refresh()
		end

		function v.Close(p)
			p.active = false
			p.memory = nil

			if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(self.panel) then
				GuiService.SelectedObject = nil

				if not GamepadSupport.IsBlocked() then
					focus(p.previous) -- equivalent call inferred; original call site unknown
				end
			end

			p.previous = nil
		end

		function v.SetCategory(p)
			p.memory = nil
			refresh()

			if usable() then
				focus(self.tabs[self.getCategoryIndex()]) -- equivalent call inferred; original call site unknown
			end
		end

		function v:Destroy()
			self:Close()

			for _, connection in connections do
				connection:Disconnect()
			end

			ContextActionService:UnbindAction("TradeNavigation")
		end

		table.insert(connections, GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
			if v2 or not GamepadPages.CanRestoreFocus(self.panel) or not (v.active and GamepadSupport.IsGamepad()) or not GamepadSupport.IsVisible(self.panel) or GamepadSupport.IsBlocked() then
				return
			end

			local selectedObject = GuiService.SelectedObject

			if selectedObject and selectedObject:IsDescendantOf(self.panel) then
				remember(selectedObject)
				reveal(selectedObject)
			end
		end))

		for _, v4 in { self.inventoryList, self.ownList, self.otherList } do
			table.insert(connections, v4.ChildAdded:Connect(function()
				v.dirty = true
			end))
			table.insert(connections, v4.ChildRemoved:Connect(function()
				v.dirty = true
			end))
			table.insert(connections, v4:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				v.dirty = true
			end))
			local uIGridLayout = v4:FindFirstChildOfClass("UIGridLayout") or v4:FindFirstChildOfClass("UIListLayout")

			if uIGridLayout then
				table.insert(
					connections,
					uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
						v.dirty = true
					end)
				)
			end
		end

		table.insert(connections, self.accept:GetPropertyChangedSignal("Visible"):Connect(function()
			v.dirty = true
		end))
		table.insert(connections, UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			v.dirty = true
		end))
		table.insert(connections, diamonds.FocusLost:Connect(function()
			task.defer(function()
				if usable() then
					focus(self.diamonds) -- equivalent call inferred; original call site unknown
				end
			end)
		end))
		local total = 0
		table.insert(connections, RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total < 0.1 then
				return
			end

			total = 0

			if v.active then
				if v.dirty or usable() and not table.find(v.nodes, GuiService.SelectedObject) then
					refresh()
				end

				if usable() then
					remember(GuiService.SelectedObject)
				end
			end
		end))
		GamepadSupport.WatchRoot(self.panel)
		return v
	end
}