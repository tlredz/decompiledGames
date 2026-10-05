require(script.Parent.Parent.Types)
local v = nil

local function timeToFormattedString(p: number)
	return DateTime.fromUnixTimestamp(p):FormatLocalTime("lll", "en-us")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupAutoSelect(state)
	state.ClearTextOnFocus = false
	state.Focused:Connect(function()
		state.CursorPosition = #state.Text + 1
		state.SelectionStart = 1
	end)
end

return function(_, p)
	local extended = p.extend("Time", "Time")

	function extended:Init()
		function self.OnChanged() end

		self.SelectedTime = -1
		self.IsOpen = false
		self.UI.Right.Ctn.Btn.MouseButton1Click:Connect(function()
			self:SetIsOpen(not self.IsOpen)
		end)
		local content = self.UI.Right.Selector.Ctn.Content
		setupAutoSelect(content.Top.Left.Timestamp.Box) -- equivalent call inferred; original call site unknown
		content.Top.Left.Timestamp.Box.FocusLost:Connect(function()
			self:SetTime(tonumber(content.Top.Left.Timestamp.Box.Text) or 0)
			self.OnChanged(self.SelectedTime)
		end)
		local v2 = {
			Year = content.Top.Right.Date.Year.Bottom.Ctn.Box,
			Month = content.Top.Right.Date.Month.Bottom.Ctn.Box,
			Day = content.Top.Right.Date.Day.Bottom.Ctn.Box,
			Hour = content.Top.Right.Time.Hour.Bottom.Ctn.Box,
			Minute = content.Top.Right.Time.Minute.Bottom.Ctn.Box
		}

		for _, v3 in v2 do
			setupAutoSelect(v3) -- equivalent call inferred; original call site unknown
			v3.FocusLost:Connect(function()
				local text = tonumber(v2.Year.Text) or 0
				local text2 = tonumber(v2.Month.Text) or 0
				local text3 = tonumber(v2.Day.Text) or 0
				local text4 = tonumber(v2.Hour.Text) or 0
				local text5 = tonumber(v2.Minute.Text) or 0
				local success, result = pcall(function()
					return DateTime.fromLocalTime(text, text2, text3, text4, text5)
				end)

				if success then
					self:SetTime(result.UnixTimestamp)
					self.OnChanged(self.SelectedTime)
				else
					print(("[CUI::Time] Invalid date/time entered: %s-%s-%s %s:%s"):format(
						text,
						text2,
						text3,
						text4,
						text5
					))
					self:UpdateData()
				end
			end)
		end

		content.Top.Left.SetToNow.Btn.MouseButton1Click:Connect(function()
			self:SetTimeToNow()
			self.OnChanged(self.SelectedTime)
		end)
		content.Top.Left.SetToNow.Btn.MouseEnter:Connect(function()
			content.Top.Left.SetToNow.Hover.Visible = true
		end)
		content.Top.Left.SetToNow.Btn.MouseLeave:Connect(function()
			content.Top.Left.SetToNow.Hover.Visible = false
		end)
		self:SetIsOpen(false)
	end

	function extended.SetText(p2, text: string)
		p2.UI.Left.Title.Text = text
		return p2
	end

	function extended:SetTime(value: number)
		self.SelectedTime = math.clamp(value, 0, 32503680000)
		self:UpdateData()
		return self
	end

	function extended:SetTimeToNow()
		self:SetTime(DateTime.now().UnixTimestamp)
		return self
	end

	function extended.GetTime(p2)
		return p2.SelectedTime
	end

	function extended:SetOnChanged(onChanged)
		self.OnChanged = onChanged
		return self
	end

	function extended:SetIsOpen(isOpen: boolean)
		if v and v ~= self then
			v:SetIsOpen(false)
		end

		if not self:GetEnabled() then
			isOpen = false
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

	function extended:UpdateData()
		local textLabel = self.UI.Right.Ctn.TextCtn.TextLabel
		local selectedTime = self.SelectedTime
		textLabel.Text = DateTime.fromUnixTimestamp(selectedTime):FormatLocalTime("lll", "en-us")

		if not self.IsOpen then
			return
		end

		local content = self.UI.Right.Selector.Ctn.Content
		content.Top.Left.Timestamp.Box.Text = tostring(self.SelectedTime)
		local localTime = DateTime.fromUnixTimestamp(self.SelectedTime):ToLocalTime()
		content.Top.Right.Date.Year.Bottom.Ctn.Box.Text = string.format("%04d", localTime.Year)
		content.Top.Right.Date.Month.Bottom.Ctn.Box.Text = string.format("%02d", localTime.Month)
		content.Top.Right.Date.Day.Bottom.Ctn.Box.Text = string.format("%02d", localTime.Day)
		content.Top.Right.Time.Hour.Bottom.Ctn.Box.Text = string.format("%02d", localTime.Hour)
		content.Top.Right.Time.Minute.Bottom.Ctn.Box.Text = string.format("%02d", localTime.Minute)
	end

	function extended:UpdateDisplay()
		self.UI.Right.Selector.Visible = self.IsOpen
		self:UpdateData()
	end

	function extended.UpdateEnabledDisplay(object)
		local enabled = object:GetEnabled()
		object.UI.Right.Ctn.NonEnabled.Visible = not enabled
		object.UI.Right.Ctn.TextCtn.TextLabel.TextTransparency = enabled and 0 or 0.25
	end

	return extended
end