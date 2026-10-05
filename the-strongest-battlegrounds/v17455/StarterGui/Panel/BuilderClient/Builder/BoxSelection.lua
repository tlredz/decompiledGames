local BoxSelection = {
	active = false
}
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local clone = script.BuildBoxSelection:Clone()
local area = clone.Area
local mouseLocation = nil
clone.Parent = playerGui

local function coordIsInBox(p, p2, p3)
	return p.X > p2.X and p.X < p3.X and p.Y > p2.Y and p.Y < p3.Y
end

local function dragAreaUpdate()
	while true do
		task.wait()

		if not area.Visible then
			break
		end

		if BoxSelection.active then
			local mouseLocation2 = UserInputService:GetMouseLocation()
			local v = mouseLocation2.X - mouseLocation.X
			local v2 = mouseLocation2.Y - mouseLocation.Y
			local v3 = Vector2.new(v < 0 and v or 0, v2 < 0 and v2 or 0) + mouseLocation
			area.Size = UDim2.fromOffset(math.abs(v), (math.abs(v2)))
			area.Position = UDim2.fromOffset(v3.X, v3.Y)
		else
			mouseLocation = nil
			area.Size = UDim2.new()
			area.Visible = false
			break
		end
	end
end

local function captureDragSelection()
	local parentModule = require(script.Parent)
	local v = area.AbsolutePosition + GuiService:GetGuiInset()
	local v2 = v + area.AbsoluteSize
	local magnitude = (v - v2).Magnitude
	area.Size = UDim2.new()
	area.Visible = false
	mouseLocation = nil

	if magnitude < 6 then
		return
	end

	local updateConnection = false

	for _, v3 in parentModule.GetSelectable() do
		if not (v3.Parent and v3 ~= parentModule.base) then
			continue
		end

		local worldToViewportPoint, v4 = workspace.CurrentCamera:WorldToViewportPoint(v3.Position)

		if not v4 then
			continue
		end

		local v5

		if worldToViewportPoint.X > v.X and worldToViewportPoint.X < v2.X and worldToViewportPoint.Y > v.Y then
			v5 = worldToViewportPoint.Y < v2.Y
		else
			v5 = false
		end

		if not v5 then
			continue
		end

		if parentModule.mode == "delete" then
			parentModule.PartRemoved:Fire(v3)
		else
			parentModule.AddSelection(v3)
			updateConnection = parentModule.updateConnection
		end
	end

	if updateConnection then
		updateConnection()
	end
end

function BoxSelection.SetColor(backgroundColor: Color3)
	area.BackgroundColor3 = backgroundColor
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not BoxSelection.active then
		return
	end

	UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)

	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouseLocation = UserInputService:GetMouseLocation()
		area.Size = UDim2.new()
		area.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y)
		area.Visible = true
		task.spawn(dragAreaUpdate)
	end
end)
UserInputService.InputEnded:Connect(function(input, _)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and area.Visible then
		captureDragSelection()
	end
end)
UserInputService.WindowFocusReleased:Connect(function()
	if area.Visible then
		captureDragSelection()
	end
end)
return BoxSelection