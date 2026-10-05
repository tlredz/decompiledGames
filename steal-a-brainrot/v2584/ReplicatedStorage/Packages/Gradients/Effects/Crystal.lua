local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 179, 216)),
	ColorSequenceKeypoint.new(0.5250431895256042, Color3.fromRGB(153, 155, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 193, 217))
})
local colorSequence2 = ColorSequence.new(Color3.fromRGB(255, 255, 255))
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.499377, 0),
	NumberSequenceKeypoint.new(1, 1)
})

-- equivalent calls inferred from this helper; original call sites unknown
local function getSweepOffset(serverTimeNow: number)
	local v = serverTimeNow % 4

	if v < 3 then
		return Vector2.new(1, 0)
	end

	local v2 = 1 - (1 - (v - 3) % 0.5 / 0.5) ^ 2
	return Vector2.new(v2 * 2 + -1, 0)
end

local Crystal = {}

function Crystal.simulate(_: number)
	local serverTimeNow = workspace:GetServerTimeNow()
	local v = {
		main = colorSequence,
		mainRotation = serverTimeNow % 3 / 3 * 360,
		shine = colorSequence2,
		shineTransparency = numberSequence,
		shineOffset = 0
	}
	local sweepOffset = getSweepOffset(serverTimeNow) -- equivalent call inferred; original call site unknown
	v.shineOffset = sweepOffset
	return v
end

function Crystal.apply(label)
	local v = {}
	local main = label:FindFirstChildWhichIsA("UIGradient")
	local color

	if main then
		color = main.Color
	else
		color = nil
	end

	local transparency

	if main then
		transparency = main.Transparency
	else
		transparency = nil
	end

	local rotation

	if main then
		rotation = main.Rotation
	else
		rotation = nil
	end

	local offset

	if main then
		offset = main.Offset
	else
		offset = nil
	end

	if not main then
		main = Instance.new("UIGradient")
		assert(main)
		main.Parent = label
		table.insert(v, main)
	end

	assert(main)
	main.Color = colorSequence
	main.Transparency = NumberSequence.new(0)
	main.Offset = Vector2.new(0, 0.1)
	local uIGradient

	if label:IsA("TextLabel") then
		local clone = label:Clone()
		clone.Name = "ShineSweep"
		clone:ClearAllChildren()

		for _, tag in clone:GetTags() do
			clone:RemoveTag(tag)
		end

		clone.Active = false
		clone.Selectable = false
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Position = UDim2.fromScale(0.5, 0.5)
		clone.Size = UDim2.fromScale(1, 1)
		clone.ZIndex = math.min(10, label.ZIndex + 1)
		clone.BackgroundTransparency = 1
		clone.TextColor3 = Color3.fromRGB(255, 228, 255)
		uIGradient = Instance.new("UIGradient")
		assert(uIGradient)
		uIGradient.Color = colorSequence2
		uIGradient.Transparency = numberSequence
		uIGradient.Offset = Vector2.new(1, 0)
		uIGradient.Parent = clone
		clone.Parent = label
		table.insert(v, clone)
		local textChangedConnection = label:GetPropertyChangedSignal("Text"):Connect(function()
			clone.Text = label.Text
		end)
		table.insert(v, function()
			textChangedConnection:Disconnect()
		end)
	end

	return {
		main = main,
		shine = uIGradient,
		cleanup = function()
			if color then
				main.Color = color
			end

			if transparency then
				main.Transparency = transparency
			end

			if rotation ~= nil then
				main.Rotation = rotation
			end

			if offset then
				main.Offset = offset
			end

			for _, v3 in ipairs(v) do
				if typeof(v3) == "function" then
					v3()
				else
					v3:Destroy()
				end
			end
		end
	}
end

return Crystal