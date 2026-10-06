local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local Keybinds = require(script.Parent.Parent.HUD.Keybinds)
local scroll = module.Interface:WaitForChild("Frames"):WaitForChild("Settings"):WaitForChild("SettingsList"):WaitForChild("Scroll")
local settings = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Settings")
return fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(1.75, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = settings.Keybind:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Info.DisplayName
		local keybind = self.Instance.Main.Keybind
		local textButton = Instance.new("TextButton")
		textButton.Name = "Capture"
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.BackgroundTransparency = 1
		textButton.BorderSizePixel = 0
		textButton.Text = ""
		textButton.AutoButtonColor = false
		textButton.Selectable = true
		textButton.ZIndex = math.max(keybind.Texture.ZIndex, keybind.Main.Title.ZIndex) + 1
		textButton.Parent = keybind
		table.insert(self, textButton.Activated:Connect(function()
			Keybinds.Activate(self.Name)
		end))
		local name = self.Name
		table.insert(self, function()
			Keybinds.Cancel(name)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

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
		local status = Keybinds.GetStatus(self.Name)
		local value = module.Shared.Keybinds.GetValue(module.Data.Settings, self.Name)
		self.Instance.Main.Keybind.Main.Title.Text = status and (status.Listening or status.Pending) and "..." or Keybinds.GetLabel(value)
		local desc = self.Instance.Main.Desc
		local text

		if status then
			text = status.Message
		else
			text = self.Info.Description
		end

		desc.Text = text
	end
})