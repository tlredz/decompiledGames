local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
return function(data)
	local part = data.part

	if not part then
		return
	end

	local cFrame = part.CFrame

	if game.Players.LocalPlayer == data.player then
		local clone = script.inverse:Clone()
		clone.Parent = game.Lighting
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://1081841854",
			Volume = 1,
			PlaybackSpeed = 0.9,
			TimePosition = 0.35
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
		task.spawn(function()
			wait(0.15)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Contrast = 0,
				Saturation = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}):Play()
		end)
		_G.PU:Dust(clone, 0.45)
		local clone2 = script.ScreenGui:Clone()
		clone2.Parent = game.Players.LocalPlayer.PlayerGui
		local frame = clone2.Frame
		frame.Rotation = math.random(-180, 180)
		frame.Size = UDim2.new(2, 0, 0.1, 0)
		task.spawn(function()
			wait()
			TweenService:Create(frame, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = UDim2.new(2, 0, 0, 0)
			}):Play()
		end)
		_G.PU:Dust(clone2, 0.5)
	end

	if data.target:IsA("Player") and data.target == game.Players.LocalPlayer then
		local clone = script.inverse:Clone()
		_G.PU:Dust(clone, 0.45)
		clone.Parent = game.Lighting
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://1081841854",
			Volume = 1,
			PlaybackSpeed = 0.9,
			TimePosition = 0.35
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = workspace.Effects
		sound:Play()
		task.spawn(function()
			wait(0.15)
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Contrast = 0,
				Saturation = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}):Play()
		end)
		local clone2 = script.ScreenGui:Clone()
		clone2.Parent = game.Players.LocalPlayer.PlayerGui
		local frame = clone2.Frame
		frame.Rotation = math.random(-180, 180)
		frame.Size = UDim2.new(2, 0, 0.1, 0)
		task.spawn(function()
			wait()
			TweenService:Create(frame, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = UDim2.new(2, 0, 0, 0)
			}):Play()
		end)
		_G.PU:Dust(clone2, 0.5)
	end

	wait(0.5)
	local clone = ReplicatedStorage.Chest.SwordEffect.SoulCane.piercing_slash:Clone()
	_G.PU:Dust(clone, 3)
	clone.CFrame = cFrame * CFrame.Angles(
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	)
	clone.Parent = workspace.Effects
	PeodizService.ForceForLoop({
		Step = 6,
		WaitTime = 0.1
	}, function(p)
		local v = math.floor(p * 6)

		if not part then
			return true
		end

		if game.Players.LocalPlayer == data.player then
			local v2 = v == 6 and "SmallBump" or "SmallerBump"
			_G.shake(v2)
		end

		local clone2 = clone.sample:Clone()
		clone2.CFrame = clone.sample.CFrame * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		clone2.Parent = clone
		clone2.dotz:Emit(9)
		clone2.smoke:Emit(5)
		clone2.shard:Emit(9)
		clone2.slash:Emit(35)
		clone2.Lines:Emit(20)
		clone2.spark:Emit(5)

		if v == 6 then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://10090605140",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
		else
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://8748165437",
				PlaybackSpeed = 1.5,
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://7104937177",
				PlaybackSpeed = 1.75,
				Volume = 0.76
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone2
			sound2:Play()
		end

		local clone3 = ReplicatedStorage.Chest.SwordEffect.SoulCane.wind:Clone()
		clone3.Parent = workspace.Effects
		clone3.CFrame = cFrame
		local ModuleScript = require(clone3.ModuleScript)
		ModuleScript()
		_G.PU:Dust(clone3, 1)
	end)
end