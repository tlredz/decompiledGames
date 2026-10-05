local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Assets")
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
local Util = require(ReplicatedStorage.Util)
local Pool = require(ReplicatedStorage.Pool)
local misc = Util.Misc
local _ = Util.DistributedLoop
local tween = Util.Tween
local v = {}
local v2 = {}
local v3 = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))

function v2.new(attachment, value, p, root, ID)
	local v4

	if attachment then
		if typeof(attachment) == "Instance" then
			v4 = attachment:IsA("Attachment")
		else
			v4 = false
		end
	else
		v4 = attachment
	end

	assert(v4, string.format("Please make sure that the core is an Attachment"))
	local direction = p or not root and createVector(0, 0, -1) or root.Position - attachment.WorldPosition
	local attachment2 = Instance.new("Attachment")
	attachment2.CFrame = CFrame.new(Vector3.new(), direction) + attachment.WorldPosition
	local clone = dough.Beams.Strip:Clone()
	clone.Enabled = false
	clone.Attachment0 = attachment
	clone.Attachment1 = attachment2
	clone.Width0 = 0
	clone.Width1 = 0
	clone.Parent = attachment2
	local random = Random.new()
	local object = setmetatable({
		LastUpdate = tick(),
		Root = root,
		ID = ID,
		Scale = value or 1,
		Core = attachment,
		Beam = clone,
		Attachment = attachment2,
		Direction = direction,
		Angle = 0,
		Speed = random:NextNumber(0.75, 1),
		BeamDirection = random:NextNumber(-1, 1)
	}, {
		__index = v2
	})
	object:scale(object.Scale)
	attachment2.Parent = workspace.Terrain

	if object.ID then
		v[object.ID] = object
	elseif object.Root then
		v[object.Root] = object
	end

	v3:add(object)
	return object
end

function v2:scale(p)
	local scale = p or self.Scale
	self.Scale = scale
	self.Beam.Width0 = scale * 1.25
end

function v2:fire(point, value, stick, callback)
	if self.Destroying then
		return
	end

	self.Fired = nil
	self.Firing = nil
	self.Beam.Enabled = true
	self.Length = 0
	self.Stick = stick

	if not self.Stick then
		local attachment = Instance.new("Attachment")
		attachment.CFrame = self.Core.WorldCFrame
		attachment.Parent = workspace.Terrain
		self.Core = attachment
		self.Beam.Attachment0 = self.Core
	end

	self.Firing = {
		Start = tick(),
		Point = point,
		Duration = value or 1,
		Callback = callback
	}
end

function v2:Destroy(value)
	if self.Destroying then
		return
	end

	local scale = self.Scale
	local keypoints = self.Beam.Transparency.Keypoints
	local cFrame = self.Core.CFrame
	self.Destroying = {
		Start = tick(),
		CFrame = cFrame,
		Duration = value or 0.5,
		Scale = scale,
		Keypoints = keypoints
	}
end

v3:setAction(function(object, p)
	local now = tick()
	local __getCount = object:__getCount()

	for _, v4 in pairs(object.Pool) do
		local v5 = now - v4.LastUpdate

		if not (0.016666666666666666 * (__getCount / 12 - 1) <= v5) then
			continue
		end

		if v4.Destroyed then
			if not v4.Stick then
				v4.Core:Destroy()
			end

			v4.Attachment:Destroy()

			if v4.ID then
				v[v4.ID] = nil
			elseif v4.Root then
				v[v4.Root] = nil
			end

			object:remove(v4)
		elseif v4.Fired or v4.Destroying then
			local angle = v4.Angle
			local v6 = v4.Scale / 2 * math.sin(angle)
			local v7 = v4.Scale / 2 * math.cos(angle)

			if v4.Fired then
				if v4.Fired.Destroy then
					v4.Beam.CurveSize0 = v4.BeamDirection * v6
					v4.Beam.CurveSize1 = v4.BeamDirection * v7
				else
					v4.Beam.CurveSize0 = v4.BeamDirection * v6
					v4.Beam.CurveSize1 = v4.BeamDirection * v7 * 0.1
				end
			end

			if v4.Destroying then
				local v8 = math.min(1, (now - v4.Destroying.Start) / v4.Destroying.Duration)
				local quad = tween.ease.out.quad(v8, 0, 1, 1)
				v4:scale(tween.ease.out.quad(v8, 1, -1, 1) * v4.Destroying.Scale)
				local lerpKeypoints = misc.LerpKeypoints(v4.Destroying.Keypoints, 1, quad)
				v4.Beam.Transparency = NumberSequence.new(lerpKeypoints)

				if not v4.Stick then
					v4.Core.CFrame = v4.Destroying.CFrame + v4.Direction * v4.Length * quad
				end

				if v8 == 1 then
					v4.Destroyed = true
				end
			end

			v4.Angle = v4.Angle % 6.283185307179586 + 6.283185307179586 * v4.Speed * p
		elseif v4.Firing then
			local v6 = math.min(1, (now - v4.Firing.Start) / v4.Firing.Duration)
			local angle = v4.Angle

			if v4.Root then
				local v7 = v4.Root.Position - v4.Core.WorldPosition
				v4.Length = v7.Magnitude
				v4.Direction = v7.Unit
			elseif v4.Firing.Point then
				local v7 = v4.Firing.Point - v4.Core.WorldPosition
				v4.Length = v7.Magnitude
				v4.Direction = v7.Unit
			end

			local v7 = v4.Length * v6
			local v8 = v4.Scale / 2 * math.sin(angle)
			local v9 = v4.Scale / 2 * math.cos(angle)
			v4.Attachment.CFrame = CFrame.new(Vector3.new(), v4.Direction) * CFrame.new(0, 0, -v7) + v4.Core.WorldPosition
			v4.Beam.CurveSize0 = v4.BeamDirection * v8
			v4.Beam.CurveSize1 = v4.BeamDirection * v9
			v4.Angle = v4.Angle % 6.283185307179586 + 6.283185307179586 * v4.Speed * p

			if v6 == 1 then
				local destroy = false

				if v4.Root and v4.Attachment.Parent then
					v4.Attachment.WorldPosition = Vector3.new()
					v4.Attachment.Parent = v4.Root
				end

				if v4.Firing.Callback then
					destroy = v4.Firing.Callback()
				end

				v4.Speed = Random.new():NextNumber(0.75, 2)
				v4.Fired = {
					Start = now,
					Destroy = destroy
				}
			end
		end
	end
end)
return (setmetatable({}, {
	__index = function(_, value)
		if value:lower() == "get" then
			return function(...)
				local v4 = { ... }
				local v5 = v4[1]

				if typeof(v5) == "table" then
					v5 = v4[2]
				end

				return v[v5]
			end
		end

		if v2[value] then
			return v2[value]
		end
	end
}))