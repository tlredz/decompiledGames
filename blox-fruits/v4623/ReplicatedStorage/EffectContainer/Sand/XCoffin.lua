local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local sound = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
return function(p)
	local root = p.Root

	if not (root and root:IsDescendantOf(workspace)) then
		return
	end

	local v = 15 + root.Size.Y * 2

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	local v2 = {}

	for _ = 1, 4 do
		local clone = script.SandBall:Clone()
		clone.Parent = workspace._WorldOrigin
		table.insert(v2, { clone, (Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)) })
	end

	local lastTime = tick()
	local clone = script.Main.Attachment:Clone()
	clone.CFrame = CFrame.new()
	clone.Parent = root
	local v3 = sound:Play("Sand.sSlowImpact", clone)
	clone.Spiral.Enabled = true
	clone.PreBackground.Enabled = true
	clone.PreBackground.Speed = NumberRange.new(v / 2, v * 3)
	clone.PreBackground.Size = NumberSequence.new(v / 7.5, v / 2.5, v / 20)
	task.delay(2, function()
		lastTime = tick()

		for _, emitter in pairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	local lastTime2 = tick()
	local now = 0

	while tick() - lastTime2 < 2.5 do
		local v4 = ((tick() - lastTime2) / 2.5) ^ 0.25
		clone.Spiral.Size = NumberSequence.new(v * v4 * 1.5, 0)

		for _, list in pairs(v2) do
			local v5, v6 = unpack(list)
			v5.Size = createVector(1, 1, 1) * v4 * v * 0.85
			v5.CFrame = (root.CFrame + v6 * v / 10) * CFrame.Angles(v4 * 0.01, v4 * 0.01, v4 * 0.01)

			if not (tick() - now > 0.05 and v4 < 0.9) then
				continue
			end

			local clone2 = v5:Clone()
			clone2.CFrame += Vector3.new(math.random() - 0.5, 0, math.random() - 0.5) * v * 0.66 * v4
			clone2.Size = createVector(1, 1, 1) * (0.5 + math.random()) * v * 0.33
			clone2.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(clone2, TweenInfo.new(0.9 + math.random() * 0.4), {
				Size = Vector3.new(),
				CFrame = clone2.CFrame - Vector3.new(0, math.random(v, v * 1.5), 0)
			})
			tween.Completed:Connect(function()
				clone2:Destroy()
			end)
			tween:Play()
			now = tick()
		end

		task.wait()
	end

	clone.Spiral.Size = NumberSequence.new(v * 1.5, 0)
	clone.Particle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, v * 2),
		NumberSequenceKeypoint.new(1, 0)
	})
	task.delay(0.1, function()
		clone.Particle:Emit(12)
	end)
	sound:FadeOut(v3, 1)
	local lastTime3 = tick()

	while tick() - lastTime3 < 0.3 do
		local v4 = ((tick() - lastTime3) / 0.3) ^ 5

		for _, list in pairs(v2) do
			local v5, v6 = unpack(list)
			v5.Size = createVector(1, 1, 1) * v * 0.85 * (1 - v4)
			v5.CFrame = (root.CFrame + v6) * CFrame.Angles(tick() - lastTime, tick() - lastTime, tick() - lastTime)
		end

		task.wait()
	end

	for _, list in pairs(v2) do
		local v4, _ = unpack(list)
		v4:Destroy()
	end

	clone.Slash:Emit(10)
	task.wait(0.1)
	sound:Play("Sand.sDustBoom", root.Position)

	if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude < v * 5 + 10 then
		Effect.new("ShakeCam"):replicate({
			18,
			12,
			0,
			1.6,
			createVector(0, 0, 1),
			createVector(0, 0, 2)
		})
	end

	clone.Boom.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.33, v * 2.75, v * 0.5),
		NumberSequenceKeypoint.new(0.66, v * 3.25, v * 0.5),
		NumberSequenceKeypoint.new(1, v * 3.5, v * 0.5)
	})
	clone.Background.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, v),
		NumberSequenceKeypoint.new(0.33, v * 1.25, v * 0.25),
		NumberSequenceKeypoint.new(1, v)
	})
	clone.Background.Speed = NumberRange.new(v * 2, v * 12)
	clone.BoomFireflies.Speed = NumberRange.new(v * 3, v * 6)
	clone.Boom:Emit(5)
	clone.BoomFireflies:Emit(70)
	clone.Background:Emit(40)
	task.delay(6, function()
		clone:Destroy()
	end)
end