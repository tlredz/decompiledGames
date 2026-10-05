local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
game:GetService("TweenService")
return function(p)
	local origin = p.Origin
	local position = p.Position
	local cframe = CFrame.new(origin, position)

	if (cframe.p - workspace.CurrentCamera.CFrame.p).Magnitude < 170 then
		Effect.new("ShakeCam"):replicate({
			10,
			10,
			0.1,
			1.75,
			createVector(1, 1, 1),
			createVector(1, 1, 1)
		})
	end

	Util.Sound:Play("LightBoom2", cframe)
	local clone = script.Wave.Attachment:Clone()
	clone.Parent = workspace.Terrain
	clone.CFrame = cframe
	clone.Spike.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 10, 6),
		NumberSequenceKeypoint.new(0.6, 10, 6),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Light1.Size = NumberSequence.new(17, 0)
	clone.Light2.Size = NumberSequence.new(8, 0)
	clone.Spike:Emit(100)
	clone.BoomFireflies:Emit(50)
	clone.Spike.Enabled = true
	clone.BoomFireflies.Enabled = true
	local clone2 = script.Wave.Attachment2:Clone()
	clone2.Parent = workspace.Terrain
	clone2.CFrame = cframe
	clone2.Shockwave.Size = NumberSequence.new(0, 40)
	clone2.Tiny2.Enabled = true
	local lastTime = tick()

	while tick() - lastTime < 0.4 do
		local v = 1 - (tick() - lastTime) / 0.4
		clone.Tiny.Speed = NumberRange.new(20 * v, 5 + 150 * v)
		clone.Tiny.SpreadAngle = Vector2.new(45, 45) * v
		clone.BoomFireflies.SpreadAngle = Vector2.new(7, 7) * v
		clone.Tiny:Emit(6)
		clone.Light1:Emit(2)
		clone.Light2:Emit(1)
		clone2.Shockwave:Emit(1)
		clone2.Tiny2:Emit(10)
		clone2.CFrame = cframe * CFrame.new(0, 0, -1000 * (1 - v))
		task.wait()
	end

	clone.Spike.Enabled = false
	clone.BoomFireflies.Enabled = false
	clone2.Tiny2.Enabled = false
	wait(4)
	clone2:Destroy()
	clone:Destroy()
end