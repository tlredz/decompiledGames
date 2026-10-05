require(script.Parent.Parent.Types)

local function numberStr(p: number)
	return (tostring(math.floor(p * 100) / 100))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function absolutePoint(p, scale: number, scale2: number)
	return Vector2.new(
		p.AbsolutePosition.X + p.AbsoluteSize.X * scale,
		p.AbsolutePosition.Y + p.AbsoluteSize.Y * scale2
	)
end

return function(_, p)
	local extended = p.extend("SequenceEditor", "SequenceEditor")

	function extended:Init()
		self.Value = NumberSequence.new(0, 1)
		self.SelectedIndex = 1
		self.HoveringIndex = -1
		self.Min = 0
		self.Max = 1

		function self.Callback() end

		self.MousePos = Vector2.new(0, 0)
		self.MouseInUI = false
		self.HoldingMouse = false
		self:UpdateCurve()
		self.UI.Content.Top.ButtonCtn.Refresh.MouseButton1Click:Connect(function()
			self:UpdateCurve()
		end)
		local ctn = self.UI.Content.Bottom.Ctn
		ctn.Max.TextBox.Text = tostring(self.Max)
		ctn.Min.TextBox.Text = tostring(self.Min)
		ctn.Time.TextBox.Text = "0"
		ctn.Value.TextBox.Text = "0"
		ctn.Max.TextBox.FocusLost:Connect(function(p2)
			if not p2 then
				ctn.Max.TextBox.Text = tostring(self.Max)
				return
			end

			self.Max = tonumber(ctn.Max.TextBox.Text) or 0
			self:UpdateCurve()
		end)
		ctn.Min.TextBox.FocusLost:Connect(function(p2)
			if not p2 then
				ctn.Min.TextBox.Text = tostring(self.Min)
				return
			end

			self.Min = tonumber(ctn.Min.TextBox.Text) or 0
			self:UpdateCurve()
		end)
		ctn.Time.TextBox.FocusLost:Connect(function(p2)
			local keypoint = self.Value.Keypoints[self.SelectedIndex]
			local v = self.SelectedIndex == 1 or self.SelectedIndex == #self.Value.Keypoints
			local v2 = math.clamp(tonumber(ctn.Time.TextBox.Text) or 0, 0.001, 0.999)

			if v or not p2 then
				ctn.Time.TextBox.Text = tostring(math.floor(keypoint.Time * 100) / 100)
			else
				self:ReplaceSelected(NumberSequenceKeypoint.new(v2, keypoint.Value))
			end
		end)
		ctn.Value.TextBox.FocusLost:Connect(function(p2)
			local keypoint = self.Value.Keypoints[self.SelectedIndex]
			local text = tonumber(ctn.Value.TextBox.Text) or 0

			if p2 then
				self:ReplaceSelected(NumberSequenceKeypoint.new(keypoint.Time, text))
			else
				ctn.Value.TextBox.Text = tostring(math.floor(keypoint.Value * 100) / 100)
			end
		end)
		ctn.RemoveBtn.Btn.MouseButton1Click:Connect(function()
			if self.SelectedIndex <= 1 or self.SelectedIndex >= #self.Value.Keypoints then
				return
			end

			local keypoints = {}

			for k, keypoint in self.Value.Keypoints do
				if k ~= self.SelectedIndex then
					table.insert(keypoints, keypoint)
				end
			end

			self.Value = NumberSequence.new(keypoints)
			self:UpdateCurve()
			self:SelectPoint(1)
			self.HoveringIndex = -1
		end)
		local mouseInteraction = self.UI.Content.Mid.MouseInteraction
		mouseInteraction.MouseMoved:Connect(function(p2, p3)
			self.MousePos = Vector2.new(p2, p3)
			self:Update()
		end)
		mouseInteraction.MouseButton1Down:Connect(function()
			self.HoldingMouse = true
			self:Update()
		end)
		mouseInteraction.MouseButton1Up:Connect(function()
			self.HoldingMouse = false
			self:Update()
		end)
		mouseInteraction.MouseEnter:Connect(function()
			self.MouseInUI = true
			self:Update()
		end)
		mouseInteraction.MouseLeave:Connect(function()
			self.MouseInUI = false
			self.HoldingMouse = false
			self:Update()
		end)
	end

	function extended:ReplaceSelected(p2)
		local keypoints = {}

		for k, keypoint in self.Value.Keypoints do
			if k == self.SelectedIndex then
				keypoint = p2
			end

			table.insert(keypoints, keypoint)
		end

		table.sort(keypoints, function(a, b)
			return a.Time < b.Time
		end)
		self:SetValue(NumberSequence.new(keypoints))
		local index = table.find(keypoints, p2) or self.SelectedIndex
		self.HoveringIndex = index
		self:SelectPoint(index)
	end

	function extended:UpdateCurve()
		local sequenceContainer = self.OriginalUI.Content.Mid.InnerContent.SequenceContainer
		local sequenceContainer2 = self.UI.Content.Mid.InnerContent.SequenceContainer
		sequenceContainer2.ControlPoints:ClearAllChildren()
		sequenceContainer2.Curve:ClearAllChildren()
		local keypoints = self.Value.Keypoints
		local v = math.max(self.Max - self.Min, 0.0001)
		local v2 = false

		for k, keypoint in keypoints do
			local keypoint2 = keypoints[k + 1]
			local uDim = UDim2.new(keypoint.Time, 0, 1 - (keypoint.Value - self.Min) / v, 0)
			local clone = sequenceContainer.ControlPoints.Start:Clone()
			clone.Position = uDim
			clone.ZIndex = sequenceContainer2.ZIndex + 10
			clone.Name = tostring(k)
			clone.Parent = sequenceContainer2.ControlPoints
			local v3 = self.SelectedIndex == k
			local backgroundColor

			if v3 then
				backgroundColor = Color3.fromRGB(255, 115, 115)
			else
				backgroundColor = Color3.fromRGB(255, 255, 255)
			end

			clone.BackgroundColor3 = backgroundColor
			v2 = v2 or v3

			if not keypoint2 then
				continue
			end

			local uDim2 = UDim2.new(keypoint2.Time, 0, 1 - (keypoint2.Value - self.Min) / v, 0)
			local uDim3 = UDim2.fromScale((uDim.X.Scale + uDim2.X.Scale) / 2, (uDim.Y.Scale + uDim2.Y.Scale) / 2)
			local v5 = absolutePoint(sequenceContainer2, uDim.X.Scale, uDim.Y.Scale) -- equivalent call inferred; original call site unknown
			local v6 = absolutePoint(sequenceContainer2, uDim2.X.Scale, uDim2.Y.Scale) -- equivalent call inferred; original call site unknown
			local v7 = math.atan2(v6.Y - v5.Y, v6.X - v5.X)
			local clone2 = sequenceContainer.Curve.LineExample:Clone()
			clone2.Position = uDim3
			clone2.Rotation = math.deg(v7)
			clone2.Size = UDim2.fromOffset((v5 - v6).Magnitude, 1)
			clone2.ZIndex = sequenceContainer2.ZIndex + 7
			clone2.Parent = sequenceContainer2.Curve
		end

		local keypoint = keypoints[self.SelectedIndex]

		if keypoint then
			local ctn = self.UI.Content.Bottom.Ctn
			ctn.Time.TextBox.Text = tostring(math.floor(keypoint.Time * 100) / 100)
			ctn.Value.TextBox.Text = tostring(math.floor(keypoint.Value * 100) / 100)
		end

		if not v2 then
			self:SelectPoint(1)
		end
	end

	function extended:Update()
		local sequenceContainer = self.UI.Content.Mid.InnerContent.SequenceContainer

		if self.HoldingMouse then
			local v = self.MousePos - sequenceContainer.AbsolutePosition
			local v2 = v.X / sequenceContainer.AbsoluteSize.X
			local v3 = 1 - v.Y / sequenceContainer.AbsoluteSize.Y
			local v4 = math.clamp(self.Min + (self.Max - self.Min) * v3, self.Min, self.Max)

			if self.HoveringIndex == -1 then
				local clone = table.clone(self.Value.Keypoints)
				local numberSequenceKeypoint = NumberSequenceKeypoint.new(v2, v4)
				table.insert(clone, numberSequenceKeypoint)
				table.sort(clone, function(a, b)
					return a.Time < b.Time
				end)
				local index = table.find(clone, numberSequenceKeypoint) or 1
				self:SetValue(NumberSequence.new(clone))
				self.HoveringIndex = index
				self:SelectPoint(index)
			else
				local v5 = self.HoveringIndex == 1 and 0 or self.HoveringIndex == #self.Value.Keypoints and 1 or v2
				self:ReplaceSelected(NumberSequenceKeypoint.new(v5, v4))
			end
		else
			self.HoveringIndex = -1

			for _, frame in sequenceContainer.ControlPoints:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				local name = tonumber(frame.Name) or 1
				local v = absolutePoint(frame, 0.5, 0.5) -- equivalent call inferred; original call site unknown

				if not ((self.MousePos - v).Magnitude < 10) then
					continue
				end

				self.HoveringIndex = name
				self:SelectPoint(name)
			end
		end
	end

	function extended:SelectPoint(selectedIndex: number)
		if self.SelectedIndex == selectedIndex then
			return
		end

		self.SelectedIndex = selectedIndex

		for _, frame in self.UI.Content.Mid.InnerContent.SequenceContainer.ControlPoints:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			local backgroundColor

			if tonumber(frame.Name) == selectedIndex then
				backgroundColor = Color3.fromRGB(255, 115, 115)
			else
				backgroundColor = Color3.fromRGB(255, 255, 255)
			end

			frame.BackgroundColor3 = backgroundColor
		end

		self:UpdateCurve()
	end

	function extended:SetValue(p2)
		self.Value = p2
		self:UpdateCurve()
		self.Callback(self.Value)
		return self
	end

	function extended:SetMin(min: number)
		self.Min = min
		self:UpdateCurve()
		self.UI.Content.Bottom.Ctn.Min.TextBox.Text = tostring(self.Min)
		return self
	end

	function extended:SetMax(max: number)
		self.Max = max
		self:UpdateCurve()
		self.UI.Content.Bottom.Ctn.Max.TextBox.Text = tostring(self.Max)
		return self
	end

	function extended.SetSizeY(object, p2: number)
		object.UI.Size = UDim2.new(1, 0, 0, p2)
		object:UpdateHeight()
		object:UpdateParentHeight()
		return object
	end

	function extended.SetTitle(p2, text: string)
		p2.UI.Content.Top.TextLabel.Text = text
		return p2
	end

	function extended:SetOnChanged(callback)
		self.Callback = callback
		return self
	end

	return extended
end