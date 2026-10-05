local createVector = vector.create

local function CreatePointPart(position)
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Anchored = true
	part.Size = createVector(1, 1, 1)
	part.CanCollide = false
	part.CanQuery = false
	part.CFrame = CFrame.new(position)
	Instance.new("Attachment", part)
	game.Debris:AddItem(part, 1)
	part.Parent = game.Workspace
	return part
end

local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
local TweenService = game:GetService("TweenService")
return function(instance, position, vector2: Vector3, p)
	if typeof(position) ~= "Vector3" then
		if position:IsA("BasePart") then
			position = position.Position
		elseif position:IsA("Attachment") then
			position = position.WorldPosition
		else
			return
		end
	end

	local parent = CreatePointPart(position)
	local parent2 = CreatePointPart(vector2)
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
	v3.Attachment1 = parent2.Attachment
	v3.FaceCamera = true
	v3.Parent = parent

	if p then
		local clone = script:WaitForChild("Sparks"):Clone()
		clone.Color = ColorSequence.new(p.Color)
		clone.Parent = parent2
		clone:Emit(7)
	end

	wait(0.03)
	TweenService:Create(v3, tweenInfo, {
		Width0 = 0
	}):Play()
	TweenService:Create(v3, tweenInfo2, {
		Width1 = 0
	}):Play()
end