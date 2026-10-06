local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
game:GetService("TweenService")
return function(p, _)
	local localPlayer = game.Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
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

	localshake("Bump") -- equivalent call inferred; original call site unknown
	local cf = p.cf
	local clone = replicatedStorage.Chest.SwordEffect.CeruleanBlossom.enchant_armament:Clone()
	clone.CFrame = cf * CFrame.new(0, -3.2, 0)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 3)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://13274862962",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://13274861738",
		Volume = 1.25
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()
	clone.Attachment.circle:Emit(1)
	clone.Attachment.circle2:Emit(1)
	clone.Attachment.circle3:Emit(1)
	clone.Attachment.ring:Emit(1)
	clone.beam:Emit(8)
	clone.spikes:Emit(25)
	clone.shard:Emit(30)

	for _ = 1, 6 do
		clone.ring:Emit(1)
		wait(0.1)
	end
end