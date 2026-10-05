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
local _ = ReplicatedStorage.Assets.Models.IceRock
local FX = require(game.ReplicatedStorage.FX)
return function(data)
	local cFrame = data.CFrame
	local v = data.Width[1]
	local v2 = data.Width[2]
	local duration = data.Duration
	local radius = data.Radius
	local magnitude = (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 500 + radius < magnitude then
		return
	end

	if data.Ice then
		local ray, v3, v4 = Util.Ray(
			cFrame.p + createVector(0, 3, 0),
			Vector3.new(0, -radius / 2, 0),
			{ workspace.Enemies, workspace.Characters, workspace.Boats }
		)

		if ray then
			local vector2 = Vector3.new(radius * 2.25, 1, radius * 2.25)
			local v5 = CFrame.new(v3, v3 + v4) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local clone = FX:WaitForChild("IceEffects").IceAge.Floor:Clone()
			clone.CFrame = v5 * CFrame.new(0, 0.1, 0)
			clone.Transparency = 0
			clone.Material = "Neon"
			clone.Color = Color3.fromRGB(139, 195, 255)
			clone.Size = vector2 * 0.25
			clone.CanCollide = false
			clone.Parent = workspace._WorldOrigin
			local tween = TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Size = vector2 * 0.9
			})
			tween.Completed:Connect(function()
				clone.Material = "Glass"
				local tween2 = TweenService:Create(clone, TweenInfo.new(duration * 0.75, Enum.EasingStyle.Quad), {
					Size = vector2 * 0.75
				})
				tween2.Completed:Connect(function()
					task.wait(duration * 0.15)
					local tween3 = TweenService:Create(
						clone,
						TweenInfo.new(0.4 * (1 + math.random() * 0.25), Enum.EasingStyle.Quad),
						{
							Size = createVector(0, 0, 0)
						}
					)
					tween3.Completed:Connect(function()
						clone:Destroy()
					end)
					tween3:Play()
				end)
				tween2:Play()
			end)
			tween:Play()
		end
	end

	local part = Instance.new("Part")
	part.Size = Vector3.new(v + v2 / 4, v + v2 / 4, v + v2 / 4)
	part.Anchored = true
	part.CanCollide = false
	part.Material = "Neon"
	part.Color = Color3.fromRGB(139, 195, 255)
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	local clone = game.ReplicatedStorage.Assets.Particles.IcyWind:Clone()
	clone.Enabled = true
	clone.Size = NumberSequence.new(v * 0.9, v * 1.4, v * 0.25)
	clone.SpreadAngle = Vector2.new(360, 360)
	clone.Speed = NumberRange.new(radius * 2.2 * 1.2, radius * 2.4 * 1.2)
	clone.Parent = part

	if data.NoSmoke then
		clone.Enabled = false
	end

	wait(data.InitialDuration or 1.4)
	wait(data.ExtraDuration or 0)
	clone.Enabled = false
	wait(1)
	part:Destroy()
end