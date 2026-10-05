local createVector = vector.create
local HeartbeatLoopFor = require(script.Parent.Parent.Parent.Parent.Loops.HeartbeatLoopFor)
local IsSequenceNotConstant = require(script.Parent.Parent.Parent.SchemesUtil.IsSequenceNotConstant)
local NumSeqMap = require(script.Parent.Parent.Parent.Parent.SequenceMaps.NumSeqMap)
local SizeScheme = {
	Attributes = {
		SizeFrom = createVector(0, 0, 0),
		SizeMultiplierGoal = createVector(1, 1, 1),
		SizeSequence = NumberSequence.new(0),
		SizeScalesAttachments = false,
		SizeScalesEmitters = false
	},
	_InsertResetState = function(p, instance, folder)
		if not p[folder] then
			p[folder] = {}
		end

		local v = p[folder]
		v.CFrame = folder.CFrame
		v.Size = folder.Size
		local sizeScalesAttachments = instance:GetAttribute("SizeScalesAttachments")
		local sizeScalesEmitters = instance:GetAttribute("SizeScalesEmitters")

		if sizeScalesAttachments or sizeScalesEmitters then
			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant.ClassName == "Attachment" and sizeScalesAttachments then
					if not p[descendant] then
						p[descendant] = {}
					end

					p[descendant].CFrame = descendant.CFrame
				elseif descendant.ClassName == "ParticleEmitter" and sizeScalesEmitters then
					if not p[descendant] then
						p[descendant] = {}
					end

					local v2 = p[descendant]
					v2.Size = descendant.Size
					v2.Speed = descendant.Speed
					v2.Acceleration = descendant.Acceleration
				end
			end
		end
	end,
	_LoopCondition = function(instance)
		return IsSequenceNotConstant(instance:GetAttribute("SizeSequence"))
	end
}

local function ScaleParticle(state, p)
	local keypoints = state.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	state.Size = NumberSequence.new(numberSequenceKeypoints)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Acceleration *= p
end

function SizeScheme.Setup(instance)
	for k, attribute in pairs(SizeScheme.Attributes) do
		instance:SetAttribute(k, attribute)
	end
end

function SizeScheme.Play(instance, p, p2)
	if not SizeScheme._LoopCondition(instance) then
		return
	end

	local folder = p2 or instance
	local sizeFrom = instance:GetAttribute("SizeFrom")
	local sizeScalesAttachments = instance:GetAttribute("SizeScalesAttachments")
	local sizeScalesEmitters = instance:GetAttribute("SizeScalesEmitters")
	local descendants = {}
	local descendants2 = {}

	if sizeScalesAttachments or sizeScalesEmitters then
		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant.ClassName == "Attachment" and sizeScalesAttachments then
				table.insert(descendants, descendant)
			elseif descendant.ClassName == "ParticleEmitter" and sizeScalesEmitters then
				table.insert(descendants2, descendant)
			end
		end
	end

	local function fn(data)
		local v = math.max(data.X, data.Y, data.Z)

		for _, v2 in ipairs(descendants2) do
			ScaleParticle(v2, v)
		end
	end

	local size = folder.Size
	local v = folder.Size * instance:GetAttribute("SizeMultiplierGoal") - size
	local v2 = NumSeqMap.new(instance:GetAttribute("SizeSequence"), instance:GetAttribute("Keypoints"))
	local v3 = size

	if sizeFrom == createVector(0, 0, 0) then
		HeartbeatLoopFor(p, function(_, _, p3)
			local size2 = size + v * v2:GetValue(p3)
			local v5 = size2 / v3
			folder.Size = size2

			for _, v6 in ipairs(descendants) do
				v6.Position *= v5
			end

			fn(v5)
			v3 = size2
		end, function()
			local size2 = size + v * v2:GetValue(1)
			local v5 = size2 / v3
			folder.Size = size2

			for _, v6 in ipairs(descendants) do
				v6.Position *= v5
			end

			fn(v5)
		end)
	else
		HeartbeatLoopFor(p, function(_, _, p3)
			local size2 = size + v * v2:GetValue(p3)
			local v5 = size2 / v3
			folder.Position = folder.CFrame:PointToWorldSpace(sizeFrom - sizeFrom * v5)
			folder.Size = size2
			sizeFrom *= v5

			for _, v6 in ipairs(descendants) do
				v6.Position *= v5
			end

			fn(v5)
			v3 = size2
		end, function()
			local size2 = size + v * v2:GetValue(1)
			local v5 = size2 / v3
			folder.Position = folder.CFrame:PointToWorldSpace(sizeFrom - sizeFrom * v5)
			folder.Size = size2

			for _, v6 in ipairs(descendants) do
				v6.Position *= v5
			end

			fn(v5)
		end)
	end
end

return SizeScheme