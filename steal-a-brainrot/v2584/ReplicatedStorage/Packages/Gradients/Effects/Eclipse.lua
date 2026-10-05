game:GetService("RunService")
local color = Color3.fromRGB(42, 37, 66)
local color2 = Color3.fromRGB(255, 219, 111)
local colorSequences = {}
local v = {}
local mainRotation = 0

local function getSequence(p: number)
	local v3 = colorSequences[p]

	if v3 then
		return v3
	end

	local v4 = p / 512 / 2
	local v5 = 0.5 - v4
	local v6 = v4 + 0.5
	local colorSequenceKeypoints = {}

	if v5 > 0 then
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(0, color))
	end

	for i = 0, 12 do
		local v7 = i / 12
		table.insert(
			colorSequenceKeypoints,
			ColorSequenceKeypoint.new(v5 + (v6 - v5) * v7, color:Lerp(color2, v7 * v7 * (3 - v7 * 2)))
		)
	end

	if v6 < 1 then
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(1, color2))
	end

	local colorSequence = ColorSequence.new(colorSequenceKeypoints)
	colorSequences[p] = colorSequence
	return colorSequence
end

local function updateLabel(p)
	local parent = p.Parent

	if not (parent and parent:IsA("GuiObject")) then
		return
	end

	local absoluteSize = parent.AbsoluteSize
	local vector

	if parent:IsA("TextLabel") and parent.TextBounds.X > 0 then
		vector = Vector2.new(
			math.min(absoluteSize.X, parent.TextBounds.X),
			(math.min(absoluteSize.Y, parent.TextBounds.Y))
		)
	else
		vector = absoluteSize
	end

	local v3 = math.rad(mainRotation)
	local v4 = math.abs((math.cos(v3)))
	local v5 = math.abs((math.sin(v3)))
	local v6 = math.min(
		not (v4 > 1e-6) and 1e999 or absoluteSize.X / 2 / v4,
		not (v5 > 1e-6) and 1e999 or absoluteSize.Y / 2 / v5
	)
	local v7 = math.min(absoluteSize.Y, vector.X) / 2
	local v8 = not (v6 > 0 and v6 < 1e999) and 512 or math.clamp(math.ceil(v7 / v6 * 512), 1, 512)

	if v[p] ~= v8 then
		v[p] = v8
		p.Color = getSequence(v8)
	end
end

local Eclipse = {}

function Eclipse.simulate(_: number)
	mainRotation = workspace:GetServerTimeNow() % 6 / 6 * 360
	return {
		mainRotation = mainRotation,
		perLabel = updateLabel
	}
end

function Eclipse.apply(parent)
	local v3 = {}
	local main = parent:FindFirstChildWhichIsA("UIGradient")
	local color3

	if main then
		color3 = main.Color
	else
		color3 = nil
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
		main.Parent = parent
		table.insert(v3, main)
	end

	assert(main)
	main.Color = getSequence(256)
	main.Transparency = NumberSequence.new(0)
	main.Offset = Vector2.zero
	return {
		main = main,
		cleanup = function()
			v[main] = nil

			if color3 then
				main.Color = color3
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

			for _, v5 in v3 do
				v5:Destroy()
			end
		end
	}
end

return Eclipse