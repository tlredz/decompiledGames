local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Destruction = require(ReplicatedStorage.Chest.Assets.Modules.Features.Destruction)
return function(p)
	local part = p.Part

	if not part or (workspace.CurrentCamera.CFrame.Position - part:GetModelCFrame().Position).Magnitude >= 600 then
		return
	end

	local clone = part:Clone()
	clone.Name = "FakePart"
	local part2 = Instance.new("Part")
	part2.Size = Vector3.new()
	part2.Transparency = 1
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanTouch = false
	part2.CanQuery = false
	part2.CastShadow = false
	part2.CFrame = part:GetModelCFrame()
	part2.Parent = workspace.Effects
	local sound = _G.PU.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://1741599172",
		Volume = 0.35
	})
	sound.Parent = part2
	sound:Play()
	_G.PU:Dust({ part2, sound }, 3)

	for _, part3 in pairs(clone:GetChildren()) do
		if not (part3:IsA("BasePart") and part3.ClassName ~= "WedgePart") then
			continue
		end

		local gridBreak = Destruction:GridBreak(part3)
		local clones = {}

		for _, parent in pairs(gridBreak) do
			parent.Anchored = nil
			parent.CanCollide = true
			parent.Transparency = 0
			parent.CollisionGroup = "Effect"
			parent.Velocity = Vector3.new(math.random(-50, 50), math.random(5, 20), math.random(-50, 50))
			parent.RotVelocity = Vector3.new(math.random(-25, 25), math.random(-10, 10), math.random(-25, 25))
			local clone2 = ReplicatedStorage.Chest.Etc.DestroyT.Smoke:Clone()
			clone2.Color = ColorSequence.new(parent.Color)
			clone2.Enabled = true
			clone2.Parent = parent
			_G.PU:Dust({ clone2, parent }, 4)
			TweenService:Create(
				parent,
				TweenInfo.new(0.75, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 3),
				{
					Size = createVector(0, 0, 0)
				}
			):Play()
			table.insert(clones, clone2)
		end

		task.delay(1, function()
			for k, v2 in pairs(clones) do
				v2.Enabled = false
			end
		end)
	end

	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 4)
end