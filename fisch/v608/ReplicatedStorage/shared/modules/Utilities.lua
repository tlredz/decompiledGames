local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local forPlayer

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	local legacyPlayerData = require(ServerScriptService.server.modules.legacyPlayerData)
	forPlayer = legacyPlayerData.forPlayer
else
	forPlayer = nil
end

local Utilities = {
	all = {
		["Old Cage"] = {
			TargetType = "lobster",
			TierRequired = 1,
			Icon = "rbxassetid://92539991691181",
			CatchTime = NumberRange.new(4, 10),
			EscapeTime = NumberRange.new(20, 30),
			EscapeChance = 0.7,
			CatchChance = 0.5,
			CatchSpeed = 250,
			CatchAngle = NumberRange.new(0, 30),
			Strength = 500,
			Luck = 20,
			Price = 150
		},
		["Rusted Cage"] = {
			TargetType = "lobster",
			TierRequired = 2,
			Icon = "rbxassetid://104717074652202",
			CatchTime = NumberRange.new(240, 360),
			EscapeTime = NumberRange.new(40, 100),
			EscapeChance = 0.55,
			CatchChance = 0.65,
			CatchSpeed = 150,
			CatchAngle = NumberRange.new(0, 50),
			Strength = 1000,
			Luck = 40,
			Price = 300
		},
		["Reinforced Cage"] = {
			TargetType = "lobster",
			TierRequired = 2,
			Icon = "rbxassetid://103705685360795",
			CatchTime = NumberRange.new(10, 20),
			EscapeTime = NumberRange.new(160, 280),
			EscapeChance = 0.4,
			CatchChance = 0.7,
			CatchSpeed = 120,
			CatchAngle = NumberRange.new(0, 80),
			Strength = 7500,
			Luck = 75,
			Price = 600
		},
		["Premium Cage"] = {
			TargetType = "lobster",
			TierRequired = 2,
			Icon = "rbxassetid://101092546187568",
			CatchTime = NumberRange.new(240, 360),
			EscapeTime = NumberRange.new(200, 320),
			EscapeChance = 0.25,
			CatchChance = 0.75,
			CatchSpeed = 100,
			CatchAngle = NumberRange.new(0, 90),
			Strength = 35000,
			Luck = 100,
			Price = 1000
		},
		["Obsidian Cage"] = {
			TargetType = "lobster",
			TierRequired = 3,
			Icon = "rbxassetid://74690281813935",
			CatchTime = NumberRange.new(240, 360),
			EscapeTime = NumberRange.new(400, 600),
			EscapeChance = 0.05,
			CatchChance = 0.9,
			CatchSpeed = 120,
			CatchAngle = NumberRange.new(0, 130),
			Strength = 90000,
			Luck = 150,
			Price = 6500
		},
		["Cursed Cage"] = {
			TargetType = "lobster",
			TierRequired = 4,
			Icon = "rbxassetid://81330346994915",
			CatchTime = NumberRange.new(60, 180),
			EscapeTime = NumberRange.new(600, 1200),
			EscapeChance = 0.1,
			CatchChance = 0.95,
			CatchSpeed = 85,
			CatchAngle = NumberRange.new(0, 40),
			Strength = 500000,
			Luck = 200,
			Price = 15000
		},
		["Fishing Net"] = {
			TargetType = "school",
			TierRequired = 1,
			Icon = "rbxassetid://78882815727903",
			InstantCatch = true,
			EscapeTime = NumberRange.new(10, 20),
			EscapeChance = 0.7,
			CatchChance = 0.5,
			CatchSpeed = 150,
			CatchAngle = NumberRange.new(0, 50),
			Strength = 250,
			Luck = 45,
			Price = 300
		},
		["Premium Net"] = {
			TargetType = "school",
			TierRequired = 2,
			Icon = "rbxassetid://87332121040321",
			InstantCatch = true,
			EscapeTime = NumberRange.new(35, 45),
			EscapeChance = 0.5,
			CatchChance = 0.6,
			CatchSpeed = 150,
			CatchAngle = NumberRange.new(0, 90),
			Strength = 500,
			Luck = 75,
			Price = 600
		},
		["Obsidian Net"] = {
			TargetType = "school",
			TierRequired = 3,
			Icon = "rbxassetid://127358751021089",
			InstantCatch = true,
			EscapeTime = NumberRange.new(60, 90),
			EscapeChance = 0.05,
			CatchChance = 0.95,
			CatchSpeed = 150,
			CatchAngle = NumberRange.new(0, 130),
			Strength = 1000,
			Luck = 100,
			Price = 7500
		},
		["Bubba's Net"] = {
			TargetType = "school",
			TierRequired = 4,
			Icon = "rbxassetid://137472622435791",
			InstantCatch = true,
			EscapeTime = NumberRange.new(250, 400),
			EscapeChance = 0.01,
			CatchChance = 0.99,
			CatchSpeed = 150,
			CatchAngle = NumberRange.new(0, 180),
			Strength = 5000,
			Luck = 200,
			Price = 17500
		}
	}
}

for k, v in Utilities.all do
	local targetType = v.TargetType

	if not Utilities[targetType] then
		Utilities[targetType] = {}
	end

	Utilities[targetType][k] = v
end

function Utilities.Give(p, player, p2: string, value: number?)
	local amount = value or 1

	if not (RunService:IsServer() and p.all[p2]) then
		return
	end

	local _, v2 = forPlayer(player)

	if not (v2 and v2.Data.NewFormat) then
		return
	end

	if not v2.Data.NewFormat.Utilities then
		v2.Data.NewFormat.Utilities = {}
	end

	if not v2.Data.NewFormat.ReplicatedBooleans.HasPurchasedCage then
		v2.Data.NewFormat.ReplicatedBooleans.HasPurchasedCage = true
	end

	if amount > 0 then
		ReplicatedStorage.events.anno_thought:FireClient(
			player,
			"You can view your newly purchased utility on a Utility Boat!"
		)
	end

	local utility = v2.Data.NewFormat.Utilities[p2]

	if utility then
		v2.Data.NewFormat.Utilities[p2] = {
			amount = utility.amount + amount
		}
	else
		v2.Data.NewFormat.Utilities[p2] = {
			amount = amount
		}
	end
end

function Utilities.GetUtilityCountByType(p, p2, p3: string)
	if not (RunService:IsServer() and p.all[p3]) then
		return
	end

	local _, v = forPlayer(p2)

	if v and v.Data.NewFormat and v.Data.NewFormat.Utilities then
		local utility = v.Data.NewFormat.Utilities[p3]
		return utility and utility.amount or 0
	end
end

return Utilities