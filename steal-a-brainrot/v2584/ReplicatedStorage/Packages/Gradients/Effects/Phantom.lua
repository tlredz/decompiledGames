local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
})

local function getTransparency()
	local v = workspace:GetServerTimeNow() % 5.9
	local v2

	if v < 2 then
		v2 = (1 - math.cos(v / 2 * 6.283185307179586 * 2)) * 0.5
	elseif v < 3 then
		v2 = 1
	elseif v < 3.9 then
		v2 = (v - 3) % 0.3 < 0.15 and 0 or 1
	else
		v2 = (1 - math.cos((v - 3.9) / 2 * 6.283185307179586 * 2)) * 0.5
	end

	return NumberSequence.new(v2)
end

local Phantom = {}

function Phantom.simulate(_: number)
	return {
		main = colorSequence,
		mainTransparency = getTransparency()
	}
end

function Phantom.apply(parent)
	local v = {}
	local main = parent:FindFirstChildWhichIsA("UIGradient")
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

	if not main then
		main = Instance.new("UIGradient")
		main.Rotation = 90
		main.Parent = parent
		table.insert(v, main)
	end

	assert(main)
	return {
		main = main,
		cleanup = function()
			if color then
				main.Color = color
			end

			if transparency then
				main.Transparency = transparency
			end

			for _, v3 in v do
				v3:Destroy()
			end
		end
	}
end

return Phantom