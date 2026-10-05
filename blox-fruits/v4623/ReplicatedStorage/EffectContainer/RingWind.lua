local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local models = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models")
local util = ReplicatedStorage:WaitForChild("Util")
require(util:WaitForChild("Tween"))
local Queue = require(ReplicatedStorage:WaitForChild("Queue"))

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local ringWind = Queue.new("RingWind", function(object, p, data, _)
	if data.time > data.duration then
		data.ring:Destroy()
		object:remove(p)
	else
		local v = data.time / data.duration
		local ring = data.ring
		local v2 = data.transparency[1]
		ring.Transparency = v2 + (data.transparency[2] - v2) * v
		data.ring.Size = data.radius[1]:lerp(data.radius[2], v ^ 0.666)
		data.ring.CFrame = data.cframe * CFrame.Angles(-1.5707963267948966, 0, 0) + data.offset * v
	end
end, 250, 0.0013333333333333333)
return function(data)
	local offset = data.Offset or createVector(0, 0, 0)
	local radius = data.Radius or { 1, 5 }
	local transparency = data.Transparency or { 0, 1 }
	local cFrame = data.CFrame or CFrame.new()
	local color = data.Color or Color3.new(1, 1, 1)
	local duration = data.Duration or 1
	local clone = models.CurvedRing:Clone()
	clone.Color = color
	clone.Transparency = transparency[1]
	clone.Size = createVector(1, 0.1, 1) * radius[1]
	clone.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone.Parent = _WorldOrigin
	radius[1] *= createVector(1, 0.1, 1)
	radius[2] *= createVector(1, 0.1, 1)
	ringWind:add({
		ring = clone,
		radius = radius,
		offset = offset,
		cframe = cFrame,
		transparency = transparency,
		duration = duration
	})
end