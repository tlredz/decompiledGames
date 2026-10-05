return function(instance)
	local uIListLayout = instance:FindFirstChildOfClass("UIListLayout")
	assert(uIListLayout, "UIListLayout not under ScrollingFrame with tag UI_AutoAdjustCanvasSize")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		instance.CanvasSize = UDim2.new(0, 0, 0, uIListLayout.AbsoluteContentSize.Y)
	end

	local absoluteContentSizeChangedConnection = uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update() -- equivalent call inferred; original call site unknown
	return function()
		absoluteContentSizeChangedConnection:Disconnect()
	end
end