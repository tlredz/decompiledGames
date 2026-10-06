local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local lastTime = tick()
return function(p)
	local startCF = p.StartCF
	local success, result = pcall(function()
		return (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude > 1000
	end)

	if success and result then
		return
	end

	local target = p.Target

	if tick() - lastTime <= 0.05 then
		return
	end

	local clone = ReplicatedStorage.Chest.SwordEffect.Acroscyth.BloodPart:Clone()
	clone.CFrame = CFrame.new(startCF.p)
	clone.Parent = workspace.Effects
	lastTime = tick()
	local v = math.random(10, 40)
	local v2 = math.random(1, 2)
	PeodizService.ForLoop({
		Step = 50
	}, function(p2)
		local v3 = math.floor(p2 * 50)
		clone.CFrame = CFrame.new(startCF.p, target.Position) * CFrame.new(
			0,
			0,
			-(target.Position - startCF.p).Magnitude / 50 * v3
		) * CFrame.new(
			v2 == 1 and math.sin(3.141592653589793 * v3 / 50) * v or math.sin(3.141592653589793 * v3 / 50) * -v,
			0,
			0
		)
	end)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://180083298",
		Volume = 1,
		PlaybackSpeed = 1.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	clone.BloodParticle.Enabled = false
	TweenService:Create(clone, TweenInfo.new(0.25), {
		Transparency = 1
	}):Play()
	wait(0.5)
	clone:Destroy()
end