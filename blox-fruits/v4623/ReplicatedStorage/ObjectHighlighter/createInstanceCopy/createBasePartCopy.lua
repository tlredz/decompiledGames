return function(part)
	assert(part:IsA("BasePart"), "createBasePartCopy must only receive a basePart!")

	if part:IsA("MeshPart") or part:IsA("UnionOperation") then
	end

	local clone = part:Clone()

	for _, descendant in pairs(clone:GetDescendants()) do
		if not (descendant:IsA("DataModelMesh") or descendant:IsA("Decal")) then
			descendant:Destroy()
		end
	end

	if part.CollisionGroupId == 0 then
		clone.Name ..= math.random(1, 9999999)
	end

	return clone
end