local createVector = vector.create
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")
local CrackManager = require(script.CrackManager)
local BufferManager = require(script.BufferManager)
local ParallelTasks = require(script.ParallelWorker.ParallelTasks)
local thrown = workspace:WaitForChild("Thrown")
local currentCamera = workspace.CurrentCamera
local playerGui = Players.LocalPlayer.PlayerGui
local GroundCrack = {}
GroundCrack.__index = GroundCrack
local v = BufferManager.new(function()
	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	viewportFrame.Size = UDim2.new(1, 0, 1, 0)
	viewportFrame.BackgroundTransparency = 1
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewportFrame
	return viewportFrame
end)
local v2 = BufferManager.new(function()
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.ResetOnSpawn = false
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.ClipsDescendants = true
	return surfaceGui
end)
local v3 = BufferManager.new(function()
	return Instance.new("Camera")
end)
local v4 = BufferManager.new(function()
	return Instance.new("Part")
end)

local function SetDefaults(instance)
	if instance:IsA("Part") then
		instance.Size = createVector(1, 1, 1)
		instance.CFrame = CFrame.new()
		instance.Transparency = 0
		instance.Anchored = false
		instance.CanCollide = true
		instance.CanTouch = true
		instance.CanQuery = true
		instance.Color = Color3.new(1, 1, 1)
		instance.Material = Enum.Material.Plastic
		instance.CastShadow = true
		instance.Name = "Part"
	elseif instance:IsA("SurfaceGui") then
		instance.Adornee = nil
		instance.ResetOnSpawn = true
		instance.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		instance.PixelsPerStud = 50
		instance.ClipsDescendants = false
		instance.Face = Enum.NormalId.Front
		instance.ZIndexBehavior = Enum.ZIndexBehavior.Global
		instance.Enabled = true
		instance.Brightness = 1
		instance.LightInfluence = 1
		instance.AlwaysOnTop = false
		instance.ToolPunchThroughDistance = 0
		instance.Name = "SurfaceGui"
		instance.Parent = nil
	elseif instance:IsA("ViewportFrame") then
		instance.CurrentCamera = nil
		instance.AnchorPoint = Vector2.new(0, 0)
		instance.Size = UDim2.new(0, 100, 0, 100)
		instance.Position = UDim2.new(0, 0, 0, 0)
		instance.LightDirection = createVector(-1, -1, -1)
		instance.BackgroundTransparency = 0
		instance.BorderSizePixel = 1
		instance.Ambient = Color3.new(1, 1, 1)
		instance.Name = "ViewportFrame"
	end
end

function GroundCrack.new(model, cframe: CFrame, vector2: Vector3?)
	print("NEW CRACK")
	local self = setmetatable({}, GroundCrack)
	local surfaceGui = v2:get()
	SetDefaults(surfaceGui)
	local viewport = v:get()
	SetDefaults(viewport)
	local part = v4:get()
	SetDefaults(part)
	local vCam = v3:get()
	self.SurfaceGui = surfaceGui
	self.Viewport = viewport
	self.Part = part
	self.vCam = vCam
	self.Model = model
	self:_setInstanceProps()
	self:setCFrame(cframe or CFrame.new())
	self:setSize(vector2 or createVector(45, 0.15, 45))
	self:_updateSurfaceInfo()
	CrackManager:add(self)
	return self
end

function GroundCrack:_setInstanceProps()
	local surfaceGui = self.SurfaceGui
	local viewport = self.Viewport
	local part = self.Part
	local vCam = self.vCam
	local model = self.Model
	surfaceGui.Parent = playerGui
	surfaceGui.Name = "GroundCrackSurfaceGui"
	surfaceGui.ResetOnSpawn = false
	surfaceGui.Adornee = part
	surfaceGui.Face = Enum.NormalId.Top
	surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	surfaceGui.MaxDistance = 1000
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 1000
	surfaceGui.ClipsDescendants = true
	viewport.Parent = surfaceGui
	viewport.CurrentCamera = vCam
	viewport.AnchorPoint = Vector2.new(0.5, 0.5)
	viewport.Position = UDim2.new(0.5, 0, 0.5, 0)
	viewport.Size = UDim2.new(1, 0, 1, 0)
	viewport.BackgroundTransparency = 1
	vCam.Parent = viewport
	part.Parent = thrown
	part.Transparency = 1
	part.Anchored = true

	local function TestWeld()
		part.Anchored = false
		local weld = Instance.new("Weld")
		weld.Part0 = part
		weld.Part1 = game.Players.ILuvMrCool.Character.Torso
		weld.C0 = CFrame.new(0, 0, 0.5) * CFrame.Angles(-1.5707963267948966, 0, 0)
		weld.Parent = part
	end

	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Name = "Crackpart"
	print(part)
	model.Parent = viewport
end

function GroundCrack:setCFrame(cFrame: CFrame)
	self.CFrame = cFrame
	self.Part.CFrame = self.CFrame
	self.Model:PivotTo(self.Part.CFrame * CFrame.new(0, -self.Model.PrimaryPart.Size.Y / 2, 0))
	self:_updateSurfaceInfo()
end

function GroundCrack.getCFrame(p)
	return p.CFrame
end

function GroundCrack:setSize(size: Vector3)
	self.Size = size
	self.Part.Size = self.Size
	self:_updateSurfaceInfo()
end

function GroundCrack.getSize(p)
	return p.Size
end

function GroundCrack:_updateSurfaceInfo()
	local part = self.Part
	local cFrame = part.CFrame
	local size = part.Size
	local surfaceInfo, size2 = ParallelTasks.CalculateSurfaceInfo(cFrame, size)
	self.SurfaceInfo = {
		cf = surfaceInfo,
		size = size2
	}
end

function GroundCrack.updateCamera(data)
	local cFrame = currentCamera.CFrame
	local cf = data.SurfaceInfo.cf
	local size = data.SurfaceInfo.size
	local y = currentCamera.ViewportSize.y

	if not (cf and size) then
		return
	end

	local cameraProperties, v5, v6, v7, fieldOfView = ParallelTasks.CalculateCameraProperties(cFrame, cf, size, y)
	local viewport = data.Viewport
	viewport.Position = UDim2.new(viewport.AnchorPoint.x - cameraProperties, 0, viewport.AnchorPoint.y - v5, 0)
	viewport.Size = UDim2.new(v6, 0, v6, 0)
	viewport.BackgroundColor3 = data.SurfaceGui.Adornee.Color
	data.SurfaceGui.CanvasSize = Vector2.new(y * (size.x / size.y), y)
	data.vCam.FieldOfView = fieldOfView
	data.vCam.CFrame = CFrame.new(cFrame.p) * (cf - cf.p) * CFrame.Angles(0, 3.141592653589793, 0) * v7
end

function GroundCrack:Destroy()
	CrackManager:remove(self)
	v3:release(self.vCam)
	v:release(self.Viewport)
	v2:release(self.SurfaceGui)
	v4:release(self.Part)
	self.Model:Destroy()
	setmetatable(self, nil)
end

local heartbeatConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureCrackLoop()
	if heartbeatConnection or #CrackManager:getActiveCracks() == 0 then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		CrackManager:updateAllCameras()

		if #CrackManager:getActiveCracks() == 0 then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)
end

local add = CrackManager.add

function CrackManager:add(p2)
	add(self, p2)
	ensureCrackLoop() -- equivalent call inferred; original call site unknown
end

setmetatable(GroundCrack, {
	__index = function(p, p2)
		if rawget(p, p2) then
			return (rawget(p, p2))
		end

		error(string.format("'%s' is not a valid member of 'Crack'", p2), 2)
	end
})
return GroundCrack