local createVector = vector.create
local CFrame2 = {}
local abs = math.abs
local new = Vector3.new
local new2 = CFrame.new
local components = new2().components
local inverse = new2().inverse
local fromAxisAngle = CFrame.fromAxisAngle

function CFrame2.AxisAngleInterpolate(p, p2, p3)
	local _, _, _, v, v2, v3, v4, v5, v6, v7, v8, v9 = components(inverse(p) * p2)
	local v10 = (v + v5 + v9 - 1) / 2
	local v11 = (p2.p - p.p) * p3
	local v13

	if math.abs(v10) < 1 then
		v13 = new(v8 - v6, v3 - v7, v4 - v2) or createVector(0, 1, 0)
	else
		v13 = createVector(0, 1, 0)
	end

	return p * fromAxisAngle(v13, math.acos(v10 > 1 and 1 or v10 < -1 and -1 or v10) * p3) + v11
end

function CFrame2.PosInObj(list, p, p2, p3)
	if abs(list[4] * p + list[5] * p2 + list[6] * p3 + list[1]) < 1 and abs(list[7] * p + list[8] * p2 + list[9] * p3 + list[2]) < 1 and abs(list[10] * p + list[11] * p2 + list[12] * p3 + list[3]) < 1 then
		return true
	end

	return false
end

function CFrame2.PosInObjBlock(list, p, p2, p3)
	local v = list[4] * p + list[5] * p2 + list[6] * p3 + list[1]
	local v2 = list[7] * p + list[8] * p2 + list[9] * p3 + list[2]
	local v3 = list[10] * p + list[11] * p2 + list[12] * p3 + list[3]
	local v4 = abs(v)
	local v5 = abs(v2)
	local v6 = abs(v3)

	if not (v4 < 1.03 and v5 < 1.03 and v6 < 1.03) then
		return false
	end

	if v5 < v4 then
		if v6 < v4 then
			local v7 = v4 / v
			return list[13] * v7, list[14] * v7, list[15] * v7
		end

		local v7 = v6 / v3
		return list[19] * v7, list[20] * v7, list[21] * v7
	elseif v6 < v5 then
		local v7 = v5 / v2
		return list[16] * v7, list[17] * v7, list[18] * v7
	else
		local v7 = v6 / v3
		return list[19] * v7, list[20] * v7, list[21] * v7
	end
end

function CFrame2.GetInvSizeComponents(object, data)
	local components2, v, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11 = object:inverse():components()
	local v12 = data.x / 2
	local v13 = data.y / 2
	local v14 = data.z / 2
	return {
		components2 / v12,
		v / v13,
		v2 / v14,
		v3 / v12,
		v4 / v12,
		v5 / v12,
		v6 / v13,
		v7 / v13,
		v8 / v13,
		v9 / v14,
		v10 / v14,
		v11 / v14
	}
end

function CFrame2.NormalOfPart(instance, data)
	local x = data.x
	local y = data.y
	local z = data.z
	local size = instance.Size
	local cFrame = instance.CFrame
	local _, _, _, v, v2, v3, v4, v5, v6, v7, v8, v9 = cFrame:components()
	local components2, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20 = cFrame:inverse():components()
	local v21 = size.x / 2
	local v22 = size.y / 2
	local v23 = size.z / 2
	local v24 = {
		components2 / v21,
		v10 / v22,
		v11 / v23,
		v12 / v21,
		v13 / v21,
		v14 / v21,
		v15 / v22,
		v16 / v22,
		v17 / v22,
		v18 / v23,
		v19 / v23,
		v20 / v23,
		v,
		v4,
		v7,
		v2,
		v5,
		v8,
		v3,
		v6,
		v9
	}
	local v25 = v24[4] * x + v24[5] * y + v24[6] * z + v24[1]
	local v26 = v24[7] * x + v24[8] * y + v24[9] * z + v24[2]
	local v27 = v24[10] * x + v24[11] * y + v24[12] * z + v24[3]
	local v28 = abs(v25)
	local v29 = abs(v26)
	local v30 = abs(v27)

	if v29 < v28 then
		if v30 < v28 then
			local v31 = v28 / v25
			return (Vector3.new(v24[13] * v31, v24[14] * v31, v24[15] * v31))
		end

		local v31 = v30 / v27
		return (Vector3.new(v24[19] * v31, v24[20] * v31, v24[21] * v31))
	elseif v30 < v29 then
		local v31 = v29 / v26
		return (Vector3.new(v24[16] * v31, v24[17] * v31, v24[18] * v31))
	else
		local v31 = v30 / v27
		return (Vector3.new(v24[19] * v31, v24[20] * v31, v24[21] * v31))
	end
end

function CFrame2.InsidePart(instance, data, value)
	local v = value or 1
	local x = data.x
	local y = data.y
	local z = data.z
	local components2, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12 = instance.CFrame:inverse():components()
	local size = instance.Size
	local v13 = size.x / 2
	local v14 = size.y / 2
	local v15 = size.z / 2

	if abs(v4 / v13 * x + v5 / v13 * y + v6 / v13 * z + components2 / v13) < v and abs(v7 / v14 * x + v8 / v14 * y + v9 / v14 * z + v2 / v14) < v and abs(v10 / v15 * x + v11 / v15 * y + v12 / v15 * z + v3 / v15) < v then
		return true
	end

	return false
end

function CFrame2.GetChildrenInRange(instance, cframe: CFrame, vector2: Vector3, p)
	local result = {}

	for _, child in pairs(instance:GetChildren()) do
		local position = child:IsA("Model") and child.PrimaryPart and child.PrimaryPart.Position

		if not position then
			if child:IsA("BasePart") then
				position = child.Position or nil
			else
				position = nil
			end
		end

		if not (position and CFrame2.InsidePart({
			CFrame = cframe,
			Size = vector2
		}, position)) then
			continue
		end

		local humanoid = child:FindFirstChildOfClass("Humanoid")

		if not humanoid or p and p[humanoid] then
			continue
		end

		result[#result + 1] = {
			Humanoid = humanoid,
			Position = position,
			Model = child
		}
	end

	return result
end

function CFrame2.CreatePart(position, duration)
	local part = Instance.new("Part")
	part.Size = Vector3.new()
	part.Anchored = true
	part.Massless = true
	part.CanCollide = false
	part.Position = position
	part.Transparency = 1
	part.Parent = workspace

	if duration then
		task.delay(duration, function()
			part:Destroy()
		end)
	end

	return part
end

function CFrame2.Weld(part, part2, p, cframe: CFrame, cframe2: CFrame)
	local weld = Instance.new("Weld")
	weld.Part0 = part
	weld.Part1 = part2
	weld.C0 = cframe or part.CFrame:Inverse() * part2.CFrame
	weld.C1 = cframe2 or CFrame.new()
	weld.Parent = p or part
	return weld
end

function CFrame2.RigToPrimaryPart(folder, p)
	if not p then
		return warn("No PrimaryPart given!")
	end

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") and part ~= p then
			CFrame2.Weld(part, p)
		end
	end

	return folder
end

function CFrame2.Motor6D(part, part2, p, p2, cframe: CFrame, _: CFrame)
	local v = p or part
	local cframe2 = CFrame.new(v.Position)
	local cframe3 = CFrame.Angles(v.CFrame:ToEulerAnglesXYZ())
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = part
	motor6D.Part1 = part2
	motor6D.C0 = cframe or part.CFrame:inverse() * cframe2 * cframe3
	motor6D.C1 = cframe or part2.CFrame:inverse() * cframe2 * cframe3
	motor6D.Parent = p2 or part
	return motor6D
end

return CFrame2