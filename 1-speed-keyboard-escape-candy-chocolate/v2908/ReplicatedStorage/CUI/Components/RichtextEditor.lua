require(script.Parent.Parent.Types)
local TextService = game:GetService("TextService")

local function colorToText(color: Color3)
	return ("%d, %d, %d"):format(math.floor(color.R * 255), math.floor(color.G * 255), (math.floor(color.B * 255)))
end

local function textToColor(text: string)
	local v, v2, v3 = string.match(text, "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")

	if v and v2 and v3 then
		return Color3.fromRGB(
			math.clamp(tonumber(v) or 0, 0, 255),
			math.clamp(tonumber(v2) or 0, 0, 255),
			(math.clamp(tonumber(v3) or 0, 0, 255))
		)
	end

	local v4, v5, v6 = string.match(text, "^#?(%x%x)(%x%x)(%x%x)$")

	if v4 and v5 and v6 then
		return Color3.fromRGB(tonumber(v4, 16) or 0, tonumber(v5, 16) or 0, tonumber(v6, 16) or 0)
	end

	return nil
end

return function(_, p)
	local extended = p.extend("RichtextEditor", "RichTextEditor")

	function extended:Init()
		self.IsPreviewing = false
		self.CurValue = ""
		self.CurrentSelection = { 0, 0 }
		self.CurrentColor = Color3.new(1, 1, 1)

		function self.OnChanged() end

		self.UI.Content.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if not self.UI:FindFirstChild("Content") then
				return
			end

			local text = self.UI.Content.TextBox.Text

			if text == self.CurValue then
				return
			end

			self.CurValue = text
			self:UpdateHeight()
			self.OnChanged(text)
		end)
		self.UI.Content.TextBox.Focused:Connect(function()
			if not self.UI:FindFirstChild("Content") then
				return
			end

			self:UpdateHeight()

			while self.UI.Content.TextBox:IsFocused() do
				local cursorPosition = self.UI.Content.TextBox.CursorPosition
				local selectionStart = self.UI.Content.TextBox.SelectionStart
				self.CurrentSelection = {
					math.min(cursorPosition, selectionStart),
					(math.max(cursorPosition, selectionStart))
				}
				task.wait()
			end
		end)
		self.UI.Content.TextBox.FocusLost:Connect(function()
			if self.UI:FindFirstChild("Content") then
				self:UpdateHeight()
			end
		end)
		self.UI.Top.ColorBox.TextBox.Focused:Connect(function()
			if self.UI:FindFirstChild("Content") then
				self.UI.Top.ColorBox.TextBox.CursorPosition = #self.UI.Top.ColorBox.TextBox.Text + 1
				self.UI.Top.ColorBox.TextBox.SelectionStart = 1
			end
		end)
		self.UI.Top.ColorBox.TextBox.FocusLost:Connect(function(p2)
			if not self.UI:FindFirstChild("Content") then
				return
			end

			if p2 then
				self:SetFontColor(textToColor(self.UI.Top.ColorBox.TextBox.Text) or self.CurrentColor)
			else
				self:SetFontColor(self.CurrentColor)
			end
		end)

		for _, frame in self.UI.Top:GetChildren() do
			if not (frame:IsA("Frame") and frame:FindFirstChild("Interactibility")) then
				continue
			end

			local v = frame
			frame.Interactibility.MouseEnter:Connect(function()
				v.BackgroundTransparency = 0.9
			end)
			local v2 = frame
			frame.Interactibility.MouseLeave:Connect(function()
				v2.BackgroundTransparency = 1
			end)
			local v3 = frame
			frame.Interactibility.MouseButton1Down:Connect(function()
				if v3.Name == "Bold" then
					self:AppendToSelectedText("<b>", "</b>")
				elseif v3.Name == "Italic" then
					self:AppendToSelectedText("<i>", "</i>")
				elseif v3.Name == "Underline" then
					self:AppendToSelectedText("<u>", "</u>")
				elseif v3.Name == "FontColor" then
					self:AppendToSelectedText(
						"<font color='rgb(" .. self.UI.Top.ColorBox.TextBox.Text .. ")'>",
						"</font>"
					)
				end

				self:ClearSelectedText()
			end)
		end
	end

	function extended:ClearSelectedText()
		self.CurrentSelection = { 0, 0 }
	end

	function extended.GetSelectedText(p2)
		local text = p2.UI.Content.TextBox.Text
		local v = p2.CurrentSelection[1]
		local v2 = p2.CurrentSelection[2]

		if v == v2 then
			return ""
		end

		return (string.sub(text, v, v2 - 1))
	end

	function extended:AppendToSelectedText(p2: string, p3: string?)
		local text = self.UI.Content.TextBox.Text
		local v2 = self.CurrentSelection[1]
		local v3 = self.CurrentSelection[2]

		if v2 == v3 then
			return
		end

		local text2 = string.sub(text, 1, v2 - 1) .. p2 .. string.sub(text, v2, v3 - 1) .. (p3 or p2) .. string.sub(
			text,
			v3
		)
		self.UI.Content.TextBox.Text = text2
		self:SetValue(text2)
	end

	function extended:SetFontColor(color: Color3)
		self.CurrentColor = color
		self.UI.Top.ColorBox.TextBox.Text = ("%d, %d, %d"):format(
			math.floor(color.R * 255),
			math.floor(color.G * 255),
			(math.floor(color.B * 255))
		)
		self.UI.Top.FontColor.Icon.ImageColor3 = color
		return self
	end

	function extended.SetText(p2, text: string)
		p2.UI.Top.InBetween.TextLabel.Text = text
		return p2
	end

	function extended:SetValue(p2: string)
		self.UI.Content.TextBox.Text = p2
		self.CurValue = p2
		self:UpdateHeight()
		self.OnChanged(p2)
		return self
	end

	function extended.GetValue(p2)
		return p2.CurValue
	end

	function extended:SetOnChanged(callback)
		self.OnChanged = callback or function() end
		return self
	end

	function extended:UpdateHeight()
		local offset = self.UI.Size.Y.Offset
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		local text

		if self.UI.Content.TextBox:IsFocused() then
			text = self.UI.Content.TextBox.Text
		else
			text = self.UI.Content.TextBox.ContentText
		end

		getTextBoundsParams.Text = text
		getTextBoundsParams.Font = self.UI.Content.TextBox.FontFace
		getTextBoundsParams.Size = self.UI.Content.TextBox.TextSize
		getTextBoundsParams.Width = self.UI.Content.TextBox.AbsoluteSize.X
		local v2 = TextService:GetTextBoundsAsync(getTextBoundsParams).Y - self.UI.Content.TextBox.Size.Y.Offset
		local uDim = UDim2.new(1, 0, 0, v2 + self.UI.Top.Size.Y.Offset + 3)

		if offset ~= uDim.Y.Offset then
			self.UI.Size = uDim
			self:UpdateParentHeight()
		end

		return self
	end

	return extended
end