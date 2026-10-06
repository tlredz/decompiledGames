local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(p)
	local start = script.Parent.start
	local attachment = script.Parent["end"]
	local beam = script.Parent.Beam
	start.CFrame = CFrame.new(start.CFrame.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	attachment.CFrame = CFrame.new(attachment.CFrame.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)

	if p.startatt then
		start = p.startatt
	end

	local tocf = CFrame.new(start.CFrame.p) * CFrame.new(0, 100, 0) * CFrame.Angles(
		0,
		6.283185307179586 * math.random(),
		0
	)

	if p.tocf then
		tocf = p.tocf
	end

	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9279738916",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = start
	sound:Play()
	attachment.CFrame = start.CFrame
	beam.Attachment0 = start
	beam.Attachment1 = attachment
	beam.Width0 = 0.05
	beam.Width1 = 0.05
	local v2 = math.random(1, 2) == 1 and 9.5 or -9.5
	local v3 = math.random(1, 2) == 1 and 9.5 or -9.5
	beam.CurveSize0 = v2 * 2
	beam.CurveSize1 = v3 * 2
	game.TweenService:Create(attachment, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		WorldCFrame = tocf
	}):Play()
	game.TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CurveSize0 = math.random(-9.5, 9.5),
		CurveSize1 = math.random(-9.5, 9.5)
	}):Play()
	wait(0.15)
	game.TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CurveSize0 = -beam.CurveSize0,
		CurveSize1 = -beam.CurveSize1
	}):Play()
	wait(0.15)
	game.TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CurveSize0 = math.random(-9.5, 9.5) * 0.01,
		CurveSize1 = math.random(-9.5, 9.5) * 0.01
	}):Play()
	wait(0.25)
	game.TweenService:Create(beam, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Width0 = 0,
		Width1 = 0
	}):Play()
end