local parent = script.Parent
local uIGridLayout = parent:WaitForChild("UIGridLayout")

-- equivalent calls inferred from this helper; original call sites unknown
local function SetContentSize()
	parent.CanvasSize = UDim2.new(0, uIGridLayout.AbsoluteContentSize.X, 0, uIGridLayout.AbsoluteContentSize.Y + 10)
end

uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SetContentSize)
SetContentSize() -- equivalent call inferred; original call site unknown