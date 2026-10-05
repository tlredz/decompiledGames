local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ToolGrid = require(script.Parent:WaitForChild("ToolGrid"))
local Inventory = require(script.Parent.Parent:WaitForChild("State"):WaitForChild("Inventory"))
local Backpack3D = {}
Backpack3D.__index = Backpack3D

function Backpack3D.new(parent, p)
	local object = setmetatable({
		Opened = false
	}, Backpack3D)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "NexusVRBackpack"
	surfaceGui.AlwaysOnTop = true
	surfaceGui.Enabled = false
	surfaceGui.LightInfluence = 0
	surfaceGui.Face = Enum.NormalId.Back
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 250
	surfaceGui.Parent = parent
	object.SurfaceGui = surfaceGui
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Size = createVector(0, 0, 0)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Parent = surfaceGui
	surfaceGui.Adornee = part
	object.Part = part
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Parent = surfaceGui
	object.CenterFrame = frame
	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = Color3.new(1, 1, 1)
	frame2.Size = UDim2.new(0.1, 0, 0.1, 0)
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.ZIndex = 10
	frame2.Parent = frame
	object.Cursor = frame2
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = frame2
	local toolGrid = ToolGrid.new()
	toolGrid.AdornFrame.Size = UDim2.new(0, 0, 0, 0)
	toolGrid.AdornFrame.Parent = frame
	object.ToolGrid = toolGrid
	local inventory = Inventory.new(p)
	object.Inventory = inventory
	inventory.ToolsChanged:Connect(function()
		object:UpdateInventory()
	end)
	object:UpdateInventory()
	return object
end

function Backpack3D.GetFocusedTool(p)
	return p.ToolGrid.FocusedIcon and p.ToolGrid.FocusedIcon.Tool
end

function Backpack3D:UpdateInventory()
	self.ToolGrid:SetTools(self.Inventory.Tools)
	local v = (#self.ToolGrid.IconGroups * 2 + 1) * 0.8660254037844386
	self.Part.Size = Vector3.new(v * 0.5, v * 0.5, 0)
	self.CenterFrame.Size = UDim2.new(1 / v, 0, 1 / v, 0)
end

function Backpack3D:UpdateFocusedToolLocalSpace(p: number, p2: number)
	if not self.Opened then
		return
	end

	local v = self.SurfaceGui.AbsoluteSize.X * p
	local v2 = self.SurfaceGui.AbsoluteSize.Y * p2
	local v3 = (v - self.CenterFrame.AbsolutePosition.X) / self.CenterFrame.AbsoluteSize.X
	local v4 = (v2 - self.CenterFrame.AbsolutePosition.Y) / self.CenterFrame.AbsoluteSize.Y
	self.Cursor.Position = UDim2.new(v3, 0, v4, 0)
	self.ToolGrid:UpdateFocusedIcon(v3, v4)
end

function Backpack3D:UpdateFocusedToolWorldSpace(position: Vector3)
	local v = self.Part.CFrame:Inverse() * CFrame.new(position)
	local size = self.Part.Size
	self:UpdateFocusedToolLocalSpace(v.X / size.X + 0.5, 0.5 - v.Y / size.Y)
end

function Backpack3D.MoveTo(p, cFrame: CFrame)
	p.Part.CFrame = cFrame
end

function Backpack3D:Open()
	if self.Opened then
		return
	end

	self.Opened = true
	self.SurfaceGui.Enabled = true
	TweenService:Create(self.ToolGrid.AdornFrame, TweenInfo.new(0.1), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
end

function Backpack3D:Close()
	if not self.Opened then
		return
	end

	self:UpdateFocusedToolLocalSpace(1e999, 1e999)
	self.Opened = false
	TweenService:Create(self.ToolGrid.AdornFrame, TweenInfo.new(0.1), {
		Size = UDim2.new(0, 0, 0, 0)
	}):Play()
	task.delay(0.1, function()
		if self.Opened then
			return
		end

		self.SurfaceGui.Enabled = false
	end)
end

function Backpack3D:Destroy()
	self.SurfaceGui:Destroy()
	self.ToolGrid:Destroy()
	self.Inventory:Destroy()
end

return Backpack3D