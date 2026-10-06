local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local cframe = CFrame.new(data.tocf.p)
	local v = {}
	local v2 = {}
	v2[#v2 + 1] = CFrame.new(data.cf.p)
	local localPlayer = game.Players.LocalPlayer
	local v3 = {
		CFrame.Angles(0, 3.839724354387525, 0) * CFrame.new(0, 0, -math.random(35, 40)),
		CFrame.Angles(0, 6.283185307179586, 0) * CFrame.new(0, 0, -math.random(45, 50)),
		CFrame.Angles(0, 2.443460952792061, 0) * CFrame.new(0, 0, -math.random(45, 50)),
		CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.new(0, 0, -math.random(45, 50)),
		CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(0, 0, -math.random(45, 50)),
		CFrame.Angles(0, 3.839724354387525, 0) * CFrame.new(0, 0, -math.random(45, 50)),
		CFrame.new(0, 20, 0),
		CFrame.new(0, -20, 0)
	}
	v[#v + 1] = cframe
	v2[#v2 + 1] = cframe

	if game.Players.LocalPlayer == data.plr then
		_G.shake("Bump")
		game.TweenService:Create(
			localPlayer.Character.HumanoidRootPart,
			TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				CFrame = data.tocf
			}
		):Play()
	end

	for i = 1, 8 do
		local v4 = cframe * CFrame.new(0, i * 2.5, 0) * v3[i]
		v[#v + 1] = v4
		v2[#v2 + 1] = v4
	end

	local part = Instance.new("Part")
	part.CFrame = v2[1]
	part.Size = createVector(5, 5, 5)
	part.CanCollide = false
	part.Anchored = true
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Transparency = 1
	part.Name = "Cam"
	part.Parent = workspace.Effects
	local cameraSubject = workspace.CurrentCamera.CameraSubject

	if game.Players.LocalPlayer == data.plr then
		workspace.CurrentCamera.CameraSubject = part
		task.spawn(function()
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Parent = game.Lighting
			colorCorrectionEffect.Brightness = -0.125
			colorCorrectionEffect.TintColor = Color3.fromRGB(255, 207, 188)
			_G.PU:Dust(colorCorrectionEffect, 3)
			wait(0.9)
			wait(0.25)
			game.TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0
				}
			):Play()
		end)
	end

	if (localPlayer.Character.HumanoidRootPart.Position - cframe.p).Magnitude < 75 then
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Parent = game.Lighting
		colorCorrectionEffect.Contrast = -2
		colorCorrectionEffect.TintColor = Color3.fromRGB(255, 152, 92)
		game.TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Contrast = 0
			}
		):Play()
		game.TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				TintColor = Color3.fromRGB(255, 255, 255)
			}
		):Play()
		_G.PU:Dust(colorCorrectionEffect, 1)
	end

	for k, cFrame in pairs(v) do
		if not v2[k + 1] then
			continue
		end

		if k == 9 then
			v2[9 + 1] = data.down

			if game.Players.LocalPlayer == data.plr then
				localPlayer.Character.HumanoidRootPart.CFrame = data.down
			end
		end

		game.TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(v2[k].p, v2[k + 1].p) * CFrame.new(0, 0, -(v2[k].p - v2[k + 1].p).magnitude)
		}):Play()

		if (localPlayer.Character.HumanoidRootPart.Position - cframe.p).Magnitude < 50 or game.Players.LocalPlayer == data.plr then
			if k == 9 then
				_G.shake("Bump")
			else
				_G.shake("SmallBump")
			end
		end

		local clone = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.Spiral:Clone()
		clone:SetPrimaryPartCFrame(CFrame.new(v2[k].p, v2[k + 1].p) * CFrame.new(
			0,
			0,
			-(v2[k].p - v2[k + 1].p).magnitude
		))
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 0.5)
		task.spawn(function()
			local ModuleScript = require(clone.ModuleScript)
			ModuleScript()
		end)
		local part2 = Instance.new("Part")
		part2.CFrame = cFrame
		part2.Size = createVector(1, 1, 1)
		part2.CanCollide = false
		part2.Anchored = true
		part2.Color = Color3.fromRGB(255, 0, 0)
		part2.Transparency = 1
		part2.Name = "Part" .. k
		part2.Parent = workspace.Effects
		_G.PU:Dust(part2, 1.5)
		local clone2 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.transfrom.Attachment:Clone()
		clone2.Parent = part2
		clone2.Spark.Rotation = NumberRange.new(math.random(0, 180))
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6780413304",
			Volume = 1.5,
			PlaybackSpeed = 1.25
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone2
		sound:Play()

		if k == 9 then
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://8882227579",
				Volume = 3,
				PlaybackSpeed = 1.15
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone2
			sound2:Play()
			part2.CFrame = data.down
			clone2.sm2:Emit(30)
		end

		task.spawn(function()
			local ModuleScript = require(clone2.ModuleScript)
			ModuleScript()
		end)
		local v7 = k
		task.spawn(function()
			wait(math.random() * wait())

			for i = 1, math.random(2, 3) do
				local clone3 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.sphere:Clone()
				clone3.CFrame = CFrame.new(v2[v7].p, v2[v7 + 1].p) * CFrame.new(
					math.random(-7, 7),
					math.random(-7, 7),
					-(v2[v7].p - v2[v7 + 1].p).magnitude / 3
				) * CFrame.new(0, 0, math.random(-5, 5))
				clone3.Size = Vector3.new(0.75, 0.75, (v2[v7].p - v2[v7 + 1].p).magnitude / 1.5)
				clone3.Parent = workspace.Effects
				game.TweenService:Create(
					clone3,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new()
					}
				):Play()
				game.TweenService:Create(
					clone3,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone3.CFrame * CFrame.new(0, 0, -(v2[v7].p - v2[v7 + 1].p).magnitude) * CFrame.new(
							0,
							0,
							(v2[v7].p - v2[v7 + 1].p).magnitude / 3
						)
					}
				):Play()
				_G.PU:Dust(clone3, 0.5)
				task.spawn(function()
					wait(0.15)
					game.TweenService:Create(
						clone3,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end
		end)
		local clone3 = ReplicatedStorage.Chest.SwordEffect.Muramasa.X.sphere:Clone()
		clone3.CFrame = CFrame.new(v2[k].p, v2[k + 1].p)
		clone3.Size = createVector(15, 15, 0)
		clone3.Parent = workspace.Effects
		game.TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(1, 1, (v2[k].p - v2[k + 1].p).magnitude)
		}):Play()
		game.TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone3.CFrame * CFrame.new(0, 0, -(v2[k].p - v2[k + 1].p).magnitude / 2)
		}):Play()
		_G.PU:Dust(clone3, 1)
		local v9 = k
		task.spawn(function()
			wait(0.1)

			if clone3:FindFirstChild("sakura") then
				clone3.sakura:Emit(4)
			end

			game.TweenService:Create(
				clone3,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = Vector3.new(0.1, 0.1, (v2[v9].p - v2[v9 + 1].p).magnitude)
				}
			):Play()
			wait(0.15)
			game.TweenService:Create(
				clone3,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end)
		wait(0.1)
	end

	if game.Players.LocalPlayer == data.plr then
		workspace.CurrentCamera.CameraSubject = cameraSubject
	end

	part:Destroy()
end