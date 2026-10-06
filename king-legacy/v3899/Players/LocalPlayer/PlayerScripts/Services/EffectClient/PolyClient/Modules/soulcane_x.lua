local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local player = data.Player

	if not data.char then
		return
	end

	local rootPart = data.RootPart

	if not rootPart then
		return
	end

	local cFrame = rootPart.CFrame
	task.spawn(function()
		if game.Players.LocalPlayer == player then
			_G.shake("SmallBump")
		end

		wait()
		local clone = replicatedStorage.Chest.SwordEffect.SoulCane.morbing:Clone()
		clone.CFrame = cFrame
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 1)
		clone.Attachment.big:Emit(1)
		clone.Attachment.Ring:Emit(2)

		for _ = 1, 9 do
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Cylinder
			part.Anchored = true
			part.CanCollide = false
			part.Size = createVector(5, 2, 2) * math.random(10, 15) / 10
			part.CFrame = cFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			part.CFrame *= CFrame.new(part.Size.X / 2, 0, 0)
			part.Parent = workspace.Effects
			local random = require(script.random)
			part.Color = random({ Color3.fromRGB(94, 150, 255), Color3.fromRGB(105, 215, 255) })
			part.Material = Enum.Material.Neon
			_G.PU:Dust(part, 1)
			TweenService:Create(
				part,
				TweenInfo.new(math.random(50, 60) / 100, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = part.CFrame * CFrame.new(math.random(17, 25), 0, 0)
				}
			):Play()
			task.spawn(function()
				wait()
				TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = Vector3.new(part.Size.X + 1, 0, 0)
				}):Play()
				wait(0.1)
				TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
		end
	end)
	local cFrame2 = nil
	local character

	if player:IsA("Player") then
		character = player.Character
	else
		character = player
	end

	tick()
	PeodizService.HeartbeatWait({
		Time = 8,
		WaitTime = 0.05
	}, function()
		if not character:IsDescendantOf(workspace) then
			return true
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and character:FindFirstChild("SoulCaneX")) then
			return true
		end

		cFrame2 = humanoidRootPart.CFrame

		if (localPlayer.Character.HumanoidRootPart.Position - cFrame2.p).Magnitude < 30 or game.Players.LocalPlayer == player then
			_G.shake("SmallerBump2")
		end

		for _ = 1, 1 do
			task.wait()
			task.wait()
			local clone = replicatedStorage.Chest.SwordEffect.SoulCane.slash5:Clone()
			_G.PU:Dust(clone, 1)
			clone.mesh.Scale = createVector(6.6325, 0.685, 6.6325)
			clone.CFrame = cFrame2 * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			clone.Parent = workspace.Effects
			local fx = require(clone.decal.fx)
			fx()
			clone.sparks:Emit(math.random(0, 1))
			clone.Ice2:Emit(10)
			clone.sm2:Emit(2)
			clone.flakes:Emit(2)
			clone.smoke:Emit(2)
			clone.Ice:Emit(2)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://10166443718",
				PlaybackSpeed = 1.25,
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://10166444311",
				PlaybackSpeed = 1.25,
				Volume = 1
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone
			sound2:Play()
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.new(0, 0, -3.25) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			TweenService:Create(
				clone.mesh,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = createVector(16.581251, 1.7125, 16.581251)
				}
			):Play()
		end
	end)
	cFrame2 = CFrame.new(cFrame2.p)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8823677867",
		Volume = 1,
		PlaybackSpeed = 1.25
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = rootPart
	sound:Play()

	for i = 1, 6 do
		local cFrame3 = cFrame2 * CFrame.Angles(0, 1.0471975511965976 * i, 0) * CFrame.new(0, -12, -20) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
		local cFrame4 = cFrame2 * CFrame.Angles(0, 1.0471975511965976 * i, 0) * CFrame.new(0, 8, -35) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
		local clone = replicatedStorage.Chest.SwordEffect.SoulCane.IceShard:Clone()
		_G.PU:Dust(clone, 1)
		clone.Size = createVector(16.651, 15.3855, 17.6635)
		clone.CFrame = cFrame3
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 0.25
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = cFrame4
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(41.6275, 38.46375, 44.15875)
		}):Play()
		task.spawn(function()
			clone.Sm:Emit(11)
			wait(0.75)
			TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new(),
				CFrame = cFrame3
			}):Play()
		end)
	end

	task.wait(0.7)

	if (localPlayer.Character.HumanoidRootPart.Position - cFrame2.p).Magnitude < 60 or game.Players.LocalPlayer == player then
		_G.shake("Bump")
	end

	local clone = replicatedStorage.Chest.SwordEffect.SoulCane.explode:Clone()
	clone.CFrame = cFrame2
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 2)
	clone.Dots:Emit(25)
	clone.Sm:Emit(30)
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://10166445810",
		Volume = 1.25
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://10166446725",
		Volume = 1.25
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone
	sound3:Play()

	for _ = 1, 8 do
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Cylinder
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(5.5, 2.5, 2.5) * math.random(20, 25) / 10
		part.CFrame = cFrame2 * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		part.CFrame *= CFrame.new(part.Size.X / 2, 0, 0)
		part.Parent = workspace.Effects
		local random = require(script.random)
		part.Color = random({ Color3.fromRGB(94, 150, 255), Color3.fromRGB(105, 215, 255) })
		part.Material = Enum.Material.Neon
		_G.PU:Dust(part, 1)
		TweenService:Create(
			part,
			TweenInfo.new(math.random(60, 75) / 100, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				CFrame = part.CFrame * CFrame.new(math.random(30, 40), 0, 0)
			}
		):Play()
		task.spawn(function()
			wait()
			TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(part.Size.X + 2, 0, 0)
			}):Play()
			wait(0.1)
			TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
	end

	local clone2 = replicatedStorage.Chest.SwordEffect.SoulCane.Ball:Clone()
	clone2.Transparency = -2
	clone2.CFrame = cFrame2
	clone2.Size = createVector(100, 100, 100)
	clone2.Color = Color3.fromRGB(153, 232, 255)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 0.5)
	TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = Vector3.new(),
		Transparency = 0.6
	}):Play()

	for _ = 1, 2 do
		local clone3 = replicatedStorage.Chest.SwordEffect.SoulCane.slash4:Clone()
		clone3.mesh.Scale = Vector3.new()
		clone3.CFrame = cFrame2 * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		clone3.Parent = workspace.Effects
		local fx = require(clone3.decal.fx)
		fx()
		_G.PU:Dust(clone3, 1)
		TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone3.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
		TweenService:Create(clone3.mesh, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Scale = createVector(43.87275, 4.5315, 43.87275)
		}):Play()
	end
end