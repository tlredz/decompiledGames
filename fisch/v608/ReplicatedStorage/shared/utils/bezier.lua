local createVector = vector.create
local Bezier = {}
local color = Color3.fromRGB(25, 26, 31)
local fabric = Enum.Material.Fabric

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function lerp(p, p2, p3)
	return (1 - p3) * p + p3 * p2
end

function Bezier.getNode(p, ...)
	local v = { ... }

	while #v > 1 do
		for i = 1, #v - 1 do
			v[i] = lerp(v[i], v[i + 1], p)
		end

		v[#v] = nil
	end

	return v[1]
end

function Bezier.getFolder(parent)
	local lines = parent:FindFirstChild("Lines")

	if lines then
		return lines
	end

	local folder = Instance.new("Folder")
	folder.Name = "Lines"
	folder.Parent = parent
	return folder
end

function Bezier.getSettings(instance)
	local v = {}
	local color2 = instance:FindFirstChild("Color")

	if color2 then
		v[1] = color2.Value
	else
		v[1] = color
	end

	local material = instance:FindFirstChild("Material")

	if material then
		v[2] = Enum.Material[material.Value] or fabric
		return v
	end

	v[2] = fabric
	return v
end

function Bezier.createPart(p, p2, p3, p4)
	local settings = Bezier.getSettings(p4)
	local part = Instance.new("Part")
	part.Name = "Line" .. tostring(p)
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0.15, 0.15, (p2 - p3).Magnitude)
	part.CFrame = CFrame.lookAt(p2, p3, createVector(0, 1, 0)) * CFrame.new(0, 0, part.Size.Z / -2)
	part.Material = settings[2] or fabric
	part.Color = settings[1] or color
	part.Parent = Bezier.getFolder(p4)
end

function Bezier.new(p, ...)
	local v = { ... }
	local positions = {}

	for i = 1, #v do
		table.insert(positions, v[i].Position)
	end

	for i = 0, 0.9999999999999999, 0.025 do
		local node = Bezier.getNode(i, unpack(positions))
		local node2 = Bezier.getNode(i + 0.025, unpack(positions))
		Bezier.createPart(i, node, node2, p)
	end
end

return Bezier