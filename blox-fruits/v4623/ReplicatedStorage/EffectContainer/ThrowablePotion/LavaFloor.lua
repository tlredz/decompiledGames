local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = workspace.Map
local _ = Util.Debris
local FX = require(game.ReplicatedStorage.FX)
local TweenService = game:GetService("TweenService")

local function ScaleParticle(clone, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, clone.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	return
		NumberSequence.new(numberSequenceKeypoints),
		NumberRange.new(clone.Speed.Min * p, clone.Speed.Max * p),
		clone.Acceleration * p
end

return function(data)
	local _ = data.size / 2 * 200
	local _ = data.size / 2 * 100
	local _ = data.size / 2 * 200
	local clone = FX:WaitForChild("MagmaEffects").OptimizedBall2:Clone()
	local primaryPart = clone.PrimaryPart
	clone:SetPrimaryPartCFrame(CFrame.new(data.pos))
	local v = math.random(15, 50) / data.size

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "root" then
			part.Size /= v
		end
	end

	local cframe = CFrame.new(primaryPart.Position)
	local ray, v2, v3 = Util.Ray(cframe.p, cframe.UpVector * -500, { workspace.Characters, workspace.Enemies }, false)

	if v2.Y <= -4 then
		v2 = v2 * createVector(1, 0, 1) + createVector(0, -4, 0)
	end

	if ray then
		clone.Parent = _WorldOrigin
		local magnitude = (cframe.Position - v2).Magnitude
		local v4 = cframe * CFrame.new(0, -magnitude, 0)
		local v5 = 0 * ((cframe.Position - v4.Position).Magnitude / data.size)

		for _, part in pairs(clone:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "root" then
				TweenService:Create(part, TweenInfo.new(v5 / 2), {
					Size = part.Size + Vector3.new(
						-math.random(2, 3) / 10,
						-math.random(2, 3) / 10,
						math.random(2, 3) / 10
					)
				}):Play()
			end
		end

		local size = data.size

		if v2.Y <= -4 then
			task.delay(v5, function()
				for _, part in pairs(clone:GetChildren()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end

				local v6 = createVector(1.405, 1.488, 1.434) / v + Vector3.new(size, size, -math.random(2, 3) / 10)
				Util.Sound:Play("SteamHiss", primaryPart, nil, 1.7413333333333334)
				local clones = {}

				for _, emitter in pairs(ReplicatedStorage.Assets.Models.MagmaFloors.Particles:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local clone2 = emitter:Clone()
					local size2, speed, acceleration = ScaleParticle(
						clone2,
						(v6 / 4 * createVector(1, 0, 1)).Magnitude * 0.08
					)
					clone2.Size = size2
					clone2.Speed = speed
					clone2.Acceleration = acceleration
					clone2.Parent = primaryPart
					table.insert(clones, clone2)
				end

				for _, v7 in pairs(clones) do
					local enable = v7:GetAttribute("Enable")
					local emit = v7:GetAttribute("Emit")

					if emit then
						v7:Emit(2 * (typeof(emit) == "number" and emit or 1))
					end

					if not enable then
						continue
					end

					if typeof(enable) == "number" then
						local v8 = v7
						task.delay(enable + 0.375, function()
							v8.Enabled = false
						end)
					end

					v7.Enabled = enable and true
				end
			end)
		end

		local v6 = math.rad((math.random(360)))

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			local tween = TweenService:Create(
				part,
				TweenInfo.new(v5, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
				{
					CFrame = v4 * CFrame.Angles(0, math.rad((math.random(360))), 0)
				}
			)
			tween:Play()
			local v7 = part
			tween.Completed:Connect(function()
				v7.CFrame = CFrame.new(v2, v2 + v3) * CFrame.Angles(0, 0, v6)
				TweenService:Create(v7, TweenInfo.new(3), {
					Size = v7.Size + Vector3.new(size, size, -math.random(2, 3) / 10)
				}):Play()
				coroutine.resume(coroutine.create(function()
					wait(data.duration)

					if v7.Name ~= "root" and v7.Name ~= "sphere" then
						local tween2 = TweenService:Create(
							v7,
							TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
							{
								Size = createVector(0, 0, 0)
							}
						)
						tween2:Play()
						tween2.Completed:Connect(function()
							if clone then
								clone:Destroy()
							end
						end)
					end
				end))
			end)
		end
	else
		clone:Destroy()
	end
end