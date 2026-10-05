local RunService = game:GetService("RunService")
local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
return function(list)
	local cFrame, v2 = unpack(list)
	local Players = game:GetService("Players")
	local character = Players.LocalPlayer.Character
	local magnitude = character:GetModelSize().Magnitude
	local v3 = BodyMover.new(character)
	local v4 = v3:Create("BodyGyro", {
		D = 250,
		CFrame = cFrame
	})
	local v5 = v3:Create("BodyPosition", {
		Position = cFrame.p
	})
	local lastTime = tick()

	while tick() - lastTime < v2 do
		local v6 = (tick() - lastTime) / v2
		local v7 = math.sin(3.141592653589793 * v6)
		local v8 = v6 ^ 0.5
		local v9 = v6 ^ 4
		v5:Set(cFrame * Vector3.new(0, 0, magnitude * v6) + Vector3.new(0, magnitude * v7, 0))
		v4:Set(cFrame * CFrame.Angles(3.141592653589793 * v8, 0, 3.141592653589793 * v9))
		RunService.RenderStepped:Wait()
	end

	wait(0.1)
	v4:Set(cFrame * CFrame.Angles(3.141592653589793, 0, 3.141592653589793))
	v5:Set(cFrame * Vector3.new(0, 0, magnitude))
	wait(0.03333333333333333)
	v5:Destroy()
	v4:Destroy()
end