local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(data, _)
	local fromcf = data.fromcf
	local tocf = data.tocf
	local ti = data.ti
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

	local clone = replicatedStorage2.Chest.Etc.DragonClaw.DragonClawV2.flame_slash:Clone()
	clone.CastShadow = false
	clone.CFrame = CFrame.new(fromcf.p, tocf.p)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 5)
	TweenService:Create(clone, TweenInfo.new(ti, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = tocf
	}):Play()
	wait(ti * 0.4)
	local clone2 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.flame_exp:Clone()
	clone2.CFrame = CFrame.new(tocf.p)
	clone2.Parent = workspace.Effects

	for _, emitter in pairs(clone2.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	_G.PU:Dust(clone2, 1)
	TweenService:Create(clone2.PointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = 10
	}):Play()
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6814067199",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8748164748",
		PlaybackSpeed = 0.85,
		Volume = 2
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()
	local v = 60
	local p = tocf.p
	local v2 = "SmallBump"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
			_G.shake(v2)
		end
	end)

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		end

		if descendant:IsA("Decal") then
			TweenService:Create(
				descendant,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end
	end

	_G.PU:Dust(clone, 1)
end