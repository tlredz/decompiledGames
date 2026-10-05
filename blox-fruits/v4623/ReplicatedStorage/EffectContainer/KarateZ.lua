local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local direction = p.Direction

	if (direction.p - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
		return
	end

	for i = 0, 50, 10 do
		local clone = game.ReplicatedStorage.Assets.Models.ShockwaveTransparent:Clone()
		clone.CFrame = direction * CFrame.new(0, 0, -i) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Mesh.Scale = createVector(0.01, 0.35, 0.01)
		clone.Parent = _WorldOrigin
		TweenService:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = clone.CFrame * CFrame.new(0, -10, 0),
			Transparency = 1
		}):Play()
		local tween = TweenService:Create(
			clone.Mesh,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Scale = createVector(0.1, 0, 0.1),
				VertexColor = createVector(1, 1, 1)
			}
		)
		local v = i
		tween.Completed:Connect(function()
			if v == 0 then
				Util.Sound:Play("Engulf", direction)
			end

			clone.Dust:Emit(6)
			local tween2 = TweenService:Create(clone.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Scale = createVector(0.25, 0.1, 0.25)
			})
			tween2.Completed:Connect(function()
				clone:Destroy()
			end)
			tween2:Play()
		end)
		tween:Play()
		wait()
	end
end