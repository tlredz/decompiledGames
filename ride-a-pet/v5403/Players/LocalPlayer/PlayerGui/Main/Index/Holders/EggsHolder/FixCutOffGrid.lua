local parent = script.Parent
local uIGridLayout = parent:WaitForChild("UIGridLayout")
local uIPadding = parent:FindFirstChild("UIPadding")
local Y = uIGridLayout.CellSize.Y
local Y2 = uIGridLayout.CellPadding.Y
local paddingTop = uIPadding and uIPadding.PaddingTop or UDim.new()
local paddingBottom = uIPadding and uIPadding.PaddingBottom or UDim.new()
parent.AutomaticCanvasSize = Enum.AutomaticSize.None

-- equivalent calls inferred from this helper; original call sites unknown
local function Pin(p)
	return math.floor(parent.AbsoluteSize.Y * p.Scale + 0.5) + p.Offset
end

local function ApplyGridSizing()
	local pin = Pin(Y) -- equivalent call inferred; original call site unknown

	if pin > 0 then
		uIGridLayout.CellSize = UDim2.new(uIGridLayout.CellSize.X.Scale, uIGridLayout.CellSize.X.Offset, 0, pin)
	end

	uIGridLayout.CellPadding = UDim2.new(
		uIGridLayout.CellPadding.X.Scale,
		uIGridLayout.CellPadding.X.Offset,
		0,
		Pin(Y2)
	)

	if uIPadding then
		uIPadding.PaddingTop = UDim.new(0, Pin(paddingTop))
		uIPadding.PaddingBottom = UDim.new(0, Pin(paddingBottom))
	end
end

local function MeasureOverhang()
	for _, guiObject in parent:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v = guiObject.AbsolutePosition.Y + guiObject.AbsoluteSize.Y
		local v2 = v

		for _, guiObject2 in guiObject:GetDescendants() do
			if not (guiObject2:IsA("GuiObject") and guiObject2.Visible) then
				continue
			end

			local v3 = guiObject2.AbsolutePosition.Y + guiObject2.AbsoluteSize.Y

			if v2 < v3 then
				v2 = v3
			end
		end

		return v2 - v
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateCanvas()
	local v = not uIPadding and 0 or uIPadding.PaddingTop.Offset + uIPadding.PaddingBottom.Offset
	parent.CanvasSize = UDim2.fromOffset(0, uIGridLayout.AbsoluteContentSize.Y + v + MeasureOverhang() + 4)
end

parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	ApplyGridSizing()
	UpdateCanvas() -- equivalent call inferred; original call site unknown
end)
parent.ChildAdded:Connect(function()
	task.defer(UpdateCanvas)
end)
parent.ChildRemoved:Connect(function()
	task.defer(UpdateCanvas)
end)
uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
ApplyGridSizing()
UpdateCanvas() -- equivalent call inferred; original call site unknown