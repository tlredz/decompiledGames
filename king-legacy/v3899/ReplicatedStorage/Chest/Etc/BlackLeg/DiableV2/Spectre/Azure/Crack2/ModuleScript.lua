local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function()
	local parent = script.Parent
	game:GetService("TweenService")
	local neon = script.Parent.neon
	local dark = script.Parent.dark
	script.Parent.Size = Vector3.new()
	dark.Transparency = 1
	neon.Transparency = 1
	game.TweenService:Create(
		parent.PointLight,
		TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{
			Range = 50,
			Brightness = 0.25
		}
	):Play()
	game.TweenService:Create(parent, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(60, 1, 60)
	}):Play()
	game.TweenService:Create(parent.dark, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0.5
	}):Play()
	game.TweenService:Create(parent.neon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0
	}):Play()
	parent.Attachment.Ring:Emit(2)
	parent.Attachment.big:Emit(3)
	parent.Attachment.sparkl1:Emit(10)
	parent.Attachment.sparkl2:Emit(10)
	parent.Attachment.Spark:Emit(2)
	parent.Attachment.Spark2:Emit(6)
	task.spawn(function() end)
	task.spawn(function()
		local clone = game.ReplicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.Shockwave2:Clone()
		clone.Size = createVector(2.5, 5, 5)
		clone.Position = script.Parent.Position + createVector(0, 2, 0)
		clone.Parent = workspace.Effects
		clone.Color = Color3.fromRGB(83, 138, 255)
		clone.Transparency = 0.25
		clone.Material = Enum.Material.Neon
		local TweenService = game:GetService("TweenService")
		TweenService:Create(clone, TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(6, 70, 70),
			Orientation = clone.Orientation + createVector(0, 180, 0)
		}):Play()
		task.wait(0.25)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(0, 72, 72),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 0.6)
	end)
	task.spawn(function()
		parent.rock:Emit(35)
		parent.rock.Enabled = true
		parent.diable.Enabled = true
		parent.diable2.Enabled = true
		parent.Specs.Enabled = true

		for _ = 1, 5 do
			wait(0.6)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9201395294",
				PlaybackSpeed = 1.65,
				Volume = 1.25
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = parent
			sound:Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://8748164748",
				PlaybackSpeed = 0.85,
				Volume = 2
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = parent
			sound2:Play()
			game.TweenService:Create(
				parent.PointLight,
				TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true, 0),
				{
					Range = 60,
					Brightness = 0.4
				}
			):Play()
			game.TweenService:Create(
				parent,
				TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = createVector(70, 1, 70)
				}
			):Play()
			parent.rock:Emit(25)
			parent.diable3:Emit(20)
			parent.Attachment.Ring:Emit(2)
			parent.Attachment.sparkl1:Emit(10)
			parent.Attachment.sparkl2:Emit(10)
			parent.Attachment.big:Emit(3)
			task.spawn(function()
				local clone = game.ReplicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.Shockwave2:Clone()
				clone.Size = createVector(2.5, 5, 5)
				clone.Position = script.Parent.Position + createVector(0, 2, 0)
				clone.Parent = workspace.Effects
				clone.Color = Color3.fromRGB(83, 138, 255)
				clone.Transparency = 0.25
				clone.Material = Enum.Material.Neon
				local TweenService = game:GetService("TweenService")
				TweenService:Create(
					clone,
					TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(6, 70, 70),
						Orientation = clone.Orientation + createVector(0, 180, 0)
					}
				):Play()
				task.wait(0.2)
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 72, 72),
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone, 0.6)
			end)
		end

		parent.rock.Enabled = false
		parent.diable.Enabled = false
		parent.diable2.Enabled = false
		parent.Specs.Enabled = false
	end)
	task.spawn(function()
		wait(3)
		game.TweenService:Create(
			parent.PointLight,
			TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Brightness = 0,
				Range = 5
			}
		):Play()
		game.TweenService:Create(
			parent.dark,
			TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
		game.TweenService:Create(
			parent.neon,
			TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
	end)
end