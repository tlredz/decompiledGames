local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local mouseFolder = data.MouseFolder
	local charge = data.Charge
	local char = data.Char
	local root = data.Root
	local localPlayer = game.Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
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

	tick()
	local cFrame = root.CFrame
	local value = mouseFolder.Value
	local clone = ReplicatedStorage.Chest.FruitEffect.Toy.nut_cracker:Clone()
	clone.Parent = workspace.Effects
	clone:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 0, -10) * CFrame.Angles(0, -1.5707963267948966, 0))
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15292531792",
		Volume = 1,
		PlaybackSpeed = 1.25
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone.PrimaryPart
	sound:Play()
	_G.PU:Dust(clone, 10)
	local lastTime = tick()
	clone.AnimationController:LoadAnimation(clone.Idle):Play()

	for _, emitter in pairs(clone.spawn_fx:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	localshake("SmallerBump") -- equivalent call inferred; original call site unknown
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15389329223",
		Volume = 1
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone.spawn_fx
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9110516965",
		Volume = 1,
		Looped = true
	})
	_G.PU:Dust(sound3, 5)
	sound3.Parent = clone.spawn_fx
	sound3:Play()
	wait()
	PeodizService.HeartbeatWait({
		Time = 4,
		WaitTime = 0.05
	}, function()
		if not (root and charge:IsDescendantOf(char)) then
			return true
		end

		if tick() - lastTime > 0.25 then
			lastTime = tick()
			local v = 50
			local p = value.p
			local v2 = "SmallerBump"
			task.spawn(function()
				v = v or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
					_G.shake(v2)
				end
			end)
		end

		cFrame = root.CFrame
		value = mouseFolder.Value
		TweenService:Create(
			clone.PrimaryPart,
			TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				CFrame = value * CFrame.Angles(0, -1.5707963267948966, 0)
			}
		):Play()
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = clone.PrimaryPart
		pointLight.Color = Color3.fromRGB(255, 211, 51)
		pointLight.Range = 25
		pointLight.Brightness = 1
		game.TweenService:Create(
			pointLight,
			TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Brightness = 0.25,
				Range = 0
			}
		):Play()
		_G.PU:Dust(pointLight, 0.2)
		task.spawn(function()
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.bullet:Clone()
			clone2.Parent = workspace.Effects
			clone2.CFrame = value * CFrame.new(0, 2, -2) * CFrame.Angles(
				math.rad((math.random(-5, 5))),
				math.rad((math.random(-35, 35))),
				(math.rad((math.random(-35, 35))))
			)
			_G.PU:Dust(clone2, 0.25)
			wait()
			game.TweenService:Create(
				clone2,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone2.CFrame * CFrame.new(0, 0, -math.random(80, 100))
				}
			):Play()
		end)
		task.spawn(function()
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.bullet:Clone()
			clone2.Parent = workspace.Effects
			clone2.CFrame = value * CFrame.new(0, 2, -2) * CFrame.Angles(
				math.rad((math.random(-5, 5))),
				math.rad((math.random(-35, 35))),
				(math.rad((math.random(-35, 35))))
			)
			_G.PU:Dust(clone2, 0.25)
			wait()
			game.TweenService:Create(
				clone2,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone2.CFrame * CFrame.new(0, 0, -math.random(80, 100))
				}
			):Play()
		end)
	end)

	if sound3 and sound3.Parent then
		game.TweenService:Create(sound3, TweenInfo.new(0.5), {
			Volume = 0
		}):Play()
		_G.PU:Dust(sound3, 1)
	end

	wait(0.1)

	if clone then
		local sound4 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://15389322430",
			Volume = 1
		})
		_G.PU:Dust(sound4, 3)
		sound4.Parent = clone.spawn_fx
		sound4:Play()

		if sound and sound.Parent then
			sound:Stop()
		end

		for _, emitter in pairs(clone.Cube:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, part in pairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end
		end

		_G.PU:Dust(clone, 1)
	end
end