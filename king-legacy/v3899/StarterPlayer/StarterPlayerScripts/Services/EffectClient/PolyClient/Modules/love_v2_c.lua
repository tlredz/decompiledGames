local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
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

	wait(0.2)
	local clone = ReplicatedStorage.Chest.FruitEffect.Love.Awake.heart_c:Clone()
	clone.Size = Vector3.new()
	clone.CFrame = CFrame.new(cf.p) * CFrame.new(0, 100, 0) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
		0,
		0,
		6.283185307179586 * math.random()
	)
	clone.Transparency = 0
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 1.5)
	task.spawn(function()
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		wait()
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(90.695, 79.59, 4)
		}):Play()
		wait(0.1)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	wait(0.3)
	PeodizService.ForLoop({
		Step = 50,
		WaitTime = 0.05
	}, function(p2)
		math.floor(p2 * 50)
		local v = p.cf * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(0, 0, math.random(10, 60))
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.harrow:Clone()
		_G.PU:Dust(clone2, 1)
		clone2.CFrame = v * CFrame.Angles(0, 6.283185307179586 * math.random(), (math.rad((math.random(0, 25))))) * CFrame.new(
			0,
			125,
			0
		)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.new(0, -125, 0)
		}):Play()
		clone2.Star:Emit(1)
		clone2.AT1.sharddown:Emit(20)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://15632397413",
			Volume = 0.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone2
		sound:Play()
		task.spawn(function()
			wait(0.1)
			local v2 = {
				2,
				3,
				0,
				0.25
			}
			local v3 = 40
			local p3 = v.p
			task.spawn(function()
				v3 = v3 or 100

				if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < v3 then
					_G.shake(v2)
				end
			end)
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.love_arrow_hit:Clone()
			_G.PU:Dust(clone3, 2)
			clone3.Parent = workspace.Effects
			clone3.CFrame = v * CFrame.new(0, 3, 0)
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15632461482",
				Volume = 0.5
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone3
			sound2:Play()
			TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
			}):Play()

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			end
		end)
	end)
end