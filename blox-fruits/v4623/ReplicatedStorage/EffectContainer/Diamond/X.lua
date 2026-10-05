local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local root = p.Root

	if not root or (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
		return
	end

	local lastTime = tick()

	while tick() - lastTime < p.Duration do
		local clone = script.ThinRing:Clone()
		clone.CFrame = root.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
			Size = createVector(26, 0, 26),
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()

		for _ = 1, 3 do
			local color = math.random() > 0.5 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 255, 255)
			local v2 = 15 + math.random() * 10
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = root.CFrame * CFrame.new(math.random(-7, 7), math.random(-7, 7), 0)
			part.Size = createVector(1, 1, 1)
			part.Color = color
			part.Transparency = 0
			part.Material = "Neon"
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = createVector(0.075, 0.075, 1) * v2
			specialMesh.Parent = part
			part.Parent = _WorldOrigin
			local tween2 = TweenService:Create(specialMesh, TweenInfo.new(0.15 + math.random() * 0.1), {
				Scale = Vector3.new(),
				Offset = Vector3.new(0, 0, math.random(20, 30))
			})
			tween2.Completed:Connect(function()
				part:Destroy()
			end)
			tween2:Play()
		end

		wait()
	end
end