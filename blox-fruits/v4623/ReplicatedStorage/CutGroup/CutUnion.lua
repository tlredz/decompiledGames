local createVector = vector.create
local CutUnion = {}
local v = {}

function GetPart()
	local v2 = v[1]

	if v2 then
		table.remove(v, 1)
		return v2
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	return part
end

function ReturnPart(p)
	p.Parent = nil
	table.insert(v, p)
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

function CutUnion:GetModelFromParts(items, p)
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

function CutUnion:CutSlice(cframe: CFrame, modelFromParts, value: number?, p)
	if typeof(modelFromParts) == "CFrame" then
		local v2 = (cframe - cframe.Position + modelFromParts.Position) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local v3 = modelFromParts
		local count = 0

		while typeof(modelFromParts) ~= "Instance" do
			count += 1

			if count > 50 then
				return
			end

			local v4 = v2 * CFrame.Angles(count // 2 * 0.008726646259971648 * (count % 2 == 0 and -1 or 1), 0, 0)
			local raycastResult = workspace:Raycast(v3.Position, v4.LookVector * 1000, raycastParams)

			if raycastResult then
				modelFromParts = self:GetModelFromParts({ raycastResult.Instance }, p)
			end
		end
	end

	assert(modelFromParts)
	local v2 = value or 0.1
	local model = Instance.new("Model")
	local v3 = {}
	local v4 = {}
	local v5 = nil
	local parts = {}

	if modelFromParts:IsA("Model") then
		if modelFromParts:GetAttribute("OwnedPlayer") and modelFromParts:GetAttribute("OwnedPlayer") ~= (p or {
			Name = "thisisntanamemansladkjhsadkljhsadvmfn"
		}).Name then
			return
		end

		for _, part in pairs(modelFromParts:GetDescendants()) do
			if not part:IsA("BasePart") or (part:FindFirstChildOfClass("BaseMesh") or part:IsA("MeshPart")) or part.Name == "Windows" then
				continue
			end

			if part.Name == "DontCut" then
				continue
			end

			local hex = part.Color:ToHex()
			v3[part.Material] = v3[part.Material] or 0
			v4[hex] = v4[hex] or 0
			local v6 = part:GetMass() / part.CurrentPhysicalProperties.Density
			local material = part.Material
			v3[material] += v6
			v4[hex] += v6

			if v5 then
				table.insert(parts, part)
			else
				v5 = part
			end
		end
	elseif modelFromParts:IsA("BasePart") then
		if modelFromParts.Parent:GetAttribute("OwnedPlayer") and modelFromParts.Parent:GetAttribute("OwnedPlayer") ~= (p or {
			Name = "thisisntanamemansladkjhsadkljhsadvmfn"
		}).Name then
			return
		end

		local hex = modelFromParts.Color:ToHex()
		v3[modelFromParts.Material] = v3[modelFromParts.Material] or 0
		v4[hex] = v4[hex] or 0
		local material = modelFromParts.Material
		v3[material] += 1
		v4[hex] += 1
		v5 = modelFromParts
	end

	local v6 = {
		Material = nil,
		Max = 0
	}
	local v7 = {
		Color = nil,
		Max = 0
	}

	for k, max in pairs(v3) do
		if v6.Max < max then
			v6 = {
				Material = k,
				Max = max
			}
		end
	end

	for k, max in pairs(v4) do
		if v7.Max < max then
			v7 = {
				Color = Color3.fromHex(k),
				Max = max
			}
		end
	end

	if v5 or not modelFromParts:IsA("BasePart") then
		if not v5 then
			return
		end
	else
		v5 = modelFromParts
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getOrigCFrame()
		if modelFromParts:IsA("Model") then
			return (modelFromParts:GetPivot())
		end

		if modelFromParts:IsA("BasePart") then
			return modelFromParts.CFrame
		end

		return CFrame.identity
	end

	local origCFrame = getOrigCFrame() -- equivalent call inferred; original call site unknown
	local clone

	if #parts > 0 then
		clone = v5:UnionAsync(parts)
		local origCFrame2 = getOrigCFrame() -- equivalent call inferred; original call site unknown
		clone.CFrame = origCFrame:ToObjectSpace(origCFrame2) * clone.CFrame
		clone.Material = v6.Material or Enum.Material.SmoothPlastic
	else
		clone = v5:Clone()
		clone.Anchored = true
		clone.CanCollide = false
		clone.Parent = workspace.CurrentCamera
	end

	local origCFrame2 = getOrigCFrame() -- equivalent call inferred; original call site unknown
	local v8 = nil
	local v9 = nil
	task.spawn(function()
		local v10 = GetPart()
		v10.Color = v7.Color
		v10.Parent = workspace.Camera
		v10.Transparency = 1
		v10.Size = createVector(2000, 2000, 2000)
		v10.CFrame = cframe * CFrame.new(-1000 + v2 / 2, 0, 0)
		local v11 = nil
		pcall(function()
			v11 = clone:SubtractAsync({ v10 })
		end)
		ReturnPart(v10)

		if v11 then
			v11.Anchored = true
			v11.Color = v7.Color
			v11.Name = "Left"
			v9 = v11
		else
			v9 = true
		end
	end)
	task.spawn(function()
		local v10 = GetPart()
		v10.Color = v7.Color
		v10.Parent = workspace.Camera
		v10.Transparency = 1
		v10.Size = createVector(2000, 2000, 2000)
		v10.CFrame = cframe * CFrame.new(1000 - v2 / 2, 0, 0)
		local v11 = nil
		pcall(function()
			v11 = clone:SubtractAsync({ v10 })
		end)
		ReturnPart(v10)

		if v11 then
			v11.Anchored = true
			v11.Name = "Right"
			v11.Color = v7.Color
			v8 = v11
		else
			v8 = true
		end
	end)
	task.spawn(function()
		while not (v8 and v9) do
			task.wait()
		end

		if modelFromParts:IsA("Model") then
			clone.CFrame = modelFromParts:GetPivot()
		elseif modelFromParts:IsA("BasePart") then
			clone.CFrame = modelFromParts.CFrame
		end

		local origCFrame3 = getOrigCFrame() -- equivalent call inferred; original call site unknown
		local objectSpace = origCFrame2:ToObjectSpace(origCFrame3)

		if typeof(v8) == "Instance" then
			v8.CFrame *= objectSpace
			v8.Parent = model
		else
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "Right"
			boolValue.Parent = model
		end

		if typeof(v9) == "Instance" then
			v9.CFrame *= objectSpace
			v9.Parent = model
		else
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "Left"
			boolValue.Parent = model
		end

		clone:Destroy()
	end)
	return model, modelFromParts
end

return CutUnion