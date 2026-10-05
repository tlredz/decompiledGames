require(script.Parent.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function fixDecimal(p: number)
	local v = tostring(p)
	local v2, v3 = string.match(v, "^([^%.]+)%.(.+)$")

	if v3 then
		return tonumber(v2 .. "." .. string.sub(v3, 1, 3)) or 0
	end

	return tonumber(v) or 0
end

return function(_, p)
	local extended = p.extend("Slider", "Slider")

	function extended:Init()
		function self.OnChanged() end

		self.CurValue = 0
		self.Range = { 0, 100 }
		self.Increment = 1
		self.UI.Right.TextBox.Focused:Connect(function()
			self.UI.Right.TextBox.CursorPosition = #self.UI.Right.TextBox.Text + 1
			self.UI.Right.TextBox.SelectionStart = 1
		end)
		self.UI.Right.TextBox.FocusLost:Connect(function(p2)
			local text = tonumber(self.UI.Right.TextBox.Text)

			if text == nil or not p2 then
				self.UI.Right.TextBox.Text = tostring(self.CurValue)
				return
			end

			self:SetValue(text)
			self.OnChanged(text)
		end)

		local function updateInput(p2)
			if not self:GetEnabled() then
				return
			end

			local sliderBar = self.UI.Right.SliderCtn.SliderBar
			local v = (p2 - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
			local v2 = fixDecimal(math.clamp(
				math.floor(math.clamp(self.Range[1] + (self.Range[2] - self.Range[1]) * v, self.Range[1], self.Range[2]) / self.Increment + 0.5) * self.Increment,
				self.Range[1],
				self.Range[2]
			)) -- equivalent call inferred; original call site unknown

			if self:GetValue() == v2 then
				return
			end

			self:SetValue(v2)
			self.OnChanged(v2)
		end

		local flag = false
		local sliderInteractibility = self.UI.Right.SliderCtn.SliderInteractibility
		sliderInteractibility.MouseButton1Down:Connect(function(p2)
			flag = true
			updateInput(p2)
		end)
		sliderInteractibility.MouseButton1Up:Connect(function()
			flag = false
		end)
		sliderInteractibility.MouseLeave:Connect(function()
			flag = false
		end)
		sliderInteractibility.MouseMoved:Connect(function(p2)
			if flag then
				updateInput(p2)
			end
		end)
	end

	function extended.SetText(p2, text: string)
		p2.UI.Left.Title.Text = text
		return p2
	end

	function extended:SetValue(p2: number)
		local curValue = fixDecimal(p2) -- equivalent call inferred; original call site unknown
		self.CurValue = curValue
		self:UpdateDisplay()
		return self
	end

	function extended:SetRange(p2: number, p3: number)
		self.Range = { math.min(p2, p3), (math.max(p3, p2)) }
		self:UpdateDisplay()
		return self
	end

	function extended:SetIncrement(increment: number)
		self.Increment = increment
		return self
	end

	function extended:GetValue()
		return self.CurValue
	end

	function extended:SetOnChanged(onChanged)
		self.OnChanged = onChanged
		return self
	end

	function extended:UpdateDisplay()
		self.UI.Right.TextBox.Text = tostring(self.CurValue)
		local v = math.clamp((self.CurValue - self.Range[1]) / (self.Range[2] - self.Range[1]), 0, 1)
		self.UI.Right.SliderCtn.SliderBar.Cursor.Position = UDim2.fromScale(v, 0.5)
		self.UI.Right.SliderCtn.SliderBar.SliderBG.Size = UDim2.fromScale(v, 1)
	end

	function extended.UpdateEnabledDisplay(object)
		local enabled = object:GetEnabled()
		object.UI.Right.TextBox.TextEditable = enabled
		object.UI.Right.TextBox.TextTransparency = enabled and 0 or 0.25
		local cursor = object.UI.Right.SliderCtn.SliderBar.Cursor
		local backgroundColor

		if enabled then
			backgroundColor = object.OriginalUI.Right.SliderCtn.SliderBar.Cursor.BackgroundColor3
		else
			backgroundColor = Color3.fromRGB(130, 130, 130)
		end

		cursor.BackgroundColor3 = backgroundColor
		local sliderBG = object.UI.Right.SliderCtn.SliderBar.SliderBG
		local backgroundColor2

		if enabled then
			backgroundColor2 = object.OriginalUI.Right.SliderCtn.SliderBar.SliderBG.BackgroundColor3
		else
			backgroundColor2 = Color3.fromRGB(61, 61, 61)
		end

		sliderBG.BackgroundColor3 = backgroundColor2
	end

	return extended
end