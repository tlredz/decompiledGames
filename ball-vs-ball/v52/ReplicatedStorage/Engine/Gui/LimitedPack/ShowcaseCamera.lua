local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local vector2 = Vector2.new(0.5, 0.75)

local function collectPoints(model)
	local firstChild = model:FindFirstChild("礼包展示运行时")
	local v = { model:FindFirstChild("棋盘") }
	local result = {}

	for _, childName in { "左侧R15", "右侧R15" } do
		table.insert(v, firstChild and firstChild:FindFirstChild(childName .. "_展示") or model:FindFirstChild(childName))
	end

	for _, folder in model.Parent and model.Parent.Name == "全套展示" and { model } or v do
		if not folder then
			continue
		end

		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") or part.Transparency >= 1 then
				continue
			end

			local v2 = part.Size * 0.5

			for i = -1, 1, 2 do
				for i2 = -1, 1, 2 do
					table.insert(result, part.CFrame:PointToWorldSpace(v2 * Vector3.new(i, i2, -1)))
					table.insert(result, part.CFrame:PointToWorldSpace(v2 * Vector3.new(i, i2, 1)))
				end
			end
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function slopes(object, point: Vector2)
	local vectorToObjectSpace = object.CFrame:VectorToObjectSpace(object:ScreenPointToRay(point.X, point.Y).Direction)
	return Vector2.new(vectorToObjectSpace.X, vectorToObjectSpace.Y) / -vectorToObjectSpace.Z
end

local function fit(currentCamera, p, list, point: Vector2, point2: Vector2)
	if #list == 0 then
		return
	end

	local v = slopes(currentCamera, point) -- equivalent call inferred; original call site unknown
	local v2 = slopes(currentCamera, point2) -- equivalent call inferred; original call site unknown
	local X = v.X
	local X2 = v2.X
	local Y = v2.Y
	local Y2 = v.Y

	if X2 <= X or Y2 <= Y then
		return
	end

	local cframe = CFrame.new(list[1]) * p.CFrame.Rotation
	local v3 = -1e999
	local v4 = 1e999
	local v5 = -1e999
	local v6 = 1e999
	local v7 = -1e999

	for _, v8 in list do
		local pointToObjectSpace = cframe:PointToObjectSpace(v8)
		v3 = math.max(v3, pointToObjectSpace.X + X2 * pointToObjectSpace.Z)
		v4 = math.min(v4, pointToObjectSpace.X + X * pointToObjectSpace.Z)
		v5 = math.max(v5, pointToObjectSpace.Y + Y2 * pointToObjectSpace.Z)
		v6 = math.min(v6, pointToObjectSpace.Y + Y * pointToObjectSpace.Z)
		v7 = math.max(v7, pointToObjectSpace.Z)
	end

	local v8 = math.max((v3 - v4) / (X2 - X), (v5 - v6) / (Y2 - Y), v7 + 1)
	local v9 = (v3 + v4 - (X2 + X) * v8) * 0.5
	local v10 = (v5 + v6 - (Y2 + Y) * v8) * 0.5
	return cframe * CFrame.new(v9, v10, v8), CFrame.new(cframe.Position)
end

local function plateCenter(model)
	local instance = model:FindFirstChild("盘子")

	if instance and instance:IsA("BasePart") then
		return instance.Position
	end

	if instance and instance:IsA("Model") then
		return instance:GetBoundingBox().Position
	end

	if model:IsA("Model") then
		return model:GetPivot().Position
	end

	return createVector(0, 0, 0)
end

local function platePoints(folder)
	local result = {}

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and (part.Name == "盘子" or part.Name == "Baseplate")) then
			continue
		end

		local v = part.Size * 0.5

		if part:IsA("Part") and part.Shape == Enum.PartType.Cylinder then
			for i = -1, 1, 2 do
				for i2 = 0, 63 do
					local v2 = i2 / 64 * 3.141592653589793 * 2
					table.insert(
						result,
						part.CFrame:PointToWorldSpace((Vector3.new(i * v.X, math.cos(v2) * v.Y, math.sin(v2) * v.Z)))
					)
				end
			end
		else
			for i = -1, 1, 2 do
				for i2 = -1, 1, 2 do
					table.insert(result, part.CFrame:PointToWorldSpace(v * Vector3.new(i, i2, -1)))
					table.insert(result, part.CFrame:PointToWorldSpace(v * Vector3.new(i, i2, 1)))
				end
			end
		end
	end

	return result
end

local function fitFullSetAtRoll(object, p, items, position: Vector3, data, point: Vector2, point2: Vector2, list, p2: number)
	local v = p.CFrame.LookVector * createVector(1, 0, 1)
	local v2 = v.Magnitude < 0.001 and createVector(0, 0, -1) or v
	local v3 = CFrame.lookAt(createVector(0, 0, 0), v2.Unit) * CFrame.Angles(-0.13962634015954636, 0, 0) * CFrame.Angles(
		0,
		0,
		p2
	)
	local cframe = CFrame.new(position) * v3
	local v5 = slopes(object, data.AbsolutePosition + data.AbsoluteSize * vector2) -- equivalent call inferred; original call site unknown
	local v6 = slopes(object, point) -- equivalent call inferred; original call site unknown
	local v7 = slopes(object, point2) -- equivalent call inferred; original call site unknown
	local X = v6.X
	local X2 = v7.X
	local Y = v7.Y
	local Y2 = v6.Y

	if v5.X <= X or X2 <= v5.X or v5.Y <= Y or Y2 <= v5.Y then
		return
	end

	local v8 = 1

	for _, item in items do
		local pointToObjectSpace = cframe:PointToObjectSpace(item)
		v8 = math.max(
			v8,
			pointToObjectSpace.Z + 1,
			(pointToObjectSpace.X + X2 * pointToObjectSpace.Z) / (X2 - v5.X),
			(-pointToObjectSpace.X - X * pointToObjectSpace.Z) / (v5.X - X),
			(pointToObjectSpace.Y + Y2 * pointToObjectSpace.Z) / (Y2 - v5.Y),
			(-pointToObjectSpace.Y - Y * pointToObjectSpace.Z) / (v5.Y - Y)
		)
	end

	local v9 = v8 * 0.66

	for _, item in items do
		v9 = math.max(v9, cframe:PointToObjectSpace(item).Z + 1)
	end

	local v10 = -v5.Y * v9
	local guiObject = data.Parent and data.Parent:FindFirstChild("展示区边框")

	if guiObject and guiObject:IsA("GuiObject") and #list > 0 then
		local Y3 = (slopes(object, guiObject.AbsolutePosition + guiObject.AbsoluteSize * Vector2.new(0.5, 0.975))).Y
		local v12 = 1e999

		for _, v13 in list do
			local pointToObjectSpace = cframe:PointToObjectSpace(v13)
			v12 = math.min(v12, pointToObjectSpace.Y + Y3 * pointToObjectSpace.Z)
		end

		v10 = v12 - Y3 * v9
	end

	return cframe * CFrame.new(-v5.X * v9, v10, v9), CFrame.new(position)
end

local function projectedPlateTilt(cframe: CFrame, items)
	local zero = Vector2.zero
	local v = {}

	for _, item in items do
		local pointToObjectSpace = cframe:PointToObjectSpace(item)

		if pointToObjectSpace.Z >= -0.001 then
			continue
		end

		local v2 = Vector2.new(pointToObjectSpace.X, -pointToObjectSpace.Y) / -pointToObjectSpace.Z
		table.insert(v, v2)
		zero += v2
	end

	if #v < 3 then
		return 0
	end

	local v2 = zero / #v
	local total = 0
	local total2 = 0
	local total3 = 0

	for _, v3 in v do
		local v4 = v3 - v2
		total += v4.X * v4.X
		total2 += v4.X * v4.Y
		total3 += v4.Y * v4.Y
	end

	if total + total3 < 1e-10 then
		return 0
	end

	return math.atan2(total2 * 2, total - total3) * 0.5
end

local function fitFullSet(currentCamera, p, p2, vector3: Vector3, data, point: Vector2, point2: Vector2, list)
	local v = 0
	local v2 = nil
	local v3 = nil

	for _ = 1, 8 do
		v2, v3 = fitFullSetAtRoll(currentCamera, p, p2, vector3, data, point, point2, list, v)

		if not v2 or #list < 3 then
			break
		end

		local v4 = projectedPlateTilt(v2, list)

		if math.abs(v4) < 0.00017453292519943296 then
			break
		else
			v -= v4
		end
	end

	return v2, v3
end

return {
	Start = function(model, data, p)
		local v = nil
		local v2 = nil
		local v3

		if model.Parent == nil then
			v3 = false
		else
			v3 = model.Parent.Name == "全套展示"
		end

		local v4 = collectPoints(model)
		local v5 = nil
		local v6 = nil
		local cFrame = nil
		local v7 = nil
		local v8 = nil
		local v9 = nil
		local v10 = nil
		local v11 = nil
		local flag = true
		local v12 = nil
		local v13 = 0
		local v14 = nil
		local v15 = nil
		local pivot

		if model:IsA("Model") then
			pivot = model:GetPivot()
		else
			pivot = nil
		end

		local v16 = plateCenter(model)
		local v17 = platePoints(model)
		local v18 = nil
		local X = 0
		local connections = {}

		local function canRotateModel()
			return v3
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function restoreModel()
			if v3 and model:IsA("Model") and pivot then
				model:PivotTo(pivot)
			end
		end

		local function stopDrag()
			v18 = nil
		end

		local function insideRegion(position: Vector3)
			local vector3 = Vector2.new(position.X, position.Y)
			local absolutePosition = data.AbsolutePosition
			local absoluteSize = data.AbsoluteSize
			return vector3.X >= absolutePosition.X and vector3.Y >= absolutePosition.Y and vector3.X <= absolutePosition.X + absoluteSize.X and vector3.Y <= absolutePosition.Y + absoluteSize.Y
		end

		table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or v18 or not (v3 and v14) then
				return
			end

			if v12 and v12.PlaybackState == Enum.PlaybackState.Playing or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch or not insideRegion(input.Position) then
				return
			end

			v18 = input
			X = input.Position.X
		end))
		table.insert(connections, UserInputService.InputChanged:Connect(function(input)
			local v19 = v18

			if not (v19 and v3 and v and v14 and v15) then
				return
			end

			local v20 = v19.UserInputType == Enum.UserInputType.MouseButton1

			if v20 and input.UserInputType ~= Enum.UserInputType.MouseMovement or not v20 and input ~= v19 then
				return
			end

			local v21 = input.Position.X - X
			X = input.Position.X
			v13 = (v13 + v21 / math.max(data.AbsoluteSize.X, 1) * 3.141592653589793 * 2) % 6.283185307179586

			if model:IsA("Model") and pivot then
				model:PivotTo(CFrame.new(v16) * CFrame.Angles(0, v13, 0) * CFrame.new(-v16) * pivot)
			end
		end))
		table.insert(connections, UserInputService.InputEnded:Connect(function(input)
			if input == v18 then
				v18 = nil
			end
		end))
		table.insert(connections, UserInputService.WindowFocusReleased:Connect(stopDrag))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function restore()
			if v12 then
				v12:Cancel()
				v12 = nil
			end

			if v and v.Parent and v2 then
				v.CFrame = v2.cframe
				v.Focus = v2.focus
				local v19 = v
				local cameraType

				if v2.cameraType == Enum.CameraType.Scriptable then
					cameraType = Enum.CameraType.Custom
				else
					cameraType = v2.cameraType
				end

				v19.CameraType = cameraType
			end
		end

		local function update()
			local currentCamera = workspace.CurrentCamera

			if not (currentCamera and model.Parent and data.Parent) then
				return
			end

			if currentCamera ~= v then
				restore() -- equivalent call inferred; original call site unknown
				v = currentCamera
				v2 = {
					cframe = currentCamera.CFrame,
					focus = currentCamera.Focus,
					cameraType = currentCamera.CameraType
				}
				flag = true
			end

			currentCamera.CameraType = Enum.CameraType.Scriptable
			local v19

			if not v3 then
				v19 = model:FindFirstChild("礼包展示运行时")
			end

			local cameraBoundsRevision = v19 and v19:GetAttribute("CameraBoundsRevision")

			if v19 ~= v5 or cameraBoundsRevision ~= v6 then
				v5 = v19
				v6 = cameraBoundsRevision
				v11 = os.clock() + 0.25
			end

			if p.CFrame ~= cFrame then
				cFrame = p.CFrame

				if not v3 then
					v4 = collectPoints(model)
				end

				flag = true
			end

			if v11 then
				local now = os.clock()

				if v11 <= now then
					v11 = nil
					v4 = collectPoints(model)
					flag = true
				end
			end

			local absoluteSize = data.AbsoluteSize
			local absolutePosition = data.AbsolutePosition

			if absoluteSize.X < 2 or absoluteSize.Y < 2 or currentCamera.ViewportSize.Y < 2 then
				return
			end

			local v20 = absoluteSize * 0.05
			local v21 = absolutePosition + v20
			local v22 = absolutePosition + absoluteSize - v20
			local v23 = slopes(currentCamera, v21) -- equivalent call inferred; original call site unknown
			local v24 = slopes(currentCamera, v22) -- equivalent call inferred; original call site unknown

			if absoluteSize ~= v7 or absolutePosition ~= v8 or not v9 or (v23 - v9).Magnitude > 0.00001 or not v10 or (v24 - v10).Magnitude > 0.00001 then
				v7 = absoluteSize
				v8 = absolutePosition
				v9 = v23
				v10 = v24
				flag = true
			end

			if flag then
				flag = false
				local cFrame2, focus

				if v3 then
					cFrame2, focus = fitFullSet(currentCamera, p, v4, v16, data, v21, v22, v17)
				else
					cFrame2, focus = fit(currentCamera, p, v4, v21, v22)
				end

				if cFrame2 and focus then
					local v27 = v14 == nil
					v14 = cFrame2
					v15 = focus

					if v12 then
						v12:Cancel()
						v12 = nil
					end

					if v27 then
						currentCamera.CFrame = cFrame2
						currentCamera.Focus = focus
					else
						v12 = TweenService:Create(
							currentCamera,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								CFrame = cFrame2,
								Focus = focus
							}
						)
						v12:Play()
					end
				end
			end
		end

		RunService:BindToRenderStep("LimitedPackShowcaseCamera", Enum.RenderPriority.Camera.Value + 1, update)
		update()
		return function()
			v18 = nil
			restoreModel() -- equivalent call inferred; original call site unknown

			for _, connection in connections do
				connection:Disconnect()
			end

			RunService:UnbindFromRenderStep("LimitedPackShowcaseCamera")
			restore() -- equivalent call inferred; original call site unknown
		end, function(p2, p3)
			v18 = nil

			if v12 then
				v12:Cancel()
				v12 = nil
			end

			restoreModel() -- equivalent call inferred; original call site unknown
			v13 = 0
			v14 = nil
			v15 = nil
			model = p2
			p = p3
			v3 = model.Parent ~= nil and model.Parent.Name == "全套展示"
			local v20

			if model:IsA("Model") then
				v20 = model:GetPivot()
			end

			pivot = v20
			v16 = plateCenter(model)
			v17 = platePoints(model)
			v4 = collectPoints(model)
			cFrame = nil
			v5 = nil
			v6 = nil
			v11 = nil
			v7 = nil
			v8 = nil
			v9 = nil
			v10 = nil
			flag = true
			update()
		end
	end
}