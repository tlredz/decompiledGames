local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local cf = data.cf
	local tocf = data.tocf

	if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 45 or game.Players.LocalPlayer == data.plr then
		_G.shake("Bump")
	end

	task.spawn(function()
		if game.Players.LocalPlayer == data.plr then
			localPlayer.Character.HumanoidRootPart.CFrame = tocf * CFrame.new(0, 2.45, 0)
			local part = Instance.new("Part")
			part.CFrame = cf
			part.Size = createVector(5, 5, 5)
			part.CanCollide = false
			part.Anchored = true
			part.Color = Color3.fromRGB(255, 0, 0)
			part.Transparency = 1
			part.Name = "Cam"
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 1)
			workspace.CurrentCamera.CameraSubject = part
			TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = tocf
			}):Play()
			wait(0.3)
			workspace.CurrentCamera.CameraSubject = localPlayer.Character.Humanoid
		end
	end)
	local clone = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.leg:Clone()
	clone.Parent = workspace.Effects
	clone.Size = createVector(0, 0, 22)
	clone.CFrame = cf * CFrame.Angles(0, 3.141592653589793, 0)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5801257793",
		Volume = 1.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	_G.PU:Dust(clone, 2)
	TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(5, 5, 62.5)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.new(0, 0, 50)
	}):Play()
	local pointLight = clone.PointLight
	pointLight.Range = 40
	TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = pointLight.Range / 2
	}):Play()
	task.spawn(function()
		wait(0.1)
		TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 75)
		}):Play()
		wait(0.1)
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.FlameSpiral2:Clone()
	clone2.Parent = workspace.Effects
	clone2:SetPrimaryPartCFrame(cf * CFrame.new(0, 0, -30))
	clone2.PrimaryPart.Blast:Emit(10)
	clone2.PrimaryPart.Spec1:Emit(10)
	clone2.PrimaryPart.Spec2:Emit(25)
	task.spawn(function()
		local ModuleScript = require(clone2.ModuleScript)
		ModuleScript()
		_G.PU:Dust(clone2, 0.75)
	end)

	for _, part in pairs(clone2:GetChildren()) do
		if part:IsA("BasePart") and part ~= clone2.PrimaryPart then
			TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = part.CFrame * CFrame.new(40, 0, 0)
			}):Play()
		end
	end

	local clone3 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.WindRing:Clone()
	clone3.CFrame = cf * CFrame.new(0, 0, -5) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 1)
	task.spawn(function()
		local ModuleScript = require(clone3.ModuleScript)
		ModuleScript()
	end)
	local part = Instance.new("Part")
	part.CFrame = cf
	part.Size = createVector(1, 1, 1)
	part.CanCollide = false
	part.Anchored = true
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Transparency = 1
	part.Parent = workspace.Effects
	_G.PU:Dust(part, 1.5)
	local clone4 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.transfrom.Attachment:Clone()
	clone4.Parent = part
	clone4.Spark.Rotation = NumberRange.new(math.random(0, 180))
	task.spawn(function()
		local ModuleScript = require(clone4.ModuleScript)
		ModuleScript()
	end)
	task.spawn(function()
		local v = { createVector(1, 43.365, 43.365), createVector(1, 31, 31), createVector(1, 18, 18) }

		for i = 1, 3 do
			local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Shockwave:Clone()
			clone5.CFrame = cf * CFrame.new(0, 0, i * -25) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
				0,
				0,
				0
			) * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
			clone5.Size = Vector3.new()
			clone5.Parent = workspace.Effects
			TweenService:Create(clone5, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone5.CFrame * CFrame.new(-10, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = v[i] * 1.25
			}):Play()
			_G.PU:Dust(clone5, 1)
			task.spawn(function()
				wait(0.2)
				TweenService:Create(
					clone5,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
			clone.Spark2:Emit(2.5)
			clone.Spark:Emit(2.5)
			clone.wave:Emit(2)
			wait()
			local clone6 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Shockwave:Clone()
			clone6.CFrame = cf * CFrame.new(0, 0, i * -25) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
				5,
				0,
				0
			) * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
			clone6.Size = Vector3.new()
			clone6.Color = Color3.fromRGB(159, 159, 159)
			clone6.Parent = workspace.Effects
			TweenService:Create(clone6, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone6.CFrame * CFrame.new(-15, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = v[i] * 0.5
			}):Play()
			_G.PU:Dust(clone6, 1)
			task.spawn(function()
				wait(0.2)
				TweenService:Create(
					clone6,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end
	end)
	task.spawn(function()
		wait(math.random() * wait())

		for _ = 1, math.random(2, 3) do
			local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.sphere:Clone()
			clone5.CFrame = cf * CFrame.new(math.random(-7, 7), math.random(-7, 7), -25) * CFrame.new(
				0,
				0,
				math.random(-5, 5)
			)
			clone5.Size = createVector(1, 1, 50)
			clone5.Transparency = -1
			clone5.Color = Color3.fromRGB(202, 202, 202)
			clone5.Parent = workspace.Effects
			TweenService:Create(clone5, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone5.CFrame * CFrame.new(0, 0, -75) * CFrame.new(0, 0, 25)
			}):Play()
			_G.PU:Dust(clone5, 0.5)
			task.spawn(function()
				wait(0.15)
				TweenService:Create(
					clone5,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end
	end)
end