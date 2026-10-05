return function(p, p2: number, _: number, _: number, _: Color3, _: Color3, _: UDim2, udim: UDim2, p3: number?, _: boolean?)
	local v = 0.25 * p3
	p.Position = UDim2.fromScale(p.Position.X.Scale, udim.Y.Scale + v * (1 - p2))
end