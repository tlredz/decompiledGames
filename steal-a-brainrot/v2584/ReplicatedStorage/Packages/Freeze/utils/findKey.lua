local findPair = require(script.Parent.findPair)
return function(p, p2)
	local pair, _ = findPair(p, p2)
	return pair
end