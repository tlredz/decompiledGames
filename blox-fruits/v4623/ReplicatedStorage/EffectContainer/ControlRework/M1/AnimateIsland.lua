local createVector = vector.create
local jagged = game.ReplicatedStorage.CutUnion.Jagged

local function SpawnWedgeRocks(hingeCF: CFrame, part, part2)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	local v = { 1e999 }

	for _, model in pairs(workspace.Map:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		local magnitude = (model:GetPivot().Position - hingeCF.Position).Magnitude

		if magnitude < v[1] then
			v = { magnitude, model }
		end
	end

	raycastParams.FilterDescendantsInstances = { v[2] }
	local clone = jagged:Clone()
	clone.Name = "CutRocks"
	clone.Parent = workspace

	if not clone:FindFirstChild("Hinge") then
		warn("Jagged model missing Hinge")
		return clone
	end

	for _, child in pairs(clone:GetChildren()) do
		child.Size = Vector3.new(child.Size.X, 900, child.Size.Z)
	end

	clone:PivotTo(hingeCF * CFrame.Angles(0, -1.5707963267948966, 0) + createVector(0, 5, 0) - createVector(0, 448, 0))
	local Ys = {}

	for _, part3 in ipairs(clone:GetChildren()) do
		if not (part3:IsA("BasePart") and part3.Name ~= "Hinge" and (part3.Name == "Left" or part3.Name == "Right")) then
			continue
		end

		local v2 = part3.Position + createVector(0, 150, 0)
		local raycastResult = workspace:Raycast(v2, createVector(0, -600, 0), raycastParams)

		if raycastResult then
			table.insert(Ys, raycastResult.Position.Y)
		else
			part3:Destroy()
		end
	end

	table.sort(Ys)

	for _, part3 in ipairs(clone:GetChildren()) do
		if not part3:IsA("BasePart") then
			continue
		end

		if part3.Name == "Hinge" then
			part3:Destroy()
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part3

		if part3.Name == "Left" then
			weldConstraint.Part1 = part
		elseif part3.Name == "Right" then
			weldConstraint.Part1 = part2
		end

		weldConstraint.Parent = part3
	end

	part.Destroying:Once(function()
		clone:Destroy()
	end)
	return clone
end

local flag = false

local function AnimateIslandCut(data)
	if not data or flag then
		return
	end

	local hingeCF = data.HingeCF
	local TL = data.TL
	local TR = data.TR
	local BH = data.BH
	local static = data.Static
	local staticOriginalCFrames = data.StaticOriginalCFrames

	local function newAnchor()
		local part = Instance.new("Part")
		part.Size = createVector(1, 1, 1)
		part.Transparency = 1
		part.CanCollide = false
		part.Anchored = true
		part.CFrame = hingeCF
		part.Parent = workspace
		return part
	end

	local part = Instance.new("Part")
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.CFrame = hingeCF
	part.Parent = workspace
	local part2 = Instance.new("Part")
	part2.Size = createVector(1, 1, 1)
	part2.Transparency = 1
	part2.CanCollide = false
	part2.Anchored = true
	part2.CFrame = hingeCF
	part2.Parent = workspace
	local part3 = Instance.new("Part")
	part3.Size = createVector(1, 1, 1)
	part3.Transparency = 1
	part3.CanCollide = false
	part3.Anchored = true
	part3.CFrame = hingeCF
	part3.Parent = workspace
	SpawnWedgeRocks(hingeCF, part, part2)

	local function weldList(list, part4)
		for _, v in ipairs(list) do
			if not v then
				continue
			end

			local weld = Instance.new("Weld")
			weld.C0 = v.CFrame:ToObjectSpace(part4.CFrame)
			weld.Part0 = v
			weld.Part1 = part4
			weld.Parent = v
			v.Parent = workspace
			v.Anchored = false
			v.Transparency = 0
		end
	end

	for _, v in pairs(data.touching) do
		v.Transparency = 1
		v.CanCollide = false
		v.CanTouch = false
		v.CanQuery = false
	end

	weldList(TL, part)
	weldList(TR, part2)
	weldList(BH, part3)

	for _, parent in ipairs(static) do
		if not parent then
			continue
		end

		staticOriginalCFrames[parent] = parent.CFrame
		local weldConstraint = Instance.new("WeldConstraint", parent)
		weldConstraint.Part0 = parent
		local part4

		if hingeCF:PointToObjectSpace(parent.Position).Z < 0 then
			part4 = hingeCF:PointToObjectSpace(parent.Position).X < 0 and part or part2 or part3
		else
			part4 = part3
		end

		weldConstraint.Part1 = part4
		parent.Anchored = false
	end

	task.delay(15, function()
		part.CFrame = hingeCF
		part2.CFrame = hingeCF
		part3.CFrame = hingeCF
		task.wait()

		for k, staticOriginalCFrame in pairs(staticOriginalCFrames) do
			if not (k and k.Parent) then
				continue
			end

			k.Anchored = true
			k.CFrame = staticOriginalCFrame
			k.WeldConstraint:Destroy()
		end

		for _, v in pairs(TL) do
			v:Destroy()
		end

		for _, v in pairs(TR) do
			v:Destroy()
		end

		for _, v in pairs(BH) do
			v:Destroy()
		end

		part:Destroy()
		part2:Destroy()
		part3:Destroy()

		for _, v in pairs(data.touching) do
			v.Transparency = 0
			v.CanCollide = true
			v.CanTouch = true
			v.CanQuery = true
		end

		flag = false
	end)
	task.spawn(function()
		local total = 0

		while total < 4 do
			total += task.wait()
			local TweenService = game:GetService("TweenService")
			local value = TweenService:GetValue(
				math.clamp(total / 4, 0, 1),
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			)
			part.CFrame = hingeCF * CFrame.Angles(0, math.rad(15 * value), 0) - createVector(0, 0.05, 0)
			part2.CFrame = hingeCF * CFrame.Angles(0, -math.rad(15 * value), 0) - createVector(0, 0.05, 0)
			part3.CFrame = hingeCF
		end
	end)
end

return AnimateIslandCut