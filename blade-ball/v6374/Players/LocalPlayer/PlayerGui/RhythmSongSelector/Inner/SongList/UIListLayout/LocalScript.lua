-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	script.Parent.Parent.CanvasSize = UDim2.new(1, 0, 0, script.Parent.AbsoluteContentSize.Y)
end

script.Parent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
update() -- equivalent call inferred; original call site unknown