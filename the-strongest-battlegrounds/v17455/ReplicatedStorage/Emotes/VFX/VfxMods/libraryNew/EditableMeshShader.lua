local AssetService = game:GetService("AssetService")
local RunService = game:GetService("RunService")
local EditableMeshShader = {}
EditableMeshShader.__index = EditableMeshShader

function EditableMeshShader.new(mesh, callback, callback2, p)
	local object = setmetatable({}, EditableMeshShader)
	object.Mesh = mesh
	object.FixedTime = 0
	object.Time = 0
	object._alive = true
	task.spawn(function()
		local success, result = pcall(function()
			return AssetService:CreateEditableMeshAsync(mesh.MeshContent)
		end)

		if not (success and result) then
			warn("EditableMesh failed:", result)
			return
		end

		if not object._alive then
			result:Destroy()
			return
		end

		object.EditableMesh = result
		mesh:ApplyMesh((AssetService:CreateMeshPartAsync(Content.fromObject(result))))
		local vertices = result:GetVertices()
		local uVs = result:GetUVs()
		local count = #vertices
		local count2 = #uVs
		local positions = table.create(count)
		local lastPositions = table.create(count)

		for i = 1, count do
			local position = result:GetPosition(vertices[i])
			positions[i] = position
			lastPositions[i] = position
		end

		local UVs = table.create(count2)
		local lastUVs = table.create(count2)

		for i = 1, count2 do
			local UV = result:GetUV(uVs[i])
			UVs[i] = UV
			lastUVs[i] = UV
		end

		object._vertexIds = vertices
		object._uvIds = uVs
		object._originalPositions = positions
		object._lastPositions = lastPositions
		object._originalUVs = UVs
		object._lastUVs = lastUVs
		local total = 0
		object.Update = RunService.Heartbeat:Connect(function(dt)
			object.FixedTime += dt
			object.Time = p and object.Time + dt * p.Value or object.FixedTime
			total += dt

			if total < 0.03333333333333333 then
				return
			end

			local v4 = total
			total = 0
			local time = object.Time
			local fixedTime = object.FixedTime
			local setPosition = result.SetPosition
			local setUV = result.SetUV

			for i = 1, count do
				local v5 = callback(positions[i], time, v4, fixedTime)
				local v6 = lastPositions[i]
				local v7 = v5.X - v6.X
				local v8 = v5.Y - v6.Y
				local v9 = v5.Z - v6.Z

				if not (v7 * v7 + v8 * v8 + v9 * v9 > 1e-6) then
					continue
				end

				setPosition(result, vertices[i], v5)
				lastPositions[i] = v5
			end

			for i = 1, count2 do
				local v5 = callback2(UVs[i], time, v4, fixedTime)
				local v6 = lastUVs[i]
				local v7 = v5.X - v6.X
				local v8 = v5.Y - v6.Y

				if not (v7 * v7 + v8 * v8 > 1e-8) then
					continue
				end

				setUV(result, uVs[i], v5)
				lastUVs[i] = v5
			end
		end)
	end)
	return object
end

function EditableMeshShader:Destroy()
	self._alive = false

	if self.Update then
		self.Update:Disconnect()
		self.Update = nil
	end

	if self.EditableMesh then
		self.EditableMesh:Destroy()
		self.EditableMesh = nil
	end
end

return EditableMeshShader