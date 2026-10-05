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
				parent.DisplayOrder = p._config.DisplayOrderOffset
				parent.IgnoreGuiInset = p._config.IgnoreGuiInset
			else
				parent = Instance.new("Folder")
			end

			parent.Name = "PseudoWindowScreenGui"
			parent.Parent = folder
			local parent2

			if p._config.UseScreenGUIs then
				parent2 = Instance.new("ScreenGui")
				parent2.ResetOnSpawn = false
				parent2.DisplayOrder = p._config.DisplayOrderOffset + 1024
				parent2.IgnoreGuiInset = p._config.IgnoreGuiInset
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
			else
				parent2 = Instance.new("Folder")
			end

			parent2.Name = "PopupScreenGui"
			parent2.Parent = folder
			local frame = Instance.new("Frame")
			frame.Name = "PseudoWindow"
			frame.Size = UDim2.new(0, 0, 0, 0)
			frame.Position = UDim2.fromOffset(0, 22)
			frame.AutomaticSize = Enum.AutomaticSize.XY
			frame.BackgroundTransparency = p._config.WindowBgTransparency
			frame.BackgroundColor3 = p._config.WindowBgColor
			frame.BorderSizePixel = p._config.WindowBorderSize
			frame.BorderColor3 = p._config.BorderColor
			frame.Selectable = false
			frame.SelectionGroup = true
			frame.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
			frame.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
			frame.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
			frame.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
			frame.Visible = false
			p2.UIPadding(frame, p._config.WindowPadding)
			p2.UIListLayout(frame, Enum.FillDirection.Vertical, UDim.new(0, p._config.ItemSpacing.Y))
			frame.Parent = parent
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