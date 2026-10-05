local UIUtil = {}

function UIUtil.getSnapLocation(p, instance, p2: string?)
	if p2 and p2 ~= "Top" and p2 ~= "Bottom" and p2 ~= "Center" then
		return nil
	end

	local Y = instance.AbsolutePosition.Y
	local v = Y + instance.AbsoluteSize.Y * 0.5
	local v2 = Y + instance.AbsoluteSize.Y
	local Y2 = p.AbsolutePosition.Y
	local position = p.AbsolutePosition.Y + p.AbsoluteSize.Y * 0.5
	local position2 = Y2 + p.AbsoluteSize.Y

	if not (Y2 < Y or v2 < position2 or p2) then
		return nil
	end

	local uIListLayout = instance:FindFirstChildOfClass("UIListLayout")
	local offset = uIListLayout and uIListLayout.Padding.Offset or 0

	if p2 == nil and position < v or p2 == "Top" then
		local v5 = -instance.AbsolutePosition.Y + (instance.CanvasPosition.Y + Y2) - offset
		return {
			Context = "Top",
			Position = Y2,
			Snap = Vector2.new(0, v5)
		}
	end

	if p2 == nil and v < position or p2 == "Bottom" then
		local v5 = math.max(0, instance.AbsoluteSize.Y - p.AbsoluteSize.Y)
		local v6 = -instance.AbsolutePosition.Y + (instance.CanvasPosition.Y + Y2 - v5) + offset
		return {
			Context = "Bottom",
			Position = position2,
			Snap = Vector2.new(0, v6)
		}
	elseif p2 == "Center" then
		local v5 = math.max(0, instance.AbsoluteSize.Y - p.AbsoluteSize.Y)
		local v6 = -instance.AbsolutePosition.Y + (instance.CanvasPosition.Y + Y2 - v5 * 0.5) - offset
		return {
			Context = "Center",
			Position = position,
			Snap = Vector2.new(0, v6)
		}
	end

	return nil
end

function UIUtil.setButtonText(instance, text: string)
	local textLabel = instance:FindFirstChild("TextLabel")
	local textLabel2 = textLabel:FindFirstChild("TextLabel")
	textLabel.Text = text
	textLabel2.Text = text
end

function UIUtil.setButtonState(instance, p: string)
	local trans = instance:FindFirstChild("Trans")

	if p == "Inactive" then
		instance.BackgroundColor3 = Color3.fromRGB(158, 158, 158)
		instance.BorderColor3 = Color3.fromRGB(48, 48, 48)
		trans.BackgroundColor3 = Color3.fromRGB(191, 191, 191)
		trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
	elseif p == "Active" then
		instance.BackgroundColor3 = Color3.fromRGB(255, 214, 49)
		instance.BorderColor3 = Color3.fromRGB(136, 61, 0)
		trans.BackgroundColor3 = Color3.fromRGB(255, 241, 87)
		trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
	end
end

return UIUtil