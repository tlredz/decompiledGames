local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local TweenService = game:GetService("TweenService")
return function(data)
	local fromcf = data.fromcf
	local tocf = data.tocf
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

	localshake("SmallBump") -- equivalent call inferred; original call site unknown
	local step = math.max(math.floor((fromcf.p - tocf.p).magnitude / 9), 2) - 1
	local v2 = {}
	local clone = ReplicatedStorage.Chest.FruitEffect.Venom.New.head:Clone()
	clone.CFrame = CFrame.new(fromcf.p, tocf.p)
	clone.Color = Color3.fromRGB(195, 51, 54)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11633780899",
		Volume = 1.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	task.spawn(function()
		for _ = 1, 2 do
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Venom.New.WindRing_Demon:Clone()
			clone2.CFrame = CFrame.new(fromcf.p, tocf.p) * CFrame.Angles(0, -1.5707963267948966, 0)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			task.spawn(function()
				local ModuleScript = require(clone2.ModuleScript)
				ModuleScript()
			end)
			wait()
		end
	end)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball_Demon:Clone()
	clone2.Size = createVector(0, 0, 0)
	clone2.CFrame = CFrame.new(fromcf.p, tocf.p)
	clone2.Parent = workspace.Effects
	clone2.Attachment.sm2:Emit(10)
	clone2.Attachment.Spark:Emit(2)
	TweenService:Create(clone2, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(25, 25, 1.5)
	}):Play()
	task.spawn(function()
		wait(0.35)
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	_G.PU:Dust(clone2, 1)
	PeodizService.ForLoop({
		Step = step,
		WaitTime = 0.05
	}, function(p)
		local v3 = math.floor(p * step)
		v2[v3] = CFrame.new(fromcf.p, tocf.p) * CFrame.new(0, 0, v3 * -12 + 12) * CFrame.new(0, 0, -6)

		if v3 % 2 == 0 then
			for _ = 1, math.random(1, 2) do
				local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball_Demon:Clone()
				clone3.Size = createVector(6, 6, 6)
				clone3.CFrame = v2[v3] * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				clone3.Parent = workspace.Effects
				TweenService:Create(
					clone3,
					TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone3.CFrame * CFrame.new(0, 0, math.random(7, 12))
					}
				):Play()
				task.spawn(function()
					wait(0.15)
					TweenService:Create(clone3, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new()
					}):Play()
				end)
				_G.PU:Dust(clone3, 1)
			end
		end

		local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.New.tail:Clone()
		clone3.CFrame = v2[v3]
		clone3.Color = Color3.fromRGB(195, 51, 54)
		clone3.Size = createVector(0, 0, 8.5)
		clone3.Parent = workspace.Effects
		TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(6.5, 7, 12)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = v2[v3] * CFrame.new(0, 0, -12)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone3.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
		}):Play()
		_G.PU:Dust(clone3, 1)
		task.spawn(function()
			wait(0.35)
			TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 12),
				Transparency = 1
			}):Play()
		end)
	end)
	local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.New.poison_explode_big_Demon:Clone()
	_G.PU:Dust(clone3, 2)
	clone3.CFrame = CFrame.new(tocf.p)
	clone3.Parent = workspace.Effects
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://365002938",
		Volume = 1
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone3
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11594475441",
		Volume = 1.25
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone3
	sound3:Play()

	for _, emitter in pairs(clone3:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if emitter:GetAttribute("EmitCount") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		else
			emitter:Emit(20)
		end
	end

	task.spawn(function()
		PeodizService.ForLoop({
			Step = 3,
			WaitTime = 0.05
		}, function(_)
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Venom.Shockowave:Clone()
			clone4.CFrame = tocf * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			clone4.Parent = workspace.Effects
			_G.PU:Dust(clone4, 1)
			TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(66.986, 7.43, 66.987) * math.random(150, 200) / 100
			}):Play()
			spawn(function()
				wait()
				TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
		end)
	end)
	local clone4 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball_Demon:Clone()
	clone4.Size = createVector(0, 0, 0)
	clone4.Material = Enum.Material.Neon
	clone4.CFrame = tocf
	clone4.Parent = workspace.Effects
	TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(70, 70, 70),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone4, 1)
	local v3 = 75
	local p = data.tocf.p
	local v4 = "Bump"
	task.spawn(function()
		v3 = v3 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v3 then
			_G.shake(v4)
		end
	end)
	task.spawn(function()
		wait(0.35)
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 25),
			Transparency = 1
		}):Play()
	end)
	_G.PU:Dust(clone, 1)
end