game:GetService("HttpService")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
local _ = CFrame.new(0, 0, -1.1) * CFrame.Angles(0, 1.5707963267948966, 0)
local ScopeModifier = {}
ScopeModifier.__index = ScopeModifier

function ScopeModifier.new(itemInterface)
	local self = setmetatable({}, ScopeModifier)
	self.ItemInterface = itemInterface
	self.CanvasGroup = Instance.new("CanvasGroup")
	self.CanvasGroupUICorner = Instance.new("UICorner")
	self.CanvasGroupImage = self.ItemInterface.Mouse.Scope.BlurImage:Clone()
	self._glass = Instance.new("Part")
	self._dof = Instance.new("DepthOfFieldEffect")
	self._glass_renderstep_id = nil
	self:_Init()
	return self
end

function ScopeModifier:SetShape(shape)
	self._glass.Shape = shape
	self.ItemInterface.Mouse.Scope.Frame.Size = shape == Enum.PartType.Block and UDim2.new(0.875, 0, 0.875, 0) or UDim2.new(
		1,
		0,
		1,
		0
	)
	self.ItemInterface.Mouse.Scope.CircleImage.Image = shape == Enum.PartType.Block and "rbxassetid://85501091107884" or "rbxassetid://128819262942122"
	self.CanvasGroupUICorner.CornerRadius = shape == Enum.PartType.Block and UDim.new(0, 0) or UDim.new(1, 0)
	self.CanvasGroupImage.Image = shape == Enum.PartType.Block and "rbxassetid://102865472475647" or "rbxassetid://13466088854"
end

function ScopeModifier:Refresh()
	if self._glass_renderstep_id then
		RunService:UnbindFromRenderStep(self._glass_renderstep_id)
		self._glass_renderstep_id = nil
	end

	self._glass.Parent = nil
	self._dof.Parent = nil
end

function ScopeModifier:Destroy()
	if self._glass_renderstep_id then
		RunService:UnbindFromRenderStep(self._glass_renderstep_id)
		self._glass_renderstep_id = nil
	end

	self._glass:Destroy()
	self._dof:Destroy()
end

function ScopeModifier:_Setup()
	self._glass.Color = Color3.fromRGB(255, 255, 255)
	self._glass.Material = Enum.Material.Glass
	self._glass.Transparency = 0.999
	self._glass.Anchored = true
	self._glass.CanCollide = false
	self._glass.CanQuery = false
	self._glass.CanTouch = false
	self._glass.CastShadow = false
	self._glass.Name = "CrossbowScope"
	self._dof.FarIntensity = 1
	self._dof.FocusDistance = 0
	self._dof.InFocusRadius = 0.2
	self._dof.NearIntensity = 0
	self._dof.Name = "CrossbowScope"
	self.ItemInterface.Mouse.Scope.CircleImageBottom.Visible = false
	self.ItemInterface.Mouse.Scope.CircleImageTop.Visible = false
	self.ItemInterface.Mouse.Scope.CircleImageLeft.Visible = false
	self.ItemInterface.Mouse.Scope.CircleImageRight.Visible = false
	self.ItemInterface.Mouse.Scope.BlurImage.Visible = false
	self.ItemInterface.Mouse.Scope.ReticleContainerBottom.Size = UDim2.new(0, 4, 0.25, 0)
	self.ItemInterface.Mouse.Scope.ReticleContainerTop.Size = UDim2.new(0, 4, 0.25, 0)
	self.ItemInterface.Mouse.Scope.ReticleContainerLeft.Size = UDim2.new(0.25, 0, 0, 4)
	self.ItemInterface.Mouse.Scope.ReticleContainerRight.Size = UDim2.new(0.25, 0, 0, 4)
	self.CanvasGroup.BackgroundTransparency = 1
	self.CanvasGroup.Size = UDim2.new(1, 0, 1, 0)
	self.CanvasGroup.Parent = self.ItemInterface.Mouse.Scope.Frame
	self.CanvasGroupUICorner.Parent = self.CanvasGroup
	self.CanvasGroupImage.Parent = self.CanvasGroup
	self:SetShape(Enum.PartType.Cylinder)

	if self.ItemInterface.ClientItem.ViewModel.Name == "Pixel Crossbow" then
		self.CanvasGroupImage.Image = "rbxassetid://18171031143"
		self.CanvasGroupImage.ResampleMode = Enum.ResamplerMode.Pixelated
	end
end

function ScopeModifier:_Init()
	self.ItemInterface.Mouse.Scope.ActiveChanged:Connect(function()
		self:Refresh()
	end)
	self.ItemInterface.ActiveChanged:Connect(function()
		self:Refresh()
	end)
	self.ItemInterface.Mouse.Scope.BlurFrame:GetPropertyChangedSignal("Position"):Connect(function()
		self.CanvasGroupImage.Position = self.ItemInterface.Mouse.Scope.BlurFrame.Position
	end)
	self.ItemInterface.Mouse.Scope.BlurFrame:GetPropertyChangedSignal("Size"):Connect(function()
		self.CanvasGroupImage.Size = self.ItemInterface.Mouse.Scope.BlurFrame.Size
	end)
	self:_Setup()
	self:Refresh()
end

return ScopeModifier