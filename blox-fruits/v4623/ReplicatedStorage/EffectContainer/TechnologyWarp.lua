local createVector = vector.create
game:GetService("RunService")

function round(p, value)
	local v = 10 ^ (value or 0)
	return math.floor(p * v + 0.5) / v
end

local function ScaleParticle(clone, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, clone.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

function RandomVectorOffsetBetween(p, p2, p3)
	local random = Random.new()
	return (CFrame.new(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local FX = require(game.ReplicatedStorage.FX)
local currentCamera = workspace.CurrentCamera
local technology = FX:WaitForChild("Technology")
local clone = technology.Swirl:Clone()
local clone2 = technology.SwirlCenter:Clone()
local Tween = require(game.ReplicatedStorage.Util.Tween)
Random.new()
local v = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep(script.Name, Enum.RenderPriority.Last.Value - 100, function(p)
	local now = tick()

	for k, v2 in pairs(v) do
		local v3 = now - v2.Start
		v2.Angle = v2.Angle % 6.283185307179586 + 4.537856055185257 * p
		local flag = true
		local v4 = 0

		if v2.FadeIn + v2.Lifetime + v2.FadeOut + 1 < v3 then
			for _, content in next, v2.Contents, nil do
				content.Part:Destroy()
			end

			v2.Center:Destroy()
			v[k] = nil
			flag = false
		elseif v2.FadeIn + v2.Lifetime < v3 then
			v2.Center.SwirlCenter.Enabled = false
			v4 = Tween.ease.out.quint(math.min(v2.FadeOut, v3 - (v2.FadeIn + v2.Lifetime)), 1, -1, v2.FadeOut)
		elseif v2.FadeIn < v3 then
			v4 = 1
		else
			v4 = Tween.ease.out.quint(math.min(v2.FadeIn, v3), 0, 1, v2.FadeIn)
		end

		if not flag then
			continue
		end

		if v2.Origin then
			v2.Center.CFrame = v2.Origin
		elseif v2.Position then
			v2.Center.CFrame = CFrame.new(v2.Position, currentCamera.CFrame.p)
		end

		for k2, content in next, v2.Contents, nil do
			local v5 = 6.283185307179586 * (k2 / 6)

			for k3, attachment in next, content.Attachments, nil do
				local v6 = k3 == 1 and 1 or -1
				attachment.CFrame = CFrame.new(0.5 * v2.SwirlScale * v6 * v4, 0, v2.SwirlScale * 0.6 * v4)
			end

			for k3, v6 in next, content.Attachments2, nil do
				local v7 = k3 == 1 and 1 or -1
				v6.CFrame = CFrame.new(-0.25 * v7 * v2.SwirlScale * 0.5 * v4, 0, -v7 * v2.SwirlScale * 0.75 * v4)
			end

			content.Part.CFrame = v2.Center.CFrame * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				v5 - v2.Angle,
				0
			) * CFrame.new(0, 0, -v2.SwirlScale / 2 * v4) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
				0,
				0.5235987755982988,
				0
			)
			content.Part.Mesh.Scale = createVector(0.07189073, 0.6887052, 0.07149496) * Vector3.new(
				v2.SwirlScale * 2,
				v2.SwirlScale * 3,
				v2.SwirlScale * 1.5
			) * v4
		end
	end
end)
return function(list)
	local position, swirlScale, fadeIn, lifetime, fadeOut = unpack(list)
	local cframe

	if typeof(position) == "CFrame" then
		cframe = position
	else
		cframe = CFrame.new(position)
	end

	if (cframe.p - currentCamera.CFrame.p).Magnitude > 400 then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.CFrame = cframe
	local clone3 = clone2:Clone()
	clone3.Size = ScaleParticle(clone3, swirlScale)
	clone3.Parent = attachment
	attachment.Parent = workspace.Terrain
	local contents = {}

	for i = 0, 5 do
		local clone4 = clone:Clone()
		clone4.CFrame = attachment.CFrame * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			6.283185307179586 * (i / 6),
			0
		) * CFrame.new(0, 0, -0) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(0, 0.5235987755982988, 0)
		clone4.Mesh.Scale = createVector(0, 0, 0)
		local attachments = {}

		for i2 = 1, 2 do
			local v10 = i2 == 1 and 1 or -1
			local attachment2 = Instance.new("Attachment", clone4)
			attachment2.CFrame = CFrame.new(0 * v10, 0, 0)
			table.insert(attachments, attachment2)
		end

		local clone5 = technology.SwirlTrail:Clone()
		clone5.FaceCamera = true
		clone5.LightEmission = 0.3
		clone5.Lifetime = 0.35
		local attachment4 = attachments[1]
		local attachment5 = attachments[2]
		clone5.Attachment0 = attachment4
		clone5.Attachment1 = attachment5
		clone5.Parent = clone4
		local attachment2 = Instance.new("Attachment", clone4)
		attachment2.CFrame = CFrame.new(-0, 0, -0)
		table.insert(attachments, attachment2)
		local attachment3 = Instance.new("Attachment", clone4)
		attachment3.CFrame = CFrame.new(0, 0, 0)
		table.insert(attachments, attachment3)
		local clone6 = technology.SwirlTrail:Clone()
		clone6.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})
		clone6.Lifetime *= 0.75
		local attachment6 = attachments[1]
		local attachment7 = attachments[2]
		clone6.Attachment0 = attachment6
		clone6.Attachment1 = attachment7
		clone6.Parent = clone4
		clone4.Parent = workspace._WorldOrigin
		table.insert(contents, {
			Part = clone4,
			Attachments = attachments,
			Attachments2 = {}
		})
	end

	local v9 = {
		rng_v = Random.new(),
		Origin = typeof(position) == "CFrame" and position,
		Position = 0,
		Angle = 0,
		SwirlScale = 0,
		Center = 0,
		Contents = 0,
		FadeIn = 0,
		Lifetime = 0,
		FadeOut = 0,
		Start = 0
	}

	if typeof(position) ~= "Vector3" then
		position = false
	end

	v9.Position = position
	v9.SwirlScale = swirlScale
	v9.Center = attachment
	v9.Contents = contents
	v9.FadeIn = fadeIn
	v9.Lifetime = lifetime
	v9.FadeOut = fadeOut
	v9.Start = tick()
	table.insert(v, v9)
end