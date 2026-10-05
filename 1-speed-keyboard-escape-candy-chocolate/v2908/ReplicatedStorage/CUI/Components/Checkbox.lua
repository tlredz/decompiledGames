require(script.Parent.Parent.Types)
return function(_, p)
	local extended = p.extend("Checkbox", "Checkbox")

	function extended:Init()
		function self.OnChanged() end

		self.CurrentValue = false
		self:UpdateDisplay()
		self.UI.Right.CheckboxCtn.TextButton.MouseButton1Click:Connect(function()
			if not self:GetEnabled() then
				return
			end

			self:SetValue(not self.CurrentValue)
			self.OnChanged(self.CurrentValue)
		end)
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

	function extended:SetValue(currentValue: boolean)
		self.CurrentValue = currentValue
		self:UpdateDisplay()
		return self
	end

	function extended.GetValue(p2)
		return p2.CurrentValue
	end

	function extended:SetOnChanged(onChanged)
		self.OnChanged = onChanged
		return self
	end

	function extended.ShowCheckboxOnly(p2)
		p2.UI.Left.Visible = false
		p2.UI.Right.Size = UDim2.new(1, 0, 1, 0)
		return p2
	end

	function extended.SetYSize(p2, p3: number)
		p2.UI.Size = UDim2.new(1, 0, 0, p3)
		return p2
	end

	function extended.SetBackgroundVisible(p2, visible: boolean)
		p2.UI.Right.BackgroundTransparency = visible and 0 or 1
		p2.UI.Left.BackgroundTransparency = visible and 0 or 1
		p2.UI.BackgroundTransparency = visible and 0 or 1
		p2.UI.BG.Visible = visible
		return p2
	end

	function extended:UpdateDisplay()
		self.UI.Right.CheckboxCtn.Checkbox.BackgroundTransparency = self.CurrentValue and 0 or 1
		self.UI.Right.CheckboxCtn.Icon.Visible = self.CurrentValue
	end

	function extended.UpdateEnabledDisplay(object)
		local enabled = object:GetEnabled()
		local checkbox = object.UI.Right.CheckboxCtn.Checkbox
		local backgroundColor

		if enabled then
			backgroundColor = object.OriginalUI.Right.CheckboxCtn.Checkbox.BackgroundColor3
		else
			backgroundColor = Color3.new(0.6, 0.6, 0.6)
		end

		checkbox.BackgroundColor3 = backgroundColor
		object.UI.Right.CheckboxCtn.DisabledCheckbox.Visible = not enabled
	end

	return extended
end