local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Packages.Replion)
return {
	Name = "SerpentBreakout",
	Interval = require3(ReplicatedStorage2.ServerInfo).isTestGame() and 60 or 900,
	MinPlayersNeeded = 3,
	QueueTime = 30
}