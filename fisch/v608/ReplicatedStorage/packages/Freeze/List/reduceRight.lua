local reduce = require(script.Parent.Parent.utils.reduce)

local function reduceRight(p, callback, p2)
	return reduce(p, callback, p2, true)
end

return reduceRight