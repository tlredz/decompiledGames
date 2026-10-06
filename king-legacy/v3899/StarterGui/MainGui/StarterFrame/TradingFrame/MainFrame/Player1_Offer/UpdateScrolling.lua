local uIGridLayout = script.Parent:WaitForChild("UIGridLayout")
local parent = script.Parent
uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	wait()
	parent.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, 0)
end)