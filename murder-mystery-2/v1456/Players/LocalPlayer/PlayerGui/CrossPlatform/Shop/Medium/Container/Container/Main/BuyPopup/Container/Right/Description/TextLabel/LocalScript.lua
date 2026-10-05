local parent = script.Parent
parent:GetPropertyChangedSignal("Text"):Connect(function()
	parent.TextScaled = false

	if not parent.TextFits then
		parent.TextScaled = true
	end
end)