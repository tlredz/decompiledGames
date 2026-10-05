local updateIn = require(script.Parent.updateIn)
return function(p, p2, callback, p3)
	return updateIn(p, { p2 }, callback, p3)
end