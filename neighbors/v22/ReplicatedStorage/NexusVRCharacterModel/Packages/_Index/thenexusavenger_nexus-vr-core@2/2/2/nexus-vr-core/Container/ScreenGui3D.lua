local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local NexusInstance = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local BaseScreenGui = require(script.Parent:WaitForChild("BaseScreenGui"))
local v = {
	ClassName = "ScreenGui3D"
}
v.__index = v
setmetatable(v, BaseScreenGui)

function v:__new()
	BaseScreenGui.__new(self, Instance.new("SurfaceGui"))
	local parent = Workspace.CurrentCamera:FindFirstChild("NexusVRCoreContainer")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "NexusVRCoreContainer"
		parent.Parent = Workspace.CurrentCamera
	end

	local part = Instance.new("Part")
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Parent = parent
	self.Adornee = part
	self.Face = Enum.NormalId.Back
	self.AlwaysOnTop = true
	self:OnPropertyChanged("PointingEnabled", function()
		self.Adornee.CanQuery = self.Enabled and self.PointingEnabled
	end)
	self:OnPropertyChanged("Enabled", function()
		self.Adornee.CanQuery = self.Enabled and self.PointingEnabled
	end)
	self:DisableChangeReplication("DisplayOrder")
	self:DisableChangeReplication("IgnoreGuiInset")
	self:DisableChangeReplication("LastRotation")
	self.LastRotation = CFrame.new(Workspace.CurrentCamera:GetRenderCFrame().Position):Inverse() * Workspace.CurrentCamera:GetRenderCFrame()
	self:OnPropertyChanged("Depth", function()
		self:UpdateSize()
	end)
	self:OnPropertyChanged("FieldOfView", function()
		self:UpdateSize()
	end)
	self:OnPropertyChanged("CanvasSize", function(_)
		self:UpdateSize()
	end)
	self:UpdateSize()
	self:DisableChangeReplication("UpdateEvent")

	if RunService:IsClient() then
		self.UpdateEvent = RunService.RenderStepped:Connect(function(dt: number)
			if self.Enabled then
				self:UpdateCFrame(dt)
			end
		end)
	end
end

function v:UpdateSize()
	local v2 = math.tan(self.FieldOfView / 2) * 2 * self.Depth
	local canvasSize = self.CanvasSize

	if canvasSize.Y <= canvasSize.X then
		self.Adornee.Size = Vector3.new(v2, v2 * (self.CanvasSize.Y / self.CanvasSize.X), 0)
	else
		self.Adornee.Size = Vector3.new(v2 * (self.CanvasSize.X / self.CanvasSize.Y), v2, 0)
	end

	self.CanvasSize = self.CanvasSize
end

function v:UpdateCFrame(p: number)
	local v2 = p or self.Easing
	local renderCFrame = Workspace.CurrentCamera:GetRenderCFrame()
	local lastRotation = CFrame.new(renderCFrame.Position):Inverse() * renderCFrame

	if self.Easing == 0 then
		self.LastRotation = lastRotation
	else
		self.LastRotation = self.LastRotation:Lerp(lastRotation, (math.clamp(v2 / self.Easing, 0, 1)))
	end

	self.Adornee.CFrame = CFrame.new(renderCFrame.Position) * self.LastRotation * self.RotationOffset * CFrame.new(
		0,
		0,
		-self.Depth
	)
end

function v:Destroy()
	BaseScreenGui.Destroy(self)

	if self.UpdateEvent then
		self.UpdateEvent:Disconnect()
		self.UpdateEvent = nil
	end

	self.Adornee:Destroy()
end

return (NexusInstance.ToInstance(v))