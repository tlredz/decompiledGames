local terrain = workspace:WaitForChild("Terrain")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local weakHit = FX:WaitForChild("Hit"):WaitForChild("WeakHit")
local RenderDistance = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("RenderDistance"))
local v = {}

local function create(data, _)
	assert(data.Position, "position required")
	local position = data.Position
	local rays = data.Rays or math.random(4, 5)
	local length = data.Length or 5
	local duration = data.Duration or 0.35
	local clone = weakHit.Origin:Clone()
	clone.Position = position
	local cont = {}

	for _ = 1, rays do
		local clone2 = weakHit.Beam:Clone()
		local attachment = Instance.new("Attachment")
		clone2.Attachment0 = clone
		clone2.Attachment1 = attachment
		attachment.Parent = terrain
		clone2.Parent = terrain
		table.insert(cont, {
			Beam = clone2,
			Attachment = attachment,
			Length = length * (0.6 + math.random() * 0.4),
			Duration = duration * (0.6 + math.random() * 0.4),
			Dir = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).unit,
			Width = 0.2 * (0.75 + math.random() * 0.25)
		})
	end

	clone.Parent = terrain
	clone.Out:Emit(4)
	clone.RingInner:Emit(2)
	clone.Ring:Emit(1)
	table.insert(v, {
		RenderDistance = RenderDistance.new(position, 200, 240, 0.25),
		Origin = clone,
		Cont = cont,
		Length = length,
		Duration = duration,
		Start = tick()
	})
end

local RunService = game:GetService("RunService")
RunService:BindToRenderStep("WeakHitEffect", 10015, function(p)
	for k, v2 in pairs(v) do
		if tick() - v2.Start > math.max(0.5, v2.Duration) then
			for _, v3 in next, v2.Cont, nil do
				v3.Beam:Destroy()
				v3.Attachment:Destroy()
			end

			v2.Origin:Destroy()
			v[k] = nil
		elseif v2.RenderDistance:WithinRange(p) then
			for _, v3 in next, v2.Cont, nil do
				local v4 = math.min(1, (tick() - v2.Start) / v3.Duration)

				if v4 >= 1 then
					v3.Beam.Enabled = false
				else
					v3.Attachment.Position = v2.Origin.Position + v3.Dir * v3.Length * v4
					v3.Beam.Width0 = v3.Width * (1 - v4)
					v3.Beam.Width1 = v3.Beam.Width0
				end
			end
		end
	end
end)
return create