local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local _ = data.MouseFolder
	local _ = data.Charge
	local _ = data.Char
	local _ = data.Root
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
	local fromcf = data.fromcf
	local tocf = data.tocf
	local clone = ReplicatedStorage.Chest.FruitEffect.Toy.gun_pull:Clone()
	_G.PU:Dust(clone, 2)
	clone.CFrame = fromcf
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 0,
		RollOffMode = Enum.RollOffMode.Linear,
		SoundId = "rbxassetid://15545821891",
		Volume = 0.33
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
		CFrame = tocf
	}):Play()
	local pointLight = Instance.new("PointLight")
	pointLight.Parent = clone
	pointLight.Color = Color3.fromRGB(255, 211, 51)
	pointLight.Range = 30
	pointLight.Brightness = 0.5
	task.spawn(function()
		wait(1)
		TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Range = 0,
			Brightness = 0.25
		}):Play()

		if sound and sound.Parent then
			TweenService:Create(sound, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
		end
	end)
	localshake("Bump") -- equivalent call inferred; original call site unknown
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.bazooka_shoot:Clone()
	_G.PU:Dust(clone2, 2)
	clone2.CFrame = fromcf * CFrame.new(0, 0, -3.5) * CFrame.Angles(0, 3.141592653589793, 0)
	clone2.Parent = workspace.Effects
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 0,
		RollOffMode = Enum.RollOffMode.Linear,
		SoundId = "rbxassetid://15545819224",
		Volume = 0.45
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") * 1.5)
		end
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
		emitter.Enabled = true
		local v = emitter
		task.spawn(function()
			wait(0.5)

			if v.Name == "trail" then
				v.Enabled = false
			end

			wait(0.5)
			v.Enabled = false
		end)
	end

	task.spawn(function()
		PeodizService.ForLoop({
			Step = 4,
			WaitTime = 0.25
		}, function(_)
			if clone:IsDescendantOf(workspace) and (localPlayer.Character.HumanoidRootPart.Position - clone.CFrame.p).Magnitude < 100 then
				_G.shake({
					2,
					3,
					0.25,
					0.75
				})
			end
		end)
	end)
end