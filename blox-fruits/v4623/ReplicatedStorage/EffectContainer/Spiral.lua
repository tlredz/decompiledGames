local terrain = workspace.Terrain
local service = game:service("ReplicatedStorage")
local FX = require(service:WaitForChild("FX"))
local Util = require(service:WaitForChild("Util"))
local tween = Util.Tween
local Queue = require(service:WaitForChild("Queue"))
local _ = Util.Debris

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local spiral = Queue.new("Spiral", function(object, p, data, _)
	local cycles = data.cycles
	local direction = data.direction
	local radius = data.radius
	local length = data.length
	local anchor = data.anchor
	local cframe = data.cframe
	local width = data.width
	local a = data.a
	local b = data.b
	local ease = data.ease
	local start = data.start

	if data.time < data.duration then
		local v = ease(math.min(data.duration, tick() - start), 0, 1, data.duration)
		local v2 = math.sin(direction * 3.141592653589793 * 2 * cycles * v)
		local v3 = math.cos(direction * 3.141592653589793 * 2 * cycles * v)
		local v4 = lerpNumber(radius[1], radius[2], v)
		local v5 = lerpNumber(length[1], length[2], v)
		local cframe2 = CFrame.new(v4 * v2, v5, v4 * v3)

		if anchor then
			a.CFrame = anchor.CFrame * cframe
		else
			a.CFrame = cframe
		end

		b.CFrame = a.CFrame
		local cFrame = a.CFrame * CFrame.new(width) * cframe2
		local cFrame2 = b.CFrame * CFrame.new(-width) * cframe2
		a.CFrame = cFrame
		b.CFrame = cFrame2
	elseif data.time > data.duration + 1.5 then
		a:Destroy()
		b:Destroy()
		object:remove(p)
	end
end)
return function(data)
	local anchor = data.Anchor
	local cFrame = data.CFrame or CFrame.new()
	local radius = data.Radius or { 1, 2 }
	local length = data.Length or { 0, 1 }
	local cycles = data.Cycles or 1
	local vector = Vector3.new(data.Width or 0.4, 0, 0)
	local direction = data.Direction or math.random(1, 2) == 1 and 1 or -1
	local color = data.Color or Color3.new(1, 1, 1)
	local duration = data.Duration or 1
	local clone = FX:WaitForChild("SpiralTrail"):Clone()
	clone.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color) })
	local attachment = Instance.new("Attachment")
	local attachment2 = Instance.new("Attachment")

	if anchor then
		local cFrame2 = anchor.CFrame * cFrame
		local cFrame3 = anchor.CFrame * cFrame
		attachment.CFrame = cFrame2
		attachment2.CFrame = cFrame3
	else
		attachment.CFrame = cFrame
		attachment2.CFrame = cFrame
	end

	local cFrame4 = attachment.CFrame * CFrame.new(vector)
	local cFrame5 = attachment2.CFrame * CFrame.new(-vector)
	attachment.CFrame = cFrame4
	attachment2.CFrame = cFrame5
	clone.Attachment0 = attachment
	clone.Attachment1 = attachment2
	clone.Parent = attachment
	attachment.Parent = terrain
	attachment2.Parent = terrain
	spiral:add({
		duration = duration,
		start = tick(),
		ease = tween.ease.out.sine,
		length = length,
		cycles = cycles,
		direction = direction,
		anchor = anchor,
		a = attachment,
		b = attachment2,
		width = vector,
		radius = radius,
		cframe = cFrame
	})
end