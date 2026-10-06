local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local _ = data.cf
	local fromcf = data.fromcf
	local tocf = data.tocf
	local charge_mode = data.charge_mode
	local ti = data.ti
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

	if charge_mode then
		local v = 70
		local p = data.cf.p
		local v2 = "Bump2"
		task.spawn(function()
			v = v or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
				_G.shake(v2)
			end
		end)

		if localPlayer == data.plr then
			task.spawn(function()
				local clone = script.inverse:Clone()
				clone.Parent = game.Lighting
				clone.Enabled = true
				task.wait(0.1)
				clone:Destroy()
			end)
		end

		local clone = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.bullet2:Clone()
		clone.CastShadow = false
		clone.Transparency = -1
		clone.Size = createVector(1, 1, 10)
		clone.CFrame = fromcf
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(ti, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
			CFrame = tocf
		}):Play()
		_G.PU:Dust(clone, ti + 0.5)
		local clone2 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.shoot3:Clone()
		clone2.CFrame = fromcf * CFrame.new(0, 0, -10)
		clone2.Anchored = true
		clone2.Massless = true
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 2)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://12265826457",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone2
		sound:Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8748164748",
			PlaybackSpeed = 2,
			Volume = 1
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone2
		sound2:Play()
		local sound3 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://12388328102",
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

		local magnitude = (fromcf.p - tocf.p).magnitude
		task.spawn(function()
			local step = math.floor(magnitude / 20)
			PeodizService.ForLoop({
				Step = step
			}, function(p2)
				local v4 = math.floor(p2 * step)
				local clone3 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.side_fx:Clone()
				clone3.CFrame = fromcf * CFrame.new(0, 0, -6) * CFrame.new(0, 0, v4 * -20)
				clone3.Parent = workspace.Effects
				_G.PU:Dust(clone3, 1)

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
					end
				end
			end)
		end)
		task.spawn(function()
			local step = math.floor(magnitude / 50)
			PeodizService.ForLoop({
				Step = step
			}, function(p2)
				local v4 = math.floor(p2 * step)
				local clone3 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.animated_wind2:Clone()
				clone3.CFrame = fromcf * CFrame.new(0, 0, v4 * -50) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					6.283185307179586 / step * v4,
					0
				)
				clone3.Mesh.Scale = clone3.Mesh.Scale + clone3.Mesh.Scale * 0.15 * (1 - v4 / 6)
				clone3.Parent = workspace.Effects
				local Animate = require(clone3.Animate)
				Animate()
				_G.PU:Dust(clone3, 2)
				TweenService:Create(
					clone3.Mesh,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = clone3.Mesh.Scale * 1.25
					}
				):Play()
				TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = clone3.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
				}):Play()
			end)
		end)
		wait(ti)
		local clone3 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.pillar:Clone()
		clone3.Parent = workspace.Effects
		clone3:SetPrimaryPartCFrame(CFrame.new(tocf.p))
		_G.PU:Dust(clone3, 4)
		local pillar = clone3.pillar
		local bar = clone3.bar
		local crack2 = clone3.Crack2
		local main = clone3.main
		local beamMain1 = pillar.BeamMain1
		local beamMain2 = pillar.BeamMain2
		bar.CFrame = main.CFrame
		beamMain1.Width0 = 0
		beamMain1.Width1 = 0
		beamMain2.Width0 = 0
		beamMain2.Width1 = 0
		TweenService:Create(beamMain1, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Width0 = 50,
			Width1 = 30
		}):Play()
		TweenService:Create(beamMain2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Width0 = 50,
			Width1 = 30
		}):Play()
		TweenService:Create(crack2.dark, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Transparency = -1
		}):Play()
		local sound4 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://12276907916",
			Volume = 3.5
		})
		_G.PU:Dust(sound4, 3)
		sound4.Parent = pillar
		sound4:Play()
		local sound5 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://12417157275",
			Volume = 0,
			Looped = true
		})
		_G.PU:Dust(sound5, 30)
		sound5.Parent = pillar
		sound5:Play()
		TweenService:Create(sound5, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Volume = 4
		}):Play()

		for _, emitter in pairs(pillar:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(15)
			emitter.Enabled = true
		end

		for _, emitter in pairs(bar:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(15)
			emitter.Enabled = true
		end

		tick()
		PeodizService.HeartbeatWait({
			Time = 3,
			WaitTime = 0.1
		}, function()
			bar.CFrame *= CFrame.Angles(0, 0.2617993877991494, 0)
			local v3 = 80
			local p2 = tocf.p
			local v4 = "SmallestBump"
			task.spawn(function()
				v3 = v3 or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v3 then
					_G.shake(v4)
				end
			end)
		end)
		_G.PU:Dust(clone3, 1)

		for _, emitter in pairs(bar:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(pillar:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		if sound5.Parent then
			TweenService:Create(sound5, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
		end

		TweenService:Create(crack2.dark, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		TweenService:Create(beamMain1, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beamMain2, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Width0 = 0,
			Width1 = 0
		}):Play()
	else
		local v = 70
		local p = data.cf.p
		local v2 = "Bump"
		task.spawn(function()
			v = v or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v then
				_G.shake(v2)
			end
		end)
		local clone = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.bullet:Clone()
		clone.CastShadow = false
		clone.Transparency = -1
		clone.Size = createVector(1, 1, 10)
		clone.CFrame = fromcf
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(ti, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
			CFrame = tocf
		}):Play()
		_G.PU:Dust(clone, ti + 0.5)
		local clone2 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.shoot2:Clone()
		clone2.CFrame = fromcf * CFrame.new(0, 0, -8)
		clone2.Anchored = true
		clone2.Massless = true
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 1)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://12265826457",
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone2
		sound:Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8748164748",
			PlaybackSpeed = 2,
			Volume = 1
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone2
		sound2:Play()

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		wait(ti)
		local clone3 = ReplicatedStorage.Chest.SwordEffect.PhoenixBlade.V2.explode1:Clone()
		clone3.CFrame = CFrame.new(tocf.p)
		clone3.Anchored = true
		clone3.Massless = true
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 1.25)
		local sound3 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://12276907916",
			Volume = 3.5
		})
		_G.PU:Dust(sound3, 3)
		sound3.Parent = clone3
		sound3:Play()
		local sound4 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8748164748",
			Volume = 4,
			PlaybackSpeed = 0.85
		})
		_G.PU:Dust(sound4, 3)
		sound4.Parent = clone3
		sound4:Play()

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		local v3 = 70
		local p2 = data.tocf.p
		local v4 = "Bump"
		task.spawn(function()
			v3 = v3 or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v3 then
				_G.shake(v4)
			end
		end)
	end
end