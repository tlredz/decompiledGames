require(script.Parent.Parent.Types)
local v = nil
return function(_, p)
	local extended = p.extend("Dropdown", "Dropdown")

	function extended:Init()
		function self.OnChanged() end

		self.Choices = {}
		self.CurChoice = "Choice 1"
		self.IsOpen = false
		self.ActiveChoiceInput = nil
		self.UI.Right.DropdownCtn.TextBox.Focused:Connect(function()
			if not self:GetEnabled() then
				self.UI.Right.DropdownCtn.TextBox:ReleaseFocus(false)
				return
			end

			task.wait()
			task.wait()
			self:UpdateFilter()
			self:SetIsOpen(not self.IsOpen)
		end)
		self.UI.Right.DropdownCtn.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if self.IsOpen then
				local text = self.UI.Right.DropdownCtn.TextBox.Text

				if text ~= "" then
					self:UpdateFilter(text)
				end
			end
		end)
		self.UI.Right.DropdownCtn.TextBox.FocusLost:Connect(function(p2)
			if self:IsDestroyed() then
				return
			end

			task.wait()

			if self.ActiveChoiceInput then
				return
			end

			self:SetIsOpen(false)

			if p2 then
				local firstVisibleChoice = self:GetFirstVisibleChoice()

				if firstVisibleChoice then
					self:SetSelected(firstVisibleChoice)
					self.OnChanged(firstVisibleChoice)
				end
			else
				self:SetSelected(self.CurChoice, true)
			end

			self:UpdateFilter()
		end)
		self:SetIsOpen(false)
	end

	function extended.SetText(p2, text: string)
		p2.UI.Left.Title.Text = text
		return p2
	end

	function extended.SetTextVisible(p2, visible: boolean)
		p2.UI.Left.Visible = visible
		local right = p2.UI.Right
		local size

		if visible then
			size = UDim2.new(0.5, -1, 1, 0)
		else
			size = UDim2.fromScale(1, 1)
		end

		right.Size = size
		return p2
	end

	function extended:SetChoiceList(choices)
		self.Choices = choices
		self:UpdateChoices()
		return self
	end

	function extended:SetSelectedToFirst()
		self:SetSelected(self.Choices[1] or "<NONE>", true)
		return self
	end

	function extended:SetSelected(p2: string, flag: boolean?)
		if self:IsDestroyed() then
			return self
		end

		if flag or table.find(self.Choices, p2) then
			self.CurChoice = p2
			self.UI.Right.DropdownCtn.TextBox.Text = p2
		end

		return self
	end

	function extended.GetValue(p2)
		return p2.CurChoice
	end

	function extended:SetOnChanged(onChanged)
		self.OnChanged = onChanged
		return self
	end

	function extended:SetIsOpen(isOpen: boolean)
		if not self:GetEnabled() then
			isOpen = false
		end

		if v and v ~= self then
			v:SetIsOpen(false)
		end

		self.IsOpen = isOpen
		self:UpdateDisplay()

		if isOpen then
			v = self
			return self
		end

		if v == self then
			v = nil
		end

		return self
	end

	function extended:UpdateFilter(value: string?)
		if self:IsDestroyed() then
			return
		end

		local v2 = value and string.lower(value)

		for _, frame in self.UI.Right.DropdownCtn.Content.InnerContent:GetChildren() do
			if frame:IsA("Frame") then
				frame.Visible = not v2 or string.find(string.lower(frame.Name), v2, 1, true) ~= nil
			end
		end

		self:UpdateDropdownHeight()
	end

	function extended:UpdateDropdownHeight()
		local total = 0

		for _, frame in self.UI.Right.DropdownCtn.Content.InnerContent:GetChildren() do
			if frame:IsA("Frame") and frame.Visible then
				total += frame.Size.Y.Offset
			end
		end

		self.UI.Right.DropdownCtn.Content.Size = UDim2.new(1, 0, 0, (math.min(total, 100)))
		self.UI.Right.DropdownCtn.Content.InnerContent.CanvasSize = UDim2.new(0, 0, 0, total)
	end

	function extended:GetFirstVisibleChoice()
		local frames = {}

		for _, frame in self.UI.Right.DropdownCtn.Content.InnerContent:GetChildren() do
			if frame:IsA("Frame") and frame.Visible then
				table.insert(frames, frame)
			end
		end

		table.sort(frames, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		return frames[1] and frames[1].Name or nil
	end

	function extended:UpdateChoices()
		local innerContent = self.UI.Right.DropdownCtn.Content.InnerContent

		for _, frame in innerContent:GetChildren() do
			if not frame:IsA("Frame") or table.find(self.Choices, frame.Name) then
				continue
			end

			frame:Destroy()
		end

		for k, childName in self.Choices do
			local clone = innerContent:FindFirstChild(childName)

			if not (clone and clone:IsA("Frame")) then
				clone = self.OriginalUI.Right.DropdownCtn.Content.InnerContent.Item:Clone()
				clone.Visible = true
				clone.Name = childName
				clone.Parent = innerContent
				clone.TextLabel.ZIndex = innerContent.ZIndex + 1
				clone.TextButton.ZIndex = innerContent.ZIndex + 10
				clone.TextButton.MouseEnter:Connect(function()
					clone.TextButton.BackgroundTransparency = 0.8
				end)
				clone.TextButton.MouseLeave:Connect(function()
					clone.TextButton.BackgroundTransparency = 1
				end)
				clone.TextButton.InputBegan:Connect(function(activeChoiceInput)
					if activeChoiceInput.UserInputType == Enum.UserInputType.MouseButton1 or activeChoiceInput.UserInputType == Enum.UserInputType.Touch then
						self.ActiveChoiceInput = activeChoiceInput
					end
				end)
				clone.TextButton.InputEnded:Connect(function(input)
					if self.ActiveChoiceInput == input then
						task.defer(function()
							if self.ActiveChoiceInput == input then
								self.ActiveChoiceInput = nil
							end
						end)
					end
				end)
				local v2 = childName
				clone.TextButton.Activated:Connect(function()
					self:SetSelected(v2)
					self:SetIsOpen(false)
					self.OnChanged(v2)
				end)
			end

			clone.TextLabel.Text = childName
			clone.LayoutOrder = k - 1
		end

		self:UpdateDropdownHeight()
	end

	function extended:UpdateEnabledDisplay()
		local enabled = self:GetEnabled()
		local textBox = self.UI.Right.DropdownCtn.TextBox
		textBox.TextEditable = enabled
		textBox.Active = enabled
		textBox.Selectable = enabled

		if not enabled and textBox:IsFocused() then
			textBox:ReleaseFocus(false)
		end

		self.UI.Right.Overlay.Visible = not enabled

		if self.IsOpen and not enabled then
			self:SetIsOpen(false)
		end
	end

	function extended:UpdateDisplay()
		if not self:IsDestroyed() then
			self.UI.Right.DropdownCtn.Content.Visible = self.IsOpen
		end
	end

	return extended
end