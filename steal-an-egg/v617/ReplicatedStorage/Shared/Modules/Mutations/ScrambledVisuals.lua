local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {
	Clear = function(folder)
		for _, descendant in folder:GetDescendants() do
			if descendant:HasTag("Cleanup_Scrambled") then
				descendant:Destroy()
			end
		end
	end
}

local function emitter(emitter2, parent, p: number)
	local clone = emitter2:Clone()
	local numberSequenceKeypoints = {}

	for _, keypoint in emitter2.Size.Keypoints do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope * p)
		)
	end

	clone.Size = NumberSequence.new(numberSequenceKeypoints)
	clone.Speed = NumberRange.new(emitter2.Speed.Min * p, emitter2.Speed.Max * p)
	clone.Acceleration = emitter2.Acceleration * p
	clone:AddTag("Cleanup_Scrambled")
	clone:AddTag("Effect")
	clone.Parent = parent
end

function v.Apply(folder, parent)
	v.Clear(folder)
	local scrambled = ReplicatedStorage.Mutations:FindFirstChild("Scrambled")

	if not (scrambled and parent) then
		return
	end

	local referenceSize = scrambled:GetAttribute("ReferenceSize")
	local v2 = (typeof(referenceSize) ~= "Vector3" or not (referenceSize.Magnitude > 0)) and 1 or math.clamp(
		parent.Size.Magnitude / referenceSize.Magnitude,
		0.01,
		100
	)
	local body = scrambled:FindFirstChild("Body")

	if body then
		for _, emitter2 in body:GetChildren() do
			if emitter2:IsA("ParticleEmitter") then
				emitter(emitter2, parent, v2)
			end
		end
	end

	local eyes = scrambled:FindFirstChild("Eyes")

	if not eyes then
		return
	end

	local v3 = {}

	for _, bone in folder:GetDescendants() do
		if not (bone:IsA("Bone") and bone.Name:lower():find("eye", 1, true)) then
			continue
		end

		if bone.Name:lower():find("brow", 1, true) then
			continue
		end

		table.insert(v3, bone)
	end

	if #v3 == 0 then
		for _, part in folder:GetDescendants() do
			if part:IsA("BasePart") and part:GetAttribute("IsEye") == true then
				table.insert(v3, part)
			end
		end
	end

	for k, parent2 in v3 do
		if k > 8 then
			break
		end

		local attachment = Instance.new("Attachment")
		attachment.Name = "ScrambledEyeFX"
		local attribute = eyes:GetAttribute(parent2.Name)

		if typeof(attribute) == "CFrame" then
			attachment.CFrame = attribute.Rotation + attribute.Position * v2
		end

		attachment:AddTag("Cleanup_Scrambled")
		attachment:AddTag("Effect")
		attachment.Parent = parent2

		for _, emitter2 in eyes:GetChildren() do
			if emitter2:IsA("ParticleEmitter") then
				emitter(emitter2, attachment, v2)
			end
		end
	end
end

return table.freeze(v)