return {
	softRequire = function(instance)
		local clone = instance:Clone()
		local module = require(clone)
		clone:Destroy()
		return module
	end
}