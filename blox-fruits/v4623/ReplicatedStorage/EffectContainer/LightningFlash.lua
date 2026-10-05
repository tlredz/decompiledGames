local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage.Effect)
return function(p)
	for i = 1, (p.Position1 - p.Position0).Magnitude, 20 do
		local origin = CFrame.new(p.Position0, p.Position1) * CFrame.new(0, 0, -i)
		Effect.new("ExpandRing"):replicate({
			Origin = origin,
			Size = { createVector(1.75, 1.75, 0.375), createVector(18.75, 18.75, 0) },
			Duration = 0.2
		})
		RunService.Stepped:Wait()
	end
end