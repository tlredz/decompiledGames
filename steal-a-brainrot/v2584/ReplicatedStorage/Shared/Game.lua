local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Synchronizer = require(packages.Synchronizer)
local datas = ReplicatedStorage:WaitForChild("Datas")
local Rebirth = require(datas.Rebirth)
local shared = ReplicatedStorage:WaitForChild("Shared")
local Friends = require(shared.Friends)
local Index = require(shared.Index)
require(shared.Updates)
return {
	GetPlayerCashMultiplayer = function(_, p)
		local v = p or Players.LocalPlayer
		local v2 = 1
		local v3 = Synchronizer:Get(v)

		if not v3 then
			return v2
		end

		local rebirth = v3:Get("Rebirth")

		if rebirth > 0 then
			local v4 = Rebirth[rebirth]

			if v4 then
				v2 += v4.Rewards.Multiplier
			end
		end

		if v3:Get("Gamepass.VIP") == true then
			v2 += 0.5
		end

		if v3:Get("Gamepass.2x Money") == true then
			v2 += 2
		end

		local unixTimestamp = DateTime.now().UnixTimestamp
		local v4 = v3:Get("BoostExpiration.2xMoney")
		local v5 = v3:Get("BoostExpiration.2xMoneyBoost")
		local v6

		if typeof(v4) == "number" and v4 > 0 then
			v6 = unixTimestamp < v4
		else
			v6 = false
		end

		local v7

		if typeof(v5) == "number" and v5 > 0 then
			v7 = unixTimestamp < v5
		else
			v7 = false
		end

		if v6 or v7 then
			v2 += 2
		end

		return v2 + Friends:GetFriendBoostModifier(v) + Index:GetMultipliers(v)
	end
}