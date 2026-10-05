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
	local cFrame = p.CFrame
	local scale = p.Scale
	local magnitude = (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 200 + scale * 10 < magnitude then
		return
	end

	local iceRock = ReplicatedStorage.Assets.Models.IceRock
	iceRock.Color = Color3.fromRGB(139, 195, 255)

	for _ = 1, 6 do
		local cframe = CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		)
		local clone = iceRock:Clone()
		clone.Size = createVector(0.05, 0.05, 0.05)
		clone.Color = clone.Color:Lerp(Color3.new(), math.random() * 0.1)
		clone.CFrame = cFrame * cframe
		clone.Parent = _WorldOrigin
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.2 + math.random() * 0.1, Enum.EasingStyle.Exponential),
			{
				Size = createVector(0.5, 1, 0.5) * scale,
				CFrame = cFrame * cframe * CFrame.new(0, scale / 2, 0)
			}
		)
		tween.Completed:Connect(function()
			local tween2 = TweenService:Create(clone, TweenInfo.new(0.1), {
				Size = createVector(0.05, 0.05, 0.05),
				CFrame = cFrame * cframe
			})
			tween2.Completed:Connect(function()
				clone:Destroy()
			end)
			tween2:Play()
		end)
		tween:Play()
	end

	for _ = 1, 5 do
		local cframe = CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		)
		local clone = iceRock:Clone()
		clone.Size = Vector3.new(0.5, 3.5 + math.random(), 0.5) * scale * (0.7 + math.random() * 0.6)
		clone.CFrame = cFrame * cframe
		clone.Parent = _WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.2 + math.random() * 0.2), {
			Size = createVector(0.05, 0.05, 0.05),
			CFrame = cFrame * cframe * CFrame.new(0, scale * (2 + math.random()), 0)
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	end

	local part = Instance.new("Part")
	part.CastShadow = false
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)
	part.CFrame = cFrame
	part.Color = iceRock.Color
	part.Material = "Neon"
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.Scale = Vector3.new()
	specialMesh.MeshType = "Sphere"
	part.Parent = _WorldOrigin
	local tween = TweenService:Create(part, TweenInfo.new(0.2), {
		Transparency = 1
	})
	local tween2 = TweenService:Create(specialMesh, TweenInfo.new(0.2), {
		Scale = createVector(1, 1, 1) * scale * 3
	})
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	tween:Play()
	tween2:Play()
end