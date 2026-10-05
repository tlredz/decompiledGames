local createVector = vector.create
local FishModel = require(script.Parent.FishModel)
local identity = CFrame.identity
local color = Color3.new(0, 0, 0)
local HarpoonProjectile = {
	VELOCITY_FALLBACK = 120,
	PROJECTILE_ROTATION_OFFSET = identity,
	RETRACT_SPEED_MULT = 6,
	RETRACT_RAMP_TIME = 0.35,
	RETRACT_MIN_SPEED_FRACTION = 0.25,
	PROJECTILE_RETURN_EPSILON = 1,
	IMPACT_STICK_TIME = 0.3,
	HOOK_GRACE_TIME = 1.5,
	WOBBLE_FREQUENCY = 45,
	WOBBLE_ANGLE_DEGREES = 7,
	WOBBLE_DECAY = 10,
	WIRE_WIDTH = 0.06,
	WIRE_COLOR = color,
	PULL_SPEED_MULT = 3,
	CATCH_FX_GRACE_TIME = 0.5,
	CATCH_FX_MAX_AGE = 3,
	FISH_PULL_ROTATION_OFFSET = CFrame.identity,
	FISH_MODEL_MAX_SIZE = 100,
	ARM_PITCH_MAX_DEGREES = 55,
	ARM_PITCH_LERP_SPEED = 12
}

local function collectParts(folder)
	local parts = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	return parts
end

local function resolvePrimaryPart(folder)
	if folder.PrimaryPart then
		return folder.PrimaryPart
	end

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			return part
		end
	end

	return nil
end

local function findAttachment(instance, childName: string)
	local attachment = instance:FindFirstChild(childName, true)

	if attachment and attachment:IsA("Attachment") then
		return attachment
	end

	return nil
end

function HarpoonProjectile.parseCatchFx(fishName, p, p2, mutation, weight)
	if type(fishName) ~= "string" then
		return nil
	end

	local v = {
		fishName = fishName,
		shiny = p == true,
		sparkling = p2 == true,
		mutation = 0,
		weight = 0,
		receivedAt = 0
	}

	if type(mutation) ~= "string" then
		mutation = nil
	end

	v.mutation = mutation

	if type(weight) ~= "number" or not math.isfinite(weight) then
		weight = nil
	end

	v.weight = weight
	v.receivedAt = os.clock()
	return v
end

function HarpoonProjectile.buildCatchFishModel(data)
	local folder = FishModel.Create({
		Name = data.fishName,
		ItemData = {
			Shiny = data.shiny,
			Sparkling = data.sparkling,
			Mutation = data.mutation,
			Weight = data.weight
		},
		CastShadow = false,
		RemoveScripts = true,
		ResizeArgs = {
			MaxSize = 100
		}
	})

	if not folder then
		return nil
	end

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	return folder
end

function HarpoonProjectile.readStat(value, p: number)
	if typeof(value) == "number" and value == value and value > 0 and value ~= 1e999 then
		return value
	end

	return p
end

function HarpoonProjectile.findProjectileSource(instance)
	local harpoon = instance:FindFirstChild("Harpoon", true)

	if harpoon and harpoon:IsA("Model") then
		return harpoon
	end

	return nil
end

function HarpoonProjectile.setLocalTransparency(p, localTransparencyModifier: number)
	for _, v in collectParts(p) do
		v.LocalTransparencyModifier = localTransparencyModifier
	end
end

function HarpoonProjectile.buildRig(instance)
	local primaryPart = resolvePrimaryPart(instance)
	local tip = instance:FindFirstChild("tip", true)

	if not (tip and tip:IsA("Attachment")) then
		tip = nil
	end

	local wire = instance:FindFirstChild("wire", true)

	if not (wire and wire:IsA("Attachment")) then
		wire = nil
	end

	if not (primaryPart and tip and wire) then
		return nil
	end

	local pivot = instance:GetPivot()
	local pointToObjectSpace = pivot:PointToObjectSpace(tip.WorldPosition)
	local pointToObjectSpace2 = pivot:PointToObjectSpace(wire.WorldPosition)
	local v = pointToObjectSpace - pointToObjectSpace2
	local magnitude = v.Magnitude

	if magnitude < 0.1 then
		return nil
	end

	local v2 = math.abs(v.Unit.Y) > 0.99 and createVector(1, 0, 0) or createVector(0, 1, 0)
	local cframe = CFrame.lookAt(pointToObjectSpace2, pointToObjectSpace, v2)
	return {
		instance = instance,
		primary = primaryPart,
		parts = collectParts(instance),
		length = magnitude,
		pivotOffset = identity * cframe:Inverse(),
		wireAttachment = wire
	}
end

function HarpoonProjectile.buildProjectile(instance)
	if not instance then
		return nil
	end

	local clone = instance:Clone()

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("WeldConstraint") or descendant:IsA("JointInstance") then
			descendant:Destroy()
		end
	end

	for _, v in collectParts(clone) do
		v.Anchored = true
		v.CanCollide = false
		v.CanQuery = false
		v.CanTouch = false
		v.CastShadow = false
		v.Massless = true
		v.LocalTransparencyModifier = 0
	end

	local rig = HarpoonProjectile.buildRig(clone)

	if rig then
		return rig
	end

	clone:Destroy()
	return nil
end

function HarpoonProjectile.pickSound(instance, p: string, p2)
	if not instance then
		return p2
	end

	local sounds = {}

	for _, sound in instance:GetChildren() do
		if not sound:IsA("Sound") or not string.match(sound.Name, (`^{p}%d*$`)) or sound:GetAttribute("temp") then
			continue
		end

		table.insert(sounds, sound)
	end

	if #sounds > 0 then
		return sounds[math.random(1, #sounds)]
	end

	return p2
end

local v = {}

function HarpoonProjectile.trackProjectile(p, p2)
	v[p2] = p
end

function HarpoonProjectile.untrackProjectile(p)
	v[p] = nil
end

function HarpoonProjectile.stepJanitor()
	for k, v2 in v do
		if k.Parent then
			if not v2.Parent then
				v[k] = nil
				k:Destroy()
			end
		else
			v[k] = nil
		end
	end
end

function HarpoonProjectile.aimFrame(vector2: Vector3, vector3: Vector3)
	local v2 = math.abs(vector3.Y) > 0.99 and createVector(1, 0, 0) or createVector(0, 1, 0)
	return CFrame.lookAt(vector2, vector2 + vector3, v2)
end

function HarpoonProjectile.frameFromTip(p, vector2: Vector3, vector3: Vector3)
	return HarpoonProjectile.aimFrame(vector2 - vector3 * p.length, vector3)
end

function HarpoonProjectile.tipCFrame(p, cframe: CFrame)
	return cframe * CFrame.new(0, 0, -p.length)
end

function HarpoonProjectile.wobbleFrame(p, cframe: CFrame, p2: number)
	return cframe * CFrame.new(0, 0, -p.length) * CFrame.Angles(p2, 0, 0) * CFrame.new(0, 0, p.length)
end

function HarpoonProjectile.applyPose(p, cframe: CFrame)
	p.instance:PivotTo(cframe * p.pivotOffset)
end

function HarpoonProjectile.encodeWireColor(sequence)
	if typeof(sequence) == "Color3" then
		return (`{sequence.R},{sequence.G},{sequence.B}`)
	end

	local v2 = {}

	for _, keypoint in sequence.Keypoints do
		local value = keypoint.Value
		table.insert(v2, (`{keypoint.Time}:{value.R},{value.G},{value.B}`))
	end

	return table.concat(v2, ";")
end

function HarpoonProjectile.parseWireColor(value)
	if type(value) ~= "string" or value == "" then
		return nil
	end

	if string.find(value, ":", 1, true) then
		local colorSequenceKeypoints = {}

		for _, v2 in string.split(value, ";") do
			local v3 = string.split(v2, ":")

			if #v3 ~= 2 then
				return nil
			end

			local v4 = tonumber(v3[1])
			local v5 = string.split(v3[2], ",")

			if not v4 or #v5 ~= 3 then
				return nil
			end

			local v6 = tonumber(v5[1])
			local v7 = tonumber(v5[2])
			local v8 = tonumber(v5[3])

			if v6 and v7 and v8 then
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(math.clamp(v4, 0, 1), Color3.new(v6, v7, v8))
				)
			else
				return nil
			end
		end

		if #colorSequenceKeypoints < 2 then
			return nil
		end

		local success, result = pcall(ColorSequence.new, colorSequenceKeypoints)

		if success then
			return result
		end

		return nil
	else
		local v2 = string.split(value, ",")

		if #v2 ~= 3 then
			return nil
		end

		local v3 = tonumber(v2[1])
		local v4 = tonumber(v2[2])
		local v5 = tonumber(v2[3])

		if v3 and v4 and v5 then
			return ColorSequence.new(Color3.new(v3, v4, v5))
		end

		return nil
	end
end

function HarpoonProjectile.buildWire(attachment, p, p2: string?)
	local wireColor = HarpoonProjectile.parseWireColor(p2)
	local beam = Instance.new("Beam")
	beam.Name = "wire"
	beam.Attachment0 = attachment
	beam.Attachment1 = p.wireAttachment
	beam.Width0 = 0.06
	beam.Width1 = 0.06
	beam.Color = wireColor or ColorSequence.new(color)
	beam.FaceCamera = true
	beam:AddTag("IgnorePerformance")
	beam.Parent = p.primary
	return beam
end

return HarpoonProjectile