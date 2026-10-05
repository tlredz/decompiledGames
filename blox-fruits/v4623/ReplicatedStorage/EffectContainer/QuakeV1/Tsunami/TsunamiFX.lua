local RunService = game:GetService("RunService")
require(game.ReplicatedStorage.Util)

local function tsunamiParticleFunction(part)
	for _ = 1, 5 do
		local clone = script:WaitForChild("ParticleEmitter"):Clone()
		clone.Parent = part
		clone.Enabled = true
	end
end

return function(p)
	local tsunami = p.tsunami
	local _ = p.mul
	local part = Instance.new("Part")
	part.Size = Vector3.new(25, 25, tsunami.Size.Z)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	tsunamiParticleFunction(part)
	part.Parent = workspace._WorldOrigin
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		part.CFrame = tsunami.CFrame * CFrame.new(-tsunami.Size.X * 1.5, tsunami.Size.Y / 2, 0)
	end)
	task.delay(16, function()
		if renderSteppedConnection then
			part:Destroy()
			renderSteppedConnection:Disconnect()
		end
	end)
end