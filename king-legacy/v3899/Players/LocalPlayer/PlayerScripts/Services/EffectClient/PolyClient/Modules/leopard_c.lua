local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
game:GetService("RunService")
return function(data, _)
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

	local char = data.char
	local root = data.root

	if not root then
		return
	end

	local clone = replicatedStorage2.Chest.FruitEffect.Leopard.ray:Clone()
	_G.PU:Dust(clone, 8)
	clone.Parent = root.Parent
	local weld = Instance.new("Weld")
	weld.Parent = root
	weld.Part0 = root
	weld.Part1 = clone.PrimaryPart
	weld.C0 = CFrame.new(0, -3, -25)
	_G.PU:Dust(weld, 8)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15040971243",
		Volume = 0.75
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone.EffectsHolder
	sound:Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	for _, child in pairs(clone.Beams:GetChildren()) do
		child["2"].WorldCFrame = child["1"].WorldCFrame
		TweenService:Create(child["2"], TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Position = child["2"].Position + createVector(0, 0, 75)
		}):Play()
	end

	local pointLight = Instance.new("PointLight")
	pointLight.Color = Color3.fromRGB(255, 122, 61)
	pointLight.Range = 0
	pointLight.Brightness = 1
	pointLight.Parent = clone.PrimaryPart
	task.spawn(function()
		TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 1,
			Range = 40
		}):Play()
	end)
	local lastTime = tick()
	PeodizService.new({
		Time = 10
	}, function()
		if tick() - lastTime > 0.1 then
			lastTime = tick()
			localshake("SmallestBump") -- equivalent call inferred; original call site unknown
		end

		if not (char:IsDescendantOf(workspace) and root ~= nil) then
			return true
		end

		if char:FindFirstChild("LeopardCharge") then
			return
		else
			return true
		end
	end)

	if weld then
		_G.PU:Dust(weld, 1.5)
	end

	if clone then
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, child in pairs(clone.Beams:GetChildren()) do
			TweenService:Create(
				child["2"],
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Position = child["1"].Position
				}
			):Play()
		end

		if sound and sound.Parent then
			TweenService:Create(sound, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
		end

		TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0,
			Range = 0
		}):Play()
		_G.PU:Dust(clone, 1.5)
	end
end