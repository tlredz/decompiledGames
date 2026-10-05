local parent = script.Parent.Parent

if not parent:FindFirstChild("Promise") then
	return nil
end

local Promise = require(parent.Promise)
return Promise