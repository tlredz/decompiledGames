local ColorSequenceUtils = require(script.Parent.Parent.ColorSequenceUtils)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
	ColorSequenceKeypoint.new(0.1510416716337204, Color3.new(0, 1, 0)),
	ColorSequenceKeypoint.new(0.3072916567325592, Color3.new(1, 0, 0)),
	ColorSequenceKeypoint.new(0.4965277910232544, Color3.new(0, 1, 0)),
	ColorSequenceKeypoint.new(0.6649305820465088, Color3.new(1, 0, 0)),
	ColorSequenceKeypoint.new(0.8385416865348816, Color3.new(0, 1, 0)),
	ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
})
local total = 0
local GreenRed = {}

function GreenRed.simulate(p: number)
	total += p * 0.5
	return {
		main = ColorSequenceUtils.calculateColorSequence(colorSequence, total)
	}
end

function GreenRed.apply(parent)
	local v = {}
	local main = parent:FindFirstChildWhichIsA("UIGradient")
	local color

	if main then
		color = main.Color
	else
		color = nil
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
			if color then
				main.Color = color
			end

			for _, v3 in v do
				v3:Destroy()
			end
		end
	}
end

return GreenRed