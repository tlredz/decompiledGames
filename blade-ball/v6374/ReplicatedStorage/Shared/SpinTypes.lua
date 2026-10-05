local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = {
	Battlepass = "AddGachaSpins",
	Weekly = "AddWeeklySpins",
	Christmas = "AddChristmasSpins",
	NewYear = "AddNewYearSpins",
	Brazil = "AddBrazilSpins",
	Thai = "AddThaiGachaSpins",
	EasterGacha = "AddEasterGachaSpins",
	EasterWheel = "AddEasterWheelSpins",
	SummerWheel = "AddSummerWheelSpins",
	SynthWheel = "AddSynthWheelSpins",
	CyborgWheel = "AddCyborgWheelSpins",
	HourlyWheel = "AddHourlyWheelSpins",
	SciFi = "AddSciFiSpins"
}

local function awardActiveGacha(p, p2: number)
	local v3 = require3(ReplicatedStorage2.Shared.LootboxData)
	local replionFor = v.Server:GetReplionFor(p, "Data")

	if not replionFor then
		return false
	end

	replionFor:Increase(`GachaData.{v3.ActiveGacha.Name}.SpinsLeft`, p2)
	return true
end

return {
	Names = {
		"Battlepass",
		"Weekly",
		"Christmas",
		"NewYear",
		"Brazil",
		"Thai",
		"EasterGacha",
		"EasterWheel",
		"SummerWheel",
		"SynthWheel",
		"CyborgWheel",
		"HourlyWheel",
		"SciFi",
		"ActiveGacha"
	},
	award = function(p: string, items, p2: number)
		local ServerScriptService = game:GetService("ServerScriptService")
		local v4 = require3(ServerScriptService.Game.Server.AwardService)
		local v5 = {}
		local v6 = {}

		for _, item in items do
			local v7

			if p == "ActiveGacha" then
				local v8 = require3(ReplicatedStorage2.Shared.LootboxData)
				local replionFor = v.Server:GetReplionFor(item, "Data")

				if replionFor then
					replionFor:Increase(`GachaData.{v8.ActiveGacha.Name}.SpinsLeft`, p2)
					v7 = true
				else
					v7 = false
				end
			else
				local v8 = v2[p]

				if v8 == nil then
					v7 = false
				else
					v7 = v4[v8](v4, item, p2) ~= false
				end
			end

			local v8

			if v7 then
				v8 = v5
			else
				v8 = v6
			end

			table.insert(v8, item.Name)
		end

		return v5, v6
	end
}