local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(p)
	local origin = p.Origin
	local direction = p.Direction

	if (origin - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	local cframe = CFrame.new(origin, origin + direction * createVector(1, 0, 1))

	for i = 0, 160, 20 do
		local v = i * 0.25 + 25
		local v2 = cframe * CFrame.new(0, v, -i)
		local ray, v3, _ = Util.Ray(
			v2.p,
			Vector3.new(0, -60 - v, 0),
			{ workspace._WorldOrigin, workspace.Enemies, workspace.Characters }
		)

		if not (ray and ray.Transparency <= 0 and ray.Anchored) then
			continue
		end

		local cframe2 = CFrame.new(v3, v3 + direction * createVector(1, 0, 1))
		local v4 = math.cos(i * 3) ^ 2 * 4 + 20 + i / 20
		local v5 = math.cos(i * 3) ^ 2 * 1.5 + 3 + i / 80
		local v6 = v + math.sin(i) ^ 2 * 12 + i / 30
		local clone = game.ReplicatedStorage.Assets.Models.SandBall:Clone()
		local color = clone.Color
		local color2 = ray.Color
		clone.Color = color2
		clone.Mesh.Scale = Vector3.new(v5, v6, v4)
		clone.CFrame = cframe2
		local clone2 = FX:WaitForChild("SandDust"):Clone()
		clone2.Speed = NumberRange.new(v * 3, v * 4)
		clone2.Parent = clone
		clone.Parent = _WorldOrigin
		clone2:Emit(8)
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()
		clone2.Speed = NumberRange.new(v5 * 9, v5 * 11)
		TweenService:Create(clone, TweenInfo.new(0.3), {
			Color = color
		}):Play()
		local tween = TweenService:Create(clone.Mesh, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {
			Scale = Vector3.new(v5, v6 * 2, v4)
		})
		tween.Completed:Connect(function()
			wait(0.6)
			Util.Sound:Play("SetFire", cframe2.p)
			clone2.Enabled = false
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Color = color2
			}):Play()
			local tween2 = TweenService:Create(
				clone.Mesh,
				TweenInfo.new(0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
				{
					Scale = Vector3.new(v5 * 4, 0, v4),
					Offset = createVector(0, -0.5, 0)
				}
			)
			tween2.Completed:Connect(function()
				clone:Destroy()
			end)
			tween2:Play()
		end)
		tween:Play()
		Util.Sound:Play("ShortExplosion", cframe2.p)
	end
end