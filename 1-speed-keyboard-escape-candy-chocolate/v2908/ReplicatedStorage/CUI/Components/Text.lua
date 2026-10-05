require(script.Parent.Parent.Types)
local TextService = game:GetService("TextService")
return function(_, p)
	local extended = p.extend("Text", "Text")

	function extended:Init()
		self.DoResize = false
		self:GetMainContainer().OnUpdateWidth:Connect(function()
			self:Resize()
		end)
	end

	function extended:Resize()
		if not self.DoResize then
			return
		end

		task.spawn(function()
			local getTextBoundsParams = Instance.new("GetTextBoundsParams")
			getTextBoundsParams.Width = self:GetWidth() - self.UI.TextLabel.Size.X.Offset
			getTextBoundsParams.Text = self.UI.TextLabel.Text
			getTextBoundsParams.Font = self.UI.TextLabel.FontFace
			getTextBoundsParams.Size = self.UI.TextLabel.TextSize
			self:SetYSize(TextService:GetTextBoundsAsync(getTextBoundsParams).Y + 4)
		end)
	end

	function extended.SetRichTextEnabled(p2, richText: boolean)
		if not p2.Destroyed then
			p2.UI.TextLabel.RichText = richText
		end

		return p2
	end

	function extended:SetAutoResize(doResize: boolean)
		if not self.Destroyed then
			self.DoResize = doResize
			self:Resize()
		end

		return self
	end

	function extended.SetTextColor(p2, textColor: Color3)
		if not p2.Destroyed then
			p2.UI.TextLabel.TextColor3 = textColor
		end

		return p2
	end

	function extended:SetText(text: string)
		if self.Destroyed then
			return self
		end

		self.UI.TextLabel.Text = text
		self:Resize()
		return self
	end

	function extended:SetYSize(p2: number)
		if not self.Destroyed then
			self.UI.Size = UDim2.new(1, 0, 0, p2)
			self:SetAutoResize(false)
		end

		return self
	end

	function extended.SetTextSize(p2, textSize: number)
		if not p2.Destroyed then
			p2.UI.TextLabel.TextSize = textSize
		end

		return p2
	end

	function extended.SetTextXAlignment(p2, textXAlignment)
		if not p2.Destroyed then
			p2.UI.TextLabel.TextXAlignment = textXAlignment
		end

		return p2
	end

	function extended.SetTextYAlignment(p2, textYAlignment)
		if not p2.Destroyed then
			p2.UI.TextLabel.TextYAlignment = textYAlignment
		end

		return p2
	end

	function extended.SetFontWeight(p2, weight)
		if not p2.Destroyed then
			local fontFace = p2.UI.TextLabel.FontFace
			fontFace.Weight = weight
			p2.UI.TextLabel.FontFace = fontFace
		end

		return p2
	end

	return extended
end