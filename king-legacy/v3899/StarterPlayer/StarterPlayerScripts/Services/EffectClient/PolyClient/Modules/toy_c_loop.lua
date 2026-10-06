local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local _ = data.cf
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

	local v = {
		Fire = Color3.fromRGB(202, 0, 0),
		Heal = Color3.fromRGB(79, 202, 42),
		Ice = Color3.fromRGB(22, 130, 202),
		Water = Color3.fromRGB(0, 55, 255)
	}
	local v2 = {
		Fire = Color3.fromRGB(255, 0, 0),
		Heal = Color3.fromRGB(100, 255, 53),
		Ice = Color3.fromRGB(28, 164, 255),
		Water = Color3.fromRGB(0, 55, 255)
	}
	local charge = data.charge
	local char = data.char
	local root = data.root
	local ran_tbl = data.ran_tbl
	local clones = {}
	task.spawn(function()
		for i = 1, 2 do
			local clone = ReplicatedStorage.Chest.FruitEffect.Toy.small_gift:Clone()
			_G.PU:Dust(clone, 11)
			clone.Size = Vector3.new()
			clone.Cube.Size = Vector3.new()
			clone.Cube.Color = v[ran_tbl[i + 1]]
			clone.Anchored = true
			clone.CFrame = root.CFrame * CFrame.new(i / 5 + -5, 0, i * 3 + -5) * CFrame.new(
				i / 5 + -5,
				0,
				i * 3.25 + -5
			) * CFrame.Angles(0, -0.7853981633974483, 0) * CFrame.new(0, math.sin(i * 5 + tick() * 2), 0)
			clone.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15430242701",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			clones[#clones + 1] = clone
			local folder = clone
			local v3 = i
			task.spawn(function()
				wait()

				for i2, emitter in pairs(folder:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Color = ColorSequence.new(v2[ran_tbl[v3 + 1]])
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				TweenService:Create(folder, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(1.433, 1.262, 1.433)
				}):Play()
				TweenService:Create(folder.Cube, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(1.574, 1.832, 1.706)
				}):Play()
			end)
			wait(0.15)
		end
	end)
	PeodizService.new({
		Time = 10
	}, function()
		if not charge:IsDescendantOf(char) or char.Humanoid.Health <= 0 then
			return true
		end

		for k, v3 in pairs(clones) do
			v3.CFrame = root.CFrame * CFrame.new(-5 + k / 5, 0, -5 + 3.25 * k) * CFrame.Angles(
				0,
				-0.7853981633974483,
				0
			) * CFrame.new(0, math.sin(k * 5 + tick() * 2), 0)
		end
	end)

	for _, v3 in pairs(clones) do
		wait(0.25)

		for _, emitter in pairs(v3.despawn:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(2)
			end
		end

		TweenService:Create(v3, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
		TweenService:Create(v3.Cube, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
		_G.PU:Dust(v3, 1)
	end

	task.delay(10, function()
		table.clear(clones)
	end)
end