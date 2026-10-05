require(script.Parent.Parent.Types)
return function(_, p)
	local extended = p.extend("BigDropdown", "BigDropdown")

	function extended:Init()
		self.Choices = {}
		self.Selected = nil

		function self.Callback() end

		self.UI.Top.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			self:UpdateFilter()
		end)
		self.UI.Top.TextBox.Focused:Connect(function()
			self.UI.Top.TextBox.CursorPosition = #self.UI.Top.TextBox.Text + 1
			self.UI.Top.TextBox.SelectionStart = 1
		end)
	end

	function extended:UpdateFilter()
		local text = string.lower(self.UI.Top.TextBox.Text)
		local scrollingFrame = self.UI.ScrollingFrame
		local total = 0

		for _, button in scrollingFrame:GetChildren() do
			if not button:IsA("TextButton") then
				continue
			end

			button.Visible = text == "" or string.find(string.lower(button.Name), text, 1, true) ~= nil

			if button.Visible then
				total += button.AbsoluteSize.Y
			end
		end

		scrollingFrame.CanvasSize = UDim2.fromOffset(0, total)
		self:UpdateHeight()
		self:UpdateParentHeight()
	end

	function extended:UpdateChoices()
		local exampleButton = self.OriginalUI.ScrollingFrame.ExampleButton
		local scrollingFrame = self.UI.ScrollingFrame

		for _, button in scrollingFrame:GetChildren() do
			if not button:IsA("TextButton") or table.find(self.Choices, button.Name) then
				continue
			end

			button:Destroy()
		end

		for _, childName in self.Choices do
			if scrollingFrame:FindFirstChild(childName) then
				continue
			end

			local clone = exampleButton:Clone()
			clone.Name = childName
			clone.TextLabel.Text = childName
			clone.ZIndex = scrollingFrame.ZIndex + 1
			clone.TextLabel.ZIndex = scrollingFrame.ZIndex + 2
			clone.Parent = scrollingFrame
			local v = childName
			clone.MouseButton1Click:Connect(function()
				self:SetSelected(v)
			end)
		end

		local buttons = {}

		for _, button in scrollingFrame:GetChildren() do
			if button:IsA("TextButton") then
				table.insert(buttons, button)
			end
		end

		table.sort(buttons, function(a, b)
			return a.Name < b.Name
		end)

		for k, v in buttons do
			v.LayoutOrder = k
		end

		self:UpdateFilter()
		self:UpdateSelected()
	end

	function extended:UpdateSelected()
		for _, button in self.UI.ScrollingFrame:GetChildren() do
			if not button:IsA("TextButton") then
				continue
			end

			local v = button.Name == self.Selected
			button.BorderSizePixel = v and 1 or 0
			local backgroundColor

			if v then
				backgroundColor = Color3.fromRGB(43, 69, 99)
			else
				backgroundColor = Color3.fromRGB(61, 61, 61)
			end

			button.BackgroundColor3 = backgroundColor
		end
	end

	function extended:SetChoiceList(choices)
		self.Choices = choices
		self:UpdateChoices()
		return self
	end

	function extended.SetSizeY(object, p2: number)
		object.UI.Size = UDim2.new(1, 0, 0, p2)
		object:UpdateHeight()
		object:UpdateParentHeight()
		return object
	end

	function extended:SetSelected(selected: string?)
		if selected and not table.find(self.Choices, selected) then
			selected = nil
		end

		if self.Selected == selected then
			return self
		end

		self.Selected = selected
		self.Callback(selected)
		self:UpdateSelected()
		return self
	end

	function extended:SetOnChanged(callback)
		self.Callback = callback
		return self
	end

	function extended.GetSelected(p2)
		return p2.Selected
	end

	return extended
end