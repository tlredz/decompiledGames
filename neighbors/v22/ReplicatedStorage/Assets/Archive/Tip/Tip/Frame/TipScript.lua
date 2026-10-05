local mouse = game.Players.LocalPlayer:GetMouse()
mouse.Move:connect(function()
	script.Parent.AnchorPoint = Vector2.new(
		mouse.X + 30 + script.Parent.AbsoluteSize.X >= script.Parent.Parent.AbsoluteSize.X and 1 or 0,
		mouse.Y + 30 + script.Parent.AbsoluteSize.Y >= script.Parent.Parent.AbsoluteSize.Y and 1 or 0
	)
	local v = script.Parent.AnchorPoint.X == 1 and -1 or 1
	local v2 = script.Parent.AnchorPoint.X == 1 and -1 or 1
	script.Parent.Position = UDim2.new(0, mouse.X + 16 * v, 0, mouse.Y + 16 * v2)
end)