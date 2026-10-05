local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function distanceCK(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

return function(data)
	local part_to_send = data.part_to_send

	if not part_to_send or (part_to_send.CFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude >= 2000 then
		return
	end

	local scale_to_send = data.scale_to_send
	local ultimate_ko_to_send = data.ultimate_ko_to_send
	local p = part_to_send.CFrame.p
	local character = game.Players.LocalPlayer.Character

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= 100 then
			Util.CameraShaker:ShakeOnce(2.5, 10, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 1))
		end
	end

	local v = math.random(50, 75) / 100
	local position = part_to_send.Position
	local v2 = nil

	if ultimate_ko_to_send then
		v2 = 12
	elseif not ultimate_ko_to_send then
		v2 = math.random(1, 2)
	end

	coroutine.resume(coroutine.create(function()
		for _ = 1, v2 do
			local clone = FX:WaitForChild("MagmaEffects"):WaitForChild("OptimizedBall2"):Clone()
			local vector2 = Vector3.new(math.random(-25, 25) / 10, math.random(-25, 25) / 10, math.random(15, 50) / 10)

			for _, part in pairs(clone:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Size *= scale_to_send / 1.35
				part.CFrame = CFrame.new(part_to_send.CFrame.p, part_to_send.CFrame * vector2) * CFrame.Angles(
					math.rad(math.random(-350, 350) / 10),
					math.rad(math.random(-350, 350) / 10),
					(math.rad(math.random(-350, 350) / 10))
				)
				part.Anchored = false
			end

			clone.Parent = workspace:WaitForChild("_WorldOrigin")

			for _, emitter in pairs(clone:GetDescendants()) do
				if not (emitter:IsA("ParticleEmitter") and emitter.Name == "smoke_p") then
					continue
				end

				if ultimate_ko_to_send then
					emitter.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 5),
						NumberSequenceKeypoint.new(1, 7.5)
					})
					emitter.Speed = NumberRange.new(200)
				end

				emitter.Rate /= 3
				emitter.Enabled = true
			end

			for _, child in pairs(clone:GetChildren()) do
				if not (child.Name ~= "root" and child.Name ~= "Sphere") then
					continue
				end

				local tween = TweenService:Create(
					child,
					TweenInfo.new(math.random(30, 50) / 10, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(0, 0, 0)
					}
				)
				tween:Play()
				local folder = clone
				tween.Completed:Connect(function()
					for i, emitter in pairs(folder:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") and emitter.Name == "smoke_p" then
							emitter.Enabled = false
						end
					end

					if folder then
						folder:Destroy()
					end
				end)
			end

			local velocity = clone.PrimaryPart.CFrame.lookVector * (math.random(1000, 1500) / 10)
			local vector3 = Vector3.new(math.random(-50, 50) / 10, math.random(-50, 50) / 10, math.random(-50, 50) / 10)

			for _, part in pairs(clone:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Velocity = velocity
				part.RotVelocity = vector3
			end
		end
	end))
	local clone = FX:WaitForChild("MagmaEffects"):WaitForChild("MagmaBall"):Clone()

	for _, part in pairs(clone:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Name ~= "Sphere" and part.Name ~= "old" and part.Name ~= "root") then
			continue
		end

		part:Destroy()
	end

	clone:SetPrimaryPartCFrame(part_to_send.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(1.5707963267948966, 0, 0))
	clone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame * CFrame.Angles(
		math.rad(math.random(-100, 100) / 10),
		math.rad(math.random(-100, 100) / 10),
		(math.rad(math.random(-100, 100) / 10))
	))
	clone:SetPrimaryPartCFrame(CFrame.new(clone.PrimaryPart.Position, position) * CFrame.Angles(
		1.5707963267948966,
		0,
		0
	))
	clone.Parent = workspace:WaitForChild("_WorldOrigin")
	local sphere = clone:WaitForChild("Sphere")
	sphere.Size = createVector(50, 15, 50)

	if math.random(1, 2) == 1 then
		sphere.Color = Color3.fromRGB()
	end

	local tween = TweenService:Create(sphere, TweenInfo.new(v, Enum.EasingStyle.Quart), {
		CFrame = sphere.CFrame * CFrame.new(0, -math.random(350, 500) / 10, 0) * CFrame.Angles(
			0,
			math.rad(math.random(-3600, 3600) / 10),
			0
		),
		Size = sphere.Size * math.random(15, 20) / 10,
		Transparency = 1,
		Color = Color3.fromRGB(255, 0, 0)
	})
	tween:Play()
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	local _ = part_to_send.Position
end