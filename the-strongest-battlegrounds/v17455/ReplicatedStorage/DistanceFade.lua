local createVector = vector.create
local DistanceFade = {}
DistanceFade.__index = DistanceFade
local v = {
	DistanceOuter = 118,
	DistanceInner = 4,
	EffectRadius = 96,
	EffectRadiusMin = 0,
	Texture = "rbxassetid://106608742642683",
	TextureTransparency = 0,
	TextureTransparencyMin = 1,
	BackgroundTransparency = 1,
	BackgroundTransparencyMin = 1,
	TextureColor = Color3.fromRGB(255, 255, 255),
	BackgroundColor = Color3.fromRGB(255, 255, 255),
	TextureSize = Vector2.new(8, 8),
	TextureOffset = Vector2.new(0, 0),
	ZOffset = 0,
	AlwaysOnTop = false,
	Brightness = 1,
	LightInfluence = 0,
	MaxDistance = 1000,
	PixelsPerStud = 100,
	SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
}
local Players = game:GetService("Players")
local new = Vector3.new
local new2 = Vector2.new
local new3 = UDim2.new
local new4 = CFrame.new
local angles = CFrame.Angles
local fromMatrix = CFrame.fromMatrix
local new5 = NumberSequenceKeypoint.new
local new6 = NumberSequence.new
local normalId = Enum.NormalId
local clamp = math.clamp
local _ = math.floor
local abs = math.abs
local min = math.min
local max = math.max
local front = normalId.Front
local back = normalId.Back
local left = normalId.Left
local right = normalId.Right
local top = normalId.Top
local _ = normalId.Bottom
local cframe = angles(0, 0, 0)
local cframe2 = angles(0, 3.141592653589793, 0)
local cframe3 = angles(0, 1.5707963267948966, 0)
local cframe4 = angles(0, -1.5707963267948966, 0)
local cframe5 = angles(1.5707963267948966, 0, 0)
local cframe6 = angles(-1.5707963267948966, 0, 0)

-- equivalent calls inferred from this helper; original call sites unknown
local function setupFolder(p)
	if p.WorkspaceFolder and p.WorkspaceFolder.Parent then
		return
	end

	local workspaceFolder = workspace:FindFirstChild("DistanceFade_SurfaceParts")

	if not workspaceFolder then
		workspaceFolder = Instance.new("Folder")
		workspaceFolder.Name = "DistanceFade_SurfaceParts"
		workspaceFolder.Parent = workspace
	end

	p.WorkspaceFolder = workspaceFolder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clampSettings(state)
	if state.EffectRadiusMin > state.EffectRadius then
		state.EffectRadiusMin = state.EffectRadius
	end

	if state.DistanceInner > state.DistanceOuter then
		state.DistanceInner = state.DistanceOuter
	end
end

local function buildMerged(items, items2)
	local result = {}

	for k, item in items do
		result[k] = item
	end

	for k, item in items2 do
		result[k] = item
	end

	clampSettings(result) -- equivalent call inferred; original call site unknown
	return result
end

function DistanceFade.new()
	local self = setmetatable({
		Settings = {},
		FaceSettings = {},
		TargetParts = {},
		WorkspaceFolder = nil,
		_lastPos = nil,
		_dirty = true
	}, DistanceFade)

	for k, v2 in v do
		self.Settings[k] = v2
	end

	clampSettings(self.Settings) -- equivalent call inferred; original call site unknown
	setupFolder(self) -- equivalent call inferred; original call site unknown
	return self
end

function DistanceFade:UpdateSettings(p2)
	if p2 == nil then
		for k, v2 in v do
			self.Settings[k] = v2
		end
	else
		assert(type(p2) == "table", "Expected table as parameter")

		for k in v do
			if p2[k] ~= nil then
				self.Settings[k] = p2[k]
			end
		end
	end

	clampSettings(self.Settings) -- equivalent call inferred; original call site unknown
	self._dirty = true
end

function DistanceFade:UpdateFaceSettings(p, p2, items)
	if not self.FaceSettings[p] then
		self.FaceSettings[p] = {}
	end

	if not self.FaceSettings[p][p2] then
		self.FaceSettings[p][p2] = {}
	end

	local v2 = self.TargetParts[p] and self.TargetParts[p][p2]

	if items == nil then
		self.FaceSettings[p][p2] = nil

		if v2 then
			v2.MergedSettings = nil
		end
	else
		assert(type(items) == "table", "Expected table as parameter")

		for k, item in items do
			self.FaceSettings[p][p2][k] = item
		end

		if v2 then
			local settings = self.Settings
			local v3 = self.FaceSettings[p][p2]
			local mergedSettings = {}

			for k, setting in settings do
				mergedSettings[k] = setting
			end

			for k, v5 in v3 do
				mergedSettings[k] = v5
			end

			clampSettings(mergedSettings) -- equivalent call inferred; original call site unknown
			v2.MergedSettings = mergedSettings
		end
	end

	self._dirty = true
end

local function normalToOffsetRotation(p, p2)
	local size = p2.Size

	if p == front then
		return new(0, 0, -size.Z * 0.5), cframe
	end

	if p == back then
		return new(0, 0, size.Z * 0.5), cframe2
	end

	if p == left then
		return new(-size.X * 0.5, 0, 0), cframe3
	end

	if p == right then
		return new(size.X * 0.5, 0, 0), cframe4
	end

	if p == top then
		return new(0, size.Y * 0.5, 0), cframe5
	end

	return new(0, -size.Y * 0.5, 0), cframe6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalDirection(p, instance)
	local cFrame = instance.CFrame

	if p == front then
		return cFrame.LookVector
	end

	if p == back then
		return -cFrame.LookVector
	end

	if p == left then
		return -cFrame.RightVector
	end

	if p == right then
		return cFrame.RightVector
	end

	if p == top then
		return cFrame.UpVector
	end

	return -cFrame.UpVector
end

local function faceHalfDims(p, data)
	if p == front or p == back then
		return data.X * 0.5, data.Y * 0.5
	end

	if p == left or p == right then
		return data.Z * 0.5, data.Y * 0.5
	end

	return data.X * 0.5, data.Z * 0.5
end

local function toNormalSpace(targetCF, p, p2)
	local pointToObjectSpace = targetCF:PointToObjectSpace(p)

	if p2 == front then
		return pointToObjectSpace
	end

	if p2 == back then
		return (new(-pointToObjectSpace.X, pointToObjectSpace.Y, pointToObjectSpace.Z))
	elseif p2 == left then
		return (new(-pointToObjectSpace.Z, pointToObjectSpace.Y, pointToObjectSpace.X))
	elseif p2 == right then
		return (new(pointToObjectSpace.Z, pointToObjectSpace.Y, pointToObjectSpace.X))
	elseif p2 == top then
		return (new(pointToObjectSpace.X, pointToObjectSpace.Z, pointToObjectSpace.Y))
	else
		return (new(pointToObjectSpace.X, -pointToObjectSpace.Z, pointToObjectSpace.Y))
	end
end

local v2 = {
	[1] = 45,
	[3] = 135,
	[7] = -45,
	[9] = -135
}
local v3 = {
	[2] = 90,
	[4] = 0,
	[6] = 180,
	[8] = -90
}
local v4 = {
	{
		OffsetX = 2,
		OffsetY = 2
	},
	{
		OffsetX = 1,
		OffsetY = 2
	},
	{
		OffsetX = 0,
		OffsetY = 2
	},
	{
		OffsetX = 2,
		OffsetY = 1
	},
	{
		OffsetX = 1,
		OffsetY = 1
	},
	{
		OffsetX = 0,
		OffsetY = 1
	},
	{
		OffsetX = 2,
		OffsetY = 0
	},
	{
		OffsetX = 1,
		OffsetY = 0
	},
	{
		OffsetX = 0,
		OffsetY = 0
	}
}

local function newTile()
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	local frame2 = Instance.new("Frame")
	frame2.Name = "ScaleFrame"
	frame2.BackgroundTransparency = 1
	frame2.ClipsDescendants = true
	frame2.AnchorPoint = new2(0.5, 0.5)
	frame2.Position = new3(0.5, 0, 0.5, 0)
	frame2.Size = new3(1, 0, 1, 0)
	frame2.Parent = frame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = new2(0.5, 0.5)
	imageLabel.Position = new3(0.5, 0, 0.5, 0)
	imageLabel.Size = new3(9, 0, 9, 0)
	imageLabel.ScaleType = Enum.ScaleType.Tile
	imageLabel.TileSize = new3(0.111, 0, 0.111, 0)
	imageLabel.Image = v.Texture
	imageLabel.ImageColor3 = v.TextureColor
	imageLabel.BackgroundColor3 = v.BackgroundColor
	imageLabel.Parent = frame2
	return frame
end

local function createGrid(frame)
	local count = 0
	local result = {}

	for i = 1, 3 do
		for i2 = 1, 3 do
			local parent = newTile()
			parent.Size = new3(0.3333333333333333, 0, 0.3333333333333333, 0)
			parent.Position = new3((i2 - 1) * 0.3333333333333333, 0, (i - 1) * 0.3333333333333333, 0)
			parent.Parent = frame
			count += 1
			result[count] = parent
			parent.Name = tostring(count)
		end
	end

	return result
end

local function applyGradients(grid)
	for i = 1, #grid do
		local rotation = v2[i] or v3[i]

		if not rotation then
			continue
		end

		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = rotation
		uIGradient.Parent = grid[i].ScaleFrame.ImageLabel
	end
end

local function setupSurface(instance, p, state)
	local settings = state.Settings
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Size = createVector(0, 0, 0)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Locked = true
	local v5, v6 = normalToOffsetRotation(p, instance)
	part.CFrame = instance.CFrame * new4(v5) * v6
	part.Parent = state.WorkspaceFolder
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.ResetOnSpawn = false
	surfaceGui.ClipsDescendants = true
	surfaceGui.Adornee = part
	surfaceGui.Face = front
	surfaceGui.SizingMode = settings.SizingMode
	surfaceGui.PixelsPerStud = settings.PixelsPerStud
	surfaceGui.ZOffset = settings.ZOffset
	surfaceGui.AlwaysOnTop = settings.AlwaysOnTop
	surfaceGui.Brightness = settings.Brightness
	surfaceGui.LightInfluence = settings.LightInfluence
	surfaceGui.MaxDistance = settings.MaxDistance
	surfaceGui.Enabled = false
	local frame = Instance.new("Frame")
	frame.Name = "ScaleFrame"
	frame.Size = new3(1, 0, 1, 0)
	frame.AnchorPoint = new2(0.5, 0.5)
	frame.Position = new3(0.5, 0, 0.5, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = surfaceGui
	local grid = createGrid(frame)
	applyGradients(grid)
	surfaceGui.Parent = Players.LocalPlayer.PlayerGui
	return part, surfaceGui, grid, frame
end

function DistanceFade:AddFace(instance, p)
	local surfaceNormal = p or front

	if self.TargetParts[instance] and self.TargetParts[instance][surfaceNormal] then
		return
	end

	setupFolder(self) -- equivalent call inferred; original call site unknown
	local surfacePart, surfaceGui, v8, scaleFrame = setupSurface(instance, surfaceNormal, self)
	local normalOffset, rotation = normalToOffsetRotation(surfaceNormal, instance)
	local baseCFrame = instance.CFrame * new4(normalOffset) * rotation
	local targetNormal = normalDirection(surfaceNormal, instance) -- equivalent call inferred; original call site unknown
	local size = instance.Size
	local halfWidth, halfHeight

	if surfaceNormal == front or surfaceNormal == back then
		halfWidth = size.X * 0.5
		halfHeight = size.Y * 0.5
	elseif surfaceNormal == left or surfaceNormal == right then
		halfWidth = size.Z * 0.5
		halfHeight = size.Y * 0.5
	else
		halfWidth = size.X * 0.5
		halfHeight = size.Z * 0.5
	end

	local position = baseCFrame.Position
	local rightVector = baseCFrame.RightVector
	local upVector = baseCFrame.UpVector
	local tileMeta = {}

	for i = 1, #v8 do
		local tile = v8[i]
		local imageLabel = tile.ScaleFrame.ImageLabel
		tileMeta[i] = {
			Tile = tile,
			ImageLabel = imageLabel,
			Gradient = imageLabel:FindFirstChildOfClass("UIGradient"),
			Index = i,
			Name = tile.Name,
			IsCorner = v2[i] ~= nil,
			IsSide = v3[i] ~= nil,
			Mult = v4[i]
		}
	end

	local v17 = {
		SurfaceNormal = surfaceNormal,
		SurfacePart = surfacePart,
		SurfaceGui = surfaceGui,
		ScaleFrame = scaleFrame,
		TileMeta = tileMeta,
		TargetPart = instance,
		TargetCF = instance.CFrame,
		NormalOffset = normalOffset,
		Rotation = rotation,
		TargetNormal = targetNormal,
		BaseCFrame = baseCFrame,
		FacePos = position,
		RightVec = rightVector,
		UpVec = upVector,
		HalfWidth = halfWidth,
		HalfHeight = halfHeight,
		LeftWorld = position - rightVector * halfWidth,
		RightWorld = position + rightVector * halfWidth,
		TopWorld = position + upVector * halfHeight,
		BotWorld = position - upVector * halfHeight,
		MergedSettings = nil,
		GradCache = {},
		LastEnabled = false
	}
	v17.LeftLocal = toNormalSpace(v17.TargetCF, v17.LeftWorld, surfaceNormal)
	v17.RightLocal = toNormalSpace(v17.TargetCF, v17.RightWorld, surfaceNormal)
	v17.TopLocal = toNormalSpace(v17.TargetCF, v17.TopWorld, surfaceNormal)
	v17.BotLocal = toNormalSpace(v17.TargetCF, v17.BotWorld, surfaceNormal)

	if not self.TargetParts[instance] then
		self.TargetParts[instance] = {}
	end

	self.TargetParts[instance][surfaceNormal] = v17

	if self.FaceSettings[instance] and self.FaceSettings[instance][surfaceNormal] then
		local settings = self.Settings
		local v18 = self.FaceSettings[instance][surfaceNormal]
		local mergedSettings = {}

		for k, setting in settings do
			mergedSettings[k] = setting
		end

		for k, v20 in v18 do
			mergedSettings[k] = v20
		end

		clampSettings(mergedSettings) -- equivalent call inferred; original call site unknown
		v17.MergedSettings = mergedSettings
	end

	self._dirty = true
end

function DistanceFade:RemoveFace(p, p2)
	local v5 = p2 or front

	if not self.TargetParts[p] then
		return
	end

	local v6 = self.TargetParts[p][v5]

	if not v6 then
		return
	end

	v6.SurfacePart:Destroy()
	v6.SurfaceGui:Destroy()
	self.TargetParts[p][v5] = nil

	if next(self.TargetParts[p]) == nil then
		self.TargetParts[p] = nil

		if self.WorkspaceFolder and #self.WorkspaceFolder:GetChildren() == 0 then
			self.WorkspaceFolder:Destroy()
			self.WorkspaceFolder = nil
		end
	end

	self._dirty = true
end

function DistanceFade:Clear()
	for _, targetPart in self.TargetParts do
		for _, v5 in targetPart do
			v5.SurfacePart:Destroy()
			v5.SurfaceGui:Destroy()
		end
	end

	if self.WorkspaceFolder and #self.WorkspaceFolder:GetChildren() == 0 then
		self.WorkspaceFolder:Destroy()
		self.WorkspaceFolder = nil
	end

	table.clear(self.TargetParts)
	self._dirty = true
end

local v5 = {
	new5(0, 1),
	new5(0.444, 1),
	new5(0.466, 1),
	new5(0.555, 0),
	new5(1, 0)
}
local count = #v5
local v6 = {
	new5(0, 1),
	new5(0.444, 1),
	new5(0.51, 1),
	new5(0.555, 0.2),
	new5(1, 0.2)
}
local count2 = #v6
local v7 = {}

for _, v8 in {
	45,
	135,
	-45,
	-135,
	90,
	0,
	180,
	-90
} do
	local v9 = math.rad(v8)
	v7[v8] = {
		c = math.cos(v9),
		s = math.sin(v9)
	}
end

local function adjustGradOffset(p, p2)
	local v8 = v7[p]
	local c = v8.c
	local s = v8.s
	local X = p2.X
	local Y = p2.Y
	return new2(X * c - Y * s, X * s + Y * c)
end

local function toRange(p, p2)
	local v8 = abs(p) / p2 % 1

	if p < 0 then
		return -v8 or v8
	end

	return v8
end

local function updateTextureOffset(p, p2, p3, p4)
	local v10 = abs(p) / p3 % 1

	if p < 0 then
		v10 = -v10 or v10
	end

	local v11 = 0.5 + v10 * p3
	local v14 = abs(p2) / p4 % 1

	if p2 < 0 then
		v14 = -v14 or v14
	end

	return new3(v11, 0, 0.5 + v14 * p4, 0)
end

local function updateSideGradient(data, p)
	local imageLabel = data.ImageLabel
	local gradient = data.Gradient
	local position = imageLabel.Position
	local name = data.Name
	local index = data.Index
	local scale = position.X.Scale
	local scale2 = position.Y.Scale
	local v8 = -(scale + 0.5) / 200
	local v9 = -(scale2 + 0.5) / 200
	local v10 = (index == 2 or index == 8) and 0 or v8
	local v11 = (index == 4 or index == 6) and 0 or v9
	local v12 = (scale - 0.5) / 9 + v10
	local v13 = (scale2 - 0.5) / 9 + v11

	if index == 2 or index == 4 then
		v13 = -v13
	end

	if index == 6 or index == 8 then
		v12 = -v12
	end

	if index == 2 or index == 8 then
		v13, v12 = v12, v13
	end

	local v14 = p.GradCache[name]

	if v14 and abs(v14[1] - v12) < 0.003 and abs(v14[2] - v13) < 0.003 then
		return
	end

	if v14 then
		v14[1] = v12
		v14[2] = v13
	else
		p.GradCache[name] = { v12, v13 }
	end

	local v15 = table.create(count + 2)
	local count3 = 0

	for i = 1, count do
		local v16 = v5[i]
		count3 += 1
		v15[count3] = new5(clamp(v16.Time + v12, 0, 1), v16.Value)
	end

	if v15[1].Time > 0 then
		table.insert(v15, 1, new5(0, v15[1].Value))
		count3 += 1
	end

	if v15[count3].Time < 1 then
		local v16 = count3 + 1
		v15[v16] = new5(1, v15[v16 - 1].Value)
	end

	gradient.Transparency = new6(v15)
	local rotation = gradient.Rotation
	local vector2 = new2(-v13 / 4, 0)
	local v16 = v7[rotation]
	local c = v16.c
	local s = v16.s
	local X = vector2.X
	local Y = vector2.Y
	gradient.Offset = new2(X * c - Y * s, X * s + Y * c)
end

local function updateCornerGradient(data, p)
	local imageLabel = data.ImageLabel
	local gradient = data.Gradient
	local position = imageLabel.Position
	local name = data.Name
	local index = data.Index
	local scale = position.X.Scale
	local scale2 = position.Y.Scale
	local v8 = -(scale + 0.5) / 75
	local v9 = -(scale2 + 0.5) / 75
	local v10 = (scale - 0.5) / 9 + v8
	local v11 = (scale2 - 0.5) / 9 + v9

	if index == 1 or index == 7 then
		v10 = -v10
	end

	if index == 1 or index == 3 then
		v11 = -v11
	end

	local v12

	if index == 1 then
		v12 = -0.015
	elseif index == 3 then
		v12 = 0.0025
	elseif index == 9 then
		v12 = 0.02
	elseif index == 7 then
		v12 = 0.0025
	else
		v12 = 0
	end

	local v13 = (v10 + v11) * 0.7071067811865475 + v12
	local v14 = p.GradCache[name]

	if v14 and abs(v14[1] - v13) < 0.003 then
		return
	end

	if v14 then
		v14[1] = v13
	else
		p.GradCache[name] = { v13 }
	end

	local v15 = table.create(count2 + 2)
	local count3 = 0

	for i = 1, count2 do
		local v16 = v6[i]
		count3 += 1
		v15[count3] = new5(clamp(v16.Time + v13, 0, 1), v16.Value)
	end

	if v15[1].Time > 0 then
		table.insert(v15, 1, new5(0, v15[1].Value))
		count3 += 1
	end

	if v15[count3].Time < 1 then
		count3 += 1
		v15[count3] = new5(1, v15[count3 - 1].Value)
	end

	if index == 1 or index == 3 then
		for i = 1, count3 do
			if v15[i].Time ~= 1 then
				continue
			end

			for i2 = i + 1, count3 do
				v15[i2] = nil
			end

			break
		end
	end

	gradient.Transparency = new6(v15)
	local rotation = gradient.Rotation
	local vector2 = new2(-v13 / 4, 0)
	local v16 = v7[rotation]
	local c = v16.c
	local s = v16.s
	local X = vector2.X
	local Y = vector2.Y
	gradient.Offset = new2(X * c - Y * s, X * s + Y * c)
end

function DistanceFade:Step(position)
	if not position then
		local character = Players.LocalPlayer.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		position = humanoidRootPart.Position
	end

	if not self._dirty and self._lastPos and (position - self._lastPos).Magnitude < 0.01 then
		return
	end

	self._lastPos = position
	self._dirty = false
	local settings = self.Settings

	for _, targetPart in self.TargetParts do
		for k, v8 in targetPart do
			local mergedSettings = v8.MergedSettings or settings
			local facePos = v8.FacePos
			local rightVec = v8.RightVec
			local upVec = v8.UpVec
			local halfWidth = v8.HalfWidth
			local halfHeight = v8.HalfHeight
			local v9 = position.X - facePos.X
			local v10 = position.Y - facePos.Y
			local v11 = position.Z - facePos.Z
			local X = rightVec.X
			local Y = rightVec.Y
			local Z = rightVec.Z
			local X2 = upVec.X
			local Y2 = upVec.Y
			local Z2 = upVec.Z
			local v12 = v9 * X + v10 * Y + v11 * Z
			local v13 = v9 * X2 + v10 * Y2 + v11 * Z2
			local v15 = clamp(v12, -halfWidth, halfWidth)
			local v17 = clamp(v13, -halfHeight, halfHeight)
			local v18 = facePos.X + X * v15 + X2 * v17
			local v19 = facePos.Y + Y * v15 + Y2 * v17
			local v20 = facePos.Z + Z * v15 + Z2 * v17
			local v21 = position.X - v18
			local v22 = position.Y - v19
			local v23 = position.Z - v20
			local v24 = (v21 * v21 + v22 * v22 + v23 * v23) ^ 0.5
			local surfaceGui = v8.SurfaceGui
			local distanceOuter = mergedSettings.DistanceOuter

			if distanceOuter <= v24 then
				if v8.LastEnabled then
					surfaceGui.Enabled = false
					v8.LastEnabled = false
				end
			else
				if not v8.LastEnabled then
					surfaceGui.Enabled = true
					v8.LastEnabled = true
				end

				local surfacePart = v8.SurfacePart
				surfacePart.CFrame = fromMatrix(
					new(facePos.X + X * v12 + X2 * v13, facePos.Y + Y * v12 + Y2 * v13, facePos.Z + Z * v12 + Z2 * v13),
					rightVec,
					upVec
				)
				local textureSize = mergedSettings.TextureSize
				local X3 = textureSize.X
				local effectRadius = mergedSettings.EffectRadius
				local distanceInner = mergedSettings.DistanceInner
				local effectRadiusMin = mergedSettings.EffectRadiusMin
				local v28 = X3 * 2 / effectRadius
				local v29 = 1 / v28
				local v30

				if v24 < distanceInner then
					v30 = v29
				else
					v30 = v29 - clamp((v24 - distanceInner) / (distanceOuter - distanceInner), 0, 1)
				end

				local v31 = effectRadius / v29
				local v32 = (effectRadiusMin + (effectRadius - effectRadiusMin) * v30 * v28) * 2
				local Z3 = surfacePart.Size.Z
				surfacePart.Size = new(v32, v32, Z3)
				local targetCF = v8.TargetCF
				local leftLocal = v8.LeftLocal
				local rightLocal = v8.RightLocal
				local topLocal = v8.TopLocal
				local botLocal = v8.BotLocal
				local v33 = v32 * 0.5
				local v34 = v32 * 0.5
				local position2 = surfacePart.Position
				local v35 = position2 - rightVec * v33
				local v36 = position2 + rightVec * v33
				local v37 = position2 + upVec * v34
				local v38 = position2 - upVec * v34
				local v39 = toNormalSpace(targetCF, v35, k)
				local v40 = toNormalSpace(targetCF, v36, k)
				local v41 = toNormalSpace(targetCF, v37, k)
				local v42 = toNormalSpace(targetCF, v38, k)
				local v43 = 1 / v32
				local v44 = not (v39.X < leftLocal.X) and 1 or 1 - (leftLocal.X - v39.X) * v43
				local v45 = not (v40.X > rightLocal.X) and 1 or 1 - (v40.X - rightLocal.X) * v43
				local v46 = not (v42.Y < botLocal.Y) and 1 or 1 - (botLocal.Y - v42.Y) * v43
				local v47 = not (v41.Y > topLocal.Y) and 1 or 1 - (v41.Y - topLocal.Y) * v43

				if v47 < 0 or v46 < 0 or v44 < 0 or v45 < 0 then
					if v8.LastEnabled then
						surfaceGui.Enabled = false
						v8.LastEnabled = false
					end
				else
					local v48 = 1 - (1 - v44 + (1 - v45))
					local v49 = 1 - (1 - v47 + (1 - v46))
					local v50 = v44 <= v45 and 1 or -1
					local v51 = v46 <= v47 and 1 or -1
					local v52 = v32 * v48
					local v53 = v32 * v49
					local v54

					if v45 < 1 and v44 < 1 then
						local v55 = (v45 - v44) * 2
						local v56 = (v32 - v52) * 0.5 * v55
						local v57 = (v40.X + v39.X) * 0.5
						local v58 = (rightLocal.X + leftLocal.X) * 0.5
						local v60 = abs(rightLocal.X - leftLocal.X)
						v54 = v56 - (v57 + v56 + v52 - (v58 + v60))
						v50 = v55 / ((1 - (v45 + v44 - 1)) * 2)
					else
						v54 = (v32 - v52) * 0.5 * v50
					end

					local v55

					if v47 < 1 and v46 < 1 then
						local v56 = (v47 - v46) * 2
						local v57 = (v32 - v53) * 0.5 * v56
						local v58 = (v41.Y + v42.Y) * 0.5
						local v59 = (topLocal.Y + botLocal.Y) * 0.5
						local v61 = abs(topLocal.Y - botLocal.Y)
						v55 = v57 - (v58 + v57 + v53 - (v59 + v61))
						v51 = v56 / ((1 - (v47 + v46 - 1)) * 2)
					else
						v55 = (v32 - v53) * 0.5 * v51
					end

					surfacePart.CFrame *= new4(v54, v55, 0)
					surfacePart.Size = new(v52, v53, Z3)
					local scaleFrame = v8.ScaleFrame
					local v56 = 1 / v48
					local v57 = 1 / v49
					scaleFrame.Size = new3(v56, 0, v57, 0)
					scaleFrame.Position = new3(0.5 - (1 - v56) * 0.5 * v50, 0, 0.5 - (1 - v57) * 0.5 * v51, 0)
					local v58 = v29 > 1 and v29 or 1
					local v59 = 1 - v29
					local v60 = 0.8 - v59
					local v62 = min((1 - (v30 + v59)) / v60, 1) * v58
					local v63 = v62 < 0 and 1 or v62
					local textureTransparency = mergedSettings.TextureTransparency
					local backgroundTransparency = mergedSettings.BackgroundTransparency
					local imageTransparency = textureTransparency + (mergedSettings.TextureTransparencyMin - textureTransparency) * v63
					local backgroundTransparency2 = backgroundTransparency + (mergedSettings.BackgroundTransparencyMin - backgroundTransparency) * v63
					local v66 = 1 / (v30 + (v29 - v30) * (effectRadiusMin / effectRadius))
					local v67 = 1 / v66
					local position3 = surfacePart.Position
					local targetNormal = v8.TargetNormal
					local v69 = toNormalSpace(targetCF, position3 - targetNormal * position3:Dot(targetNormal), k)
					local v70 = (v67 - 1) * 3 * v66
					local v71 = -(1 - v48) / 0.5 * v50
					local v72 = -(1 - v49) / 0.5 * v51
					local textureOffset = mergedSettings.TextureOffset
					local v73 = -textureOffset.X / X3 * v66
					local v74 = textureSize.Y / X3
					local v75 = v74 - 1
					local v76 = -textureOffset.Y / X3 * v66
					local v77 = v31 * 0.5
					local v78 = v69.X / v77 * v66
					local v79 = v69.Y / v77 * v66
					local v80 = v75 * v66
					local uDim = new3(max(0.111 * v66, 0.001), 0, max(0.111 * v66 * v74, 0.001), 0)
					local v85 = (v67 - 1) * v66
					local v86 = v30 < 0.125
					local tileMeta = v8.TileMeta

					for i = 1, #tileMeta do
						local v87 = tileMeta[i]
						local imageLabel = v87.ImageLabel
						imageLabel.ImageTransparency = imageTransparency
						imageLabel.BackgroundTransparency = backgroundTransparency2
						local mult = v87.Mult
						local v88 = v85 * mult.OffsetX
						local v89 = v85 * mult.OffsetY
						local v90 = v73 + v88 + v71 + v70 + v78
						local v91 = v76 + v89 + v72 + v70 + v79
						imageLabel.TileSize = uDim

						if i <= 3 then
							v91 -= v80
						elseif i >= 7 then
							v91 += v80
						end

						local v92 = updateTextureOffset(v90, v91, v66, v66 * v74)
						local scale = v92.X.Scale
						local scale2 = v92.Y.Scale
						local v93 = 0
						local v94 = 0

						if scale > 4.5 then
							v93 = scale - 4.5
						elseif scale < -3.5 then
							v93 = scale + 3.5
						end

						if scale2 > 4.5 then
							v94 = scale2 - 4.5
						elseif scale2 < -3.5 then
							v94 = scale2 + 3.5
						end

						local v95 = -v93
						local v96 = -v94

						if v94 < 0 then
							if v86 then
								v96 = -v94 or v66
							else
								v96 = v66
							end
						end

						if v93 < 0 then
							if v86 then
								v95 = -v93 or v66
							else
								v95 = v66
							end
						end

						imageLabel.Position = new3(scale + v95, 0, scale2 + v96, 0)

						if v87.IsSide then
							updateSideGradient(v87, v8)
						elseif v87.IsCorner then
							updateCornerGradient(v87, v8)
						end
					end
				end
			end
		end
	end
end

return DistanceFade