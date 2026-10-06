local GamepadPages = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ButtonHints = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonHints)
local PageControls = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.PageControls)
local GuiService = game:GetService("GuiService")
game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local GamepadSupport = require(game.ReplicatedStorage.Engine.Service.GamepadSupport)

local function reveal(selectedObject, panel)
	local parent = selectedObject.Parent

	while parent and parent ~= panel do
		if parent:IsA("ScrollingFrame") then
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

		parent = parent.Parent
	end
end

return {
	new = function(data)
		local v = {}
		local v2 = data.panel:WaitForChild("查看全部页面")
		GamepadPages.Observe(data.panel, {
			available = data.isOpen,
			defaultButton = data.tabs[1].button
		})

		local function step(p)
			local tabs = {}

			for _, tab in data.tabs do
				if GamepadSupport.CanActivate(tab.button) then
					table.insert(tabs, tab)
				end
			end

			if #tabs == 0 then
				return
			end

			local v3 = 1

			for k, v5 in tabs do
				if v5.key ~= data.getTab() then
					continue
				end

				v3 = k
				break
			end

			data.onTab(tabs[(v3 - 1 + p) % #tabs + 1].key)
		end

		PageControls.FromHint(data.panel, "上一分类手柄提示", "L1", function()
			step(-1)
		end)
		PageControls.FromHint(data.panel, "下一分类手柄提示", "R1", function()
			step(1)
		end)

		local function register(guiObject)
			if guiObject:IsA("GuiButton") then
				v[guiObject] = true
			elseif guiObject:IsA("ScrollingFrame") then
				guiObject.Selectable = false
			end
		end

		local v3 = {
			nodes = {},
			memory = {},
			page = nil,
			previous = nil,
			active = false
		}

		for _, guiObject in data.panel:GetDescendants() do
			if guiObject:IsA("GuiButton") then
				v[guiObject] = true
			elseif guiObject:IsA("ScrollingFrame") then
				guiObject.Selectable = false
			end
		end

		data.panel.DescendantAdded:Connect(register)
		data.panel.DescendantRemoving:Connect(function(descendant)
			v[descendant] = nil
		end)
		GamepadSupport.WatchRoot(data.panel)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function blocked()
			return not GamepadPages.IsActive(data.panel)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function usable()
			return GamepadPages.CanRestoreFocus(data.panel) and data.isOpen() and GamepadSupport.IsGamepad() and GamepadSupport.IsVisible(data.panel) and (GamepadPages.IsActive(data.panel) and true or false)
		end

		local function page()
			if v2.Visible then
				return v2
			end

			for _, page2 in data.pages do
				if page2.Visible then
					return page2
				end
			end

			return data.panel
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function focus(selectedObject)
			if selectedObject and selectedObject.Parent and selectedObject.Selectable and GamepadSupport.IsVisible(selectedObject) then
				GuiService.SelectedObject = selectedObject
				reveal(selectedObject, data.panel)
			end
		end

		function v3:Release()
			if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(data.panel) then
				GuiService.SelectedObject = nil

				if GamepadPages.IsActive(data.panel) then
					focus(self.previous) -- equivalent call inferred; original call site unknown
				end
			end

			self.previous = nil
			self.active = false
			self.page = nil
			self.preferredTab = nil
		end

		function v3:Refresh()
			if data.isOpen() and GamepadSupport.IsGamepad() and GamepadSupport.IsVisible(data.panel) then
				if not GamepadPages.CanRestoreFocus(data.panel) or blocked() then
					return
				end

				if not self.active then
					self.previous = GuiService.SelectedObject
					self.active = true
				end

				local panel

				if v2.Visible then
					panel = v2
				else
					local flag = true

					for _, page2 in data.pages do
						if not page2.Visible then
							continue
						end

						panel = page2
						flag = false
						break
					end

					if flag then
						panel = data.panel
					end
				end

				ButtonHints.Shortcut(data.panel["关闭按钮"], panel == v2 and "A" or "B")
				local v4 = panel ~= self.page
				self.page = panel
				self.nodes = {}

				for k in v do
					if k.Parent then
						local _ = k.Parent.Name == "奖池"
					end

					k.Selectable = ButtonActions.Has(k) and k.Active and k.Interactable and GamepadSupport.IsVisible(k)

					if k.Selectable then
						table.insert(self.nodes, k)
					end
				end

				table.sort(self.nodes, function(a, b)
					if a.AbsolutePosition.Y ~= b.AbsolutePosition.Y then
						return a.AbsolutePosition.Y < b.AbsolutePosition.Y
					end

					if a.AbsolutePosition.X == b.AbsolutePosition.X then
						return a.LayoutOrder < b.LayoutOrder
					end

					return a.AbsolutePosition.X < b.AbsolutePosition.X
				end)

				for _, node in self.nodes do
					local v5 = node.AbsolutePosition + node.AbsoluteSize / 2

					for _, v6 in {
						{ "NextSelectionLeft", Vector2.new(-1, 0) },
						{ "NextSelectionRight", Vector2.new(1, 0) },
						{ "NextSelectionUp", Vector2.new(0, -1) },
						{ "NextSelectionDown", Vector2.new(0, 1) }
					} do
						local v7 = node
						local v8 = 1e999

						for _, node2 in self.nodes do
							if node2 == node then
								continue
							end

							local vector = node2.AbsolutePosition + node2.AbsoluteSize / 2 - v5
							local dot = vector:Dot(v6[2])

							if not (dot > 1) then
								continue
							end

							local v9 = dot + math.abs(vector.X * v6[2].Y - vector.Y * v6[2].X) * 3

							if not (v9 < v8) then
								continue
							end

							v7 = node2
							v8 = v9
						end

						node[v6[1]] = v7
					end
				end

				local selectedObject = GuiService.SelectedObject

				if self.preferredTab or v4 or not table.find(self.nodes, selectedObject) then
					local preferredTab = self.preferredTab or self.memory[panel]
					self.preferredTab = nil

					if not table.find(self.nodes, preferredTab) then
						preferredTab = nil

						for _, node in self.nodes do
							if not (node:IsDescendantOf(panel) and ButtonActions.Has(node)) then
								continue
							end

							if node.Name == "查看全部" or node.Name == "返回按钮" then
								preferredTab = node
								break
							else
								preferredTab = preferredTab or node
							end
						end
					end

					if not preferredTab then
						for _, tab in data.tabs do
							if not (tab.key == data.getTab() and table.find(self.nodes, tab.button)) then
								continue
							end

							preferredTab = tab.button
							break
						end
					end

					focus(preferredTab or data.panel["关闭按钮"]) -- equivalent call inferred; original call site unknown
				end

				GamepadSupport.Refresh()
			elseif self.active then
				self:Release()
			end
		end

		GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
			if not usable() then
				return
			end

			local selectedObject = GuiService.SelectedObject

			if selectedObject and selectedObject:IsDescendantOf(data.panel) then
				local panel

				if v2.Visible then
					panel = v2
				else
					local flag = true

					for _, page2 in data.pages do
						if not page2.Visible then
							continue
						end

						panel = page2
						flag = false
						break
					end

					if flag then
						panel = data.panel
					end
				end

				if panel == v3.page and selectedObject:IsDescendantOf(panel) then
					v3.memory[panel] = selectedObject
				end

				reveal(selectedObject, data.panel)
			end
		end)
		local total = 0
		RunService.Heartbeat:Connect(function(dt)
			total += dt

			if total >= 0.1 then
				total = 0
				v3:Refresh()
			end
		end)
		return v3
	end
}