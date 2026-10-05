local ColorSequenceUtils = require(script.Parent.Parent.ColorSequenceUtils)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(1, 1, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.new(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.new(1, 1, 0))
})
local total = 0
local OG = {}

function OG.simulate(p: number)
	total += p * 1
	return {
		main = ColorSequenceUtils.calculateColorSequence(colorSequence, total)
	}
end

function OG.apply(label)
	local v = {}

	local function modifyAndRestore(p, p2, p3)
		local v2 = p[p2]
		p[p2] = p3
		table.insert(v, 1, function()
			p[p2] = v2
		end)
	end

	local function useOrCreate(parent, className)
		local instance = parent:FindFirstChildWhichIsA(className)

		if not instance then
			instance = Instance.new(className)
			instance.Parent = parent
			table.insert(v, 1, function()
				instance:Destroy()
			end)
		end

		return instance
	end

	if label:IsA("TextLabel") then
		local color = Color3.new(1, 1, 1)
		local textColor3 = label.TextColor3
		label.TextColor3 = color
		local v2 = "TextColor3"
		table.insert(v, 1, function()
			label[v2] = textColor3
		end)
	end

	local main = label:FindFirstChildWhichIsA("UIGradient")

	if not main then
		main = Instance.new("UIGradient")
		main.Parent = label
		table.insert(v, 1, function()
			main:Destroy()
		end)
	end

	local colors = label:FindFirstChildWhichIsA("UIStroke")

	if not colors then
		colors = Instance.new("UIStroke")
		colors.Parent = label
		table.insert(v, 1, function()
			colors:Destroy()
		end)
	end

	local stroke = colors:FindFirstChildWhichIsA("UIGradient")

	if not stroke then
		stroke = Instance.new("UIGradient")
		stroke.Parent = colors
		table.insert(v, 1, function()
			stroke:Destroy()
		end)
	end

	local color = Color3.new(0, 0, 0)
	local color2 = colors.Color
	colors.Color = color
	local v4 = "Color"
	table.insert(v, 1, function()
		colors[v4] = color2
	end)
	local rotation = main.Rotation
	main.Rotation = 90
	local v5 = "Rotation"
	table.insert(v, 1, function()
		main[v5] = rotation
	end)
	local numberSequence = NumberSequence.new(0)
	local transparency = main.Transparency
	main.Transparency = numberSequence
	local v6 = "Transparency"
	table.insert(v, 1, function()
		main[v6] = transparency
	end)
	local rotation2 = stroke.Rotation
	stroke.Rotation = 90
	local v7 = "Rotation"
	table.insert(v, 1, function()
		stroke[v7] = rotation2
	end)
	local numberSequence2 = NumberSequence.new(0)
	local transparency2 = stroke.Transparency
	stroke.Transparency = numberSequence2
	local v8 = "Transparency"
	table.insert(v, 1, function()
		stroke[v8] = transparency2
	end)
	return {
		main = main,
		stroke = stroke,
		cleanup = function()
			for _, v9 in v do
				v9()
			end
		end
	}
end

return OG