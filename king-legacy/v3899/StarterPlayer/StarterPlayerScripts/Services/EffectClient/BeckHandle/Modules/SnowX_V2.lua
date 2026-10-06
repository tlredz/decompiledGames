local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("Debris")
local effects = workspace.Effects
local Utility = require(ReplicatedStorage.Chest.Modules:WaitForChild("Utility"))
local PeodizService = require(ReplicatedStorage.Chest.Modules:WaitForChild("PeodizService"))
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local snow = ReplicatedStorage.Chest.FruitEffect.Snow
local localPlayer = game.Players.LocalPlayer
return function(list)
	local _, v, v2, _ = unpack(list)
	local _ = v2.Character
	local rootPart = v2.RootPart
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://16470315014",
		Volume = 1
	})
	_G.PU:Dust(sound, 6)
	sound.Parent = rootPart
	sound:Play()
	local clone = snow.X.snow_edge:Clone()
	clone.Parent = effects
	clone.CFrame = rootPart.CFrame
	_G.PU:Dust(clone, 6)
	local clone2 = snow.X.snow_fade:Clone()
	clone2.Parent = effects
	clone2.CFrame = rootPart.CFrame
	_G.PU:Dust(clone2, 6)
	local clone3 = snow.X.clouds:Clone()
	clone3.PrimaryPart.CFrame = CFrame.new(rootPart.CFrame.p) * CFrame.new(0, 80, 0)
	clone3.Parent = effects
	clone3.PrimaryPart.Circles.Enabled = true
	clone3.PrimaryPart.snow2.Enabled = true
	_G.PU:Dust(clone3, 6)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local lastTime = tick()
	local v3 = {}

	local function shoot_beam(cFrame)
		local v4 = cFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
			0,
			math.random(45, 60),
			math.random(45, 70)
		)
		local v5 = cFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
			0,
			0,
			math.random(45, 70)
		)
		local magnitude = (v4.p - v5.p).magnitude
		local part = Instance.new("Part")
		part.CFrame = CFrame.new(v4.p, v5.p)
		part.Size = createVector(6, 6, 0)
		part.Color = Color3.fromRGB(172, 208, 255)
		part.Anchored = true
		part.CanCollide = false
		part.Material = Enum.Material.Neon
		_G.PU:Dust(part, 10)
		part.Parent = effects
		v3[#v3 + 1] = part
		TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
			Size = Vector3.new(2, 2, magnitude),
			CFrame = part.CFrame * CFrame.new(0, 0, -magnitude / 2)
		}):Play()
		task.spawn(function()
			wait(0.05)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(178, 208, 255)
			}):Play()
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, magnitude)
			}):Play()
			local v6 = CFrame.new(v4.p, v5.p) * CFrame.new(0, 0, -magnitude)
			local clone4 = snow.X.hit:Clone()
			clone4.Parent = effects
			clone4.CFrame = CFrame.new(v6.p)
			_G.PU:Dust(clone4, 2)
			Utility.EmitParticles(clone4)
			wait(0.2)
			part.Transparency = 1
		end)
	end

	local count = 0
	PeodizService.new({
		Time = 3
	}, function(p)
		count += 1
		local v4 = math.floor(p * count)
		TweenService:Create(
			clone3.PrimaryPart,
			TweenInfo.new(0.77, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				CFrame = CFrame.new(rootPart.CFrame.p) * CFrame.new(0, 80, 0) * CFrame.Angles(0, math.rad(v4), 0)
			}
		):Play()

		if tick() - lastTime > 0.1 then
			lastTime = tick()
			shoot_beam(rootPart.CFrame)
		end

		clone.CFrame = CFrame.new(rootPart.CFrame.p)
		clone2.CFrame = CFrame.new(rootPart.CFrame.p)
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	clone3.PrimaryPart.Circles.Enabled = false
	clone3.PrimaryPart.snow2.Enabled = false

	if (localPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude < 200 then
		_G.CameraShake:ShakeOnce(8, 16, 0, 0.77)
	end

	PeodizService.ForLoop({
		Step = #v3
	}, function(p)
		local v4 = math.floor(p * #v3)
		local v5 = v3[v4]
		_G.PU:Dust(v5, 0.35)
		v5.Transparency = 0
		v5.Size = Vector3.new(6, 6, v5.Size.Z)
		v5.Color = Color3.fromRGB(0, 0, 0)
		task.spawn(function()
			wait()
			v5.Color = Color3.fromRGB(178, 208, 255)
		end)

		if v4 % 2 == 0 then
			local clone4 = snow.X.slash:Clone()
			clone4.CFrame = v5.CFrame
			clone4.Parent = effects
			_G.PU:Dust(clone4, 3)
			Utility.EmitParticles(clone4)
			local clone5 = snow.X.slash2:Clone()
			clone5.Parent = effects
			clone5.CFrame = v5.CFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			) * CFrame.new(0, 0, math.random(5, 15))
			_G.PU:Dust(clone5, 0.5)
			Utility.EmitParticles(clone5)
		end

		task.spawn(function()
			task.wait()
			TweenService:Create(v5, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, v5.Size.Z * 1.5)
			}):Play()
		end)
	end)
	v3 = {}
end