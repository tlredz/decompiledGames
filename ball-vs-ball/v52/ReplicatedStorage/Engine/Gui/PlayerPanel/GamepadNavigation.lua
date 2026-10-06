local GamepadPages = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ButtonHints = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonHints)
local PageControls = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.PageControls)
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local GamepadSupport = require(game.ReplicatedStorage.Engine.Service.GamepadSupport)
local v = {
	"profile",
	"balls",
	"explosion",
	"flyer"
}

local function reveal(state, p)
	if not GamepadSupport.IsVisible(p) then
		return
	end

	local v2 = p.AbsolutePosition - state.AbsolutePosition
	local absoluteWindowSize = state.AbsoluteWindowSize
	local absoluteSize = p.AbsoluteSize

	local function delta(p2, p3, p4)
		if p2 < 0 then
			return p2
		end

		if p4 < p2 + p3 then
			return p2 + p3 - p4
		end

		return 0
	end

	local v3 = state.AbsoluteCanvasSize - absoluteWindowSize
	local canvasPosition = state.CanvasPosition
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

	state.CanvasPosition = Vector2.new(v4, (math.clamp(Y + Y2, 0, (math.max(0, v3.Y)))))
end

return {
	new = function(data)
		local v2 = {
			active = false,
			index = 1,
			previous = nil,
			remembered = {},
			cells = {},
			dirty = true
		}
		GamepadPages.Observe(data.panel, {
			available = function()
				return v2.active
			end,
			defaultButton = data.tabs[1]
		})
		local v3 = ButtonHints.Ensure(data.close, "B")
		PageControls.FromHint(data.panel, "上一分类手柄提示", "L1", function()
			data.onPage(v[(v2.index - 2) % #v + 1])
		end)
		PageControls.FromHint(data.panel, "下一分类手柄提示", "R1", function()
			data.onPage(v[v2.index % #v + 1])
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function usable()
			return GamepadPages.CanRestoreFocus(data.panel) and v2.active and GamepadSupport.IsGamepad() and GamepadSupport.IsVisible(data.panel) and not GamepadSupport.IsBlocked()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function tab()
			return data.tabs[v2.index]
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setFocus(selectedObject)
			if selectedObject and selectedObject.Parent and selectedObject.Selectable and GamepadSupport.IsVisible(selectedObject) then
				GuiService.SelectedObject = selectedObject
			end
		end

		local function listCells(k)
			local guiObjects = {}

			for _, guiObject in data.lists[k]:GetChildren() do
				if not (guiObject:IsA("GuiObject") and guiObject.Visible and (guiObject:GetAttribute("PlayerPanelGeneratedSlot") or guiObject:GetAttribute("RewardLevel"))) then
					continue
				end

				table.insert(guiObjects, guiObject)
			end

			table.sort(guiObjects, function(a, b)
				if a.LayoutOrder == b.LayoutOrder then
					return a.Name < b.Name
				end

				return a.LayoutOrder < b.LayoutOrder
			end)
			return guiObjects
		end

		local function refresh()
			v2.dirty = false
			local copies = data.isCopies()
			v3.Name = copies and "关闭快捷键提示" or "手柄B"

			if copies then
				v3.Visible = false
			end

			local v4 = {}

			if copies then
				table.insert(v4, data.copiesHeader["返回按钮"])

				for _, v5 in {
					"全部筛选",
					"经典筛选",
					"闪光筛选",
					"彩虹筛选"
				} do
					local v6 = data.copiesHeader[v5]

					if GamepadSupport.IsVisible(v6) then
						table.insert(v4, v6)
					end
				end
			end

			for k, list in data.lists do
				list.Selectable = false
				local v5 = k ~= v2.index and {} or listCells(k)
				v2.cells[k] = v5
				local uIGridLayout = list:FindFirstChildOfClass("UIGridLayout")
				local navigationColumns = list:GetAttribute("NavigationColumns")

				if not navigationColumns then
					if uIGridLayout then
						navigationColumns = math.max(1, uIGridLayout.AbsoluteCellCount.X)
					else
						navigationColumns = math.max(1, #v5)
					end
				end

				for k2, v6 in v5 do
					v6.Selectable = v2.active and k == v2.index
					local v7 = (k2 - 1) % navigationColumns
					local nextSelectionLeft

					if v7 == 0 then
						nextSelectionLeft = data.tabs[k]
					else
						nextSelectionLeft = v5[k2 - 1]
					end

					v6.NextSelectionLeft = nextSelectionLeft
					local nextSelectionRight

					if v7 < navigationColumns - 1 then
						nextSelectionRight = v5[k2 + 1] or v6
					else
						nextSelectionRight = v6
					end

					v6.NextSelectionRight = nextSelectionRight
					v6.NextSelectionUp = v5[k2 - navigationColumns] or v4[math.min(k2, #v4)] or data.tabs[k]
					v6.NextSelectionDown = v5[k2 + navigationColumns] or v6
				end
			end

			for k, tab2 in data.tabs do
				tab2.Selectable = v2.active
				tab2.NextSelectionUp = data.tabs[k - 1] or data.close
				tab2.NextSelectionDown = data.tabs[k + 1] or tab2
				local v5 = v2.cells[v2.index] or {}
				local trade = v5[math.min(v2.remembered[v2.index] or 1, #v5)]

				if not trade then
					if GamepadSupport.IsVisible(data.trade) then
						trade = data.trade
					else
						trade = data.close
					end
				end

				tab2.NextSelectionRight = trade
				tab2.NextSelectionLeft = tab2
			end

			local v5 = v2.cells[v2.index] or {}

			for k, v6 in v4 do
				v6.Selectable = v2.active
				v6.NextSelectionLeft = v4[k - 1] or tab()
				v6.NextSelectionRight = v4[k + 1] or v6
				v6.NextSelectionUp = data.close
				v6.NextSelectionDown = v5[1] or tab()
			end

			data.close.NextSelectionLeft = tab()
			local close = data.close
			local nextSelectionDown

			if GamepadSupport.IsVisible(data.trade) then
				nextSelectionDown = data.trade
			else
				nextSelectionDown = tab()
			end

			close.NextSelectionDown = nextSelectionDown
			data.close.NextSelectionRight = data.close
			data.close.NextSelectionUp = data.close
			data.trade.NextSelectionLeft = tab()
			data.trade.NextSelectionUp = data.close
			data.trade.NextSelectionDown = data.trade
			data.trade.NextSelectionRight = data.trade
			local selectedObject = GuiService.SelectedObject

			if usable() and not (selectedObject and selectedObject.Parent and selectedObject:IsDescendantOf(data.panel) and GamepadSupport.IsVisible(selectedObject)) then
				local v7 = v2.cells[v2.index] or {}
				setFocus(v7[math.min(v2.remembered[v2.index] or 1, #v7)] or tab()) -- equivalent call inferred; original call site unknown
			end
		end

		function v2:Refresh()
			self.dirty = true
		end

		function v2:FocusCopies()
			self.dirty = true
			refresh()

			if usable() then
				setFocus(data.copiesHeader["返回按钮"]) -- equivalent call inferred; original call site unknown
			end
		end

		function v2:FocusItem(p)
			self.dirty = true
			refresh()

			if not usable() then
				return
			end

			for _, v4 in self.cells[self.index] or {} do
				if v4:GetAttribute("ItemInstanceId") ~= p then
					continue
				end

				setFocus(v4) -- equivalent call inferred; original call site unknown
				reveal(data.lists[self.index], v4)
				return
			end

			local selectedObject = tab() -- equivalent call inferred; original call site unknown
			setFocus(selectedObject) -- equivalent call inferred; original call site unknown
		end

		function v2:SetPage(p2)
			for k, v4 in v do
				if v4 ~= p2 then
					continue
				end

				self.index = k
				break
			end

			self.dirty = true

			if usable() then
				local selectedObject = tab() -- equivalent call inferred; original call site unknown
				setFocus(selectedObject) -- equivalent call inferred; original call site unknown
			end
		end

		function v2:Open()
			if not self.active then
				self.previous = GuiService.SelectedObject
			end

			self.active = true
			refresh()

			if usable() then
				local selectedObject = tab() -- equivalent call inferred; original call site unknown
				setFocus(selectedObject) -- equivalent call inferred; original call site unknown
			end
		end

		function v2:Close()
			self.active = false
			self.dirty = true

			if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(data.panel) then
				GuiService.SelectedObject = nil

				if not GamepadSupport.IsBlocked() then
					setFocus(self.previous) -- equivalent call inferred; original call site unknown
				end
			end

			self.previous = nil
		end

		local function selectChanged()
			if not usable() then
				return
			end

			local selectedObject = GuiService.SelectedObject

			if selectedObject and selectedObject:IsDescendantOf(data.panel) then
				local list = data.lists[v2.index]

				if selectedObject.Parent == list then
					for k, v4 in v2.cells[v2.index] or {} do
						if v4 ~= selectedObject then
							continue
						end

						v2.remembered[v2.index] = k
						break
					end

					reveal(list, selectedObject)
				end
			else
				local selectedObject2 = tab() -- equivalent call inferred; original call site unknown
				setFocus(selectedObject2) -- equivalent call inferred; original call site unknown
			end
		end

		GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(selectChanged)
		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			if usable() then
				local selectedObject = tab() -- equivalent call inferred; original call site unknown
				setFocus(selectedObject) -- equivalent call inferred; original call site unknown
			end
		end)
		local v4 = {}

		for _, list in data.lists do
			if v4[list] then
				continue
			end

			v4[list] = true
			list.ChildAdded:Connect(function()
				v2.dirty = true
			end)
			list.ChildRemoved:Connect(function()
				v2.dirty = true
			end)
			list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				v2.dirty = true
			end)
			local uIGridLayout = list:FindFirstChildOfClass("UIGridLayout") or list:FindFirstChildOfClass("UIListLayout")

			if uIGridLayout then
				uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					v2.dirty = true
				end)
			end
		end

		data.trade:GetPropertyChangedSignal("Visible"):Connect(function()
			v2.dirty = true
		end)

		for _, guiObject in data.copiesHeader:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
					v2.dirty = true
				end)
			end
		end

		data.copiesHeader:GetPropertyChangedSignal("Visible"):Connect(function()
			v2.dirty = true
		end)
		data.tabList.Selectable = false
		local total = 0
		RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total < 0.1 then
				return
			end

			total = 0

			if v2.dirty then
				refresh()
			end

			if usable() then
				local selectedObject = GuiService.SelectedObject

				if not (selectedObject and selectedObject.Parent and selectedObject:IsDescendantOf(data.panel) and GamepadSupport.IsVisible(selectedObject)) then
					selectChanged()
				end
			end
		end)
		return v2
	end
}