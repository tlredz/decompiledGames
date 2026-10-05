local AssetService = game:GetService("AssetService")
local EditableMeshProvider = require(game.ReplicatedStorage.Util.EditableMeshProvider)

-- equivalent calls inferred from this helper; original call sites unknown
local function colorKey(color: Color3)
	return string.format("%.5f,%.5f,%.5f", color.R, color.G, color.B)
end

local function getColorId(object, p, color: Color3)
	local v = colorKey(color) -- equivalent call inferred; original call site unknown
	local v2 = p[v]

	if v2 then
		return v2
	end

	local v3 = object:AddColor(color, 1)
	p[v] = v3
	return v3
end

local function getPrimitiveGeometry(instance)
	local vectors = {}
	local result = {}

	if instance:IsA("Part") then
		if instance.Shape == Enum.PartType.Block then
			local v = instance.Size * 0.5
			return {
				Vector3.new(-v.X, -v.Y, -v.Z),
				Vector3.new(v.X, -v.Y, -v.Z),
				Vector3.new(v.X, v.Y, -v.Z),
				Vector3.new(-v.X, v.Y, -v.Z),
				Vector3.new(-v.X, -v.Y, v.Z),
				Vector3.new(v.X, -v.Y, v.Z),
				Vector3.new(v.X, v.Y, v.Z),
				(Vector3.new(-v.X, v.Y, v.Z))
			}, {
				{ 5, 6, 7 },
				{ 5, 7, 8 },
				{ 2, 1, 4 },
				{ 2, 4, 3 },
				{ 1, 5, 8 },
				{ 1, 8, 4 },
				{ 6, 2, 3 },
				{ 6, 3, 7 },
				{ 1, 2, 6 },
				{ 1, 6, 5 },
				{ 4, 8, 7 },
				{ 4, 7, 3 }
			}
		end

		if instance.Shape ~= Enum.PartType.Cylinder then
			return vectors, result
		end

		local v = math.min(instance.Size.X, instance.Size.Z) * 0.5
		local v2 = instance.Size.Y * 0.5
		table.insert(vectors, (Vector3.new(0, -v2, 0)))
		table.insert(vectors, (Vector3.new(0, v2, 0)))

		for i = 0, 15 do
			local v3 = i / 16 * 3.141592653589793 * 2
			table.insert(vectors, (Vector3.new(math.cos(v3) * v, -v2, math.sin(v3) * v)))
		end

		for i = 0, 15 do
			local v3 = i / 16 * 3.141592653589793 * 2
			table.insert(vectors, (Vector3.new(math.cos(v3) * v, v2, math.sin(v3) * v)))
		end

		for i = 0, 15 do
			local v3 = (i + 1) % 16
			table.insert(result, { 1, v3 + 3, i + 3 })
			table.insert(result, { 2, i + 19, v3 + 19 })
			table.insert(result, { i + 3, i + 19, v3 + 19 })
			table.insert(result, { i + 3, v3 + 19, v3 + 3 })
		end

		return vectors, result
	else
		if instance:IsA("WedgePart") then
			local v = instance.Size * 0.5
			vectors = {
				Vector3.new(-v.X, -v.Y, v.Z),
				Vector3.new(v.X, -v.Y, v.Z),
				Vector3.new(v.X, v.Y, v.Z),
				Vector3.new(-v.X, v.Y, v.Z),
				Vector3.new(-v.X, -v.Y, -v.Z),
				(Vector3.new(v.X, -v.Y, -v.Z))
			}
			result = {
				{ 1, 2, 3 },
				{ 1, 3, 4 },
				{ 1, 5, 6 },
				{ 1, 6, 2 },
				{ 1, 4, 5 },
				{ 2, 6, 3 },
				{ 5, 3, 6 },
				{ 5, 4, 3 }
			}
		end

		return vectors, result
	end
end

return {
	BuildEditableMeshFromParts = function(list)
		local editable = EditableMeshProvider.GetEditableFromMesh()
		local v = 0
		local v2 = {}
		local v3 = {}

		for _, part in ipairs(list) do
			if not (part:IsA("MeshPart") and part.MeshId ~= "") then
				continue
			end

			v += 1
			local v4 = part
			task.spawn(function()
				local success, result = pcall(function()
					return AssetService:CreateEditableMeshAsync(v4.MeshContent, {
						FixedSize = true
					})
				end)

				if success and result then
					v2[v4] = result
				end

				v -= 1
			end)
		end

		while v > 0 do
			task.wait()
		end

		for _, instance in ipairs(list) do
			if not (instance:IsA("Part") or instance:IsA("WedgePart")) then
				continue
			end

			local primitiveGeometry, v4 = getPrimitiveGeometry(instance)

			if not primitiveGeometry then
				continue
			end

			local v5 = {}
			local color = instance.Color
			local v6 = colorKey(color) -- equivalent call inferred; original call site unknown

			if not v3[v6] then
				v3[v6] = editable:AddColor(color, 1)
			end

			for i, v7 in ipairs(primitiveGeometry) do
				v5[i] = editable:AddVertex(instance.CFrame:PointToWorldSpace(v7))
			end

			for _, v7 in ipairs(v4) do
				editable:AddTriangle(v5[v7[1]], v5[v7[2]], v5[v7[3]])
			end
		end

		for k, v4 in pairs(v2) do
			local v5 = {}
			local color = k.Color
			local v6 = colorKey(color) -- equivalent call inferred; original call site unknown

			if not v3[v6] then
				v3[v6] = editable:AddColor(color, 1)
			end

			for _, v7 in ipairs(v4:GetVertices()) do
				local position = v4:GetPosition(v7)
				v5[v7] = editable:AddVertex((k.CFrame:PointToWorldSpace(position)))
			end

			for _, v7 in ipairs(v4:GetFaces()) do
				local faceVertices = v4:GetFaceVertices(v7)

				if #faceVertices == 3 then
					editable:AddTriangle(v5[faceVertices[1]], v5[faceVertices[2]], v5[faceVertices[3]])
				end
			end
		end

		for _, v4 in pairs(v2) do
			v4:Destroy()
		end

		editable:RemoveUnused()
		return EditableMeshProvider:ConvertEditableToMeshPart(editable)
	end
}