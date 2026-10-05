local Frozen = {}
Frozen.__index = Frozen

function Frozen.new(fighterInterface)
	local self = setmetatable({}, Frozen)
	self.FighterInterface = fighterInterface
	self.Vignette = self.FighterInterface.Frame:WaitForChild("FrozenVignette")
	self.VignetteTexture = self.Vignette:WaitForChild("Texture")
	self:_Init()
	return self
end

function Frozen.Refresh(data)
	local isFrozen = data.FighterInterface.ClientFighter and data.FighterInterface.ClientFighter.Entity and data.FighterInterface.ClientFighter:IsAlive() and data.FighterInterface.ClientFighter.Entity:Get("IsFrozen")
	local isDisableOnly = (typeof(isFrozen) == "table" and isFrozen or {}).IsDisableOnly
	data.Vignette.ImageColor3 = isDisableOnly and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(35, 149, 255)
	data.Vignette.ImageTransparency = isFrozen and 0 or 1
	data.VignetteTexture.ImageTransparency = data.Vignette.ImageTransparency
end

function Frozen.Destroy(_) end

function Frozen:_Init() end

return Frozen