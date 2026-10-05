local ColorSequenceUtils = require(script.Parent.Parent.ColorSequenceUtils)
local color = Color3.fromRGB(42, 37, 66)
local color2 = Color3.fromRGB(255, 219, 111)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, color),
	ColorSequenceKeypoint.new(0.15, color),
	ColorSequenceKeypoint.new(0.35, color2),
	ColorSequenceKeypoint.new(0.65, color2),
	ColorSequenceKeypoint.new(0.85, color),
	ColorSequenceKeypoint.new(1, color)
})
local EclipseWave = {}

function EclipseWave.simulate(_: number)
	return {
		main = ColorSequenceUtils.calculateColorSequence(colorSequence, workspace:GetServerTimeNow() * 0.25 % 1)
	}
end

function EclipseWave.apply(parent)
	local v = {}
	local main = parent:FindFirstChildWhichIsA("UIGradient")
	local color3

	if main then
		color3 = main.Color
	else
		color3 = nil
	end

	if not main then
		main = Instance.new("UIGradient")
		main.Parent = parent
		table.insert(v, main)
	end

	assert(main)
	return {
		main = main,
		cleanup = function()
			if color3 then
				main.Color = color3
			end

			for _, v3 in v do
				v3:Destroy()
			end
		end
	}
end

return EclipseWave