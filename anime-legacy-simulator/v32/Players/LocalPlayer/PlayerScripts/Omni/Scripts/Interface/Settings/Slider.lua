local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local scroll = module.Interface:WaitForChild("Frames"):WaitForChild("Settings"):WaitForChild("SettingsList"):WaitForChild("Scroll")
local settings = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Settings")
return fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.MaxDelta = self.Info.Maximum - self.Info.Minimum
		self.CurrentValue = self:Value(self.Info.Default)
		self.CurrentValueSpring = self:Spring(self.CurrentValue, 10, 1)
		self.Position = self:Value(UDim2.fromScale(1.75, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = settings.Slider:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name
		self.Instance.Main.Desc.Text = self.Info.Description
		module.Slider:Create(self.Instance.Main.Slider):BindFunction("Drag", function(p: number, p2: string)
			local dragValue = self.Info.Minimum + self.MaxDelta * p

			if p2 == "Start" then
				if self.CleanTask then
					task.cancel(self.CleanTask)
					self.CleanTask = nil
				end
			elseif p2 == "Stop" then
				if self.CleanTask then
					return
				end

				module.Signal:Fire("General", "Settings", "Set", self.Name, dragValue)
				self.CleanTask = task.delay(1, function()
					if not next(self) then
						return
					end

					self.DragValue = nil
					self:Update()
				end)
			end

			self.DragValue = dragValue
			self:Update()
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Observer(self.CurrentValueSpring):onBind(function()
			local currentValueSpring = self.peek(self.CurrentValueSpring)

			if not currentValueSpring then
				return
			end

			self.Instance.Main.Value.Text = module.Utils.Number:Round(currentValueSpring) .. "%"
			self.Instance.Main.Slider.Bar.Slider.Size = UDim2.fromScale(currentValueSpring / self.Info.Maximum, 1)
			self.Instance.Main.Slider.Point.Position = UDim2.fromScale(currentValueSpring / self.Info.Maximum, 0.5)
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
		local dragValue = self.DragValue or tonumber(module.Data.Settings[self.Name]) or self.Info.Default
		self.CurrentValue:set(dragValue)
	end
})