local createVector = vector.create
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
			Brightness = 0.5
		}
	):Play()
	game.TweenService:Create(parent, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(60, 1, 60)
	}):Play()
	game.TweenService:Create(parent.dark, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0.25
	}):Play()
	game.TweenService:Create(parent.neon, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 0
	}):Play()
	parent.Attachment.Ring:Emit(2)
	parent.Attachment.big:Emit(1)
	parent.Attachment.sparkl1:Emit(10)
	parent.Attachment.sparkl2:Emit(10)
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

		for _, emitter in pairs(parent.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		wait(2.75)

		for _, emitter in pairs(parent.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		parent.rock.Enabled = false
		parent.diable.Enabled = false
		parent.diable2.Enabled = false
		parent.Specs.Enabled = false
	end)
	task.spawn(function()
		wait(2.75)
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