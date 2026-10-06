local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
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

	local v = 70
	local p2 = p.cf.p
	local v2 = "Bump"
	task.spawn(function()
		v = v or 100

		if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v then
			_G.shake(v2)
		end
	end)
	local clone = ReplicatedStorage.Chest.FruitEffect.Gold.railgun_shoot:Clone()
	_G.PU:Dust(clone, 1.5)
	clone.CFrame = cf * CFrame.new(0, 0, -5)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12584643130",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	task.spawn(function()
		wait(0.05)
		TweenService:Create(
			clone.PointLight,
			TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Brightness = 0.5,
				Range = 0
			}
		):Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6948300574",
			Volume = 1.5
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone
		sound2:Play()
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	local clone2 = ReplicatedStorage.Chest.FruitEffect.Gold.railgun_trail:Clone()
	clone2.CFrame = cf * CFrame.new(0, 0, -47.5)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 1.5)

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end
end