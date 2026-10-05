local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local Signal = require(ReplicatedStorage.Modules.Signal)
local Scope = {}
Scope.__index = Scope

function Scope.new(mouse)
	local self = setmetatable({}, Scope)
	self.ActiveChanged = Signal.new()
	self.Mouse = mouse
	self.Frame = self.Mouse.Frame:WaitForChild("Scope")
	self.BlurFrame = self.Frame:WaitForChild("Blur")
	self.BlurImage = self.BlurFrame:WaitForChild("ImageLabel")
	self.ReticleFrame = self.Frame:WaitForChild("Reticle")
	self.ReticleContainer = self.ReticleFrame:WaitForChild("Container")
	self.ReticleContainerHorizontal = self.ReticleContainer:WaitForChild("Horizontal")
	self.ReticleContainerVertical = self.ReticleContainer:WaitForChild("Vertical")
	self.ReticleContainerBottom = self.ReticleContainer:WaitForChild("Bottom")
	self.ReticleContainerTop = self.ReticleContainer:WaitForChild("Top")
	self.ReticleContainerLeft = self.ReticleContainer:WaitForChild("Left")
	self.ReticleContainerRight = self.ReticleContainer:WaitForChild("Right")
	self.ReticleContainerDot = self.ReticleContainer:WaitForChild("Dot")
	self.ReticleContainerDotUICorner = self.ReticleContainerDot:WaitForChild("UICorner")
	self.CircleFrame = self.Frame:WaitForChild("Circle")
	self.CircleImage = self.CircleFrame:WaitForChild("ImageLabel")
	self.CircleImageBottom = self.CircleImage:WaitForChild("Bottom")
	self.CircleImageTop = self.CircleImage:WaitForChild("Top")
	self.CircleImageLeft = self.CircleImage:WaitForChild("Left")
	self.CircleImageRight = self.CircleImage:WaitForChild("Right")
	self._destroyed = false
	self._is_scope_active = false
	self._dont_rotate_scope_while_sliding = false
	self._scope_dot_spring = Spring.new(1, 1, 50)
	self:_Init()
	return self
end

function Scope:IsActive()
	return self._is_scope_active
end

function Scope:SetActive(is_scope_active)
	if self._destroyed then
		return
	end

	assert(typeof(is_scope_active) == "boolean", "Argument 1 invalid, expected a boolean")
	self._is_scope_active = is_scope_active
	self.ActiveChanged:Fire()
	self.Frame.Visible = self._is_scope_active and CONSTANTS.DEVICE ~= "VR"
	local scopedRedDotColor = self.Mouse.MouseCrosshair.Crosshair:GetScopedRedDotColor() or "#ff3232"
	local visible = not self.Mouse.MouseCrosshair.Crosshair:IsScopedRedDotDisabled()
	local visible2 = not self.Mouse.MouseCrosshair.Crosshair:IsScopedBarsDisabled()
	self.ReticleContainerDot.BackgroundColor3 = Utility:Color3FromHex(scopedRedDotColor)
	self.ReticleContainerDot.Visible = visible
	self.ReticleContainerBottom.Visible = visible2
	self.ReticleContainerTop.Visible = visible2
	self.ReticleContainerLeft.Visible = visible2
	self.ReticleContainerRight.Visible = visible2
	self.ReticleContainerVertical.Visible = visible2
	self.ReticleContainerHorizontal.Visible = visible2

	if not self._is_scope_active then
		return
	end

	self.BlurFrame.Size = UDim2.new(0.5, 0, 0.5, 0)
	self.BlurFrame:TweenSize(
		UDim2.new(1, 0, 1, 0),
		"Out",
		"Quint",
		0.5 / (self.Mouse.ItemInterface.ClientItem.Info.AimSpeed or 1),
		true
	)
	self.BlurFrame.Position = UDim2.new(0.75, 0, 0.75, 0)
	self.BlurFrame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 0.375, true)
end

function Scope:Update(_, _, _)
	if not self._is_scope_active then
		return
	end

	if self._dont_rotate_scope_while_sliding then
		self.Frame.Rotation = -self.Mouse.Frame.Rotation
		self.ReticleFrame.Rotation = self.Mouse.Frame.Rotation
	end

	local currentLandingValue = self.Mouse.ItemInterface.ClientItem.ViewModel.CurrentLandingValue
	local v = self.Mouse.ItemInterface.ClientItem.ViewModel.CurrentJumpValue * 0.0025 - currentLandingValue * 0.125
	self.BlurImage.Position = UDim2.new(0.5, 0, 0.5 + v, 0)
	local raycastWhitelist = self.Mouse.ItemInterface.ClientItem.ClientFighter:GetRaycastWhitelist(
		true,
		nil,
		nil,
		self.Mouse.ItemInterface.ClientItem.Info.RaycastGrabSmallHitboxes
	)
	local cameraData = self.Mouse.ItemInterface.ClientItem.ClientFighter:GetCameraData(raycastWhitelist, nil, true)
	local v2 = cameraData[utf8.char(2)]
	local v3 = cameraData[utf8.char(3)]
	local v4 = not v2 and 1e999 or (workspace.CurrentCamera.CFrame.Position - (v2.CFrame * v3).Position).Magnitude
	self._scope_dot_spring.Target = 12 / math.max(1, v4 / 50)
	local v5 = self._scope_dot_spring.Value / 8
	self.ReticleContainerDot.Size = UDim2.new(0.008 * v5, 0, 0.008 * v5, 0)
end

function Scope:Destroy()
	self._destroyed = true
	self.ActiveChanged:Destroy()
end

function Scope:_Setup()
	if self.Mouse.ItemInterface.ClientItem.ViewModel.Name == "Pixel Sniper" then
		self.BlurImage.Image = "rbxassetid://18171031143"
		self.BlurImage.ResampleMode = Enum.ResamplerMode.Pixelated
		self.CircleImage.Image = "rbxassetid://18171045114"
		self.CircleImage.ResampleMode = Enum.ResamplerMode.Pixelated
		self.ReticleContainerDotUICorner:Destroy()
	elseif self.Mouse.ItemInterface.ClientItem.ViewModel.Name == "Keyper" then
		self.BlurImage.Image = "rbxassetid://129335242148588"
		self.BlurImage.Size = UDim2.new(1.25, 0, 1.25, 0)
		self.CircleImage.Image = "rbxassetid://81498448678518"
		self.CircleImage.Size = UDim2.new(1.25, 0, 1.25, 0)
		self._dont_rotate_scope_while_sliding = true
	elseif self.Mouse.ItemInterface.ClientItem.ViewModel.Name == "Pixel Crossbow" then
		self.CircleImage.Image = "rbxassetid://97622703342015"
		self.CircleImage.ResampleMode = Enum.ResamplerMode.Pixelated
		self.ReticleContainerDotUICorner:Destroy()
	end
end

function Scope:_Init()
	self:_Setup()
end

return Scope