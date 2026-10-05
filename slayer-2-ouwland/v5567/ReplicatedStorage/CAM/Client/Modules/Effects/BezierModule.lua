local createVector = vector.create

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local RunService = game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local class = {}
class.__index = class

local function GenerateBezier(points, start, p, p2)
	if #points == 3 then
		return quadBezier(p2, start, points[2], p)
	end

	local v = {}

	for i = 1, #points - 1 do
		local v2 = #v + 1
		local v3 = points[i]
		v[v2] = v3 + (points[i + 1] - v3) * p2
	end

	while #v > 1 do
		local v2 = {}

		for i = 1, #v - 1 do
			local v3 = #v2 + 1
			local v4 = v[i]
			v2[v3] = v4 + (v[i + 1] - v4) * p2
		end

		RunService.Heartbeat:Wait()
		v = v2
	end

	return v[1]
end

function class:CreatePoint(p)
	local part = Instance.new("Part", self.Parent)
	part.Name = "Point_" .. self.PointCount
	self.PointCount += 1

	if self.Debug then
		part.Transparency = 0
	else
		part.Transparency = 1
	end

	part.Size = createVector(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	local midpoint = self:GenerateMidpoint()
	part.Position = midpoint
	part.CFrame = CFrame.new(midpoint, self.Start) * p
	table.remove(self.Points, #self.Points)
	table.insert(self.Points, part.Position)
	table.insert(self.Points, self.End)
	part:Destroy()
end

function class:GenerateMidpoint(_)
	return (self.Start + self.End) / 2
end

function class:GetDistance()
	return (self.End - self.Start).Magnitude
end

function class:Get(p)
	return (GenerateBezier(self.Points, self.Start, self.End, p))
end

function class:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

function class:Play(callback)
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt / self:GetDistance() * self.Speed

		if callback then
			if callback(self:Get(total)) then
				heartbeatConnection:Disconnect()
				self:Destroy()
				return
			end
		else
			warn("Bezier Curve Module: No Function was given!")
		end

		if total >= 1 then
			heartbeatConnection:Disconnect()
			self:Destroy()
		end
	end)
end

return {
	new = function(points)
		return (setmetatable({
			Points = points,
			Parent = workspace,
			Speed = 50,
			PointCount = 1,
			Start = points[1],
			End = points[#points]
		}, class))
	end
}