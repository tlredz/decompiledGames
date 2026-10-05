require(script.Parent.Parent.Types)
local TweenService = game:GetService("TweenService")
return function(p, data)
	local extended = data.extend("Expandable", "Expandable")

	function extended:Init()
		self.TextRatio = self.OriginalUI.Top.Ctn.TextLabel.TextSize / self.OriginalUI.Size.Y.Offset

		function self.OnExpanded() end

		self.Expanded = false
		self.ContentHeight = 0
		self.SizeY = 22
		self.Components = p.ComponentManager.new(self.UI.Content.InnerContent.DeepContent, self)
		self.UI.Size = UDim2.new(1, 0, 0, self.SizeY)
		self.UI.Top.Ctn.TextLabel.TextSize = self.SizeY * self.TextRatio
		self.UI.Content.Position = UDim2.new(0, 0, 0, self.SizeY)
		self.UI.Content:GetPropertyChangedSignal("Size"):Connect(function()
			self:UpdateInternalSize()
			self:UpdateParentHeight()
			self.UI.Content.Visible = self.UI.Content.Size.Y.Offset > 0
		end)
		self.UI.Top.Interactibility.MouseButton1Click:Connect(function()
			self:SetExpanded(not self:IsExpanded(), true)
		end)
		self.UI.Top.Interactibility.MouseEnter:Connect(function()
			self.UI.Top.WhiteFrame.Visible = true
		end)
		self.UI.Top.Interactibility.MouseLeave:Connect(function()
			self.UI.Top.WhiteFrame.Visible = false
		end)
	end

	function extended:SetSizeY(sizeY: number)
		self.SizeY = sizeY
		self.UI.Size = UDim2.new(1, 0, 0, self.SizeY + self.UI.Content.Size.Y.Offset)
		self.UI.Top.Ctn.TextLabel.TextSize = self.SizeY * self.TextRatio
		self.UI.Content.Position = UDim2.new(0, 0, 0, self.SizeY)
		return self
	end

	function extended.SetText(p2, text: string)
		p2.UI.Top.Ctn.TextLabel.Text = text
		return p2
	end

	function extended:SetExpanded(expanded: boolean, flag: boolean?, flag2: boolean?)
		self.Expanded = expanded
		self.OnExpanded(self.Expanded, flag)
		local v = flag2 and 0 or 0.1
		TweenService:Create(self.UI.Content, TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, not self.Expanded and 0 or self.ContentHeight)
		}):Play()
		TweenService:Create(
			self.UI.Top.Ctn.Icon.Logo,
			TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Rotation = self.Expanded and 90 or 180
			}
		):Play()
		return self
	end

	function extended:IsExpanded()
		return self.Expanded
	end

	function extended:BindOnExpanded(onExpanded)
		self.OnExpanded = onExpanded
		return self
	end

	function extended:UpdateHeight(flag: boolean?)
		if self.Destroyed or not self.UI.Parent then
			return self
		end

		self.ContentHeight = self.Components:GetComponentsHeight()

		if self:IsExpanded() then
			TweenService:Create(self.UI.Content, TweenInfo.new(0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 0, self.ContentHeight)
			}):Play()
		end

		return data.UpdateHeight(self, flag)
	end

	function extended.SetBackgroundColor(p2, backgroundColor: Color3)
		data.SetBackgroundColor(p2, backgroundColor)
		p2.UI.Top.Ctn.BackgroundColor3 = backgroundColor
		return p2
	end

	function extended:UpdateInternalSize()
		self.UI.Size = UDim2.new(1, 0, 0, self.SizeY + self.UI.Content.Size.Y.Offset)
	end

	return extended
end