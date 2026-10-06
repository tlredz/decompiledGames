local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local PeodizService = require(replicatedStorage2.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
return function(p, _)
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

	local cf = p.cf
	local clone = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.punch_fx:Clone()
	clone.CFrame = cf * CFrame.new(0, 0, -5)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 3)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11818435490",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11818433306",
		Volume = 2
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()
	clone.Attachment.hit:Emit(5)
	clone.Attachment.flare1:Emit(5)
	clone.Attachment.shards1:Emit(20)
	PeodizService.ForLoop({
		Step = 6,
		WaitTime = 0.05
	}, function(p2)
		local v = math.floor(p2 * 6)
		local clone2 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.flame:Clone()
		clone2.CFrame = cf * CFrame.new(0, 0, v * -20)
		clone2.Parent = workspace.Effects

		for _, emitter in pairs(clone2.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		_G.PU:Dust(clone2, 1)
		TweenService:Create(
			clone2.PointLight,
			TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Brightness = 0,
				Range = 25
			}
		):Play()

		if v % 2 == 1 then
			local clone3 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.animated_wind2:Clone()
			clone3.CFrame = cf * CFrame.new(0, 0, v * -20) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				1.0471975511965976 * v,
				0
			)
			clone3.Mesh.Scale = clone3.Mesh.Scale + clone3.Mesh.Scale * 0.15 * (1 - v / 6)
			clone3.Parent = workspace.Effects
			clone3.Specs:Emit(10)
			local Animate = require(clone3.Animate)
			Animate()
			_G.PU:Dust(clone3, 2)
			TweenService:Create(clone3.Mesh, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Scale = clone3.Mesh.Scale * 1.25
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
			}):Play()
		end

		if ({ 2, 4, 6 })[v] then
			local v2 = 40
			local p3 = (cf * CFrame.new(0, 0, 10) * CFrame.new(0, 0, v * 2 * -20)).p
			local v3 = "Bump"
			task.spawn(function()
				v2 = v2 or 100

				if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < v2 then
					_G.shake(v3)
				end
			end)
			local clone3 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.flare_trail:Clone()
			clone3.CFrame = cf * CFrame.new(0, 0, 10) * CFrame.new(0, 0, v * 2 * -20) * CFrame.Angles(
				0,
				0,
				-1.5707963267948966
			)
			clone3.Parent = workspace.Effects
			clone3.Blast2:Emit(3)
			clone3.beam:Emit(2)
			clone3.rock:Emit(10)
			clone3.Blast1:Emit(3)
			_G.PU:Dust(clone3, 1)
		end

		task.spawn(function()
			local v2 = (8 - v) / 8
			local part = Instance.new("Part")
			part.Parent = workspace.Effects
			part.Size = createVector(12, 8, 8) + createVector(13, 13, 13) * v2
			part.CFrame = cf * CFrame.new(0, 0, 0) * CFrame.new(0, 0, v * 3 * -20 / 4) * CFrame.new(
				(v2 * 20 + 20) * 1,
				0,
				0
			) * CFrame.new(1 * math.random(20, 40) / 10, 0, -v * math.random(45, 55) / 10)
			part.CFrame = part.CFrame * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
				math.rad(-math.random(10, 20)) * 1,
				0,
				0
			)
			part.Anchored = true
			part.CanCollide = false
			part.Massless = true
			local ray = Ray.new(part.CFrame.p, createVector(0, -15, 0))
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
				part.Position = position - createVector(0, 2, 0)
				local size = part.Size
				local cFrame = part.CFrame
				local v3 = instance.Color.R * 205
				local v4 = instance.Color.G * 205
				local v5 = instance.Color.B * 205
				local v6 = math.random(-10, 30)
				part.Color = Color3.fromRGB(v3 - v6, v4 - v6, v5 - v6)
				part.Size *= 0.85
				part.CFrame *= CFrame.new(0, -7, 0)
				game.TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = cFrame,
					Size = size
				}):Play()
				task.spawn(function()
					wait(1)
					task.wait(math.random(1, 20) * 0.01)
					game.TweenService:Create(
						part,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = cFrame * CFrame.new(0, -8, 0),
							Size = size * 0.75
						}
					):Play()
				end)
			else
				part.Parent = nil
			end

			_G.PU:Dust(part, 2)
		end)
		task.spawn(function()
			local v2 = (8 - v) / 8
			local part = Instance.new("Part")
			part.Parent = workspace.Effects
			part.Size = createVector(12, 8, 8) + createVector(13, 13, 13) * v2
			part.CFrame = cf * CFrame.new(0, 0, 0) * CFrame.new(0, 0, v * 3 * -20 / 4) * CFrame.new(
				(v2 * 20 + 20) * -1,
				0,
				0
			) * CFrame.new(-1 * math.random(20, 40) / 10, 0, -v * math.random(45, 55) / 10)
			part.CFrame = part.CFrame * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
				math.rad(-math.random(10, 20)) * -1,
				0,
				0
			)
			part.Anchored = true
			part.CanCollide = false
			part.Massless = true
			local ray = Ray.new(part.CFrame.p, createVector(0, -15, 0))
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
				part.Position = position - createVector(0, 2, 0)
				local size = part.Size
				local cFrame = part.CFrame
				local v3 = instance.Color.R * 205
				local v4 = instance.Color.G * 205
				local v5 = instance.Color.B * 205
				local v6 = math.random(-10, 30)
				part.Color = Color3.fromRGB(v3 - v6, v4 - v6, v5 - v6)
				part.Size *= 0.85
				part.CFrame *= CFrame.new(0, -7, 0)
				game.TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = cFrame,
					Size = size
				}):Play()
				task.spawn(function()
					wait(1)
					task.wait(math.random(1, 20) * 0.01)
					game.TweenService:Create(
						part,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = cFrame * CFrame.new(0, -8, 0),
							Size = size * 0.75
						}
					):Play()
				end)
			else
				part.Parent = nil
			end

			_G.PU:Dust(part, 2)
		end)
	end)
end