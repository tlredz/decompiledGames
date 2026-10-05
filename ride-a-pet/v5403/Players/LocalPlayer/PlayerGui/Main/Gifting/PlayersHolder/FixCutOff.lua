local parent = script.Parent
local uIListLayout = parent:WaitForChild("UIListLayout")
local uIPadding = parent:FindFirstChild("UIPadding")
local giftPlayerFrame = parent.Parent:WaitForChild("Handler"):WaitForChild("GiftPlayerFrame")
local scale = giftPlayerFrame.Size.Y.Scale
local offset = giftPlayerFrame.Size.Y.Offset
local scale2 = uIListLayout.Padding.Scale
local offset2 = uIListLayout.Padding.Offset
parent.AutomaticCanvasSize = Enum.AutomaticSize.None

-- equivalent calls inferred from this helper; original call sites unknown
local function CardHeight()
	if scale <= 0 then
		return offset
	end

	return (math.floor(parent.AbsoluteSize.Y * scale + 0.5))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyListPadding()
	if scale2 > 0 then
		uIListLayout.Padding = UDim.new(0, math.floor(parent.AbsoluteSize.Y * scale2 + 0.5) + offset2)
	end
end

local function ApplyHeights()
	local cardHeight = CardHeight() -- equivalent call inferred; original call site unknown

	for _, guiObject in parent:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local size = guiObject.Size

		if size.Y.Scale ~= 0 or size.Y.Offset ~= cardHeight then
			guiObject.Size = UDim2.new(size.X.Scale, size.X.Offset, 0, cardHeight)
		end
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
	parent.CanvasSize = UDim2.fromOffset(0, uIListLayout.AbsoluteContentSize.Y + v + MeasureOverhang() + 4)
end

parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	ApplyListPadding() -- equivalent call inferred; original call site unknown
	ApplyHeights()
	UpdateCanvas() -- equivalent call inferred; original call site unknown
end)
parent.ChildAdded:Connect(function()
	task.defer(function()
		ApplyHeights()
		UpdateCanvas() -- equivalent call inferred; original call site unknown
	end)
end)
parent.ChildRemoved:Connect(function()
	task.defer(UpdateCanvas)
end)
uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
ApplyListPadding() -- equivalent call inferred; original call site unknown
ApplyHeights()
UpdateCanvas() -- equivalent call inferred; original call site unknown