require(script.Parent.Parent.Types)
return function(p, p2)
	local v = 0
	p.WidgetConstructor("Root", {
		hasState = false,
		hasChildren = true,
		Args = {},
		Events = {},
		Generate = function(_)
			local folder = Instance.new("Folder")
			folder.Name = "Iris_Root"
			local parent

			if p._config.UseScreenGUIs then
				parent = Instance.new("ScreenGui")
				parent.ResetOnSpawn = false
				parent.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				parent.DisplayOrder = p._config.DisplayOrderOffset
				parent.IgnoreGuiInset = p._config.IgnoreGuiInset
			else
				parent = Instance.new("Frame")
				parent.AnchorPoint = Vector2.new(0.5, 0.5)
				parent.Position = UDim2.new(0.5, 0, 0.5, 0)
				parent.Size = UDim2.new(1, 0, 1, 0)
				parent.BackgroundTransparency = 1
				parent.ZIndex = p._config.DisplayOrderOffset
			end

			parent.Name = "PseudoWindowScreenGui"
			parent.Parent = folder
			local parent2

			if p._config.UseScreenGUIs then
				parent2 = Instance.new("ScreenGui")
				parent2.ResetOnSpawn = false
				parent2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				parent2.DisplayOrder = p._config.DisplayOrderOffset + 1024
				parent2.IgnoreGuiInset = p._config.IgnoreGuiInset
			else
				parent2 = Instance.new("Frame")
				parent2.AnchorPoint = Vector2.new(0.5, 0.5)
				parent2.Position = UDim2.new(0.5, 0, 0.5, 0)
				parent2.Size = UDim2.new(1, 0, 1, 0)
				parent2.BackgroundTransparency = 1
				parent2.ZIndex = p._config.DisplayOrderOffset + 1024
			end

			parent2.Name = "PopupScreenGui"
			parent2.Parent = folder
			local frame = Instance.new("Frame")
			frame.Name = "TooltipContainer"
			frame.AutomaticSize = Enum.AutomaticSize.XY
			frame.Size = UDim2.fromOffset(0, 0)
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			p2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, p._config.PopupBorderSize))
			frame.Parent = parent2
			local frame2 = Instance.new("Frame")
			frame2.Name = "MenuBarContainer"
			frame2.AutomaticSize = Enum.AutomaticSize.Y
			frame2.Size = UDim2.fromScale(1, 0)
			frame2.BackgroundTransparency = 1
			frame2.BorderSizePixel = 0
			frame2.Parent = parent2
			local frame3 = Instance.new("Frame")
			frame3.Name = "PseudoWindow"
			frame3.Size = UDim2.new(0, 0, 0, 0)
			frame3.Position = UDim2.fromOffset(0, 22)
			frame3.AutomaticSize = Enum.AutomaticSize.XY
			frame3.BackgroundTransparency = p._config.WindowBgTransparency
			frame3.BackgroundColor3 = p._config.WindowBgColor
			frame3.BorderSizePixel = p._config.WindowBorderSize
			frame3.BorderColor3 = p._config.BorderColor
			frame3.Selectable = false
			frame3.SelectionGroup = true
			frame3.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
			frame3.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
			frame3.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
			frame3.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
			frame3.Visible = false
			p2.UIPadding(frame3, p._config.WindowPadding)
			p2.UIListLayout(frame3, Enum.FillDirection.Vertical, UDim.new(0, p._config.ItemSpacing.Y))
			frame3.Parent = parent
			return folder
		end,
		Update = function(p3)
			if v > 0 then
				p3.Instance.PseudoWindowScreenGui.PseudoWindow.Visible = true
			end
		end,
		Discard = function(p3)
			v = 0
			p3.Instance:Destroy()
		end,
		ChildAdded = function(p3, p4)
			local instance = p3.Instance

			if p4.type == "Window" then
				return p3.Instance
			end

			if p4.type == "Tooltip" then
				return instance.PopupScreenGui.TooltipContainer
			end

			if p4.type == "MenuBar" then
				return instance.PopupScreenGui.MenuBarContainer
			end

			local pseudoWindow = instance.PseudoWindowScreenGui.PseudoWindow
			v += 1
			pseudoWindow.Visible = true
			return pseudoWindow
		end,
		ChildDiscarded = function(p3, p4)
			if p4.type ~= "Window" and p4.type ~= "Tooltip" and p4.type ~= "MenuBar" then
				v -= 1

				if v == 0 then
					p3.Instance.PseudoWindowScreenGui.PseudoWindow.Visible = false
				end
			end
		end
	})
end