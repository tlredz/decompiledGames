local createVector = vector.create
local RunService = game:GetService("RunService")

if RunService:IsServer() and not workspace:FindFirstChild("CutParts") then
	local model_2 = Instance.new("Model", workspace)
	model_2.Name = "CutParts"
end

local AssetService = game:GetService("AssetService")
game:GetService("Workspace")
local CapBuilder = require(script.CapBuilder)
local v = {}

local function distToPlane(p, p2, vector2)
	return vector2:Dot(p - p2)
end

local function triArea(p, p2, p3)
	return 0.5 * (p2 - p):Cross(p3 - p).Magnitude
end

-- equivalent calls inferred from this helper; original call sites unknown
local function colorKey(data)
	return string.format("%.5f,%.5f,%.5f", data.R, data.G, data.B)
end

local function computeCentroidAndVertices(object)
	local vertices = object:GetVertices()
	local positions = {}
	local count = #vertices

	if count == 0 then
		return createVector(0, 0, 0), vertices
	end

	local v2 = createVector(0, 0, 0)

	for _, v3 in ipairs(vertices) do
		positions[v3] = object:GetPosition(v3)
		v2 += positions[v3]
	end

	return v2 / count, positions
end

local function makeStepper(p)
	local lastTime = os.clock()
	return function()
		if p <= os.clock() - lastTime then
			task.wait()
			lastTime = os.clock()
		end
	end
end

function GetParent(model)
	local parent = model.Parent

	if not parent or parent == workspace then
		return nil
	end

	if parent:IsA("Model") then
		local _, v2 = parent:GetBoundingBox()

		if math.max(v2.X, v2.Y, v2.Z) > 200 or math.min(v2.X, v2.Y, v2.Z) < 10 then
			if model:IsA("Model") then
				return model
			end
		else
			return GetParent(model.Parent)
		end
	elseif parent:IsA("BasePart") then
		return GetParent(parent)
	end

	return nil
end

function GetModelFromParts(items, p)
	local v2 = {}
	local folders = {}

	for _, item in pairs(items) do
		if v2[item] then
			continue
		end

		if (item.Name == "Left" or item.Name == "Right") and p and item.Parent and item.Parent.Name == "CutModel" and item.Parent:GetAttribute("OwnedPlayer") == p.Name then
			return item
		end

		local folder = GetParent(item)

		if not folder then
			continue
		end

		table.insert(folders, folder)

		for _, descendant in pairs(folder:GetDescendants()) do
			v2[descendant] = true
		end
	end

	return folders[1]
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.CutParts }

local function cut(cframe: CFrame, editableMesh, value: number?, p)
	local lastTime = os.clock()
	local v2 = 0.001388888888888889

	local function fn()
		if v2 <= os.clock() - lastTime then
			task.wait()
			lastTime = os.clock()
		end
	end

	if typeof(editableMesh) == "CFrame" then
		local v3 = editableMesh
		local v4 = (cframe - cframe.Position + v3.Position) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local count = 0

		while typeof(editableMesh) ~= "Instance" do
			count += 1

			if count > 50 then
				return
			end

			local v5 = v4 * CFrame.Angles(count // 2 * 0.008726646259971648 * (count % 2 == 0 and -1 or 1), 0, 0)
			local raycastResult = workspace:Raycast(v3.Position, v5.LookVector * 1000, raycastParams)

			if raycastResult then
				editableMesh = GetModelFromParts({ raycastResult.Instance }, p)
			end
		end
	end

	assert(editableMesh)

	if not editableMesh then
		error("CutMesh: no MeshPart found")
	end

	local model = Instance.new("Model", workspace)
	task.spawn(function()
		local sourceMesh

		if editableMesh:IsA("EditableMesh") then
			local EditableMeshProvider = require(game.ReplicatedStorage.Util.EditableMeshProvider)
			local v4
			v4, sourceMesh = EditableMeshProvider:ConvertEditableToMeshPart(editableMesh)
			editableMesh = v4
		else
			sourceMesh = v[editableMesh] or AssetService:CreateEditableMeshAsync(editableMesh.MeshContent, {
				FixedSize = true
			})
		end

		local EditableMeshProvider = require(game.ReplicatedStorage.Util.EditableMeshProvider)
		local editable = EditableMeshProvider.GetEditableFromMesh()
		local EditableMeshProvider2 = require(game.ReplicatedStorage.Util.EditableMeshProvider)
		local editable2 = EditableMeshProvider2.GetEditableFromMesh()
		os.clock()
		local cFrame = editableMesh.CFrame
		local v4 = cFrame:Inverse() * cframe
		local position = v4.Position
		local unit = v4.LookVector.Unit
		local v5 = (value or 0) * 0.5 + 1e-6
		local faces = sourceMesh:GetFaces()
		local positions = {}

		local function getPos(p2)
			local v6 = positions[p2]

			if v6 then
				return v6
			end

			local position2 = sourceMesh:GetPosition(p2)
			positions[p2] = position2
			return position2
		end

		local v6 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function recordRawCutVertex(pos, color)
			v6[#v6 + 1] = {
				pos = pos,
				color = color
			}
			return #v6
		end

		local colorsByFaceVertice = {}
		local v7 = {}
		local cutSegments = {}

		for _, face in ipairs(faces) do
			local faceVertices = sourceMesh:GetFaceVertices(face)
			local faceColors = sourceMesh:GetFaceColors(face)

			if not (faceVertices and faceColors and #faceVertices == #faceColors) then
				continue
			end

			for i = 1, #faceVertices do
				local faceVertice = faceVertices[i]

				if colorsByFaceVertice[faceVertice] then
					continue
				end

				local faceColor = faceColors[i]

				if faceColor then
					colorsByFaceVertice[faceVertice] = sourceMesh:GetColor(faceColor)
				end
			end
		end

		local v9 = {}
		local v10 = {}
		local v11 = {}
		local v12 = {}
		local v13 = {}
		local v14 = {}
		local v15 = {}
		local v16 = {}

		local function getLeftColorId(data)
			local v17 = colorKey(data) -- equivalent call inferred; original call site unknown
			local v18 = v13[v17]

			if v18 then
				return v18
			end

			local v19 = editable:AddColor(data, 1)
			v13[v17] = v19
			return v19
		end

		local function getRightColorId(data)
			local v17 = colorKey(data) -- equivalent call inferred; original call site unknown
			local v18 = v14[v17]

			if v18 then
				return v18
			end

			local v19 = editable2:AddColor(data, 1)
			v14[v17] = v19
			return v19
		end

		local function ensureLeftSrc(p2)
			if v9[p2] then
				return v9[p2]
			end

			local position2 = positions[p2]

			if not position2 then
				position2 = sourceMesh:GetPosition(p2)
				positions[p2] = position2
			end

			local v17 = editable:AddVertex(position2)
			v9[p2] = v17
			local v18 = colorsByFaceVertice[p2]

			if not v18 then
				return v17
			end

			local v19 = v15
			local v20 = colorKey(v18) -- equivalent call inferred; original call site unknown
			local v21 = v13[v20]

			if not v21 then
				v21 = editable:AddColor(v18, 1)
				v13[v20] = v21
			end

			v19[v17] = v21
			return v17
		end

		local function ensureRightSrc(p2)
			if v10[p2] then
				return v10[p2]
			end

			local position2 = positions[p2]

			if not position2 then
				position2 = sourceMesh:GetPosition(p2)
				positions[p2] = position2
			end

			local v17 = editable2:AddVertex(position2)
			v10[p2] = v17
			local v18 = colorsByFaceVertice[p2]

			if not v18 then
				return v17
			end

			local v19 = v16
			local v20 = colorKey(v18) -- equivalent call inferred; original call site unknown
			local v21 = v14[v20]

			if not v21 then
				v21 = editable2:AddColor(v18, 1)
				v14[v20] = v21
			end

			v19[v17] = v21
			return v17
		end

		local function ensureLeftCut(p2, p3, data)
			if v11[p2] then
				return v11[p2]
			end

			local v17 = editable:AddVertex(p3)
			v11[p2] = v17

			if not data then
				return v17
			end

			local v18 = v15
			local v19 = colorKey(data) -- equivalent call inferred; original call site unknown
			local v20 = v13[v19]

			if not v20 then
				v20 = editable:AddColor(data, 1)
				v13[v19] = v20
			end

			v18[v17] = v20
			return v17
		end

		local function ensureRightCut(p2, p3, data)
			if v12[p2] then
				return v12[p2]
			end

			local v17 = editable2:AddVertex(p3)
			v12[p2] = v17

			if not data then
				return v17
			end

			local v18 = v16
			local v19 = colorKey(data) -- equivalent call inferred; original call site unknown
			local v20 = v14[v19]

			if not v20 then
				v20 = editable2:AddColor(data, 1)
				v14[v19] = v20
			end

			v18[v17] = v20
			return v17
		end

		for _, face in ipairs(faces) do
			fn()
			local faceVertices = sourceMesh:GetFaceVertices(face)

			if #faceVertices < 3 then
				continue
			end

			local v17 = false
			local v18 = false

			for _, faceVertice in ipairs(faceVertices) do
				local v19 = v7[faceVertice]

				if not v19 then
					local position2 = positions[faceVertice]

					if not position2 then
						position2 = sourceMesh:GetPosition(faceVertice)
						positions[faceVertice] = position2
					end

					v19 = unit:Dot(position2 - position)
					v7[faceVertice] = v19
				end

				v17 = v5 < v19 or v17

				if v19 < -v5 then
					v18 = true
				end
			end

			if v17 and v18 then
				local v19 = {}

				for i = 1, #faceVertices do
					fn()
					local faceVertice = faceVertices[i]
					local faceVertice2 = faceVertices[i % #faceVertices + 1]
					local v20 = v7[faceVertice]
					local v21 = v7[faceVertice2]

					if not (v5 < v20 and v21 < -v5 or v20 < -v5 and v5 < v21) then
						continue
					end

					local position2 = positions[faceVertice]

					if not position2 then
						position2 = sourceMesh:GetPosition(faceVertice)
						positions[faceVertice] = position2
					end

					local position3 = positions[faceVertice2]

					if not position3 then
						position3 = sourceMesh:GetPosition(faceVertice2)
						positions[faceVertice2] = position3
					end

					local v22 = v20 - v21

					if not (math.abs(v22) > 1e-6) then
						continue
					end

					local v23 = v20 / v22
					local pos = position2 + (position3 - position2) * v23
					local v25 = colorsByFaceVertice[faceVertice]
					local v26 = colorsByFaceVertice[faceVertice2] or v25
					local v27

					if v25 then
						v27 = Color3.new(
							v25.R + (v26.R - v25.R) * v23,
							v25.G + (v26.G - v25.G) * v23,
							v25.B + (v26.B - v25.B) * v23
						)
					end

					table.insert(v19, recordRawCutVertex(pos, v27))
				end

				if #v19 == 2 then
					local pos = v6[v19[1]].pos
					local pos2 = v6[v19[2]].pos
					table.insert(cutSegments, {
						A = cFrame:PointToWorldSpace(pos),
						B = cFrame:PointToWorldSpace(pos2)
					})
				end
			end

			local v19 = {}

			for i = 1, #faceVertices do
				fn()
				local faceVertice = faceVertices[i]
				local faceVertice2 = faceVertices[i % #faceVertices + 1]
				local v20 = v7[faceVertice]
				local v21 = v7[faceVertice2]
				local position2 = positions[faceVertice]

				if not position2 then
					position2 = sourceMesh:GetPosition(faceVertice)
					positions[faceVertice] = position2
				end

				local position3 = positions[faceVertice2]

				if not position3 then
					position3 = sourceMesh:GetPosition(faceVertice2)
					positions[faceVertice2] = position3
				end

				local v22 = v20 <= v5
				local v23 = v21 <= v5

				if v22 then
					table.insert(v19, {
						src = faceVertice,
						pos = position2
					})
				end

				if not (v22 and not v23 or not v22 and v23) then
					continue
				end

				local v24 = v20 - v21

				if not (math.abs(v24) > 1e-6) then
					continue
				end

				local v25 = v20 / v24
				table.insert(v19, {
					src = 0,
					pos = position2 + (position3 - position2) * v25
				})
			end

			if #v19 >= 3 then
				for i = 2, #v19 - 1 do
					local v20 = { v19[1], v19[i], v19[i + 1] }
					local v21 = {}

					for _, v22 in ipairs(v20) do
						if v22.src == 0 then
							local v23 = 1e999
							local v24 = 1

							for i2, v25 in ipairs(v6) do
								local magnitude = (v25.pos - v22.pos).Magnitude

								if not (magnitude < v23) then
									continue
								end

								v24 = i2
								v23 = magnitude
							end

							local v25 = v6[v24]
							local pos = v25.pos
							local color = v25.color
							local v26

							if v11[v24] then
								v26 = v11[v24]
							else
								v26 = editable:AddVertex(pos)
								v11[v24] = v26

								if color then
									local v27 = colorKey(color) -- equivalent call inferred; original call site unknown
									local v28 = v13[v27]

									if not v28 then
										v28 = editable:AddColor(color, 1)
										v13[v27] = v28
									end

									v15[v26] = v28
								end
							end

							table.insert(v21, v26)
						else
							local src = v22.src
							local v23

							if v9[src] then
								v23 = v9[src]
							else
								local position2 = positions[src]

								if not position2 then
									position2 = sourceMesh:GetPosition(src)
									positions[src] = position2
								end

								v23 = editable:AddVertex(position2)
								v9[src] = v23
								local v24 = colorsByFaceVertice[src]

								if v24 then
									local v25 = colorKey(v24) -- equivalent call inferred; original call site unknown
									local v26 = v13[v25]

									if not v26 then
										v26 = editable:AddColor(v24, 1)
										v13[v25] = v26
									end

									v15[v23] = v26
								end
							end

							table.insert(v21, v23)
						end
					end

					editable:SetFaceColors(
						editable:AddTriangle(v21[1], v21[2], v21[3]),
						{ v15[v21[1]], v15[v21[2]], v15[v21[3]] }
					)
				end
			end

			local v20 = {}

			for i = 1, #faceVertices do
				fn()
				local faceVertice = faceVertices[i]
				local faceVertice2 = faceVertices[i % #faceVertices + 1]
				local v21 = v7[faceVertice]
				local v22 = v7[faceVertice2]
				local position2 = positions[faceVertice]

				if not position2 then
					position2 = sourceMesh:GetPosition(faceVertice)
					positions[faceVertice] = position2
				end

				local position3 = positions[faceVertice2]

				if not position3 then
					position3 = sourceMesh:GetPosition(faceVertice2)
					positions[faceVertice2] = position3
				end

				local v23 = -v5 <= v21
				local v24 = -v5 <= v22

				if v23 then
					table.insert(v20, {
						src = faceVertice,
						pos = position2
					})
				end

				if not (v23 and not v24 or not v23 and v24) then
					continue
				end

				local v25 = v21 - v22

				if not (math.abs(v25) > 1e-6) then
					continue
				end

				local v26 = v21 / v25
				table.insert(v20, {
					src = 0,
					pos = position2 + (position3 - position2) * v26
				})
			end

			if not (#v20 >= 3) then
				continue
			end

			fn()

			for i = 2, #v20 - 1 do
				local v21 = { v20[1], v20[i], v20[i + 1] }
				local v22 = {}

				for _, v23 in ipairs(v21) do
					if v23.src == 0 then
						local v24 = 1e999
						local v25 = 1

						for i2, v26 in ipairs(v6) do
							local magnitude = (v26.pos - v23.pos).Magnitude

							if not (magnitude < v24) then
								continue
							end

							v25 = i2
							v24 = magnitude
						end

						local v26 = v6[v25]
						local pos = v26.pos
						local color = v26.color
						local v27

						if v12[v25] then
							v27 = v12[v25]
						else
							v27 = editable2:AddVertex(pos)
							v12[v25] = v27

							if color then
								local v28 = colorKey(color) -- equivalent call inferred; original call site unknown
								local v29 = v14[v28]

								if not v29 then
									v29 = editable2:AddColor(color, 1)
									v14[v28] = v29
								end

								v16[v27] = v29
							end
						end

						table.insert(v22, v27)
					else
						local src = v23.src
						local v24

						if v10[src] then
							v24 = v10[src]
						else
							local position2 = positions[src]

							if not position2 then
								position2 = sourceMesh:GetPosition(src)
								positions[src] = position2
							end

							v24 = editable2:AddVertex(position2)
							v10[src] = v24
							local v25 = colorsByFaceVertice[src]

							if v25 then
								local v26 = colorKey(v25) -- equivalent call inferred; original call site unknown
								local v27 = v14[v26]

								if not v27 then
									v27 = editable2:AddColor(v25, 1)
									v14[v26] = v27
								end

								v16[v24] = v27
							end
						end

						table.insert(v22, v24)
					end
				end

				editable2:SetFaceColors(
					editable2:AddTriangle(v22[1], v22[2], v22[3]),
					{ v16[v22[1]], v16[v22[2]], v16[v22[3]] }
				)
			end
		end

		if #cutSegments > 0 then
			CapBuilder.BuildCapsFromSegments({
				cutSegments = cutSegments,
				planeCFrame = cframe,
				meshLeft = editable,
				meshRight = editable2,
				dominantColor = Color3.new(0, 0, 0),
				meshToWorld = cFrame,
				sourceMesh = sourceMesh
			})
		end

		editable:RemoveUnused()
		editable2:RemoveUnused()

		if editableMesh.TextureID == "" then
			local _ = editableMesh:FindFirstChildOfClass("SurfaceAppearance") == nil
		end

		local success, _ = pcall(function()
			local EditableMeshProvider3 = require(game.ReplicatedStorage.Util.EditableMeshProvider)
			local convertEditableToMeshPart = EditableMeshProvider3:ConvertEditableToMeshPart(editable2)
			convertEditableToMeshPart.Anchored = editableMesh.Anchored
			convertEditableToMeshPart.Color = editableMesh.Color
			convertEditableToMeshPart.Material = editableMesh.Material
			convertEditableToMeshPart.CFrame = editableMesh.CFrame
			convertEditableToMeshPart.Parent = model
			v[convertEditableToMeshPart] = editable2
			convertEditableToMeshPart.Destroying:Once(function()
				v[convertEditableToMeshPart] = nil
			end)
		end)

		if not success then
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "Right"
			boolValue.Parent = model
		end

		local success2, _ = pcall(function()
			local EditableMeshProvider3 = require(game.ReplicatedStorage.Util.EditableMeshProvider)
			local convertEditableToMeshPart = EditableMeshProvider3:ConvertEditableToMeshPart(editable)
			convertEditableToMeshPart.Anchored = editableMesh.Anchored
			convertEditableToMeshPart.Color = editableMesh.Color
			convertEditableToMeshPart.Material = editableMesh.Material
			convertEditableToMeshPart.CFrame = editableMesh.CFrame
			convertEditableToMeshPart.Parent = model
			v[convertEditableToMeshPart] = editable
			convertEditableToMeshPart.Destroying:Once(function()
				v[convertEditableToMeshPart] = nil
			end)
		end)

		if not success2 then
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "Left"
			boolValue.Parent = model
		end

		sourceMesh:Destroy()
	end)
	model.Parent = workspace.CutParts
	return model
end

return cut