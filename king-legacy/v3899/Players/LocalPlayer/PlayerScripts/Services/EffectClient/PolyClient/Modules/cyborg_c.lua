local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local TweenService = game:GetService("TweenService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local mouseFolder = data.MouseFolder
	local charge = data.Charge
	local char = data.Char
	local root = data.Root
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

	tick()
	local cFrame = root.CFrame
	local cframe = CFrame.new(mouseFolder.Value)
	local clone = ReplicatedStorage.Chest.Etc.Cyborg.pillar:Clone()
	clone.Size = Vector3.new(10, 10, (cFrame.p - cframe.p).Magnitude)
	clone.CFrame = CFrame.new(cFrame.p, cframe.p) * CFrame.new(0, 0, -(cFrame.p - cframe.p).Magnitude / 2)
	clone.Attachment.WorldCFrame = cFrame
	clone.Attachment2.WorldCFrame = cframe
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 4)
	clone.BeamMain1.Width0 = 0
	clone.BeamMain1.Width1 = 0
	clone.BeamMain2.Width0 = 0
	clone.BeamMain2.Width1 = 0
	TweenService:Create(clone.BeamMain1, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Width0 = 5,
		Width1 = 15
	}):Play()
	TweenService:Create(clone.BeamMain2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Width0 = 5,
		Width1 = 20
	}):Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and emitter.Name ~= "star") then
			continue
		end

		emitter.Enabled = true
		emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
	end

	local clone2 = ReplicatedStorage.Chest.Etc.Cyborg.heat_trail:Clone()
	clone2.CFrame = cframe
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 5)
	local lastTime = tick()
	local lastTime2 = tick()
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://12111549625",
		Volume = 0.25
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	PeodizService.HeartbeatWait({
		Time = 4,
		WaitTime = 0.05
	}, function()
		if not (root ~= nil and charge:IsDescendantOf(char)) then
			return true
		end

		if tick() - lastTime2 > 0.1 then
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11271018931",
				Volume = 2,
				PlaybackSpeed = 1.1
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone2
			sound2:Play()
			local sound3 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11045655712",
				Volume = 1
			})
			_G.PU:Dust(sound3, 3)
			sound3.Parent = clone2
			sound3:Play()
			local sound4 = PeoUtils.CreateSound({
				RollOffMaxDistance = 750,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://365002938",
				Volume = 1
			})
			_G.PU:Dust(sound4, 3)
			sound4.Parent = clone2
			sound4:Play()
			lastTime2 = tick()
			local part = Instance.new("Part")
			part.Parent = workspace.Effects
			part.Size = createVector(12, 12, 12)
			part.CFrame = cframe * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
				0,
				0,
				math.random(10, 12)
			) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			part.Anchored = true
			part.CanCollide = false
			part.Massless = true
			local ray = Ray.new(part.CFrame.p + createVector(0, 3, 0), createVector(0, -8, 0))
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			local instance

			if raycastResult then
				instance = raycastResult.Instance or nil
			end

			local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

			if instance then
				part.Color = instance.Color
				part.Material = instance.Material
				part.MaterialVariant = instance.MaterialVariant
				part.Position = position
				part.CFrame *= CFrame.new(0, -1, 0)
				local v = instance.Color.R * 255
				local v2 = instance.Color.G * 255
				local v3 = instance.Color.B * 255
				local v4 = math.random(-10, 30)
				part.Color = Color3.fromRGB(v - v4, v2 - v4, v3 - v4)
				TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(part.CFrame.p) * CFrame.new(0, math.random(18, 28), 0) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
				}):Play()
				task.spawn(function()
					wait()
					TweenService:Create(part, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = Vector3.new()
					}):Play()
				end)
				_G.PU:Dust(part, 1)
			else
				part.Parent = nil
			end
		end

		if tick() - lastTime > 0.25 then
			lastTime = tick()
			local v = 50
			local p = cframe.p
			local v2 = "SmallerBump"
			task.spawn(function()
				v = v or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
					_G.shake(v2)
				end
			end)
			local pointLight = Instance.new("PointLight")
			pointLight.Parent = clone2
			pointLight.Color = Color3.fromRGB(255, 97, 57)
			pointLight.Range = 55
			pointLight.Brightness = 1
			game.TweenService:Create(
				pointLight,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 0.25,
					Range = 0
				}
			):Play()
			_G.PU:Dust(pointLight, 0.35)

			for _, emitter in pairs(clone2.Attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			end
		end

		cFrame = root.CFrame
		cframe = CFrame.new(mouseFolder.Value)
		local v = 50
		local p = cframe.p
		local v2 = "SmallestBump"
		task.spawn(function()
			v = v or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
				_G.shake(v2)
			end
		end)
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = cframe
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(10, 10, (cFrame.p - cframe.p).Magnitude),
			CFrame = CFrame.new(cFrame.p, cframe.p) * CFrame.new(0, 0, -(cFrame.p - cframe.p).Magnitude / 2)
		}):Play()
		TweenService:Create(
			clone.Attachment,
			TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				WorldCFrame = cFrame
			}
		):Play()
		TweenService:Create(
			clone.Attachment2,
			TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				WorldCFrame = cframe
			}
		):Play()
	end)

	if sound and sound.Parent then
		TweenService:Create(sound, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Volume = 0
		}):Play()
	end

	_G.PU:Dust(clone2, 1)
	wait()
	TweenService:Create(clone.BeamMain1, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Width0 = 0,
		Width1 = 0
	}):Play()
	TweenService:Create(clone.BeamMain2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Width0 = 0,
		Width1 = 0
	}):Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	clone.star:Emit(20)
end