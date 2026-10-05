local ValleyPanels = require(script.Parent.ValleyPanels)
return {
	new = function(instance)
		local screen = ValleyPanels.screen(instance, "ValleySpectate", 76)
		local v = {
			gui = screen,
			mode = "Follow",
			active = false,
			touch = false,
			open = ValleyPanels.button(screen, "Open", "◉  WATCH MATCH", 0, 0, 156, 42, Color3.fromRGB(31, 59, 72))
		}
		v.open.AnchorPoint = Vector2.new(1, 1)
		v.open.Position = UDim2.new(1, -18, 1, -30)
		local bar = ValleyPanels.make("Frame", screen, "Controls", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -16),
			Size = UDim2.fromOffset(760, 96),
			BackgroundColor3 = ValleyPanels.Ink,
			BorderSizePixel = 0,
			Visible = false
		})
		ValleyPanels.corner(bar, 12)
		ValleyPanels.stroke(bar, ValleyPanels.Blue, 0.35)
		v.bar = bar
		v.scale = ValleyPanels.make("UIScale", bar, "Scale", {})
		v.label = ValleyPanels.text(bar, "Label", "WATCHING", 18, 8, 550, 16, 11, ValleyPanels.Blue)
		v.name = ValleyPanels.text(bar, "Subject", "", 18, 26, 410, 26, 20)
		v.name.Font = Enum.Font.GothamBold
		v.role = ValleyPanels.text(bar, "Role", "", 18, 63, 180, 18, 12, ValleyPanels.Muted)
		v.prev = ValleyPanels.button(bar, "Previous", "‹", 200, 52, 44, 36)
		v.prev.TextSize = 26
		v.next = ValleyPanels.button(bar, "Next", "›", 250, 52, 44, 36)
		v.next.TextSize = 26
		v.follow = ValleyPanels.button(bar, "Follow", "FOLLOW", 310, 52, 104, 36)
		v.free = ValleyPanels.button(bar, "Free", "FREE CAM", 422, 52, 115, 36)
		v.exit = ValleyPanels.button(bar, "Exit", "EXIT SPECTATE  ×", 553, 20, 187, 62, Color3.fromRGB(130, 61, 62))
		v.exit.TextSize = 16
		v.hint = ValleyPanels.text(screen, "ControlHint", "", 0, 0, 660, 25, 12, ValleyPanels.Paper)
		v.hint.AnchorPoint = Vector2.new(0.5, 1)
		v.hint.BackgroundColor3 = ValleyPanels.Ink
		v.hint.BackgroundTransparency = 0.28
		ValleyPanels.corner(v.hint, 5)
		v.hint.TextXAlignment = Enum.TextXAlignment.Center
		v.hint.Visible = false
		v.hintButton = ValleyPanels.button(bar, "HintToggle", "?", 507, 8, 26, 26)
		v.hintButton.TextSize = 14
		v.hintVersion = 0
		v.hintConnection = v.hintButton.Activated:Connect(function()
			v.hintVersion += 1
			v.hint.Visible = not v.hint.Visible
		end)
		v.note = ValleyPanels.text(screen, "Notice", "", 0, 0, 330, 36, 14, ValleyPanels.Paper)
		v.note.AnchorPoint = Vector2.new(1, 1)
		v.note.Position = UDim2.new(1, -18, 1, -130)
		v.note.TextXAlignment = Enum.TextXAlignment.Right
		local pad2 = ValleyPanels.make("Frame", screen, "FlightPad", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 24, 1, -152),
			Size = UDim2.fromOffset(126, 126),
			BackgroundColor3 = ValleyPanels.Ink,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Active = true,
			Visible = false
		})
		ValleyPanels.corner(pad2, 63)
		ValleyPanels.stroke(pad2, ValleyPanels.Blue, 0.15)
		v.pad = pad2
		v.knob = ValleyPanels.make("Frame", pad2, "Knob", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(46, 46),
			BackgroundColor3 = ValleyPanels.Blue,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0
		})
		ValleyPanels.corner(v.knob, 23)
		local text = ValleyPanels.text(pad2, "Hint", "MOVE", 27, 96, 72, 20, 11, ValleyPanels.Paper)
		text.TextXAlignment = Enum.TextXAlignment.Center
		v.up = ValleyPanels.button(screen, "Up", "UP ↑", 0, 0, 66, 48)
		v.up.AnchorPoint = Vector2.new(1, 1)
		v.down = ValleyPanels.button(screen, "Down", "DOWN ↓", 0, 0, 66, 48)
		v.down.AnchorPoint = Vector2.new(1, 1)
		v.zoomIn = ValleyPanels.button(screen, "ZoomIn", "＋", 0, 0, 48, 44)
		v.zoomIn.AnchorPoint = Vector2.new(1, 1)
		v.zoomIn.TextSize = 24
		v.zoomOut = ValleyPanels.button(screen, "ZoomOut", "−", 0, 0, 48, 44)
		v.zoomOut.AnchorPoint = Vector2.new(1, 1)
		v.zoomOut.TextSize = 24
		v.up.Visible = false
		v.down.Visible = false
		v.zoomIn.Visible = false
		v.zoomOut.Visible = false

		function v:layout()
			local absoluteSize = screen.AbsoluteSize
			local v4 = absoluteSize.X < absoluteSize.Y
			local v5 = v4 and 360 or 760
			local v6 = v4 and 143 or 96
			bar.Size = UDim2.fromOffset(v5, v6)
			self.scale.Scale = math.min(1, absoluteSize.X * 0.94 / v5)
			self.label.Size = UDim2.fromOffset(v4 and 320 or 550, 16)
			self.name.Size = UDim2.fromOffset(v4 and 320 or 410, 26)
			self.name.TextSize = v4 and 18 or 20
			self.role.Visible = not v4
			local v7 = v4 and 50 or 52
			self.prev.Position = UDim2.fromOffset(v4 and 12 or 200, v7)
			self.next.Position = UDim2.fromOffset(v4 and 62 or 250, v7)
			self.follow.Position = UDim2.fromOffset(v4 and 113 or 310, v7)
			self.free.Position = UDim2.fromOffset(v4 and 228 or 422, v7)
			self.exit.Position = UDim2.fromOffset(v4 and 12 or 553, v4 and 92 or 20)
			self.exit.Size = UDim2.fromOffset(v4 and 336 or 187, v4 and 42 or 62)
			self.hintButton.Position = UDim2.fromOffset(v4 and 317 or 507, 8)
			self.hint.Size = UDim2.fromOffset(math.min(absoluteSize.X * 0.9, 660), v4 and 34 or 25)
			self.hint.Position = UDim2.new(0.5, 0, 1, -v6 * self.scale.Scale - 22)
			local v8 = v6 * self.scale.Scale + 32
			pad2.Position = UDim2.new(0, 20, 1, -v8)
			pad2.Size = UDim2.fromOffset(v4 and 110 or 116, v4 and 110 or 116)
			pad2.Hint.Position = UDim2.fromOffset(19, v4 and 84 or 90)
			self.up.Position = UDim2.new(1, -20, 1, -v8 - 55)
			self.down.Position = UDim2.new(1, -20, 1, -v8)
			self.zoomIn.Position = UDim2.new(1, -20, 1, -v8 - 51)
			self.zoomOut.Position = UDim2.new(1, -20, 1, -v8)
		end

		function v:render(p, mode, p2, gamepad)
			local v4 = self.active ~= p or self.mode ~= mode or self.touch ~= p2 or self.gamepad ~= gamepad
			self.active = p
			self.mode = mode
			self.touch = p2
			self.gamepad = gamepad
			self.hintButton.Visible = p
			local hint = self.hint
			local text2

			if p2 then
				text2 = mode == "Free" and "Left pad: fly · Swipe right: look · UP / DOWN" or "Swipe to orbit · + / − to zoom"
			elseif gamepad then
				text2 = mode == "Free" and "Left stick: fly · Right stick: look · Triggers: height" or "Right stick: orbit · Triggers: zoom · Bumpers: switch"
			else
				text2 = mode == "Free" and "WASD: fly · Q / E: height · Right-drag: look · Shift: faster" or "Right-drag: orbit · Scroll: zoom · X: exit"
			end

			hint.Text = text2

			if p and instance:GetAttribute("SpectatorHints") ~= false then
				if v4 then
					self.hintVersion += 1
					local hintVersion = self.hintVersion
					self.hint.Visible = true
					task.delay(8, function()
						if self.hintVersion == hintVersion and self.hint.Parent then
							self.hint.Visible = false
						end
					end)
				end
			else
				self.hint.Visible = false
			end

			bar.Visible = p
			local pad = self.pad
			local visible

			if p then
				if mode == "Free" then
					visible = p2
				else
					visible = false
				end
			else
				visible = p
			end

			pad.Visible = visible
			self.up.Visible = self.pad.Visible
			self.down.Visible = self.pad.Visible
			local zoomIn = self.zoomIn

			if p then
				if mode ~= "Follow" then
					p2 = false
				end
			else
				p2 = p
			end

			zoomIn.Visible = p2
			self.zoomOut.Visible = self.zoomIn.Visible
			self.prev.Visible = mode == "Follow"
			self.next.Visible = mode == "Follow"
			self.follow.BackgroundColor3 = mode == "Follow" and Color3.fromRGB(43, 93, 109) or Color3.fromRGB(
				36,
				56,
				70
			)
			self.free.BackgroundColor3 = mode == "Free" and Color3.fromRGB(43, 93, 109) or Color3.fromRGB(36, 56, 70)
			self:layout()
		end

		v.connection = screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			v:layout()
		end)
		v:layout()

		function v.destroy(p)
			p.connection:Disconnect()
			p.hintConnection:Disconnect()
			screen:Destroy()
		end

		return v
	end
}