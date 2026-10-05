local createVector = vector.create
local RunService = game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local bodyMover = Util.BodyMover
return function(list)
	local v, v2, v3 = unpack(list)
	local character = localPlayer.Character
	character:WaitForChild("Humanoid", 1)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 1)
	local v4 = bodyMover.new(character):Create("BodyGyro", {
		CFrame = CFrame.new(v2.p, humanoidRootPart.CFrame * createVector(0, 0, -1))
	})
	local v5 = bodyMover.new(character):Create("BodyPosition", {
		Position = v2 * Vector3.new(0, 3 * v.Y / 2, 3)
	})
	local position = humanoidRootPart.Position
	local lastTime = tick()

	while tick() - lastTime < v3 * 0.5 do
		local v6 = (tick() - lastTime) / (v3 * 0.5)
		local v7 = math.sin(3.141592653589793 * v6)
		v5:Set(position:Lerp(v2 * Vector3.new(0, 3 * v.Y, 2 * v.Z), v6) - v2.LookVector * 2 * v.Z * v7)
		v4:Set(CFrame.new(humanoidRootPart.Position, v2.p))
		RunService.RenderStepped:Wait()
	end

	local position2 = humanoidRootPart.Position
	Effect.new("Mochi-Mochi.Shockwave"):replicate({
		CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector) * CFrame.new(
			0,
			0,
			-2
		) * CFrame.Angles(3.141592653589793, 0, 0),
		15,
		0.3,
		3
	})
	local lastTime2 = tick()

	while tick() - lastTime2 < v3 * 0.5 do
		local v6 = (tick() - lastTime2) / (v3 * 0.5)
		local v7 = math.sin(3.141592653589793 * v6)
		v5:Set(position2:Lerp(v2 * createVector(0, 0, 3), v6) + Vector3.new(0, v7 * 30, 0))
		v4:Set(CFrame.new(humanoidRootPart.Position, v2.p))
		RunService.RenderStepped:Wait()
	end

	v5:Set(v2 * createVector(0, 0, 3) + createVector(0, 2.1, 0))
	wait(0.5)
	v5:Destroy()
	v4:Destroy()
end