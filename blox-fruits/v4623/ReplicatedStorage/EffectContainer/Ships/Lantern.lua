local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local verlet = Util.Verlet
return function(data)
	local shipModel = data.ShipModel

	if not data.Model then
		warn("No model found")
		return
	end

	if not shipModel then
		warn("No Ship Model")
		return
	end

	local modelOffset = data.ModelOffset
	local model = data.Model
	local primaryPart = model.PrimaryPart

	if not model.PrimaryPart then
		while shipModel:IsDescendantOf(workspace) do
			primaryPart = model.PrimaryPart

			if primaryPart then
				break
			else
				task.wait(0.1)
			end
		end
	end

	if not primaryPart then
		return
	end

	model:SetPrimaryPartCFrame(shipModel.PrimaryPart.CFrame * modelOffset)
	model.Parent = _WorldOrigin
	local magnitude = shipModel:GetModelSize().Magnitude
	local v = { model.Shell, model.Rod, table.unpack(model.Chains:GetChildren()) }
	local objectSpace = model.Shell.CFrame:ToObjectSpace(model.Light.CFrame)
	table.sort(v, function(a, b)
		return a.Position.Y < b.Position.Y
	end)
	local points = {}
	local constraints = {}
	local v2 = {}

	for k, v3 in pairs(v) do
		local point = verlet.point.new(v3.Position)
		point.gravity = workspace.Gravity * 1.25

		if k > 1 then
			local total = 0

			if k == 2 then
				total += math.max(v[2 - 1].Size.X, v[2 - 1].Size.Y, v[2 - 1].Size.Z) / 2 * 0.9
			end

			table.insert(
				constraints,
				(verlet.constraint.new(
					point,
					points[k - 1],
					(point.position - points[k - 1].position).Magnitude + total
				))
			)
			local objectSpace2 = primaryPart.CFrame:ToObjectSpace(v3.CFrame)

			if k == #v then
				objectSpace2 = v2[2]
			end

			table.insert(v2, objectSpace2 - objectSpace2.p)
		end

		if k == #v then
			point.anchored = true
		end

		table.insert(points, point)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Boats }

	local function getCalculatedCFrameFromIndex(i)
		local v3 = constraints[i]
		local v4 = v3.point2.position - v3.point1.position
		local _ = v4.Magnitude
		return CFrame.new(createVector(0, 0, 0), v4.Unit) * CFrame.Angles(1.5707963267948966, 0, 0) * v2[i] + v3.point1.position + v4 / 2
	end

	local v3 = false

	local function Update(p, p2)
		points[#points].position = (shipModel.PrimaryPart.CFrame * modelOffset).Position

		for _, v4 in pairs(points) do
			v4:update(p, 0.9985)
		end

		for _ = 1, p2 and 15 or 1 do
			for _, v4 in pairs(constraints) do
				v4:solve()
			end
		end

		if p2 then
			local modelSize = model:GetModelSize()
			local vector2 = Vector3.new(
				math.min(40, modelSize.X),
				math.min(40, modelSize.Y),
				(math.min(40, modelSize.Z))
			)
			local blockcast = workspace:Blockcast(
				model:GetModelCFrame(),
				vector2,
				model:GetModelCFrame():VectorToWorldSpace(createVector(-0, -1, -0)),
				raycastParams
			)

			if blockcast then
				local collision = verlet.collision.new(blockcast.Instance)

				for _, v4 in pairs(points) do
					local pointToPlanes = collision:pointToPlanes(v4.position)

					if pointToPlanes then
						v4.position = pointToPlanes
					end
				end
			end

			v3 = false
			primaryPart.CFrame = shipModel.PrimaryPart.CFrame * modelOffset

			for i = 1, #constraints do
				v[i].CFrame = getCalculatedCFrameFromIndex(i)
			end

			model.Light.CFrame = model.Shell.CFrame * objectSpace
		elseif not v3 then
			model:SetPrimaryPartCFrame(CFrame.new(0, math.max(1 + workspace.FallenPartsDestroyHeight, -999), 0))
			v3 = true
		end
	end

	local v4 = 0.016666666666666666

	while data.ShipModel and data.ShipModel:IsDescendantOf(workspace) and data.Model and data.Model:IsDescendantOf(workspace) do
		local lastTime = tick()
		Update(
			v4,
			(workspace.CurrentCamera.CFrame.Position - shipModel:GetModelCFrame().Position).Magnitude - magnitude < 600
		)
		RunService.RenderStepped:Wait()
		v4 = tick() - lastTime
	end

	for _, v5 in pairs(constraints) do
		v5:Destroy()
	end
end