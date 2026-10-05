local createVector = vector.create
local Signal = require(script:WaitForChild("Signal"))
local BoxSelection = require(script:WaitForChild("BoxSelection"))
local localPlayer = game.Players.LocalPlayer
local models = game.ReplicatedStorage:WaitForChild("Prefabs"):WaitForChild("Models")
local model = nil
local v = {}

local function fn() end

local object = setmetatable({}, {
	__index = function(list, p)
		if typeof(list) ~= "table" then
			return (rawget(list, p))
		end

		if p == "Add" then
			return function(_, instance)
				if instance:GetAttribute("Pseudo") then
					return warn("PSEUDO PART")
				end

				local clone = instance:Clone()
				clone:SetAttribute("Pseudo", true)
				clone.CanCollide = false
				clone.CanTouch = false
				clone.CanQuery = false
				clone.CastShadow = false
				local objectValue = Instance.new("ObjectValue")
				objectValue.Name = "Pseudo"
				objectValue.Value = instance
				objectValue.Parent = clone
				v[instance] = clone
				local specialMesh = Instance.new("SpecialMesh")
				specialMesh.Name = "Invisible"
				specialMesh.Scale = createVector(0, 0, 0)
				specialMesh.Parent = instance
				clone:SetAttribute("Serial", instance:GetAttribute("Serial"))
				clone.Parent = model
				table.insert(list, clone)
			end
		elseif p == "Remove" then
			return function(_, p2)
				local v2 = table.remove(list, p2)
				fn(v2)
			end
		elseif p == "Clear" then
			return function(_)
				for k, v2 in pairs(list) do
					if typeof(v2) == "function" then
						continue
					end

					list[k] = nil
					fn(v2)
				end
			end
		end

		return (rawget(list, p))
	end
})
local Builder = {
	PartChanged = Signal(),
	PartCreated = Signal(),
	PartRemoved = Signal(),
	Snapshots = {},
	gridSize = 4,
	sizeSnap = 0.2,
	moveSnap = 0.2,
	ghostObjectSkyPlaceDist = 60,
	angleSnap = 0.2617993877991494,
	mode = "none",
	targetObject = nil,
	lockedTargetObjects = object,
	mouseHittableObjects = {},
	ghostObject = nil,
	base = nil,
	active = false
}

fn = function(part)
	if not (part and part:IsA("BasePart")) then
		return
	end

	local live = part:GetAttribute("Live")
	local pseudo = part:FindFirstChild("Pseudo")
	v[part] = nil

	if pseudo then
		local Debris = game:GetService("Debris")
		Debris:AddItem(part, 0)
		local value = pseudo.Value or pseudo

		if value and value:GetAttribute("Live") then
			local Debris2 = game:GetService("Debris")
			Debris2:AddItem(value, 0)
		else
			for _, child in pairs(value:GetChildren()) do
				if child.Name == "Invisible" then
					child:Destroy()
				end
			end
		end
	end

	if live then
		part:SetAttribute("Live", nil)
		Builder.PartCreated:Fire(part, live, part.CFrame)
		local Debris = game:GetService("Debris")
		Debris:AddItem(part, 0)
	end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local updateConnection = nil
Builder.currentGoal = nil
local localPlayer2 = Players.LocalPlayer
local playerGui = localPlayer2:WaitForChild("PlayerGui")
local currentCamera = workspace.CurrentCamera
local mouse = localPlayer2:GetMouse()
local highlight = Instance.new("Highlight")
highlight.FillTransparency = 0.9
highlight.Parent = playerGui:WaitForChild("MobileJunk")
local highlight2 = Instance.new("Highlight")
highlight2.FillTransparency = 0.9
highlight2.Parent = playerGui
highlight:GetPropertyChangedSignal("FillColor"):Connect(function()
	highlight2.FillColor = highlight.FillColor
end)
local model2 = Instance.new("Model")
model2.Name = "BuilderStorage"
model2.Parent = workspace.Built
local model3 = Instance.new("Model")
model3.Name = "GroupSelectionGhostHolder"
model3.Parent = model2
model = Instance.new("Model")
model.Name = "BuildSelectionHolder"
model.Parent = model2
model.ChildAdded:Connect(function(part)
	if not part:IsA("BasePart") then
		return
	end

	local clone = part:Clone()
	local CollectionService = game:GetService("CollectionService")

	for _, tag in pairs(CollectionService:GetTags(clone)) do
		local CollectionService2 = game:GetService("CollectionService")
		CollectionService2:RemoveTag(clone, tag)
	end

	for k, _ in pairs(clone:GetAttributes()) do
		clone:SetAttribute(k, nil)
	end

	clone.CanCollide = false
	clone.CastShadow = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone:ClearAllChildren()
	clone.BrickColor = BrickColor.new("Light blue")
	clone.Parent = workspace.Thrown
	local now = 0

	local function onChanged(p)
		if p == "BrickColor" or p == "Color3uint8" or p == "Attributes" then
			return
		end

		clone.Size = part.Size + createVector(0.1, 0.1, 0.1)
		clone.Material = Enum.Material.SmoothPlastic
		clone.CFrame = part.CFrame

		if part:IsA("Part") and clone:IsA("Part") then
			clone.Shape = part.Shape
		end

		clone.CanCollide = false

		if p == "Color" or p == "Transparency" then
			clone.Transparency = 1
			now = tick()
			task.delay(2.5, function()
				if tick() - now > 2.5 then
					clone.Transparency = 0.4
				end
			end)
		else
			now = 0
			clone.Transparency = 0.4
		end
	end

	local changedConnection = part.Changed:Connect(onChanged)
	onChanged()
	local parentChangedConnection = nil
	parentChangedConnection = part:GetPropertyChangedSignal("Parent"):Connect(function()
		if part.Parent == model then
			return
		end

		parentChangedConnection:Disconnect()
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 0)
		return changedConnection:Disconnect()
	end)
end)
Builder.groupSelectionHolder = model
local humanoid = Instance.new("Humanoid")
humanoid.EvaluateStateMachine = false
humanoid.Parent = model3
local part = Instance.new("Part")
part.Name = "GroupSelectionHighlight"
part.Transparency = 0.99
part.Material = Enum.Material.SmoothPlastic
part.CastShadow = false
part.Anchored = true
part.CanCollide = false
part.CanQuery = false
part.Parent = model3
local handles = Instance.new("Handles")
handles.Faces = Faces.new(
	Enum.NormalId.Front,
	Enum.NormalId.Left,
	Enum.NormalId.Top,
	Enum.NormalId.Right,
	Enum.NormalId.Back,
	Enum.NormalId.Bottom
)
handles.Style = Enum.HandlesStyle.Resize
handles.Parent = playerGui.MobileJunk
local arcHandles = Instance.new("ArcHandles")
arcHandles.Axes = Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z)
arcHandles.Parent = playerGui.MobileJunk
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
local v3 = {
	none = Color3.fromRGB(255, 255, 255),
	delete = Color3.fromRGB(255, 0, 0),
	move = Color3.fromRGB(244, 142, 0),
	resize = Color3.fromRGB(0, 115, 255),
	rotate = Color3.fromRGB(0, 232, 27),
	select = Color3.new(1, 1, 1)
}
local cframesByR = {
	[Enum.KeyCode.R] = CFrame.Angles(0, 1.5707963267948966, 0)
}
local v4 = {
	"move",
	"resize",
	"delete",
	"place",
	"rotate",
	"none",
	"select"
}
local v5 = {
	"move",
	"resize",
	"rotate",
	"select"
}
local result = {}
local v6 = {}
shared.mouseHittableInstances = result
local v7 = {
	move = handles,
	resize = handles,
	rotate = arcHandles
}

-- equivalent calls inferred from this helper; original call sites unknown
local function applyGridTexture(parent)
	local texture = Instance.new("Texture")
	texture.Texture = "http://www.roblox.com/asset/?id=17123114275"
	texture.StudsPerTileU = Builder.gridSize
	texture.StudsPerTileV = Builder.gridSize
	texture.Name = "GridTexture"
	texture.Color3 = Color3.new(1, 1, 1)
	texture.Face = "Top"
	texture.Transparency = 0.8
	texture.Parent = parent
end

local function createBlock(cframe)
	local rotation = Builder.base.CFrame.Rotation
	local transparency = 0.4
	Builder.ResetSelection()
	local v9

	if Builder.Default then
		v9 = Builder.Default:Clone()
		v9:SetAttribute("Serial", nil)
		local prefab = v9:GetAttribute("Prefab")

		if prefab then
			task.spawn(function()
				prefab = models:FindFirstChild(prefab)
				prefab = prefab:Clone()
				local center = prefab:FindFirstChild("Center")

				if center and not prefab:GetAttribute("FineCenter") then
					center.Parent = script
					center.Size = prefab:GetModelSize()
					center.CFrame = prefab:GetModelCFrame()
					center.Parent = prefab
					prefab.PrimaryPart = center
				end

				prefab.Parent = workspace.Thrown

				repeat
					local RunService2 = game:GetService("RunService")
					RunService2.RenderStepped:Wait()
					prefab:PivotTo(v9.CFrame)
				until not v9.Parent

				task.wait()

				if v9:GetAttribute("Created") then
					for _, part2 in pairs(prefab:GetDescendants()) do
						if part2:IsA("BasePart") and part2 ~= center then
							Builder.PartCreated:Fire(part2, nil, part2.CFrame)
						end
					end
				end

				prefab:Destroy()
			end)
			transparency = 0.9
		end
	else
		v9 = Instance.new("Part")
		v9.Size = createVector(4, 4, 4)
		v9.CanCollide = false
		v9.Anchored = true
		v9.Material = Enum.Material.SmoothPlastic
		v9:SetAttribute("Anchored", true)
		v9:SetAttribute("Collision", true)
		v9:SetAttribute("Shadow", true)
	end

	v9:SetAttribute("GhostTransparency", transparency)
	v9.Transparency = transparency
	v9.CFrame = cframe * rotation or CFrame.identity
	return v9
end

local function castMouseRay()
	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local v8 = viewportPointToRay.Origin + viewportPointToRay.Direction * 500
	raycastParams.FilterDescendantsInstances = result
	return workspace:Raycast(viewportPointToRay.Origin, viewportPointToRay.Direction * 500, raycastParams), v8
end

local function ghostInstance(instance)
	instance.Transparency = instance:GetAttribute("GhostTransparency") or 0.4
	instance.CanCollide = false
	instance.CanQuery = false
	instance.CanTouch = false
	instance.CastShadow = false
	shared.sfx({
		SoundId = "rbxassetid://9114378556",
		Parent = instance,
		Volume = 0.2
	}):Play()
	local CollectionService = game:GetService("CollectionService")
	CollectionService:RemoveTag(instance, "psbuilt2")

	for _ = 1, 10 do
		if not table.find(result, instance) then
			break
		end

		table.remove(result, table.find(result, instance))
	end
end

local function realInstance(instance)
	instance:Destroy()
end

local v8 = {}

local function tweenMove(p, cFrame2)
	if v8[p] == cFrame2 then
		return
	end

	local tween = TweenService:Create(p, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		CFrame = cFrame2
	})
	tween.Completed:Connect(function()
		v8[p] = nil
	end)
	tween:Play()
	v8[p] = cFrame2
	return tween
end

local UserInputService2 = game:GetService("UserInputService")

local function resizeFrom(lockedTargetObject, p, p2)
	local v9 = createVector(0, 0, 0)
	local flag

	if UserInputService2:IsKeyDown(Enum.KeyCode.LeftControl) then
		p2 *= 2
		flag = false
	else
		flag = true
	end

	if p == Enum.NormalId.Top or p == Enum.NormalId.Bottom then
		v9 = createVector(0, 1, 0) * p2
	elseif p == Enum.NormalId.Left or p == Enum.NormalId.Right then
		v9 = createVector(1, 0, 0) * p2
	elseif p == Enum.NormalId.Front or p == Enum.NormalId.Back then
		v9 = createVector(0, 0, 1) * p2
	end

	local vector2 = Vector3.new(
		math.round(v9.X / Builder.sizeSnap) * Builder.sizeSnap,
		math.round(v9.Y / Builder.sizeSnap) * Builder.sizeSnap,
		math.round(v9.Z / Builder.sizeSnap) * Builder.sizeSnap
	)
	local v10 = lockedTargetObject.Size + vector2
	local v11 = createVector(1, 1, 1) * Builder.sizeSnap

	if v10:Min(v11) - v11 ~= createVector(0, 0, 0) then
		return
	end

	lockedTargetObject.Size += vector2
	local cframe = CFrame.new(vector2 * 0.5)

	if p == Enum.NormalId.Bottom or p == Enum.NormalId.Left or p == Enum.NormalId.Front then
		cframe = cframe:Inverse()
	end

	if flag then
		lockedTargetObject.CFrame *= cframe
	end
end

function Builder.SetGridSize(value)
	local v9 = math.clamp(value, 0.01, 4)
	local _ = Builder.gridSize
	local gridTexture = Builder.base:FindFirstChild("GridTexture")

	if gridTexture then
		gridTexture.StudsPerTileU = v9
		gridTexture.StudsPerTileV = v9
	end

	Builder.gridSize = v9
end

function Builder.GetGridSize()
	return Builder.gridSize
end

function Builder.SetResizeSnap(value)
	Builder.sizeSnap = math.clamp(value, 0.01, 10)
end

function Builder.GetResizeSnap()
	return Builder.resizeSnap
end

function Builder.SetMoveSnap(value)
	Builder.moveSnap = math.clamp(value, 0.01, 10)
end

function Builder.GetMoveSnap()
	return Builder.moveSnap
end

function Builder.SetAngleSnap(p)
	Builder.angleSnap = math.rad(p)
end

function Builder.GetAngleSnap()
	return (math.deg(Builder.angleSnap))
end

function Builder.AddSelection(p)
	if not table.find(Builder.lockedTargetObjects, p) then
		if not table.find(result, p) and Builder.ghostObject ~= p then
			table.insert(result, p)
		end

		Builder.lockedTargetObjects:Add(nil or p)
	end
end

function Builder.ToggleSelection(p)
	local index = table.find(Builder.lockedTargetObjects, p)

	if not index then
		local v9 = v[p]
		index = table.find(Builder.lockedTargetObjects, v9)
	end

	if index then
		(nil or p).Parent = model2
		Builder.lockedTargetObjects:Remove(index)

		if #Builder.lockedTargetObjects == 0 then
			Builder.ResetSelection()
		end
	else
		Builder.lockedTargetObjects:Add(p)
	end
end

function Builder.ResetSelection()
	for _, child in model:GetChildren() do
		child.Parent = model2
	end

	for _, v9 in pairs(v6) do
		v9:Destroy()
	end

	handles.Adornee = nil
	arcHandles.Adornee = nil
	highlight.Adornee = nil
	highlight2.Adornee = nil
	Builder.lockedTargetObjects:Clear()
end

function Builder.GetSelection()
	return Builder.lockedTargetObjects
end

function Builder.GetSelectable()
	return result
end

function Builder.SetBase(base, p)
	table.insert(result, base)
	local CollectionService = game:GetService("CollectionService")
	CollectionService:AddTag(base, "gridthing")

	if p then
		applyGridTexture(base) -- equivalent call inferred; original call site unknown
	end

	Builder.base = base
end

function Builder.setObject(childName)
	local ghostObject = Builder.ghostObject

	if ghostObject then
		ghostObject:Destroy()
		Builder.ghostObject = nil
	end

	local child = models:FindFirstChild(childName)

	if childName == "Block" then
		Builder.Default = nil
	elseif childName == "Spawn Location" then
		local spawnLocation = Instance.new("SpawnLocation")
		spawnLocation.CanCollide = false
		spawnLocation.Anchored = true
		spawnLocation.Size = createVector(5, 1, 5)
		spawnLocation.Color = Color3.fromRGB(163, 162, 165)
		spawnLocation.Material = Enum.Material.Plastic
		spawnLocation.TopSurface = Enum.SurfaceType.Smooth
		spawnLocation.BackSurface = Enum.SurfaceType.Glue
		spawnLocation.BottomSurface = Enum.SurfaceType.Glue
		spawnLocation.FrontSurface = Enum.SurfaceType.Glue
		spawnLocation.LeftSurface = Enum.SurfaceType.Glue
		spawnLocation.RightSurface = Enum.SurfaceType.Glue
		spawnLocation:SetAttribute("Anchored", true)
		spawnLocation:SetAttribute("Collision", true)
		spawnLocation:SetAttribute("Shadow", true)
		local decal = Instance.new("Decal")
		decal.Texture = "rbxasset://textures/SpawnLocation.png"
		decal.Face = Enum.NormalId.Top
		decal.Parent = spawnLocation
		spawnLocation:GetPropertyChangedSignal("Transparency"):Connect(function()
			decal.Transparency = spawnLocation.Transparency
		end)
		Builder.Default = spawnLocation
	elseif childName == "Trashcan" then
		Builder.Default = game.ReplicatedStorage.Resources.Trashcan:Clone()
	elseif child then
		local clone = child:Clone()
		local center = clone:FindFirstChild("Center")

		if center then
			center:Destroy()
		end

		Instance.new("Part")
		local part2 = Instance.new("Part")
		part2.Size = clone:GetModelSize()
		part2.CFrame = clone:GetModelCFrame()
		part2:SetAttribute("Prefab", clone.Name)
		part2.Color = Color3.new(1, 1, 1)
		part2.CanCollide = false
		part2.Transparency = 1
		part2.Anchored = true
		part2.Material = Enum.Material.SmoothPlastic
		part2:SetAttribute("Anchored", true)
		part2:SetAttribute("Collision", true)
		part2:SetAttribute("Shadow", true)
		Builder.Default = part2
	end
end

function Builder:Clone()
	local clone = self:Clone()
	clone:SetAttribute("Serial", nil)
	clone.Parent = workspace
	Builder.ghostObject = clone
	ghostInstance(clone)
end

function Builder.FindGridPosition(p, p2, p3)
	local cframe = p3 or CFrame.identity
	local v9 = Builder.base.Position + Vector3.new(0, Builder.base.Size.Y / 2, 0)
	local v10 = cframe:Inverse() * (p - v9)
	return cframe * Vector3.new(
		math.round(v10.X / Builder.gridSize) * Builder.gridSize,
		p.Y + (p2 and p2.Y / 2 or Builder.gridSize / 2),
		math.round(v10.Z / Builder.gridSize) * Builder.gridSize
	) + v9 * createVector(1, 0, 1)
end

function Builder.Activate(p)
	local gridd = shared.gridd or Instance.new("Part")
	gridd.Anchored = true
	gridd.CanCollide = false
	gridd.CanTouch = false
	gridd.Transparency = 1
	gridd.Parent = workspace.Thrown
	gridd.Size = createVector(2048, 0, 2048)
	gridd:SetAttribute("DeletionImmunity", true)
	gridd.CFrame = CFrame.new(
		134.81929,
		437.756531,
		33.4901962,
		0.382694274,
		-2.42327269e-10,
		-0.923876107,
		1.22060517e-9,
		1.00000143,
		2.43416565e-10,
		0.923877358,
		-1.22084398e-9,
		0.382692665
	)
	Builder.SetBase(gridd, true)
	shared.gridd = gridd

	if not shared.BUILDERfirsttime then
		shared.BUILDERfirsttime = true
	end

	Builder.active = true
	updateConnection = p
	Builder.updateConnection = updateConnection
	return gridd
end

function Builder.Deactivate()
	local gridd = shared.gridd

	if gridd then
		gridd:Destroy()
		shared.gridd = nil
	end

	Builder.active = false
	Builder.SetMode("none")

	if updateConnection then
		updateConnection()
	end
end

local function fn2(lockedTargetObject)
	local v9 = lockedTargetObject or Builder.targetObject

	if not lockedTargetObject then
		local _ = Builder.mode == "select"
	end

	if v9 and not Builder.ghostObject then
		if Builder.mode ~= "select" then
			handles.Color3 = v3[Builder.mode]
			handles.Adornee = v9
		end

		Builder.lockedTargetObject = v9

		if updateConnection then
			updateConnection()
		end

		if not lockedTargetObject then
			shared.sfx({
				SoundId = "rbxassetid://15675059323",
				Parent = v9,
				Volume = 0.2
			}):Play()
		end
	else
		handles.Adornee = nil
		Builder.lockedTargetObject = nil

		if updateConnection then
			updateConnection()
		end
	end
end

function Builder.SetMode(value, p)
	local mode = Builder.mode
	local lockedTargetObject = Builder.lockedTargetObject
	local lower = value:lower()

	if not table.find(v4, lower) then
		warn("Invalid builder state: " .. lower)
	end

	Builder.mode = lower
	local index = table.find(v5, lower) or lower == "delete"
	BoxSelection.active = index

	if index then
		BoxSelection.SetColor(v3[lower])
	end

	if updateConnection then
		updateConnection()
	end

	if table.find(v5, mode) and table.find(v5, lower) then
		handles.Color3 = v3[Builder.mode]

		if lower ~= "select" then
			if lower == "rotate" then
				arcHandles.Adornee = handles.Adornee
				handles.Adornee = nil
			else
				handles.Adornee = handles.Adornee or arcHandles.Adornee or Builder.lockedTargetObject
				arcHandles.Adornee = nil
			end
		end
	else
		Builder.lockedTargetObject = nil
		handles.Adornee = nil
		arcHandles.Adornee = nil
		highlight.Adornee = nil
	end

	if Builder.ghostObject and not p then
		local ghostObject = Builder.ghostObject
		ghostObject:GetAttribute("BaseCF")
		ghostObject:Destroy()
		Builder.ghostObject = nil
	end

	if mode == "select" and (lower == "rotate" or lower == "resize" or lower == "move") then
		fn2(lockedTargetObject)
	elseif (mode == "rotate" or mode == "resize" or mode == "move") and lower == "select" then
		fn2(lockedTargetObject)
	end

	if updateConnection then
		updateConnection()
	end
end

function Builder.GetMode()
	return Builder.mode
end

RunService.Stepped:Connect(function(time)
	if not Builder.active or Builder.mode == "none" or not Builder.base then
		return
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local v9 = viewportPointToRay.Origin + viewportPointToRay.Direction * 500
	raycastParams.FilterDescendantsInstances = result
	local raycastResult = workspace:Raycast(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * 500,
		raycastParams
	)
	part.Size = model:GetExtentsSize()
	part.CFrame = model:GetPivot()

	if Builder.mode == "place" and not Builder.ghostObject then
		local block = createBlock(CFrame.new(mouse.Hit.p))
		ghostInstance(block)
		block.Parent = workspace
		Builder.ghostObject = block
	end

	if Builder.ghostObject then
		local index = table.find(result, Builder.ghostObject)

		if index then
			table.remove(result, index)
		end

		local ghostObject = Builder.ghostObject
		local invisible = ghostObject:FindFirstChild("Invisible")

		if invisible then
			invisible:Destroy()
		end

		if raycastResult then
			local vector2 = Vector3.new()
			local instance = raycastResult.Instance

			if instance == Builder.base and raycastResult.Normal ~= createVector(0, 1, 0) then
				return
			end

			local v10 = raycastResult.Normal == createVector(0, 1, 0)
			local v11 = raycastResult.Normal == createVector(-0, -1, -0)

			if instance ~= Builder.base and not v10 then
				if instance.Size.Y == Builder.gridSize then
					if v11 then
						vector2 = Vector3.new(0, -Builder.gridSize, 0)
					else
						vector2 = Vector3.new(
							0,
							instance.Position.Y - raycastResult.Position.Y - Builder.gridSize / 2,
							0
						)
					end
				elseif v11 then
					if v11 then
						vector2 = Vector3.new(0, -Builder.gridSize, 0)
					end
				else
					local instance2 = raycastResult.Instance
					local halfSize = instance2.Size / 2
					local position = instance2.Position
					local v13 = position.Y + halfSize.Y
					local v14 = position.Y - halfSize.Y
					local v15 = raycastResult.Position.Y + Builder.gridSize
					local v16 = raycastResult.Position.Y - Builder.gridSize

					if v13 < v15 then
						vector2 = Vector3.new(0, v13 - raycastResult.Position.Y - Builder.gridSize, 0)
					elseif v16 < v14 then
						vector2 = Vector3.new(0, v14 - raycastResult.Position.Y, 0)
					end
				end
			end

			if not (v10 or v11) then
				vector2 += raycastResult.Normal * 0.01
			end

			local rotation = Builder.base.CFrame.Rotation
			local gridPosition = Builder.FindGridPosition(raycastResult.Position + vector2, ghostObject.Size, rotation)
			local currentGoal = CFrame.new(gridPosition) * rotation * (ghostObject:GetAttribute("Rotation") or CFrame.identity)
			Builder.currentGoal = currentGoal
			ghostObject.CFrame = ghostObject.CFrame:lerp(currentGoal, 1 - 0.95 ^ time)
		else
			local character = localPlayer2.Character

			if character then
				local position = character:GetPivot().Position
				local v10 = position + (v9 - position).Unit * Builder.ghostObjectSkyPlaceDist
				local vector2 = Vector3.new(v10.X, math.round(v10.Y / Builder.gridSize) * Builder.gridSize, v10.Z)
				local rotation = Builder.base.CFrame.Rotation
				local gridPosition = Builder.FindGridPosition(vector2, ghostObject.Size, rotation)
				local currentGoal = CFrame.new(gridPosition) * rotation * (ghostObject:GetAttribute("Rotation") or CFrame.identity)
				Builder.currentGoal = currentGoal
				ghostObject.CFrame = ghostObject.CFrame:lerp(currentGoal, 1 - 0.95 ^ time)
			end
		end
	end

	if Builder.mode == "delete" or Builder.mode == "select" or Builder.mode == "move" or Builder.mode == "resize" or Builder.mode == "rotate" then
		local adornee

		if #Builder.lockedTargetObjects > 0 then
			adornee = part
		else
			adornee = false
		end

		if raycastResult and raycastResult.Instance ~= Builder.base and not Builder.ghostObject then
			highlight.FillColor = v3[Builder.mode]
			Builder.targetObject = raycastResult.Instance
			highlight2.Adornee = raycastResult.Instance

			if adornee then
				highlight.Adornee = adornee.Parent
			end

			local v11 = v7[Builder.mode]

			if adornee and v11 and not table.find(Builder.lockedTargetObjects, Builder.ghostObject) then
				v11.Adornee = adornee
				v11.Color3 = v3[Builder.mode]
			end
		elseif adornee then
			highlight.FillColor = v3[Builder.mode]
			Builder.targetObject = nil
			highlight2.Adornee = nil
			highlight.Adornee = adornee
			local v11 = v7[Builder.mode]

			if v11 and not table.find(Builder.lockedTargetObjects, Builder.ghostObject) then
				v11.Adornee = adornee
				v11.Color3 = v3[Builder.mode]
			end
		else
			Builder.targetObject = nil
			highlight2.Adornee = nil
			highlight.Adornee = nil
		end
	end
end)
local CollectionService = game:GetService("CollectionService")
CollectionService:GetInstanceAddedSignal("PSBuilt"):Connect(function(instance)
	if not table.find(result, instance) then
		if instance:GetAttribute("Pseudo") then
			return
		else
			table.insert(result, instance)
		end
	end

	if (instance:GetAttribute("loaded") or not instance:GetAttribute(localPlayer.Name)) and shared.BUILDERfirsttime then
		return
	end

	if shared.BUILDERfirsttime then
	end
end)
local CollectionService2 = game:GetService("CollectionService")
CollectionService2:GetInstanceAddedSignal("psbuilt2"):Connect(function(instance)
	if not (table.find(result, instance) or instance:GetAttribute("Pseudo")) then
		table.insert(result, instance)
	end

	task.wait()
	local serial = instance:GetAttribute("Serial")

	if not _G.builtblocks then
		_G.builtblocks = {}
	end

	if serial then
		_G.builtblocks[serial] = instance
	end
end)
local CollectionService3 = game:GetService("CollectionService")

for _, v9 in pairs(CollectionService3:GetTagged("psbuilt2")) do
	local serial = v9:GetAttribute("Serial")

	if not _G.builtblocks then
		_G.builtblocks = {}
	end

	if serial then
		_G.builtblocks[serial] = v9
	end
end

local CollectionService4 = game:GetService("CollectionService")

for _, v9 in pairs(CollectionService4:GetTagged("PSBuilt")) do
	if not (table.find(result, v9) or v9:GetAttribute("Pseudo")) then
		table.insert(result, v9)
	end

	local serial = v9:GetAttribute("Serial")

	if not _G.builtblocks then
		_G.builtblocks = {}
	end

	if serial then
		_G.builtblocks[serial] = v9
	end
end

local Info = require(game.ReplicatedStorage.Info)
local _ = Info.GetSerial
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed or not Builder.active or Builder.mode == "none" then
		return
	end

	local v9

	if localPlayer.Character then
		v9 = localPlayer.Character:FindFirstChild("Communicate")
	end

	if input.UserInputType == Enum.UserInputType.Touch and v9 and Builder.ghostObject then
		local ghostObject = Builder.ghostObject
		Builder.ghostObject = nil
		ghostObject.CFrame = Builder.currentGoal
		ghostObject.Parent = workspace.Built
		ghostObject:Destroy()
		Builder.PartCreated:Fire(ghostObject)
		table.insert(result, ghostObject)
	end
end)
local UserInputService3 = game:GetService("UserInputService")
local touchEnabled = UserInputService3.TouchEnabled
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not Builder.active or Builder.mode == "none" then
		return
	end

	local isKeyDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)

	if touchEnabled and #Builder.lockedTargetObjects > 0 then
		isKeyDown = false
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if Builder.mode == "place" and input.UserInputType ~= Enum.UserInputType.Touch and Builder.ghostObject then
			local ghostObject = Builder.ghostObject
			Builder.ghostObject = nil
			ghostObject.Parent = workspace.Built
			ghostObject.CFrame = Builder.currentGoal
			ghostObject:Destroy()
			Builder.PartCreated:Fire(ghostObject)
			table.insert(result, ghostObject)
		end

		if Builder.mode == "delete" and Builder.targetObject then
			local v9 = false

			for _, lockedTargetObject in Builder.lockedTargetObjects do
				Builder.PartRemoved:Fire(lockedTargetObject)
				v9 = true
			end

			if not v9 then
				Builder.PartRemoved:Fire(Builder.targetObject)
			end

			Builder.ResetSelection()
		end

		if Builder.mode == "move" or Builder.mode == "resize" or Builder.mode == "select" then
			local targetObject = Builder.targetObject

			if touchEnabled then
				local mouseLocation = UserInputService:GetMouseLocation()
				local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
				local _ = viewportPointToRay.Origin + viewportPointToRay.Direction * 500
				raycastParams.FilterDescendantsInstances = result
				local raycastResult = workspace:Raycast(
					viewportPointToRay.Origin,
					viewportPointToRay.Direction * 500,
					raycastParams
				)

				if raycastResult and raycastResult.Instance and raycastResult.Instance ~= Builder.base then
					targetObject = raycastResult.Instance
				end
			end

			if targetObject and not Builder.ghostObject then
				if isKeyDown then
					Builder.ToggleSelection(targetObject)
				else
					Builder.ResetSelection()
					Builder.AddSelection(targetObject)
				end
			elseif not (targetObject or touchEnabled) then
				Builder.ResetSelection()
			end

			if updateConnection then
				updateConnection()
			end
		end

		if Builder.mode == "rotate" then
			if Builder.targetObject then
				if isKeyDown then
					Builder.ToggleSelection(Builder.targetObject)
				else
					Builder.ResetSelection()
					Builder.AddSelection(Builder.targetObject)
				end
			elseif not touchEnabled then
				Builder.ResetSelection()
			end
		end

		local _ = Builder.mode == "move"
	end

	if input.UserInputType == Enum.UserInputType.Keyboard and cframesByR[input.KeyCode] then
		local v9 = cframesByR[input.KeyCode]

		if Builder.ghostObject then
			local rotation = Builder.ghostObject:GetAttribute("Rotation") or CFrame.identity
			Builder.ghostObject:SetAttribute("Rotation", rotation * v9)
		end
	end
end)
local v9 = 0
local v10 = 0
local rotationsByLockedTargetObject = {}
local CameraInput

if touchEnabled then
	CameraInput = require(localPlayer.PlayerScripts.PlayerModule.CameraModule.CameraInput)
else
	CameraInput = nil
end

handles.MouseButton1Down:Connect(function(_)
	if CameraInput then
		CameraInput.changePanState(false)
	end

	v10 = 0
	v9 = 0
	table.clear(rotationsByLockedTargetObject)

	for _, lockedTargetObject in Builder.lockedTargetObjects do
		if typeof(lockedTargetObject) == "Instance" then
			rotationsByLockedTargetObject[lockedTargetObject] = lockedTargetObject.CFrame.Rotation
		end
	end
end)
local v11 = nil
handles.MouseButton1Up:Connect(function(_)
	if CameraInput then
		CameraInput.changePanState(true)
	end

	if v11 then
		for _, v12 in pairs(v11[2]) do
			v12.Parent = Builder.groupSelectionHolder
		end

		v11[1]:Destroy()
		v11 = nil
	end

	v10 = 0
	v9 = 0
	table.clear(rotationsByLockedTargetObject)

	for _, lockedTargetObject in Builder.lockedTargetObjects do
		if typeof(lockedTargetObject) == "Instance" then
			rotationsByLockedTargetObject[lockedTargetObject] = lockedTargetObject.CFrame.Rotation
		end
	end
end)
handles.MouseDrag:Connect(function(p, p2: number)
	if #Builder.lockedTargetObjects > 0 then
		local v12 = p2 - v10
		local sizeSnap

		if Builder.mode == "resize" then
			sizeSnap = Builder.sizeSnap
		else
			sizeSnap = Builder.moveSnap
		end

		local v13 = math.round(v12 / sizeSnap)
		local v14 = v13 * sizeSnap

		if v13 ~= 0 then
			if Builder.mode == "resize" then
				local lockedTargetObjects = Builder.lockedTargetObjects

				for _, lockedTargetObject in lockedTargetObjects do
					if typeof(lockedTargetObject) == "Instance" then
						resizeFrom(lockedTargetObject, p, v14)
					end
				end

				Builder.PartChanged:Fire(lockedTargetObjects, "Size")
			elseif Builder.mode == "move" then
				local vector2 = Vector3.fromNormalId(p)
				local v15 = part.CFrame.Rotation * vector2 * v14
				local lockedTargetObjects = Builder.lockedTargetObjects

				for _, lockedTargetObject in lockedTargetObjects do
					if typeof(lockedTargetObject) ~= "Instance" then
						continue
					end

					local v16 = lockedTargetObject.CFrame.Position + v15
					lockedTargetObject.CFrame = CFrame.new(v16) * rotationsByLockedTargetObject[lockedTargetObject]
				end

				Builder.PartChanged:Fire(lockedTargetObjects, "CFrame")
			end

			v10 = p2
		end
	end
end)
local cFrame = nil
local v12 = {}
arcHandles.MouseButton1Down:Connect(function()
	if CameraInput then
		CameraInput.changePanState(false)
	end

	cFrame = part.CFrame
	table.clear(v12)

	for _, lockedTargetObject in Builder.lockedTargetObjects do
		if typeof(lockedTargetObject) == "Instance" then
			v12[lockedTargetObject] = cFrame:Inverse() * lockedTargetObject.CFrame
		end
	end
end)
arcHandles.MouseButton1Up:Connect(function()
	if CameraInput then
		CameraInput.changePanState(true)
	end
end)
arcHandles.MouseDrag:Connect(function(p, p2)
	if Builder.mode == "rotate" and #Builder.lockedTargetObjects > 0 then
		local angleSnap = Builder.angleSnap
		local v13 = math.round(p2 / angleSnap) * angleSnap
		local cframe = CFrame.fromAxisAngle(Vector3.fromAxis(p), v13)
		local v14 = cFrame * cframe
		local lockedTargetObjects = Builder.lockedTargetObjects

		for _, lockedTargetObject in lockedTargetObjects do
			if typeof(lockedTargetObject) ~= "Instance" then
				continue
			end

			local cFrame2 = v14 * v12[lockedTargetObject]

			if lockedTargetObject.CFrame ~= cFrame2 then
				lockedTargetObject.CFrame = cFrame2
			end
		end

		Builder.PartChanged:Fire(lockedTargetObjects, "CFrame")
	end
end)
return Builder