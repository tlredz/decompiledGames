local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
game:GetService("RunService")
return function(data, _)
	local localPlayer = game.Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
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

	if not root then
		return
	end

	local clone = replicatedStorage.Chest.FruitEffect.Giraffe.spin:Clone()
	_G.PU:Dust(clone, 5)
	clone.Parent = root.Parent
	local weld = Instance.new("Weld")
	weld.Parent = root
	weld.Part0 = root
	weld.Part1 = clone
	_G.PU:Dust(weld, 5)
	tick()
	local lastTime = tick()
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0.5
	game.TweenService:Create(numberValue, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		Value = 0.1
	}):Play()
	PeodizService.new({
		Time = 4
	}, function()
		if tick() - lastTime > numberValue.Value then
			lastTime = tick()
			localshake("SmallerBump") -- equivalent call inferred; original call site unknown
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15027102042",
				Volume = 3,
				TimePosition = 0.2,
				PlaybackSpeed = 0.9
			})
			_G.PU:Dust(sound, 0.8)
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