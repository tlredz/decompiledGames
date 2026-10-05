local GuiService = game:GetService("GuiService")
local Other = {}
Other.__index = Other

function Other.new(itemInterface)
	local self = setmetatable({}, Other)
	self.ItemInterface = itemInterface
	self.AimingVignette = self.ItemInterface.Frame:WaitForChild("AimingVignette")
	self:_Init()
	return self
end

function Other.Update(p, _, _, _)
	p.AimingVignette.ImageTransparency = 1 - p.ItemInterface.ClientItem.ViewModel.CurrentAimValue
end

function Other.Destroy(_) end

function Other:_Setup()
	self.AimingVignette.Size = UDim2.new(1, 0, 1, GuiService:GetGuiInset().Y)
end

function Other:_Init()
	self:_Setup()
end

return Other