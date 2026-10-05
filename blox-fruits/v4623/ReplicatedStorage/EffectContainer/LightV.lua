local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	Util.Sound:Play("BlastCharge", cFrame.p)
	Effect.new("ShineExplosion"):replicate({
		Position = cFrame.p,
		Size = 60
	})
	wait(0.4)

	for _ = 1, 14 do
		local v = cFrame * CFrame.new(40 * (math.random() - 0.5) * 2, 80, 40 * (math.random() - 0.5) * 2)
		Util.Sound:Play("DiscFire", v)
		Effect.new("ShineExplosion"):replicate({
			Position = v.p,
			Size = 15
		})
		local part = Instance.new("Part")
		part.Material = "Neon"
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(1, 1, 1)
		part.Color = Color3.new(1, 1, 0.45)
		part.CFrame = v * CFrame.Angles(0, 0, 1.5707963267948966)
		local specialMesh = Instance.new("SpecialMesh", part)
		specialMesh.MeshType = "Cylinder"
		specialMesh.Scale = createVector(0, 4, 4)
		part.Parent = _WorldOrigin
		local tween = TweenService:Create(specialMesh, TweenInfo.new(0.3), {
			Scale = createVector(80, 1, 1),
			Offset = createVector(-40, 0, 0)
		})
		tween.Completed:Connect(function()
			local tween2 = TweenService:Create(specialMesh, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Scale = createVector(80, 0, 0)
			})
			tween2.Completed:Connect(function()
				part:Destroy()
			end)
			tween2:Play()
			local position = v * createVector(0, -80, 0)
			Util.Sound:Play("GenericExplosion2", position)
			Effect.new("ShineExplosion"):replicate({
				Position = position,
				Size = 100
			})
			Effect.new("BasicExplosion"):replicate({
				Position = position,
				Size = { 0, 40 },
				Quality = 1,
				Duration = 0.7,
				Color = {
					Inner = Color3.new(1, 1, 1),
					Outer = Color3.new(1, 1, 0.3)
				},
				Rocks = true
			})
		end)
		tween:Play()
		wait(0.1)
	end
end