local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local cfs = data.cfs
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

	PeodizService.ForLoop({
		Step = 3,
		WaitTime = 0.1
	}, function(p)
		local v = math.floor(p * 3)
		task.spawn(function()
			for _ = 1, math.random(3, 5) do
				local v2 = CFrame.new(cfs[v].p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
					0,
					0,
					math.random(10, 20)
				)
				local part = Instance.new("Part")
				part.Parent = workspace.Effects
				part.Size = createVector(7, 7, 7) * math.random(10, 15) / 10
				part.CFrame = v2 * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
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
					local size = part.Size
					local v3 = CFrame.new(part.CFrame.p) * CFrame.new(0, math.random(5, 35) * 1.5, 0) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					local v4 = instance.Color.R * 255
					local v5 = instance.Color.G * 255
					local v6 = instance.Color.B * 255
					local v7 = math.random(-10, 30)
					part.Color = instance.Color
					part.Material = instance.Material
					part.MaterialVariant = instance.MaterialVariant
					part.Position = position - createVector(0, 0.25, 0)
					part.Color = Color3.fromRGB(v4 - v7, v5 - v7, v6 - v7)
					part.Size *= 0.85
					TweenService:Create(
						part,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = v3 * CFrame.new(0, 0, 10),
							Size = size
						}
					):Play()
					local v8 = part
					task.spawn(function()
						wait(0.2)
						TweenService:Create(v8, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Size = Vector3.new()
						}):Play()
					end)
				else
					part.Parent = nil
				end

				_G.PU:Dust(part, 1)
			end
		end)
		task.spawn(function()
			local v2 = 70
			local p2 = cfs[v].p
			local v3 = "Bump"
			task.spawn(function()
				v2 = v2 or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v2 then
					_G.shake(v3)
				end
			end)
			local cf = cfs[v]
			local clone = ReplicatedStorage.Chest.FruitEffect.Gold.fist:Clone()
			_G.PU:Dust(clone, 2)
			clone.CFrame = cf
			clone.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12649273669",
				Volume = 4.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12649275961",
				Volume = 2.5
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone
			sound2:Play()
			local sound3 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12649276523",
				Volume = 2.5
			})
			_G.PU:Dust(sound3, 3)
			sound3.Parent = clone
			sound3:Play()
			local sound4 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11045655712",
				Volume = 2
			})
			_G.PU:Dust(sound4, 3)
			sound4.Parent = clone
			sound4:Play()
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Gold.fist:Clone()
			_G.PU:Dust(clone2, 1)
			clone2.CFrame = cf
			clone2.Material = Enum.Material.Neon
			clone2.Transparency = -2
			clone2.Parent = workspace.Effects
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Gold.fx:Clone()
			clone3.CFrame = cf
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 2)
			local clones = {}

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			end

			task.spawn(function()
				wait(0.8)
				game.TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Transparency = 0,
					Size = Vector3.new(0, clone.Size.Y, 0)
				}):Play()
			end)
			game.TweenService:Create(
				clone2,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Gold.crack_neon:Clone()
			clone4.CFrame = cf
			clone4.Parent = workspace.Effects
			_G.PU:Dust(clone4, 2)
			clone4.Attachment.black:Emit(1)
			local clone5 = ReplicatedStorage.Chest.FruitEffect.Gold.crown:Clone()
			clone5.CFrame = cf
			clone5.Parent = workspace.Effects
			_G.PU:Dust(clone5, 2)
			game.TweenService:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(22.211, 6.123, 22.211)
			}):Play()
			game.TweenService:Create(
				clone5,
				TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone5.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 5.497787143782138, 0)
				}
			):Play()
			task.spawn(function()
				wait(0.8)
				game.TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Transparency = 0,
					Size = Vector3.new(0, clone5.Size.Y, 0)
				}):Play()
			end)
			PeodizService.ForLoop({
				Step = 3,
				WaitTime = 0.05
			}, function(p3)
				local v4 = math.floor(p3 * 3)
				local clone6 = ReplicatedStorage.Chest.FruitEffect.Gold.arm:Clone()
				clone6.CFrame = cf
				clone6.Name = "arm" .. 4 - v4
				clone6.Parent = workspace.Effects
				_G.PU:Dust(clone6, 2)
				local clone7 = ReplicatedStorage.Chest.FruitEffect.Gold.arm:Clone()
				clone7.CFrame = cf
				clone7.Name = "arm" .. 4 - v4
				clone7.Material = Enum.Material.Neon
				clone7.Transparency = -2
				clone7.Parent = workspace.Effects
				_G.PU:Dust(clone7, 1)
				task.spawn(function()
					wait(0.8)
					game.TweenService:Create(
						clone6,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Transparency = 0,
							Size = Vector3.new(0, clone6.Size.Y, 0)
						}
					):Play()
				end)
				game.TweenService:Create(
					clone7,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				clones[#clones + 1] = clone6
				clones[#clones + 1] = clone7

				for _, v5 in pairs(clones) do
					local v6 = string.sub(v5.Name, 4)
					game.TweenService:Create(v5, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						CFrame = cf * CFrame.new(0, -48, 0) * CFrame.new(0, 12 * (v6 + v4), 0)
					}):Play()
				end

				game.TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = cf * CFrame.new(0, v4 * 12.25, 0)
				}):Play()
				game.TweenService:Create(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = cf * CFrame.new(0, v4 * 12.25, 0)
				}):Play()
			end)
			task.delay(10, function()
				table.clear(clones)
			end)
		end)
	end)
end