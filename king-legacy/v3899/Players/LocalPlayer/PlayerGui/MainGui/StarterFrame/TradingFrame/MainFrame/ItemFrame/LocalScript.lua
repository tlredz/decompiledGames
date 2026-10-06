local parent = script.Parent
local uIGridLayout = parent:WaitForChild("UIGridLayout")
local v = 0.2423 - uIGridLayout.CellPadding.X.Scale
local v2 = 0.36 - uIGridLayout.CellPadding.Y.Scale
uIGridLayout.CellSize = UDim2.new(0, parent.AbsoluteSize.X * v, 0, parent.AbsoluteSize.Y * v2)
parent.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, uIGridLayout.AbsoluteContentSize.Y)
uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	uIGridLayout.CellSize = UDim2.new(0, parent.AbsoluteSize.X * v, 0, parent.AbsoluteSize.Y * v2)
	parent.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, uIGridLayout.AbsoluteContentSize.Y)
end)