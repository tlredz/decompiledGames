local function describe(_, _) end

local function it(_, _) end

local function expect(_) end

return function()
	local parentModule = require(script.Parent)
	local _ = parentModule.sha256
end