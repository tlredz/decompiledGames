local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)("./Rewards")
return nil