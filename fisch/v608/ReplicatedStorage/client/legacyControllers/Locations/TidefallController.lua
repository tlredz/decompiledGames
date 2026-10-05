local module = require("@self/LostDiver")
local module2 = require("@self/Dripstone")
return {
	Start = function(self)
		module:Start()
		module2:Start()
		require("@self/Components")
	end
}