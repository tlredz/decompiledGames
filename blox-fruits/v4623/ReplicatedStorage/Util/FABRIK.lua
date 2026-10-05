local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local FABRIK = {}

function sum(list)
	local total = 0

	for _, v in ipairs(list) do
		total += v
	end

	return total
end

local clones = {}
local RunService = game:GetService("RunService")
local part, model

if RunService:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	part = Instance.new("Part")
	assert(part, "bad part")
	part.Material = Enum.Material.Plastic
	part.Anchored = true
	part.CanCollide = false
	part.BrickColor = BrickColor.Blue()
	model = Instance.new("Model", game.Workspace)
else
	part = nil
	model = nil
end

function drawline(p, p2, p3)
	assert(part, "bad part")

	if not clones[p] then
		clones[p] = part:Clone()
		clones[p].Parent = model
	end

	clones[p].Size = Vector3.new(0.2, 0.2, p3.magnitude)
	clones[p].CFrame = CFrame.new(p2 + p3 / 2, p2 + p3)
	return clones[p]
end

function FABRIK.new(joints, target)
	local self = setmetatable({}, {
		__index = FABRIK
	})
	local magnitudes = {}

	for i = 1, #joints - 1 do
		magnitudes[i] = (joints[i] - joints[i + 1]).magnitude
	end

	self.n = #joints
	self.tolerance = 0.1
	self.target = target
	self.joints = joints
	self.lengths = magnitudes
	self.origin = joints[1]
	self.totallength = sum(magnitudes)
	self.constrained = false
	self.left = 1.5707963267948966
	self.right = 1.5707963267948966
	self.up = 1.5707963267948966
	self.down = 1.5707963267948966
	return self
end

function FABRIK:constrain(vector, p, object)
	local v = vector:Dot(p) / p.magnitude
	local v2 = v * p.unit
	local v3 = {
		object:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top)),
		object:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Bottom))
	}
	local v4 = {
		object:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Right)),
		object:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Left))
	}
	table.sort(v3, function(a, b)
		return (a - vector).magnitude < (b - vector).magnitude
	end)
	table.sort(v4, function(a, b)
		return (a - vector).magnitude < (b - vector).magnitude
	end)
	local v5 = v3[1]
	local v6 = v4[1]
	local vector2 = vector - v2

	if v < 0 then
		v2 = -v2
	end

	local dot = vector2:Dot(v6)
	local dot2 = vector2:Dot(v5)
	local v7 = -(v2.magnitude * math.tan(self.left))
	local v8 = v2.magnitude * math.tan(self.right)
	local v9 = v2.magnitude * math.tan(self.up)
	local v10 = -(v2.magnitude * math.tan(self.down))

	if dot >= 0 then
		v7 = v8 or v7
	end

	if dot2 >= 0 then
		v10 = v9 or v10
	end

	local v11

	if dot ^ 2 / v7 ^ 2 + dot2 ^ 2 / v10 ^ 2 <= 1 then
		v11 = v >= 0
	else
		v11 = false
	end

	if v11 then
		return vector
	end

	local v12 = math.atan2(dot2, dot)
	local v13 = v7 * math.cos(v12)
	local v14 = v10 * math.sin(v12)
	vector = (v2 + v6 * v13 + v5 * v14).unit * vector.magnitude
	return vector
end

function FABRIK:backward()
	self.joints[self.n] = self.target

	for i = self.n - 1, 1, -1 do
		local v = self.joints[i + 1] - self.joints[i]
		local v2 = self.lengths[i] / v.magnitude
		local v3 = (1 - v2) * self.joints[i + 1] + v2 * self.joints[i]
		self.joints[i] = v3
	end
end

function FABRIK:forward()
	self.joints[1] = self.origin
	local unit = (self.joints[2] - self.joints[1]).unit

	for i = 1, self.n - 1 do
		local v = self.joints[i + 1] - self.joints[i]
		local v2 = self.lengths[i] / v.magnitude
		local cframe = CFrame.new(self.joints[i], self.joints[i] + unit)
		local v3 = (1 - v2) * self.joints[i] + v2 * self.joints[i + 1]
		local constrain = self:constrain(v3 - self.joints[i], unit, cframe)
		local joints = self.joints
		local v4 = i + 1

		if self.constrained then
			v3 = self.joints[i] + constrain or v3
		end

		joints[v4] = v3
		unit = self.joints[i + 1] - self.joints[i]
	end
end

function FABRIK:solve()
	local magnitude = (self.joints[1] - self.target).magnitude

	if self.totallength < magnitude then
		for i = 1, self.n - 1 do
			local magnitude2 = (self.target - self.joints[i]).magnitude
			local v = self.lengths[i] / magnitude2
			self.joints[i + 1] = (1 - v) * self.joints[i] + v * self.target
		end

		self:backward()
		self:forward()
	else
		local count = 0
		local magnitude2 = (self.joints[self.n] - self.target).magnitude

		if magnitude2 < self.tolerance and magnitude then
			magnitude2 = magnitude
		end

		while self.tolerance < magnitude2 do
			self:backward()
			self:forward()
			count += 1

			if count > 10 then
				break
			end
		end
	end
end

return FABRIK