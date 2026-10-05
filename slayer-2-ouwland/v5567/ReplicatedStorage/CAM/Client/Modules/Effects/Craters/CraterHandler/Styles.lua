local createVector = vector.create
local Modes = require(script.Parent:WaitForChild("Modes"))
game:GetService("TweenService")
game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Craters_Config = require(script.Parent.Parent.Craters_Config)
local craters = workspace:WaitForChild("Debree"):WaitForChild("Craters")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local random = Random.new()

local function fn(p, range, vector2)
	local v = -p.UpVector * range
	local raycastResult = workspace:Raycast(p.Position, v, vfxUtility.RayParams.Map)
	local instance, position, material

	if raycastResult then
		instance = raycastResult.Instance
		position = raycastResult.Position
		material = raycastResult.Material
		local _ = raycastResult.Normal
	else
		instance = false
	end

	if not instance then
		return
	end

	local v2 = {
		Anchored = true,
		CanCollide = false,
		Material = material,
		Size = vector2,
		Color = instance.Color,
		Reflectance = instance.Reflectance,
		Transparency = instance.Transparency
	}
	local cFrame

	if typeof(position) == "Vector3" then
		cFrame = CFrame.new(position)
	else
		cFrame = position
	end

	v2.CFrame = cFrame
	local result = Craters_Config.Get_Part()

	for k, v4 in next, v2, nil do
		if k ~= "Parent" or k ~= "ObjectName" then
			result[k] = v4
		end
	end

	for _, child in ipairs(result:GetChildren()) do
		child:Destroy()
	end

	for _, texture in ipairs(instance:GetChildren()) do
		if not texture:IsA("Texture") then
			continue
		end

		local clone = texture:Clone()
		clone.Parent = result
	end

	return result, position
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fn2(p, p2)
	return random:NextNumber(p, p2)
end

local function fn3(p, radius, partCount, _)
	local result = {}

	for i = 1, partCount + 1 do
		local v = i * (6.283185307179586 / partCount)
		result[i] = p * Vector3.new(math.cos(v) * radius, 0, math.sin(v) * radius)
	end

	return result
end

local Styles = {}

function Styles.Crater(p, data)
	local blockSize = data.BlockSize or { 2, 3.5 }
	local partCount = data.PartCount or 10
	local radius = data.Radius or 8
	local range = data.Range or 5
	local angle = data.Angle or { 45, 65 }
	local height = data.Height or { 0, 0 }
	local tilt = data.Tilt or { 0, 0 }
	local partOffset = data.PartOffset or { 0, 0 }
	local flourishTypes = data.FlourishTypes or {}
	local iterateSpeed = data.IterateSpeed or {}
	local circleComplete = data.CircleComplete or 1
	local v = fn3(p, radius, partCount)
	local v2 = {}
	local v3 = 1

	for i = 1, math.floor(#v * circleComplete + 0.5) do
		if v[i + 1] == nil then
			continue
		end

		local cframe = v[i]
		local magnitude = (cframe - v[i + 1]).Magnitude
		local v6 = fn2(blockSize[1], blockSize[2]) -- equivalent call inferred; original call site unknown
		local vector2 = Vector3.new(magnitude + 0.5, v6, v6)

		if typeof(cframe) == "Vector3" then
			cframe = CFrame.new(cframe)
		end

		local v8, _ = fn(cframe, range, vector2)

		if not v8 then
			continue
		end

		local v11 = CFrame.lookAt(v8.Position, (Vector3.new(p.X, v8.Position.Y, p.Z))) * CFrame.new(
			0,
			random:NextNumber(height[1], height[2]),
			fn2(partOffset[1], partOffset[2])
		)
		local v12 = angle[1]
		local v13 = angle[2]
		local v14 = math.rad((random:NextNumber(v12, v13)))
		local v15 = tilt[1]
		local v16 = tilt[2]
		local v17 = {
			CFrame = v11 * CFrame.fromEulerAnglesXYZ(v14, math.rad((random:NextNumber(v15, v16))), 0)
		}
		v8.CFrame = CFrame.lookAt(v8.Position, (Vector3.new(p.X, 0, p.Z)))
		v8.Parent = craters
		local v18 = v8
		task.spawn(function()
			v2[#v2 + 1] = v18
		end)
		Modes[flourishTypes.Entrance or "Enlarge"](v8, flourishTypes.EntranceSpeed or 0.3, v17)

		if not iterateSpeed.Entrance then
			continue
		end

		if iterateSpeed.EntranceDivision == "Iterate" then
			if iterateSpeed.Entrance == "Stepped" then
				task.wait()
			else
				task.wait(iterateSpeed.Entrance)
			end
		elseif math.floor((math.floor(#v * circleComplete + 0.5) - 1) * (v3 / (iterateSpeed.EntranceDivision or 3))) == i and i ~= math.floor(#v * circleComplete + 0.5) - 1 then
			if iterateSpeed.Entrance == "Stepped" then
				task.wait()
			else
				task.wait(iterateSpeed.Entrance)
			end

			v3 += 1
		end
	end

	task.wait(data.HoldTime or 5)
	local v4 = 1

	for i = 1, #v2 do
		Modes[flourishTypes.Exit or "Shrink"](v2[i], flourishTypes.ExitSpeed or 0.3)

		if iterateSpeed.Exit then
			if iterateSpeed.ExitDivision == "Iterate" then
				if iterateSpeed.Exit == "Stepped" then
					task.wait()
				else
					task.wait(iterateSpeed.Exit)
				end
			elseif math.floor(#v2 * (v4 / (iterateSpeed.ExitDivision or 2))) == i and i ~= #v2 then
				if iterateSpeed.Exit == "Stepped" then
					task.wait()
				else
					task.wait(iterateSpeed.Exit)
				end

				v4 += 1
			end
		end

		local v5 = i
		task.spawn(function()
			task.wait((flourishTypes.ExitSpeed or 0.3) + 0.15)

			if v2[v5] then
				Craters_Config.Delete_Part(v2[v5])
			end
		end)
	end
end

function Styles.ChunkCrater(p, data)
	local blockSize = data.BlockSize or { 2, 3.5 }
	local partCount = data.PartCount or 10
	local radius = data.Radius or 8
	local range = data.Range or 5
	local angle = data.Angle or { 45, 65 }
	local height = data.Height or { 0, 0 }
	local tilt = data.Tilt or { 0, 0 }
	local partOffset = data.PartOffset or { 0, 0 }
	local flourishTypes = data.FlourishTypes or {}
	local iterateSpeed = data.IterateSpeed or {}
	local circleComplete = data.CircleComplete or 1
	local v = fn3(p, radius, partCount)
	local v2 = {}
	local v3 = {}
	local v4 = 1

	for i = 1, math.floor(#v * circleComplete + 0.5) do
		if v[i + 1] == nil then
			continue
		end

		local cframe = v[i]
		local magnitude = (cframe - v[i + 1]).Magnitude
		local v7 = fn2(blockSize[1], blockSize[2]) -- equivalent call inferred; original call site unknown
		local vector2 = Vector3.new(magnitude + 0.5, v7, v7)

		if typeof(cframe) == "Vector3" then
			cframe = CFrame.new(cframe)
		end

		local v9, cframe2 = fn(cframe, range, Vector3.new(magnitude + 0.55, 0.5, v7 + 0.05))

		if not v9 then
			continue
		end

		local v10 = {
			Anchored = true,
			CanCollide = false,
			Material = Enum.Material.Slate,
			Size = vector2,
			Color = Color3.fromRGB(90, 76, 66)
		}

		if typeof(cframe2) == "Vector3" then
			cframe2 = CFrame.new(cframe2)
		end

		v10.CFrame = cframe2
		local get_Part = Craters_Config.Get_Part()

		for k, v11 in next, v10, nil do
			if k ~= "Parent" or k ~= "ObjectName" then
				get_Part[k] = v11
			end
		end

		get_Part.CFrame = CFrame.lookAt(get_Part.Position, (Vector3.new(p.X, 0, p.Z)))
		v9.CFrame = get_Part.CFrame
		v9.Parent = craters
		local v13 = CFrame.lookAt(get_Part.Position, (Vector3.new(p.X, 0, p.Z))) * CFrame.new(
			0,
			random:NextNumber(height[1], height[2]),
			fn2(partOffset[1], partOffset[2])
		)
		local v14 = angle[1]
		local v15 = angle[2]
		local v16 = math.rad((random:NextNumber(v14, v15)))
		local v17 = tilt[1]
		local v18 = tilt[2]
		local cFrame = v13 * CFrame.fromEulerAnglesXYZ(v16, math.rad((random:NextNumber(v17, v18))), 0)
		local v20 = v9
		task.spawn(function()
			v2[#v2 + 1] = v20
			v3[#v3 + 1] = get_Part
		end)
		Modes[flourishTypes.Entrance or "Enlarge"](get_Part, flourishTypes.EntranceSpeed or 0.3, {
			CFrame = cFrame
		})
		Modes[flourishTypes.Entrance or "Enlarge"](v9, flourishTypes.EntranceSpeed or 0.3, {
			CFrame = cFrame * CFrame.new(0, v7 / 2 + 0.15, 0)
		})

		if not iterateSpeed.Entrance then
			continue
		end

		if iterateSpeed.EntranceDivision == "Iterate" then
			if iterateSpeed.Entrance == "Stepped" then
				task.wait()
			else
				task.wait(iterateSpeed.Entrance)
			end
		elseif math.floor((math.floor(#v * circleComplete + 0.5) - 1) * (v4 / (iterateSpeed.EntranceDivision or 3))) == i and i ~= math.floor(#v * circleComplete + 0.5) - 1 then
			if iterateSpeed.Entrance == "Stepped" then
				task.wait()
			else
				task.wait(iterateSpeed.Entrance)
			end

			v4 += 1
		end
	end

	task.wait(data.HoldTime or 5)
	local v5 = 1

	for i = 1, #v2 do
		Modes[flourishTypes.Exit or "Shrink"](v2[i], flourishTypes.ExitSpeed or 0.3)
		Modes[flourishTypes.Exit or "Shrink"](v3[i], flourishTypes.ExitSpeed or 0.3)

		if iterateSpeed.Exit and math.floor(#v2 * (v5 / (iterateSpeed.ExitDivision or 2))) == i and i ~= #v2 then
			if iterateSpeed.Exit == "Stepped" then
				task.wait()
			else
				task.wait(iterateSpeed.Exit)
			end

			v5 += 1
		end

		local v6 = i
		task.spawn(function()
			task.wait((flourishTypes.ExitSpeed or 0.3) + 0.15)

			if v2[v6] then
				Craters_Config.Delete_Part(v2[v6])
			end

			if v3[v6] then
				Craters_Config.Delete_Part(v3[v6])
			end
		end)
	end
end

function Styles.Orbit(p, data)
	local blockSize = data.BlockSize or { 2, 3.5 }
	local partCount = data.PartCount or 10
	local radius = data.Radius or 8
	local range = data.Range or 5
	local angle = data.Angle or { 45, 65 }
	local height = data.Height or { 0, 0 }
	local tilt = data.Tilt or { 0, 0 }
	local partOffset = data.PartOffset or { 0, 0 }
	local flourishTypes = data.FlourishTypes or {}
	local iterateSpeed = data.IterateSpeed or {}
	local circleComplete = data.CircleComplete or 1
	local v = fn3(p, radius, partCount)
	local v2 = {}
	local v3 = 1

	for i = 1, math.floor(#v * circleComplete + 0.5) - 1 do
		local cframe = v[i]
		local v6 = fn2(blockSize[1], blockSize[2]) -- equivalent call inferred; original call site unknown

		if typeof(cframe) == "Vector3" then
			cframe = CFrame.new(cframe)
		end

		local v8, _ = fn(cframe, range, Vector3.new(v6, v6, v6))

		if not v8 then
			continue
		end

		local v11 = CFrame.lookAt(v8.Position, (Vector3.new(p.X, 0, p.Z))) * CFrame.new(
			0,
			random:NextNumber(height[1], height[2]),
			fn2(partOffset[1], partOffset[2])
		)
		local v12 = angle[1]
		local v13 = angle[2]
		local v14 = math.rad((random:NextNumber(v12, v13)))
		local v15 = tilt[1]
		local v16 = tilt[2]
		local v17 = {
			CFrame = v11 * CFrame.fromEulerAnglesXYZ(v14, math.rad((random:NextNumber(v15, v16))), 0)
		}
		v8.CFrame = CFrame.lookAt(v8.Position, (Vector3.new(p.X, 0, p.Z)))
		v8.Parent = craters
		local v18 = v8
		task.spawn(function()
			v2[#v2 + 1] = v18
		end)
		Modes[flourishTypes.Entrance or "Enlarge"](v8, flourishTypes.EntranceSpeed or 0.3, v17)

		if not iterateSpeed.Entrance then
			continue
		end

		if iterateSpeed.EntranceDivision == "Iterate" then
			if iterateSpeed.Entrance == "Stepped" then
				task.wait()
			else
				task.wait(iterateSpeed.Entrance)
			end
		elseif math.floor((math.floor(#v * circleComplete + 0.5) - 1) * (v3 / (iterateSpeed.EntranceDivision or 3))) == i and i ~= math.floor(#v * circleComplete + 0.5) - 1 then
			if iterateSpeed.Entrance == "Stepped" then
				task.wait()
			else
				task.wait(iterateSpeed.Entrance)
			end

			v3 += 1
		end
	end

	task.wait(data.HoldTime or 5)
	local v4 = 1

	for i = 1, #v2 do
		Modes[flourishTypes.Exit or "Shrink"](v2[i], flourishTypes.ExitSpeed or 0.3)

		if iterateSpeed.Exit then
			if iterateSpeed.ExitDivision == "Iterate" then
				if iterateSpeed.Exit == "Stepped" then
					task.wait()
				else
					task.wait(iterateSpeed.Exit)
				end
			elseif math.floor(#v2 * (v4 / (iterateSpeed.ExitDivision or 2))) == i and i ~= #v2 then
				if iterateSpeed.Exit == "Stepped" then
					task.wait()
				else
					task.wait(iterateSpeed.Exit)
				end

				v4 += 1
			end
		end

		local v5 = i
		task.spawn(function()
			task.wait((flourishTypes.ExitSpeed or 0.3) + 0.15)

			if v2[v5] then
				Craters_Config.Delete_Part(v2[v5])
			end
		end)
	end
end

function Styles.Path(p, data)
	local blockSize = data.BlockSize or { 1.5, 2 }
	local distance = data.Distance or 15
	local stepSize = data.StepSize or blockSize[1]
	local width = data.Width or { 1, 3 }
	local range = data.Range or 5
	local angle = data.Angle or { -1000, 1000 }
	local height = data.Height or { 0, 0 }
	local tilt = data.Tilt or { -1000, 1000 }
	local v = not data.RightCurve and 0 or -data.RightCurve or 0
	local leftCurve = data.LeftCurve or 0
	local rightOffset = data.RightOffset or 0
	local leftOffset = data.LeftOffset or 0
	local flourishTypes = data.FlourishTypes or {}
	local iterateSpeed = data.IterateSpeed or {}
	local v2 = p * CFrame.new(width[1], 0, 0)
	local v3 = p * CFrame.new(width[2], 0, -distance)
	local v4 = p * CFrame.new(-width[1], 0, 0)
	local v5 = p * CFrame.new(-width[2], 0, -distance)
	local midpoint = (v2.Position + v3.Position) / 2
	local midpoint2 = (v4.Position + v5.Position) / 2
	local v8 = {}
	local v9 = {}
	local v10 = 1

	for i = 0, distance, stepSize do
		local v11 = width[1]
		local v12 = width[2]
		local v13 = i / distance
		local _ = v11 + (v12 - v11) * v13
		local v14 = blockSize[1]
		local v15 = blockSize[2]
		local v16 = i / distance
		local v17 = v14 + (v15 - v14) * v16
		local v19 = i / distance
		local position = v2.Position
		local position2 = (CFrame.lookAt(midpoint, v2.Position) * CFrame.new(v, 0, rightOffset)).Position
		local position3 = v3.Position
		local cframe = (1 - v19) ^ 2 * position + 2 * (1 - v19) * v19 * position2 + v19 ^ 2 * position3

		if typeof(cframe) == "Vector3" then
			cframe = CFrame.new(cframe)
		end

		local v20 = fn(cframe, range, Vector3.new(v17, v17, v17))
		local v22 = i / distance
		local position4 = v4.Position
		local position5 = (CFrame.lookAt(midpoint2, v4.Position) * CFrame.new(leftCurve, 0, leftOffset)).Position
		local position6 = v5.Position
		local cframe2 = (1 - v22) ^ 2 * position4 + 2 * (1 - v22) * v22 * position5 + v22 ^ 2 * position6

		if typeof(cframe2) == "Vector3" then
			cframe2 = CFrame.new(cframe2)
		end

		local v23 = fn(cframe2, range, Vector3.new(v17, v17, v17))

		if v20 then
			local v26 = fn2(angle[1], angle[2]) -- equivalent call inferred; original call site unknown
			local v29 = fn2(tilt[1], tilt[2]) -- equivalent call inferred; original call site unknown
			local cFrame = v20.CFrame * CFrame.new(0, random:NextNumber(height[1], height[2]), 0) * CFrame.fromEulerAnglesXYZ(
				math.rad(v26),
				math.rad(v29),
				0
			)
			v20.Orientation = Vector3.new(math.rad(v26), math.rad(v29), 0)
			v20.Parent = craters
			Modes[flourishTypes.Entrance or "Enlarge"](v20, flourishTypes.EntranceSpeed or 0.3, {
				CFrame = cFrame
			})
		end

		if v23 then
			local v26 = fn2(angle[1], angle[2]) -- equivalent call inferred; original call site unknown
			local v29 = fn2(tilt[1], tilt[2]) -- equivalent call inferred; original call site unknown
			local cFrame = v23.CFrame * CFrame.new(0, random:NextNumber(height[1], height[2]), 0) * CFrame.fromEulerAnglesXYZ(
				math.rad(v26),
				math.rad(v29),
				0
			)
			v23.Orientation = Vector3.new(math.rad(v26), math.rad(v29), 0)
			v23.Parent = craters
			Modes[flourishTypes.Entrance or "Enlarge"](v23, flourishTypes.EntranceSpeed or 0.3, {
				CFrame = cFrame
			})
		end

		task.spawn(function()
			v8[#v8 + 1] = v20
			v9[#v9 + 1] = v23
		end)

		if not iterateSpeed.Entrance then
			continue
		end

		if iterateSpeed.EntranceDivision ~= "Iterate" and math.floor(distance * (v10 / (iterateSpeed.EntranceDivision or 3))) == i and i ~= distance - 1 then
			v10 += 1
		end

		task.wait(iterateSpeed.EntranceSpeed)
	end

	task.wait(data.HoldTime or 5)
	local v11 = 1

	for i = 1, #v8 do
		Modes[flourishTypes.Exit or "Shrink"](v8[i], flourishTypes.ExitSpeed or 0.3)
		Modes[flourishTypes.Exit or "Shrink"](v9[i], flourishTypes.ExitSpeed or 0.3)

		if iterateSpeed.Exit then
			if iterateSpeed.ExitDivision == "Iterate" then
				if iterateSpeed.Exit == "Stepped" then
					task.wait()
				else
					task.wait(iterateSpeed.Exit)
				end
			elseif math.floor(#v8 * (v11 / (iterateSpeed.ExitDivision or 2))) == i and i ~= #v8 then
				if iterateSpeed.Exit == "Stepped" then
					task.wait()
				else
					task.wait(iterateSpeed.Exit)
				end

				v11 += 1
			end
		end

		local v12 = i
		task.spawn(function()
			task.wait((flourishTypes.ExitSpeed or 0.3) + 0.15)

			if v8[v12] then
				Craters_Config.Delete_Part(v8[v12])
			end

			if v9[v12] then
				Craters_Config.Delete_Part(v9[v12])
			end
		end)
	end
end

function Styles.Break(p, data)
	local blockSize = data.BlockSize or { 0.25, 0.5 }
	local partCount = data.PartCount or 10
	local radius = data.Radius or 8
	local width = data.Width or { -8, 8 }
	local range = data.Range or 5
	local angle = data.Angle or { 45, 65 }
	local height = data.Height or { 0, 0 }
	local flourishTypes = data.FlourishTypes or {}
	local iterateSpeed = data.IterateSpeed or {}
	local v = {}
	local v2 = 1

	for i = 1, partCount do
		local v5 = fn2(blockSize[1], blockSize[2]) -- equivalent call inferred; original call site unknown
		local v6 = blockSize[1]
		local v7 = blockSize[2]
		local vector2 = Vector3.new(v5, random:NextNumber(v6, v7), fn2(blockSize[1], blockSize[2]))
		local v10, _ = fn(p * CFrame.new(random:NextNumber(-radius, radius), 0, fn2(-radius, radius)), range, vector2)

		if not v10 then
			continue
		end

		v10.CollisionGroup = "Blocks"
		v10.CFrame *= CFrame.new(0, v10.Size.Y / 2, 0)
		v10.Parent = craters
		v10.Anchored = false
		v10.CanCollide = true
		v[#v + 1] = v10
		Modes[flourishTypes.Entrance or "Enlarge"](v10, flourishTypes.EntranceSpeed or 0.3, {
			CFrame = v10.CFrame
		})
		local bodyVelocity = Instance.new("BodyVelocity", v10)
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.P = 100000
		local v13 = fn2(width[1], width[2]) -- equivalent call inferred; original call site unknown
		local v14 = height[1]
		local v15 = height[2]
		bodyVelocity.Velocity = Vector3.new(v13, random:NextNumber(v14, v15), fn2(width[1], width[2]))
		local bodyAngularVelocity = Instance.new("BodyAngularVelocity", v10)
		local v18 = fn2(-angle[1], angle[2]) -- equivalent call inferred; original call site unknown
		local v19 = -angle[1]
		local v20 = angle[2]
		bodyAngularVelocity.AngularVelocity = Vector3.new(v18, random:NextNumber(v19, v20), fn2(-angle[1], angle[2]))
		bodyAngularVelocity.MaxTorque = createVector(1e999, 1e999, 1e999)
		bodyAngularVelocity.P = 100000
		local Debris = game:GetService("Debris")
		Debris:AddItem(bodyVelocity, 0.25)
		local Debris2 = game:GetService("Debris")
		Debris2:AddItem(bodyAngularVelocity, 0.1)

		if not iterateSpeed.Entrance then
			continue
		end

		if iterateSpeed.EntranceDivision == "Iterate" then
			if iterateSpeed.Entrance == "Stepped" then
				task.wait()
			else
				task.wait(iterateSpeed.Entrance)
			end
		elseif math.floor(partCount * (v2 / (iterateSpeed.EntranceDivision or 3)) + 0.5) == i and i ~= partCount then
			if iterateSpeed.Entrance == "Stepped" then
				task.wait()
			else
				task.wait(iterateSpeed.Entrance)
			end

			v2 += 1
		end
	end

	task.wait(data.HoldTime or 5)
	local v3 = 1

	for i = 1, #v do
		Modes[flourishTypes.Exit or "Shrink"](v[i], flourishTypes.ExitSpeed or 0.3)

		if iterateSpeed.Exit then
			if iterateSpeed.ExitDivision == "Iterate" then
				if iterateSpeed.Exit == "Stepped" then
					task.wait()
				else
					task.wait(iterateSpeed.Exit)
				end
			elseif math.floor(#v * (v3 / (iterateSpeed.ExitDivision or 2))) == i and i ~= #v then
				if iterateSpeed.Exit == "Stepped" then
					task.wait()
				else
					task.wait(iterateSpeed.Exit)
				end

				v3 += 1
			end
		end

		local v4 = i
		task.spawn(function()
			task.wait((flourishTypes.ExitSpeed or 0.3) + 0.15)

			if v[v4] then
				Craters_Config.Delete_Part(v[v4])
			end
		end)
	end
end

return Styles