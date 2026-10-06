local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
return function(data)
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

	local fromcf = data.fromcf
	local tocf = data.tocf
	local clone = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball_In:Clone()
	clone.CFrame = fromcf
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 1)

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
		end
	end

	local v = 30
	local p = data.fromcf.p
	local v2 = "SmallBump"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
			_G.shake(v2)
		end
	end)

	for _ = 1, 4 do
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball:Clone()
		clone2.Size = createVector(3, 3, 3)
		clone2.CFrame = fromcf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, math.random(15, 20))
		clone2.Parent = workspace.Effects
		task.spawn(function()
			wait()
			TweenService:Create(clone2, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = fromcf
			}):Play()
			wait()
			TweenService:Create(clone2, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
		end)
		_G.PU:Dust(clone2, 1)
	end

	local clone2 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball:Clone()
	clone2.Size = createVector(20, 20, 20)
	clone2.CFrame = fromcf
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = Vector3.new()
	}):Play()
	_G.PU:Dust(clone2, 1)
	wait()
	local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball:Clone()
	clone3.Size = createVector(0, 0, 0)
	clone3.CFrame = tocf
	TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(30, 30, 30)
	}):Play()
	_G.PU:Dust(clone3, 1)
	task.spawn(function()
		wait(0.1)
		TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)

	for _ = 1, 4 do
		local clone4 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball:Clone()
		clone4.Size = createVector(8, 8, 8)
		clone4.CFrame = tocf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		clone4.Parent = workspace.Effects
		task.spawn(function()
			TweenService:Create(clone4, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone4.CFrame * CFrame.new(0, 0, math.random(15, 20) * 2)
			}):Play()
			wait()
			TweenService:Create(clone4, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
		end)
		_G.PU:Dust(clone4, 1)
	end

	local clone4 = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball_Out:Clone()
	clone4.CFrame = tocf
	clone4.Parent = workspace.Effects
	_G.PU:Dust(clone4, 1.5)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11750333816",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone4
	sound:Play()

	for _, emitter in pairs(clone4.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
		end
	end

	local clone5 = ReplicatedStorage.Chest.FruitEffect.Venom.New.wind_ring:Clone()
	clone5.CFrame = CFrame.new(tocf.p + createVector(0, 4.5, 0)) * CFrame.Angles(0, 1.5707963267948966, 0)
	clone5.Parent = workspace.Effects
	_G.PU:Dust(clone5, 1)
	local ModuleScript = require(clone5.ModuleScript)
	ModuleScript(34)
	local v3 = 30
	local p2 = data.tocf.p
	local v4 = "SmallBump"
	task.spawn(function()
		v3 = v3 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v3 then
			_G.shake(v4)
		end
	end)
end