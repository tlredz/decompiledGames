local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local Drag = require(script.Drag)
local Color = {}
Color.__index = Color

function toPolar(data)
	return math.atan2(data.y, data.x), data.Magnitude
end

function radToDeg(p)
	return (p + 3.141592653589793) / 6.283185307179586 * 360
end

function template(p, items)
	local result = (not p or typeof(p) ~= "table" or not p) and {} or p

	for k, item in pairs(items) do
		if result[k] == nil then
			result[k] = item
		end
	end

	return result
end

function rotateVector(p, p2)
	local v = math.rad(p2)
	local X = p.X
	local Y = p.Y
	return Vector2.new(X * math.cos(v) - Y * math.sin(v), X * math.sin(v) + Y * math.cos(v))
end

function roundToHundredths(p)
	return math.ceil(p * 100) / 100
end

function Color:Create(_: number, p2: number)
	local v = (self - 1) / 2
	local v2 = self / 2
	local AssetService = game:GetService("AssetService")
	local editableImage = AssetService:CreateEditableImage({
		Size = Vector2.new(self, self)
	})
	local buf = buffer.create(self * self * 4)

	for i = 0, self - 1 do
		for i2 = 0, self - 1 do
			local v3 = i2 - v
			local v4 = i - v
			local v5 = math.sqrt(v3 * v3 + v4 * v4)
			local v6 = (i * self + i2) * 4

			if v5 <= v2 then
				local v7 = (math.atan2(-v4, v3) + 3.141592653589793) / 6.283185307179586
				local v8 = math.clamp(v5 / v2, 0, 1)
				local color = Color3.fromHSV(v7, v8, p2)
				buffer.writeu8(buf, v6, (math.floor(color.R * 255 + 0.5)))
				buffer.writeu8(buf, v6 + 1, (math.floor(color.G * 255 + 0.5)))
				buffer.writeu8(buf, v6 + 2, (math.floor(color.B * 255 + 0.5)))
				buffer.writeu8(buf, v6 + 3, 255)
			else
				buffer.writeu8(buf, v6, 0)
				buffer.writeu8(buf, v6 + 1, 0)
				buffer.writeu8(buf, v6 + 2, 0)
				buffer.writeu8(buf, v6 + 3, 0)
			end
		end
	end

	editableImage:WritePixelsBuffer(Vector2.zero, Vector2.new(self, self), buf)
	return editableImage
end

function Color.ColorAt(p: number, p2: number, p3: number, value: number?)
	local v = math.sqrt(p * p + p2 * p2)
	local v2 = (math.atan2(p2, -p) + 3.141592653589793) / 6.283185307179586
	local v3 = math.clamp(v / p3, 0, 1)
	return Color3.fromHSV(v2, v3, value or 1)
end

function Color.New(gui, mouse, p3)
	local params = template(p3, {
		Position = UDim2.fromOffset(mouse.X + 16, mouse.Y + 16),
		Draggable = true,
		RoundedCorners = true,
		PrimaryColor = Color3.fromRGB(26, 26, 36),
		SecondaryColor = Color3.fromRGB(36, 36, 46),
		TopbarColor = Color3.fromRGB(21, 21, 31),
		TextColor = Color3.fromRGB(255, 255, 255)
	})
	local object = setmetatable({
		Gui = gui,
		Mouse = mouse,
		Color = Color3.fromRGB(255, 255, 255),
		Params = params
	}, Color)
	object:Create()
	object._wheelDownFunc = nil
	object._wheelUpFunc_uis = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function _resetWheelFunc()
		if object._wheelDownFunc then
			object._wheelDownFunc:Disconnect()
			object._wheelDownFunc = nil
		end

		if object._wheelUpFunc_uis then
			object._wheelUpFunc_uis:Disconnect()
			object._wheelUpFunc_uis = nil
		end
	end

	object.Instance.Wheel.Button.MouseButton1Down:Connect(function()
		object.Instance.Parent.Topbar.Button.Visible = false
		_resetWheelFunc() -- equivalent call inferred; original call site unknown
		object._wheelDownFunc = RunService.Heartbeat:Connect(function()
			local mouseToWheelPos = object:GetMouseToWheelPos()
			object.Instance.Wheel.Image.Select.Position = UDim2.fromOffset(mouseToWheelPos.X, mouseToWheelPos.Y)
			object:SetColorFromPos(mouseToWheelPos)
		end)
		object._wheelUpFunc_uis = UserInputService.InputEnded:Connect(function(input, _)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				_resetWheelFunc() -- equivalent call inferred; original call site unknown
			end
		end)
	end)
	object.Instance.Wheel.Button.MouseButton1Up:Connect(function()
		object.Instance.Parent.Topbar.Button.Visible = true
		_resetWheelFunc() -- equivalent call inferred; original call site unknown
	end)
	object._valueDownFunc = nil
	object._valueUpFunc_uis = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function _resetValueFunc()
		if object._valueDownFunc then
			object._valueDownFunc:Disconnect()
			object._valueDownFunc = nil
		end

		if object._valueUpFunc_uis then
			object._valueUpFunc_uis:Disconnect()
			object._valueUpFunc_uis = nil
		end
	end

	object.Instance.Right.Value.Button.MouseButton1Down:Connect(function()
		object.Instance.Parent.Topbar.Button.Visible = false
		_resetValueFunc() -- equivalent call inferred; original call site unknown
		object._valueDownFunc = RunService.Heartbeat:Connect(function()
			local mouseToValuePos = object:GetMouseToValuePos()
			object.Instance.Right.Value.Select.Position = UDim2.new(0, 0, mouseToValuePos, 0)
			local HSV, v2, _ = object.Color:ToHSV()
			object.Color = Color3.fromHSV(object.CurrentHue or HSV, object.CurrentSaturation or v2, 1 - mouseToValuePos)
			object:UpdateColor()
		end)
		object._valueUpFunc_uis = UserInputService.InputEnded:Connect(function(input, _)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				_resetValueFunc() -- equivalent call inferred; original call site unknown
			end
		end)
	end)
	object.Instance.Right.Value.Button.MouseButton1Up:Connect(function()
		object.Instance.Parent.Topbar.Button.Visible = true
		_resetValueFunc() -- equivalent call inferred; original call site unknown
	end)
	object:UpdateColor()
	object.Instance.Bottom.Buttons.Confirm.MouseButton1Down:Connect(function()
		object.Instance.Parent.FinishedEvent:Fire(object.Color)
		object:Destroy()
	end)
	object.Instance.Bottom.Buttons.Cancel.MouseButton1Down:Connect(function()
		object.Instance.Parent.CanceledEvent:Fire()
		object:Destroy()
	end)

	for _, frame in pairs(object.Instance.Parent.Properties.RGB:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local v2 = frame
		frame.Frame.TextBox.FocusLost:Connect(function()
			if not tonumber(v2.Frame.TextBox.Text) then
				v2.Frame.TextBox.Text = "0"
			end

			local text = tonumber(object.Instance.Parent.Properties.RGB.R.Frame.TextBox.Text) or 0
			local text2 = tonumber(object.Instance.Parent.Properties.RGB.G.Frame.TextBox.Text) or 0
			local text3 = tonumber(object.Instance.Parent.Properties.RGB.B.Frame.TextBox.Text) or 0
			local v3 = math.clamp(text, 0, 255)
			local v4 = math.clamp(text2, 0, 255)
			local v5 = math.clamp(text3, 0, 255)
			object:SetColor(Color3.fromRGB(v3, v4, v5))
		end)
	end

	for _, frame in pairs(object.Instance.Parent.Properties.HSV:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local v2 = frame
		frame.Frame.TextBox.FocusLost:Connect(function()
			if not tonumber(v2.Frame.TextBox.Text) then
				v2.Frame.TextBox.Text = "0"
			end

			local text = tonumber(object.Instance.Parent.Properties.HSV.H.Frame.TextBox.Text) or 0
			local text2 = tonumber(object.Instance.Parent.Properties.HSV.S.Frame.TextBox.Text) or 0
			local text3 = tonumber(object.Instance.Parent.Properties.HSV.V.Frame.TextBox.Text) or 0
			local v3 = math.clamp(text, 0, 360)
			local v4 = math.clamp(text2, 0, 1)
			local v5 = math.clamp(text3, 0, 1)
			object:SetColor(Color3.fromHSV(v3 / 360, v4, v5))
		end)
	end

	object.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.FocusLost:Connect(function()
		local text = object.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.Text
		local success, _ = pcall(function()
			text = Color3.fromHex(text)
		end)

		if not success then
			text = Color3.fromRGB(255, 255, 255)
		end

		object.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.Text = text:ToHex()
		object:SetColor(text)
	end)
	return object
end

function Color:Create()
	local clone = script.ColorWindow:Clone()
	clone.Position = self.Params.Position
	clone.Parent = self.Gui
	clone.Visible = true
	self.Instance = clone.Content

	for _, descendant in pairs(clone:GetDescendants()) do
		if not self.Params.RoundedCorners and descendant:IsA("UICorner") and descendant.Parent.Name ~= "Select" then
			descendant:Destroy()
		end

		if not (descendant:IsA("TextLabel") or descendant:IsA("TextBox") or descendant:IsA("ImageButton")) then
			continue
		end

		descendant[(descendant:IsA("TextLabel") or descendant:IsA("TextBox")) and "TextColor3" or "ImageColor3"] = self.Params.TextColor
	end

	clone.BackgroundColor3 = self.Params.PrimaryColor
	clone.Properties.BackgroundColor3 = self.Params.PrimaryColor
	clone.Properties.Line.BackgroundColor3 = self.Params.SecondaryColor
	clone.Content.Bottom.Hex.Frame.BackgroundColor3 = self.Params.SecondaryColor

	for _, v in pairs({ clone.Properties.HSV, clone.Properties.RGB }) do
		for _, frame in pairs(v:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Frame.BackgroundColor3 = self.Params.SecondaryColor
			end
		end
	end

	clone.Topbar.BackgroundColor3 = self.Params.TopbarColor
	clone.Topbar.Frame.BackgroundColor3 = self.Params.TopbarColor
	self.Finished = clone.FinishedEvent.Event
	self.Canceled = clone.CanceledEvent.Event
	self.Updated = clone.UpdateEvent.Event

	if self.Params.Draggable and not UserInputService.TouchEnabled then
		self.Drag = Drag.New(self.Instance.Parent)
		local button = self.Instance.Parent.Topbar.Button
		button.MouseButton1Down:Connect(function()
			self.Drag:Start()
		end)
		button.MouseButton1Up:Connect(function()
			self.Drag:Stop()
		end)
		self._dragStopFunc = UserInputService.InputEnded:Connect(function(input, _)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and self.Drag.Active then
				self.Drag:Stop()
			end
		end)
	end
end

function Color:Destroy()
	if self.Instance and self.Instance.Parent then
		self.Instance.Parent:Destroy()
	end

	if self._dragStopFunc then
		self._dragStopFunc:Disconnect()
		self._dragStopFunc = nil
	end

	if self._valueDownFunc then
		self._valueDownFunc:Disconnect()
		self._valueDownFunc = nil
	end

	if self._valueUpFunc_uis then
		self._valueUpFunc_uis:Disconnect()
		self._valueUpFunc_uis = nil
	end
end

function Color:GetMouseToWheelPos()
	local vector = Vector2.new(self.Mouse.X, self.Mouse.Y)
	local absolutePosition = self.Instance.Wheel.Image.AbsolutePosition
	local absoluteSize = self.Instance.Wheel.Image.AbsoluteSize
	local v = vector - absolutePosition
	local v2 = absolutePosition + absoluteSize / 2
	local v3 = absoluteSize.X / 2
	local v4 = v2 - vector

	if v3 < v4.Magnitude then
		return absoluteSize / 2 - v4.Unit * v3
	end

	return v
end

function Color:GetMouseToValuePos()
	local vector = Vector2.new(self.Mouse.X, self.Mouse.Y)
	local absolutePosition = self.Instance.Right.Value.AbsolutePosition
	local absoluteSize = self.Instance.Right.Value.AbsoluteSize
	return (math.clamp((vector.Y - absolutePosition.Y) / absoluteSize.Y, 0, 1))
end

function Color:UpdateColor()
	self.Instance.Parent.UpdateEvent:Fire(self.Color)
	self.Instance.Bottom.Color.Frame.BackgroundColor3 = self.Color
	self.Instance.Parent.Properties.RGB.R.Frame.TextBox.Text = math.floor(self.Color.R * 255 + 0.5)
	self.Instance.Parent.Properties.RGB.G.Frame.TextBox.Text = math.floor(self.Color.G * 255 + 0.5)
	self.Instance.Parent.Properties.RGB.B.Frame.TextBox.Text = math.floor(self.Color.B * 255 + 0.5)
	local HSV, v, v2 = self.Color:ToHSV()
	self.Instance.Parent.Properties.HSV.H.Frame.TextBox.Text = math.floor(HSV * 360 + 0.5)
	self.Instance.Parent.Properties.HSV.S.Frame.TextBox.Text = roundToHundredths(v)
	self.Instance.Parent.Properties.HSV.V.Frame.TextBox.Text = roundToHundredths(v2)
	local hex = self.Color:ToHex()
	self.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.Text = string.format("#%s", string.lower(hex))
end

function Color:SetColorFromPos(point: Vector2)
	local absoluteSize = self.Instance.Wheel.Image.AbsoluteSize
	local v = absoluteSize / 2 - point
	local v2 = absoluteSize.X / 2
	math.min(v.Magnitude, v2)
	local v3, v4 = toPolar(v * Vector2.new(-1, 1))
	local v5 = radToDeg(v3) / 360
	local v6 = v4 / v2
	local v7 = math.clamp(v5, 0, 1)
	local v8 = math.clamp(v6, 0, 1)
	local _, _, v9 = self.Color:ToHSV()
	self.Color = Color3.fromHSV(v7, v8, v9)
	self:UpdateColor()
	self:SetValueGradient(v7, v8)
end

function Color:SetValueGradient(currentHue: number, currentSaturation: number)
	self.CurrentSaturation = currentSaturation
	self.CurrentHue = currentHue
	local color = Color3.fromHSV(currentHue, currentSaturation, 1)
	self.Instance.Right.Value.UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	})
end

function Color:SetColor(color: Color3)
	local HSV, v, v2 = color:ToHSV()
	self.Color = color
	local absoluteSize = self.Instance.Wheel.Image.AbsoluteSize
	local _ = absoluteSize / 2
	local _ = absoluteSize.X / 2
	local vector = Vector2.new(0.5, 0.5)
	local vector2 = Vector2.new(-1, 0)
	local v3 = rotateVector(vector2, HSV * -360)
	local v4 = vector - rotateVector(v3, 180) * v * 0.5
	self.Instance.Wheel.Image.Select.Position = UDim2.fromScale(v4.X, v4.Y)
	self.Instance.Right.Value.Select.Position = UDim2.new(0, 0, 1 - v2, 0)
	self:UpdateColor()
	self:SetValueGradient(HSV, v)
end

return Color