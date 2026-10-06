local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
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
	local v = 100
	local p2 = cf.p
	local v2 = "Explosion"
	task.spawn(function()
		v = v or 100

		if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v then
			_G.shake(v2)
		end
	end)
	local clone = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.animated_wind:Clone()
	clone.CFrame = cf
	clone.Parent = workspace.Effects
	clone.Specs:Emit(10)
	clone.hit:Emit(3)
	local ModuleScript = require(clone.ModuleScript)
	ModuleScript(110)
	_G.PU:Dust(clone, 2)
	local clone2 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.crack_x:Clone()
	_G.PU:Dust(clone2, 3)
	clone2.CFrame = cf * CFrame.new(0, 0, 0)
	clone2.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://7191039540",
		Volume = 10
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11045655712",
		Volume = 3.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://11818434924",
		Volume = 3
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone2
	sound3:Play()

	for _, emitter in pairs(clone2:GetChildren()) do
		if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	task.spawn(function()
		clone2.flame.Enabled = true
		clone2.shards1.Enabled = true
		clone2.hit.Enabled = true
		wait(0.35)
		clone2.hit.Enabled = false
		clone2.flame.Enabled = false
		clone2.shards1.Enabled = false
	end)
	clone2.Attachment.sm1:Emit(25)

	for i = 1, 6 do
		local v3 = i
		spawn(function()
			local v4 = cf * CFrame.Angles(0, 6.283185307179586 * v3 / 6, 0)
			local v5 = v4 * CFrame.new(0, 0, 100)
			local v6 = {}

			for i2 = 0, 7 do
				local cframe = CFrame.new(math.random(-250, 250) / 25, 0, 0)

				if i2 == 0 or i2 == 7 then
					cframe = CFrame.new()
				end

				local v7 = v4 * CFrame.new(0, 0, (v4.Position - v5.Position).Magnitude / 7 * i2) * cframe
				v6[#v6 + 1] = v7
			end

			PeodizService.ForLoop({
				Step = #v6
			}, function(p3)
				local v7 = math.floor(p3 * #v6)
				local v8 = v6[v7]
				local v9 = v6[v7 + 1]

				if v9 then
					local part = Instance.new("Part")
					part.Anchored = true
					part.CanCollide = false
					part.Material = Enum.Material.Neon
					part.Color = Color3.fromRGB(0, 0, 0)
					part.Size = Vector3.new(0, 10, (v8.p - v9.p).Magnitude + 1)
					part.CFrame = CFrame.new(v8.p, v9.p) * CFrame.new(0, 0, -(v8.p - v9.p).Magnitude / 2)
					part.Parent = workspace.Effects
					task.spawn(function()
						task.wait(v7 * 0.2 / 3 + -0.2)
						local clone3 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.Blast2:Clone()
						clone3.Parent = part
						clone3:Emit(math.random(3, 5))
					end)
					local TweenService = game:GetService("TweenService")
					TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						Color = Color3.fromRGB(255, 112, 64)
					}):Play()
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
						Size = Vector3.new(4 - v7 * 0.575, 0.15, (v8.p - v9.p).Magnitude)
					}):Play()
					spawn(function()
						wait(1)
						local TweenService3 = game:GetService("TweenService")
						TweenService3:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
							Transparency = 1,
							Size = Vector3.new(0, 0, part.Size.Z)
						}):Play()
					end)
					_G.PU:Dust(part, 3)
				end
			end)
			task.delay(10, function()
				table.clear(v6)
			end)
		end)
	end

	for i = 1, 6 do
		local v3 = CFrame.new(cf.p) * CFrame.Angles(0, 6.283185307179586 * i / 6, 0) * CFrame.Angles(
			0,
			0.5235987755982988,
			0
		)

		for i2 = 1, 5 do
			local v4 = i2
			local v5 = v3
			task.spawn(function()
				task.wait(v4 * task.wait())
				cf = v5
				local v6 = v4 % 2
				local v7 = v6 == 0 and -1 or v6
				local part = Instance.new("Part")
				part.Parent = workspace.Effects
				part.Size = createVector(3.75, 2.75, 2.75) + createVector(30, 18, 18) * v4 / 5
				part.CFrame = cf * CFrame.new(v7 * math.random(10, 20) / 10, 0, -v4 * 90 / 6) * CFrame.new(
					v7 * math.random(40, 50) / 10 * v4 / 5,
					0,
					0
				)
				part.Anchored = true
				part.CanCollide = false
				part.Massless = true
				local v8 = cf * CFrame.new(0, 0, -v4 * 100 / 6)
				local magnitude = (part.CFrame.p - v8.p).magnitude
				part.CFrame *= CFrame.Angles(math.rad(-math.random(10, 25)), math.rad(magnitude * -v7), 0)
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
					local cFrame = part.CFrame * CFrame.new(0, v4 * 2 / 5, 0)
					local v10 = instance.Color.R * 255
					local v11 = instance.Color.G * 255
					local v12 = instance.Color.B * 255
					local v13 = math.random(-10, 30)
					part.Color = Color3.fromRGB(v10 - v13, v11 - v13, v12 - v13)
					part.Size *= 0.85
					part.CFrame *= CFrame.new(0, -(v4 * 2 / 5 + 8), 0)
					game.TweenService:Create(
						part,
						TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							CFrame = cFrame,
							Size = size
						}
					):Play()
					task.spawn(function()
						wait(1)
						game.TweenService:Create(
							part,
							TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								CFrame = cFrame * CFrame.new(0, -(v4 * 3 / 5 + 9), 0),
								Size = size * 0.75
							}
						):Play()
					end)
				else
					part.Parent = nil
				end

				_G.PU:Dust(part, 2)
			end)
		end
	end
end