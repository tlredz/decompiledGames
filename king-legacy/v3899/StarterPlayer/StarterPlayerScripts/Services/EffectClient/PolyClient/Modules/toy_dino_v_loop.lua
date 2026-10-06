local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)

-- equivalent calls inferred from this helper; original call sites unknown
local function randomnumber(p, p2)
	return Random.new():NextNumber(p, p2)
end

return function(data)
	local cf = data.cf
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

	local charge = data.charge
	local char = data.char
	local root = data.root

	if localPlayer == data.plr then
		_G.shake({
			2.5,
			3.5,
			0.33,
			1
		})
	end

	local lastTime = tick()
	local cFrame = root.CFrame
	local clone = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.rush_fx:Clone()
	clone.CFrame = cFrame * CFrame.new(0, -8, -40)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 10)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15982354094",
		Volume = 4,
		Looped = true
	})
	_G.PU:Dust(sound, 5)
	sound.Parent = clone
	sound:Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	PeodizService.new({
		Time = 5
	}, function()
		if not charge:IsDescendantOf(char) or char.Humanoid.Health <= 0 then
			return true
		end

		if tick() - lastTime > 0.25 then
			lastTime = tick()
			localshake({
				3,
				4,
				0,
				0.5
			}) -- equivalent call inferred; original call site unknown
		end

		cFrame = root.CFrame
		clone.CFrame = cFrame * CFrame.new(0, -8, -40)
	end)
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15982356085",
		Volume = 4
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	if sound then
		sound:Stop()
	end

	for _ = 1, 4 do
		local dEFjaw = char:FindFirstChild("DEF-jaw", true)
		local hasTarget = char:GetAttribute("HasTarget")

		if dEFjaw and hasTarget then
			local v = dEFjaw.WorldCFrame * CFrame.new(0, 15, -5.4)
			local orientation, v2, _ = dEFjaw.WorldCFrame:ToOrientation()
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.bite_fx:Clone()
			clone2.CFrame = CFrame.new(v.p) * CFrame.fromOrientation(orientation, v2, 0)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1.5)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			end

			local v4 = 60
			local v5 = v.p
			local v6 = {
				5,
				7,
				0,
				0.75
			}
			task.spawn(function()
				v4 = v4 or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - v5).Magnitude < v4 then
					_G.shake(v6)
				end
			end)
		end

		wait(0.375)
	end

	wait(0.1)
	local v = {
		16,
		19,
		0,
		0.88
	}
	local v2 = 60
	local p = cFrame.p
	task.spawn(function()
		v2 = v2 or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v2 then
			_G.shake(v)
		end
	end)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.slam:Clone()
	_G.PU:Dust(clone2, 2)
	clone2.Parent = workspace.Effects
	clone2.Transparency = 1
	clone2.CFrame = CFrame.new((cFrame * CFrame.new(0, -27, -40)).p)
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15982358493",
		Volume = 5,
		TimePosition = 0.1
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone2
	sound3:Play()

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	task.spawn(function()
		cf = CFrame.new((cFrame * CFrame.new(0, -25, -40)).p)

		for i = 1, 12 do
			local v3 = 0.5235987755982988 * i
			local v4 = math.random(60, 80) / 100
			local v5 = randomnumber(30, 60) -- equivalent call inferred; original call site unknown
			local v6 = cf.p + Vector3.new(
				math.cos(v3) * (65 * v4),
				-Random.new():NextNumber(1, 2.5) * 2.25,
				math.sin(v3) * (65 * v4)
			)
			local part = Instance.new("Part")
			part.Size = Vector3.new()
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new(v6, cf.p + Vector3.new(0, v5, 0))
			_G.PU:Dust(part, 3)
			local ray = Ray.new(part.CFrame.p + createVector(0, 5, 0), createVector(0, -15, 0))
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			local instance

			if raycastResult then
				instance = raycastResult.Instance or nil
			end

			local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

			if not instance then
				continue
			end

			local v7 = position + createVector(0, 2.25, 0) + Vector3.new(
				0,
				-Random.new():NextNumber(1.65, 2.5) * 2.25,
				0
			)
			local orientation, v8, v9 = CFrame.new(v6, cf.p - Vector3.new(0, v5, 0)):ToOrientation()
			part.Parent = workspace.Effects
			part.CFrame = CFrame.new(v7) * CFrame.fromOrientation(orientation, v8, v9) * CFrame.new(0, -5, 0)
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			local v10 = instance.Color.R * 255
			local v11 = instance.Color.G * 255
			local v12 = instance.Color.B * 255
			local v13 = math.random(-10, 30)
			part.Color = Color3.fromRGB(v10 - v13, v11 - v13, v12 - v13)
			TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(6, 3, 3) * Random.new():NextNumber(3, 3.5)
			}):Play()
			TweenService:Create(
				part,
				TweenInfo.new(
					(0.25 + Random.new():NextNumber(0.1, 0.2)) * 0.75,
					Enum.EasingStyle.Back,
					Enum.EasingDirection.Out
				),
				{
					CFrame = CFrame.new(v7) * CFrame.fromOrientation(orientation, v8, v9)
				}
			):Play()
			local v16 = part
			task.spawn(function()
				wait(1)
				task.wait(randomnumber(0.1, 0.3))
				TweenService:Create(v16, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(v7) * CFrame.fromOrientation(orientation, v8, v9) * CFrame.new(0, -9, 0)
				}):Play()
			end)
		end
	end)

	for i = 1, 2 do
		local v3 = i
		task.spawn(function()
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.wave:Clone()
			clone3.CFrame = CFrame.new((cFrame * CFrame.new(0, -30, -40)).p) * CFrame.new(0, 60, 0) * CFrame.Angles(
				0,
				0,
				1.5707963267948966
			)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 1)
			clone3.Mesh.Scale = createVector(2.418, 1.8, 1.8)

			if v3 == 2 then
				clone3.Mesh.Scale = createVector(2.1762, 1.6199999, 1.6199999)
				clone3.Decal.Color3 = Color3.fromRGB()
			end

			wait()
			TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.new(-40, 0, 0)
			}):Play()
			TweenService:Create(clone3.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = createVector(3.11, 0.173, 0.086)
			}):Play()
			wait(0.2)
			TweenService:Create(
				clone3.Decal,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end)
		task.wait()
	end
end