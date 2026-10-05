require(script.Parent.Parent.Types)

local function toHex(currentColor: Color3)
	return string.format("#%02X%02X%02X", currentColor.R * 255, currentColor.G * 255, currentColor.B * 255)
end

local function textToColor(text: string)
	if string.match(text, "^#?(%x%x)(%x%x)(%x%x)$") then
		local v, v2, v3 = string.match(text, "^#?(%x%x)(%x%x)(%x%x)$")
		return Color3.fromRGB(tonumber(v, 16) or 0, tonumber(v2, 16) or 0, tonumber(v3, 16) or 0)
	end

	local v, v2, v3 = string.match(text, "(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")

	if v and v2 and v3 then
		return Color3.fromRGB(
			math.clamp(tonumber(v) or 0, 0, 255),
			math.clamp(tonumber(v2) or 0, 0, 255),
			(math.clamp(tonumber(v3) or 0, 0, 255))
		)
	end

	return nil
end

local v = nil
local text2 = "HSV"
return function(_, p)
	local extended = p.extend("Color", "Color")

	function extended:Init()
		function self.OnChanged() end

		self.CurrentColor = Color3.new(1, 1, 1)
		self.IsOpen = false
		self.UI.Right.Ctn.Btn.MouseButton1Click:Connect(function()
			self:SetOpen(not self.IsOpen)
		end)
		self.UI.Right.Selector.RatioedCtn.Others.Mode.Btn.MouseButton1Click:Connect(function()
			self:SetMode(text2 == "RGB" and "HSV" or "RGB")
		end)
		self.UI.Right.Selector.RatioedCtn.Others.HTML.TextBox.Focused:Connect(function()
			if self.UI:FindFirstChild("Right") then
				self.UI.Right.Selector.RatioedCtn.Others.HTML.TextBox.CursorPosition = #self.UI.Right.Selector.RatioedCtn.Others.HTML.TextBox.Text + 1
				self.UI.Right.Selector.RatioedCtn.Others.HTML.TextBox.SelectionStart = 1
			end
		end)
		self.UI.Right.Selector.RatioedCtn.Others.HTML.TextBox.FocusLost:Connect(function(p2)
			if not p2 then
				return
			end

			local v3 = textToColor(self.UI.Right.Selector.RatioedCtn.Others.HTML.TextBox.Text)

			if not v3 then
				self:SetColor(self.CurrentColor)
				return
			end

			self:SetColor(v3)
			self.OnChanged(v3)
		end)
		self:SetupSlider(self.UI.Right.Selector.RatioedCtn.Sliders.R, 1)
		self:SetupSlider(self.UI.Right.Selector.RatioedCtn.Sliders.G, 2)
		self:SetupSlider(self.UI.Right.Selector.RatioedCtn.Sliders.B, 3)
		self:SetOpen(false)
	end

	function extended.SetText(p2, text: string)
		p2.UI.Left.Title.Text = text
		return p2
	end

	function extended:SetColor(currentColor: Color3)
		self.CurrentColor = currentColor
		self:UpdateData()
		return self
	end

	function extended.GetColor(p2)
		return p2.CurrentColor
	end

	function extended:SetOnChanged(onChanged)
		self.OnChanged = onChanged
		return self
	end

	function extended:SetOpen(isOpen: boolean)
		if not self:GetEnabled() then
			isOpen = false
		end

		if v and v ~= self then
			v:SetOpen(false)
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

	function extended:SetupSlider(p2, p3: number)
		local function updateInput(p4)
			local sliderCtn = p2.Items.SliderCtn
			local v3 = math.clamp(
				(p4 - sliderCtn.InnerSlider.AbsolutePosition.X) / sliderCtn.InnerSlider.AbsoluteSize.X,
				0,
				1
			)
			local _ = self.CurrentColor
			local color

			if text2 == "RGB" then
				if p3 == 1 then
					color = Color3.new(v3, self.CurrentColor.G, self.CurrentColor.B)
				elseif p3 == 2 then
					color = Color3.new(self.CurrentColor.R, v3, self.CurrentColor.B)
				else
					color = Color3.new(self.CurrentColor.R, self.CurrentColor.G, v3)
				end
			else
				local HSV, v4, v5 = self.CurrentColor:ToHSV()

				if p3 == 1 then
					color = Color3.fromHSV(v3, v4, v5)
				elseif p3 == 2 then
					color = Color3.fromHSV(HSV, v3, v5)
				else
					color = Color3.fromHSV(HSV, v4, v3)
				end
			end

			self:SetColor(color)
			self.OnChanged(color)
		end

		local flag = false
		p2.Interactibility.MouseButton1Down:Connect(function(p4)
			flag = true
			updateInput(p4)
		end)
		p2.Interactibility.MouseButton1Up:Connect(function()
			flag = false
		end)
		p2.Interactibility.MouseLeave:Connect(function()
			flag = false
		end)
		p2.Interactibility.MouseMoved:Connect(function(p4)
			if flag then
				updateInput(p4)
			end
		end)
	end

	function extended:GetHTML()
		return toHex(self.CurrentColor)
	end

	function extended:SetMode(p2: string)
		text2 = p2
		self:UpdateData()
		return self
	end

	function extended:UpdateData()
		self.UI.Right.Ctn.Frame.BackgroundColor3 = self.CurrentColor
		local selector = self.UI.Right.Selector
		selector.RatioedCtn.Others.Mode.Btn.Text = text2
		selector.RatioedCtn.Others.HTML.TextBox.Text = self:GetHTML()

		if text2 == "RGB" then
			local R = self.CurrentColor.R
			local G = self.CurrentColor.G
			local B = self.CurrentColor.B
			self:SetSliderData(
				selector.RatioedCtn.Sliders.R,
				R,
				math.floor(R * 255),
				ColorSequence.new(Color3.new(0, G, B), Color3.new(1, G, B))
			)
			self:SetSliderData(
				selector.RatioedCtn.Sliders.G,
				G,
				math.floor(G * 255),
				ColorSequence.new(Color3.new(R, 0, B), Color3.new(R, 1, B))
			)
			self:SetSliderData(
				selector.RatioedCtn.Sliders.B,
				B,
				math.floor(B * 255),
				ColorSequence.new(Color3.new(R, G, 0), Color3.new(R, G, 1))
			)
		else
			local HSV, v3, v4 = self.CurrentColor:ToHSV()
			local colorSequenceKeypoints = {}

			for i = 0, 10 do
				table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(i / 10, Color3.fromHSV(i / 10, v3, v4)))
			end

			self:SetSliderData(
				selector.RatioedCtn.Sliders.R,
				HSV,
				math.floor(HSV * 255),
				ColorSequence.new(colorSequenceKeypoints)
			)
			self:SetSliderData(
				selector.RatioedCtn.Sliders.G,
				v3,
				math.floor(v3 * 255),
				ColorSequence.new(Color3.fromHSV(HSV, 0, v4), Color3.fromHSV(HSV, 1, v4))
			)
			self:SetSliderData(
				selector.RatioedCtn.Sliders.B,
				v4,
				math.floor(v4 * 255),
				ColorSequence.new(Color3.fromHSV(HSV, v3, 0), Color3.fromHSV(HSV, v3, 1))
			)
		end
	end

	function extended:SetSliderData(p2, p3: number, p4: number, color)
		p2.Items.NumCtn.Title.Text = tostring(p4)
		p2.Items.SliderCtn.InnerSlider.Cursor.Position = UDim2.fromScale(p3, 0.5)
		p2.Items.SliderCtn.InnerSlider.UIGradient.Color = color
	end

	function extended:UpdateDisplay()
		self.UI.Right.Selector.Visible = self.IsOpen
		self:UpdateData()
	end

	function extended:UpdateEnabledDisplay()
		local enabled = self:GetEnabled()

		if not enabled and self.IsOpen then
			self:SetOpen(false)
		end

		self.UI.Right.NonEnabled.Visible = not enabled
	end

	return extended
end