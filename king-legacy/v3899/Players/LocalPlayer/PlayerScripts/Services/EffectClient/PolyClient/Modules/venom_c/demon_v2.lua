local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
return function(p)
	local cf = p.cf
	local v = cf * CFrame.new(0, 150, 0)
	local localPlayer = game.Players.LocalPlayer

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

	local v2 = 100
	local p2 = p.cf.p
	local v3 = "Bump"
	task.spawn(function()
		v2 = v2 or 100

		if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v2 then
			_G.shake(v3)
		end
	end)

	if localPlayer == p.plr then
		local clone = script.bw:Clone()
		clone.Parent = game.Lighting
		_G.PU:Dust(clone, 0.1)
	end

	local step = math.max(math.floor((cf.p - v.p).magnitude / 30), 2) - 1
	local v5 = {}
	local clone = ReplicatedStorage.Chest.FruitEffect.Venom.New.head:Clone()
	clone.CFrame = CFrame.new(cf.p, v.p)
	clone.Size = createVector(38, 59, 70)
	clone.Color = Color3.fromRGB(195, 51, 54)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11633780899",
		Volume = 2,
		PlaybackSpeed = 0.9,
		TimePosition = 0.25
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball_Demon:Clone()
	clone2.Size = createVector(110, 110, 110)
	clone2.CFrame = CFrame.new(cf.p)
	clone2.Color = Color3.fromRGB(195, 51, 54)
	clone2.Parent = workspace.Effects
	task.spawn(function()
		wait()
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 0)
		}):Play()
	end)
	_G.PU:Dust(clone2, 1)
	local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.New.animated_wind2:Clone()
	clone3.Parent = workspace.Effects
	clone3.CFrame = CFrame.new(cf.p) * CFrame.new(0, 50, 0) * CFrame.Angles(0, 0, 3.141592653589793)
	_G.PU:Dust(clone3, 1)
	task.spawn(function()
		local ModuleScript = require(clone3.ModuleScript)
		ModuleScript(80)
	end)
	local clone4 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball_Demon:Clone()
	clone4.Size = createVector(15, 60, 15)
	clone4.CFrame = CFrame.new(cf.p)
	clone4.Parent = workspace.Effects
	clone4.Attachment.sm3:Emit(35)
	clone4.Attachment.sm4:Emit(15)
	clone4.Attachment.Specs:Emit(20)
	clone4.Attachment.Sparks2:Emit(10)
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11712058000",
		Volume = 1,
		PlaybackSpeed = 1.25
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone4
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6814067199",
		Volume = 2,
		PlaybackSpeed = 0.8
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone4
	sound3:Play()
	TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(100, 4, 100)
	}):Play()
	task.spawn(function()
		wait(0.35)
		TweenService:Create(clone4, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	_G.PU:Dust(clone4, 1)
	task.spawn(function()
		for _ = 1, 5 do
			local v6 = CFrame.new(cf.p) * CFrame.new(
				math.random(-25, 25) * 1.75,
				60 + math.random(0, 70),
				math.random(-25, 25) * 1.75
			)
			local Smoke = require(ReplicatedStorage.Chest.FruitEffect.Venom.New.Smoke)
			Smoke(cf, v6, Color3.fromRGB(108, 32, 39), Color3.fromRGB(81, 25, 26))
			wait()
		end
	end)
	PeodizService.ForLoop({
		Step = 4
	}, function(_)
		local v6 = CFrame.new(cf.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
			0,
			0,
			math.random(10, 30)
		)
		local part = Instance.new("Part")
		part.Parent = workspace.Effects
		part.Size = createVector(25, 25, 25) * math.random(10, 15) / 10
		part.CFrame = v6 * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		part.Anchored = true
		part.CanCollide = false
		part.Massless = true
		local raycastResult = workspace:Raycast(part.CFrame.p, createVector(0, -15, 0))

		if raycastResult then
			local instance = raycastResult.Instance
			local position = raycastResult.Position
			local size = part.Size
			local v7 = CFrame.new(part.CFrame.p) * CFrame.new(0, math.random(20, 100) * 1.5, 0) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			local v8 = instance.Color.R * 255
			local v9 = instance.Color.G * 255
			local v10 = instance.Color.B * 255
			local v11 = math.random(-10, 30)
			part.Color = instance.Color
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Position = position - createVector(0, 0.25, 0)
			part.Color = Color3.fromRGB(v8 - v11, v9 - v11, v10 - v11)
			part.Size *= 0.85
			TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = v7 * CFrame.new(0, 0, 10),
				Size = size
			}):Play()
			task.spawn(function()
				wait(0.2)
				TweenService:Create(part, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = Vector3.new()
				}):Play()
			end)
		else
			part.Parent = nil
		end

		_G.PU:Dust(part, 1)
	end)
	PeodizService.ForLoop({
		Step = step,
		WaitTime = 0.05
	}, function(p3)
		local v6 = math.floor(p3 * step)
		v5[v6] = CFrame.new(cf.p, v.p) * CFrame.new(0, 0, v6 * -30 + 30) * CFrame.new(0, 0, -15)
		local clone5 = ReplicatedStorage.Chest.FruitEffect.Venom.New.tail:Clone()
		clone5.CFrame = v5[v6]
		clone5.Size = createVector(0, 0, 28)
		clone5.Color = Color3.fromRGB(195, 51, 54)
		clone5.Parent = workspace.Effects
		TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(25, 25, 30)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = v5[v6] * CFrame.new(0, 0, -30)
		}):Play()
		TweenService:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone5.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
		}):Play()
		_G.PU:Dust(clone5, 1)
		task.spawn(function()
			wait(0.45)
			TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 30),
				Transparency = 1
			}):Play()
		end)
	end)
	_G.PU:Dust(clone, 1.25)
	task.spawn(function()
		wait(0.45)
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 30),
			Transparency = 1
		}):Play()
	end)
end