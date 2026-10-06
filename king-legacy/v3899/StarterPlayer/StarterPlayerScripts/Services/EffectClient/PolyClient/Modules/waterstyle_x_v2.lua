local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf2.p).Magnitude then
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

	local cf = data.cf
	local cf2 = data.cf2
	local mag = data.Mag
	local speed = data.Speed
	local v = CFrame.new(cf.p, cf2.p) * CFrame.Angles(0, 0, -1.5707963267948966 + 3.141592653589793 * math.random())
	local clone = replicatedStorage2.Chest.MeleeEffect.WaterStyle.V2.X.SharkBullet:Clone()
	clone.CFrame = cf
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 4)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 0,
		RollOffMode = Enum.RollOffMode.Linear,
		SoundId = "rbxassetid://14976068473",
		Volume = 0.5,
		PlaybackSpeed = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	clone.Attachment.ring:Emit(1)
	clone.Attachment.SmallSparks:Emit(3)
	local v2 = 30
	local p = cf.p
	local v3 = "SmallestBump"
	task.spawn(function()
		v2 = v2 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v2 then
			_G.shake(v3)
		end
	end)
	PeodizService.ForLoop({
		Step = speed
	}, function(p2)
		local cframe = CFrame.new(0, math.sin(3.141592653589793 * p2) * speed, -(p2 * speed) * mag)
		game.TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = CFrame.new((v * cframe).p, clone.Position) * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()

		if clone then
			if clone:FindFirstChild("specs") then
				clone.specs:Emit(math.random(0, 1))
			end

			if clone:FindFirstChild("watersmoke") then
				clone.watersmoke:Emit(math.random(0, 1))
			end
		end
	end)
	rangeshake("SmallerBump", 30) -- equivalent call inferred; original call site unknown
	game.TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = Vector3.new()
	}):Play()
	local clone2 = replicatedStorage2.Chest.MeleeEffect.WaterStyle.V2.X.smallball:Clone()
	clone2.Parent = workspace.Effects
	clone2.CFrame = cf2
	clone2.Size = createVector(1, 1, 1) * math.random(15, 20)
	_G.PU:Dust(clone2, 1)
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 0,
		RollOffMode = Enum.RollOffMode.Linear,
		SoundId = "rbxassetid://14976070159",
		Volume = 0.2,
		PlaybackSpeed = 4
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()

	for _, emitter in pairs(clone2:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.spawn(function()
		wait()
		game.TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
	end)
end