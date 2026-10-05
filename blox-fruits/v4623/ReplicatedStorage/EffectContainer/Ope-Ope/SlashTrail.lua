local RunService = game:GetService("RunService")
workspace:WaitForChild("_WorldOrigin")
local Tween = require(game.ReplicatedStorage.Util.Tween)
local opeOpe = game.ReplicatedStorage["Ope-Ope"]
return function(list)
	local v, v2, v3, v4, v5, lifetime, v7 = unpack(list)
	local attachment = Instance.new("Attachment")
	attachment.CFrame = v * CFrame.new(-v5 / 2, 0, 0)
	attachment.Parent = workspace.Terrain
	local clone = attachment:Clone()
	clone.Parent = workspace.Terrain
	local clone2 = opeOpe.Particles.TravelTrail:Clone()
	clone2.FaceCamera = true
	clone2.Enabled = true
	clone2.Color = ColorSequence.new(v2)
	clone2.Lifetime = lifetime
	clone2.Attachment0 = attachment
	clone2.Attachment1 = clone
	clone2.Parent = attachment
	local lastTime = tick()
	local v8 = v7 or 1

	while tick() - lastTime < lifetime do
		local v9 = (tick() - lastTime) / lifetime
		local sine = Tween.ease.out.sine(v9, 0, 1, 1)
		local v10 = math.sin(3.141592653589793 * v9) ^ 0.5
		local v11 = v3 * v10
		attachment.CFrame = v * CFrame.new(-1 * v11 - v8 * v5 / 2 + v8 * v5 * sine, 0, -v4 * v10)
		clone.CFrame = v * CFrame.new(1 * v11 - v8 * v5 / 2 + v8 * v5 * sine, 0, -v4 * v10)
		RunService.RenderStepped:Wait()
	end

	clone2.Enabled = false
	wait(lifetime)
	attachment:Destroy()
	clone:Destroy()
end