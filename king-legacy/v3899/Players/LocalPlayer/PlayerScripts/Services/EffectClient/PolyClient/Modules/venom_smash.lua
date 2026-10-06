local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
return function(data)
	local localPlayer = game.Players.LocalPlayer
	local cf = data.cf
	local _ = data.plr
	local _ = data.state

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	PeodizService.ForceForLoop({
		Step = 3,
		WaitTime = 0.125
	}, function(p)
		local v = math.floor(p * 3)
		local clone = ReplicatedStorage.Chest.FruitEffect.Venom.New.smash_fx:Clone()
		_G.PU:Dust(clone, 2)
		clone.CFrame = cf * CFrame.new(0, -3, v * -40)
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6814067199",
			Volume = 2.5,
			PlaybackSpeed = 0.75
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		local crack = require(script.crack)
		crack(cf * CFrame.new(0, 2, v * -40))
		local v2 = 50
		local v3 = cf * CFrame.new(0, -3, v * -40)
		local v4 = "Bump"
		task.spawn(function()
			v2 = v2 or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - v3).Magnitude < v2 then
				_G.shake(v4)
			end
		end)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end
	end)
end