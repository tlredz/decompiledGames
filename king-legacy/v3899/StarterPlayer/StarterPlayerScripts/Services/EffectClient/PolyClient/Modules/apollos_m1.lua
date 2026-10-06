local replicatedStorage = game.ReplicatedStorage
game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(p, _)
	local cf = p.cf
	local player = p.Player

	if game.Players.LocalPlayer == player then
		_G.shake("SmallerBump")
	end

	for _ = 1, math.random(2, 3) do
		local clone = replicatedStorage.Chest.SwordEffect.Apollos.symbol:Clone()
		_G.PU:Dust(clone, 1.5)
		clone.CFrame = cf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, math.random(30, 40))
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://10860758942",
			Volume = 0.25
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		task.spawn(function()
			local ModuleScript = require(clone.ModuleScript)
			ModuleScript()
		end)
	end

	local clone = replicatedStorage.Chest.SwordEffect.Apollos.fx_sphere:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = cf
	clone.flare:Emit(30)
	clone.flare2:Emit(30)
	_G.PU:Dust(clone, 1.5)
	local clone2 = replicatedStorage.Chest.SwordEffect.Apollos.wind_ring:Clone()
	_G.PU:Dust(clone2, 1)
	clone2.Parent = workspace.Effects
	clone2.CFrame = CFrame.new(cf.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6313682232",
		PlaybackSpeed = 1.5,
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	local ModuleScript = require(clone2.ModuleScript)
	ModuleScript(50)
end