local createVector = vector.create
return {
	[2506127037] = function(object)
		local v = {}
		local v2 = {}

		for i = 0, 24 do
			v[i] = {}
			v2[i] = {}
			local v3 = 1.5707963267948966 * (i / 24)
			local v4 = math.sin(v3) * 1 - 0.5
			local v5 = math.cos(v3) * 1

			for i2 = 0, 35 do
				local v6 = 6.283185307179586 * i2 / 36
				local v7 = object:AddVertex((Vector3.new(v5 * math.cos(v6), v4, v5 * math.sin(v6))))
				table.insert(v[i], v7)
			end
		end

		for i = 0, 23 do
			for i2 = 0, 35 do
				local v3 = (i2 + 1) % 36
				local v4 = v[i][i2 + 1]
				local v5 = v[i][v3 + 1]
				local v6 = v[i + 1][i2 + 1]
				local v7 = v[i + 1][v3 + 1]
				object:AddTriangle(v4, v6, v5)
				object:AddTriangle(v5, v6, v7)
			end
		end

		local v3 = object:AddVertex(createVector(0, -0.5, 0))

		for i = 0, 35 do
			object:AddTriangle(v3, v[0][i + 1], v[0][(i + 1) % 36 + 1])
		end
	end,
	[14945731824] = function(object)
		local v = {}
		local v2 = {}

		for i = 0, 35 do
			local v3 = 6.283185307179586 * i / 36
			local v4 = math.cos(v3) * 0.5
			local v5 = math.sin(v3) * 0.5
			local v6 = object:AddVertex((Vector3.new(v4, v5, 0.5)))
			local v7 = object:AddVertex((Vector3.new(v4, v5, -0.5)))
			table.insert(v, v6)
			table.insert(v2, v7)
		end

		local v3 = object:AddVertex(createVector(0, 0, 0.5))
		local v4 = object:AddVertex(createVector(0, 0, -0.5))

		for i = 1, 36 do
			local v5 = i % 36 + 1
			object:AddTriangle(v3, v[i], v[v5])
			object:AddTriangle(v4, v2[v5], v2[i])
		end

		for i = 1, 36 do
			local v5 = i % 36 + 1
			object:AddTriangle(v[i], v2[i], v2[v5])
			object:AddTriangle(v[i], v2[v5], v[v5])
		end
	end,
	[134653856420428] = function(object)
		local v = {}
		local v2 = {}

		for i = 0, 35 do
			local v3 = 3.141592653589793 * i / 35
			local v4 = math.cos(v3) * 0.5
			local v5 = math.sin(v3) * 0.5 - 0.25
			local v6 = object:AddVertex((Vector3.new(v4, v5, 0.5)))
			local v7 = object:AddVertex((Vector3.new(v4, v5, -0.5)))
			table.insert(v, v6)
			table.insert(v2, v7)
		end

		local v3 = object:AddVertex(createVector(0, -0.25, 0.5))
		local v4 = object:AddVertex(createVector(0, -0.25, -0.5))

		for i = 1, 35 do
			object:AddTriangle(v3, v[i], v[i + 1])
			object:AddTriangle(v4, v2[i + 1], v2[i])
		end

		for i = 1, 35 do
			object:AddTriangle(v[i], v2[i], v2[i + 1])
			object:AddTriangle(v[i], v2[i + 1], v[i + 1])
		end

		object:AddTriangle(v3, v2[1], v[1])
		object:AddTriangle(v3, v4, v2[1])
		object:AddTriangle(v3, v[36], v2[36])
		object:AddTriangle(v3, v2[36], v4)
	end,
	[135384238901086] = function(object)
		local v = {}
		local v2 = {}

		for i = 0, 35 do
			local v3 = 1.5707963267948966 * i / 35
			local v4 = math.cos(v3) * 0.5
			local v5 = math.sin(v3) * 0.5 - 0.25
			local v6 = object:AddVertex((Vector3.new(v4, v5, 0.5)))
			local v7 = object:AddVertex((Vector3.new(v4, v5, -0.5)))
			table.insert(v, v6)
			table.insert(v2, v7)
		end

		local v3 = object:AddVertex(createVector(0, -0.25, 0.5))
		local v4 = object:AddVertex(createVector(0, -0.25, -0.5))

		for i = 1, 35 do
			object:AddTriangle(v3, v[i], v[i + 1])
			object:AddTriangle(v4, v2[i + 1], v2[i])
		end

		for i = 1, 35 do
			object:AddTriangle(v[i], v2[i], v2[i + 1])
			object:AddTriangle(v[i], v2[i + 1], v[i + 1])
		end

		object:AddTriangle(v3, v2[1], v[1])
		object:AddTriangle(v3, v4, v2[1])
		object:AddTriangle(v3, v[36], v2[36])
		object:AddTriangle(v3, v2[36], v4)
	end,
	[137287050553068] = function(object)
		local v = {}
		local v2 = {}

		for i = 0, 47 do
			local v3 = 6.283185307179586 * i / 48
			local v4 = math.cos(v3) * 0.25
			local v5 = math.sin(v3) * 0.25
			local v6 = object:AddVertex((Vector3.new(v4, v5, 0.5)))
			local v7 = object:AddVertex((Vector3.new(v4, v5, -0.5)))
			table.insert(v, v6)
			table.insert(v2, v7)
		end

		local v3 = {}
		local v4 = {}

		for i = 0, 47 do
			local v5 = 6.283185307179586 * i / 48
			local v6 = math.cos(v5)
			local v7 = math.sin(v5)
			local v8 = math.min(
				v6 == 0 and 1e999 or 0.5 / math.abs(v6) or 1e999,
				v7 == 0 and 1e999 or 0.5 / math.abs(v7) or 1e999
			)
			local v9 = v8 * v6
			local v10 = v8 * v7
			local v11 = object:AddVertex((Vector3.new(v9, v10, 0.5)))
			local v12 = object:AddVertex((Vector3.new(v9, v10, -0.5)))
			table.insert(v3, v11)
			table.insert(v4, v12)
		end

		for i = 1, 48 do
			local v5 = i % 48 + 1
			object:AddTriangle(v[i], v2[v5], v2[i])
			object:AddTriangle(v[i], v[v5], v2[v5])
		end

		for i = 1, 48 do
			local v5 = i % 48 + 1
			object:AddTriangle(v[i], v3[i], v[v5])
			object:AddTriangle(v3[i], v3[v5], v[v5])
		end

		for i = 1, 48 do
			local v5 = i % 48 + 1
			object:AddTriangle(v2[i], v2[v5], v4[i])
			object:AddTriangle(v4[i], v2[v5], v4[v5])
		end

		for i = 1, 48 do
			local v5 = i % 48 + 1
			local v6 = v3[i]
			local v7 = v3[v5]
			local v8 = v4[i]
			local v9 = v4[v5]
			object:AddTriangle(v6, v8, v9)
			object:AddTriangle(v6, v9, v7)
		end
	end,
	[104528104155128] = function(object)
		local function CreateFaceWithHole(vector2: Vector3, vector3: Vector3, vector4: Vector3, flag: boolean)
			local result = {}
			local v = {}

			for i = 0, 47 do
				local v2 = 6.283185307179586 * i / 48
				local v3 = math.cos(v2)
				local v4 = math.sin(v2)
				local v5 = vector2 * (v3 * 0.25) + vector3 * (v4 * 0.25)
				table.insert(result, object:AddVertex(vector4 + v5))
				local v6 = math.min(
					v3 == 0 and 1e999 or 0.5 / math.abs(v3) or 1e999,
					v4 == 0 and 1e999 or 0.5 / math.abs(v4) or 1e999
				)
				local v7 = vector2 * (v6 * v3) + vector3 * (v6 * v4)
				table.insert(v, object:AddVertex(vector4 + v7))
			end

			for i = 1, 48 do
				local v2 = i % 48 + 1

				if flag then
					object:AddTriangle(result[i], v[i], result[v2])
					object:AddTriangle(v[i], v[v2], result[v2])
				else
					object:AddTriangle(result[i], result[v2], v[i])
					object:AddTriangle(v[i], result[v2], v[v2])
				end
			end

			return result
		end

		local function CreateCylinderWalls(list, list2, vector2: Vector3, vector3: Vector3, vector4: Vector3)
			local v = {}
			local v2 = {}
			local v3 = {}
			local v4 = {}

			for i = 0, 47 do
				local v5 = 6.283185307179586 * i / 48
				local v6 = math.cos(v5)
				local v7 = math.sin(v5)
				local v8 = vector2 * (v6 * 0.25) + vector3 * (v7 * 0.25)
				local v9 = vector4 * 0.25
				table.insert(v, object:AddVertex(v9 + v8))
				local v10 = vector4 * -0.25
				table.insert(v2, object:AddVertex(v10 + v8))
				local v11 = math.min(
					v6 == 0 and 1e999 or 0.25 / math.abs(v6) or 1e999,
					v7 == 0 and 1e999 or 0.25 / math.abs(v7) or 1e999
				)
				local v12 = vector2 * (v11 * v6) + vector3 * (v11 * v7)
				table.insert(v3, object:AddVertex(v9 + v12))
				table.insert(v4, object:AddVertex(v10 + v12))
			end

			for i = 1, 48 do
				local v5 = i % 48 + 1
				object:AddTriangle(list[i], v[v5], v[i])
				object:AddTriangle(list[i], list[v5], v[v5])
			end

			for i = 1, 48 do
				local v5 = i % 48 + 1
				object:AddTriangle(list2[i], v2[i], v2[v5])
				object:AddTriangle(list2[i], v2[v5], list2[v5])
			end

			for i = 1, 48 do
				local v5 = i % 48 + 1
				object:AddTriangle(v[i], v[v5], v3[i])
				object:AddTriangle(v3[i], v[v5], v3[v5])
			end

			for i = 1, 48 do
				local v5 = i % 48 + 1
				object:AddTriangle(v2[i], v4[i], v2[v5])
				object:AddTriangle(v4[i], v4[v5], v2[v5])
			end
		end

		local faceWithHole = CreateFaceWithHole(
			createVector(1, 0, 0),
			createVector(0, 1, 0),
			createVector(0, 0, 0.5),
			true
		)
		local faceWithHole2 = CreateFaceWithHole(
			createVector(1, 0, 0),
			createVector(0, 1, 0),
			createVector(0, 0, -0.5),
			false
		)
		local faceWithHole3 = CreateFaceWithHole(
			createVector(0, 1, 0),
			createVector(0, 0, 1),
			createVector(0.5, 0, 0),
			true
		)
		local faceWithHole4 = CreateFaceWithHole(
			createVector(0, 1, 0),
			createVector(0, 0, 1),
			createVector(-0.5, 0, 0),
			false
		)
		local faceWithHole5 = CreateFaceWithHole(
			createVector(0, 0, 1),
			createVector(1, 0, 0),
			createVector(0, 0.5, 0),
			true
		)
		local faceWithHole6 = CreateFaceWithHole(
			createVector(0, 0, 1),
			createVector(1, 0, 0),
			createVector(0, -0.5, 0),
			false
		)
		CreateCylinderWalls(
			faceWithHole,
			faceWithHole2,
			createVector(1, 0, 0),
			createVector(0, 1, 0),
			createVector(0, 0, 1)
		)
		CreateCylinderWalls(
			faceWithHole3,
			faceWithHole4,
			createVector(0, 1, 0),
			createVector(0, 0, 1),
			createVector(1, 0, 0)
		)
		CreateCylinderWalls(
			faceWithHole5,
			faceWithHole6,
			createVector(0, 0, 1),
			createVector(1, 0, 0),
			createVector(0, 1, 0)
		)

		local function CreateCornerPocket(p: number, p2: number, p3: number)
			local vectors = {}

			for i = 0, 12 do
				local v7 = i / 12 * 3.141592653589793 / 2
				table.insert(vectors, (Vector3.new(p * 0.25 * math.cos(v7), p2 * 0.25 * math.sin(v7), p3 * 0.25)))
			end

			for i = 1, 12 do
				local v7 = i / 12 * 3.141592653589793 / 2
				table.insert(vectors, (Vector3.new(p * 0.25 * math.sin(v7), p2 * 0.25, p3 * 0.25 * math.cos(v7))))
			end

			for i = 1, 11 do
				local v7 = i / 12 * 3.141592653589793 / 2
				table.insert(vectors, (Vector3.new(p * 0.25, p2 * 0.25 * math.cos(v7), p3 * 0.25 * math.sin(v7))))
			end

			local v7 = createVector(0, 0, 0)

			for _, v8 in vectors do
				v7 += v8
			end

			local v9 = object:AddVertex(v7 / #vectors)
			local v10 = {}

			for _, v11 in vectors do
				table.insert(v10, object:AddVertex(v11))
			end

			local v11 = ((p < 0 and 1 or 0) + (p2 < 0 and 1 or 0) + (p3 < 0 and 1 or 0)) % 2 == 1
			local count = #v10

			for i = 1, count do
				local v12 = i % count + 1

				if v11 then
					object:AddTriangle(v9, v10[v12], v10[i])
				else
					object:AddTriangle(v9, v10[i], v10[v12])
				end
			end
		end

		CreateCornerPocket(1, 1, 1)
		CreateCornerPocket(-1, 1, 1)
		CreateCornerPocket(1, -1, 1)
		CreateCornerPocket(1, 1, -1)
		CreateCornerPocket(-1, -1, 1)
		CreateCornerPocket(-1, 1, -1)
		CreateCornerPocket(1, -1, -1)
		CreateCornerPocket(-1, -1, -1)
	end
}