local GetInvisibility = require(script.Parent.GetInvisibility)
return {
	HasInvisibility = function(p)
		local invisibility, v = GetInvisibility.GetInvisibility(p)
		return invisibility ~= nil or v ~= nil
	end
}