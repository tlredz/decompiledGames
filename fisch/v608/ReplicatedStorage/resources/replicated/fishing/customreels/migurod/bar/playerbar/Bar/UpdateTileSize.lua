local parent = script.Parent
local bar = parent:FindFirstAncestorOfClass("ScreenGui").bar
local uIScale = bar.UIScale
local vector = Vector2.new(272, 100)
local v = vector.X / vector.Y

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	local v2 = parent.AbsoluteSize.Y / uIScale.Scale
	parent.TileSize = UDim2.new(0, v2 * v, 1 / uIScale.Scale, 0)
end

update() -- equivalent call inferred; original call site unknown
bar:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)