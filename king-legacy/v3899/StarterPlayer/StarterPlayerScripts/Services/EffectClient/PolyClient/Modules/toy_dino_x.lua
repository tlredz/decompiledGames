local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
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
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(255, 0, 255)
	}
	local char = data.char
	local root = data.root
	local cFrame = root.CFrame
	local v2 = {
		8,
		10,
		0,
		1
	}
	local v3 = 90
	local p = cFrame.p
	task.spawn(function()
		v3 = v3 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v3 then
			_G.shake(v2)
		end
	end)
	wait(0.5)
	PeodizService.ForLoop({
		Step = 20,
		WaitTime = 0.2
	}, function(p2)
		if char.Humanoid.Health <= 0 then
			return true
		end

		local v4 = math.floor(p2 * 20)
		cFrame = root.CFrame
		local cFrame2 = cFrame * data.fromcf_tbl[v4]
		local cFrame3 = cFrame * data.tocf_tbl[v4]
		local clone = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.meteor:Clone()
		clone.CFrame = cFrame2
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 2)
		clone.Color = v[math.random(1, 5)]
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = cFrame3
		}):Play()
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.meteor_spawn:Clone()
		clone2.CFrame = CFrame.new(cFrame2.p)
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 1)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://15897161691",
			Volume = 3
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone2
		sound:Play()

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		task.spawn(function()
			wait(0.4)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			TweenService:Create(
				clone.PointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Range = 0
				}
			):Play()
			wait()
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.meteor_exp:Clone()
			clone3.CFrame = CFrame.new(cFrame3.p) * CFrame.new(0, 5, 0)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 2)
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15897156465",
				Volume = 10
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone3
			sound2:Play()

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			end

			wait(0.5)
			TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		task.spawn(function()
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.meteor_trail:Clone()
			clone3.Parent = workspace.Effects
			clone3.CFrame = CFrame.new(cFrame2.p, cFrame3.p)
			_G.PU:Dust(clone3, 2)
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.meteor_trail:Clone()
			clone4.Parent = workspace.Effects
			clone4.CFrame = CFrame.new(cFrame2.p, cFrame3.p)
			_G.PU:Dust(clone4, 2)
			PeodizService.ForLoop({
				Step = 25
			}, function(p3)
				local v7 = math.floor(p3 * 25)
				local v8 = 20 - v7 * 0.5
				clone3.CFrame = CFrame.new(cFrame2.p, cFrame3.p) * CFrame.new(
					math.sin(0.18849555921538758 * v7) * v8,
					math.cos(0.18849555921538758 * v7) * v8,
					-v7 * 4
				)
				clone4.CFrame = CFrame.new(cFrame2.p, cFrame3.p) * CFrame.new(
					-math.sin(0.18849555921538758 * v7 + 5) * v8,
					-math.cos(0.18849555921538758 * v7 + 5) * v8,
					-v7 * 4 + 10
				)
				task.wait()
			end)
		end)
	end)
end