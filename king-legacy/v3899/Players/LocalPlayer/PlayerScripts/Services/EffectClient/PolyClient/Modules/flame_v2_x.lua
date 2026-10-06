local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
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
	local clone

	if p.plr == localPlayer then
		clone = script.cc:Clone()
		clone.Parent = game.Lighting
		_G.PU:Dust(clone, 10)
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			TintColor = Color3.fromRGB(255, 183, 170),
			Saturation = -0.5
		}):Play()
	end

	task.spawn(function()
		local clone2 = replicatedStorage.Chest.FruitEffect.Flame.V2.tower_big:Clone()
		_G.PU:Dust(clone2, 3)
		clone2.CFrame = cf * CFrame.new(0, -30, -70)
		clone2.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 600,
			RollOffMinDistance = 0,
			RollOffMode = Enum.RollOffMode.Linear,
			SoundId = "rbxassetid://14975880028",
			Volume = 0.2
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone2
		sound:Play()
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.new(0, 30, 0)
		}):Play()
		local v = 100
		local p2 = cf.p
		local v2 = "Explosion"
		task.spawn(function()
			v = v or 100

			if localPlayer == p.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v then
				_G.shake(v2)
			end
		end)
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(255, 81, 0)
		pointLight.Range = 60
		pointLight.Brightness = 1
		pointLight.Parent = clone2
		task.spawn(function()
			wait(2)
			TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Brightness = 0,
				Range = 0
			}):Play()

			if sound and sound.Parent then
				TweenService:Create(sound, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {
					Volume = 0
				}):Play()
			end
		end)

		for _, emitter in pairs(clone2.exp:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		wait()

		for _, emitter in pairs(clone2.Attachment:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			local v3 = emitter
			task.spawn(function()
				wait(2)
				v3.Enabled = false
			end)
		end

		for _, emitter in pairs(clone2:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			local v3 = emitter
			task.spawn(function()
				wait(2)
				v3.Enabled = false
			end)
		end
	end)
	wait(0.1)

	for i = 1, 2 do
		local v = i % 2 == 0 and -1 or 1
		local clone2 = replicatedStorage.Chest.FruitEffect.Flame.V2.tower_small:Clone()
		clone2.CFrame = cf * CFrame.new(v * 60, -30, -30)
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 3)
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.new(0, 30, 0)
		}):Play()
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(255, 81, 0)
		pointLight.Range = 60
		pointLight.Brightness = 1
		pointLight.Parent = clone2
		task.spawn(function()
			wait(2)
			TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Brightness = 0,
				Range = 0
			}):Play()
		end)

		for _, emitter in pairs(clone2.exp:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		wait()

		for _, emitter in pairs(clone2.Attachment:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			local v3 = emitter
			task.spawn(function()
				wait(2)
				v3.Enabled = false
			end)
		end

		for _, emitter in pairs(clone2:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			local v3 = emitter
			task.spawn(function()
				wait(2)
				v3.Enabled = false
			end)
		end
	end

	if clone then
		wait(1.8)
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			TintColor = Color3.fromRGB(255, 255, 255),
			Saturation = 0
		}):Play()
		_G.PU:Dust(clone, 1)
	end
end