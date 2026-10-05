local packages = script.Parent.Packages

if not packages:FindFirstChild("Promise") then
	return nil
end

local Promise = require(packages.Promise)
return Promise