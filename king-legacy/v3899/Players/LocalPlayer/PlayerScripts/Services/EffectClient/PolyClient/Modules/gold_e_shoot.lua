local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rangeshake(p, value, p2)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude then
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

	local fromcf = data.fromcf
	local tocf = data.tocf
	local magnitude = (fromcf.p - tocf.p).magnitude
	local clone = replicatedStorage.Chest.FruitEffect.Gold.beam:Clone()
	clone.AT1.WorldCFrame = fromcf
	clone.AT2.WorldCFrame = fromcf
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 1)
	TweenService:Create(clone.AT2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		WorldCFrame = CFrame.new(tocf.p - createVector(0, 2, 0))
	}):Play()
	task.spawn(function()
		local clone2 = replicatedStorage.Chest.FruitEffect.Gold.beam_pillar:Clone()
		_G.PU:Dust(clone2, 1)
		clone2.CFrame = CFrame.new(fromcf.p, tocf.p) * CFrame.new(0, 0, -magnitude / 2)
		clone2.Size = Vector3.new(5, 5, magnitude)
		clone2.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://12847710758",
			Volume = 1.25
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone2
		sound:Play()
		wait(0.05)
		rangeshake("SmallerBump", 30, tocf.p) -- equivalent call inferred; original call site unknown

		if clone2:FindFirstChild("spec") then
			clone2.spec:Emit(20)
		end

		TweenService:Create(clone.BeamMain1, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(clone.BeamMain2, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		local clone3 = replicatedStorage.Chest.FruitEffect.Gold.gold_explosion:Clone()
		_G.PU:Dust(clone3, 1)
		clone3.CFrame = CFrame.new(tocf.p - createVector(0, 2, 0))
		clone3.Parent = workspace.Effects
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://12053064330",
			Volume = 2
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone3
		sound2:Play()

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end
	end)
end