local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
game:GetService("RunService")
return function(data, _)
	local localPlayer = game.Players.LocalPlayer

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local cf = data.cf
	local range = data.range
	local v = 45
	local p = cf.p
	local v2 = "Bump"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
			_G.shake(v2)
		end
	end)
	local clone = replicatedStorage.Chest.FruitEffect.Leopard.thrust:Clone()
	_G.PU:Dust(clone, 2.2)
	clone.Size = Vector3.new(10, 10, range * 2)
	clone.CFrame = cf * CFrame.new(0, 0, -range)
	clone.Attachment.WorldCFrame = data.tocf
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9191515635",
		Volume = 1,
		PlaybackSpeed = 1.66
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15034025797",
		Volume = 2.5,
		PlaybackSpeed = 1.1
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone.Attachment
	sound2:Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end
end