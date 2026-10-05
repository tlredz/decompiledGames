local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
return {
	new = function(instance, data, data2)
		data2.ensureDrawer(instance)
		local v = {
			opened = false,
			available = false,
			pinned = false,
			version = 0,
			connections = {}
		}
		local menuToggle = instance.MenuToggle
		local panel = instance.DrawerClip.Panel
		local drawerReveal = instance.DrawerReveal
		local v2 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function connect(object, p)
			table.insert(v.connections, object:Connect(p))
		end

		local function contains(p, p2)
			local absolutePosition = p.AbsolutePosition
			local absoluteSize = p.AbsoluteSize
			return p2.X >= absolutePosition.X and p2.X <= absolutePosition.X + absoluteSize.X and p2.Y >= absolutePosition.Y and p2.Y <= absolutePosition.Y + absoluteSize.Y
		end

		local function mouseInside()
			local guiInset = GuiService:GetGuiInset()
			local v3 = UserInputService:GetMouseLocation() - guiInset
			local v4 = menuToggle
			local absolutePosition = v4.AbsolutePosition
			local absoluteSize = v4.AbsoluteSize
			local visible

			if v3.X >= absolutePosition.X and v3.X <= absolutePosition.X + absoluteSize.X and v3.Y >= absolutePosition.Y then
				visible = v3.Y <= absolutePosition.Y + absoluteSize.Y
			else
				visible = false
			end

			if visible then
				return visible
			end

			visible = panel.Visible

			if not visible then
				return visible
			end

			local v5 = panel
			local absolutePosition2 = v5.AbsolutePosition
			local absoluteSize2 = v5.AbsoluteSize

			if v3.X >= absolutePosition2.X and v3.X <= absolutePosition2.X + absoluteSize2.X and v3.Y >= absolutePosition2.Y then
				visible = v3.Y <= absolutePosition2.Y + absoluteSize2.Y
			else
				visible = false
			end

			return visible
		end

		function v:setOpen(p, p2, p3)
			local available = p and self.available
			self.pinned = available and p2 == true
			self.version += 1
			local version = self.version
			self.opened = available

			if v2 then
				v2:Cancel()
				v2 = nil
			end

			menuToggle.Arrow.Text = available and "‹" or "›"
			menuToggle.Modal = available and UserInputService.PreferredInput ~= Enum.PreferredInput.Touch

			if available then
				panel.Visible = true
			end

			if p3 then
				drawerReveal.Value = available and 1 or 0
				panel.Visible = available
			else
				v2 = TweenService:Create(
					drawerReveal,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Value = available and 1 or 0
					}
				)
				v2:Play()

				if not available then
					task.delay(0.2, function()
						if self.version == version then
							panel.Visible = false
						end
					end)
				end
			end

			instance:SetAttribute("DrawerOpen", available)

			if not available then
				instance.Notice.Visible = false
			end

			if not available and GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(panel) then
				GuiService.SelectedObject = self.available and menuToggle or nil
			end

			data.Changed:Fire("Drawer")
		end

		function v:setAvailable(p)
			local v3 = p == true

			if self.available == v3 then
				return
			end

			self.available = v3
			menuToggle.Visible = v3
			instance.DrawerClip.Visible = v3

			if not v3 then
				self:setOpen(false, false, true)
			end
		end

		function v.isOpen(p)
			return p.opened
		end

		local function leave()
			local version = v.version
			task.delay(0.28, function()
				if v.opened and not v.pinned and v.version == version then
					local guiInset = GuiService:GetGuiInset()
					local v3 = UserInputService:GetMouseLocation() - guiInset
					local v4 = menuToggle
					local absolutePosition = v4.AbsolutePosition
					local absoluteSize = v4.AbsoluteSize
					local visible

					if v3.X >= absolutePosition.X and v3.X <= absolutePosition.X + absoluteSize.X and v3.Y >= absolutePosition.Y then
						visible = v3.Y <= absolutePosition.Y + absoluteSize.Y
					else
						visible = false
					end

					if not visible then
						visible = panel.Visible

						if visible then
							local v5 = panel
							local absolutePosition2 = v5.AbsolutePosition
							local absoluteSize2 = v5.AbsoluteSize

							if v3.X >= absolutePosition2.X and v3.X <= absolutePosition2.X + absoluteSize2.X and v3.Y >= absolutePosition2.Y then
								visible = v3.Y <= absolutePosition2.Y + absoluteSize2.Y
							else
								visible = false
							end
						end
					end

					if not visible then
						v:setOpen(false)
					end
				end
			end)
		end

		local changed = drawerReveal.Changed
		table.insert(v.connections, changed:Connect(function()
			data2.positionDrawer(instance)
		end))

		local function fn()
			if v.available and not v.opened and UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse and UserInputService.MouseBehavior == Enum.MouseBehavior.Default and not (GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox()) then
				v:setOpen(true, false)
			end
		end

		connect(menuToggle.MouseEnter, fn) -- equivalent call inferred; original call site unknown
		connect(menuToggle.MouseLeave, leave) -- equivalent call inferred; original call site unknown
		connect(panel.MouseLeave, leave) -- equivalent call inferred; original call site unknown

		local function fn2()
			if v.opened and v.pinned then
				v:setOpen(false)
				return
			end

			v:setOpen(true, true)

			if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
				for _, v3 in data2.Order do
					if not data.available[v3] then
						continue
					end

					GuiService.SelectedObject = panel.Navigation[v3]
					return
				end
			end
		end

		connect(menuToggle.Activated, fn2) -- equivalent call inferred; original call site unknown
		local event = data.Opening.Event
		table.insert(v.connections, event:Connect(function()
			v:setOpen(false, false, true)
		end))

		local function fn3(p, p2)
			if not v.opened or UserInputService:GetFocusedTextBox() then
				return
			end

			if p.KeyCode == Enum.KeyCode.Escape or p.KeyCode == Enum.KeyCode.ButtonB then
				v:setOpen(false)
			elseif not p2 and (p.KeyCode == Enum.KeyCode.W or p.KeyCode == Enum.KeyCode.A or p.KeyCode == Enum.KeyCode.S or p.KeyCode == Enum.KeyCode.D or p.KeyCode == Enum.KeyCode.Space) then
				v:setOpen(false)
			end
		end

		connect(UserInputService.InputBegan, fn3) -- equivalent call inferred; original call site unknown
		local windowFocusReleased = UserInputService.WindowFocusReleased
		table.insert(v.connections, windowFocusReleased:Connect(function()
			v:setOpen(false, false, true)
		end))
		local propertyChangedSignal = UserInputService:GetPropertyChangedSignal("PreferredInput")
		table.insert(v.connections, propertyChangedSignal:Connect(function()
			if v.opened then
				v:setOpen(false, false, true)
			end
		end))

		function v:destroy()
			self:setOpen(false, false, true)

			for _, connection in self.connections do
				connection:Disconnect()
			end
		end

		menuToggle.Visible = false
		instance.DrawerClip.Visible = false
		panel.Visible = false
		drawerReveal.Value = 0
		return v
	end
}