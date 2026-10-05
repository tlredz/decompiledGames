local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Signal = require(packages.Signal)
local Trove = require(packages.Trove)
local assets = require(ReplicatedStorage.shared.utils.assets)
local SharedPlacement = require(ReplicatedStorage.shared.modules.SharedPersonalAquarium.SharedPlacement)
local NotificationController = require(ReplicatedStorage.client.legacyControllers.NotificationController)
local remoteEvent = Net:RemoteEvent("PersonalAquarium/Furniture/Place")
local remoteEvent2 = Net:RemoteEvent("PersonalAquarium/Furniture/Remove")
local remoteEvent3 = Net:RemoteEvent("PersonalAquarium/Furniture/Move")
local remoteEvent4 = Net:RemoteEvent("PersonalAquarium/Furniture/Rotate")
local remoteEvent5 = Net:RemoteEvent("PersonalAquarium/Furniture/Recolor")
local remoteEvent6 = Net:RemoteEvent("PersonalAquarium/Furniture/ResetColor")
local remoteEvent7 = Net:RemoteEvent("PersonalAquarium/Furniture/SetEditing")
local remoteEvent8 = Net:RemoteEvent("PersonalAquarium/Furniture/VisitorAquarium")
local color = Color3.fromRGB(80, 255, 120)
local color2 = Color3.fromRGB(255, 80, 80)
local color3 = Color3.fromRGB(80, 170, 255)
local color4 = Color3.fromRGB(235, 70, 60)
local color5 = Color3.fromRGB(45, 110, 245)
local color6 = Color3.fromRGB(90, 200, 90)
local color7 = Color3.fromRGB(227, 73, 75)
Color3.fromRGB(80, 255, 120)
Color3.fromRGB(255, 80, 80)
Color3.fromRGB(200, 80, 255)
Color3.fromRGB(255, 170, 60)
local localPlayer = Players.LocalPlayer
local v = nil
local FurnitureController = {
	IsEditing = false,
	CurrentMode = "Idle",
	CurrentTool = "Select",
	PlaceFurnitureId = nil,
	SelectedUid = nil,
	IsCursorOn = false,
	EditModeChanged = Signal.new(),
	ModeChanged = Signal.new(),
	ToolChanged = Signal.new(),
	SelectionChanged = Signal.new(),
	CursorModeChanged = Signal.new()
}
local maid = Trove.new()
local v2 = nil
local v3 = false
local v4 = createVector(0, 0, 0)
local v5 = createVector(0, 0, 0)
local v6 = nil
local v7 = false
local v8 = 0
local total = 0
local v9 = false
local count = 0
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local flag = false
local v16 = false
local v17 = 0
local v18 = nil
local v19 = nil
local pivot = nil
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = nil
local v24 = 0
local v25 = false
local fn
local fn2
local fn3
local fn4
local v26 = nil
local v27 = ""

local function debugFootprint(_: CFrame, _: Vector3, _: string) end

local function destroyDebugFootprint()
	if v26 then
		v26:Destroy()
		v26 = nil
	end

	v27 = ""
end

local function getOwnAquarium()
	local model = Workspace:FindFirstChild((tostring(localPlayer.UserId)))

	if not (model and model:IsA("Model")) then
		return nil, nil
	end

	local __furnitureorigin__ = model:FindFirstChild("__furnitureorigin__")

	if __furnitureorigin__ and __furnitureorigin__:IsA("BasePart") then
		return model, __furnitureorigin__
	end

	return nil, nil
end

local function raycastScreen(point: Vector2, list, flag2: boolean?)
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	local viewportPointToRay = currentCamera:ViewportPointToRay(point.X, point.Y)
	local filterDescendantsInstances = {}

	if localPlayer.Character then
		table.insert(filterDescendantsInstances, localPlayer.Character)
	end

	for _, v29 in ipairs(list) do
		if v29 then
			table.insert(filterDescendantsInstances, v29)
		end
	end

	if flag2 then
		local ownAquarium = getOwnAquarium()

		if ownAquarium then
			for _, v29 in ipairs(CollectionService:GetTagged("AquariumBlocker")) do
				if v29:IsDescendantOf(ownAquarium) then
					table.insert(filterDescendantsInstances, v29)
				end
			end
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	return Workspace:Raycast(viewportPointToRay.Origin, viewportPointToRay.Direction * 200, raycastParams)
end

local function raycastFloorAt(vector2: Vector3)
	local ownAquarium = getOwnAquarium()

	if not ownAquarium then
		return nil
	end

	local filterDescendantsInstances = {}
	local __placedfurniture__ = ownAquarium:FindFirstChild("__placedfurniture__")

	if __placedfurniture__ then
		table.insert(filterDescendantsInstances, __placedfurniture__)
	end

	if v2 then
		table.insert(filterDescendantsInstances, v2)
	end

	if localPlayer.Character then
		table.insert(filterDescendantsInstances, localPlayer.Character)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = Workspace:Raycast(vector2 + createVector(0, 2, 0), createVector(0, -52, 0), raycastParams)

	if not (raycastResult and raycastResult.Instance:IsDescendantOf(ownAquarium)) then
		return nil
	end

	if SharedPlacement.hasTagInAncestry(raycastResult.Instance, "AquariumFloor") then
		return raycastResult.Position
	end

	return nil
end

local function overlapsAt(vector2: Vector3, vector3: Vector3, p: number, p2)
	local ownAquarium, v28 = getOwnAquarium()

	if not (ownAquarium and v28) then
		return false
	end

	local __placedfurniture__ = ownAquarium:FindFirstChild("__placedfurniture__")
	local furnitureBox, v29 = SharedPlacement.getFurnitureBox(vector2, vector3, v28, p)

	if SharedPlacement.overlapsFurniture(__placedfurniture__, furnitureBox, v29, p2) or SharedPlacement.overlapsBlockers(
		ownAquarium,
		furnitureBox,
		v29
	) then
		return true
	end

	return false
end

local function isValidGhostSpot(vector2: Vector3, p: number)
	local _, v28 = getOwnAquarium()

	if not v28 then
		return false
	end

	return not (v28.CFrame:PointToObjectSpace(vector2).Magnitude > 250) and not overlapsAt(vector2, v4, p, nil)
end

local function findPlacedModelByUid(p: string)
	local ownAquarium = getOwnAquarium()

	if not ownAquarium then
		return nil
	end

	local __placedfurniture__ = ownAquarium:FindFirstChild("__placedfurniture__")

	if not __placedfurniture__ then
		return nil
	end

	for _, model in ipairs(__placedfurniture__:GetChildren()) do
		if model:IsA("Model") and model:GetAttribute("PlacedUid") == p then
			return model
		end
	end

	return nil
end

local function getPlacedModelFromHit(instance)
	local placedUid = instance:GetAttribute("PlacedUid")

	if typeof(placedUid) == "string" then
		return (findPlacedModelByUid(placedUid))
	end

	local model = instance:FindFirstAncestorOfClass("Model")

	while model do
		if model:GetAttribute("PlacedUid") then
			return model
		else
			model = model:FindFirstAncestorOfClass("Model")
		end
	end

	return nil
end

local function findPlacedModelNear(position: Vector3)
	local ownAquarium = getOwnAquarium()

	if not ownAquarium then
		return nil
	end

	local __placedfurniture__ = ownAquarium:FindFirstChild("__placedfurniture__")

	if not __placedfurniture__ then
		return nil
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { __placedfurniture__ }
	local partBoundsInRadius = Workspace:GetPartBoundsInRadius(position, 2, overlapParams)
	local v28 = 1e999
	local v29 = nil

	for _, v30 in ipairs(partBoundsInRadius) do
		local placedModelFromHit = getPlacedModelFromHit(v30)

		if not placedModelFromHit then
			continue
		end

		local magnitude = (v30.Position - position).Magnitude

		if not (magnitude < v28) then
			continue
		end

		v29 = placedModelFromHit
		v28 = magnitude
	end

	return v29
end

local function raycastPlacedFurniture(point: Vector2)
	local ownAquarium = getOwnAquarium()

	if not ownAquarium then
		return nil
	end

	local __placedfurniture__ = ownAquarium:FindFirstChild("__placedfurniture__")

	if not __placedfurniture__ then
		return nil
	end

	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	local viewportPointToRay = currentCamera:ViewportPointToRay(point.X, point.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { __placedfurniture__ }
	local raycastResult = Workspace:Raycast(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * 200,
		raycastParams
	)

	if raycastResult then
		return (getPlacedModelFromHit(raycastResult.Instance))
	end

	return nil
end

local function findPlacedModelByScreen(point: Vector2)
	local ownAquarium = getOwnAquarium()

	if not ownAquarium then
		return nil
	end

	local __placedfurniture__ = ownAquarium:FindFirstChild("__placedfurniture__")

	if not __placedfurniture__ then
		return nil
	end

	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	local v28 = 60
	local v29 = nil

	for _, part in ipairs(__placedfurniture__:GetChildren()) do
		if not (part:IsA("BasePart") and part.Name == "__clickbox__") then
			continue
		end

		local worldToViewportPoint, v30 = currentCamera:WorldToViewportPoint(part.Position)

		if not v30 then
			continue
		end

		local magnitude = (Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y) - point).Magnitude

		if not (magnitude < v28) then
			continue
		end

		local placedUid = part:GetAttribute("PlacedUid")

		if typeof(placedUid) ~= "string" then
			continue
		end

		local placedModelByUid = findPlacedModelByUid(placedUid)

		if not placedModelByUid then
			continue
		end

		v29 = placedModelByUid
		v28 = magnitude
	end

	return v29
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOriginSpaceRotY(placedModelByUid, p)
	local _, v28 = p.CFrame:ToObjectSpace(placedModelByUid:GetPivot()):ToEulerAnglesYXZ()
	return v28
end

local function tintModel(folder, color8: Color3)
	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Color = color8
		end
	end
end

local function prepareGhost(folder)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false

		if part.Transparency < 1 then
			part.Transparency = 0.5
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function commitSelectedRotation(selectedUid: string, p: number)
	remoteEvent4:FireServer(selectedUid, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearSelection()
	if v11 and FurnitureController.SelectedUid then
		commitSelectedRotation(FurnitureController.SelectedUid, v11) -- equivalent call inferred; original call site unknown
	end

	v11 = nil

	if v10 then
		v10:Destroy()
		v10 = nil
	end

	if FurnitureController.SelectedUid then
		FurnitureController.SelectedUid = nil
		FurnitureController.SelectionChanged:Fire(nil)
	end

	fn2()
end

local function selectModel(instance)
	clearSelection() -- equivalent call inferred; original call site unknown
	local placedUid = instance:GetAttribute("PlacedUid")

	if typeof(placedUid) ~= "string" then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = color3
	highlight.FillTransparency = 0.7
	highlight.OutlineColor = color3
	highlight.Adornee = instance
	highlight.Parent = instance
	v10 = highlight
	FurnitureController.SelectedUid = placedUid
	FurnitureController.SelectionChanged:Fire(placedUid)
	fn()
end

local function destroyGhost()
	count += 1
	v3 = false
	v6 = nil

	if v2 then
		v2:Destroy()
		v2 = nil
	end

	for _, model in ipairs(Workspace:GetChildren()) do
		if model:IsA("Model") and model.Name == "__furnitureghost__" then
			model:Destroy()
		end
	end

	v9 = false
end

local function createGhost(placeFurnitureId: string)
	destroyGhost()
	local v28 = count
	local async = assets.getAsync("personalAquariumFurniture", placeFurnitureId)

	if not (async and async:IsA("Model")) then
		NotificationController:Notify(`Couldn't find furniture ID: '{placeFurnitureId}' in models`, 5)
		return false
	end

	if v28 ~= count or not FurnitureController.IsEditing then
		return false
	end

	local clone = async:Clone()
	clone.Name = "__furnitureghost__"
	prepareGhost(clone)
	local boundingBox, size = clone:GetBoundingBox()
	v4 = size
	local part = Instance.new("Part")
	part.Name = "__clickbox__"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = true
	part.Transparency = 1
	part.Size = size
	part.CFrame = boundingBox
	part.Parent = clone
	clone.Parent = Workspace
	v2 = clone
	return true
end

local function updateSelectedRotation(p: number)
	local v28 = v11
	local selectedUid = FurnitureController.SelectedUid

	if not (v28 and selectedUid) then
		return
	end

	local placedModelByUid = findPlacedModelByUid(selectedUid)
	local _, v29 = getOwnAquarium()

	if not (placedModelByUid and v29) then
		v11 = nil
		return
	end

	local originSpaceRotY = getOriginSpaceRotY(placedModelByUid, v29) -- equivalent call inferred; original call site unknown
	local v30 = (v28 - originSpaceRotY + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
	local v31 = v29.CFrame - v29.CFrame.Position
	local position = placedModelByUid:GetPivot().Position

	if math.abs(v30) < 0.008726646259971648 then
		placedModelByUid:PivotTo(CFrame.new(position) * v31 * CFrame.Angles(0, v28, 0))

		if not v16 then
			v11 = nil
			commitSelectedRotation(selectedUid, v28) -- equivalent call inferred; original call site unknown
		end
	else
		local v32 = originSpaceRotY + v30 * math.min(1, p * 14)
		placedModelByUid:PivotTo(CFrame.new(position) * v31 * CFrame.Angles(0, v32, 0))
	end
end

local function updatePlacedDrag(p: number)
	local v28 = pivot
	local v29 = v20
	local v30 = v21

	if not v28 or not v29 or not v30 or v30 == v2 then
		return
	end

	local position = v30:GetPivot().Position
	local v31 = position + (v29 - position) * math.min(1, p * 18)
	v30:PivotTo(CFrame.new(v31) * (v28 - v28.Position))
end

local function updatePlacedBodyDrag()
	if not v25 then
		local v28 = v23

		if not (v28 and v22) or pivot or os.clock() < v24 then
			return
		end

		if (UserInputService:GetMouseLocation() - v28).Magnitude <= 6 then
			return
		else
			fn4()
		end
	end

	local v28 = v21

	if not (v28 and pivot and v28.Parent) then
		return
	end

	local v30 = raycastScreen(UserInputService:GetMouseLocation(), { v28 }, true)

	if not v30 then
		return
	end

	local v31 = raycastFloorAt(v30.Position + createVector(0, 1, 0))

	if not v31 then
		return
	end

	local _, v32 = v28:GetBoundingBox()
	local _, v33 = getOwnAquarium()
	local v34

	if v33 then
		local v35
		v35, v34 = v33.CFrame:ToObjectSpace(v28:GetPivot()):ToEulerAnglesYXZ()
	else
		v34 = 0
	end

	if not overlapsAt(v31, v32, v34, v28) then
		v20 = v31
	end
end

local function updateGhostBodyDrag()
	local v28 = v2

	if not (v3 and v28) then
		return
	end

	if pivot then
		v3 = false
		return
	end

	local v29 = raycastScreen(UserInputService:GetMouseLocation(), { v28 }, true)

	if not v29 then
		return
	end

	local v30 = raycastFloorAt(v29.Position + createVector(0, 1, 0))

	if v30 then
		local v31 = v8
		local _, v32 = getOwnAquarium()
		local v33

		if v32 and not (v32.CFrame:PointToObjectSpace(v30).Magnitude > 250) then
			v33 = not overlapsAt(v30, v4, v31, nil)
		else
			v33 = false
		end

		if v33 then
			v5 = v30
			v7 = true
			v9 = true
		end
	end
end

local function updateGhost(p: number)
	fn3()
	updateSelectedRotation(p)
	updatePlacedBodyDrag()
	updatePlacedDrag(p)
	updateGhostBodyDrag()
	local v28 = v2

	if not v28 then
		return
	end

	local v29 = (v8 - total + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
	total += v29 * math.min(1, p * 14)
	local v30 = v6 or v5
	local v31 = v30 + (v5 - v30) * math.min(1, p * 18)
	v6 = v31
	local _, v32 = getOwnAquarium()
	local v33

	if v32 then
		v33 = v32.CFrame - v32.CFrame.Position
	else
		v33 = CFrame.identity
	end

	v28:PivotTo(CFrame.new(v31) * v33 * CFrame.Angles(0, total, 0))
	local v35

	if v9 then
		v35 = color
	else
		v35 = color2
	end

	tintModel(v28, v35)
end

local function setGhostPosition(spawnSpotNearPlayer: Vector3, flag2: boolean)
	v5 = spawnSpotNearPlayer
	v7 = flag2

	if flag2 then
		local v28 = v8
		local _, v29 = getOwnAquarium()
		local v30

		if v29 and not (v29.CFrame:PointToObjectSpace(spawnSpotNearPlayer).Magnitude > 250) then
			v30 = not overlapsAt(spawnSpotNearPlayer, v4, v28, nil)
		else
			v30 = false
		end

		v9 = v30
	else
		v9 = false
		local _, v28 = getOwnAquarium()

		if v28 then
			local _, _ = SharedPlacement.getFurnitureBox(spawnSpotNearPlayer, v4, v28, v8)
		end
	end

	fn()
end

local function findSpawnSpotNearPlayer()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return nil, false
	end

	local position = humanoidRootPart.Position
	local lookVector = humanoidRootPart.CFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

	local function isFreeSpot(vector3: Vector3?)
		local v28

		if vector3 == nil then
			v28 = false
			return false
		end

		local v29 = v8
		local _, v30 = getOwnAquarium()

		if not v30 then
			return false
		end

		return not (v30.CFrame:PointToObjectSpace(vector3).Magnitude > 250) and not overlapsAt(vector3, v4, v29, nil)
	end

	if vector2.Magnitude > 0.001 then
		local v28 = raycastFloorAt(position + vector2.Unit * 5)
		local v29

		if v28 == nil then
			v29 = false
		else
			local v30 = v8
			local _, v31 = getOwnAquarium()

			if v31 and not (v31.CFrame:PointToObjectSpace(v28).Magnitude > 250) then
				v29 = not overlapsAt(v28, v4, v30, nil)
			else
				v29 = false
			end
		end

		if v29 then
			return v28, true
		end
	end

	for i = 0, 7 do
		local v28 = i * 3.141592653589793 / 4
		local v30 = raycastFloorAt(position + Vector3.new(math.cos(v28), 0, (math.sin(v28))) * 5)
		local v31

		if v30 == nil then
			v31 = false
		else
			local v32 = v8
			local _, v33 = getOwnAquarium()

			if v33 and not (v33.CFrame:PointToObjectSpace(v30).Magnitude > 250) then
				v31 = not overlapsAt(v30, v4, v32, nil)
			else
				v31 = false
			end
		end

		if v31 then
			return v30, true
		end
	end

	local v28 = raycastFloorAt(position)

	if v28 then
		return v28, true
	end

	return position - createVector(0, 2, 0), false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setMode(currentMode: string)
	if FurnitureController.CurrentMode == currentMode then
		return
	end

	FurnitureController.CurrentMode = currentMode
	FurnitureController.ModeChanged:Fire(currentMode)
	fn()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lockCameraForGizmo()
	if flag then
		return
	end

	flag = true
	ContextActionService:BindActionAtPriority("FurnitureGizmoCameraLock", function()
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.Touch)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unlockCameraForGizmo()
	if not flag then
		return
	end

	flag = false
	ContextActionService:UnbindAction("FurnitureGizmoCameraLock")
end

fn2 = function()
	unlockCameraForGizmo() -- equivalent call inferred; original call site unknown

	if v12 then
		v12:Destroy()
		v12 = nil
	end

	if v13 then
		v13:Destroy()
		v13 = nil
	end

	if v14 then
		v14:Destroy()
		v14 = nil
	end

	v16 = false

	if v18 then
		v18:Destroy()
		v18 = nil
	end

	v19 = nil
	v15 = nil
	pivot = nil
	v20 = nil
	v21 = nil
end

fn3 = function()
	local v28 = v18
	local v29 = v19

	if not (v28 and v29 and v29.Parent) then
		return
	end

	local boundingBox, v30 = v29:GetBoundingBox()
	v28.CFrame = boundingBox
	v28.Size = v30 * 1.35
end

local function commitSelectedPosition()
	local selectedUid = FurnitureController.SelectedUid

	if not selectedUid then
		return
	end

	local placedModelByUid = findPlacedModelByUid(selectedUid)

	if not placedModelByUid then
		return
	end

	local _, v28 = getOwnAquarium()

	if not v28 then
		return
	end

	local pivot2 = placedModelByUid:GetPivot()
	local pointToObjectSpace = v28.CFrame:PointToObjectSpace(pivot2.Position)
	local originSpaceRotY = getOriginSpaceRotY(placedModelByUid, v28) -- equivalent call inferred; original call site unknown
	remoteEvent3:FireServer(
		selectedUid,
		pointToObjectSpace.X,
		pointToObjectSpace.Y,
		pointToObjectSpace.Z,
		originSpaceRotY
	)
end

local function onHandleDrag(p, p2: number)
	if p == Enum.NormalId.Top or p == Enum.NormalId.Bottom then
		return
	end

	local cframe = pivot

	if not cframe then
		return
	end

	local v28 = v19

	if not v28 then
		return
	end

	local vectorToWorldSpace = cframe:VectorToWorldSpace(Vector3.FromNormalId(p))
	local vector2 = Vector3.new(vectorToWorldSpace.X, 0, vectorToWorldSpace.Z)

	if vector2.Magnitude < 0.001 then
		return
	end

	local unit = vector2.Unit
	local v30 = raycastFloorAt(cframe.Position + unit * p2)

	if not v30 then
		return
	end

	if v28 == v2 then
		local v31 = v8
		local _, v32 = getOwnAquarium()
		local v33

		if v32 and not (v32.CFrame:PointToObjectSpace(v30).Magnitude > 250) then
			v33 = not overlapsAt(v30, v4, v31, nil)
		else
			v33 = false
		end

		if not v33 then
			return
		end

		v5 = v30
		v7 = true
		v9 = true
	else
		local _, v31 = v28:GetBoundingBox()
		local _, v32 = getOwnAquarium()
		local v33

		if v32 then
			local v34
			v34, v33 = v32.CFrame:ToObjectSpace(v28:GetPivot()):ToEulerAnglesYXZ()
		else
			v33 = 0
		end

		if overlapsAt(v30, v31, v33, v28) then
			return
		end

		v20 = v30
	end
end

local function createAxisHandles(color8: Color3, faces, part, instance)
	local handles = Instance.new("Handles")
	handles.Style = Enum.HandlesStyle.Movement
	handles.Color3 = color8
	handles.Faces = faces
	handles.Adornee = part
	handles.Parent = localPlayer:WaitForChild("PlayerGui")
	handles.MouseButton1Down:Connect(function()
		pivot = instance:GetPivot()

		if instance ~= v2 then
			v21 = instance
		end

		lockCameraForGizmo() -- equivalent call inferred; original call site unknown
	end)
	handles.MouseDrag:Connect(onHandleDrag)
	handles.MouseButton1Up:Connect(function()
		local v28 = pivot
		local v29 = v20
		pivot = nil
		v20 = nil
		v21 = nil
		unlockCameraForGizmo() -- equivalent call inferred; original call site unknown

		if instance ~= v2 then
			if v28 and v29 then
				instance:PivotTo(CFrame.new(v29) * (v28 - v28.Position))
			end

			commitSelectedPosition()
		end
	end)
	return handles
end

local function createRotationRing(part, instance)
	local arcHandles = Instance.new("ArcHandles")
	arcHandles.Axes = Axes.new(Enum.Axis.Y)
	arcHandles.Color3 = color6
	arcHandles.Adornee = part
	arcHandles.Parent = localPlayer:WaitForChild("PlayerGui")
	arcHandles.MouseButton1Down:Connect(function()
		v16 = true
		lockCameraForGizmo() -- equivalent call inferred; original call site unknown

		if instance == v2 then
			v17 = v8
			return
		end

		local _, v28 = getOwnAquarium()

		if v28 then
			local v29 = v11

			if not v29 then
				local v31
				v31, v29 = v28.CFrame:ToObjectSpace(instance:GetPivot()):ToEulerAnglesYXZ()
			end

			v17 = v29
		end
	end)
	arcHandles.MouseDrag:Connect(function(p, p2: number)
		if p ~= Enum.Axis.Y or not v16 then
			return
		end

		local v28 = math.round((v17 + p2) / 0.2617993877991494) * 0.2617993877991494 % 6.283185307179586

		if instance == v2 then
			if v7 then
				local v29 = v5
				local _, v30 = getOwnAquarium()
				local v31

				if v30 and not (v30.CFrame:PointToObjectSpace(v29).Magnitude > 250) then
					v31 = not overlapsAt(v29, v4, v28, nil)
				else
					v31 = false
				end

				if not v31 then
					return
				end
			end

			v8 = v28
		else
			local _, v29 = instance:GetBoundingBox()

			if not overlapsAt(instance:GetPivot().Position, v29, v28, instance) then
				v11 = v28
			end
		end
	end)
	arcHandles.MouseButton1Up:Connect(function()
		v16 = false
		unlockCameraForGizmo() -- equivalent call inferred; original call site unknown
	end)
	return arcHandles
end

fn = function()
	local currentTool = FurnitureController.CurrentTool
	local v28 = nil

	if currentTool == "Move" or currentTool == "Rotate" then
		if FurnitureController.CurrentMode == "Placing" then
			v28 = v2
		elseif FurnitureController.IsEditing and FurnitureController.CurrentMode == "Idle" and FurnitureController.SelectedUid then
			v28 = findPlacedModelByUid(FurnitureController.SelectedUid)
		end
	end

	if not v28 then
		fn2()
		return
	end

	if v19 == v28 and v15 == currentTool and v18 and v18.Parent then
		return
	end

	fn2()
	local boundingBox, v29 = v28:GetBoundingBox()
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = v29 * 1.35
	part.CFrame = boundingBox
	part.Parent = Workspace
	v18 = part
	v19 = v28
	v15 = currentTool

	if currentTool ~= "Move" then
		v14 = createRotationRing(part, v28)
		return
	end

	v12 = createAxisHandles(color4, Faces.new(Enum.NormalId.Left, Enum.NormalId.Right), part, v28)
	v13 = createAxisHandles(color5, Faces.new(Enum.NormalId.Front, Enum.NormalId.Back), part, v28)
end

local function gamepadQuickRotate(p: number)
	if FurnitureController.CurrentMode == "Placing" then
		if not v2 then
			return
		end

		local v28 = (v8 + p * 0.2617993877991494) % 6.283185307179586

		if v7 then
			local v29 = v5
			local _, v30 = getOwnAquarium()
			local v31

			if v30 and not (v30.CFrame:PointToObjectSpace(v29).Magnitude > 250) then
				v31 = not overlapsAt(v29, v4, v28, nil)
			else
				v31 = false
			end

			if v31 then
				v8 = v28
			end
		else
			v8 = v28
		end
	else
		if FurnitureController.CurrentMode ~= "Idle" then
			return
		end

		local selectedUid = FurnitureController.SelectedUid

		if not selectedUid then
			return
		end

		local placedModelByUid = findPlacedModelByUid(selectedUid)
		local _, v28 = getOwnAquarium()

		if not (placedModelByUid and v28) then
			return
		end

		local v29 = v11

		if not v29 then
			local v30
			v30, v29 = v28.CFrame:ToObjectSpace(placedModelByUid:GetPivot()):ToEulerAnglesYXZ()
		end

		local v30 = (v29 + p * 0.2617993877991494) % 6.283185307179586
		local _, v31 = placedModelByUid:GetBoundingBox()

		if overlapsAt(placedModelByUid:GetPivot().Position, v31, v30, placedModelByUid) then
			return
		end

		v11 = v30
	end
end

local function onPointerActivate(point: Vector2)
	if FurnitureController.CurrentMode == "Idle" then
		local v28 = raycastPlacedFurniture(point)

		if not v28 then
			local v29 = raycastScreen(point, {}, true)

			if v29 then
				v28 = getPlacedModelFromHit(v29.Instance) or findPlacedModelNear(v29.Position)
			end
		end

		local v29 = v28 or findPlacedModelByScreen(point)

		if v29 then
			selectModel(v29)
		elseif FurnitureController.CurrentTool == "Select" then
			clearSelection() -- equivalent call inferred; original call site unknown
		end
	end
end

local function onInputBegan(p, flag2: boolean)
	if flag2 then
		return
	end

	if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
		onPointerActivate(Vector2.new(p.Position.X, p.Position.Y))
	end
end

local function beginPendingPlacedDrag(point: Vector2)
	if FurnitureController.CurrentMode ~= "Idle" or FurnitureController.CurrentTool ~= "Select" then
		return false
	end

	local v28 = raycastPlacedFurniture(point)

	if not v28 then
		local v29 = raycastScreen(point, {}, true)

		if v29 then
			v28 = getPlacedModelFromHit(v29.Instance) or findPlacedModelNear(v29.Position)
		end
	end

	local v29 = v28 or findPlacedModelByScreen(point)

	if not v29 then
		return false
	end

	if v29:GetAttribute("PlacedUid") ~= FurnitureController.SelectedUid then
		selectModel(v29)
		v24 = os.clock() + 0.5
	end

	v22 = v29
	v23 = point
	return true
end

fn4 = function()
	local v28 = v22

	if not v28 then
		return
	end

	v25 = true
	v21 = v28
	pivot = v28:GetPivot()
	v20 = nil
	lockCameraForGizmo() -- equivalent call inferred; original call site unknown
end

local function endPlacedDrag()
	local v28 = v25
	local v29 = v21
	local v30 = pivot
	local v31 = v20
	v22 = nil
	v23 = nil
	v25 = false

	if not v28 then
		return false
	end

	pivot = nil
	v20 = nil
	v21 = nil
	unlockCameraForGizmo() -- equivalent call inferred; original call site unknown

	if v29 and v30 and v31 then
		v29:PivotTo(CFrame.new(v31) * (v30 - v30.Position))
	end

	commitSelectedPosition()
	return true
end

function FurnitureController.ConfirmGhost()
	if not (FurnitureController.CurrentMode == "Placing" and v9) then
		return
	end

	local placeFurnitureId = FurnitureController.PlaceFurnitureId

	if not placeFurnitureId then
		return
	end

	local _, v28 = getOwnAquarium()

	if not v28 then
		return
	end

	local pointToObjectSpace = v28.CFrame:PointToObjectSpace(v5)
	remoteEvent:FireServer(placeFurnitureId, pointToObjectSpace.X, pointToObjectSpace.Y, pointToObjectSpace.Z, v8)

	for i = 0, 7 do
		local v29 = i * 3.141592653589793 / 4
		local v30 = Vector3.new(math.cos(v29), 0, (math.sin(v29))) * 5
		local v31 = raycastFloorAt(v5 + v30)

		if not v31 then
			continue
		end

		local v32 = v8
		local _, v33 = getOwnAquarium()
		local v34

		if v33 and not (v33.CFrame:PointToObjectSpace(v31).Magnitude > 250) then
			v34 = not overlapsAt(v31, v4, v32, nil)
		else
			v34 = false
		end

		if not v34 then
			continue
		end

		v5 = v31
		v7 = true
		local v35 = v8
		local _, v36 = getOwnAquarium()
		local v37

		if v36 and not (v36.CFrame:PointToObjectSpace(v31).Magnitude > 250) then
			v37 = not overlapsAt(v31, v4, v35, nil)
		else
			v37 = false
		end

		v9 = v37
		fn()
		break
	end
end

function FurnitureController.StartPlacing(placeFurnitureId: string)
	if not FurnitureController.IsEditing then
		return
	end

	clearSelection() -- equivalent call inferred; original call site unknown
	FurnitureController.PlaceFurnitureId = placeFurnitureId
	v8 = 0
	total = 0
	local spawnSpotNearPlayer, v28 = findSpawnSpotNearPlayer()

	if not spawnSpotNearPlayer then
		return
	end

	if createGhost(placeFurnitureId) then
		if FurnitureController.CurrentTool == "Select" then
			FurnitureController.SetTool("Move")
		end

		setGhostPosition(spawnSpotNearPlayer, v28)
		setMode("Placing") -- equivalent call inferred; original call site unknown
	end
end

function FurnitureController.CancelPlacing()
	if FurnitureController.CurrentMode == "Placing" then
		destroyGhost()
		setMode("Idle") -- equivalent call inferred; original call site unknown
	end
end

function FurnitureController.SetTool(currentTool: string)
	if FurnitureController.CurrentTool == currentTool then
		fn()
		return
	end

	FurnitureController.CurrentTool = currentTool
	FurnitureController.ToolChanged:Fire(currentTool)
	fn()
end

function FurnitureController.RemoveSelected()
	local selectedUid = FurnitureController.SelectedUid

	if not selectedUid or FurnitureController.CurrentMode ~= "Idle" then
		return
	end

	remoteEvent2:FireServer(selectedUid)
	clearSelection() -- equivalent call inferred; original call site unknown
end

function FurnitureController.ResetColor()
	local selectedUid = FurnitureController.SelectedUid

	if not selectedUid or FurnitureController.CurrentMode ~= "Idle" then
		return
	end

	local placedModelByUid = findPlacedModelByUid(selectedUid)
	remoteEvent6:FireServer(selectedUid)
	task.spawn(function()
		for _ = 1, 20 do
			task.wait(0.1)

			if FurnitureController.SelectedUid ~= selectedUid then
				break
			end

			local placedModelByUid2 = findPlacedModelByUid(selectedUid)

			if not (placedModelByUid2 and placedModelByUid2 ~= placedModelByUid) then
				continue
			end

			selectModel(placedModelByUid2)
			break
		end
	end)
end

function FurnitureController.RecolorUid(value: string, p: number, p2: number, p3: number)
	if typeof(value) ~= "string" then
		return
	end

	remoteEvent5:FireServer(value, p, p2, p3)
end

function FurnitureController.Recolor(p: number, p2: number, p3: number)
	local selectedUid = FurnitureController.SelectedUid

	if not selectedUid then
		return
	end

	FurnitureController.RecolorUid(selectedUid, p, p2, p3)
end

function FurnitureController.EnterEditMode()
	if FurnitureController.IsEditing or not getOwnAquarium() then
		return
	end

	FurnitureController.IsEditing = true
	FurnitureController.CurrentMode = "Idle"
	FurnitureController.CurrentTool = "Select"
	FurnitureController.ToolChanged:Fire("Select")
	maid:Connect(UserInputService.InputBegan, onInputBegan)
	maid:Connect(UserInputService.InputEnded, function(p)
		if p.UserInputType == Enum.UserInputType.Touch or p.UserInputType == Enum.UserInputType.MouseButton1 then
			unlockCameraForGizmo() -- equivalent call inferred; original call site unknown
		end
	end)
	maid:Connect(RunService.RenderStepped, updateGhost)
	ContextActionService:BindActionAtPriority("FurnitureGhostDrag", function(_, p)
		if p == Enum.UserInputState.Begin then
			local v28 = v2

			if FurnitureController.CurrentMode ~= "Placing" or not v28 or pivot then
				return Enum.ContextActionResult.Pass
			end

			local v29 = raycastScreen(UserInputService:GetMouseLocation(), {})

			if v29 and v29.Instance:IsDescendantOf(v28) then
				v3 = true
				return Enum.ContextActionResult.Sink
			else
				return Enum.ContextActionResult.Pass
			end
		else
			if not (p == Enum.UserInputState.End and v3) then
				return Enum.ContextActionResult.Pass
			end

			v3 = false
			return Enum.ContextActionResult.Sink
		end
	end, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)
	maid:Add(function()
		ContextActionService:UnbindAction("FurnitureGhostDrag")
	end)
	ContextActionService:BindActionAtPriority("FurniturePlacedDrag", function(_, p, p2)
		if p == Enum.UserInputState.Begin then
			if pivot or FurnitureController.CurrentMode ~= "Idle" then
				return Enum.ContextActionResult.Pass
			end

			if beginPendingPlacedDrag(Vector2.new(p2.Position.X, p2.Position.Y)) then
				return Enum.ContextActionResult.Sink
			end
		else
			if p ~= Enum.UserInputState.End then
				return Enum.ContextActionResult.Pass
			end

			if endPlacedDrag() then
				return Enum.ContextActionResult.Sink
			end
		end

		return Enum.ContextActionResult.Pass
	end, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)
	maid:Add(function()
		ContextActionService:UnbindAction("FurniturePlacedDrag")
		v22 = nil
		v23 = nil
		v25 = false
	end)
	ContextActionService:BindActionAtPriority("FurnitureQuickRotate", function(_, p, p2)
		if p ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		local v28 = FurnitureController.CurrentMode == "Placing"
		local v29

		if FurnitureController.CurrentMode == "Idle" then
			v29 = FurnitureController.SelectedUid ~= nil
		else
			v29 = false
		end

		if v28 or v29 then
			gamepadQuickRotate(p2.KeyCode == Enum.KeyCode.ButtonR1 and 1 or -1)
			return Enum.ContextActionResult.Sink
		else
			return Enum.ContextActionResult.Pass
		end
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1)
	maid:Add(function()
		ContextActionService:UnbindAction("FurnitureQuickRotate")
	end)
	maid:Add(destroyGhost)
	maid:Add(clearSelection)
	maid:Add(fn2)
	maid:Add(destroyDebugFootprint)
	remoteEvent7:FireServer(true)
	FurnitureController.EditModeChanged:Fire(true)
end

function FurnitureController.ExitEditMode()
	if not FurnitureController.IsEditing then
		return
	end

	FurnitureController.IsEditing = false
	maid:Clean()
	FurnitureController.CurrentMode = "Idle"
	remoteEvent7:FireServer(false)
	FurnitureController.EditModeChanged:Fire(false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isInOwnAquarium()
	return v == tostring(localPlayer.UserId) and getOwnAquarium() ~= nil
end

local v28 = false
local v29 = false
local v30 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function applyCursorState()
	local isCursorOn = v29 and not v30

	if isCursorOn == v28 then
		return
	end

	v28 = isCursorOn
	FurnitureController.IsCursorOn = isCursorOn

	if isCursorOn then
		GamepadService:EnableGamepadCursor(nil)
	else
		GamepadService:DisableGamepadCursor()
	end

	FurnitureController.CursorModeChanged:Fire(isCursorOn)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setVirtualCursor(isEditing: boolean)
	v29 = isEditing
	v30 = true
	applyCursorState() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleCursorForCamera()
	if not v29 then
		return
	end

	v30 = not v30
	applyCursorState() -- equivalent call inferred; original call site unknown
end

local function reassertCursor()
	if not v28 then
		return
	end

	GamepadService:EnableGamepadCursor(nil)
end

local function initCustomizeButton()
	local personalAquariumCustomize = localPlayer:WaitForChild("PlayerGui"):WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("personalAquariumCustomize")
	local textLabel

	if personalAquariumCustomize:IsA("TextButton") then
		textLabel = personalAquariumCustomize
	else
		textLabel = personalAquariumCustomize:FindFirstChildWhichIsA("TextLabel")
	end

	local text = textLabel.Text
	local textColor3 = textLabel.TextColor3

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateState()
		personalAquariumCustomize.Visible = isInOwnAquarium() or FurnitureController.IsEditing
		setVirtualCursor(FurnitureController.IsEditing) -- equivalent call inferred; original call site unknown

		if FurnitureController.IsEditing then
			textLabel.Text = "Exit"
			textLabel.TextColor3 = color7
		else
			textLabel.Text = text
			textLabel.TextColor3 = textColor3
		end
	end

	personalAquariumCustomize.Activated:Connect(function()
		if FurnitureController.IsEditing then
			FurnitureController.ExitEditMode()
		else
			FurnitureController.EnterEditMode()
		end

		updateState() -- equivalent call inferred; original call site unknown
	end)
	FurnitureController.EditModeChanged:Connect(updateState)
	remoteEvent8.OnClientEvent:Connect(function(value: string)
		if typeof(value) ~= "string" then
			value = nil
		end

		v = value
		updateState() -- equivalent call inferred; original call site unknown
	end)
	local success, result = pcall(function()
		local WindowController = require(ReplicatedStorage.client.legacyControllers.WindowController)
		return WindowController
	end)

	if success and result and result.WindowClosed then
		result.WindowClosed:Connect(function()
			task.defer(reassertCursor)
		end)
	end

	ContextActionService:BindActionAtPriority("FurnitureCursorToggle", function(_, p)
		if p ~= Enum.UserInputState.Begin or not FurnitureController.IsEditing or not v29 or success and result and result.CurrentWindow then
			return Enum.ContextActionResult.Pass
		end

		toggleCursorForCamera() -- equivalent call inferred; original call site unknown
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonY)
	local PersonalAquariumController = require(ReplicatedStorage.client.legacyControllers.PersonalAquariumController)

	while not PersonalAquariumController.LocalPlayerInAquarium do
		task.wait(0.1)
	end

	PersonalAquariumController.LocalPlayerInAquarium:observe(function(flag2: boolean)
		if not flag2 then
			v = nil

			if FurnitureController.IsEditing then
				FurnitureController.ExitEditMode()
			end
		end

		updateState() -- equivalent call inferred; original call site unknown
	end)
	updateState() -- equivalent call inferred; original call site unknown
end

function FurnitureController.Start()
	task.spawn(initCustomizeButton)
end

return FurnitureController