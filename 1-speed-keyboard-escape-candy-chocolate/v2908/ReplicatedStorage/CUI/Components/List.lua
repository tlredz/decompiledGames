require(script.Parent.Parent.Types)
return function(p, p2)
	local extended = p2.extend("List", "List")

	function extended:Init()
		self.Components = p.ComponentManager.new(self.UI.Content, self)
	end

	function extended:SetSizeY(p3: number)
		self.UI.Size = UDim2.new(1, 0, 0, p3)
		self:UpdateHeight()
		self:UpdateParentHeight()
		return self
	end

	function extended.GetScroll(p3)
		return p3.UI.Content.CanvasPosition.Y
	end

	function extended.SetScroll(p3, p4: number)
		p3.UI.Content.CanvasPosition = Vector2.new(0, p4)
		return p3
	end

	function extended.GetHeight(p3)
		return p3.UI.Size.Y.Offset
	end

	function extended:UpdateHeight()
		if self.Destroyed or not self.UI.Parent then
			return self
		end

		self.UI.Content.CanvasSize = UDim2.new(0, 0, 0, self.Components:GetComponentsHeight())
		return self
	end

	function extended.OnDestroy(p3)
		for _, v in p3.Components:GetAll() do
			v:Destroy()
		end

		p2.OnDestroy(p3)
	end

	return extended
end