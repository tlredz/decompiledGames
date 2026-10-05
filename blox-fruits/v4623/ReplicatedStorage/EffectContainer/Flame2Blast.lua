local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function fn(cFrame, duration, size)
	local color = Color3.fromRGB(248, 78, 0)
	local clone = game.ReplicatedStorage.Assets.Models.InvertedSpikeMesh:Clone()
	clone.Transparency = 0
	clone.CanCollide = false
	clone.Anchored = true
	clone.Color = Color3.fromRGB(226, 155, 64)
	clone.CFrame = cFrame * CFrame.new(0, size * 0.1, 0)
	clone.Size = createVector(0.05, 0.05, 0.05)
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(clone, TweenInfo.new(duration * 1.3, Enum.EasingStyle.Quad), {
		Color = color,
		Transparency = 1,
		Size = createVector(1, 1, 1) * size * 4.5,
		CFrame = cFrame * CFrame.Angles(1.5707963267948966, 1.5707963267948966, 1.5707963267948966)
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
	local ray, v, v2 = Util.Ray(
		cFrame.p - cFrame.lookVector * 30,
		cFrame.lookVector * 70,
		{ workspace.Enemies, workspace.Boats, workspace.Characters }
	)

	if ray then
		local clone2 = game.ReplicatedStorage.Assets.Models.ShockwaveNeon:Clone()
		clone2.Transparency = 0
		clone2.CanCollide = false
		clone2.Anchored = true
		clone2.Color = Color3.fromRGB(226, 155, 64)
		clone2.CFrame = CFrame.new(v, v + v2) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone2.Size = createVector(0.05, 0.05, 0.05)
		clone2.Parent = _WorldOrigin
		local tween2 = TweenService:Create(clone2, TweenInfo.new(duration * 1.3, Enum.EasingStyle.Quad), {
			Color = color,
			Transparency = 1,
			Size = Vector3.new(size * 4, size * 0.1, size * 4),
			CFrame = cFrame * CFrame.new(0, size * 0.05, 0)
		})
		tween2.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween2:Play()
	end

	Effect.new("FireExplosion"):replicate({
		Position = cFrame.p,
		Emit = 40,
		Speed = size * 5,
		Scale = 3,
		Lifetime = { duration * 0.4, duration * 0.8 }
	})
end

return function(instance)
	if (instance.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
		return
	end

	fn(instance.CFrame, instance.Duration, instance.Size)
end