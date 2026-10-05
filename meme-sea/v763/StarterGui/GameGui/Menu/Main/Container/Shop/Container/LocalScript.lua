local parent = script.Parent
local uIListLayout = parent:WaitForChild("UIListLayout")

-- equivalent calls inferred from this helper; original call sites unknown
local function SetContentSize()
	parent.CanvasSize = UDim2.new(0, uIListLayout.AbsoluteContentSize.X, 0, uIListLayout.AbsoluteContentSize.Y + 10)
end

uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SetContentSize)
SetContentSize() -- equivalent call inferred; original call site unknown