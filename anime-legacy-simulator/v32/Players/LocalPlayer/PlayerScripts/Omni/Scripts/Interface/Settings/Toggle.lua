local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(0, 255, 149)
local color3 = Color3.fromRGB(255, 51, 99)
local uDim = UDim2.fromScale(0.789, 0.5)
local uDim2 = UDim2.fromScale(0.211, 0.5)
local fusion = module.Libs.Fusion
local scroll = module.Interface:WaitForChild("Frames"):WaitForChild("Settings"):WaitForChild("SettingsList"):WaitForChild("Scroll")
local settings = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Settings")
return fusion.scoped(fusion, {
	BindToggle = function(self)
		local toggle = self.Instance.Main.Toggle
		local point = toggle.Point
		local value = self:Value(1)
		local v = false
		local v2 = false
		point.Active = false
		point.Interactable = false
		point.Selectable = false
		self:Hydrate(point:FindFirstChildWhichIsA("UIScale") or self:New("UIScale")({
			Parent = point
		}))({
			Scale = self:Spring(value, 40, 1)
		})
		local v3 = self:New("TextButton")({
			Name = "Hitbox",
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0, 0),
			AnchorPoint = Vector2.zero,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Visible = true,
			Active = true,
			Interactable = true,
			Selectable = true,
			ZIndex = point.ZIndex + 1,
			Parent = toggle
		})
		table.insert(self, v3.MouseEnter:Connect(function()
			v = true
			value:set(1.05)
		end))
		table.insert(self, v3.MouseLeave:Connect(function()
			v = false
			value:set(v2 and 1.05 or 1)
		end))
		table.insert(self, v3.MouseButton1Down:Connect(function()
			value:set(0.95)
		end))
		table.insert(self, v3.MouseButton1Up:Connect(function()
			value:set((v or v2) and 1.05 or 1)
		end))
		table.insert(self, v3.SelectionGained:Connect(function()
			v2 = true
			value:set(1.05)
		end))
		table.insert(self, v3.SelectionLost:Connect(function()
			v2 = false
			value:set(v and 1.05 or 1)
		end))
		table.insert(self, v3.Activated:Connect(function()
			local v4 = module.Data.Settings[self.Name] == true
			module.Signal:Fire("General", "Settings", "Set", self.Name, not v4)
		end))
	end,
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(1.75, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.TogglePosition = self:Value(uDim2)
		self.TogglePositionSpring = self:Spring(self.TogglePosition, 10, 1)
		self.ToggleColor = self:Value(color3)
		self.ToggleColorSpring = self:Spring(self.ToggleColor, 10, 1)
		self.Instance = settings.Toggle:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name
		self.Instance.Main.Desc.Text = self.Info.Description
		self:BindToggle()
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Hydrate(self.Instance.Main.Toggle)({
			ImageColor3 = self.ToggleColorSpring
		})
		self:Hydrate(self.Instance.Main.Toggle.Point)({
			Position = self.TogglePositionSpring,
			ImageColor3 = self.ToggleColorSpring
		})
		self:Hydrate(self.Instance.Main.Toggle.Point.Glow)({
			ImageColor3 = self.ToggleColorSpring
		})
		self:Observer(self.ToggleColorSpring):onBind(function()
			local toggleColorSpring = self.peek(self.ToggleColorSpring)

			if not toggleColorSpring then
				return
			end

			self.Instance.Main.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color),
				ColorSequenceKeypoint.new(1, toggleColorSpring)
			})
		end)

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local v = module.Data.Settings[self.Name] == true
		self.ToggleColor:set(v and color2 or color3)
		self.TogglePosition:set(v and uDim or uDim2)
	end
})