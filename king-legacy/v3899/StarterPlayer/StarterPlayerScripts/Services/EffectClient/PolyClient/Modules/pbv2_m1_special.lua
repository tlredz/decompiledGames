local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
return function(p)
	local cf = p.cf
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p2)
		if localPlayer == p.plr then
			_G.shake(p2)
		end
	end

	local function rangeshake(p2, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - p.cf.p).Magnitude then
			_G.shake(p2)
		end
	end

	local function local_rangeshake(p2, value, p3)
		task.spawn(function()
			value = value or 100

			if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < value then
				_G.shake(p2)
			end
		end)
	end

	PeodizService.ForceForLoop({
		Step = 11,
		WaitTime = 0.045
	}, function(_)
		local v = 45
		local p2 = cf.p
		local v2 = "SmallerBump"
		task.spawn(function()
			v = v or 100

			if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v then
				_G.shake(v2)
			end
		end)
		local v3 = cf * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.Angles(
			0.7853981633974483 * math.random(),
			0,
			0
		) * CFrame.new(0, 0, -math.random(15, 20))
		local clone = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.shoot:Clone()
		_G.PU:Dust(clone, 1)
		clone.CFrame = v3 * CFrame.Angles(0, math.random() * 3.141592653589793, 0)
		clone.Anchored = true
		clone.Massless = true
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://12265826457",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8748164748",
			Volume = 1
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone
		sound2:Play()
		local clone2 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.teleport:Clone()
		_G.PU:Dust(clone2, 1)
		clone2.CFrame = clone.CFrame * CFrame.new(0, 0, 12)
		clone2.Parent = workspace.Effects
		task.spawn(function()
			wait()
			local clone3 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.neon:Clone()
			clone3.Parent = workspace.Effects
			clone3.Size = createVector(2, 2, 40)
			clone3.CFrame = cf * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
				0,
				0,
				-clone3.Size.Z / 3
			) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			game.TweenService:Create(
				clone3,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(0, 0, clone3.Size.Z)
				}
			):Play()

			if math.random(1, 2) == 1 then
				clone3.Color = Color3.fromRGB(255, 81, 38)
			end

			_G.PU:Dust(clone3, 0.5)
		end)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		task.spawn(function()
			wait()

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			end
		end)
	end)
end