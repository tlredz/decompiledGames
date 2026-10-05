local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Freeze)
local v3 = require3(ReplicatedStorage2.Common.RewardInfo)

local function getEvent(p: string)
	return v:RemoteEvent((`BattlepassEvent/{p}`))
end

local function getFunction(p: string)
	return v:RemoteFunction((`BattlepassEvent/{p}`))
end

local BattlepassEventData = {}
BattlepassEventData.Id = 5
BattlepassEventData.CountTowardsGlobal = false
BattlepassEventData.Stat = "Wins"
BattlepassEventData.StatDisplay = "Win"
BattlepassEventData.StatDisplayPlural = "Wins"
BattlepassEventData.Teams = { "Santas", "Elves" }
BattlepassEventData.Colors = {
	Santas = Color3.fromRGB(255, 61, 61),
	Elves = Color3.fromRGB(61, 255, 61)
}
BattlepassEventData.TeamLockPercentage = 3
BattlepassEventData.WinnerReward = 5
BattlepassEventData.Rewards = {
	v3.createCandyCanesReward(250),
	v3.createExplosionReward("Gift Wrap Burst"),
	v3.createGenericGachaSpinReward(1, "Reindeer Spin"),
	v3.createEmoteReward("Frozen Feather"),
	{
		Type = "TeamReward",
		Santas = v3.createSwordReward("Crimson Claus"),
		Elves = v3.createSwordReward("Elven Spark")
	}
}
BattlepassEventData.Remotes = {
	JoinTeam = v:RemoteFunction("BattlepassEvent/JoinTeam"),
	OpenedUI = v:RemoteEvent("BattlepassEvent/OpenedUI")
}

function BattlepassEventData.GetPath(value)
	local v4 = type(value) == "string" and { value } or type(value) ~= "table" and {} or value
	return v2.List.concat({ "BattlepassEvents", (tostring(5)) }, v4)
end

function BattlepassEventData.GetFFlagKey(p: string)
	return (`BattlepassEventChristmas{p}`)
end

function BattlepassEventData.GetGlobalNumberKey(p: string)
	return (`BattlepassEvent{5}{p}Kills`)
end

return BattlepassEventData