local function CreatePointPart(position)
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = CFrame.new(position)
	Instance.new("Attachment", part)
	game.Debris:AddItem(part, 1)
	part.Parent = game.Workspace
	return part
end

local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local TweenService = game:GetService("TweenService")
return function(instance, p)
	local parent = CreatePointPart(instance.Position)
	local pointPart = CreatePointPart(p)
	local customBeam = instance:FindFirstChild("CustomBeam")
	local v3

	if customBeam then
		v3 = customBeam:Clone()
	else
		v3 = Instance.new("Beam")
		v3.Width0 = 0.2
		v3.Width1 = 0.2
		v3.LightEmission = 0.5
		v3.LightInfluence = 0
		v3.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.202, 0.95),
			NumberSequenceKeypoint.new(1, 0.6)
		})
	end

	v3.Attachment0 = parent.Attachment
	v3.Attachment1 = pointPart.Attachment
	v3.FaceCamera = true
	v3.Parent = parent
	wait(0.03)
	TweenService:Create(v3, tweenInfo, {
		Width0 = 0
	}):Play()
	TweenService:Create(v3, tweenInfo2, {
		Width1 = 0
	}):Play()
end