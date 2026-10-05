local TweenService = game:GetService("TweenService")
local TutorialProp = require(script.Parent.TutorialProp)
local tweenInfo = TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)

-- equivalent calls inferred from this helper; original call sites unknown
local function nudgeX(position: UDim2, p: number)
	return UDim2.new(p, position.X.Offset, position.Y.Scale, position.Y.Offset)
end

local function placement(data, flag: boolean, udim: UDim2?)
	if flag then
		return Vector2.zero, UDim2.fromScale(0, 0), udim or UDim2.fromScale(1, 1)
	end

	return data.AnchorPoint, data.Position, udim or data.Size
end

-- equivalent calls inferred from this helper; original call sites unknown
local function roundCorners(clone, cornerRadius: UDim)
	local frame = clone:FindFirstChild("Frame")
	local uICorner

	if frame ~= nil then
		uICorner = frame:FindFirstChildWhichIsA("UICorner")
	end

	assert(uICorner ~= nil, "the tap template needs Frame.UICorner to reshape")
	uICorner.CornerRadius = cornerRadius
end

return {
	Attach = function(button, flag: boolean?, cornerRadius: UDim?, uDim: UDim2?)
		local v

		if typeof(button) == "Instance" then
			v = button:IsA("GuiButton")
		else
			v = false
		end

		assert(v, "a tap hint needs a GuiButton")
		local v2 = flag == true
		local parent

		if v2 then
			parent = button
		else
			parent = assert(button.Parent, "a tap hint beside its button needs that button parented")
		end

		local clone, v4 = TutorialProp.Clone("TutorialTap", "TutorialTapHint")
		local zero, uDim2

		if v2 then
			zero = Vector2.zero
			uDim2 = UDim2.fromScale(0, 0)

			if not uDim then
				uDim = UDim2.fromScale(1, 1)
			end
		else
			zero = button.AnchorPoint
			uDim2 = button.Position

			if not uDim then
				uDim = button.Size
			end
		end

		clone.AnchorPoint = zero
		clone.Size = uDim
		clone.Position = uDim2
		clone.Active = false
		clone.ZIndex = button.ZIndex + 1

		if cornerRadius ~= nil then
			roundCorners(clone, cornerRadius) -- equivalent call inferred; original call site unknown
		end

		clone.Parent = parent
		local chevron = clone:FindFirstChild("Chevron")
		local v5

		if chevron == nil then
			v5 = false
		else
			v5 = chevron:IsA("ImageLabel")
		end

		assert(v5, "the tap template needs a Chevron ImageLabel")
		local position = nudgeX(chevron.Position, 1) -- equivalent call inferred; original call site unknown
		chevron.Position = position
		local tween = TweenService:Create(chevron, tweenInfo, {
			Position = UDim2.new(1.18, position.X.Offset, position.Y.Scale, position.Y.Offset)
		})
		tween:Play()
		v4:Add(tween, "Cancel")
		return TutorialProp.Teardown("Removing the tutorial tap hint", v4)
	end
}