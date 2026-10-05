local createVector = vector.create

function getFrame(p)
	local position = p.Part.CFrame.Position
	return CFrame.new(position.X, position.Y, position.Z)
end

function getFloorY(instance)
	local cFrame = instance.CFrame
	local halfSize = instance.Size / 2
	return math.abs(cFrame.RightVector.Y) * halfSize.X + math.abs(cFrame.UpVector.Y) * halfSize.Y + math.abs(cFrame.LookVector.Y) * halfSize.Z
end

function getDepth(p)
	local parent = p.Parent
	local count = 0

	while parent do
		count += 1
		parent = parent.Parent
	end

	return count
end

function getAttachmentOffset(instance, cframe: CFrame)
	local cFrame = instance.CFrame
	local parent = instance.Parent

	while parent and parent:IsA("Attachment") do
		cFrame = parent.CFrame * cFrame
		parent = parent.Parent
	end

	if parent and parent:IsA("BasePart") then
		cFrame = parent.CFrame * cFrame
	end

	return (cframe:Inverse() * cFrame).Position
end

function getUpAxis(cframe: CFrame)
	local Y = math.abs(cframe.RightVector.Y)
	local Y2 = math.abs(cframe.UpVector.Y)
	local Y3 = math.abs(cframe.LookVector.Y)

	if Y2 <= Y and Y3 <= Y then
		return createVector(1, 0, 0)
	end

	if Y2 < Y3 then
		return createVector(0, 0, 1)
	end

	return createVector(0, 1, 0)
end

function scaleHeight(vector2: Vector3, p: number, p2: number)
	return (Vector3.new(vector2.X, p + (vector2.Y - p) * p2, vector2.Z))
end

function scaleSizeAlong(vector2: Vector3, vector3: Vector3, p: number)
	return vector2 * (createVector(1, 1, 1) - vector3) + vector2 * vector3 * p
end

local Geometry = {
	newAnchor = function(part)
		return {
			Part = part,
			FloorY = getFloorY(part)
		}
	end,
	placePart = function(p, instance)
		local cFrame = instance.CFrame
		return {
			Part = instance,
			Offset = getFrame(p):Inverse() * cFrame,
			Size = instance.Size,
			UpAxis = getUpAxis(cFrame)
		}
	end
}

function Geometry.collectHosts(p, items)
	local frame = getFrame(p)
	local v = {}
	local instances = {}
	local v2 = {
		Attachments = {},
		Parts = {}
	}

	for _, instance in items do
		if not instance or v[instance] or instance == p.Part then
			continue
		end

		v[instance] = true

		if instance:IsA("Attachment") then
			table.insert(instances, instance)
		elseif instance:IsA("BasePart") then
			table.insert(v2.Parts, Geometry.placePart(p, instance))
		end
	end

	table.sort(instances, function(a, b)
		return getDepth(a) < getDepth(b)
	end)

	for _, attachment in instances do
		table.insert(v2.Attachments, {
			Attachment = attachment,
			Offset = getAttachmentOffset(attachment, frame)
		})
	end

	return v2
end

function Geometry.beamHosts(p, items)
	local v = {}

	for _, item in items do
		table.insert(v, item.Attachment0)
		table.insert(v, item.Attachment1)
	end

	return Geometry.collectHosts(p, v)
end

function Geometry.particleHosts(p, items)
	local parents = {}

	for _, item in items do
		table.insert(parents, item.Parent)
	end

	return Geometry.collectHosts(p, parents)
end

function Geometry.applyPart(p, data, p2: number, p3: number)
	local offset = data.Offset
	local v = scaleHeight(offset.Position, p.FloorY, p2)
	data.Part.CFrame = getFrame(p) * (offset - offset.Position + v) * CFrame.Angles(0, p3, 0)
	data.Part.Size = scaleSizeAlong(data.Size, data.UpAxis, (math.max(p2, 0.001)))
end

function Geometry.applyHosts(p, p2, p3: number)
	local frame = getFrame(p)

	for _, attachment in p2.Attachments do
		attachment.Attachment.WorldPosition = frame:PointToWorldSpace(scaleHeight(attachment.Offset, p.FloorY, p3))
	end

	for _, part in p2.Parts do
		Geometry.applyPart(p, part, p3, 0)
	end
end

return Geometry