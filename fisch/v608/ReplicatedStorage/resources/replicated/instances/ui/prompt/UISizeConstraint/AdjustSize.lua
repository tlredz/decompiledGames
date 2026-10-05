local absoluteSize = script:FindFirstAncestorWhichIsA("ScreenGui").AbsoluteSize
script.Parent.MinSize = absoluteSize * 0.23

if math.max(absoluteSize.X * 0.23, absoluteSize.Y * 0.23) > 400 then
	script.Parent.MaxSize = absoluteSize * 0.25
end