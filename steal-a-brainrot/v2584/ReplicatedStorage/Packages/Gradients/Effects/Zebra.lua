local ColorSequenceUtils = require(script.Parent.Parent.ColorSequenceUtils)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
	ColorSequenceKeypoint.new(0.015625, Color3.new(1, 1, 1)),
	ColorSequenceKeypoint.new(0.1458333283662796, Color3.new(1, 1, 1)),
	ColorSequenceKeypoint.new(0.2482638955116272, Color3.new(1, 1, 1)),
	ColorSequenceKeypoint.new(0.3559027910232544, Color3.new(1, 1, 1)),
	ColorSequenceKeypoint.new(0.4970000088214874, Color3.new(1, 1, 1)),
	ColorSequenceKeypoint.new(0.503000020980835, Color3.new(0, 0, 0)),
	ColorSequenceKeypoint.new(0.647569477558136, Color3.new(0, 0, 0)),
	ColorSequenceKeypoint.new(0.7829861044883728, Color3.new(0, 0, 0)),
	ColorSequenceKeypoint.new(0.890625, Color3.new(0, 0, 0)),
	ColorSequenceKeypoint.new(0.9774305820465088, Color3.new(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
})
local total = 0
local Zebra = {}

function Zebra.simulate(p: number)
	total += p * 0.5
	return {
		main = ColorSequenceUtils.calculateColorSequence(colorSequence, total),
		stroke = ColorSequenceUtils.calculateColorSequence(colorSequence, total + 0.5)
	}
end

function Zebra.apply(label)
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

	local parent2 = label:FindFirstChildWhichIsA("UIStroke")

	if not parent2 then
		parent2 = Instance.new("UIStroke")
		parent2.Parent = label
		table.insert(v, 1, function()
			parent2:Destroy()
		end)
	end

	local stroke = parent2:FindFirstChildWhichIsA("UIGradient")

	if not stroke then
		stroke = Instance.new("UIGradient")
		stroke.Parent = parent2
		table.insert(v, 1, function()
			stroke:Destroy()
		end)
	end

	local color = Color3.new(1, 1, 1)
	local color2 = parent2.Color
	parent2.Color = color
	local v5 = "Color"
	table.insert(v, 1, function()
		parent2[v5] = color2
	end)

	if parent2.StrokeSizingMode ~= Enum.StrokeSizingMode.ScaledSize then
		local thickness = parent2.Thickness
		parent2.Thickness = 1
		local v6 = "Thickness"
		table.insert(v, 1, function()
			parent2[v6] = thickness
		end)
	end

	local transparency = parent2.Transparency
	parent2.Transparency = 0
	local v6 = "Transparency"
	table.insert(v, 1, function()
		parent2[v6] = transparency
	end)
	local thicknessChangedConnection = parent2:GetPropertyChangedSignal("Thickness"):Connect(function()
		if parent2.Thickness ~= 1 and parent2.StrokeSizingMode ~= Enum.StrokeSizingMode.ScaledSize then
			parent2.Thickness = 1
		end
	end)
	local rotation = main.Rotation
	main.Rotation = 90
	local v7 = "Rotation"
	table.insert(v, 1, function()
		main[v7] = rotation
	end)
	local numberSequence = NumberSequence.new(0)
	local transparency2 = main.Transparency
	main.Transparency = numberSequence
	local v8 = "Transparency"
	table.insert(v, 1, function()
		main[v8] = transparency2
	end)
	local rotation2 = stroke.Rotation
	stroke.Rotation = 90
	local v9 = "Rotation"
	table.insert(v, 1, function()
		stroke[v9] = rotation2
	end)
	local numberSequence2 = NumberSequence.new(0)
	local transparency3 = stroke.Transparency
	stroke.Transparency = numberSequence2
	local v10 = "Transparency"
	table.insert(v, 1, function()
		stroke[v10] = transparency3
	end)
	return {
		main = main,
		stroke = stroke,
		cleanup = function()
			thicknessChangedConnection:Disconnect()

			for _, v11 in v do
				v11()
			end
		end
	}
end

return Zebra