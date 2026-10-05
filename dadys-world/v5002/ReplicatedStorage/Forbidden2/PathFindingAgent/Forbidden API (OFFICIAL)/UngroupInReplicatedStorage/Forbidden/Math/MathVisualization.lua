local createVector = vector.create
local v = {}
local folder = nil

local function getInstance(p)
	if folder == nil then
		folder = Instance.new("Folder")
		folder.Name = "ForbiddenMathVisualizerParts"
		folder.Parent = workspace
	end

	if v[p] then
		return v[p]
	end

	v[p] = {}
	local folder2 = Instance.new("Folder")
	folder2.Name = p.Name
	folder2.Parent = folder

	local function makeNewPart(_: string)
		local part = Instance.new("Part")
		part.Size = createVector(1, 1, 1)
		part.Material = Enum.Material.Neon
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = true
		part.CastShadow = false
		part.Transparency = 0.5
		return part
	end

	local part = Instance.new("Part")
	part.Size = createVector(1, 1, 1)
	part.Material = Enum.Material.Neon
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Anchored = true
	part.CastShadow = false
	part.Transparency = 0.5
	part.Shape = Enum.PartType.Ball
	part.Parent = folder2
	v[p].originPart = part
	local part2 = Instance.new("Part")
	part2.Size = createVector(1, 1, 1)
	part2.Material = Enum.Material.Neon
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.Anchored = true
	part2.CastShadow = false
	part2.Transparency = 0.5
	part2.Shape = Enum.PartType.Ball
	part2.Parent = folder2
	v[p].endPart = part2
	local part3 = Instance.new("Part")
	part3.Size = createVector(1, 1, 1)
	part3.Material = Enum.Material.Neon
	part3.CanCollide = false
	part3.CanQuery = false
	part3.CanTouch = false
	part3.Anchored = true
	part3.CastShadow = false
	part3.Transparency = 0.5
	part3.Parent = folder2
	v[p].connectingPart = part3
	return v[p]
end

local function isValidVector3(vector2: Vector3)
	return vector2.X == vector2.X and vector2.Y == vector2.Y and vector2.Z == vector2.Z
end

return {
	VisualizeRaycast = function(p, position: Vector3, position2: Vector3, flag: boolean)
		local instance = getInstance(p)
		local originPart = instance.originPart
		local endPart = instance.endPart
		local connectingPart = instance.connectingPart
		local v2

		if position.X == position.X and position.Y == position.Y then
			v2 = position.Z == position.Z
		else
			v2 = false
		end

		if v2 then
			local v3

			if position2.X == position2.X and position2.Y == position2.Y then
				v3 = position2.Z == position2.Z
			else
				v3 = false
			end

			if v3 then
				originPart.Position = position
				endPart.Position = position2
				local midpoint = (position + position2) / 2
				local v5

				if midpoint.X == midpoint.X and midpoint.Y == midpoint.Y then
					v5 = midpoint.Z == midpoint.Z
				else
					v5 = false
				end

				if v5 then
					connectingPart.CFrame = CFrame.lookAt(midpoint, position2)
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function ChangeColor(brickColor)
					originPart.BrickColor = brickColor
					endPart.BrickColor = brickColor
					connectingPart.BrickColor = brickColor
				end

				if flag then
					ChangeColor(BrickColor.Green()) -- equivalent call inferred; original call site unknown
				end

				if not flag then
					ChangeColor(BrickColor.Red()) -- equivalent call inferred; original call site unknown
				end

				return
			end
		end

		warn("Invalid Vector3 detected. Skipping visualization.")
	end
}