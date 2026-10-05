local Entity = {}
Entity.__index = Entity

function Entity.new(p, p2)
	local module = require(script[p])
	return module.new(p2)
end

return Entity