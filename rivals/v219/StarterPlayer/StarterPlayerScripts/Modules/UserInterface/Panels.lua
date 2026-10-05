local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local Spring = require(ReplicatedStorage.Modules.Spring)
require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local PageSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PageSystem"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Part = Instance.new("Part")
	self.SurfaceGui = Instance.new("SurfaceGui")
	self.PagesFrame = Instance.new("Frame")
	self.PageSystem = PageSystem.new(self.PagesFrame)
	self._previous_part_offset = CFrame.identity
	self._part_offset = nil
	self._offset_spring = Spring.new(1, 1, 15)
	self._raycast_params = RaycastParams.new()
	self._next_raycast = 0
	self:_Init()
	return self
end

function class:_Debug()
	RunService.RenderStepped:Connect(function()
		self:_Update()
	end)
	Pages.Frame.Visible = false
	Pages.PageSystem.PageOpened:Connect(function()
		self.PageSystem:OpenPage(Pages.PageSystem.CurrentPage.Name)
	end)
	Pages.PageSystem.PageClosed:Connect(function()
		self.PageSystem:CloseCurrentPage()
	end)
end

function class:_Update()
	local cameraCFrame = CameraController:GetCameraCFrame()

	if self._offset_spring.Value >= 0.75 and (not self._part_offset or tick() > self._next_raycast and not workspace:Raycast(
		cameraCFrame.Position,
		cameraCFrame.LookVector * 20,
		self._raycast_params
	)) then
		self._previous_part_offset = self._previous_part_offset:Lerp(
			self._part_offset or CFrame.identity,
			self._offset_spring.Value
		)
		self._part_offset = workspace.CurrentCamera.CFrame.Rotation * CFrame.new(0, 0, -7)
		self._offset_spring.Value = 0
		self._next_raycast = tick() + 0.25
	end

	self.Part.CFrame = CFrame.new(cameraCFrame.Position) * self._previous_part_offset:Lerp(
		self._part_offset,
		self._offset_spring.Value
	)
end

function class:_Setup()
	self.Part.Color = Color3.fromRGB(0, 0, 0)
	self.Part.Transparency = 1
	self.Part.Size = createVector(16, 9, 1)
	self.Part.Anchored = true
	self.Part.CastShadow = false
	self.Part.CanCollide = false
	self.Part.CanTouch = false
	self.Part.CanQuery = true
	self.Part.Name = "Panel"
	self.Part.Parent = workspace
	self.SurfaceGui.MaxDistance = 100
	self.SurfaceGui.Adornee = self.Part
	self.SurfaceGui.AlwaysOnTop = false
	self.SurfaceGui.LightInfluence = 0
	self.SurfaceGui.Brightness = 2
	self.SurfaceGui.Name = "PanelsGui"
	self.SurfaceGui.Face = Enum.NormalId.Back
	self.SurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	self.SurfaceGui.PixelsPerStud = 100
	self.SurfaceGui.ResetOnSpawn = false
	self.SurfaceGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	self.PagesFrame.Size = UDim2.new(1, 0, 1, 0)
	self.PagesFrame.BackgroundTransparency = 1
	self.PagesFrame.Name = "Pages"
	self.PagesFrame.Parent = self.SurfaceGui
	self._raycast_params = RaycastParams.new()
	self._raycast_params.FilterType = Enum.RaycastFilterType.Include
	self._raycast_params.FilterDescendantsInstances = { self.Part }
	self._raycast_params.BruteForceAllSlow = true
	self._raycast_params.IgnoreWater = true
end

function class:_Init()
	self.PageSystem.PageOpened:Connect(function(p)
		local uIAspectRatioConstraint = p.PageFrame:FindFirstChildOfClass("UIAspectRatioConstraint")
		local aspectRatio = uIAspectRatioConstraint and uIAspectRatioConstraint.AspectRatio or p.PageFrame.Size.X.Scale / p.PageFrame.Size.Y.Scale
		self.Part.Size = Vector3.new(8, 8 / aspectRatio, 1)
		p.PageFrame.Size = UDim2.new(0, 0, 0, 0)
		p.PageFrame.Position = UDim2.new(0.5, 0, 1, 0)
		p.PageFrame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 0.5, true)
		p.PageFrame:TweenSize(UDim2.new(0.75, 0, 0.75, 0), "Out", "Quint", 0.25, true)
	end)
	self:_Setup()
end

return class._new()