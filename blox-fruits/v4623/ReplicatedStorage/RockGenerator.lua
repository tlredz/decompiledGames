local createVector = vector.create
local v = {}
local v2 = {}
local RunService = game:GetService("RunService")

if RunService:IsServer() then
	local v3 = {}
	local v4 = {
		__index = {
			Destroy = function(self, p2)
				if rawget(self, "Destroyed") then
					return
				end

				self.Destroyed = true
				local id = self.id

				if not p2 then
					script.RemoteEvent:FireAllClients("RemoveZone", id)
				end

				v3[id] = nil
			end
		}
	}

	script.RemoteFunction.OnServerInvoke = function(_)
		return v3
	end

	return {
		ExcludeSphere = function(p, p2, duration)
			local id = 0 + 1
			script.RemoteEvent:FireAllClients("ExcludeSphere", id, p, p2, duration, os.clock())
			local object = setmetatable({
				id = id
			}, v4)

			if duration then
				task.delay(duration, function()
					object:Destroy(true)
				end)
			end

			v3[id] = {
				1,
				id,
				p,
				p2,
				duration,
				os.clock()
			}
			return object
		end,
		ExcludeRegion = function(p, p2, duration)
			local id = 0 + 1
			script.RemoteEvent:FireAllClients("ExcludeRegion", id, p, p2, duration, os.clock())
			local object = setmetatable({
				id = id
			}, v4)

			if duration then
				task.delay(duration, function()
					object:Destroy(true)
				end)
			end

			v3[id] = {
				2,
				id,
				p,
				p2,
				duration,
				os.clock()
			}
			return object
		end
	}
else
	script:WaitForChild("RemoteEvent").OnClientEvent:Connect(function(p, p2, p3, p4, p5, p6)
		if p == "RemoveZone" then
			if v[p2] then
				v2[p2] = v[p2]
				v[p2] = nil
			end
		else
			local v3

			if p == "ExcludeRegion" then
				v3 = ExcludeRegion(p3, p4, false, p2)
			else
				v3 = ExcludeSphere(p3, p4, false, p2)
			end

			if p5 then
				task.delay(p5 - (os.clock() - p6), function()
					v3:Destroy()
				end)
			end
		end
	end)
	local v3 = script:WaitForChild("RemoteFunction"):InvokeServer()

	for _, v4 in pairs(v3) do
		local v5

		if v4[1] == 2 then
			v5 = ExcludeRegion(v4[3], v4[4], false, v4[2])
		else
			v5 = ExcludeSphere(v4[3], v4[4], false, v4[2])
		end

		if not v4[5] then
			continue
		end

		local v6 = v5
		task.delay(v4[5] - (os.clock() - v4[6]), function()
			v6:Destroy()
		end)
	end

	local folder = Instance.new("Folder", workspace)
	folder.Name = "Rocks"

	function generateSeed(p, p2, p3)
		local v4 = tostring(p) .. tostring(p2) .. tostring(p3)
		local v5 = 0

		for i = 1, #v4 do
			local v6 = string.byte(v4, i)
			v5 = (v5 * 31 + v6) % 4294967296
		end

		return v5
	end

	function generateRandom(p, p2, p3)
		local v4 = generateSeed(p, p2, p3)
		return Random.new(v4):NextNumber()
	end

	function getDangerDistance(p)
		local DangerDistance = require(game.ReplicatedStorage.DangerDistance)
		return DangerDistance(p)
	end

	local partsByMeshId = {}
	local v4 = {}

	function getRockFromCache(p)
		local v5 = v4[p]

		if v5 and v5[1] then
			local v6 = v5[1]
			table.remove(v5, 1)
			return v6
		else
			local clone = partsByMeshId[p]:Clone()
			clone.Parent = folder
			return clone
		end
	end

	function returnRockToCache(p)
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.Transparency = 1
		p.CFrame = CFrame.new()
		v4[p.MeshId] = v4[p.MeshId] or {}
		table.insert(v4[p.MeshId], p)
	end

	local v5 = {}

	for _, child in pairs(script.Rocks:GetChildren()) do
		local v6 = {}
		v5[child.Name] = v6
		local part = child:FindFirstChild("Part")

		if part then
			local boundingBox, v7 = child:GetBoundingBox()
			table.insert(v6, v7.Y / 2 + boundingBox.Position.Y - part.Position.Y)

			for _, part2 in pairs(child:GetChildren()) do
				if not part2:IsA("MeshPart") then
					continue
				end

				table.insert(v6, {
					part2.MeshId,
					part.CFrame:ToObjectSpace(part2.CFrame),
					part2.Color,
					part2.Size
				})

				if not partsByMeshId[part2.MeshId] then
					partsByMeshId[part2.MeshId] = part2
				end
			end
		else
			warn("Unable to initialize prop: " .. child.Name .. " because it lacks a primarypart.")
		end
	end

	function CreateProp(p, p2)
		local v6 = v5[p]

		if not v6 then
			warn("Unable to create prop: " .. p .. " because it was never initialized.")
			return
		end

		local result = {
			{},
			{}
		}

		for i = 1, 1 do
			for k, v7 in pairs(v6) do
				if k == 1 then
					if i == 1 then
						table.insert(result, v7)
					end
				else
					local rockFromCache = getRockFromCache(v7[1])

					if rockFromCache then
						rockFromCache.CFrame = p2 * v7[2]
						rockFromCache.Color = v7[3]
						rockFromCache.Size = v7[4]
						rockFromCache.CastShadow = false

						if i == 1 then
							rockFromCache.CanCollide = false
							rockFromCache.CanTouch = false
							rockFromCache.CanQuery = false
							rockFromCache.Transparency = 0
							rockFromCache:SetAttribute("CfOffset", rockFromCache.CFrame)
						else
							rockFromCache.CanCollide = true
							rockFromCache.CanTouch = false
							rockFromCache.CanQuery = true
							rockFromCache.Transparency = 0
							rockFromCache:SetAttribute("CfOffset", v7[2])
						end

						table.insert(result[i], rockFromCache)
					end
				end
			end
		end

		return result
	end

	function DestroyProp(items)
		for k, item in pairs(items) do
			if k == 3 then
				continue
			end

			for _, v6 in pairs(item) do
				returnRockToCache(v6)
			end
		end
	end

	local v6 = #script.Tiles.Small:GetChildren()
	local v7 = {}

	for i, child in pairs(script.Tiles.Small:GetChildren()) do
		local part = child:FindFirstChild("Part")

		if not part then
			continue
		end

		local v8 = {}

		for _, child2 in pairs(child:GetChildren()) do
			if child2 ~= part then
				table.insert(v8, { child2.Name, child2.Part.CFrame:ToObjectSpace(part.CFrame) })
			end
		end

		table.insert(v7, { i / v6, v8 })
	end

	local v8 = #script.Tiles.Medium:GetChildren()
	local v9 = {}

	for i, child in pairs(script.Tiles.Medium:GetChildren()) do
		local part = child:FindFirstChild("Part")

		if not part then
			continue
		end

		local v10 = {}

		for _, child2 in pairs(child:GetChildren()) do
			if child2 ~= part then
				table.insert(v10, { child2.Name, child2.Part.CFrame:ToObjectSpace(part.CFrame) })
			end
		end

		table.insert(v9, { i / v8, v10 })
	end

	function CreateTile(p, p2)
		local dangerDistance = getDangerDistance((Vector3.new(p, 0, p2)))

		if dangerDistance < -1200 then
			return {}
		end

		local v10 = v7

		if dangerDistance > 3200 then
			v10 = v9
		end

		local v11 = generateRandom(p, p2, 8832)
		local v12 = nil

		for _, v14 in ipairs(v10) do
			if not (v11 <= v14[1]) then
				continue
			end

			v12 = v14
			break
		end

		if not v12 then
			print("no new tile")
			return {}
		end

		local v14 = generateRandom(p, p2, 15253)
		local v15 = CFrame.new(p, 0, p2) * CFrame.Angles(0, math.rad(math.floor(v14 / 0.25 + 0.5) * 90), 0)
		local result = { false }

		for _, v16 in pairs(v12[2]) do
			table.insert(result, {
				v16[1],
				v15 * v16[2],
				false,
				{
					c = 0,
					d = 0
				}
			})
		end

		return result
	end

	function DeleteTile(items)
		for k, item in pairs(items) do
			if k > 1 and item[3] then
				DestroyProp(item[3])
			end
		end
	end

	function sphereToCircle(data, p)
		if p < math.abs(data.Y) then
			return
		else
			return Vector2.new(data.X, data.Z), (math.abs(p * p - data.Y * data.Y))
		end
	end

	local v10 = 10000000

	function LocationAdded(instance)
		local mesh = instance:WaitForChild("Mesh")
		local v11 = instance.Size.Y * mesh.Scale.Y / 2
		local position = instance.Position
		local v12, v13 = sphereToCircle(position, v11)

		if not v12 then
			return
		end

		local v14 = v10
		v10 += 1
		v[v14] = { v13, v12 }
		v2[v14] = v[v14]
		local ancestryChangedConnection = nil
		ancestryChangedConnection = instance.AncestryChanged:Connect(function()
			if not instance.Parent then
				v2[v14] = v[v14]
				v[v14] = nil
				ancestryChangedConnection:Disconnect()
			end
		end)
	end

	local v11 = {
		__index = {
			Destroy = function(self)
				if rawget(self, "Destroyed") then
					return
				end

				self.Destroyed = true
				local id = self.id

				if self.vis then
					self.vis:Destroy()
				end

				v2[id] = v[id]
				v[id] = nil
			end
		}
	}

	function ExcludeSphere(p, p2, duration, id)
		local v12, v13 = sphereToCircle(p, p2)

		if not v12 then
			return {}
		end

		if not id then
			id = v10
			v10 += 1
		end

		v[id] = { v13, v12 }
		v2[id] = v[id]
		local object = setmetatable({
			id = id
		}, v11)

		if duration then
			task.delay(duration, function()
				object:Destroy()
			end)
		end

		return object
	end

	function ExcludeRegion(p, p2, duration, id)
		if not id then
			id = v10
			v10 += 1
		end

		v[id] = { false, p2, p }
		v2[id] = v[id]
		local object = setmetatable({
			id = id
		}, v11)

		if duration then
			task.delay(duration, function()
				object:Destroy()
			end)
		end

		return object
	end

	for _, child in pairs(workspace:WaitForChild("_WorldOrigin"):WaitForChild("Locations"):GetChildren()) do
		LocationAdded(child)
	end

	workspace._WorldOrigin.Locations.ChildAdded:Connect(LocationAdded)
	task.spawn(function()
		local boundingBox, v12 = workspace:WaitForChild("Map"):WaitForChild("Submerged Island"):GetBoundingBox()
		local cframe = CFrame.new(boundingBox.Position.X, 0, boundingBox.Position.Z)
		local vector2 = Vector3.new(v12.X + 5200, 20000, v12.Z + 5200)
		ExcludeRegion(cframe, vector2, false)
	end)

	function boxIntersectsSquare(p, p2, list)
		local v12 = list[2]
		local v13 = list[3]
		local v14 = v12 / 2
		local v15 = {
			v13 * Vector3.new(v14.X, 0, v14.Z),
			v13 * Vector3.new(-v14.X, 0, v14.Z),
			v13 * Vector3.new(-v14.X, 0, -v14.Z),
			v13 * Vector3.new(v14.X, 0, -v14.Z)
		}
		local v16 = 1e999
		local v17 = -1e999
		local v18 = 1e999
		local v19 = -1e999

		for _, v20 in pairs(v15) do
			v16 = math.min(v16, v20.X)
			v17 = math.max(v17, v20.X)
			v18 = math.min(v18, v20.Z)
			v19 = math.max(v19, v20.Z)
		end

		local v20 = p - 1150
		local v21 = p + 1150
		local v22 = p2 - 1150
		local v23 = p2 + 1150
		return v20 <= v17 and v16 <= v21 and v22 <= v19 and v18 <= v23
	end

	function boxContainsPoint(p, list)
		local v12 = list[2]
		local v13 = list[3]:Inverse() * p
		local v14 = v12 / 2
		local v15 = math.abs(v13.X) <= v14.X
		local v16 = math.abs(v13.Y) <= v14.Y
		local v17 = math.abs(v13.Z) <= v14.Z
		return v15 and v16 and v17
	end

	function circleIntersectsSquare(p, p2, list)
		local v12 = p - 1150
		local v13 = p + 1150
		local v14 = p2 + 1150
		local v15 = p2 - 1150
		local v16 = math.max(v12, (math.min(list[2].X, v13)))
		local v17 = math.max(v15, (math.min(list[2].Y, v14)))
		local v18 = list[2].X - v16
		local v19 = list[2].Y - v17
		return v18 ^ 2 + v19 ^ 2 <= list[1]
	end

	function UpdateTiles(items, p)
		for k, item in pairs(items) do
			for k2, v12 in pairs(item) do
				local v13 = {}
				local v14 = not v12[1]
				local v15 = v12
				local v17 = k
				local v18 = k2

				local function c(items2)
					for k3, item2 in pairs(items2) do
						if not (not v15[1][k3] or v2[k3] and not (v[k3] and v14)) then
							continue
						end

						if v[k3] and not v15[1][k3] then
							v15[1][k3] = true

							if item2[1] and circleIntersectsSquare(v17, v18, item2) or not item2[1] and boxIntersectsSquare(
								v17,
								v18,
								item2
							) then
								v13[k3] = item2
							end
						elseif v15[1][k3] then
							v15[1][k3] = nil
							v13[k3] = item2
						end
					end
				end

				if v14 then
					v12[1] = {}
					c(v)
				end

				c(v2)

				for k3, v20 in pairs(v12) do
					if k3 == 1 then
						continue
					end

					if v20[4] and v20[4].e == nil then
						if getDangerDistance(v20[2].Position) < 500 then
							v20[4].e = true
							continue
						else
							v20[4].e = false
						end
					elseif v20[4] and v20[4].e then
						continue
					end

					local v21 = math.min(
						(math.max((p.X - v20[2].Position.X) ^ 2 + (p.Y - v20[2].Position.Z) ^ 2, 4000000) - 4000000) / 2760000,
						1
					)
					local v22 = game.Players.LocalPlayer:GetAttribute("IslandRaiding") and 1 or v21

					for k4, v23 in pairs(v13) do
						if v12[1][k4] and v20[4][k4] == nil then
							if v23[1] then
								if (v20[2].Position.X - v23[2].X) ^ 2 + (v20[2].Position.Z - v23[2].Y) ^ 2 <= v23[1] then
									v20[4][k4] = true
									v20[4].c += 1

									if not v2[k4] then
										v20[4].d = 1
									end
								end
							elseif boxContainsPoint(v20[2].Position, v23) then
								v20[4][k4] = true
								v20[4].c += 1

								if not v2[k4] then
									v20[4].d = 1
								end
							end
						elseif not v12[1][k4] and v20[4][k4] then
							v20[4][k4] = nil
							v20[4].c -= 1
						end
					end

					if v20[4].c >= 1 then
						if v20[4].d < 1 then
							v20[4].d = math.min(v20[4].d + 0.03333333333333333, 1)
						end

						v22 = math.max(v22, v20[4].d)
					else
						if v20[4].d > 0 then
							v20[4].d = math.max(v20[4].d - 0.03333333333333333, 0)
						end

						if v20[4].d > 0 then
							v22 = math.max(v22, v20[4].d)
						end
					end

					if v22 < 1 then
						local v23 = not (v22 > 0)

						if not v20[3] then
							v20[3] = CreateProp(v20[1], v20[2])
						end

						local v24 = v20[3][3] * v22

						if v20[3][4] == v24 then
							v20[3][4] = v24
						else
							for _, v25 in pairs(v20[3][1]) do
								v25.CFrame = v25:GetAttribute("CfOffset") - createVector(0, 1, 0) * v24
								v25.CanCollide = v23
								v25.CanTouch = v23
							end
						end
					elseif v20[3] then
						DestroyProp(v20[3])
						v20[3] = nil
					end
				end
			end
		end

		v2 = {}
	end

	task.spawn(function()
		local v12 = 0
		local v13 = {}

		while true do
			if workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations") then
				v12 += task.wait()
				local position = workspace.CurrentCamera.CFrame.Position
				local vector2 = Vector2.new(position.X, position.Z)

				if v12 >= 0.1 then
					v12 -= 0.1
					local vector3 = Vector2.new(
						math.floor(vector2.X / 2300) * 2300 + 1150,
						math.floor(vector2.Y / 2300) * 2300 + 1150
					)
					local vector4 = Vector2.new(vector2.X - vector3.X, vector2.Y - vector3.Y)
					local v14 = {}
					local v15

					if vector4.X > 725 then
						v15 = { vector3.X - 2300, vector3.X + 4600 }
					elseif vector4.X < -725 then
						v15 = { vector3.X - 4600, vector3.X + 2300 }
					else
						v15 = { vector3.X - 2300, vector3.X + 2300 }
					end

					local v16

					if vector4.Y > 725 then
						v16 = { vector3.Y - 2300, vector3.Y + 4600 }
					elseif vector4.Y < -725 then
						v16 = { vector3.Y - 4600, vector3.Y + 2300 }
					else
						v16 = { vector3.Y - 2300, vector3.Y + 2300 }
					end

					for i = v15[1], v15[2], 2300 do
						for i2 = v16[1], v16[2], 2300 do
							if not ((vector2.X - i) ^ 2 + (vector2.Y - i2) ^ 2 <= 17800000) then
								continue
							end

							v14[i] = v14[i] or {}
							v14[i][i2] = true
						end
					end

					for k, v17 in pairs(v13) do
						for k2, v18 in pairs(v17) do
							if v14[k] and v14[k][k2] then
								v14[k][k2] = v18
							else
								DeleteTile(v18)
							end
						end
					end

					for k, v17 in pairs(v14) do
						for k2, v18 in pairs(v17) do
							if v18 == true then
								v14[k][k2] = CreateTile(k, k2)
							end
						end
					end

					UpdateTiles(v14, vector2)
					v13 = v14
				else
					UpdateTiles(v13, vector2)
				end
			else
				task.wait()
			end
		end
	end)
	return {
		ExcludeSphere = ExcludeSphere,
		ExcludeRegion = ExcludeRegion
	}
end