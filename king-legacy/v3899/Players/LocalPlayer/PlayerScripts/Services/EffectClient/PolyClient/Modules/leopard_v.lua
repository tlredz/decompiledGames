local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
game:GetService("RunService")
return function(data, _)
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

	local head = data.head
	local clone = replicatedStorage.Chest.FruitEffect.Leopard.LeopardRoar:Clone()
	_G.PU:Dust(clone, 5)
	clone.Parent = head.Parent
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15035839446",
		Volume = 1.25,
		PlaybackSpeed = 0.88
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local weld = Instance.new("Weld")
	weld.Parent = head
	weld.Part0 = head
	weld.Part1 = clone
	_G.PU:Dust(weld, 5)
	local v = 90
	local p = head.CFrame.p
	local v2 = "Roar"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
			_G.shake(v2)
		end
	end)
	task.spawn(function()
		if localPlayer == data.plr then
			local clone2 = replicatedStorage.Chest.Etc.Blur:Clone()
			clone2.Enabled = true
			clone2.Parent = workspace.CurrentCamera
			clone2.Size = 0
			_G.PU:Dust(clone2, 1.5)
			local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
			TweenService:Create(
				clone2,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 10, true, 0),
				{
					Size = 20
				}
			):Play()
			wait(0.5)
			TweenService:Create(clone2, tweenInfo, {
				Size = 0
			}):Play()
		end
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		local v3 = emitter
		task.spawn(function()
			wait(0.55)
			v3.Enabled = false
		end)
	end
end