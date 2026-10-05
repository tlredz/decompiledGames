local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local frozen = table.freeze({
	DriverSeatOffsetAttribute = "LookoutDriverSeatOffset",
	Templates = {
		Dinghy = "Dinghy",
		Sloop = "PirateSloop",
		Brigade = "PirateBrigade",
		["Grand Brigade"] = "PirateGrandBrigade"
	},
	Lanes = {
		Dinghy = 1,
		Sloop = 2,
		Brigade = 3,
		["Grand Brigade"] = 4
	},
	SailColors = {
		White = Color3.fromRGB(245, 245, 240),
		Black = Color3.fromRGB(35, 35, 42),
		Orange = Color3.fromRGB(230, 159, 0),
		Green = Color3.fromRGB(0, 158, 115)
	},
	HullColors = {
		Brown = Color3.fromRGB(108, 88, 75),
		Red = Color3.fromRGB(151, 62, 62),
		Blue = Color3.fromRGB(62, 95, 151),
		Gray = Color3.fromRGB(112, 118, 125)
	},
	AdditionalSailPartNames = {
		PirateBrigade = {
			["Meshes/Blox Fruits Ship3_Plane.074"] = true
		}
	},
	RemovedPresentationParts = {
		MarineGrandBrigade = {
			MarineDecal = true
		}
	},
	VerticalOffsets = {
		Default = 0,
		["Grand Brigade"] = -15
	},
	FinaleSails = {
		HeightScale = 0.6,
		MinimumRaise = 9,
		HeightRaiseFactor = 0.55
	}
})
local v = {}
local v2 = {}

function v.isLookoutDecoration(p)
	return p.Name == "LookoutFlag" or p.Name == "LookoutFlagPole"
end

function v.isSailPart(p, p2)
	local additionalSailPartName = frozen.AdditionalSailPartNames[p.Name]
	return p2.Name == "Sail" or p2.Name == "Sails" or additionalSailPartName and additionalSailPartName[p2.Name] == true
end

function v.compactFinaleSails(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant.Name == "Plane.037" or string.match(descendant.Name, "Plane%.037$") then
			descendant:Destroy()
		end
	end

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and v.isSailPart(folder, part)) then
			continue
		end

		local size = part.Size
		local v3 = { part.CFrame.RightVector, part.CFrame.UpVector, part.CFrame.LookVector }
		local v4 = { size.X, size.Y, size.Z }
		local v5 = 1

		for i = 2, 3 do
			if not (math.abs((v3[i]:Dot(createVector(0, 1, 0)))) > math.abs((v3[v5]:Dot(createVector(0, 1, 0))))) then
				continue
			end

			v5 = i
		end

		local v6 = v4[v5]
		v4[v5] *= frozen.FinaleSails.HeightScale
		part.Size = Vector3.new(v4[1], v4[2], v4[3])
		local v7 = math.max(frozen.FinaleSails.MinimumRaise, v6 * frozen.FinaleSails.HeightRaiseFactor)
		part.CFrame += createVector(0, 1, 0) * v7
	end
end

function v.isHullPart(p, p2)
	if v.isSailPart(p, p2) or v.isLookoutDecoration(p2) then
		return false
	end

	if p2.Name == "BoatBottom" or p2.Name == "Engine" or p2.Name == "CustomDecal" or string.find(
		p2.Name,
		"Cannon",
		1,
		true
	) or string.find(p2.Name, "Steering", 1, true) then
		return false
	end

	local HSV, v3, v4 = p2.Color:ToHSV()
	return v4 >= 0.2 and v4 <= 0.9 and v3 >= 0.12 and (HSV <= 0.16 or HSV >= 0.96)
end

function v.recolorHull(folder, p: string)
	local hullColor = frozen.HullColors[p]

	if not hullColor then
		return false
	end

	local HSV, v3 = hullColor:ToHSV()
	local v4 = false

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and v.isHullPart(folder, part)) then
			continue
		end

		local _, _, v5 = part.Color:ToHSV()
		part.Color = Color3.fromHSV(HSV, v3, v5)
		v4 = true
	end

	return v4
end

function v.prepareBoat(instance, callback, p: string?, p2: string?)
	local clone = instance:Clone()
	local primaryPart = clone.PrimaryPart
	local removedPresentationPart = frozen.RemovedPresentationParts[instance.Name]

	if not primaryPart or not primaryPart:IsA("BasePart") or primaryPart.Name ~= "BoatBottom" then
		clone:Destroy()
		return nil, (`{instance.Name} has no BoatBottom PrimaryPart`)
	end

	local vehicleSeat = clone:FindFirstChild("VehicleSeat", true)

	if vehicleSeat and vehicleSeat:IsA("VehicleSeat") then
		clone:SetAttribute(frozen.DriverSeatOffsetAttribute, primaryPart.CFrame:ToObjectSpace(vehicleSeat.CFrame))
	end

	for _, descendant in clone:GetDescendants() do
		if not (descendant:IsA("Seat") or descendant:IsA("VehicleSeat") or descendant.Name == "CustomDecal" or removedPresentationPart and removedPresentationPart[descendant.Name]) then
			continue
		end

		descendant:Destroy()
	end

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
			descendant:Destroy()
		end
	end

	if callback then
		callback(clone)
	end

	if p and p2 and not v.recolorHull(clone, p2) then
		clone:Destroy()
		return nil, (`{instance.Name} has no valid {p2} hull presentation`)
	end

	local v3 = {}

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		if part.Transparency < 1 then
			part.Transparency = 0
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.AssemblyLinearVelocity = createVector(0, 0, 0)
		part.AssemblyAngularVelocity = createVector(0, 0, 0)

		if part == primaryPart then
			part.Anchored = true
		else
			part.Anchored = false
			part.Massless = true
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Name = "LookoutScenicWeld"
			weldConstraint.Part0 = primaryPart
			weldConstraint.Part1 = part
			weldConstraint.Parent = part
			v3[part] = weldConstraint
		end
	end

	local count = 0

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("Seat") or descendant:IsA("VehicleSeat") then
			clone:Destroy()
			return nil, (`{instance.Name} retained a seat after preparation`)
		end

		if not descendant:IsA("BasePart") then
			continue
		end

		if descendant.Anchored then
			count += 1
		end

		if descendant == primaryPart then
			continue
		end

		local v4 = v3[descendant]

		if not (descendant.Anchored or not v4 or v4.Part0 ~= primaryPart or v4.Part1 ~= descendant) then
			continue
		end

		clone:Destroy()
		return nil, (`{instance.Name} failed its direct-weld assembly invariant`)
	end

	if count == 1 and primaryPart.Anchored then
		return clone, nil
	end

	clone:Destroy()
	return nil, (`{instance.Name} must have exactly one anchored part`)
end

function v.recolorSails(folder, p: string)
	local sailColor = frozen.SailColors[p]

	if not sailColor then
		return false
	end

	local v3 = false

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and v.isSailPart(folder, part)) then
			continue
		end

		part.Color = sailColor
		v3 = true
	end

	return v3
end

function v.enableBoatCollisions(folder)
	local primaryPart = folder.PrimaryPart

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local sailPart = v.isSailPart(folder, part)
		local v3

		if part == primaryPart then
			v3 = false
		else
			v3 = not sailPart and not v.isLookoutDecoration(part) and part.Transparency < 1
		end

		part.CanCollide = v3
		part.CanQuery = v3
		part.CanTouch = false
	end
end

function v2.enableCollisions(p)
	v.enableBoatCollisions(p)
end

function v2.resolveCache()
	local boatDisplayCache = ReplicatedStorage:FindFirstChild("BoatDisplayCache") or ReplicatedStorage:WaitForChild(
		"BoatDisplayCache",
		5
	)

	if boatDisplayCache and boatDisplayCache:IsA("Folder") then
		return boatDisplayCache, nil
	end

	return nil, "ReplicatedStorage.BoatDisplayCache is unavailable"
end

function v2.validateEntry(data, flag: boolean)
	if typeof(data) == "table" and typeof(data.Boat) == "string" and frozen.Templates[data.Boat] ~= nil and (not flag or data.Lane == frozen.Lanes[data.Boat]) and (not flag or typeof(data.LaneSlot) == "number" and data.LaneSlot % 1 == 0 and data.LaneSlot >= 1 and data.LaneSlot <= 3) and typeof(data.SailColor) == "string" and typeof(frozen.SailColors[data.SailColor]) == "Color3" and typeof(data.FlagColor) == "string" and typeof(frozen.SailColors[data.FlagColor]) == "Color3" and typeof(data.HullColor) == "string" then
		return typeof(frozen.HullColors[data.HullColor]) == "Color3"
	else
		return false
	end
end

function v2.getLane(p: string)
	return frozen.Lanes[p]
end

function v2.getVerticalOffset(p: string)
	return frozen.VerticalOffsets[p] or frozen.VerticalOffsets.Default
end

function v2.getDriverSeatOffset(instance)
	local attribute = instance:GetAttribute(frozen.DriverSeatOffsetAttribute)

	if typeof(attribute) == "CFrame" then
		return attribute
	end

	return nil
end

function v2.cloneNamedFromCache(instance, childName: string, p: string, p2: string, p3: string?, p4: string?)
	local model = instance:FindFirstChild(childName)

	if not (model and model:IsA("Model")) then
		return nil, (`BoatDisplayCache.{childName} is unavailable`)
	end

	local v3

	if p2 == "Finale" then
		v3 = v.compactFinaleSails
	end

	local v4, v5 = v.prepareBoat(model, v3, p3, p4)

	if not v4 then
		return nil, v5
	end

	if not v.recolorSails(v4, p) then
		v4:Destroy()
		return nil, (`{childName} has no valid {p} sail presentation`)
	end

	if p2 == "Finale" then
		v.enableBoatCollisions(v4)
	end

	return v4, nil
end

function v2.cloneFromCache(p, data, p2: string)
	local template = frozen.Templates[data.Boat]

	if template then
		return v2.cloneNamedFromCache(p, template, data.SailColor, p2, data.FlagColor, data.HullColor)
	end

	return nil, (`unsupported boat type {tostring(data.Boat)}`)
end

return table.freeze(v2)