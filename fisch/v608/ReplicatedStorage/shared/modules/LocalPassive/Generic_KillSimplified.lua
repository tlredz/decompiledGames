local module = require("./PassiveHandler")
local GenericKillSimplified = {}
GenericKillSimplified.__index = GenericKillSimplified

function GenericKillSimplified.Morph(_, _, _) end

setmetatable(GenericKillSimplified, module)
return GenericKillSimplified