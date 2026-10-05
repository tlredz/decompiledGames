local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
Players.LocalPlayer:WaitForChild("PlayerGui")
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Common.Utils).Maid.new()
return {
	Start = function(_) end
}