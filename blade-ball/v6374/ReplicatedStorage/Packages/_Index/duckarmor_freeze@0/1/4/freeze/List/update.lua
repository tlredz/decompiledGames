local updateIn = require(script.Parent.updateIn)

local function update(p, p2: number, callback, p3)
	return updateIn(p, { p2 }, callback, p3)
end

return update