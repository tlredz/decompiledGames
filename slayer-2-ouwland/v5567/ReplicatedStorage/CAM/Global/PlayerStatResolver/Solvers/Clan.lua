local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Clans = require(ReplicatedStorage.CAM.Clans)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(p, p2: string)
	local data = Utility.GetData(p)
	local clan

	if data ~= nil then
		clan = data:FindFirstChild("Clan") or nil
	end

	local v

	if clan ~= nil then
		v = Clans.GetClan(clan.Value) or nil
	end

	local v2

	if v ~= nil then
		v2 = v.stats ~= nil and v.stats[p2] or nil
	end

	if v2 == true then
		return true
	end

	if typeof(v2) == "number" then
		return v2
	end

	return 0
end