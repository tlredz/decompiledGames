local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
game:GetService("RunService")
return function(p, _)
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

	local cf = p.cf
	local v = 45
	local p2 = cf.p
	local v2 = "Bump"
	task.spawn(function()
		v = v or 100

		if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v then
			_G.shake(v2)
		end
	end)
	local clone = replicatedStorage.Chest.FruitEffect.Giraffe.headbutt:Clone()
	_G.PU:Dust(clone, 2.2)
	clone.CFrame = cf * CFrame.new(0, 1, -40)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15017903210",
		Volume = 2.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end
end