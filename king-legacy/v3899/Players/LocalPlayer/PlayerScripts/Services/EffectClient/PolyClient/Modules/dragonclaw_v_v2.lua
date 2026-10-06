local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
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
	local tocfs = data.tocfs

	local function magma(cf2, p)
		local cframes = {}
		local magnitudes = {}

		for i = 0, 9 do
			local v = (cf2.p - p.p).magnitude / 9
			local v2 = CFrame.new(cf2.p, p.p) * CFrame.new(
				math.sin(6.283185307179586 * i / 9) * 15,
				math.sin(3.141592653589793 * i / 9) * 50,
				v + i * -v
			)
			local v3 = CFrame.new(cf2.p, p.p) * CFrame.new(
				math.sin(6.283185307179586 * (i + 1) / 9) * 15,
				math.sin(3.141592653589793 * (i + 1) / 9) * 50,
				v + (i + 1) * -v
			)
			local p2 = v2.p
			local p3 = v3.p
			cframes[i] = CFrame.new((p2 + p3) / 2, p3)
			magnitudes[i] = (p2 - p3).magnitude
		end

		local clone = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.head:Clone()
		_G.PU:Dust(clone, 5)
		clone.CFrame = CFrame.new(cf2.p, p.p)
		clone.Size = createVector(13.908001, 18.642, 26.329498)
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://11818434924",
			PlaybackSpeed = 1.25,
			Volume = 1.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		PeodizService.ForLoop({
			Step = 8,
			WaitTime = 0.05
		}, function(p2)
			local v = math.floor(p2 * 8)
			local clone2 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.tail:Clone()
			clone2.CFrame = cframes[v]
			clone2.Size = Vector3.new(0, 0, magnitudes[v] * 0.75)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new(7, 7, magnitudes[v] + 2)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(245, 118, 54)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(cframes[v].p, cframes[v + 1].p) * CFrame.new(0, 0, -(magnitudes[v] / 2))
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
			}):Play()
			_G.PU:Dust(clone2, 1)
			task.spawn(function()
				wait(0.2)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(0, 0, magnitudes[v] + 2),
						Transparency = 1
					}
				):Play()
			end)
		end)
		_G.PU:Dust(clone, 0.5)
		local v = 60
		local p2 = p.p
		local v2 = "Bump"
		task.spawn(function()
			v = v or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v then
				_G.shake(v2)
			end
		end)
		local clone2 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.flame_exp2:Clone()
		clone2.CFrame = CFrame.new(p.p)
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
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://11045655712",
			Volume = 1
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone2
		sound2:Play()
		local sound3 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8748164748",
			PlaybackSpeed = 0.85,
			Volume = 2
		})
		_G.PU:Dust(sound3, 3)
		sound3.Parent = clone2
		sound3:Play()
		task.spawn(function()
			local clone3 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.animated_wind2:Clone()
			clone3.CFrame = CFrame.new(p.p) * CFrame.new(0, 5, 0)
			clone3.Parent = workspace.Effects
			clone3.Specs:Emit(10)
			clone3.hit:Emit(3)
			local Animate = require(clone3.Animate)
			Animate()
			_G.PU:Dust(clone3, 2)
			game.TweenService:Create(
				clone3.Mesh,
				TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = clone3.Mesh.Scale * 1.2
				}
			):Play()
			game.TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
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
		task.delay(10, function()
			table.clear(cframes)
			table.clear(magnitudes)
		end)
	end

	local clone

	if data.plr == localPlayer then
		clone = script.cc:Clone()
		clone.Parent = game.Lighting
		_G.PU:Dust(clone, 10)
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			TintColor = Color3.fromRGB(255, 183, 170),
			Saturation = -0.5
		}):Play()
	end

	PeodizService.ForLoop({
		Step = #tocfs,
		WaitTime = 0.15
	}, function(p)
		local v = math.floor(p * #tocfs)
		task.spawn(function()
			magma(cf, tocfs[v])
		end)
	end)

	if clone then
		wait(0.5)
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			TintColor = Color3.fromRGB(255, 255, 255),
			Saturation = 0
		}):Play()
		_G.PU:Dust(clone, 1)
	end
end