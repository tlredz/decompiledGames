local parent = script.Parent.Parent
local parent2 = script.Parent

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	parent.CanvasSize = UDim2.new(0, 0, 0, parent2.AbsoluteContentSize.Y)
end

parent2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
update() -- equivalent call inferred; original call site unknown