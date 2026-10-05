local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	Effect.new("FireExplosion"):replicate({
		Position = cFrame.p,
		Emit = 30,
		Speed = 500
	})
	local clone = game.ReplicatedStorage.Assets.Models.ShockwaveNeon:Clone()
	clone.Size = createVector(60, 120, 60)
	clone.Color = Color3.new(1, 0.2, 0)
	clone.CFrame = cFrame * CFrame.new(0, 20, 0)
	clone.Parent = workspace._WorldOrigin
	local tween = TweenService:Create(clone, TweenInfo.new(0.9375, Enum.EasingStyle.Quad), {
		CFrame = clone.CFrame * CFrame.new(0, -10, 0),
		Size = createVector(300, 20, 300),
		Transparency = 1,
		Color = Color3.new(1, 1, 1)
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()

	for _ = 1, 8 do
		local clone2 = game.ReplicatedStorage.Assets.Models.CrescentSlash:Clone()
		clone2.Size = createVector(60, 2, 80)
		clone2.Color = Color3.new(1, 0.2, 0)
		clone2.CFrame = cFrame * CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		)
		clone2.Parent = workspace._WorldOrigin
		local tween2 = TweenService:Create(clone2, TweenInfo.new(1.25, Enum.EasingStyle.Quad), {
			Size = clone2.Size * 5,
			CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0),
			Transparency = 1,
			Color = Color3.new(1, 1, 1)
		})
		tween2.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween2:Play()
	end
end