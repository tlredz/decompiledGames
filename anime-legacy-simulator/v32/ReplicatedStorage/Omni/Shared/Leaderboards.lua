local RunService = game:GetService("RunService")
local module = require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local module2 = require("@game/ReplicatedStorage/Omni/Utils/Players")
local module3 = require("@game/ReplicatedStorage/Omni/Shared/Analytics")
local interval = RunService:IsStudio() and 30 or 300
local categories = {
	F2P = true,
	Global = true
}
local v3 = {
	List = {
		["Total Power"] = {
			Index = 1,
			Size = 100,
			MinimumValue = 1,
			Interval = interval,
			ReverseOrder = false,
			AllowHighRank = false,
			OnlyOneCategory = false,
			Stat = "Total Power",
			Icon = "rbxassetid://80640623407879",
			Categories = categories,
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 85, 88)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 192, 67))
			})
		},
		["Total Damage"] = {
			Index = 2,
			Size = 100,
			MinimumValue = 1,
			Interval = interval,
			ReverseOrder = false,
			AllowHighRank = false,
			OnlyOneCategory = false,
			Stat = "Damage Dealt",
			Icon = "rbxassetid://132679284489913",
			Categories = categories,
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 60)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 30, 90))
			})
		},
		["Highest DPS"] = {
			Index = 3,
			Size = 100,
			MinimumValue = 1,
			Interval = interval,
			ReverseOrder = false,
			AllowHighRank = false,
			OnlyOneCategory = false,
			Stat = "Highest DPS",
			Icon = "rbxassetid://97817416213580",
			Categories = categories,
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 60, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 40, 60))
			})
		},
		["Total Yen"] = {
			Index = 4,
			Size = 100,
			MinimumValue = 1,
			Interval = interval,
			ReverseOrder = false,
			AllowHighRank = false,
			OnlyOneCategory = false,
			Stat = "Total Yen",
			Icon = "rbxassetid://128122107653249",
			Categories = categories,
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 234, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 106, 0))
			})
		},
		["Defeated Enemies"] = {
			Index = 5,
			Size = 100,
			MinimumValue = 1,
			Interval = interval,
			ReverseOrder = false,
			AllowHighRank = false,
			OnlyOneCategory = false,
			Stat = "Defeated Enemies",
			Icon = "rbxassetid://85863040504275",
			Categories = categories,
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
			})
		},
		["Stars Opened"] = {
			Index = 6,
			Size = 100,
			MinimumValue = 1,
			Interval = interval,
			ReverseOrder = false,
			AllowHighRank = false,
			OnlyOneCategory = false,
			Stat = "Total Stars Opened",
			Icon = "rbxassetid://88998026190015",
			Categories = categories,
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(248, 255, 115)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(251, 255, 0))
			})
		},
		["Time Played"] = {
			Index = 7,
			Size = 100,
			MinimumValue = 1,
			Interval = interval,
			ReverseOrder = false,
			AllowHighRank = false,
			OnlyOneCategory = false,
			Stat = "Time Played",
			Icon = "rbxassetid://70953026970505",
			Categories = {
				Global = true
			},
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 238, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 119, 255))
			})
		},
		["Robux Spent"] = {
			Index = 8,
			Size = 100,
			MinimumValue = 1,
			Interval = interval,
			ReverseOrder = false,
			AllowHighRank = false,
			OnlyOneCategory = true,
			Stat = "Robux Spent",
			Icon = "rbxassetid://93731909877414",
			Categories = {
				Global = true
			},
			Gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 255, 0))
			})
		}
	},
	GetPlayerLeaderboardStatus = function(data, p, flag: boolean?)
		if data.Banned or data.ShadowBanned or not flag and (not RunService:IsStudio() or game.PlaceId ~= module.TestPlaceId) and module2.GetPlayerGroupInfo(p) >= module3.StaffRank then
			return "Banned"
		end

		for k, _ in data.Gamepasses do
			if not module.F2PGamepasses[k] then
				return "P2W"
			end
		end

		return "F2P"
	end
}

function v3.GetLeaderboardCategoriesForPlayer(p: string, p2, p3, p4: string?)
	local result = {}
	local v4 = v3.List[p]

	if not v4 then
		return result
	end

	local v5 = p4 or v3.GetPlayerLeaderboardStatus(p2, p3, v4.AllowHighRank)

	if v5 == "Banned" then
		return result
	end

	if v4.OnlyOneCategory then
		if v4.Categories["Content Creator"] and module2.IsPlayerContentCreator(p3) then
			table.insert(result, "Content Creator")
			return result
		end

		if v5 == "F2P" and v4.Categories.F2P then
			table.insert(result, "F2P")
			return result
		end

		if v5 == "P2W" and v4.Categories.P2W then
			table.insert(result, "P2W")
			return result
		end

		if v4.Categories.Global then
			table.insert(result, "Global")
			return result
		end
	else
		for k in v4.Categories do
			if k == "Global" or v5 == k or k == "Content Creator" and module2.IsPlayerContentCreator(p3) then
				table.insert(result, k)
			end
		end
	end

	return result
end

return table.freeze(v3)