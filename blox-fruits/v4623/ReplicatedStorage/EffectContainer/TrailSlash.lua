local createVector = vector.create

function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FPSTracker = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("FPSTracker"))
local RenderDistance = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("RenderDistance"))
local v = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("TrailSlash", Enum.RenderPriority.Last.Value + 1003, function(p)
	for k, v2 in next, v, nil do
		local v3 = tick() - v2.Start
		local v4 = v3 / v2.RotateDuration

		if v4 > 1 then
			if v2.Lifetime + v2.RotateDuration < v3 then
				v2.TrailPart:Destroy()
				v[k] = nil
			end
		elseif v2.RenderDistance:WithinRange(p) then
			local v5 = lerpNumber(v2.ZOffset[1], v2.ZOffset[2], v4)
			local v6 = lerpNumber(v2.Width[1], v2.Width[2], v4)

			for k2, attachment in next, v2.Attachments, nil do
				attachment.CFrame = CFrame.new(0, 0, (k2 % 2 == 0 and 1 or -1) * v6)
			end

			v2.TrailPart.CFrame = v2.CFrame * CFrame.Angles(0, v4 * (3.141592653589793 + v2.AngleOffset), 0) * CFrame.new(
				0,
				0,
				-v5
			)
		end
	end
end)
return function(data)
	local renderRequirements = data.RenderRequirements
	local v2 = not renderRequirements and 50 or renderRequirements.FPS or 50
	local v3 = not renderRequirements and 60 or renderRequirements.DistanceMin or 60
	local v4 = not renderRequirements and 75 or renderRequirements.DistanceMax or 75
	local multiplier = renderRequirements and renderRequirements.Multiplier
	local origin = data.Origin
	local offset = data.Offset
	local color = data.Color
	local width = data.Width
	local zOffset = data.ZOffset
	local rotateDuration = data.RotateDuration
	local lifetime = data.Lifetime
	local numberSequence = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(0.8, 0.15),
		NumberSequenceKeypoint.new(1, 1)
	})

	if v2 < FPSTracker.FPS and RenderDistance.value(origin.p) < v3 then
		local part = Instance.new("Part")
		part.Transparency = 1
		part.TopSurface = 0
		part.BottomSurface = 0
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(0.05, 0.05, 0.05)
		part.CFrame = origin
		local attachments = {}

		for i = 1, 2 do
			local attachment = Instance.new("Attachment", part)
			attachment.CFrame = CFrame.new(0, 0, (i % 2 == 0 and 1 or -1) * width[1])
			table.insert(attachments, attachment)
		end

		local trail = Instance.new("Trail", part)
		trail.LightEmission = data.LightEmission or 0.75
		trail.LightInfluence = 0

		if data.SecondaryColor then
			trail.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color),
				ColorSequenceKeypoint.new(1, data.SecondaryColor)
			})
		else
			trail.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color),
				ColorSequenceKeypoint.new(0.5, color),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
			})
		end

		trail.Transparency = numberSequence
		local attachment2 = attachments[1]
		local attachment3 = attachments[2]
		trail.Attachment0 = attachment2
		trail.Attachment1 = attachment3
		trail.Lifetime = lifetime
		trail.MinLength = 0
		trail.Texture = "rbxassetid://1275200298"
		trail.FaceCamera = true
		part.CFrame = origin * offset * CFrame.new(0, 0, -zOffset[1])
		part.Parent = workspace._WorldOrigin
		local v9 = {
			Attachments = attachments,
			Trail = trail,
			TrailPart = part,
			CFrame = origin * offset,
			RenderDistance = RenderDistance.new(origin.p, v3, v4, multiplier),
			Width = width,
			ZOffset = zOffset,
			AngleOffset = 0,
			RotateDuration = 0,
			Lifetime = 0,
			Start = 0
		}
		local v10 = math.random(1, 3) == 1 and 1 or -1
		local v11 = math.random(8, 24)
		v9.AngleOffset = v10 * (3.141592653589793 / v11)
		v9.RotateDuration = rotateDuration
		v9.Lifetime = lifetime
		v9.Start = tick()
		table.insert(v, v9)
	end
end