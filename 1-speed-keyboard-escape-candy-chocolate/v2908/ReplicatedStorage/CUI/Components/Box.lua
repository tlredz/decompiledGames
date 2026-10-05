require(script.Parent.Parent.Types)
return function(p, data)
	local extended = data.extend("Box", "Box")

	function extended:Init()
		self.CachedVisibility = true
		self.Components = p.ComponentManager.new(self.UI, self)
	end

	function extended.SetAlignment(p2, horizontalAlignment, verticalAlignment)
		if horizontalAlignment then
			p2.UI.UIListLayout.HorizontalAlignment = horizontalAlignment
		end

		if verticalAlignment then
			p2.UI.UIListLayout.VerticalAlignment = verticalAlignment
		end

		return p2
	end

	function extended:SetVisible(cachedVisibility: boolean, flag: boolean?)
		if not flag then
			self.CachedVisibility = cachedVisibility
		end

		return data.SetVisible(self, cachedVisibility)
	end

	function extended:GetHeight()
		return self.Components:GetComponentsHeight()
	end

	function extended:UpdateHeight(flag: boolean?)
		self.UI.Size = UDim2.new(1, 0, 0, self:GetHeight())
		return data.UpdateHeight(self, flag)
	end

	function extended.OnDestroy(p2)
		for _, v in p2.Components:GetAll() do
			v:Destroy()
		end

		data.OnDestroy(p2)
	end

	function extended:UpdateEnabledDisplay()
		self:SetVisible(self:GetEnabled() and self.CachedVisibility, true)
	end

	return extended
end