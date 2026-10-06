local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local charge = data.Charge
	local char = data.Char
	local root = data.Root
	local can_mode = data.can_mode
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude then
			_G.shake(p)
		end
	end

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local lastTime = tick()
	local clone = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.ball2:Clone()
	clone.CFrame = root.CFrame * CFrame.new(0, 0, -10)
	clone.Size = Vector3.new()
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 11)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12361984436",
		Volume = 4
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12325531264",
		Volume = 2,
		Looped = true
	})
	_G.PU:Dust(sound2, 11)
	sound2.Parent = clone
	sound2:Play()
	local clone2 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.aura:Clone()
	clone2.CFrame = root.CFrame * CFrame.new(0, 0, -10)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 11)
	TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(4, 4, 4)
	}):Play()
	TweenService:Create(clone.PointLight, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 1,
		Range = 20
	}):Play()
	local v = 1

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	for _, emitter in pairs(clone2:GetChildren()) do
		emitter:IsA("ParticleEmitter")
	end

	clone2.shards.Enabled = true
	clone2.shards2.Enabled = true
	local weld = Instance.new("Weld")
	weld.Parent = clone
	weld.Part0 = root
	weld.Part1 = clone
	weld.C0 = CFrame.new(0, 0, -10)
	_G.PU:Dust(weld, 11)
	local weld2 = Instance.new("Weld")
	weld2.Parent = clone2
	weld2.Part0 = root
	weld2.Part1 = clone2
	weld2.C0 = CFrame.new(0, 0, -10)
	_G.PU:Dust(weld2, 11)
	local v2 = 30
	local p = root.CFrame.p
	local v3 = "SmallBump"
	task.spawn(function()
		v2 = v2 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v2 then
			_G.shake(v3)
		end
	end)

	for _, emitter in pairs(clone.Attachment:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	local function trail(p2)
		local v4 = root.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, -p2)
		local v5 = root.CFrame * CFrame.new(0, 0, -10)
		local clone3 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.trail:Clone()
		clone3.CFrame = CFrame.new(v4.p, v5.p)
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 1)
		local v6 = math.random(1, 2)
		PeodizService.ForLoop({
			Step = 8
		}, function(p3)
			local v7 = math.floor(p3 * 8)
			TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(v4.p, v5.p) * CFrame.new(
					0,
					math.sin(3.141592653589793 * v6 * 0.99 / 8 * v7) * 8,
					-(p2 / 8) * v7
				)
			}):Play()
		end)
	end

	local v4 = false
	local v5 = 25
	PeodizService.HeartbeatWait({
		Time = 10,
		WaitTime = 0.1
	}, function()
		if not charge:IsDescendantOf(char) then
			return true
		end

		v += 1
		task.spawn(function()
			trail(v5)
		end)

		if v4 and localPlayer == data.plr then
			_G.shake("SmallerBump")
		end

		if tick() - lastTime > 3 and can_mode and not v4 then
			TweenService:Create(
				clone.PointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 1.25,
					Range = 30
				}
			):Play()
			TweenService:Create(weld, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				C0 = CFrame.new(0, 0, -13)
			}):Play()
			TweenService:Create(weld2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				C0 = CFrame.new(0, 0, -13)
			}):Play()
			local sound3 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12361991233",
				Volume = 2
			})
			_G.PU:Dust(sound3, 3)
			sound3.Parent = clone
			sound3:Play()
			clone2.star.Enabled = true

			if localPlayer == data.plr then
				task.spawn(function()
					local clone3 = script.inverse:Clone()
					clone3.Parent = game.Lighting
					clone3.Enabled = true
					task.wait(0.1)
					clone3:Destroy()
				end)
			end

			v5 = 35
			v4 = true
			TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(5, 5, 5)
			}):Play()
			local v6 = 30
			local p2 = root.CFrame.p
			local v7 = "Bump"
			task.spawn(function()
				v6 = v6 or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v6 then
					_G.shake(v7)
				end
			end)
			task.spawn(function()
				wait()

				for _, emitter in pairs(clone.Attachment2:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end)

			for _, emitter in pairs(clone.Attachment3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			end
		end
	end)
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12361975858",
		Volume = 4
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone
	sound3:Play()

	if clone2 then
		_G.PU:Dust(clone2, 1)
	end

	if clone then
		TweenService:Create(
			clone.PointLight,
			TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Brightness = 0.5,
				Range = 0
			}
		):Play()
		TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()

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

		_G.PU:Dust(clone, 1)
	end
end