local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)

local function getEvent(p: string)
	return v:RemoteEvent((`SinglePass/{p}`))
end

local function getFunction(p: string)
	return v:RemoteFunction((`SinglePass/{p}`))
end

return {
	BuyItem = v:RemoteEvent("SinglePass/BuyItem"),
	SetReplication = v:RemoteEvent("SinglePass/SetReplication"),
	ClaimMilestone = v:RemoteFunction("SinglePass/ClaimMilestone"),
	ClaimLeaderboardRewards = v:RemoteFunction("SinglePass/ClaimLeaderboardRewards"),
	Spin = v:RemoteFunction("SinglePass/Spin")
}