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
		clone.Color = Color3.new()
		clone.CFrame = root.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(24, 0, 24),
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()

		for _ = 1, 10 do
			local color = math.random() > 0.25 and Color3.fromRGB(218, 133, 65) or Color3.fromRGB(170, 85, 0)
			local v2 = math.random() < 0.5 and 1 or 0.125 + math.random() * 0.1
			local v3 = 10 + math.random() * 15 + (1 - v2) * 15
			local part = Instance.new("Part")
			part.CastShadow = false
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = root.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(
				math.random() - 0.5,
				math.random() - 0.5,
				math.random() - 0.5
			)
			part.Size = createVector(1, 1, 1)
			part.Color = color
			part.Transparency = 0
			part.Material = "Neon"
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = Vector3.new(v2, v2, 1) * v3 * 0.25
			specialMesh.Parent = part
			part.Parent = _WorldOrigin
			local tweenInfo = TweenInfo.new(0.2 + math.random() * 0.3 + v2 / 5)
			TweenService:Create(part, tweenInfo, {
				Color = part.Color:Lerp(Color3.new(1, 0, 0), 0.4)
			}):Play()
			local tween2 = TweenService:Create(specialMesh, tweenInfo, {
				Scale = Vector3.new(),
				Offset = Vector3.new(0, 0, v3 * (0.75 + math.random() * 1.75))
			})
			tween2.Completed:Connect(function()
				part:Destroy()
			end)
			tween2:Play()
		end

		wait()
	end
end