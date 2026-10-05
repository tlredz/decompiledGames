return function(p, p2: number, p3: number, p4: number, _: Color3, _: Color3, _: UDim2, _: UDim2, _: number?, _: boolean?)
	p.TextTransparency = 1 - p2 * (1 - p3)
	p.TextStrokeTransparency = 1 - p2 * (1 - p4)
end