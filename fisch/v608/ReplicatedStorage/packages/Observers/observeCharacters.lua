local observePlayer = require(script.Parent.observePlayer)
local observeCharacter = require(script.Parent.observeCharacter)

local function observeCharacters(callback)
	return observePlayer(function(p)
		return observeCharacter(p, callback)
	end)
end

return observeCharacters