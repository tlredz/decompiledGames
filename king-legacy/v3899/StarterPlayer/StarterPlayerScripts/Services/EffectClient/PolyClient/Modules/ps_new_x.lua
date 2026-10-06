local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
game:GetService("TweenService")
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

	local root = data.root
	local char = data.char

	if not (char and root) then
		return
	end

	local clone = replicatedStorage.Chest.SwordEffect.PumpkinSmasher.smash:Clone()
	clone.Transparency = 1
	clone.Parent = root.Parent
	clone.CFrame = root.CFrame * CFrame.new(0, -1, -2)
	_G.PU:Dust(clone, 5)
	local weld = Instance.new("Weld")
	weld.Parent = root
	weld.Part0 = root
	weld.Part1 = clone
	weld.C0 = CFrame.new(0, -1.5, -8)
	_G.PU:Dust(weld, 5)
	tick()
	local lastTime = tick()
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0.5
	game.TweenService:Create(numberValue, TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		Value = 0.1
	}):Play()
	PeodizService.new({
		Time = 4
	}, function()
		if not (char:IsDescendantOf(workspace) and char:FindFirstChild("PumpkinCharge")) then
			return true
		end

		if tick() - lastTime > numberValue.Value then
			lastTime = tick()
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15166645596",
				PlaybackSpeed = 1.25,
				Volume = 1.5
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
	end)

	if numberValue then
		numberValue:Destroy()
	end
end