local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local cframe = CFrame.new(data.cf.p, data.tocf.p)
	local cframe2 = CFrame.new(data.tocf.p)
	local magnitude = (cframe.p - cframe2.p).magnitude
	local localPlayer = game.Players.LocalPlayer
	local _ = data.didhit
	local target = data.target
	local v = {}
	v[#v + 1] = cframe * CFrame.new(0, 0, -magnitude)
	local v2 = {
		6,
		9,
		2,
		5,
		8,
		1,
		4,
		7,
		10,
		3,
		6
	}
	local v3 = {}

	for i = 1, 11 do
		v2[i] = CFrame.Angles(0, 0.6283185307179586 * v2[i], 0) * CFrame.new(0, 0, -math.random(45, 50))
	end

	for i = 1, 11 do
		local v4 = CFrame.new(cframe2.p) * CFrame.new(0, i * 1.8181818181818181, 0) * v2[i]
		v3[#v3 + 1] = v4
		v[#v + 1] = v4
	end

	v3[#v3 + 1] = cframe2 * CFrame.new(0, 20, 0)
	v[#v + 1] = cframe2 * CFrame.new(0, 20, 0)
	local part = Instance.new("Part")
	part.CFrame = cframe
	part.Size = createVector(5, 5, 5)
	part.CanCollide = false
	part.Anchored = true
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Transparency = 1
	part.Name = "Cam"
	part.Parent = workspace.Effects
	game.TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = v[1]
	}):Play()
	local colorCorrectionEffect = nil
	local cameraSubject = workspace.CurrentCamera.CameraSubject

	if game.Players.LocalPlayer == data.plr then
		workspace.CurrentCamera.CameraSubject = part
		task.spawn(function()
			colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Parent = game.Lighting
			colorCorrectionEffect.Brightness = -0.125
			colorCorrectionEffect.TintColor = Color3.fromRGB(255, 207, 188)
			_G.PU:Dust(colorCorrectionEffect, 4)
			wait(1.3)
			wait(1.25)
			game.TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0
				}
			):Play()
		end)
		task.spawn(function()
			local colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect2.Parent = game.Lighting
			colorCorrectionEffect2.Contrast = 2
			colorCorrectionEffect2.Saturation = -2
			_G.PU:Dust(colorCorrectionEffect2, 0.1)
		end)
	end

	local clone = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.Spiral2:Clone()
	clone:SetPrimaryPartCFrame(cframe * CFrame.new(0, 0, -magnitude))
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 0.5)
	task.spawn(function()
		wait()
		local ModuleScript = require(clone.ModuleScript)
		ModuleScript()
	end)
	local clone2 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.smoko:Clone()
	clone2.CFrame = cframe * CFrame.new(0, 0, -30) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 3)
	task.spawn(function()
		wait()
		local ModuleScript = require(clone2.ModuleScript)
		ModuleScript()
	end)
	local clone3 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.WindRing:Clone()
	clone3.CFrame = cframe * CFrame.new(0, 0, -5) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 1)
	task.spawn(function()
		local ModuleScript = require(clone3.ModuleScript)
		ModuleScript()
	end)
	local clone4 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.WindRing2:Clone()
	clone4.CFrame = cframe * CFrame.new(0, 0, -10) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone4.Parent = workspace.Effects
	_G.PU:Dust(clone4, 1)
	task.spawn(function()
		local ModuleScript = require(clone4.ModuleScript)
		ModuleScript()
	end)
	local clone5 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.wind:Clone()
	clone5.Parent = workspace.Effects
	clone5.CFrame = CFrame.new(cframe.p)
	task.spawn(function()
		local ModuleScript = require(clone5.ModuleScript)
		ModuleScript()
	end)
	local part2 = Instance.new("Part")
	part2.CFrame = cframe
	part2.Size = createVector(1, 1, 1)
	part2.CanCollide = false
	part2.Anchored = true
	part2.Color = Color3.fromRGB(255, 0, 0)
	part2.Transparency = 1
	part2.Parent = workspace.Effects
	_G.PU:Dust(part2, 1.5)
	local clone6 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.transfrom.Attachment:Clone()
	clone6.Parent = part2
	clone6.Spark.Rotation = NumberRange.new(math.random(0, 180))
	task.spawn(function()
		local ModuleScript = require(clone6.ModuleScript)
		ModuleScript()
	end)
	task.spawn(function()
		wait(math.random() * wait())

		for _ = 1, math.random(2, 3) do
			local clone7 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.sphere:Clone()
			clone7.CFrame = cframe * CFrame.new(math.random(-8, 8), math.random(-8, 8), -magnitude / 3) * CFrame.new(
				0,
				0,
				math.random(-5, 5)
			)
			clone7.Size = Vector3.new(1, 1, magnitude / 1.5)
			clone7.Transparency = -1
			clone7.Parent = workspace.Effects
			game.TweenService:Create(
				clone7,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = Vector3.new()
				}
			):Play()
			game.TweenService:Create(
				clone7,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone7.CFrame * CFrame.new(0, 0, -magnitude) * CFrame.new(0, 0, magnitude / 3)
				}
			):Play()
			_G.PU:Dust(clone7, 0.5)
			task.spawn(function()
				wait(0.15)
				game.TweenService:Create(
					clone7,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end
	end)
	local clone7 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.sphere:Clone()
	clone7.CFrame = cframe
	clone7.Size = createVector(25, 25, 0)
	clone7.Parent = workspace.Effects
	game.TweenService:Create(clone7, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = Vector3.new(1, 1, magnitude)
	}):Play()
	game.TweenService:Create(clone7, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone7.CFrame * CFrame.new(0, 0, -magnitude / 2)
	}):Play()
	_G.PU:Dust(clone7, 1)
	task.spawn(function()
		wait(0.1)
		clone7.sakura:Emit(10)
		game.TweenService:Create(clone7, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 0.1, magnitude)
		}):Play()
		wait(0.1)
		game.TweenService:Create(clone7, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	wait(0.1)
	local clone8 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.wind2:Clone()
	clone8.Parent = workspace.Effects
	clone8.CFrame = CFrame.new(cframe2.p)
	task.spawn(function()
		local ModuleScript = require(clone8.ModuleScript)
		ModuleScript()
	end)

	if (localPlayer.Character.HumanoidRootPart.Position - cframe.p).Magnitude < 40 or game.Players.LocalPlayer == data.plr then
		_G.shake("Bump")
	end

	for k, cFrame in pairs(v3) do
		if not v[k + 1] then
			continue
		end

		game.TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(v[k].p, v[k + 1].p) * CFrame.new(0, 0, -(v[k].p - v[k + 1].p).magnitude)
		}):Play()

		if (localPlayer.Character.HumanoidRootPart.Position - cframe.p).Magnitude < 50 or game.Players.LocalPlayer == data.plr then
			if k == 12 then
				_G.shake("Bump")
			else
				_G.shake("SmallBump")
			end
		end

		local clone9 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.Spiral:Clone()
		clone9:SetPrimaryPartCFrame(CFrame.new(v[k].p, v[k + 1].p) * CFrame.new(0, 0, -(v[k].p - v[k + 1].p).magnitude))
		clone9.Parent = workspace.Effects
		_G.PU:Dust(clone9, 0.5)
		task.spawn(function()
			local ModuleScript = require(clone9.ModuleScript)
			ModuleScript()
		end)
		local part3 = Instance.new("Part")
		part3.CFrame = cFrame
		part3.Size = createVector(1, 1, 1)
		part3.CanCollide = false
		part3.Anchored = true
		part3.Color = Color3.fromRGB(255, 0, 0)
		part3.Transparency = 1
		part3.Name = "Part" .. k
		part3.Parent = workspace.Effects
		_G.PU:Dust(part3, 1.5)
		local clone10 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.transfrom.Attachment:Clone()
		clone10.Parent = part3
		clone10.Spark.Rotation = NumberRange.new(math.random(0, 180))
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6780413304",
			PlaybackSpeed = 1.25,
			Volume = 1.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone10
		sound:Play()
		task.spawn(function()
			local ModuleScript = require(clone10.ModuleScript)
			ModuleScript()
		end)
		local v10 = k
		task.spawn(function()
			wait(math.random() * wait())

			for i = 1, math.random(2, 3) do
				local clone11 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.sphere:Clone()
				clone11.CFrame = CFrame.new(v[v10].p, v[v10 + 1].p) * CFrame.new(
					math.random(-7, 7),
					math.random(-7, 7),
					-(v[v10].p - v[v10 + 1].p).magnitude / 3
				) * CFrame.new(0, 0, math.random(-5, 5))
				clone11.Size = Vector3.new(0.75, 0.75, (v[v10].p - v[v10 + 1].p).magnitude / 1.5)
				clone11.Parent = workspace.Effects
				game.TweenService:Create(
					clone11,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new()
					}
				):Play()
				game.TweenService:Create(
					clone11,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone11.CFrame * CFrame.new(0, 0, -(v[v10].p - v[v10 + 1].p).magnitude) * CFrame.new(
							0,
							0,
							(v[v10].p - v[v10 + 1].p).magnitude / 3
						)
					}
				):Play()
				_G.PU:Dust(clone11, 0.5)
				task.spawn(function()
					wait(0.15)
					game.TweenService:Create(
						clone11,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end
		end)
		local clone11 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.sphere:Clone()
		clone11.CFrame = CFrame.new(v[k].p, v[k + 1].p)
		clone11.Size = createVector(15, 15, 0)
		clone11.Parent = workspace.Effects
		game.TweenService:Create(clone11, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.5, 0.5, (v[k].p - v[k + 1].p).magnitude)
		}):Play()
		game.TweenService:Create(clone11, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone11.CFrame * CFrame.new(0, 0, -(v[k].p - v[k + 1].p).magnitude / 2)
		}):Play()
		_G.PU:Dust(clone11, 1)
		local v12 = k
		task.spawn(function()
			wait(0.1)
			clone11.sakura:Emit(4)
			game.TweenService:Create(
				clone11,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(0.1, 0.1, (v[v12].p - v[v12 + 1].p).magnitude)
				}
			):Play()
			wait(0.2)
			game.TweenService:Create(
				clone11,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end)
		wait(0.1)
	end

	v3[#v3 + 1] = cframe2 * CFrame.new(0, 75, 0)
	v[#v + 1] = cframe2 * CFrame.new(0, 75, 0)
	magnitude = (v[13].p - v[14].p).magnitude
	game.TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = v[14]
	}):Play()
	local clone9 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.Spiral2:Clone()
	clone9:SetPrimaryPartCFrame(CFrame.new(v[13].p, v[14].p) * CFrame.new(0, 0, -magnitude))
	clone9.Parent = workspace.Effects
	_G.PU:Dust(clone9, 0.5)
	task.spawn(function()
		wait()
		local ModuleScript = require(clone9.ModuleScript)
		ModuleScript()
	end)
	local part3 = Instance.new("Part")
	part3.CFrame = v[14]
	part3.Size = createVector(1, 1, 1)
	part3.CanCollide = false
	part3.Anchored = true
	part3.Color = Color3.fromRGB(255, 0, 0)
	part3.Transparency = 1
	part3.Parent = workspace.Effects
	_G.PU:Dust(part3, 1.5)
	local clone10 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.transfrom2.Attachment:Clone()
	clone10.Parent = part3
	clone10.Spark.Rotation = NumberRange.new(math.random(0, 180))
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9213520822",
		PlaybackSpeed = 1.25,
		Volume = 1.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone10
	sound:Play()
	task.spawn(function()
		local ModuleScript = require(clone10.ModuleScript)
		ModuleScript()
	end)
	task.spawn(function()
		wait(math.random() * wait())

		for _ = 1, math.random(2, 3) do
			local clone11 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.sphere:Clone()
			clone11.CFrame = CFrame.new(v[13].p, v[14].p) * CFrame.new(
				math.random(-8, 8),
				math.random(-8, 8),
				-magnitude / 3
			) * CFrame.new(0, 0, math.random(-5, 5))
			clone11.Size = Vector3.new(1, 1, magnitude / 1.5)
			clone11.Transparency = -1
			clone11.Parent = workspace.Effects
			game.TweenService:Create(
				clone11,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = Vector3.new()
				}
			):Play()
			game.TweenService:Create(
				clone11,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone11.CFrame * CFrame.new(0, 0, -magnitude) * CFrame.new(0, 0, magnitude / 3)
				}
			):Play()
			_G.PU:Dust(clone11, 0.5)
			task.spawn(function()
				wait(0.15)
				game.TweenService:Create(
					clone11,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end
	end)
	local clone11 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.sphere:Clone()
	clone11.CFrame = CFrame.new(v[13].p, v[14].p)
	clone11.Size = createVector(15, 15, 0)
	clone11.Parent = workspace.Effects
	game.TweenService:Create(clone11, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.5, 0.5, magnitude)
	}):Play()
	game.TweenService:Create(clone11, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone11.CFrame * CFrame.new(0, 0, -magnitude / 2)
	}):Play()
	_G.PU:Dust(clone11, 1)
	task.spawn(function()
		wait(0.1)
		clone11.sakura:Emit(5)
		game.TweenService:Create(clone11, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 0.1, magnitude)
		}):Play()
		wait(0.3)
		game.TweenService:Create(clone11, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)

	if game.Players.LocalPlayer == data.plr then
		if colorCorrectionEffect then
			colorCorrectionEffect.Brightness = 0
			colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
			task.spawn(function()
				wait(0.65)
				colorCorrectionEffect.Brightness = -0.125
				colorCorrectionEffect.TintColor = Color3.fromRGB(255, 207, 188)
			end)
		end

		task.spawn(function()
			wait(0.65)
			local colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect2.Parent = game.Lighting
			colorCorrectionEffect2.Contrast = 2
			colorCorrectionEffect2.Saturation = -2
			_G.PU:Dust(colorCorrectionEffect2, 0.1)
		end)
		local colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect2.Parent = game.Lighting
		colorCorrectionEffect2.Contrast = -2
		colorCorrectionEffect2.Saturation = -1.25
		_G.PU:Dust(colorCorrectionEffect2, 0.65)
	end

	wait(0.65)
	local down = data.down

	if target and target:FindFirstChild("HumanoidRootPart") and (localPlayer.Character.HumanoidRootPart.CFrame.p - target.HumanoidRootPart.CFrame.p).magnitude < 500 then
		down = CFrame.new(target.HumanoidRootPart.CFrame.p) * CFrame.new(0, 0.1, 0)
	end

	if game.Players.LocalPlayer == data.plr then
		localPlayer.Character.HumanoidRootPart.CFrame = down
	end

	game.TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = down
	}):Play()

	if (localPlayer.Character.HumanoidRootPart.Position - down.p).Magnitude < 50 or game.Players.LocalPlayer == data.plr then
		_G.shake("Explosion")
	end

	v3[13] = cframe2 * CFrame.new(0, 75, 0)
	v[13] = cframe2 * CFrame.new(0, 75, 0)
	v[14] = down
	magnitude = (v[13].p - v[14].p).magnitude
	cframe = CFrame.new(v[13].p, v[14].p)
	local clone12 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.smoko:Clone()
	clone12.CFrame = cframe * CFrame.new(0, 0, -30) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone12.Parent = workspace.Effects
	_G.PU:Dust(clone12, 3)
	task.spawn(function()
		wait()
		local ModuleScript = require(clone12.ModuleScript)
		ModuleScript()
	end)
	local clone13 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.WindRing:Clone()
	clone13.CFrame = cframe * CFrame.new(0, 0, -5) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone13.Parent = workspace.Effects
	_G.PU:Dust(clone13, 1)
	task.spawn(function()
		local ModuleScript = require(clone13.ModuleScript)
		ModuleScript()
	end)
	local clone14 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.WindRing2:Clone()
	clone14.CFrame = cframe * CFrame.new(0, 0, -10) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone14.Parent = workspace.Effects
	_G.PU:Dust(clone14, 1)
	task.spawn(function()
		local ModuleScript = require(clone14.ModuleScript)
		ModuleScript()
	end)
	local clone15 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.Spiral2:Clone()
	clone15:SetPrimaryPartCFrame(CFrame.new(v[13].p, v[14].p) * CFrame.new(0, 0, -magnitude))
	clone15.Parent = workspace.Effects
	_G.PU:Dust(clone15, 0.5)
	task.spawn(function()
		wait()
		local ModuleScript = require(clone15.ModuleScript)
		ModuleScript()
	end)
	local part4 = Instance.new("Part")
	part4.CFrame = v[14]
	part4.Size = createVector(1, 1, 1)
	part4.CanCollide = false
	part4.Anchored = true
	part4.Color = Color3.fromRGB(255, 0, 0)
	part4.Transparency = 1
	part4.Parent = workspace.Effects
	_G.PU:Dust(part4, 2)
	local clone16 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.transfrom.Attachment:Clone()
	clone16.Parent = part4
	clone16.Spark.Rotation = NumberRange.new(math.random(0, 180))
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9167832679",
		PlaybackSpeed = 1.5,
		Volume = 2
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone16
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9228760842",
		PlaybackSpeed = 1.25,
		TimePosition = 0.1,
		Volume = 2.75
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone16
	sound3:Play()
	local sound4 = PeoUtils.CreateSound({
		RollOffMaxDistance = 400,
		RollOffMinDistance = 25,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5169902349",
		Volume = 3.5
	})
	_G.PU:Dust(sound4, 3)
	sound4.Parent = clone16
	sound4:Play()
	local sound5 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1250,
		RollOffMinDistance = 25,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://2648563122",
		Volume = 1.5
	})
	_G.PU:Dust(sound5, 3)
	sound5.Parent = clone16
	sound5:Play()
	task.spawn(function()
		local ModuleScript = require(clone16.ModuleScript)
		ModuleScript()
	end)
	task.spawn(function()
		wait(math.random() * wait())

		for _ = 1, math.random(2, 3) do
			local clone17 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.sphere:Clone()
			clone17.CFrame = CFrame.new(v[13].p, v[14].p) * CFrame.new(
				math.random(-8, 8),
				math.random(-8, 8),
				-magnitude / 3
			) * CFrame.new(0, 0, math.random(-5, 5))
			clone17.Size = Vector3.new(1, 1, magnitude / 1.5)
			clone17.Transparency = -1
			clone17.Parent = workspace.Effects
			game.TweenService:Create(
				clone17,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = Vector3.new()
				}
			):Play()
			game.TweenService:Create(
				clone17,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone17.CFrame * CFrame.new(0, 0, -magnitude) * CFrame.new(0, 0, magnitude / 3)
				}
			):Play()
			_G.PU:Dust(clone17, 0.5)
			task.spawn(function()
				wait(0.15)
				game.TweenService:Create(
					clone17,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end
	end)
	local clone17 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.sphere:Clone()
	clone17.CFrame = CFrame.new(v[13].p, v[14].p)
	clone17.Size = createVector(15, 15, 0)
	clone17.Parent = workspace.Effects
	game.TweenService:Create(clone17, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.5, 0.5, magnitude)
	}):Play()
	game.TweenService:Create(clone17, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone17.CFrame * CFrame.new(0, 0, -magnitude / 2)
	}):Play()
	_G.PU:Dust(clone17, 1)
	task.spawn(function()
		wait(0.1)
		clone17.sakura:Emit(5)
		game.TweenService:Create(clone17, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 0.1, magnitude)
		}):Play()
		wait(0.3)
		game.TweenService:Create(clone17, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	local cFrame2 = down * CFrame.new(0, -2.8565, 0)
	local clone18 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.Crack2:Clone()
	clone18.CFrame = cFrame2 * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	clone18.Parent = workspace.Effects
	_G.PU:Dust(clone18, 3)
	task.spawn(function()
		local ModuleScript = require(clone18.ModuleScript)
		ModuleScript()
	end)
	wait(0.25)

	if game.Players.LocalPlayer == data.plr then
		workspace.CurrentCamera.CameraSubject = cameraSubject
	end

	local clone19 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.Katana:Clone()
	clone19.CFrame = cFrame2 * CFrame.new(0, 27.5, 0)
	clone19.Parent = workspace.Effects
	_G.PU:Dust(clone19, 3)
	local sound6 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9213520822",
		PlaybackSpeed = 1.5,
		Volume = 1
	})
	_G.PU:Dust(sound6, 3)
	sound6.Parent = clone19
	sound6:Play()
	local clone20 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.wind3:Clone()
	clone20.CFrame = cFrame2
	clone20.Parent = workspace.Effects
	_G.PU:Dust(clone20, 3)
	local clone21 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.Crack3:Clone()
	clone21.CFrame = cFrame2 * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	clone21.Parent = workspace.Effects
	_G.PU:Dust(clone21, 4)
	task.spawn(function()
		local ModuleScript = require(clone19.ModuleScript)
		ModuleScript()
		local sound7 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1250,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://2648563122",
			Volume = 1.5
		})
		_G.PU:Dust(sound7, 3)
		sound7.Parent = clone21
		sound7:Play()
		local sound8 = PeoUtils.CreateSound({
			RollOffMaxDistance = 400,
			RollOffMinDistance = 25,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5169902349",
			Volume = 3.5
		})
		_G.PU:Dust(sound8, 3)
		sound8.Parent = clone21
		sound8:Play()

		if (localPlayer.Character.HumanoidRootPart.Position - cFrame2.p).Magnitude < 40 or game.Players.LocalPlayer == data.plr then
			_G.shake("Bump")
		end

		local ModuleScript2 = require(clone21.ModuleScript)
		ModuleScript2()
		local ModuleScript3 = require(clone20.ModuleScript)
		ModuleScript3()
	end)
	part:Destroy()
end