local terrain = workspace:WaitForChild("Terrain")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local travelTrail = FX:WaitForChild("TravelTrail")

local function Routine(p, fn)
	local lastTime = tick()
	local v = false

	while tick() - lastTime < p do
		local v2 = tick() - lastTime

		if fn(v2, v2 / p) then
			v = true
			break
		else
			RunService.RenderStepped:Wait()
		end
	end

	if not v then
		fn(p, 1)
	end
end

local function TrailObject(direction, width)
	local attachments = {}
	local attachment = Instance.new("Attachment")
	attachment.CFrame = direction
	table.insert(attachments, attachment)
	local attachment2 = Instance.new("Attachment")
	attachment2.CFrame = direction
	table.insert(attachments, attachment2)
	local clone = travelTrail:Clone()
	local attachment4 = attachments[1]
	local attachment5 = attachments[2]
	clone.Attachment0 = attachment4
	clone.Attachment1 = attachment5
	return {
		Attachments = attachments,
		Trail = clone,
		SetParent = function(self)
			self.Trail.Parent = terrain

			for _, attachment3 in next, self.Attachments, nil do
				attachment3.Parent = terrain
			end
		end,
		Orientate = function(self, p2)
			for k, attachment3 in next, self.Attachments, nil do
				local v4 = k == 1 and 1 or -1
				attachment3.CFrame = p2 * CFrame.new(v4 * width, 0, 0)
			end
		end,
		Destroy = function(self)
			self.Trail:Destroy()

			for _, attachment3 in next, self.Attachments, nil do
				attachment3:Destroy()
			end
		end
	}
end

return function(data)
	local color = data.Color or Color3.new(1, 1, 1)
	local direction = data.Direction or CFrame.new()
	local travelSpeed = data.TravelSpeed or 100
	local travelDistance = data.TravelDistance or 100
	local area = data.Area or 3
	local area2 = data.Area or 8
	local width = data.Width or 0.1
	local v = {}

	for _ = 1, area2 do
		local cframe = CFrame.new(
			math.random(-area2 / area, area2 / area),
			math.random(-area2 / area, area2 / area),
			math.random(-area2 / (area * 3), area2 / (area * 3))
		)
		local speed = math.random(travelSpeed * 0.75, travelSpeed)
		local object = TrailObject(direction, width)
		object.Trail.Color = ColorSequence.new(color)
		object.Trail.Lifetime = travelDistance / speed * 0.15
		object:Orientate(direction)
		object:SetParent(terrain)
		table.insert(v, {
			Object = object,
			Origin = direction * cframe,
			Speed = speed,
			Distance = travelDistance
		})
	end

	Routine(travelDistance / (travelSpeed * 0.75) + 0.25, function(p)
		for _, v2 in next, v, nil do
			local v3 = v2.Distance / v2.Speed

			if v3 <= p then
				if v3 <= p - 0.25 then
					v2.Object:Destroy()
				end
			else
				local v4 = p / v3
				v2.Object:Orientate(v2.Origin * CFrame.new(0, 0, -v2.Distance * v4))
			end
		end
	end)

	for _, v2 in next, v, nil do
		v2.Object:Destroy()
	end
end