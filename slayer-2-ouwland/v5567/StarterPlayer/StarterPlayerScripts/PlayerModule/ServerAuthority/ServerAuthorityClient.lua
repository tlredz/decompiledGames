if script:FindFirstAncestorOfClass("PlayerScripts") == nil then
	return
end

local parentModule = require(script.Parent)
parentModule:Initialize()