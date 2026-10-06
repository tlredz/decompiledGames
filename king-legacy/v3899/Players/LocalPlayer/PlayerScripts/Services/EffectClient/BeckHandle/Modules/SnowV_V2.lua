local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("Debris")
local effects = workspace.Effects
local Utility = require(ReplicatedStorage.Chest.Modules:WaitForChild("Utility"))
local PeodizService = require(ReplicatedStorage.Chest.Modules:WaitForChild("PeodizService"))
local snow = ReplicatedStorage.Chest.FruitEffect.Snow
local localPlayer = game.Players.LocalPlayer
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(list)
	local _, v, v2, _ = unpack(list)
	local character = v2.Character
	local rootPart = v2.RootPart
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://16470322428",
		Volume = 1.5
	})
	_G.PU:Dust(sound, 2)
	sound.Parent = rootPart
	sound:Play()
	local clone = snow.V.globe:Clone()
	clone.CFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
	clone.Size = Vector3.new()
	clone.Anchored = false
	clone.Parent = effects
	_G.PU:Dust(clone, 2.5)
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(1.5, 1.5, 1.5)
	}):Play()

	for _, emitter in pairs(clone.Attachment:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local weld = Instance.new("Weld")
	weld.Part0 = clone
	weld.Part1 = character.RightHand
	weld.C0 = CFrame.new(0, 0, 0)
	weld.Parent = clone
	wait(1)
	Utility.EmitParticles(clone.exp)

	if (localPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude < 200 then
		_G.CameraShake:ShakeOnce(6, 16, 0, 0.3)
		Utility.BloomBlur()
	end

	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = Vector3.new()
	}):Play()

	for _, emitter in pairs(clone.Attachment:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local clone2 = snow.V.foot_fx:Clone()
	clone2.CFrame = CFrame.new(v.p) * CFrame.new(0, -4, 0)
	clone2.Parent = effects
	_G.PU:Dust(clone2, 3)
	Utility.EmitParticles(clone2)
	wait(0.1)
	local clone3 = snow.V.domain:Clone()
	clone3.Size = Vector3.new()
	clone3.CFrame = v * CFrame.new(0, -2.5, 0)
	clone3.Parent = effects
	_G.PU:Dust(clone3, 6)
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://16470326156",
		Volume = 1.25
	})
	_G.PU:Dust(sound2, 6)
	sound2.Parent = clone3
	sound2:Play()
	local clone4 = snow.V.snowing:Clone()
	clone4.CFrame = v * CFrame.new(0, 212.5, 0)
	clone4.Parent = effects
	_G.PU:Dust(clone4, 6)
	local lastTime = tick()
	local lastTime2 = tick()
	TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(400, 400, 400)
	}):Play()
	wait(0.15)

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local v3 = math.clamp((tick() - lastTime) * 5.5, 0, 12)
	local clone5 = snow.V.spiral:Clone()
	clone5.CFrame = v * CFrame.Angles(0, (tick() - lastTime) * v3, 0) * CFrame.new(0, math.sin((tick())) * 8 + 16, -220)
	clone5.Parent = effects
	_G.PU:Dust(clone5, 4)
	local clone6 = snow.V.spiral:Clone()
	clone6.CFrame = v * CFrame.Angles(0, 3.141592653589793 + (tick() - lastTime) * v3, 0) * CFrame.new(
		0,
		math.sin(tick() * 2) * 10 + 14,
		-220
	)
	clone6.Parent = effects
	_G.PU:Dust(clone6, 4)
	PeodizService.new({
		Time = 4
	}, function(_)
		v3 = math.clamp((tick() - lastTime) * 5.5, 0, 12)
		clone5.CFrame = v * CFrame.Angles(0, (tick() - lastTime) * v3, 0) * CFrame.new(
			0,
			math.sin((tick())) * 8 + 16,
			-220
		)
		clone6.CFrame = v * CFrame.Angles(0, 3.141592653589793 + (tick() - lastTime) * v3, 0) * CFrame.new(
			0,
			math.sin(tick() * 2) * 10 + 14,
			-220
		)

		if tick() - lastTime2 > 0.1 then
			lastTime2 = tick()
			local v6 = v * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
				0,
				0,
				math.random(0, 200)
			)
			local v7 = v * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
				0,
				0,
				math.random(0, 200)
			)

			if (localPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude < 200 then
				_G.CameraShake:ShakeOnce(4, 4, 0, 0.2)
			end

			local ray = Ray.new(v6.p + createVector(0, 100, 0), createVector(0, -300, 0))
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			local instance

			if raycastResult then
				instance = raycastResult.Instance or nil
			else
				instance = nil
			end

			local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

			for _ = 1, 2 do
				local clone7 = snow.V.snowball:Clone()
				clone7.CFrame = v7 * CFrame.new(0, math.random(200, 250), 0)
				clone7.Size = createVector(0, 25, 0)
				clone7.Parent = effects
				_G.PU:Dust(clone7, 3)
				TweenService:Create(clone7, TweenInfo.new(0.44, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					Size = createVector(14, 15, 14)
				}):Play()
				task.spawn(function()
					wait()
					local cframe = v7 * CFrame.new(0, -1, 0)

					if instance then
						local vector2 = Vector3.new(cframe.Position.X, position.Y, cframe.Position.Z)
						cframe = CFrame.new(vector2)
					elseif not instance and position.Y < -3.35 then
						local vector2 = Vector3.new(cframe.Position.X, -3.35, cframe.Position.Z)
						cframe = CFrame.new(vector2)
					end

					TweenService:Create(
						clone7,
						TweenInfo.new(0.66, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = cframe
						}
					):Play()
					wait(0.3)
					TweenService:Create(
						clone7,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(15, 0, 15)
						}
					):Play()

					if clone7:FindFirstChild("Attachment") then
						Utility.EmitParticles(clone7.Attachment)
					end

					wait(0.25)

					if clone7 then
						TweenService:Create(
							clone7,
							TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end
				end)
			end

			if instance then
				local clone7 = snow.V.paddle:Clone()
				clone7.Material = "SmoothPlastic"
				clone7.Color = Color3.fromRGB(209, 230, 236)
				clone7.CanCollide = false
				clone7.Anchored = true
				clone7.Massless = true
				clone7.CFrame = CFrame.new(position + createVector(0, 0.75, 0))
				clone7.Size = Vector3.new(math.rad(5, 15), 10, (math.rad(5, 15)))
				clone7.Orientation = Vector3.new(0, math.random(-360, 360), 0)
				clone7.Parent = effects
				_G.PU:Dust(clone7, 5)
				TweenService:Create(clone7, TweenInfo.new(0.66, Enum.EasingStyle.Exponential), {
					Size = Vector3.new(85 * math.random(10, 15) / 10, math.random(3, 4), 85 * math.random(10, 15) / 10)
				}):Play()
				delay(4, function()
					TweenService:Create(clone7, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
						Size = Vector3.new(clone7.Size.X * 0.5, 0.25, clone7.Size.Z * 0.5)
					}):Play()
					wait(0.25)
					TweenService:Create(clone7, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
						Transparency = 1
					}):Play()
				end)
			elseif not instance and position.Y < -3.35 then
				local clone7 = snow.V.paddle:Clone()
				clone7.Material = "SmoothPlastic"
				clone7.Color = Color3.fromRGB(209, 230, 236)
				clone7.CanCollide = false
				clone7.Anchored = true
				clone7.Massless = true
				clone7.CFrame = CFrame.new(position.X, -3.35, position.Z)
				clone7.Size = Vector3.new(math.rad(5, 15), 10, (math.rad(5, 15)))
				clone7.Orientation = Vector3.new(0, math.random(-360, 360), 0)
				clone7.Parent = effects
				_G.PU:Dust(clone7, 5)
				TweenService:Create(clone7, TweenInfo.new(0.66, Enum.EasingStyle.Exponential), {
					Size = Vector3.new(85 * math.random(10, 15) / 10, math.random(3, 4), 85 * math.random(10, 15) / 10)
				}):Play()
				delay(4, function()
					TweenService:Create(clone7, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
						Size = Vector3.new(clone7.Size.X * 0.5, 0.25, clone7.Size.Z * 0.5)
					}):Play()
					wait(0.25)
					TweenService:Create(clone7, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
						Transparency = 1
					}):Play()
				end)
			end
		end
	end)

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	TweenService:Create(clone3, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
end