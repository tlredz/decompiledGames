local v = { script.Parent.MinSize, script.Parent.MaxSize }
script.Parent.Parent.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	local absoluteSize = script.Parent.Parent.Parent.AbsoluteSize
	script.Parent.MinSize = Vector2.new(0, 0)
	script.Parent.MaxSize = Vector2.new(1e999, 1e999)
	script.Parent.MinSize = Vector2.new(math.min(v[1].X, absoluteSize.X), (math.min(v[1].Y, absoluteSize.Y)))
	script.Parent.MaxSize = Vector2.new(math.min(v[2].X, absoluteSize.X), (math.min(v[2].Y, absoluteSize.Y)))
end)