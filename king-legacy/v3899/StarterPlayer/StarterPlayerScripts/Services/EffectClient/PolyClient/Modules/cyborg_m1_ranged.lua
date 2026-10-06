local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
return function(data)
	local tocf = data.tocf
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

	local cframe = CFrame.new(tocf.p + createVector(0, 30, 0), tocf.p)
	local clone = ReplicatedStorage.Chest.Etc.Cyborg.round:Clone()
	clone.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.Parent = workspace.Effects
	local clone2 = ReplicatedStorage.Chest.Etc.Cyborg.square:Clone()
	clone2.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0)
	clone2.Parent = workspace.Effects
	local clone3 = ReplicatedStorage.Chest.Etc.Cyborg.fx:Clone()
	_G.PU:Dust(clone3, 1)
	clone3.CFrame = cframe
	clone3.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11970727712",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone3
	sound:Play()
	_G.PU:Dust(clone, 1)
	_G.PU:Dust(clone2, 1)
	clone.Size = Vector3.new()
	clone2.Size = Vector3.new()
	clone3.Attachment.dot:Emit(10)
	clone3.Attachment.ring:Emit(2)
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(28.1225, 0.59000003, 28.1225)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(15.998, 0.9, 15.998)
	}):Play()
	task.spawn(function()
		wait()
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(225, 116, 255)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
		}):Play()
		wait()
		clone3.Attachment.shards1:Emit(8)
		clone3.Attachment.dot2:Emit(10)
		TweenService:Create(clone, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(101, 162, 199)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.new(0, -4, 0) * CFrame.Angles(0, -3.141592653589793, 0)
		}):Play()
		wait(0.3)
		clone3.Blast1:Emit(5)
		clone3.Blast2:Emit(5)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
		wait()
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
		clone3.Attachment.ring2:Emit(1)
	end)
	task.spawn(function()
		wait()
		local clone4 = ReplicatedStorage.Chest.Etc.Cyborg.spike:Clone()
		clone4.CFrame = cframe * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone4.Parent = workspace.Effects
		clone4.Size = Vector3.new()
		_G.PU:Dust(clone4, 0.5)
		TweenService:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(3, 30, 3),
			CFrame = clone4.CFrame * CFrame.new(0, 25, 0)
		}):Play()
		wait()
		TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(225, 116, 255)
		}):Play()
		wait(0.1)
		TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(0, 30, 0)
		}):Play()
	end)
	local clone4 = ReplicatedStorage.Chest.Etc.Cyborg.accel_ray2:Clone()
	clone4.CFrame = tocf
	clone4.Parent = workspace.Effects
	_G.PU:Dust(clone4, 1)
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11970716853",
		Volume = 1
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone4
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11970712930",
		Volume = 1.25
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone4
	sound3:Play()
	local v = 50
	local p = tocf.p
	local v2 = "SmallerBump"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
			_G.shake(v2)
		end
	end)

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end
end