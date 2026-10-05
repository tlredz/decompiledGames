local createVector = vector.create
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Util = require(script.Parent.Util)
local Shop = require(game.ReplicatedStorage.Shop)
local Net = require(game.ReplicatedStorage.Modules.Net)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local Spring = require(game.ReplicatedStorage.Util.Spring)
require(script.Parent.Types)
local v = { "Left", "Head", "Right" }
local vector2 = Vector2.new(0.3, 0.42)
local v2 = { createVector(1, 0, 0), createVector(0, 1, 0), createVector(0, 0, 1) }
local localPlayer = game.Players.LocalPlayer

local function getPreviewWeaponModel(childName: string)
	local previewWeaponAssetCache = localPlayer.PlayerGui:FindFirstChild("PreviewWeaponAssetCache")
	local child = previewWeaponAssetCache and previewWeaponAssetCache:FindFirstChild(childName)

	if not child then
		Net:RemoteEvent("PrepareWeaponPreviewModel"):FireServer(childName)
		child = localPlayer.PlayerGui:WaitForChild("PreviewWeaponAssetCache"):WaitForChild(childName)
	end

	return assert(child)
end

local function getHoldablePreviewSources(instance)
	local result = {}

	for _, childName in v do
		local child = instance:FindFirstChild(childName)

		if child and #child:GetChildren() > 0 then
			table.insert(result, child)
		end
	end

	if #result == 0 then
		table.insert(result, instance)
	end

	return result
end

local function preparePreviewModel(folder)
	local v3 = false

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		v3 = true
	end

	return v3
end

local function getLongestAndThinnestAxis(vector3: Vector3)
	local v3 = {
		{
			Index = 1,
			Size = vector3.X
		},
		{
			Index = 2,
			Size = vector3.Y
		},
		{
			Index = 3,
			Size = vector3.Z
		}
	}
	table.sort(v3, function(a, b)
		return a.Size > b.Size
	end)
	return v3[1].Index, v3[3].Index
end

-- equivalent calls inferred from this helper; original call sites unknown
local function projectOntoPlane(vector3: Vector3, vector4: Vector3)
	local v3 = vector3 - vector4 * vector3:Dot(vector4)

	if v3.Magnitude < 0.0001 then
		return nil
	end

	return v3.Unit
end

local function getFallbackDepthDirection(vector3: Vector3)
	for _, v3 in v2 do
		local selected = projectOntoPlane(v3, vector3) -- equivalent call inferred; original call site unknown

		if selected then
			return selected
		end
	end

	return createVector(1, 0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getShootAttachmentLookVector(instance)
	local shootAttachment = instance:FindFirstChild("ShootAttachment", true)

	if shootAttachment and shootAttachment:IsA("Attachment") then
		return shootAttachment.WorldCFrame.LookVector
	end

	return nil
end

local function getPreviewSourceAxes(instance, boundingBox: CFrame, vector3: Vector3)
	local longestAndThinnestAxis, v3 = getLongestAndThinnestAxis(vector3)
	local unit = assert(v2[longestAndThinnestAxis])
	local shootAttachmentLookVector = getShootAttachmentLookVector(instance) -- equivalent call inferred; original call site unknown

	if shootAttachmentLookVector and shootAttachmentLookVector.Magnitude >= 0.0001 then
		unit = boundingBox:VectorToObjectSpace(shootAttachmentLookVector).Unit
	end

	local unit2 = projectOntoPlane(assert(v2[v3]), unit) -- equivalent call inferred; original call site unknown

	if unit2 then
		return unit, unit2
	end

	local flag = true

	for _, vector4 in v2 do
		local v5 = vector4 - unit * vector4:Dot(unit)

		if v5.Magnitude < 0.0001 then
			unit2 = nil
		else
			unit2 = v5.Unit
		end

		if not unit2 then
			continue
		end

		flag = false
		break
	end

	if flag then
		unit2 = createVector(1, 0, 0)
	end

	return unit, unit2
end

local function getOrthonormalBasis(vector3: Vector3, vector4: Vector3)
	local unit = vector3.Unit
	local unit2 = projectOntoPlane(vector4, unit) -- equivalent call inferred; original call site unknown

	if not unit2 then
		local flag = true

		for _, vector5 in v2 do
			local v3 = vector5 - unit * vector5:Dot(unit)

			if v3.Magnitude < 0.0001 then
				unit2 = nil
			else
				unit2 = v3.Unit
			end

			if not unit2 then
				continue
			end

			flag = false
			break
		end

		if flag then
			unit2 = createVector(1, 0, 0)
		end
	end

	local unit3 = unit:Cross(unit2).Unit
	return unit3, unit, unit3:Cross(unit).Unit
end

local function getAlignedBoxCFrame(vector3: Vector3, vector4: Vector3, vector5: Vector3, vector6: Vector3, vector7: Vector3)
	local unit = vector4.Unit
	local unit2 = projectOntoPlane(vector5, unit) -- equivalent call inferred; original call site unknown

	if not unit2 then
		local flag = true

		for _, vector8 in v2 do
			local v3 = vector8 - unit * vector8:Dot(unit)

			if v3.Magnitude < 0.0001 then
				unit2 = nil
			else
				unit2 = v3.Unit
			end

			if not unit2 then
				continue
			end

			flag = false
			break
		end

		if flag then
			unit2 = createVector(1, 0, 0)
		end
	end

	local unit3 = unit:Cross(unit2).Unit
	local unit4 = unit3:Cross(unit).Unit
	local unit5 = vector6.Unit
	local unit6 = projectOntoPlane(vector7, unit5) -- equivalent call inferred; original call site unknown

	if not unit6 then
		local flag = true

		for _, vector8 in v2 do
			local v3 = vector8 - unit5 * vector8:Dot(unit5)

			if v3.Magnitude < 0.0001 then
				unit6 = nil
			else
				unit6 = v3.Unit
			end

			if not unit6 then
				continue
			end

			flag = false
			break
		end

		if flag then
			unit6 = createVector(1, 0, 0)
		end
	end

	local unit7 = unit5:Cross(unit6).Unit
	local unit8 = unit7:Cross(unit5).Unit
	local cframe = CFrame.fromMatrix(createVector(0, 0, 0), unit3, unit, unit4)
	return CFrame.fromMatrix(vector3, unit7, unit5, unit8) * cframe:Inverse()
end

local function getHoldableLeanAngle(p: number, p2: number)
	if p2 <= 1 then
		return 0.20943951023931956
	end

	local v3 = p2 == 2 and 0.5585053606381855 or 0.4886921905584123
	return (p - (p2 + 1) * 0.5) * v3
end

local function pivotHoldableForPreview(instance, p: number)
	local boundingBox, v3 = instance:GetBoundingBox()
	local previewSourceAxes, v4 = getPreviewSourceAxes(instance, boundingBox, v3)
	local unit = Vector3.new(math.sin(p), math.cos(p), 0).Unit
	instance:PivotTo(getAlignedBoxCFrame(createVector(0, 0, 0), previewSourceAxes, v4, unit, createVector(0, 0, -1)) * boundingBox:ToObjectSpace(instance:GetPivot()))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPreviewSourceDistance(vector3: Vector3)
	return math.max(vector3.X * 0.5 / 0.3152987888789835, vector3.Y * 0.5 / 0.3152987888789835, vector3.Z, 1) + vector3.Z * 0.5
end

local function getCameraVisibleSize(p, p2: number)
	local viewportSize = p.ViewportSize

	if viewportSize.X <= 0 or viewportSize.Y <= 0 then
		return nil
	end

	local v3 = p2 * 2 * math.tan(math.rad(p.FieldOfView) * 0.5)
	return v3 * (viewportSize.X / viewportSize.Y), v3
end

local function getPreviewScale(p, vector3: Vector3)
	local viewportSize = p.ViewportSize
	local v3, v4

	if not (viewportSize.X <= 0 or viewportSize.Y <= 0) then
		v4 = math.tan(math.rad(p.FieldOfView) * 0.5) * 6
		v3 = v4 * (viewportSize.X / viewportSize.Y)
	end

	if v3 and v4 then
		local v5 = getPreviewSourceDistance(vector3) * 1.5 * 0.3152987888789835
		return (math.max(math.min(0.42 * v3 / v5, 0.42 * v4 / v5), 0.001))
	else
		return nil
	end
end

local function getPreviewPosition(data)
	local viewportSize = data.ViewportSize
	local v3, v4

	if not (viewportSize.X <= 0 or viewportSize.Y <= 0) then
		v4 = math.tan(math.rad(data.FieldOfView) * 0.5) * 6
		v3 = v4 * (viewportSize.X / viewportSize.Y)
	end

	if v3 and v4 then
		local cFrame = data.CFrame
		return cFrame.Position + cFrame.RightVector * ((vector2.X - 0.5) * v3) + cFrame.UpVector * ((0.5 - vector2.Y) * v4) + cFrame.LookVector * 3
	else
		return nil
	end
end

local function getPreviewUprightAxis(p, p2: number, p3: number)
	local cFrame = p.CFrame
	local unit = (cFrame.UpVector * 0.984807753012208 + cFrame.RightVector * 0.17364817766693033).Unit
	local vectorToWorldSpace = CFrame.fromAxisAngle(cFrame.RightVector, p2):VectorToWorldSpace(unit)
	return CFrame.fromAxisAngle(cFrame.LookVector, p3):VectorToWorldSpace(vectorToWorldSpace)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rotateVectorAroundAxis(unit: Vector3, previewUprightAxis: Vector3, p: number)
	return CFrame.fromAxisAngle(previewUprightAxis, p):VectorToWorldSpace(unit)
end

local function getPreviewBaseDepthAxis(p, vector3: Vector3, vector4: Vector3?)
	local selected = projectOntoPlane(-p.CFrame.LookVector, vector3) -- equivalent call inferred; original call site unknown

	if selected then
		return selected
	end

	if vector4 then
		local selected2 = projectOntoPlane(vector4, vector3) -- equivalent call inferred; original call site unknown

		if selected2 then
			return selected2
		end
	end

	local v5 = projectOntoPlane(p.CFrame.RightVector, vector3) -- equivalent call inferred; original call site unknown

	if v5 then
		return v5
	end

	for _, v6 in v2 do
		local selected2 = projectOntoPlane(v6, vector3) -- equivalent call inferred; original call site unknown

		if selected2 then
			return selected2
		end
	end

	return createVector(1, 0, 0)
end

local function pivotPreviewModel(model, currentCamera, vector3: Vector3, previewSourceAxes: Vector3, vector4: Vector3, vector5: Vector3?, total: number, X: number, p: number, Z: number)
	local DISTANCE_EPSILON = 0.0001
	local previewUprightAxis = getPreviewUprightAxis(currentCamera, X, Z)
	local unit = projectOntoPlane(-currentCamera.CFrame.LookVector, previewUprightAxis) -- equivalent call inferred; original call site unknown

	if not unit then
		local rightVector, v4, v5

		if vector5 then
			local v6 = vector5 - previewUprightAxis * vector5:Dot(previewUprightAxis)

			if v6.Magnitude < DISTANCE_EPSILON then
				unit = nil
			else
				unit = v6.Unit
			end

			if not unit then
				rightVector = currentCamera.CFrame.RightVector
				v4 = rightVector - previewUprightAxis * rightVector:Dot(previewUprightAxis)

				if v4.Magnitude < DISTANCE_EPSILON then
					unit = nil
				else
					unit = v4.Unit
				end

				if not unit then
					local flag = true

					for k, vector6 in v2 do
						v5 = vector6 - previewUprightAxis * vector6:Dot(previewUprightAxis)

						if v5.Magnitude < DISTANCE_EPSILON then
							unit = nil
						else
							unit = v5.Unit
						end

						if not unit then
							continue
						end

						flag = false
						break
					end

					if flag then
						unit = createVector(1, 0, 0)
					end
				end
			end
		else
			rightVector = currentCamera.CFrame.RightVector
			v4 = rightVector - previewUprightAxis * rightVector:Dot(previewUprightAxis)

			if v4.Magnitude < DISTANCE_EPSILON then
				unit = nil
			else
				unit = v4.Unit
			end

			if not unit then
				local flag = true

				for k, vector6 in v2 do
					v5 = vector6 - previewUprightAxis * vector6:Dot(previewUprightAxis)

					if v5.Magnitude < DISTANCE_EPSILON then
						unit = nil
					else
						unit = v5.Unit
					end

					if not unit then
						continue
					end

					flag = false
					break
				end

				if flag then
					unit = createVector(1, 0, 0)
				end
			end
		end
	end

	local v5 = rotateVectorAroundAxis(unit, previewUprightAxis, total * 0.3 + p) -- equivalent call inferred; original call site unknown
	model:PivotTo((getAlignedBoxCFrame(vector3, previewSourceAxes, vector4, previewUprightAxis, v5)))
	return unit
end

local function zoomCameraForPreview(object)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
	local v3 = CameraController.new(currentCamera, 1, 0.25)
	v3:SetCameraTarget(currentCamera.CFrame.Position + currentCamera.CFrame.LookVector * 12):Zoom(18)
	object:getMaid():GiveTask(function()
		v3:FadeOut(0.25)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function inputPosition(input)
	local position = input.Position
	return Vector2.new(position.X, position.Y)
end

local function isPositionOverPreview(currentCamera, point: Vector2)
	local viewportSize = currentCamera.ViewportSize

	if viewportSize.X <= 0 or viewportSize.Y <= 0 then
		return false
	end

	local vector3 = Vector2.new(vector2.X * viewportSize.X, vector2.Y * viewportSize.Y)
	local v3 = math.min(viewportSize.X, viewportSize.Y) * 0.55 * 0.5
	return math.abs(point.X - vector3.X) <= v3 and math.abs(point.Y - vector3.Y) <= v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeAngle(X: number)
	return (math.atan2(math.sin(X), (math.cos(X))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeManualRotation(vector3: Vector3)
	local angle = normalizeAngle(vector3.X) -- equivalent call inferred; original call site unknown
	local Z = vector3.Z
	return (Vector3.new(angle, 0, (math.atan2(math.sin(Z), (math.cos(Z))))))
end

local function showWeaponPreview(object, previewWeaponModel)
	local model = Instance.new("Model")
	model.Name = previewWeaponModel.Name
	local highlight = Instance.new("Highlight")
	highlight.Adornee = model
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = model
	local v3 = {}

	for _, v4 in getHoldablePreviewSources(previewWeaponModel) do
		local model2 = Instance.new("Model")
		model2.Name = v4.Name
		model2.Parent = model
		local clone = v4:Clone()
		clone.Parent = model2

		if preparePreviewModel(model2) then
			table.insert(v3, model2)
		else
			model2:Destroy()
		end
	end

	if #v3 == 0 then
		model:Destroy()
		return
	end

	for k, v4 in v3 do
		local count = #v3
		local v6

		if count <= 1 then
			v6 = 0.20943951023931956
		else
			local v7 = count == 2 and 0.5585053606381855 or 0.4886921905584123
			v6 = (k - (count + 1) * 0.5) * v7
		end

		pivotHoldableForPreview(v4, v6)
	end

	local boundingBox, v4 = model:GetBoundingBox()
	local previewSourceAxes, v5 = getPreviewSourceAxes(model, boundingBox, v4)
	model.WorldPivot = boundingBox
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local viewportSize = currentCamera.ViewportSize
		local v6, v7

		if not (viewportSize.X <= 0 or viewportSize.Y <= 0) then
			v7 = math.tan(math.rad(currentCamera.FieldOfView) * 0.5) * 6
			v6 = v7 * (viewportSize.X / viewportSize.Y)
		end

		local v8

		if v6 and v7 then
			local v9 = getPreviewSourceDistance(v4) * 1.5 * 0.3152987888789835
			v8 = math.max(math.min(0.42 * v6 / v9, 0.42 * v7 / v9), 0.001)
		end

		if v8 then
			model:ScaleTo(v8)
		end
	end

	zoomCameraForPreview(object)
	local total = 0
	local v6 = nil
	local v7 = nil
	local v8 = nil
	local v9 = false
	local v10 = nil
	local v11 = {}
	local v12 = 0
	local v13 = nil
	local total2 = 2
	local v14 = false
	local total3 = 0
	local v15 = Spring.new(1, 0.65, createVector(0, 0, 0))
	local v16 = Spring.new(1, 4, createVector(0, 0, 0))
	local maid = object:getMaid()

	local function isDraggingPreview()
		return v12 > 0 or v9
	end

	local function getTouchCenter()
		local zero = Vector2.zero
		local count = 0

		for _, v17 in v11 do
			zero += v17
			count += 1
		end

		if count == 0 then
			return nil
		end

		return zero / count
	end

	local function getSingleTouch()
		for k, v17 in v11 do
			return k, v17
		end

		return nil, nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function beginDrag(point: Vector2)
		v10 = point
		total2 = 0
		v14 = false
		v16:SetGoal(v16.p)
		v16.v = createVector(0, 0, 0)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function endDrag()
		v10 = nil
		v13 = nil
		total2 = 0
		v16:SetGoal(v16.p)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyDragDelta(point: Vector2)
		local v17 = Vector3.new(-point.Y, 0, -point.X) * 0.01
		local v18 = v16.p + v17
		v16.p = v18
		v16:SetGoal(v18)
		v16.v = Vector3.new(-point.Y, 0, -point.X) * 0.55
		total2 = 0
		v14 = false
	end

	local function applySpinVelocity(p: number, flag: boolean?)
		local vector3 = Vector3.new(0, p, 0)
		local v17 = v15

		if flag then
			vector3 = v15.p + vector3
		end

		v17.p = vector3
		v15:SetGoal(createVector(0, 0, 0))
		v15.v = createVector(0, 0, 0)
		total2 = 0
		v14 = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function beginTouchDrag(input, point: Vector2)
		if not v11[input] then
			v12 += 1
		end

		v11[input] = point

		if v12 == 1 then
			v8 = input
			v13 = nil
			beginDrag(point) -- equivalent call inferred; original call site unknown
		else
			v8 = nil
			v10 = nil
			local zero = Vector2.zero
			local count = 0

			for _, v17 in v11 do
				zero += v17
				count += 1
			end

			local v17

			if count ~= 0 then
				v17 = zero / count
			end

			v13 = v17
			beginDrag(v13 or point) -- equivalent call inferred; original call site unknown
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateTouchDrag(input, point: Vector2)
		if not v11[input] then
			return
		end

		v11[input] = point

		if v12 >= 2 then
			local zero = Vector2.zero
			local count = 0

			for _, v17 in v11 do
				zero += v17
				count += 1
			end

			local v17

			if count ~= 0 then
				v17 = zero / count
			end

			local v18 = v13
			v13 = v17

			if v17 and v18 then
				v15.p = Vector3.new(0, -(v17 - v18).Y * 0.55, 0)
				v15:SetGoal(createVector(0, 0, 0))
				v15.v = createVector(0, 0, 0)
				total2 = 0
				v14 = false
			end
		else
			if input ~= v8 then
				return
			end

			local v17 = v10
			v10 = point

			if v17 then
				applyDragDelta(point - v17) -- equivalent call inferred; original call site unknown
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function endTouchDrag(input)
		if not v11[input] then
			return
		end

		v11[input] = nil
		v12 -= 1

		if v12 >= 2 then
			local zero = Vector2.zero
			local count = 0

			for _, v17 in v11 do
				zero += v17
				count += 1
			end

			local v17

			if count ~= 0 then
				v17 = zero / count
			end

			v13 = v17
		elseif v12 == 1 then
			local v17 = nil
			local v18 = nil

			for k, v20 in v11 do
				v17, v18 = k, v20 -- parallel
				break
			end

			v8 = v17
			v13 = nil
			beginDrag(v18 or Vector2.zero) -- equivalent call inferred; original call site unknown
		else
			v8 = nil
			endDrag() -- equivalent call inferred; original call site unknown
		end
	end

	local function updateManualRotation(p: number?)
		if not p or (v12 > 0 or v9) then
			return v16.p
		end

		total2 += p

		if v14 or not (total2 >= 2) then
			return v16:Update(p)
		end

		v16.p = normalizeManualRotation(v16.p)
		v16:SetGoal(createVector(0, 0, 0))
		total3 = 0
		v15.p = createVector(0, 0, 0)
		v15.v = createVector(0, 0, 0)
		v15:SetGoal(createVector(0, 0, 0))
		v14 = true
		return v16:Update(p)
	end

	local function updateSpinAngle(p: number?)
		if not p then
			return total3
		end

		local v17 = v15:Update(p)
		total3 += v17.Y * p
		return total3
	end

	local function updatePreview(p: number?)
		local v17 = updateManualRotation(p)

		if p then
			local v18 = v15:Update(p)
			total3 += v18.Y * p
		end

		local v18 = total3
		local currentCamera2 = workspace.CurrentCamera

		if not currentCamera2 then
			return
		end

		local v19 = v4
		local viewportSize = currentCamera2.ViewportSize
		local v20, v21

		if not (viewportSize.X <= 0 or viewportSize.Y <= 0) then
			v21 = math.tan(math.rad(currentCamera2.FieldOfView) * 0.5) * 6
			v20 = v21 * (viewportSize.X / viewportSize.Y)
		end

		local v22

		if v20 and v21 then
			local v23 = getPreviewSourceDistance(v19) * 1.5 * 0.3152987888789835
			v22 = math.max(math.min(0.42 * v20 / v23, 0.42 * v21 / v23), 0.001)
		end

		local viewportSize2 = currentCamera2.ViewportSize
		local v23, v24

		if not (viewportSize2.X <= 0 or viewportSize2.Y <= 0) then
			v24 = math.tan(math.rad(currentCamera2.FieldOfView) * 0.5) * 6
			v23 = v24 * (viewportSize2.X / viewportSize2.Y)
		end

		local v25

		if v23 and v24 then
			local cFrame = currentCamera2.CFrame
			v25 = cFrame.Position + cFrame.RightVector * ((vector2.X - 0.5) * v23) + cFrame.UpVector * ((0.5 - vector2.Y) * v24) + cFrame.LookVector * 3
		end

		if not (v22 and v25) then
			return
		end

		if model.Parent ~= currentCamera2 then
			model.Parent = currentCamera2
		end

		if not v6 or math.abs(v6 - v22) > 0.001 then
			model:ScaleTo(v22)
			v6 = v22
		end

		v7 = pivotPreviewModel(model, currentCamera2, v25, previewSourceAxes, v5, v7, total, v17.X, v18, v17.Z)
	end

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local v17

		if input.UserInputType == Enum.UserInputType.Touch then
			v17 = v12 > 0
		else
			v17 = false
		end

		if gameProcessed and not v17 then
			return
		end

		local currentCamera2 = workspace.CurrentCamera

		if not (currentCamera2 and (v17 or isPositionOverPreview(currentCamera2, inputPosition(input)))) then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			v9 = true
			beginDrag(inputPosition(input)) -- equivalent call inferred; original call site unknown
		elseif input.UserInputType == Enum.UserInputType.Touch then
			local v18 = inputPosition(input)
			beginTouchDrag(input, v18) -- equivalent call inferred; original call site unknown
		end
	end))
	maid:GiveTask(UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			if gameProcessed then
				return
			end

			local currentCamera2 = workspace.CurrentCamera

			if not (currentCamera2 and isPositionOverPreview(currentCamera2, inputPosition(input))) then
				return
			end

			local vector3 = Vector3.new(0, input.Position.Z * 4, 0)
			v15.p += vector3
			v15:SetGoal(createVector(0, 0, 0))
			v15.v = createVector(0, 0, 0)
			total2 = 0
			v14 = false
		else
			local v17

			if input.UserInputType == Enum.UserInputType.MouseMovement then
				v17 = v9
			else
				v17 = false
			end

			local v18 = v11[input] ~= nil

			if gameProcessed and not (v17 or v18) or not (v17 or v18) then
				return
			end

			local v19 = inputPosition(input) -- equivalent call inferred; original call site unknown

			if v18 then
				updateTouchDrag(input, v19) -- equivalent call inferred; original call site unknown
			else
				local v20 = v10
				v10 = v19

				if v20 then
					applyDragDelta(v19 - v20) -- equivalent call inferred; original call site unknown
				end
			end
		end
	end))
	maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and v9 then
			v9 = false
			endDrag() -- equivalent call inferred; original call site unknown
		else
			if input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			endTouchDrag(input) -- equivalent call inferred; original call site unknown
		end
	end))
	updatePreview(nil)
	maid:GiveTask((RunService.RenderStepped:Connect(function(dt)
		total += dt
		updatePreview(dt)
	end)))
	maid:GiveTask(model)
end

local function itemPurchase(itemName: string, p2)
	local v3 = Shop.LEGACY_BELI_ITEMS[itemName]
	local v4 = "$" .. TextUtil.commaValue(v3.Price)
	local v5 = DialogueController.new()
	v5:setTitle(p2.Title)
	local previewWeaponModel = getPreviewWeaponModel(itemName)

	local function buyItemText()
		local v6, v7 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", itemName)

		if v6 == 1 then
			Util.playAction("Positive")
			return "[Item purchased.]"
		elseif v6 == 0 then
			Util.playAction("Negative")
			return "[Not enough Money.]"
		elseif v6 == 2 then
			Util.playAction("Explain")
			return "[You already own this item.]"
		end

		if v6 ~= 3 then
			return "..."
		end

		Util.playAction("Negative")
		return "[You need to be Level " .. v7 .. " to purchase this item.]"
	end

	require(game.ReplicatedStorage.Packages.React)
	return (v5:addPage(function(object)
		showWeaponPreview(object, previewWeaponModel)
		object:setTitle("Confirm Purchase")
		object:addText(v3.Description or "")
		object:setSubtitle(itemName)
		object:toggleSpecialReactComponent("ItemPurchaseSkillPreview", {
			itemName = itemName
		})
		object:addPurchaseOption(v4, "Purchase", function(object2)
			object2:jumpToPage(function(object3)
				object3:addText((buyItemText()))
				object3:advanceAfterDelay(1)
			end)
		end)
		object:addOptionType("Chat", function(object2)
			object2:setText("Return")
			object2:goBack()
		end)
	end):build())
end

return itemPurchase