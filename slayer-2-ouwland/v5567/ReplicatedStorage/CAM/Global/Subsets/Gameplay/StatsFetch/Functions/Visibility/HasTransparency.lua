local GetTransparency = require(script.Parent.GetTransparency)
return {
	HasTransparency = function(p)
		local transparency, v = GetTransparency.GetTransparency(p)
		return transparency ~= nil or v ~= nil
	end
}