local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Util = require(game.ReplicatedStorage.Util)
local bodyMover = Util.BodyMover
return function(list)
	local v, v2, v3, v4 = unpack(list)
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local _ = character.HumanoidRootPart
	local v5 = bodyMover.new(character):Create("BodyPosition", {
		Position = v2.p
	})
	local v6 = v.CFrame * ((createVector(0, 1, 1)).Unit * v3 * 0.75)
	local lastTime = tick()

	while tick() - lastTime < v4 * 0.75 do
		local v7 = (tick() - lastTime) / (v4 * 0.75)
		local v8 = 2 * (6.283185307179586 * v7)
		local v9 = math.sin(3.141592653589793 * v7)
		v6 = v.CFrame * ((createVector(0, 1, 1)).Unit * v3 * 0.75) + Vector3.new(
			v3 * 0.5 * math.cos(v8) * v9,
			0,
			v3 * 0.5 * math.sin(v8) * v9
		)
		v5:Set(v2.p:Lerp(v6, v7))
		RunService.RenderStepped:Wait()
	end

	local position = v.CFrame * ((createVector(0, 0, -1)).Unit * v3 * 0.75) + createVector(0, 2, 0)
	local lastTime2 = tick()

	while tick() - lastTime2 < v4 * 0.25 do
		local v8 = (tick() - lastTime2) / (v4 * 0.25)
		position = v.CFrame * ((createVector(0, 0, -1)).Unit * v3 * 0.75)
		v5:Set(v6:Lerp(position, v8) + Vector3.new(0, v3 * 0.25 * math.sin(3.141592653589793 * v8)))
		RunService.RenderStepped:Wait()
	end

	v5.Position = position
	wait(0.7)
	v5:Destroy()
end