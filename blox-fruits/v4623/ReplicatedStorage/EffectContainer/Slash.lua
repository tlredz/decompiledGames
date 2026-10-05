local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local util = ReplicatedStorage:WaitForChild("Util")
local Tween = require(util:WaitForChild("Tween"))
local Queue = require(ReplicatedStorage:WaitForChild("Queue"))

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local new = CFrame.new
local angles = CFrame.Angles
local _ = math.clamp
local _ = math.min
local tick2 = tick
local next2 = next
local new2 = NumberSequence.new
local slash = Queue.new("Slash", function(object, p, data, _)
	local total = data.total
	local ease = data.ease
	local anchor = data.anchor
	local transparency = data.transparency
	local cframe = data.cframe
	local start = data.start

	if data.time < data.duration then
		for _, v in next2, total, nil do
			local v2 = tick2() - start
			local v3 = v2 / v.duration

			if v3 < 1 then
				local v4 = ease(v2, 0, 1, v.duration)
				local trail = v.trail
				local a = v.a
				local b = v.b
				local radius = v.radius
				local length = v.length
				local v5 = radius[1]
				local v6 = v5 + (radius[2] - v5) * v4
				local v7 = length[1]
				local v8 = v7 + (length[2] - v7) * v4
				local cframe2 = angles(0, v.direction * 3.141592653589793 * 2 * v.cycles * v3 + v.offset, 0)

				if anchor then
					a.CFrame = anchor.CFrame * cframe * cframe2 * new(0, v8, -v6)
				else
					a.CFrame = cframe * cframe2 * new(0, v8, -v6)
				end

				b.CFrame = a.CFrame * new(0, 0, v6 * 2)
				local widthMin = v.widthMin
				local width = widthMin + (v.widthMax - widthMin) * v4

				if v.direction == 1 then
					trail.Width0 = width
				else
					trail.Width1 = width
				end

				local curveSize = v6 * 1.3333333333333333
				local curveSize2 = -v6 * 1.3333333333333333
				trail.CurveSize0 = curveSize
				trail.CurveSize1 = curveSize2
				local v13 = transparency[1]
				trail.Transparency = new2(v13 + (transparency[2] - v13) * v3)
			elseif not v.killed then
				v.killed = true
				v.a:Destroy()
				v.b:Destroy()
				v.trail:Destroy()
			end
		end
	else
		for _, v in next2, total, nil do
			if v.killed then
				continue
			end

			v.a:Destroy()
			v.b:Destroy()
			v.trail:Destroy()
		end

		object:remove(p)
	end
end, 500, 0.001)
return function(state)
	local cycles = state.Cycles or { 1, 2 }
	local anchor = state.Anchor
	local cFrame = state.CFrame or CFrame.new()
	local color = state.Color or Color3.new(1, 1, 1)
	local duration = state.Duration or { 1, 1 }
	local transparency = state.Transparency or { 0, 1 }
	local radius = state.Radius or { 1, 2 }
	local length = state.Length or { 0, 1 }
	local width = state.Width or { 0, 10 }
	state.LengthOffset = state.LengthOffset or 0
	state.RadiusOffset = state.RadiusOffset or 0
	state.WidthOffset = state.WidthOffset or 0
	state.Repeat = state.Repeat or 1
	local total = {}

	for _ = 1, state.Repeat do
		local cycles2 = cycles[1] + (cycles[2] - cycles[1]) * math.random()
		local v3 = state.WidthOffset * math.random()
		local v4 = state.RadiusOffset * math.random()
		local v5 = state.LengthOffset * math.random()
		local widthMax = width[2] + v3
		local widthMin = width[1] + v3
		local direction = state.Direction or math.random(1, 2) == 1 and 1 or -1
		local radius2 = { radius[1] + v4, radius[2] + v4 }
		local length2 = { length[1] + v5, length[2] + v5 }
		local duration2 = duration[1] + (duration[2] - duration[1]) * math.random()
		local clone = FX:WaitForChild("Slash"):Clone()

		if state.LightEmission then
			clone.LightEmission = state.LightEmission
		end

		if state.Segments then
			clone.Segments = state.Segments
		end

		clone.Enabled = true
		clone.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color) })
		local attachment = Instance.new("Attachment")
		local attachment2 = Instance.new("Attachment")
		clone.Attachment0 = attachment
		clone.Attachment1 = attachment2

		if direction == 1 then
			clone.Width1 = 0
		elseif direction == -1 then
			clone.Width0 = 0
		end

		clone.Parent = _WorldOrigin
		local terrain = workspace.Terrain
		local terrain2 = workspace.Terrain
		attachment.Parent = terrain
		attachment2.Parent = terrain2
		table.insert(total, {
			trail = clone,
			a = attachment,
			b = attachment2,
			direction = direction,
			widthMin = widthMin,
			widthMax = widthMax,
			radius = radius2,
			length = length2,
			cycles = cycles2,
			duration = duration2,
			offset = 6.283185307179586 * math.random()
		})
	end

	local ease = state.Ease or Tween.ease.out.quad
	slash:add({
		renderPoint = cFrame.p,
		duration = math.max(duration[1], duration[2]),
		total = total,
		ease = ease,
		anchor = anchor,
		start = tick2(),
		transparency = transparency,
		cframe = cFrame
	})
end