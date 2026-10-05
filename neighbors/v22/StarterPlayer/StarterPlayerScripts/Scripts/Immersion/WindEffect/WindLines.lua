local createVector = vector.create
local RunService = game:GetService("RunService")
local terrain = workspace:FindFirstChildOfClass("Terrain")
local v = {}
local WindLines = {
	UpdateQueue = table.create(10)
}

function WindLines.Init(_, data)
	WindLines.Lifetime = data.Lifetime or 3
	WindLines.Direction = data.Direction or createVector(1, 0, 0)
	WindLines.Speed = data.Speed or 6
	WindLines.Enabled = true

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
	WindLines.UpdateConnection = RunService.Heartbeat:Connect(function()
		local now = os.clock()

		if v2 < now - WindLines.LastSpawned and WindLines.Enabled then
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
				local position = v4.Position
				v4.Attachment0.WorldPosition = (CFrame.new(position, position + v4.Direction) * CFrame.new(
					0,
					0,
					v4.Speed * -v5
				)).Position + Vector3.new(math.sin(v6) * 0.5, math.sin(v6) * 0.8, math.sin(v6) * 0.5)
				v4.Attachment1.WorldPosition = v4.Attachment0.WorldPosition + createVector(0, 0.1, 0)
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
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.2, 1),
		NumberSequenceKeypoint.new(0.8, 1),
		NumberSequenceKeypoint.new(1, 0.3)
	})
	trail.Transparency = NumberSequence.new(0.7)
	trail.FaceCamera = true
	trail.Parent = attachment
	attachment.WorldPosition = position
	attachment2.WorldPosition = position + createVector(0, 0.1, 0)
	local v3 = {
		Attachment0 = attachment,
		Attachment1 = attachment2,
		Trail = trail,
		Lifetime = lifetime + math.random(-10, 10) * 0.1,
		Position = position,
		Direction = direction,
		Speed = speed + math.random(-10, 10) * 0.1,
		StartClock = os.clock(),
		Seed = math.random(1, 1000) * 0.1
	}
	WindLines.UpdateQueue[#WindLines.UpdateQueue + 1] = v3
	attachment.Parent = terrain
	attachment2.Parent = terrain
	debug.profileend()
end

return WindLines