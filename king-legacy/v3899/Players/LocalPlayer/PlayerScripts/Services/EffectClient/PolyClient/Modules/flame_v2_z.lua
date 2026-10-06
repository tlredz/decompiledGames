local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
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

	local _ = data.cfs
	local cf = data.cf
	task.spawn(function()
		if (cf.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 150 then
			_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
		end
	end)
	local clone = replicatedStorage.Chest.FruitEffect.Flame.V2.fist_exp:Clone()
	clone.CFrame = cf
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 1.5)
	local v = {
		RollOffMaxDistance = 500,
		RollOffMinDistance = 0,
		RollOffMode = Enum.RollOffMode.Linear,
		SoundId = "rbxassetid://14968313699",
		Volume = 1
	}
	local sound = PeoUtils.CreateSound(v)
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	wait(0.1)

	for i = 1, 5 do
		local v2 = i
		task.spawn(function()
			local cf2 = data.cfs[v2]
			local clone2 = replicatedStorage.Chest.FruitEffect.Flame.V2.firemoth:Clone()
			clone2.PrimaryPart.CFrame = CFrame.new(cf.p, cf2.p)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 2.5)
			clone2.AnimationController:LoadAnimation(clone2.Animation):Play()
			local v3 = (cf.p - cf2.p).magnitude / 60
			TweenService:Create(
				clone2.PrimaryPart,
				TweenInfo.new(v3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CFrame = cf2
				}
			):Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://14968312909",
				Volume = 1,
				PlaybackSpeed = 0.8
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone2.mOTH
			sound2:Play()
			wait(0.33 + v3)

			if sound2 and sound2.Parent then
				sound2:Stop()
			end

			local clone3 = replicatedStorage.Chest.FruitEffect.Flame.V2.buttefly_exp:Clone()
			_G.PU:Dust(clone3, 2)
			clone3.CFrame = CFrame.new(cf2.p)
			clone3.Parent = workspace.Effects
			local sound3 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://14816787037",
				Volume = 1.5
			})
			_G.PU:Dust(sound3, 3)
			sound3.Parent = clone3
			sound3:Play()
			local pointLight = Instance.new("PointLight")
			pointLight.Color = Color3.fromRGB(255, 81, 0)
			pointLight.Range = 60
			pointLight.Brightness = 1
			pointLight.Parent = clone3
			TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Brightness = 0.5,
				Range = 0
			}):Play()
			localshake("SmallBump2") -- equivalent call inferred; original call site unknown

			for i2, emitter in pairs(clone3.Attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			TweenService:Create(
				clone2.PrimaryPart,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()

			for i2, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	end
end