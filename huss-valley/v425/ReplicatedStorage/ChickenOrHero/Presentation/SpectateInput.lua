local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local SpectateConfig = require(script.Parent.SpectateConfig)
local SpectateGeometry = require(script.Parent.SpectateGeometry)
return {
	new = function(data, callback)
		local v = {
			active = false,
			mode = "Follow",
			delta = Vector2.zero,
			zoom = 0,
			stick = Vector2.zero,
			holds = {},
			connections = {},
			focused = true
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function connect(object, fn)
			table.insert(v.connections, object:Connect(fn))
		end

		local function blocked()
			return game.Players.LocalPlayer:GetAttribute("CreatorPanelOpen") == true or game.Players.LocalPlayer:GetAttribute("GlobalWheelOpen") == true or (not v.active or not v.focused or GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() ~= nil)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function touch(p)
			return p.UserInputType == Enum.UserInputType.Touch
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function point(data2)
			return Vector2.new(data2.Position.X, data2.Position.Y)
		end

		local function updatePad(p)
			local v2 = data.pad.AbsolutePosition + data.pad.AbsoluteSize * 0.5
			local unit = (Vector2.new(p.Position.X, p.Position.Y) - v2) / (data.pad.AbsoluteSize.X * 0.35)

			if unit.Magnitude > 1 then
				unit = unit.Unit
			end

			v.stick = unit
			data.knob.Position = UDim2.new(
				0.5,
				unit.X * data.pad.AbsoluteSize.X * 0.3,
				0.5,
				unit.Y * data.pad.AbsoluteSize.Y * 0.3
			)
		end

		local inputBegan = data.pad.InputBegan
		table.insert(v.connections, inputBegan:Connect(function(padTouch)
			if not blocked() and touch(padTouch) and not v.padTouch then
				v.padTouch = padTouch
				updatePad(padTouch)
			end
		end))

		for _, v2 in {
			{ data.up, 1 },
			{ data.down, -1 }
		} do
			local inputBegan2 = v2[1].InputBegan
			local v3 = v2
			table.insert(v.connections, inputBegan2:Connect(function(p)
				if not blocked() and (touch(p) or p.UserInputType == Enum.UserInputType.MouseButton1) then
					v.holds[p] = v3[2]
				end
			end))
		end

		local inputBegan2 = UserInputService.InputBegan
		table.insert(v.connections, inputBegan2:Connect(function(lookTouch, p)
			if blocked() then
				return
			end

			if not p and lookTouch.KeyCode == Enum.KeyCode.X or lookTouch.KeyCode == Enum.KeyCode.ButtonB then
				callback("Stop")
				return
			end

			if p then
				return
			end

			if lookTouch.UserInputType == Enum.UserInputType.MouseButton2 then
				v.drag = true
			elseif touch(lookTouch) then
				if not v.lookTouch and (v.mode == "Follow" or lookTouch.Position.X > workspace.CurrentCamera.ViewportSize.X * 0.4) then
					v.lookTouch = lookTouch
					v.lastTouch = Vector2.new(lookTouch.Position.X, lookTouch.Position.Y)
				end
			elseif lookTouch.KeyCode == Enum.KeyCode.Left or lookTouch.KeyCode == Enum.KeyCode.ButtonL1 then
				callback("Previous")
			elseif lookTouch.KeyCode == Enum.KeyCode.Right or lookTouch.KeyCode == Enum.KeyCode.ButtonR1 then
				callback("Next")
			elseif lookTouch.KeyCode == Enum.KeyCode.F or lookTouch.KeyCode == Enum.KeyCode.ButtonY then
				callback("Toggle")
			end
		end))

		local function fn(data2, p)
			if blocked() then
				return
			end

			if data2 == v.padTouch then
				updatePad(data2)
			elseif data2 == v.lookTouch then
				local lastTouch = point(data2) -- equivalent call inferred; original call site unknown
				v.delta += (lastTouch - v.lastTouch) * SpectateConfig.TouchSensitivity
				v.lastTouch = lastTouch
			elseif data2.UserInputType == Enum.UserInputType.MouseMovement and v.drag and not (UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) then
				v.delta += Vector2.new(data2.Delta.X, data2.Delta.Y) * SpectateConfig.MouseSensitivity
			elseif data2.UserInputType == Enum.UserInputType.MouseWheel and not p then
				v.zoom -= data2.Position.Z * 2
			end
		end

		connect(UserInputService.InputChanged, fn) -- equivalent call inferred; original call site unknown
		local inputEnded = UserInputService.InputEnded
		table.insert(v.connections, inputEnded:Connect(function(p)
			v.holds[p] = nil

			if p.UserInputType == Enum.UserInputType.MouseButton1 then
				table.clear(v.holds)
			end

			if p.UserInputType == Enum.UserInputType.MouseButton2 then
				v.drag = false
			end

			if p == v.padTouch then
				v.padTouch = nil
				v.stick = Vector2.zero
				data.knob.Position = UDim2.fromScale(0.5, 0.5)
			end

			if p == v.lookTouch then
				v.lookTouch = nil
				v.lastTouch = nil
			end
		end))

		function v:reset()
			self.delta = Vector2.zero
			self.zoom = 0
			self.stick = Vector2.zero
			self.padTouch = nil
			self.lookTouch = nil
			self.drag = false
			table.clear(self.holds)
			data.knob.Position = UDim2.fromScale(0.5, 0.5)
		end

		function v:set(active, mode)
			self.active = active
			self.mode = mode
			self:reset()
		end

		local function fn2()
			v.focused = false
			v:reset()

			if v.active then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			end
		end

		connect(UserInputService.WindowFocusReleased, fn2) -- equivalent call inferred; original call site unknown
		local windowFocused = UserInputService.WindowFocused
		table.insert(v.connections, windowFocused:Connect(function()
			v.focused = true
		end))

		function v:sample(p)
			if blocked() then
				self:reset()
				return createVector(0, 0, 0), Vector2.zero, 0, false, false
			end

			local v2 = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function key(p2)
				if UserInputService:IsKeyDown(p2) then
					return 1
				end

				return 0
			end

			local vector2, v3

			if v2 then
				vector2 = createVector(0, 0, 0)
				v3 = false
			else
				local v4 = key(Enum.KeyCode.D) -- equivalent call inferred; original call site unknown
				local v5 = v4 - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
				local v6 = key(Enum.KeyCode.E) -- equivalent call inferred; original call site unknown
				local v7 = v6 - (UserInputService:IsKeyDown(Enum.KeyCode.Q) and 1 or 0)
				local v8 = key(Enum.KeyCode.S) -- equivalent call inferred; original call site unknown
				local W = Enum.KeyCode.W
				vector2 = Vector3.new(v5, v7, v8 - (UserInputService:IsKeyDown(W) and 1 or 0))

				if (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 1 or 0) == 1 then
					v3 = true
				else
					v3 = false
				end
			end

			local zero = Vector2.zero
			local v4 = 0

			if UserInputService.GamepadEnabled then
				for _, v5 in UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) do
					if v5.KeyCode == Enum.KeyCode.Thumbstick1 then
						local deadzone = SpectateGeometry.deadzone(Vector2.new(v5.Position.X, v5.Position.Y))
						vector2 += Vector3.new(deadzone.X, 0, -deadzone.Y)
					elseif v5.KeyCode == Enum.KeyCode.Thumbstick2 then
						local deadzone = SpectateGeometry.deadzone(Vector2.new(v5.Position.X, v5.Position.Y))
						zero = Vector2.new(deadzone.X, -deadzone.Y) * SpectateConfig.GamepadLookSpeed * p
					elseif v5.KeyCode == Enum.KeyCode.ButtonR2 then
						v4 += v5.Position.Z
					elseif v5.KeyCode == Enum.KeyCode.ButtonL2 then
						v4 -= v5.Position.Z
					end
				end
			end

			for _, hold in self.holds do
				v4 += hold
			end

			local unit = vector2 + Vector3.new(self.stick.X, self.mode == "Free" and v4 or 0, self.stick.Y)

			if unit.Magnitude > 1 then
				unit = unit.Unit
			end

			local v5 = self.delta + zero
			self.delta = Vector2.zero
			local v6 = self.zoom + (self.mode ~= "Follow" and 0 or -v4 * 20 * p or 0)
			self.zoom = 0
			return unit, v5, v6, v3, self.drag and not v2
		end

		function v:destroy()
			for _, connection in self.connections do
				connection:Disconnect()
			end

			self:reset()
		end

		return v
	end
}