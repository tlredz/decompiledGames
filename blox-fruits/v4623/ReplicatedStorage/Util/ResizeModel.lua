local function HasProperty(instance, childName)
	local success, result = pcall(function()
		return instance[childName]
	end)
	return success and result ~= instance:FindFirstChild(childName)
end

local function ScaleParticle(instance, p)
	local keypoints = instance.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	instance.Size = NumberSequence.new(numberSequenceKeypoints)
	instance.Speed = NumberRange.new(instance.Speed.Min * p, instance.Speed.Max * p)
	instance.Acceleration *= p
end

function adjust(instance, p, p2, list)
	if instance:IsA("BasePart") then
		local position = instance.Position
		local rotation = instance.CFrame.Rotation
		local v = position - p2
		table.insert(list, function()
			instance.Size *= p
			instance.CFrame = rotation + p2 + v * p
		end)

		for _, child in pairs(instance:GetChildren()) do
			adjust(child, p, p2, list)
		end
	elseif instance:IsA("Model") then
		for _, child in pairs(instance:GetChildren()) do
			adjust(child, p, p2, list)
		end
	elseif instance:IsA("Attachment") then
		instance.Position *= p

		for _, child in pairs(instance:GetChildren()) do
			adjust(child, p, p2, list)
		end
	elseif instance:IsA("ParticleEmitter") then
		ScaleParticle(instance, p)
	elseif instance:IsA("Beam") then
		instance.Width0 *= p
		instance.Width1 *= p
		instance.CurveSize0 *= p
		instance.CurveSize1 *= p
	else
		if instance:IsA("PointLight") then
			instance.Range *= p
			return
		end

		local v = "MeshId"
		local success, result = pcall(function()
			return instance[v]
		end)

		if success and result ~= instance:FindFirstChild("MeshId") then
			instance.Scale *= p
			instance.Offset *= p
		else
			local v2 = "C0"
			local success2, result2 = pcall(function()
				return instance[v2]
			end)

			if success2 and result2 ~= instance:FindFirstChild("C0") then
				instance.C0 = instance.C0.Rotation + instance.C0.Position * p
				instance.C1 = instance.C1.Rotation + instance.C1.Position * p
			end
		end
	end
end

local function resizeModel(instance, p, position)
	if not position then
		if instance:IsA("Model") then
			position = instance:GetPivot().Position
		elseif instance:IsA("BasePart") then
			position = instance.Position
		elseif instance:IsA("Attachment") then
			position = instance.WorldPosition
		end
	end

	local v = {}

	for _, child in ipairs(instance:GetChildren()) do
		adjust(child, p, position, v)
	end

	for _, v2 in v do
		v2()
	end
end

return resizeModel