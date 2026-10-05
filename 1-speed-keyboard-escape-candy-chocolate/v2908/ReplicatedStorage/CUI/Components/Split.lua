require(script.Parent.Parent.Types)
return function(p, data)
	local extended = data.extend("Split", "Split")

	function extended:Init()
		self.LeftComponents = p.ComponentManager.new(self.UI.Left, self, function()
			return self.UI.Left.Size.X.Offset + self.UI.Left.Size.X.Scale * self:GetWidth()
		end)
		self.RightComponents = p.ComponentManager.new(self.UI.Right, self, function()
			return self.UI.Right.Size.X.Offset + self.UI.Right.Size.X.Scale * self:GetWidth()
		end)
	end

	function extended.SetLeftSizePercent(p2, p3: number)
		p2.UI.Left.Size = UDim2.fromScale(p3, 1)
		p2.UI.Right.Size = UDim2.fromScale(1 - p3, 1)
		return p2
	end

	function extended.SetLeftSizeAbsolute(p2, p3: number)
		p2.UI.Left.Size = UDim2.new(0, p3, 1, 0)
		p2.UI.Right.Size = UDim2.new(1, -p3, 1, 0)
		return p2
	end

	function extended.SetRightSizePercent(p2, p3: number)
		p2.UI.Right.Size = UDim2.fromScale(p3, 1)
		p2.UI.Left.Size = UDim2.fromScale(1 - p3, 1)
		return p2
	end

	function extended.SetRightSizeAbsolute(p2, p3: number)
		p2.UI.Right.Size = UDim2.new(0, p3, 1, 0)
		p2.UI.Left.Size = UDim2.new(1, -p3, 1, 0)
		return p2
	end

	function extended.SetVerticalAlignment(p2, p3: string, verticalAlignment)
		p2.UI[p3].UIListLayout.VerticalAlignment = verticalAlignment
		return p2
	end

	function extended.SetHorizontalAlignment(p2, p3: string, horizontalAlignment)
		p2.UI[p3].UIListLayout.HorizontalAlignment = horizontalAlignment
		return p2
	end

	function extended:GetHeight()
		return (math.max(self.LeftComponents:GetComponentsHeight(), self.RightComponents:GetComponentsHeight()))
	end

	function extended:UpdateHeight(flag: boolean?)
		self.UI.Size = UDim2.new(1, 0, 0, self:GetHeight())
		return data.UpdateHeight(self, flag)
	end

	function extended.OnDestroy(p2)
		for _, v in p2.LeftComponents:GetAll() do
			v:Destroy()
		end

		for _, v in p2.RightComponents:GetAll() do
			v:Destroy()
		end

		data.OnDestroy(p2)
	end

	return extended
end