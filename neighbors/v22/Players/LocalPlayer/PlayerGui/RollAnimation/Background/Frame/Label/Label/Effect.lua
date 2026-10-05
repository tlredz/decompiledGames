local RunService = game:GetService("RunService")
local parent = script.Parent
local parent2 = parent.Parent
local items = parent2.Items
local visible = parent.Visible
local renderSteppedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getBasePosition()
	local scale = parent2.UIScale.Scale
	return UDim2.new(
		0.5,
		0,
		0,
		(items.AbsolutePosition.Y - parent2.AbsolutePosition.Y) / scale + items.AbsoluteSize.Y / scale + 20
	)
end

parent:GetPropertyChangedSignal("Visible"):Connect(function()
	visible = script.Parent.Visible

	if visible then
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			parent.Position = getBasePosition() + UDim2.new(0, 0, 0, math.sin(os.clock() * 7) * 3)
			parent.UIStroke.Transparency = script.Parent.TextTransparency
		end)
		return
	end

	renderSteppedConnection:Disconnect()
	renderSteppedConnection = nil
end)