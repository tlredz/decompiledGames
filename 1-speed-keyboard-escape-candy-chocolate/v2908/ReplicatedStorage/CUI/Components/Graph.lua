require(script.Parent.Parent.Types)
return function(_, p)
	local extended = p.extend("Graph", "Graph")

	function extended:Init()
		self.GraphValue = {
			0,
			0,
			{ 0, 0 },
			{ 0, 0 }
		}
	end

	function extended:UpdateGraphCurve() end

	function extended:SetCurve(graphValue)
		self.GraphValue = graphValue
		self:UpdateGraphCurve()
		return self
	end

	function extended.SetSizeY(object, p2: number)
		object.UI.Size = UDim2.new(1, 0, 0, p2)
		object:UpdateHeight()
		object:UpdateParentHeight()
		return object
	end

	function extended:SetStartValue(p2: number)
		self.GraphValue[1] = p2
		self:UpdateGraphCurve()
		return self
	end

	function extended:SetEndValue(p2: number)
		self.GraphValue[2] = p2
		self:UpdateGraphCurve()
		return self
	end

	function extended:SetStartPosition(p2: number, p3: number)
		self.GraphValue[3][1] = p2
		self.GraphValue[3][2] = p3
		self:UpdateGraphCurve()
		return self
	end

	function extended:SetEndPosition(p2: number, p3: number)
		self.GraphValue[4][1] = p2
		self.GraphValue[4][2] = p3
		self:UpdateGraphCurve()
		return self
	end

	return extended
end