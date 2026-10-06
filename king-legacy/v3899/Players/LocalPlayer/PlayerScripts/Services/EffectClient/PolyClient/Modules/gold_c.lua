local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage2.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(data, _)
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

	local cf = data.cf
	local tocf = data.tocf

	local function magma(cf2, tocf2)
		local cframes = {}
		local magnitudes = {}

		for i = 0, 8 do
			local v = (cf2.p - tocf2.p).magnitude / 8
			local v2 = CFrame.new(cf2.p, tocf2.p) * CFrame.new(
				math.sin(6.283185307179586 * i / 8) * 15,
				math.sin(3.141592653589793 * i / 8) * 40,
				v + i * -v
			)
			local v3 = CFrame.new(cf2.p, tocf2.p) * CFrame.new(
				math.sin(6.283185307179586 * (i + 1) / 8) * 15,
				math.sin(3.141592653589793 * (i + 1) / 8) * 40,
				v + (i + 1) * -v
			)
			local p = v2.p
			local p2 = v3.p
			cframes[i] = CFrame.new((p + p2) / 2, p2)
			magnitudes[i] = (p - p2).magnitude
		end

		local clone = replicatedStorage.Chest.FruitEffect.Gold.head:Clone()
		_G.PU:Dust(clone, 5)
		clone.CFrame = CFrame.new(cf2.p, tocf2.p)
		clone.Parent = workspace.Effects
		clone.Size = createVector(18.544, 24.856, 35.106)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://11818434924",
			Volume = 1.5,
			PlaybackSpeed = 1.25
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		PeodizService.ForLoop({
			Step = 7
		}, function(p)
			local v = math.floor(p * 7)

			if v % 2 == 0 then
				local clone2 = replicatedStorage2.Chest.FruitEffect.Gold.crown:Clone()
				clone2.CFrame = cframes[v] * CFrame.Angles(1.5707963267948966, 0, 0)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1)
				clone2.Attachment.wind:Emit(math.random(3, 4))
				clone2.Attachment.coin:Emit(6)
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(22.211, 6.123, 22.211)
				}):Play()
				task.spawn(function()
					wait(0.1)
					TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
			end

			local clone2 = replicatedStorage.Chest.FruitEffect.Gold.tail:Clone()
			clone2.CFrame = cframes[v] * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Size = Vector3.new(0, magnitudes[v] * 0.75, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new(10, magnitudes[v] + 3.5, 10)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(cframes[v].p, cframes[v + 1].p) * CFrame.new(0, 0, -(magnitudes[v] / 2))
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
			}):Play()
			_G.PU:Dust(clone2, 1)
			task.spawn(function()
				wait(0.2)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(0, magnitudes[v] + 3.5, 0),
						Transparency = 1
					}
				):Play()
			end)
		end)
		task.delay(10, function()
			table.clear(cframes)
			table.clear(magnitudes)
		end)
		_G.PU:Dust(clone, 0.5)
		local v = 60
		local p = tocf2.p
		local v2 = "Bump"
		task.spawn(function()
			v = v or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
				_G.shake(v2)
			end
		end)
		local clone2 = replicatedStorage.Chest.FruitEffect.Gold.gold_floor:Clone()
		_G.PU:Dust(clone2, 2)
		clone2.CFrame = CFrame.new(tocf2.p + createVector(0, 1, 0))
		clone2.Size = Vector3.new()
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 2)
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://12764354188",
			Volume = 4.5
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone2
		sound2:Play()
		local sound3 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://12649276523",
			Volume = 3
		})
		_G.PU:Dust(sound3, 3)
		sound3.Parent = clone2
		sound3:Play()

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(95, 5.5, 95)
		}):Play()
		task.spawn(function()
			wait(1)
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		task.spawn(function()
			wait(0.2)
			TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, clone.Size.Z),
				Transparency = 1
			}):Play()
		end)

		for i = 1, 4 do
			local cFrame = CFrame.new(tocf2.p) * CFrame.Angles(0, 1.5707963267948966 * i, 0) * CFrame.new(0, 0, -26) * CFrame.Angles(
				-0.6981317007977318,
				0,
				0
			)
			local cFrame2 = CFrame.new(tocf2.p) * CFrame.Angles(0, 1.5707963267948966 * i, 0) * CFrame.new(0, 12, -26) * CFrame.Angles(
				-0.6981317007977318,
				1.5707963267948966,
				0
			)
			local clone3 = replicatedStorage.Chest.FruitEffect.Gold.gold_spike:Clone()
			clone3.CFrame = cFrame
			clone3.Size = Vector3.new()
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(35, 55, 35),
				CFrame = cFrame2
			}):Play()
			_G.PU:Dust(clone3, 2)
			task.spawn(function()
				wait(1)
				TweenService:Create(clone3, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = clone3.CFrame * CFrame.Angles(0, 2.5132741228718345, 0)
				}):Play()
				TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
		end
	end

	local function magma2(p, p2)
		local cframes = {}
		local magnitudes = {}

		for i = 0, 8 do
			local v = (p.p - p2.p).magnitude / 8
			local v2 = CFrame.new(p.p, p2.p) * CFrame.new(
				-math.sin(6.283185307179586 * i / 8) * 15,
				math.sin(3.141592653589793 * i / 8) * 40,
				v + i * -v
			)
			local v3 = CFrame.new(p.p, p2.p) * CFrame.new(
				-math.sin(6.283185307179586 * (i + 1) / 8) * 15,
				math.sin(3.141592653589793 * (i + 1) / 8) * 40,
				v + (i + 1) * -v
			)
			local p3 = v2.p
			local p4 = v3.p
			cframes[i] = CFrame.new((p3 + p4) / 2, p4)
			magnitudes[i] = (p3 - p4).magnitude
		end

		local clone = replicatedStorage.Chest.FruitEffect.Gold.head:Clone()
		_G.PU:Dust(clone, 5)
		clone.CFrame = CFrame.new(p.p, p2.p)
		clone.Parent = workspace.Effects
		clone.Size = createVector(18.544, 24.856, 35.106)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://11818434924",
			Volume = 1.5,
			PlaybackSpeed = 1.25
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		PeodizService.ForLoop({
			Step = 7
		}, function(p3)
			local v = math.floor(p3 * 7)
			local clone2 = replicatedStorage.Chest.FruitEffect.Gold.tail:Clone()
			clone2.CFrame = cframes[v] * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Size = Vector3.new(0, magnitudes[v] * 0.75, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new(10, magnitudes[v] + 3.5, 10)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(cframes[v].p, cframes[v + 1].p) * CFrame.new(0, 0, -(magnitudes[v] / 2))
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
			}):Play()
			_G.PU:Dust(clone2, 1)
			task.spawn(function()
				wait(0.2)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(0, magnitudes[v] + 3.5, 0),
						Transparency = 1
					}
				):Play()
			end)
		end)
		task.delay(10, function()
			table.clear(cframes)
			table.clear(magnitudes)
		end)
		_G.PU:Dust(clone, 0.5)
		local v = 60
		local p3 = p2.p
		local v2 = "Bump"
		task.spawn(function()
			v = v or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p3).Magnitude < v then
				_G.shake(v2)
			end
		end)
		local clone2 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.flame_exp2:Clone()
		clone2.CFrame = CFrame.new(p2.p)
		clone2.Parent = workspace.Effects

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		_G.PU:Dust(clone2, 1.5)
		TweenService:Create(
			clone2.PointLight,
			TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Brightness = 0,
				Range = 10
			}
		):Play()
		clone2.explode:Play()
		clone2.flame:Play()
		task.spawn(function()
			local clone3 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.animated_wind2:Clone()
			clone3.CFrame = CFrame.new(p2.p) * CFrame.new(0, 5, 0)
			clone3.Parent = workspace.Effects
			clone3.Specs:Emit(10)
			clone3.hit:Emit(3)
			local Animate = require(clone3.Animate)
			Animate()
			_G.PU:Dust(clone3, 2)
			TweenService:Create(clone3.Mesh, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Scale = clone3.Mesh.Scale * 1.2
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
			}):Play()
		end)
		task.spawn(function()
			wait(0.2)
			TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, clone.Size.Z),
				Transparency = 1
			}):Play()
			TweenService:Create(
				clone2.dark,
				TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end)
	end

	task.spawn(function()
		magma(cf, tocf)
	end)
end