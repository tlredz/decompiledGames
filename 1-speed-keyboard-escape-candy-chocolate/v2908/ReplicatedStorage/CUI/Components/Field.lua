require(script.Parent.Parent.Types)
return function(_, p)
	local extended = p.extend("Field", "Field")

	function extended:Init()
		function self.OnChangedRaw() end

		function self.OnChangedEntered() end

		function self.Filter(p2)
			return p2
		end

		self.DoSelectAllOnFocus = true
		self.DoEnterCheck = false
		self.IsFocused = false
		self.CurValue = nil
		self.CurText = ""
		self.UI.Right.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if not self.UI:FindFirstChild("Right") then
				return
			end

			self.OnChangedRaw(self.UI.Right.TextBox.Text)
		end)
		self.UI.Right.TextBox.Focused:Connect(function()
			self.IsFocused = true

			if not self.UI:FindFirstChild("Right") then
				return
			end

			self.UI.Right.TextBox.TextTruncate = Enum.TextTruncate.None

			if self.DoSelectAllOnFocus then
				self.UI.Right.TextBox.CursorPosition = #self.UI.Right.TextBox.Text + 1
				self.UI.Right.TextBox.SelectionStart = 1
			end
		end)
		self.UI.Right.TextBox.FocusLost:Connect(function(p2)
			self.IsFocused = false

			if not self.UI:FindFirstChild("Right") then
				return
			end

			self.UI.Right.TextBox.TextTruncate = Enum.TextTruncate.AtEnd

			if not self:GetEnabled() or self.DoEnterCheck and p2 == false then
				self.UI.Right.TextBox.Text = self.CurText
				return
			end

			local textToValue = self:TextToValue((self.Filter(self.UI.Right.TextBox.Text)))
			local valueToText = self:ValueToText(textToValue)
			self.UI.Right.TextBox.Text = valueToText
			self.CurText = valueToText
			self.CurValue = textToValue
			self.OnChangedEntered(textToValue)
		end)
	end

	function extended:TextToValue(p2: string)
		return p2
	end

	function extended:ValueToText(p2)
		return (tostring(p2))
	end

	function extended:SetDoSelectAllOnFocus(doSelectAllOnFocus: boolean)
		self.DoSelectAllOnFocus = doSelectAllOnFocus
		return self
	end

	function extended.SetText(p2, text: string)
		if p2.UI and p2.UI:FindFirstChild("Left") then
			p2.UI.Left.Title.Text = text
		end

		return p2
	end

	function extended.SetTextVisible(p2, visible: boolean)
		if p2.UI and p2.UI:FindFirstChild("Left") then
			p2.UI.Left.Visible = visible
			local right = p2.UI.Right
			local size

			if visible then
				size = UDim2.new(0.5, -1, 1, 0)
			else
				size = UDim2.fromScale(1, 1)
			end

			right.Size = size
		end

		return p2
	end

	function extended:SetValue(curValue)
		self.CurValue = curValue
		self.CurText = self:ValueToText(curValue)

		if not self.IsFocused then
			self.UI.Right.TextBox.Text = self.CurText
		end

		return self
	end

	function extended.GetValue(p2)
		return p2.CurValue
	end

	function extended.SetPlaceholder(p2, placeholderText: string)
		p2.UI.Right.TextBox.PlaceholderText = placeholderText
		return p2
	end

	function extended.GetPlaceholder(p2)
		return p2.UI.Right.TextBox.PlaceholderText
	end

	function extended:SetOnChangedRaw(onChangedRaw)
		self.OnChangedRaw = onChangedRaw
		return self
	end

	function extended:SetOnChangedUnfocus(onChangedEntered)
		self.OnChangedEntered = onChangedEntered
		self.DoEnterCheck = false
		return self
	end

	function extended:SetOnChangedEntered(callback)
		self.OnChangedEntered = callback or function() end
		self.DoEnterCheck = true
		return self
	end

	function extended:SetNumberFilter(value: number?, value2: number?)
		function self.Filter(p3)
			return (tostring((math.clamp(tonumber(p3) or 0, value or -1e999, value2 or 1e999))))
		end

		return self
	end

	function extended:SetCustomFilter(filter)
		self.Filter = filter
		return self
	end

	function extended.UpdateEnabledDisplay(object)
		local enabled = object:GetEnabled()
		object.UI.Right.TextBox.TextEditable = enabled
		object.UI.Right.NonEnabled.Visible = not enabled
		object.UI.Right.TextBox.TextTransparency = enabled and 0 or 0.25
	end

	return extended
end