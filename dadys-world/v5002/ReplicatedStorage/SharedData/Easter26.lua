game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Universe = require(ReplicatedStorage.SharedUtils.Universe)
require(ReplicatedStorage.SharedUtils.ActionEvent)

local function standard_gift_action(p, _, p2)
	local number = p.Number or 1
	local baskets = p2.Data.Seasonal.Easter26.Baskets or 0
	p2.Data.Seasonal.Easter26.Baskets = baskets + number
	return true, {
		rewardType = "Ornaments",
		amount = number,
		newBalance = p2.Data.Seasonal.Easter26.Baskets
	}
end

local function standard_and_sticker_gift_action(p, p2, p3)
	local number = p.Number or 1
	local stickerName = p.StickerName
	local stickerGiven = false
	local baskets = p3.Data.Seasonal.Easter26.Baskets or 0
	p3.Data.Seasonal.Easter26.Baskets = baskets + number

	if stickerName and stickerName ~= "" then
		if not p3.Data.StickersOwned then
			p3.Data.StickersOwned = {}
		end

		if table.find(p3.Data.StickersOwned, stickerName) then
			print(string.format("[Calendar] %s already owns sticker '%s'", p2.Name, stickerName))
		else
			stickerGiven = true
		end
	end

	return true, {
		rewardType = "OrnamentsAndSticker",
		amount = number,
		newBalance = p3.Data.Seasonal.Easter26.Baskets,
		stickerName = stickerName,
		stickerGiven = stickerGiven
	}
end

local function give_skin(data, p, p2, object)
	local skinName = data.SkinName
	local key = data.Key
	local required = data.Required
	local v = p2 and p2.Data.Seasonal and p2.Data.Seasonal.Easter26 and p2.Data.Seasonal.Easter26.Calendars and p2.Data.Seasonal.Easter26.Calendars[key]

	if v then
		local login = v.Login or {}
		local count = 0
		local missingDays = {}

		for i = 1, required do
			if login[tostring(i)] then
				count += 1
			else
				table.insert(missingDays, i)
			end
		end

		if count < required then
			local failDetails = string.format(
				"Only %d/%d days logged for %s. Missing: %s",
				count,
				required,
				key,
				table.concat(missingDays, ",")
			)
			warn("[Calendar] FAILED:", failDetails, "- Player:", p.Name)
			return false, {
				rewardType = "Skin",
				skinName = skinName,
				success = false,
				failReason = "INCOMPLETE_DAYS",
				failDetails = failDetails,
				daysLogged = count,
				daysRequired = required,
				missingDays = missingDays
			}
		else
			for _, skin in pairs(p2.Data.Skins) do
				if skin and tostring(skin[1]) == skinName then
					return false, {
						rewardType = "Skin",
						skinName = skinName,
						success = false,
						failReason = "ALREADY_OWNED",
						failDetails = string.format("Already owns skin %s", skinName)
					}
				end
			end

			object:ArrayInsert(p, "Skins", { skinName })
			return true, {
				rewardType = "Skin",
				skinName = skinName,
				success = true,
				calendarKey = key,
				daysCompleted = required
			}
		end
	else
		local failDetails = string.format("Calendar data missing for %s", key)
		warn("[Calendar] FAILED:", failDetails, "- Player:", p.Name)
		return false, {
			rewardType = "Skin",
			skinName = skinName,
			success = false,
			failReason = "CALENDAR_MISSING",
			failDetails = failDetails
		}
	end
end

local Easter26 = {
	Active = {
		Start = DateTime.fromUniversalTime(2026, 3, 20, 4, 0, 0),
		End = DateTime.fromUniversalTime(2026, 4, 24, 19, 0, 0)
	},
	PreEventCalendar = {
		Start = DateTime.fromUniversalTime(2026, 3, 25, 4, 0, 0),
		Start_Day = 25,
		Rewards = {
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://124312096518806",
				IsDoubleWeekend = true,
				IsSkinDrop = true,
				Number = 100,
				StickerName = "Dandy Happy Easter!",
				Action = standard_and_sticker_gift_action
			},
			{
				Icon = "rbxassetid://67225889",
				IsDoubleWeekend = true,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://67225889",
				IsDoubleWeekend = true,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://124312096518806",
				IsDoubleWeekend = true,
				Number = 100,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				IsDoubleWeekend = true,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://124312096518806",
				IsDoubleWeekend = true,
				Number = 300,
				Action = standard_gift_action
			}
		},
		CompletionReward = {
			Image = "rbxassetid://83524441093876",
			Required = 12,
			SkinName = "EggHunting",
			Key = "PreEventCalendar",
			Action = give_skin
		}
	},
	PostEventCalendar = {
		Start = DateTime.fromUniversalTime(2026, 4, 6, 4, 0, 0),
		Start_Day = 6,
		Rewards = {
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://67225889",
				IsDoubleWeekend = true,
				IsSkinDrop = true,
				Number = 50,
				StickerName = "Dyle Easter Egg",
				Action = standard_and_sticker_gift_action
			},
			{
				Icon = "rbxassetid://67225889",
				IsDoubleWeekend = true,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://67225889",
				IsDoubleWeekend = true,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://124312096518806",
				IsDoubleWeekend = true,
				IsSkinDrop = true,
				Number = 300,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://124312096518806",
				IsDoubleWeekend = true,
				Number = 300,
				Action = standard_gift_action
			}
		},
		CompletionReward = {
			Image = "rbxassetid://106028826685332",
			Required = 13,
			SkinName = "StrawberryPaws",
			Key = "PostEventCalendar",
			Action = give_skin
		}
	},
	Missions = {
		Eggson = {
			Start = DateTime.fromUniversalTime(2026, 3, 20, 19, 0, 0),
			RewardSkin = "GoldenEgg",
			Order = 1,
			Quests = {
				Encounter = {
					Required = 10,
					Title = "Eggcounter!",
					Description = "Encounter Twisted Eggson <font color='#83ff00'>10</font> times as Eggson."
				},
				Floor = {
					Required = 15,
					Title = "Eggson's Exploration!",
					Description = "Complete an Easter Floor <font color='#83ff00'>15</font> times as Eggson."
				},
				Ability = {
					Required = 10,
					Title = "Eggson's Ability!",
					Description = "Use this Toon's Ability <font color='#83ff00'>10</font> times on a machine."
				}
			}
		},
		Flyte = {
			Start = DateTime.fromUniversalTime(2026, 3, 20, 19, 0, 0),
			RewardSkin = "GoldenWings",
			Order = 2,
			Quests = {
				Encounter = {
					Required = 10,
					Title = "Flyte's Encounter!",
					Description = "Encounter Twisted Flyte <font color='#83ff00'>10</font> times as Flyte."
				},
				Floor = {
					Required = 20,
					Title = "Flyte's Endurance!",
					Description = "Complete <font color='#83ff00'>Floor 20</font> as Flyte."
				},
				Ability = {
					Required = 50,
					Title = "Flyte's Gusto!",
					Description = "Use Flyte's ability to support other Toons <font color='#83ff00'>50</font> times."
				}
			}
		},
		Cocoa = {
			Start = DateTime.fromUniversalTime(2026, 3, 27, 19, 0, 0),
			RewardSkin = "GoldenBunny",
			Order = 3,
			Quests = {
				Encounter = {
					Required = 10,
					Title = "Cocoa's Encounter!",
					Description = "Encounter Twisted Cocoa <font color='#83ff00'>10</font> times as Cocoa."
				},
				Ability = {
					Required = 40,
					Title = "Cocoa's Generosity!",
					Description = "Use Cocoa's ability to place <font color='#83ff00'>40 Bonbons</font> that are picked up by other Toons."
				},
				Floor = {
					Required = 35,
					Title = "Cocoa's Endurance!",
					Description = "Complete <font color='#83ff00'>35</font> total Floors as Cocoa."
				}
			}
		},
		Bassie = {
			Start = DateTime.fromUniversalTime(2026, 3, 27, 19, 0, 0),
			RewardSkin = "GoldenBasket",
			Order = 4,
			Quests = {
				Encounter = {
					Required = 10,
					Title = "Bassie's Encounter!",
					Description = "Encounter Twisted Bassie <font color='#83ff00'>10</font> times as Bassie."
				},
				Floor = {
					Required = 20,
					Title = "Bassie's Endurance!",
					Description = "Complete <font color='#83ff00'>Floor 20</font> as Bassie with the Whispering Flower trinket equipped."
				},
				FloorEvent = {
					Required = 15,
					Title = "Bassie's Adventure!",
					Description = "Experience the Spring Fever event <font color='#83ff00'>15</font> times as Bassie."
				}
			}
		}
	}
}
local SimulatedTime

if RunService:IsServer() then
	SimulatedTime = require(script.Parent.Parent:WaitForChild("SharedUtils"):WaitForChild("SimulatedTime"))

	if not Universe:IsRoleplay() then
		if Universe:IsLobby() then
			task.defer(function()
				local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)

				if not HolidayEventConfig.ENABLED then
					return
				end

				require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("EggHuntSystem"))
			end)
		elseif Universe:IsGame() then
			local v = nil
			task.defer(function()
				local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)
				v = HolidayEventConfig
			end)

			local function isHolidayEnabled()
				return v and v.ENABLED
			end

			local editData = ReplicatedStorage:WaitForChild("editData")

			local function runOnProfile(p, callback)
				if not (v and v.ENABLED) then
					return false, "Holiday disabled"
				end

				local v2 = true
				local v3 = "N/A"
				editData:Invoke(p, function(p2)
					if p2 then
						local success, result = pcall(callback, p2)

						if success then
							return
						end

						v3 = result
						v2 = false
					else
						v3 = "Profile does not exist"
						v2 = false
					end
				end)

				if not v2 then
					print("RUNONPROFILE FAILED: ", (tostring(v3)))
				end

				return v2, v3
			end
		end
	end
else
	SimulatedTime = nil
end

if Universe:IsLobby() then
	task.defer(function()
		local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)

		if not HolidayEventConfig.ENABLED then
			return
		end

		require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("EggHuntSystem"))
	end)
end

function Easter26.UpdateMission(p, p2, value: string, value2: string, flag: boolean, p3: number?)
	if RunService:IsClient() then
		return
	end

	local unixTimestamp = SimulatedTime.now().UnixTimestamp
	local v = (tonumber(p3) or 0) > 0 and tonumber(p3) or 1

	if not value or typeof(value) ~= "string" or (not value2 or typeof(value2) ~= "string") then
		return
	end

	if not p.Missions[value] or not p.Missions[value].Quests or typeof(p.Missions[value].Quests) ~= "table" then
		return
	end

	if not p.Missions[value].Quests[value2] or typeof(p.Missions[value].Quests[value2]) ~= "table" or unixTimestamp < p.Missions[value].Start.UnixTimestamp then
		return
	end

	print("UPDATING MISSION: ", value, value2, v)
	local easter26 = p2.Data.Seasonal.Easter26

	if not easter26 or not easter26.Quests or typeof(easter26.Quests) ~= "table" then
		return
	end

	if not p2.Data.Seasonal.Easter26.Quests[value] then
		p2.Data.Seasonal.Easter26.Quests[value] = {}
	end

	local v2 = p2.Data.Seasonal.Easter26.Quests[value][value2] or 0

	if flag then
		local quest = p2.Data.Seasonal.Easter26.Quests[value]

		if v2 < v then
			v2 = v or v2
		end

		quest[value2] = v2
	else
		p2.Data.Seasonal.Easter26.Quests[value][value2] = v2 + v
	end

	local quests = p.Missions[value].Quests
	local v3 = p2 and p2.Data.Seasonal and p2.Data.Seasonal.Easter26 and p2.Data.Seasonal.Easter26.Quests and p2.Data.Seasonal.Easter26.Quests[value]
	local v4 = {}

	for k, quest in pairs(quests) do
		if v3[k] then
			local v5 = v3[k]
			local required = quest.Required

			if v5 < required then
				table.insert(v4, k .. ": " .. v5 .. "/" .. required)
			end
		else
			table.insert(v4, k .. ": not started")
		end
	end

	if #v4 <= 0 then
		if typeof(p2.Data.Seasonal.Easter26.QuestProgressNotified) ~= "table" then
			p2.Data.Seasonal.Easter26.QuestProgressNotified = {}
		end

		if p2.Data.Seasonal.Easter26.QuestProgressNotified[value] == nil then
			p2.Data.Seasonal.Easter26.QuestProgressNotified[value] = 1
		end
	end

	return true
end

return Easter26