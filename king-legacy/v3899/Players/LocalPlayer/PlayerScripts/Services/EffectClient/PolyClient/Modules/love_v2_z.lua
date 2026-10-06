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

	local fromcf = data.fromcf
	local tocf = data.tocf
	local root = data.root
	local _ = (fromcf.p - tocf.p).magnitude
	local speed = data.speed

	if localPlayer == data.plr then
		TweenService:Create(
			localPlayer.Character.HumanoidRootPart,
			TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				CFrame = tocf
			}
		):Play()
	end

	if data.IsBoss then
		TweenService:Create(root, TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = tocf
		}):Play()
	end

	local cFrame = root.CFrame
	local clones = {}
	local v = {}
	local clone = ReplicatedStorage.Chest.FruitEffect.Love.Awake.ZTrail:Clone()
	_G.PU:Dust(clone, speed + 1)
	clone.CFrame = cFrame
	clone.Anchored = false
	clone.Massless = true
	clone.CanCollide = false
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15584112804",
		Volume = 6
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local pointLight = Instance.new("PointLight")
	pointLight.Parent = clone
	pointLight.Color = Color3.fromRGB(238, 0, 255)
	pointLight.Range = 30
	pointLight.Brightness = 1
	_G.PU:Dust(pointLight, speed + 1)
	local weld = Instance.new("Weld")
	weld.Parent = root
	weld.Part0 = root
	weld.Part1 = clone
	_G.PU:Dust(weld, speed + 1)
	localshake("Bump") -- equivalent call inferred; original call site unknown
	task.spawn(function()
		wait(speed)
		clone.Anchored = true
		TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 0.25,
			Range = 0
		}):Play()

		if weld then
			weld:Destroy()
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	local v2 = { CFrame.new(0, 0, 3), (CFrame.new(0, 0, 6)) }

	for i = 1, 2 do
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.smalltrail:Clone()
		clone2.Parent = workspace.Effects
		clone2.Material = Enum.Material.Neon
		clone2.CFrame = cFrame * v2[i]
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = v2[i]
		cFrameValue.Name = "GivenCF"
		cFrameValue.Parent = clone2
		_G.PU:Dust(clone2, speed)
		clones[#clones + 1] = clone2
		v[#v + 1] = cFrameValue
	end

	PeodizService.new({
		Time = speed
	}, function()
		if not root:IsDescendantOf(workspace) then
			return true
		end

		for k, v3 in pairs(clones) do
			local v4 = (k - 1) * 2
			v3.CFrame = root.CFrame * v[k].Value * CFrame.new(
				math.cos((tick() + v4) * 15) * 10,
				math.sin((tick() + v4) * 15) * 10,
				0
			)
		end

		cFrame = root.CFrame
	end)
	task.delay(10, function()
		table.clear(clones)
		table.clear(v)
	end)
	local v3 = {
		4.5,
		9,
		0.35,
		0.66
	}
	local v4 = 60
	local p = tocf.p
	task.spawn(function()
		v4 = v4 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v4 then
			_G.shake(v3)
		end
	end)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.love_kick:Clone()
	_G.PU:Dust(clone2, 3)
	clone2.CFrame = CFrame.new(cFrame.p)
	clone2.Parent = workspace.Effects
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15584118664",
		Volume = 2
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()
	local clone3 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.love_kick_circle:Clone()
	clone3.CFrame = CFrame.new(cFrame.p)
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 2)
	local pointLight2 = Instance.new("PointLight")
	pointLight2.Parent = clone2
	pointLight2.Color = Color3.fromRGB(238, 0, 255)
	pointLight2.Range = 60
	pointLight2.Brightness = 1
	_G.PU:Dust(pointLight2, 1)
	TweenService:Create(pointLight2, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = 0
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone3.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
	}):Play()

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	for _, emitter in pairs(clone3:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	wait(0.15)
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15586433172",
		Volume = 2
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone2
	sound3:Play()
	wait(0.35)

	if localPlayer == data.plr then
		local clone4 = script.cc:Clone()
		clone4.Parent = game.Lighting
		_G.PU:Dust(clone4, 1)
		task.spawn(function()
			wait()
			TweenService:Create(clone4, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				TintColor = Color3.fromRGB(255, 255, 255)
			}):Play()
		end)
	end

	local v5 = {
		7.5,
		11,
		0.1,
		0.88
	}
	local v6 = 60
	local p2 = tocf.p
	task.spawn(function()
		v6 = v6 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v6 then
			_G.shake(v5)
		end
	end)
	local clone4 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.heart_z:Clone()
	clone4.Parent = workspace.Effects
	clone4.CFrame = CFrame.new(cFrame.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	clone4.Size = Vector3.new()
	clone4.Transparency = -1
	_G.PU:Dust(clone4, 1.5)
	local clone5 = ReplicatedStorage.Chest.FruitEffect.Love.Awake.love_upperkick:Clone()
	clone5.Parent = workspace.Effects
	clone5.CFrame = CFrame.new(cFrame.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	_G.PU:Dust(clone5, 2)
	TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(82.1415, 67.577995, 44.2545)
	}):Play()
	TweenService:Create(clone4, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone4.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	task.spawn(function()
		wait(0.05)
		TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	for _, emitter in pairs(clone5:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end
end