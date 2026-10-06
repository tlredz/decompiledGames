local TextService = game:GetService("TextService")
return function(p, p2, p3)
	local width = math.min(520, (math.max(220, p.X - 24)))
	local inner = width - 32
	local titleSize = width < 400 and 21 or 24
	local titleHeight = math.ceil(TextService:GetTextSize(p2, titleSize, Enum.Font.GothamBold, Vector2.new(inner, 1000)).Y) + 4
	local bodyHeight = math.ceil(TextService:GetTextSize(p3, 17, Enum.Font.Gotham, Vector2.new(inner - 12, 10000)).Y) + 8
	local stacked = inner < 320
	local v7 = stacked and 104 or 48
	local bodyY = titleHeight + 42 + 8
	local height = math.min(bodyY + bodyHeight + 12 + v7 + 16, (math.max(240, p.Y - 24)))
	return {
		width = width,
		height = height,
		inner = inner,
		titleSize = titleSize,
		titleHeight = titleHeight,
		bodyY = bodyY,
		bodyHeight = bodyHeight,
		visibleBody = math.max(32, height - bodyY - 12 - v7 - 16),
		buttonY = height - v7 - 16,
		stacked = stacked
	}
end