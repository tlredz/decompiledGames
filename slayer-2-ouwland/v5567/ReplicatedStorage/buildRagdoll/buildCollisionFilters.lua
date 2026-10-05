local getLastWordFromPascalCase = require(script.Parent:WaitForChild("getLastWordFromPascalCase"))
local v = {
	Hand = "Arm",
	Foot = "Leg"
}

function getLimbType(p)
	local lastWordFromPascalCase = getLastWordFromPascalCase(p)
	return v[lastWordFromPascalCase] or lastWordFromPascalCase
end

function getLimbs(p, p2)
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local parsePart

	parsePart = function(instance, p3)
		if instance.Name ~= "HumanoidRootPart" then
			local limbType = getLimbType(instance.Name)
			v2[limbType] = v2[limbType] or {}
			table.insert(v2[limbType], instance)
			local _ = v2[limbType]

			if limbType ~= p3 then
				v4[limbType] = v4[limbType] or {}

				if p3 then
					v4[limbType][p3] = true
				end

				table.insert(v3, {
					Part = instance,
					Type = limbType
				})
				p3 = limbType
			end
		end

		for _, child in pairs(instance:GetChildren()) do
			if not (child:isA("Attachment") and p2[child.Name]) then
				continue
			end

			local parent = p2[child.Name].Attachment1.Parent

			if parent and parent ~= instance then
				parsePart(parent, p3)
			end
		end
	end

	parsePart(p)
	return v2, v3, v4
end

function createNoCollision(part, part2)
	local noCollisionConstraint = Instance.new("NoCollisionConstraint")
	noCollisionConstraint.Name = part.Name .. "<->" .. part2.Name
	noCollisionConstraint.Part0 = part
	noCollisionConstraint.Part1 = part2
	return noCollisionConstraint
end

return function(p, p2)
	local folder = Instance.new("Folder")
	folder.Name = "NoCollisionConstraints"
	local limbs, v2, v3 = getLimbs(p2, p)

	for i = 1, #v2 do
		for i2 = i + 1, #v2 do
			local type = v2[i].Type
			local type2 = v2[i2].Type

			if v3[type][type2] or v3[type2][type] then
				continue
			end

			local noCollision = createNoCollision(v2[i].Part, v2[i2].Part)
			noCollision.Parent = folder
		end
	end

	for k, limb in pairs(limbs) do
		for k2, _ in pairs(v3[k]) do
			for _, v4 in pairs(limbs[k2]) do
				for _, v5 in pairs(limb) do
					local noCollision_2 = createNoCollision(v5, v4)
					noCollision_2.Parent = folder
				end
			end
		end
	end

	return folder
end