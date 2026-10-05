local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Signal)
local v2 = v.new()
local v3 = v.new()
local RankedSignalController = {}

function RankedSignalController.GetOpenMainMenuSignal(_)
	return v2
end

function RankedSignalController.GetUpdateRankedMenuSignal(_)
	return v3
end

return RankedSignalController