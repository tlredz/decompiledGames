local createVector = vector.create
return function()
	local parent = script.Parent
	game:GetService("TweenService")
	local neon = script.Parent.neon
	local dark = script.Parent.dark
	script.Parent.Size = Vector3.new()
	dark.Transparency = 1
	neon.Transparency = 1
	game.TweenService:Create(parent, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(60, 1, 60)
	}):Play()
	game.TweenService:Create(parent.dark, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0.5
	}):Play()
	game.TweenService:Create(parent.neon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0
	}):Play()
	local attachment = parent.Attachment
	attachment.Ring:Emit(1)
	attachment.Spark:Emit(2)
	attachment.sparkl1:Emit(9)
	attachment.sparkl2:Emit(9)
	attachment.big:Emit(3)
	attachment.big2:Emit(6)
	attachment.Spark2:Emit(5)
	parent.diable.Enabled = true
	parent.rock:Emit(35)
	parent.Attachment.Specs:Emit(25)
	task.spawn(function()
		local clone = game.ReplicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.Shockwave2:Clone()
		clone.Size = createVector(2.5, 5, 5)
		clone.Position = script.Parent.Position + createVector(0, 2, 0)
		clone.Parent = workspace.Effects
		clone.Color = Color3.fromRGB(239, 115, 66)
		clone.Transparency = 0.25
		clone.Material = Enum.Material.Neon
		local TweenService = game:GetService("TweenService")
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(6, 70, 70),
			Orientation = clone.Orientation + createVector(0, 180, 0)
		}):Play()
		task.wait(0.35)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(clone, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(0, 72, 72),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 0.6)
	end)
	task.spawn(function()
		wait(1)
		parent.diable.Enabled = false
		game.TweenService:Create(
			parent.dark,
			TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
		game.TweenService:Create(
			parent.neon,
			TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		):Play()
	end)
end