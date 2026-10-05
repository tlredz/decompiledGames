local parent = script.Parent
parent.Parent:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
	parent.BackgroundColor3 = Color3.fromRGB(255, 206, 108)
end)