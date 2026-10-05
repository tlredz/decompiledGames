local CollectionService = game:GetService("CollectionService")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class.Update(_, _)
	for _, v in pairs(CollectionService:GetTagged("UILoadingDots")) do
		for i = 1, 3 do
			local v2 = math.max(
				0.5,
				(math.abs((math.sin((tick() * -4 + i / 3 * 3.141592653589793 * 2 * 0.15) % 6.283185307179586))))
			) * 0.3333333333333333
			v[i].Size = UDim2.new(v2, 0, v2, 0)
		end
	end
end

function class:_Init() end

return class._new()