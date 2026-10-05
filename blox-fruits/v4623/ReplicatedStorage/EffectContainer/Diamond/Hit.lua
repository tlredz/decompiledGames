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
return function(data)
	local position = data.Position

	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	if data.Explode then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CFrame = CFrame.new(position)
		part.Size = createVector(1, 1, 1)
		part.Color = Color3.fromRGB(150, 255, 255)
		part.Transparency = 0.1
		part.Material = "Neon"
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = "Sphere"
		specialMesh.Scale = Vector3.new()
		specialMesh.Parent = part
		part.Parent = _WorldOrigin
		local tweenInfo = TweenInfo.new(data.Duration or 0.3, Enum.EasingStyle.Quad)
		TweenService:Create(part, tweenInfo, {
			Transparency = 1
		}):Play()
		local tween = TweenService:Create(specialMesh, tweenInfo, {
			Scale = createVector(42, 42, 42)
		})
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
	end

	for _ = 1, _G.FastMode and 3 or data.Explosion and 4 or 5 do
		for _ = 1, data.Explosion and 1 or 2 do
			local color = math.random() > 0.5 and Color3.fromRGB(150, 255, 255) or Color3.fromRGB(190, 255, 255)
			local v = (25 + math.random() * 10) * (data.Explosion and 1.35 or 1)
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new(position) * CFrame.Angles(
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2,
				3.141592653589793 * (math.random() - 0.5) * 2
			)
			part.Size = createVector(1, 1, 1)
			part.Color = color
			part.Transparency = 0
			part.Material = "Neon"
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = createVector(0.1, 0.1, 1.5) * v
			specialMesh.Parent = part
			part.Parent = _WorldOrigin
			local tween = TweenService:Create(
				specialMesh,
				TweenInfo.new((not data.Duration and 0.1 or data.Duration / 3 or 0.1) + math.random() * 0.1),
				{
					Scale = Vector3.new(),
					Offset = Vector3.new(0, 0, -math.random(30, 50) * (data.Explosion and 1.35 or 1))
				}
			)
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end

		if data.Ball then
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new(position)
			part.Size = createVector(1, 1, 1)
			part.Color = Color3.new(1, 1, 1)
			part.Transparency = 0.1
			part.Material = "Neon"
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.MeshType = "Sphere"
			specialMesh.Scale = Vector3.new()
			specialMesh.Parent = part
			part.Parent = _WorldOrigin
			local tweenInfo = TweenInfo.new(not data.Duration and 0.15 or data.Duration / 2 or 0.15)
			TweenService:Create(part, tweenInfo, {
				Transparency = 1
			}):Play()
			local tween = TweenService:Create(specialMesh, tweenInfo, {
				Scale = createVector(14, 14, 14)
			})
			tween.Completed:Connect(function()
				part:Destroy()
			end)
			tween:Play()
		end

		if not data.Exploion then
			wait()
		end
	end
end