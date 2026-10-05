local color = Color3.fromRGB(50, 50, 50)
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local NexusInstance = require(script.Parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local ControllerIcon = require(script.Parent:WaitForChild("ControllerIcon"))
local SimpleWrappedInstance = require(script.Parent:WaitForChild("SimpleWrappedInstance"))
local ThemedFrame = require(script.Parent:WaitForChild("ThemedFrame"))
local v = {
	Themes = ThemedFrame.Themes
}
v.__index = v
setmetatable(v, SimpleWrappedInstance)

local function MultiplyColor3(color2: Color3, p: number)
	return Color3.new(math.clamp(color2.R * p, 0, 1), math.clamp(color2.G * p, 0, 1), (math.clamp(color2.B * p, 0, 1)))
end

function v:__new()
	SimpleWrappedInstance.__new(self, Instance.new("TextButton"))
	local wrappedInstance = self:GetWrappedInstance()
	wrappedInstance.BackgroundTransparency = 1
	wrappedInstance.Text = ""
	local borderFrame = ThemedFrame.new()
	borderFrame.Parent = wrappedInstance
	self:DisableChangeReplication("BorderFrame")
	self.BorderFrame = borderFrame
	local backgroundFrame = ThemedFrame.new()
	backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
	backgroundFrame.ZIndex = 2
	backgroundFrame.Parent = wrappedInstance
	self:DisableChangeReplication("BackgroundFrame")
	self.BackgroundFrame = backgroundFrame
	backgroundFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:UpdateBorder(false)
	end)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.ZIndex = 3
	frame.Parent = wrappedInstance
	self:DisableChangeReplication("ContentsAdorn")
	self.ContentsAdorn = frame
	local gamepadIcon = ControllerIcon.new()
	gamepadIcon.BackgroundColor3 = color
	gamepadIcon.Size = UDim2.new(1, 0, 1, 0)
	gamepadIcon.Position = UDim2.new(1, 0, 0, 0)
	gamepadIcon.SizeConstraint = Enum.SizeConstraint.RelativeYY
	gamepadIcon.AnchorPoint = Vector2.new(1, 0)
	gamepadIcon.ZIndex = 4
	gamepadIcon.Parent = wrappedInstance
	self:DisableChangeReplication("GamepadIcon")
	self.GamepadIcon = gamepadIcon
	self:DisableChangeReplication("MouseButton1Down")
	self.MouseButton1Down = self:CreateEvent()
	self:GetWrappedInstance().MouseButton1Down:Connect(function(...)
		self.MouseButton1Down:Fire(...)
	end)
	self:DisableChangeReplication("MouseButton1Up")
	self.MouseButton1Up = self:CreateEvent()
	self:GetWrappedInstance().MouseButton1Up:Connect(function(...)
		self.MouseButton1Up:Fire(...)
	end)
	self:DisableChangeReplication("MouseButton1Click")
	self.MouseButton1Click = self:CreateEvent()
	self:GetWrappedInstance().MouseButton1Click:Connect(function()
		self.MouseButton1Click:Fire()
	end)
	self:DisableChangeReplication("MouseButton2Down")
	self.MouseButton2Down = self:CreateEvent()
	self:GetWrappedInstance().MouseButton2Down:Connect(function(...)
		self.MouseButton2Down:Fire(...)
	end)
	self:DisableChangeReplication("MouseButton2Up")
	self.MouseButton2Up = self:CreateEvent()
	self:GetWrappedInstance().MouseButton2Up:Connect(function(...)
		self.MouseButton2Up:Fire(...)
	end)
	self:DisableChangeReplication("MouseButton2Click")
	self.MouseButton2Click = self:CreateEvent()
	self:GetWrappedInstance().MouseButton2Click:Connect(function()
		self.MouseButton2Click:Fire()
	end)
	self:DisableChangeReplication("TweenDuration")
	self:DisableChangeReplication("BackgroundColor3")
	self:OnPropertyChanged("BackgroundColor3", function()
		self:UpdateBorder(false)
	end)
	self:DisableChangeReplication("BackgroundTransparency")
	self:OnPropertyChanged("BackgroundTransparency", function(backgroundTransparency: number)
		backgroundFrame.BackgroundTransparency = backgroundTransparency
	end)
	self:DisableChangeReplication("BorderSize")
	self:OnPropertyChanged("BorderSize", function()
		self:UpdateBorder(false)
	end)
	self:DisableChangeReplication("BorderSizePixel")
	self:OnPropertyChanged("BorderSizePixel", function(p: number)
		self.BorderSize = UDim.new(0, p)
	end)
	self:DisableChangeReplication("BorderSizeScale")
	self:OnPropertyChanged("BorderSizeScale", function(p: number)
		self.BorderSize = UDim.new(p, 0)
	end)
	self:DisableChangeReplication("BorderColor3")
	self:OnPropertyChanged("BorderColor3", function()
		self:UpdateBorder(false)
	end)
	self:DisableChangeReplication("BorderColor3")
	self:OnPropertyChanged("AutoButtonColor", function()
		self:UpdateBorder(false)
	end)
	self:DisableChangeReplication("BorderTransparency")
	self:OnPropertyChanged("BorderTransparency", function(backgroundTransparency: number)
		borderFrame.BackgroundTransparency = backgroundTransparency
	end)
	self:DisableChangeReplication("Hovering")
	self:OnPropertyChanged("Hovering", function()
		self:UpdateBorder(true)
	end)
	self:DisableChangeReplication("Pressed")
	self:OnPropertyChanged("Pressed", function()
		self:UpdateBorder(true)
	end)
	self:DisableChangeReplication("Theme")
	self:OnPropertyChanged("Theme", function(_: string)
		backgroundFrame.Theme = self.Theme
		borderFrame.Theme = self.Theme
		gamepadIcon.Theme = self.Theme
	end)
	self:DisableChangeReplication("MappedInputs")
	self.MappedInputs = {}
	self:DisableChangeReplication("EventConnections")
	self.EventConnections = {}
	self.MouseEnter:Connect(function()
		self.Hovering = true
	end)
	self.MouseLeave:Connect(function()
		self.Hovering = false
	end)
	self.MouseButton1Down:Connect(function()
		self.Pressed = true
	end)
	self.MouseButton1Up:Connect(function()
		self.Pressed = false
	end)
	table.insert(self.EventConnections, GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
		self:UpdateBorder(true)
	end))
	table.insert(self.EventConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed and (GuiService.SelectedObject ~= self:GetWrappedInstance() or input.KeyCode == Enum.KeyCode.ButtonA) or self.Pressed or not self.MappedInputs[input.KeyCode] then
			return
		end

		local mappedInput = self.MappedInputs[input.KeyCode]
		local v5 = self.AbsolutePosition + self.AbsoluteSize / 2

		if mappedInput == Enum.UserInputType.MouseButton1 then
			self.MouseButton1Down:Fire(v5.X, v5.Y)
		elseif mappedInput == Enum.UserInputType.MouseButton2 then
			self.MouseButton2Down:Fire(v5.X, v5.Y)
		end
	end))
	table.insert(self.EventConnections, UserInputService.InputEnded:Connect(function(input)
		if not (self.Pressed and self.MappedInputs[input.KeyCode]) then
			return
		end

		local mappedInput = self.MappedInputs[input.KeyCode]
		local v5 = self.AbsolutePosition + self.AbsoluteSize / 2

		if mappedInput == Enum.UserInputType.MouseButton1 then
			self.MouseButton1Up:Fire(v5.X, v5.Y)
			self.MouseButton1Click:Fire()
		elseif mappedInput == Enum.UserInputType.MouseButton2 then
			self.MouseButton2Up:Fire(v5.X, v5.Y)
			self.MouseButton2Click:Fire()
		end
	end))
	table.insert(self.EventConnections, UserInputService.InputEnded:Connect(function(input)
		if not (self.Pressed and input.UserInputType == Enum.UserInputType.MouseButton1) then
			return
		end

		self.Pressed = false
	end))
	self.Size = UDim2.new(0, 200, 0, 50)
	self.BackgroundColor3 = Color3.fromRGB(204, 204, 204)
	self.BackgroundTransparency = 0
	self.BorderSize = UDim.new(0.15, 0)
	self.BorderColor3 = Color3.fromRGB(0, 0, 0)
	self.BorderTransparency = 0
	self.AutoButtonColor = true
	self.Hovering = false
	self.Pressed = false
	self.TweenDuration = 0.1
	self.Theme = "CutCorners"
end

function v:UpdateBorder(flag: boolean?)
	if not (self.BorderSize and self.Theme) then
		return
	end

	local absoluteSize = self.BackgroundFrame.AbsoluteSize
	local v2 = absoluteSize.Y * self.BorderSize.Scale + self.BorderSize.Offset
	local backgroundColor3 = self.BackgroundColor3
	local borderColor3 = self.BorderColor3

	if self.AutoButtonColor ~= false then
		if self.Pressed then
			backgroundColor3 = Color3.new(
				math.clamp(backgroundColor3.R * 1.4285714285714286, 0, 1),
				math.clamp(backgroundColor3.G * 1.4285714285714286, 0, 1),
				(math.clamp(backgroundColor3.B * 1.4285714285714286, 0, 1))
			)
			borderColor3 = Color3.new(
				math.clamp(borderColor3.R * 1.4285714285714286, 0, 1),
				math.clamp(borderColor3.G * 1.4285714285714286, 0, 1),
				(math.clamp(borderColor3.B * 1.4285714285714286, 0, 1))
			)
			v2 *= 0.25
		elseif self.Hovering or GuiService.SelectedObject == self:GetWrappedInstance() then
			backgroundColor3 = Color3.new(
				math.clamp(backgroundColor3.R * 0.7, 0, 1),
				math.clamp(backgroundColor3.G * 0.7, 0, 1),
				(math.clamp(backgroundColor3.B * 0.7, 0, 1))
			)
			borderColor3 = Color3.new(
				math.clamp(borderColor3.R * 0.7, 0, 1),
				math.clamp(borderColor3.G * 0.7, 0, 1),
				(math.clamp(borderColor3.B * 0.7, 0, 1))
			)
			v2 *= 0.75
		end
	end

	if flag and self.TweenDuration and self.TweenDuration > 0 then
		TweenService:Create(self.BackgroundFrame:GetWrappedInstance(), TweenInfo.new(self.TweenDuration), {
			ImageColor3 = backgroundColor3
		}):Play()
		TweenService:Create(self.BorderFrame:GetWrappedInstance(), TweenInfo.new(self.TweenDuration), {
			ImageColor3 = borderColor3,
			Size = UDim2.new(1, 0, 1, v2)
		}):Play()
	else
		self.BackgroundFrame.ImageColor3 = backgroundColor3
		self.BorderFrame.ImageColor3 = borderColor3
		self.BorderFrame.Size = UDim2.new(1, 0, 1, v2)
	end

	self.GamepadIcon.SubTheme = absoluteSize.X / absoluteSize.Y < 1.2 and "MainButton" or "GamepadIconBackground"
end

function v.GetAdornFrame(p)
	return p.ContentsAdorn
end

function v.SetControllerIcon(p, p2)
	p.GamepadIcon:SetIcon(p2)
end

function v.MapKey(p, value, value2)
	if typeof(value) == "string" then
		value = Enum.KeyCode[value]
	end

	if typeof(value2) == "string" then
		value2 = Enum.UserInputType[value2]
	end

	if value2 ~= Enum.UserInputType.MouseButton1 and value2 ~= Enum.UserInputType.MouseButton2 then
		error("Mouse input must be either MouseButton1 or MouseButton2.")
	end

	p.MappedInputs[value] = value2
end

function v.UnmapKey(p, value)
	if typeof(value) == "string" then
		value = Enum.KeyCode[value]
	end

	p.MappedInputs[value] = nil
end

function v:Destroy()
	SimpleWrappedInstance.Destroy(self)
	self.GamepadIcon:Destroy()

	for _, eventConnection in self.EventConnections do
		eventConnection:Disconnect()
	end

	self.EventConnections = {}
end

return (NexusInstance.ToInstance(v))