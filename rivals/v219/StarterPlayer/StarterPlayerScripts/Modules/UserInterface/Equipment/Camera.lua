local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local Spring = require(ReplicatedStorage.Modules.Spring)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local cframe = CFrame.new(0, 0, 35)
local cframe2 = CFrame.new(0, -2, 0)
local uDim = UDim2.new(0.5, 0, -2.5, 0)
local uDim2 = UDim2.new(0.5, 0, 3.5, 0)
local Camera = {}
Camera.__index = Camera

function Camera.new(equipment)
	local self = setmetatable({}, Camera)
	self.FinishedOpenEffect = Signal.new()
	self.Equipment = equipment
	self._frame = UILibrary:GetTo("MainFrame", "Equipment", "CameraFade")
	self._look_at_attachment = nil
	self._look_at_offset = createVector(0, 0, 0)
	self._fov_spring = Spring.new(15, 0.875, 5)
	self._equipment_open_hash = 0
	self._equipment_open_start_cframe = CFrame.identity
	self._equipment_open_start = 0
	self._equipment_open_finished = true
	self._equipment_open_is_closing = false
	self._controls_connections = {}
	self._scroll_fov_spring = Spring.new(0, 1, 20)
	self._fov_zoom_direction = Vector2.zero
	self:_Init()
	return self
end

function Camera:IsOpenEffectDone()
	return self._equipment_open_finished
end

function Camera:IsClosing()
	return self._equipment_open_is_closing
end

function Camera:SetFocus(p2, p3, value, value2)
	self._look_at_attachment = p2 or nil
	self._look_at_offset = p3 or createVector(0, 0, 0)
	self._fov_spring.Target = value or 15
	self._fov_spring.Speed = value2 or 5
end

function Camera:Update(p)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	self:_IncrementFOVSpringFromInput((self._fov_zoom_direction.X - self._fov_zoom_direction.Y) * p * 60 * 0.25)
	local v = math.clamp((tick() - self._equipment_open_start) / 0.375, 0, 1)

	if v < 1 then
		local v2 = v ^ 2

		if self._equipment_open_is_closing then
			workspace.CurrentCamera.CFrame = self._equipment_open_start_cframe * CFrame.identity:Lerp(cframe2, v2)
		else
			workspace.CurrentCamera.CFrame = self._equipment_open_start_cframe * CFrame.new(0, v2 * 25, 0)
		end
	else
		local customizingType = self.Equipment:GetCustomizingType()
		local v2 = customizingType == "Finisher" or customizingType == "Emote"
		local cframe3 = self.Equipment.Scene:GetCFrame() * cframe
		local cFrame

		if self._equipment_open_finished then
			cFrame = workspace.CurrentCamera.CFrame
		else
			cFrame = cframe3 * (self:_IsOpenEffectDisabled() and CFrame.identity or cframe2)
		end

		if v2 then
			cframe3 = CFrame.new(
				cframe3.Position + createVector(0, 5, 0),
				self.Equipment.Scene:GetHumanoidCFrame().Position
			)
		elseif self._look_at_attachment then
			cframe3 = CFrame.new(cframe3.Position, self._look_at_attachment.WorldPosition + self._look_at_offset)
		end

		local cframe4 = CFrame.Angles(
			math.sin(tick() * 0.23983 % 6.283185307179586) * 0.00017453292519943296,
			math.sin(tick() * 0.372721 % 6.283185307179586) * 0.00017453292519943296,
			math.sin(tick() * 0.43123 % 6.283185307179586) * 0.00017453292519943296
		)
		local v3 = self.Equipment:IsCustomizing() and 0.025 or 0.05
		workspace.CurrentCamera.FieldOfView = self._fov_spring.Value + self._scroll_fov_spring.Value + CameraController:GetExternalFOVOffset()
		workspace.CurrentCamera.CFrame = CFrame.new(cFrame.Position:Lerp(cframe3.Position, 0.1)) * cFrame.Rotation:Lerp(
			cframe3.Rotation,
			v3
		) * cframe4

		if not self._equipment_open_finished then
			self._equipment_open_finished = true
			self.FinishedOpenEffect:Fire()
		end
	end
end

function Camera.OnStateChanged(p)
	p.Equipment:IsCustomizing()
end

function Camera:OnOpen()
	task.spawn(CameraController.CameraState.SetCustomFreecamEnabled, CameraController.CameraState, false)
	CameraController:Freeze(self.Equipment.IsOpen)
	self:_VerifyControls()

	if self.Equipment.IsOpen then
		self._scroll_fov_spring.Target = 0
		self._scroll_fov_spring.Value = 0

		if self:_IsOpenEffectDisabled() then
			self._equipment_open_hash += 1
			self._equipment_open_is_closing = false
			self._equipment_open_start_cframe = CFrame.identity
			self._equipment_open_start = 0
			self._equipment_open_finished = false
			self.FinishedOpenEffect:Fire()
		else
			self._equipment_open_hash += 1
			self._equipment_open_is_closing = false
			self._equipment_open_start_cframe = workspace.CurrentCamera.CFrame
			self._equipment_open_start = tick()
			self._equipment_open_finished = false
			self.FinishedOpenEffect:Fire()
			self._frame.Position = uDim
			self._frame:TweenPosition(uDim2, "InOut", "Quint", 0.9375, true)
			Utility:CreateSound("rbxassetid://106551800007995", 1.5, 1 + 0.2 * math.random(), script, true, 5)
		end
	end
end

function Camera:CloseEffect()
	if self:_IsOpenEffectDisabled() then
		self._equipment_open_hash += 1
		self._equipment_open_is_closing = true
		self._equipment_open_start_cframe = CFrame.identity
		self._equipment_open_start = 0
		self._equipment_open_finished = true
		self.FinishedOpenEffect:Fire()
	else
		self._equipment_open_hash += 1
		self._equipment_open_is_closing = true
		self._equipment_open_start_cframe = workspace.CurrentCamera.CFrame
		self._equipment_open_start = tick()
		self._equipment_open_finished = false
		self.FinishedOpenEffect:Fire()
		self._frame.Position = uDim2
		self._frame:TweenPosition(uDim, "InOut", "Quint", 0.75, true)
		Utility:CreateSound("rbxassetid://106551800007995", 1.25, 0.8 + 0.2 * math.random(), script, true, 5)
		local _equipment_open_hash = self._equipment_open_hash
		wait(0.375)

		if _equipment_open_hash ~= self._equipment_open_hash then
			return
		end

		if not self._equipment_open_finished then
			self._equipment_open_finished = true
			self.FinishedOpenEffect:Fire()
		end
	end
end

function Camera:_IsOpenEffectDisabled()
	return GuiService.ReducedMotionEnabled
end

function Camera:_IncrementFOVSpringFromInput(p2)
	self._scroll_fov_spring.Target = math.clamp(self._scroll_fov_spring.Target + p2, -10, 10)
end

function Camera:_VerifyControls()
	for _, _controls_connection in pairs(self._controls_connections) do
		_controls_connection:Disconnect()
	end

	self._controls_connections = {}
	self._fov_zoom_direction = Vector2.zero

	if not self.Equipment.IsOpen then
		return
	end

	table.insert(self._controls_connections, UserInputService.TouchPinch:Connect(function(_, _, p, _, p2)
		if p2 then
			return
		end

		self:_IncrementFOVSpringFromInput(p * -0.25)
	end))
	table.insert(self._controls_connections, UserInputService.InputChanged:Connect(function(input, _)
		if Pages.PageSystem.CurrentPage or input.UserInputType ~= Enum.UserInputType.MouseWheel or UILibrary:IsMouseWithinBounds(
			self.Equipment.Interface.Left.Frame.AbsolutePosition,
			self.Equipment.Interface.Left.Frame.AbsoluteSize
		) then
			return
		end

		if UILibrary:IsMouseWithinBounds(
			self.Equipment.Interface.Right.Frame.AbsolutePosition,
			self.Equipment.Interface.Right.Frame.AbsoluteSize
		) then
			return
		end

		if UILibrary:IsMouseWithinBounds(
			self.Equipment.Interface.Customize.Cosmetics.List.AbsolutePosition,
			self.Equipment.Interface.Customize.Cosmetics.List.AbsoluteSize
		) then
			return
		end

		self:_IncrementFOVSpringFromInput(input.Position.Z * -1)
	end))
	table.insert(self._controls_connections, UserInputService.InputBegan:Connect(function(input, _)
		if input.KeyCode == Enum.KeyCode.ButtonL2 then
			self._fov_zoom_direction = Vector2.new(1, self._fov_zoom_direction.Y)
		elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
			self._fov_zoom_direction = Vector2.new(self._fov_zoom_direction.X, 1)
		end
	end))
	table.insert(self._controls_connections, UserInputService.InputEnded:Connect(function(input, _)
		if input.KeyCode == Enum.KeyCode.ButtonL2 then
			self._fov_zoom_direction = Vector2.new(0, self._fov_zoom_direction.Y)
		elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
			self._fov_zoom_direction = Vector2.new(self._fov_zoom_direction.X, 0)
		end
	end))
end

function Camera:_UpdateFocus()
	local customizingType = self.Equipment:GetCustomizingType()
	self._look_at_offset = customizingType == "Charm" and createVector(0, -0.075, 0) or createVector(0, 0, 0)
	local look_at_attachment

	if customizingType == "Charm" and self.Equipment.FloatingModel then
		look_at_attachment = self.Equipment.FloatingModel:GetCharmPivotAttachment() or nil
	end

	self._look_at_attachment = look_at_attachment
	self._fov_spring.Speed = Pages.PageSystem.CurrentPage and 15 or 5
	self._fov_spring.Target = customizingType == "Finisher" and 40 or customizingType == "Emote" and 25 or customizingType == "Charm" and 5 or customizingType and 12.5 or Pages.PageSystem.CurrentPage and 20 or 15
end

function Camera:_Setup()
	self._frame.Parent = UILibrary.MainGui
end

function Camera:_Init()
	self.Equipment.CustomizingChanged:Connect(function()
		self:_UpdateFocus()
	end)
	self.Equipment.CharmAttachmentVisibleChanged:Connect(function()
		self:_UpdateFocus()
	end)
	Pages.PageSystem.PagesActivity:Connect(function()
		self:_UpdateFocus()
	end)
	self:_Setup()
	self:_UpdateFocus()
end

return Camera