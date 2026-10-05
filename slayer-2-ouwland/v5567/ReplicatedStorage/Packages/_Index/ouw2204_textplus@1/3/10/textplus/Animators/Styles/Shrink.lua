return function(p, p2: number, _: number, _: number, _: Color3, _: Color3, udim: UDim2, _: UDim2, p3: number?, _: boolean?)
	local v = p3 - p2 * (p3 - 1)
	p.Size = UDim2.fromScale(udim.X.Scale + (1 - p2) * 0.5 * v, udim.Y.Scale + (1 - p2) * 0.5 * v)
end