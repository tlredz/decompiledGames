local createVector = vector.create
local RunService = game:GetService("RunService")
local terrain = workspace.Terrain
local Global = require(game.ReplicatedStorage.Global)
local v = {}
local WindLines = {
	UpdateQueue = table.create(15)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function WaveFunction(p)
	local v2 = math.sin(p)
	return (Vector3.new(v2 * 0.5, v2 * 0.8, v2 * 0.5))
end

function WindLines.Init(_, data)
	WindLines.Lifetime = data.Lifetime or 3
	WindLines.Direction = data.Direction or createVector(1, 0, 0)
	WindLines.Speed = data.Speed or 6

	if WindLines.UpdateConnection then
		WindLines.UpdateConnection:Disconnect()
		WindLines.UpdateConnection = nil
	end

	for _, v2 in ipairs(WindLines.UpdateQueue) do
		v2.Attachment0:Destroy()
		v2.Attachment1:Destroy()
		v2.Trail:Destroy()
	end

	table.clear(WindLines.UpdateQueue)
	WindLines.LastSpawned = os.clock()
	local v2 = 1 / (data.SpawnRate or 25)
	WindLines.UpdateConnection = RunService.RenderStepped:Connect(function()
		local now = os.clock()

		if v2 < now - WindLines.LastSpawned and Global.CurrentLocation ~= "Tiki Outpost" and Global.CurrentLocation ~= "Frozen Dimension" then
			WindLines:Create()
			WindLines.LastSpawned = now
		end

		debug.profilebegin("Wind Lines")

		for i, v4 in ipairs(WindLines.UpdateQueue) do
			local v5 = now - v4.StartClock

			if v4.Lifetime <= v5 then
				v4.Attachment0:Destroy()
				v4.Attachment1:Destroy()
				v4.Trail:Destroy()
				local count = #WindLines.UpdateQueue
				WindLines.UpdateQueue[i] = WindLines.UpdateQueue[count]
				WindLines.UpdateQueue[count] = nil
			else
				v4.Trail.MaxLength = 20 - 20 * (v5 / v4.Lifetime)
				local v6 = (now + v4.Seed) * (v4.Speed * 0.2)
				local attachment0 = v4.Attachment0
				attachment0.Position = v4.CFrame * Vector3.new(0, 0, v4.Speed * -v5) + WaveFunction(v6)
				v4.Attachment1.Position = v4.Attachment0.Position + createVector(0, 0.15, 0)
			end
		end

		debug.profileend()
	end)
end

function WindLines.Cleanup(_)
	if WindLines.UpdateConnection then
		WindLines.UpdateConnection:Disconnect()
		WindLines.UpdateConnection = nil
	end

	for _, v2 in ipairs(WindLines.UpdateQueue) do
		v2.Attachment0:Destroy()
		v2.Attachment1:Destroy()
		v2.Trail:Destroy()
	end

	table.clear(WindLines.UpdateQueue)
end

function WindLines:Create(p)
	debug.profilebegin("Add Wind Line")
	local v2 = p or v
	local lifetime = v2.Lifetime or WindLines.Lifetime
	local position = v2.Position or workspace.CurrentCamera.CFrame * CFrame.Angles(
		math.rad((math.random(-30, 70))),
		math.rad((math.random(-80, 80))),
		0
	) * CFrame.new(0, 0, math.random(200, 600) * -0.1).Position
	local direction = v2.Direction or WindLines.Direction
	local speed = v2.Speed or WindLines.Speed

	if speed <= 0 then
		return
	end

	local attachment = Instance.new("Attachment")
	local attachment2 = Instance.new("Attachment")
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.33, 1),
		NumberSequenceKeypoint.new(0.66, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.33, 0.33),
		NumberSequenceKeypoint.new(0.66, 0.33),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.FaceCamera = true
	trail.Parent = attachment
	local v3 = {
		Attachment0 = attachment,
		Attachment1 = attachment2,
		Trail = trail,
		Lifetime = lifetime + math.random(-10, 10) * 0.1,
		CFrame = CFrame.new(position, position + direction),
		Speed = speed + math.random(-10, 10) * 0.1,
		StartClock = os.clock(),
		Seed = math.random(1, 1000) * 0.1
	}
	local v4 = (os.clock() + v3.Seed) * (v3.Speed * 0.2)
	local _ = v3.Position
	local attachment0 = v3.Attachment0
	attachment0.Position = v3.CFrame.Position + WaveFunction(v4)
	v3.Attachment1.Position = v3.Attachment0.Position + createVector(0, 0.15, 0)
	WindLines.UpdateQueue[#WindLines.UpdateQueue + 1] = v3
	attachment.Parent = terrain
	attachment2.Parent = terrain
	debug.profileend()
end

return WindLines