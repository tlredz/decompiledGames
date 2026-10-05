local createVector = vector.create
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local map = workspace:WaitForChild("Map")
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local liberation = FX:WaitForChild("Dark").Liberation
local sound = Util.Sound
local debris = Util.Debris
local cameraShaker = Util.CameraShaker
local _ = Util.ParticleScaler

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local v = {
	TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.In),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

for _, emitter in pairs(liberation.BlackPillar:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		emitter.Rate *= 0.75
	end
end

return function(p)
	local cFrame = p.CFrame

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).magnitude > 500 then
		return
	end

	local ray = Ray.new(cFrame.Position, createVector(0, -5, 0))
	local part, v2, v3 = game.Workspace:FindPartOnRayWithWhitelist(ray, { map })
	local v4

	if part then
		v4 = CFrame.new(v2, v2 + v3) * CFrame.Angles(-1.5707963267948966, 0, 0)
	else
		v4 = cFrame * CFrame.new(0, -5, 0)
	end

	local cFrame2 = v4 * CFrame.new(0, 1.5, 0)
	local clone = liberation.BlackPillar:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame2
	clone.Parent = _WorldOrigin
	local cFrame3 = cFrame2 * CFrame.new(0, -1.5, 0)
	local clone2 = liberation.Main:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame3
	clone2.Parent = _WorldOrigin
	local size = clone2.Size
	clone2.Size *= 0
	TweenService:Create(clone2, v[7], {
		Size = size
	}):Play()

	for _, part2 in pairs(clone2:GetChildren()) do
		if not part2:IsA("Part") then
			continue
		end

		local size2 = part2.Size
		part2.Size *= 0
		TweenService:Create(part2, v[7], {
			Size = size2
		}):Play()
	end

	sound:Play("DarkLiberation", cFrame2, nil, 1)
	local shakeSustain = cameraShaker:ShakeSustain(cameraShaker.Presets.Bump)
	local v7 = {
		Magnitude = shakeSustain.Magnitude,
		Roughness = shakeSustain.Roughness
	}

	if p.Player == game.Players.LocalPlayer then
		Effect.new("Dark.Gradient"):replicate({
			Toggle = true,
			Transparency = 0.35,
			Duration = 0.35
		})
	end

	local lastTime = tick()

	while true do
		local v8 = tick() - lastTime
		local v9 = math.clamp(1 - (currentCamera.CFrame.p - cFrame2.p).Magnitude / 150, 0, 1)

		for k, v10 in pairs(v7) do
			shakeSustain[k] = v10 * v9
		end

		if v8 > 1 then
			shakeSustain:StartFadeOut(0.5)
			local shakeSustain2 = cameraShaker:ShakeSustain(cameraShaker.Presets.Bump2)
			local v10 = {
				Magnitude = shakeSustain2.Magnitude,
				Roughness = shakeSustain2.Roughness
			}

			if p.Player == game.Players.LocalPlayer then
				Effect.new("Dark.Gradient"):replicate({
					Toggle = true,
					Transparency = 0.175,
					Duration = 0.35
				})
			end

			clone2.effectPart.Attachment.Vortex.Rate *= 5.5
			clone2.effectPart.Attachment.Vortex.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 18),
				NumberSequenceKeypoint.new(1, 100)
			})
			clone2.effectPart.Attachment.Energy.Rate *= 2
			clone2.effectPart.Attachment.Energy.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 18),
				NumberSequenceKeypoint.new(1, 120)
			})
			TweenService:Create(clone2, v[5], {
				Size = clone2.Size * 2
			}):Play()

			for _, part2 in pairs(clone2:GetChildren()) do
				if not part2:IsA("Part") then
					continue
				end

				TweenService:Create(part2, v[5], {
					Size = part2.Size * 2
				}):Play()

				if part2.Name == "BeamPart2" then
					for _, child in pairs(part2.BeamAttach:GetChildren()) do
						child.Enabled = true
					end
				elseif part2.Name == "BeamPart" then
					for _, child in pairs(part2.BeamAttach:GetChildren()) do
						child.Enabled = false
					end
				end
			end

			for _, child in pairs(clone.PillarX:GetChildren()) do
				child.Rate *= 2.25

				if child.Name == "DarkPillar" or child.Name == "DarkPillar2" then
					local speed = child.Speed
					child.Speed = NumberRange.new(speed.Min * 3, speed.Max * 3)
					local lifetime = child.Lifetime
					child.Lifetime = NumberRange.new(
						lifetime.Min * 0.3333333333333333,
						lifetime.Max * 0.3333333333333333
					)
				elseif child.Name == "Crescent" then
					local speed = child.Speed
					child.Speed = NumberRange.new(speed.Min * 3.5, speed.Max * 3.5)
					local lifetime = child.Lifetime
					child.Lifetime = NumberRange.new(
						lifetime.Min * 0.3333333333333333,
						lifetime.Max * 0.3333333333333333
					)
				elseif child.Name ~= "Crescent2" and child.Name ~= "Wisp" then
					local speed = child.Speed
					child.Speed = NumberRange.new(speed.Min * 3.375, speed.Max * 3.375)
					local lifetime = child.Lifetime
					child.Lifetime = NumberRange.new(
						lifetime.Min * 0.3333333333333333,
						lifetime.Max * 0.3333333333333333
					)
				end

				child.Enabled = true
			end

			task.spawn(function()
				task.wait(1.2)
				clone2.effectPart.Attachment.Vortex.Enabled = false
				clone2.effectPart.Attachment.Energy.Enabled = false
				task.wait(0.3)
			end)
			local lastTime2 = tick()

			while true do
				local v11 = tick() - lastTime2
				local v12 = math.clamp(1 - (currentCamera.CFrame.p - cFrame2.p).Magnitude / 300, 0, 1)

				for k, v13 in pairs(v10) do
					shakeSustain2[k] = v13 * v12
				end

				if v11 > 1.5 then
					shakeSustain2:StartFadeOut(1.5)

					if p.Player == game.Players.LocalPlayer then
						Effect.new("Dark.Gradient"):replicate({
							Toggle = false,
							Duration = 0.75
						})
					end

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					TweenService:Create(clone2, v[6], {
						Size = clone2.Size * 0
					}):Play()

					for _, part2 in pairs(clone2:GetChildren()) do
						if not part2:IsA("Part") then
							continue
						end

						TweenService:Create(part2, v[6], {
							Size = part2.Size * 0
						}):Play()

						if part2.Name == "effectPart" then
							for _, emitter in pairs(part2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end

						if part2.Name ~= "BeamPart2" then
							continue
						end

						for _, child in pairs(part2.BeamAttach:GetChildren()) do
							child.Enabled = false
						end
					end

					debris:AddItem(clone2, 1)
					debris:AddItem(clone, 2.5)
					return
				else
					task.wait(0.016666666666666666)
				end
			end
		else
			task.wait(0.016666666666666666)
		end
	end
end