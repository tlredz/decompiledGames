local parent = script.Parent
local parent2 = parent.Parent
parent2:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
	parent.ImageColor3 = parent2.BackgroundColor3
end)
parent2:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
	parent.ImageTransparency = parent2.BackgroundTransparency
end)