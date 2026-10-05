local BaseConfiguration = {}
BaseConfiguration.__index = BaseConfiguration

function BaseConfiguration.new()
	return (setmetatable({}, BaseConfiguration))
end

function BaseConfiguration.Validate(_) end

return BaseConfiguration