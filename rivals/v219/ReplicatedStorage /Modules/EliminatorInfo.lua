local EliminatorInfo = {}
EliminatorInfo.__index = EliminatorInfo

function EliminatorInfo.new(displayName, image)
	local self = setmetatable({}, EliminatorInfo)
	self.DisplayName = displayName
	self.Image = image
	self:_Init()
	return self
end

function EliminatorInfo:_Init() end

return EliminatorInfo