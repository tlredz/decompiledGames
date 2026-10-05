local RunService = game:GetService("RunService")

local function standard_gift_action(p, _, p2)
	local number = p.Number or 1
	local christmas2025Ornaments = p2.Data.Seasonal.Christmas25.Christmas2025Ornaments or 0
	p2.Data.Seasonal.Christmas25.Christmas2025Ornaments = christmas2025Ornaments + number
	return true, {
		rewardType = "Ornaments",
		amount = number,
		newBalance = p2.Data.Seasonal.Christmas25.Christmas2025Ornaments
	}
end

local function standard_and_sticker_gift_action(p, p2, p3)
	local number = p.Number or 1
	local stickerName = p.StickerName
	local stickerGiven = false
	local christmas2025Ornaments = p3.Data.Seasonal.Christmas25.Christmas2025Ornaments or 0
	p3.Data.Seasonal.Christmas25.Christmas2025Ornaments = christmas2025Ornaments + number

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
		newBalance = p3.Data.Seasonal.Christmas25.Christmas2025Ornaments,
		stickerName = stickerName,
		stickerGiven = stickerGiven
	}
end

local function give_skin(data, p, p2, object)
	local skinName = data.SkinName
	local key = data.Key
	local required = data.Required
	local v = p2 and p2.Data.Seasonal and p2.Data.Seasonal.Christmas25 and p2.Data.Seasonal.Christmas25.Calendars and p2.Data.Seasonal.Christmas25.Calendars[key]

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

local v = {
	Active = {
		Start = DateTime.fromUniversalTime(2025, 12, 14, 5, 0, 0),
		End = DateTime.fromUniversalTime(2026, 1, 16, 20, 0, 0)
	},
	PreChristmasCalendar = {
		Start = DateTime.fromUniversalTime(2025, 12, 14, 5, 0, 0),
		Start_Day = 14,
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
				Icon = "rbxassetid://15665318824",
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = "rbxassetid://9341850496",
				IsDoubleWeekend = true,
				IsSkinDrop = true,
				Number = 100,
				StickerName = "Merry Christmas!",
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
				Icon = "rbxassetid://9341850496",
				IsDoubleWeekend = true,
				Number = 300,
				Action = standard_gift_action
			}
		},
		CompletionReward = {
			Image = "rbxassetid://83524441093876",
			Required = 12,
			SkinName = "HotChocolate",
			Key = "PreChristmasCalendar",
			Action = give_skin
		}
	},
	PostChristmasCalendar = {
		Start = DateTime.fromUniversalTime(2025, 12, 26, 5, 0, 0),
		Start_Day = 26,
		Rewards = {
			{
				Icon = "rbxassetid://67225889",
				IsDoubleWeekend = true,
				IsSkinDrop = true,
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
				StickerName = "Happy holidays!",
				Action = standard_and_sticker_gift_action
			},
			{
				Icon = "rbxassetid://9341850496",
				IsDoubleWeekend = true,
				IsSkinDrop = true,
				Number = 300,
				Action = standard_gift_action
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
			}
		},
		CompletionReward = {
			Image = "rbxassetid://106028826685332",
			Required = 10,
			SkinName = "NewYearsGinger",
			Key = "PostChristmasCalendar",
			Action = give_skin
		}
	},
	Missions = {
		Rudie = {
			Start = DateTime.fromUniversalTime(2025, 12, 12, 5, 0, 0),
			RewardSkin = "GoldenAntlers",
			Order = 1,
			Quests = {
				Encounter = {
					Required = 10,
					Title = "Rudie's Encounter!",
					Description = "Encounter Twisted Rudie <font color='#83ff00'>10</font> times as Rudie."
				},
				Floor = {
					Required = 15,
					Title = "Rudie's Exploration!",
					Description = "Complete the new Holiday Floor <font color='#83ff00'>15</font> times as Rudie."
				},
				Ability = {
					Required = 30,
					Title = "Rudie's Ability!",
					Description = "Use this Toon's Ability <font color='#83ff00'>30</font> times while being chased (by a Twisted)."
				}
			}
		},
		Ginger = {
			Start = DateTime.fromUniversalTime(2025, 12, 12, 5, 0, 0),
			RewardSkin = "GoldenCookie",
			Order = 2,
			Quests = {
				Encounter = {
					Required = 10,
					Title = "Ginger's Encounter!",
					Description = "Encounter Twisted Ginger <font color='#83ff00'>10</font> times as Ginger."
				},
				Ability = {
					Required = 20,
					Title = "Ginger's Healing!",
					Description = "Heal any non-Main Toon on 1 Heart <font color='#83ff00'>20</font> times as Ginger."
				},
				Floor = {
					Required = 20,
					Title = "Ginger's Endurance!",
					Description = "Complete <font color='#83ff00'>Floor 20</font> as Ginger."
				}
			}
		},
		Coal = {
			Start = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0),
			RewardSkin = "GoldenDust",
			Order = 3,
			Quests = {
				Encounter = {
					Required = 10,
					Title = "Coal's Encounter!",
					Description = "Encounter Twisted Coal <font color='#83ff00'>10</font> times as Coal."
				},
				Pickup = {
					Required = 200,
					Title = "Coal's Collection!",
					Description = "Pick up <font color='#83ff00'>200 items</font> as Coal."
				},
				Floor = {
					Required = 10,
					Title = "Coal's Endurance!",
					Description = "Complete <font color='#83ff00'>Floor 10</font> as Coal with the Coal trinket equipped."
				}
			}
		},
		Bobette = {
			Start = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0),
			RewardSkin = "GoldenBauble",
			Order = 4,
			Quests = {
				Encounter = {
					Required = 10,
					Title = "Bobette's Encounter!",
					Description = "Encounter Twisted Bobette <font color='#83ff00'>10</font> times as Bobette."
				},
				Iced = {
					Required = 15,
					Title = "Bobette's Ice Adventure!",
					Description = "Experience the iced-over event <font color='#83ff00'>15</font> times as Bobette."
				},
				Floor = {
					Required = 20,
					Title = "Bobette's Endurance!",
					Description = "Complete <font color='#83ff00'>Floor 20</font> as Bobette with the Toy Kit trinket equipped."
				}
			}
		}
	}
}
local SimulatedTime

if RunService:IsServer() then
	SimulatedTime = require(script.Parent.Parent:WaitForChild("SharedUtils"):WaitForChild("SimulatedTime"))

	if game.PlaceId ~= 17754702286 then
		local _ = game.PlaceId == 18984409256
	end
else
	SimulatedTime = nil
end

function v.UpdateMission(p, p2, value: string, value2: string, flag: boolean, p3: number?)
	if RunService:IsClient() then
		return
	end

	local unixTimestamp = SimulatedTime.now().UnixTimestamp
	local v2 = (tonumber(p3) or 0) > 0 and tonumber(p3) or 1

	if not value or typeof(value) ~= "string" or (not value2 or typeof(value2) ~= "string") then
		return
	end

	if not p.Missions[value] or not p.Missions[value].Quests or typeof(p.Missions[value].Quests) ~= "table" then
		return
	end

	if not p.Missions[value].Quests[value2] or typeof(p.Missions[value].Quests[value2]) ~= "table" or unixTimestamp < p.Missions[value].Start.UnixTimestamp then
		return
	end

	local christmas25 = p2.Data.Seasonal.Christmas25

	if not christmas25 or not christmas25.Quests or typeof(christmas25.Quests) ~= "table" then
		return
	end

	if not p2.Data.Seasonal.Christmas25.Quests[value] then
		p2.Data.Seasonal.Christmas25.Quests[value] = {}
	end

	local v3 = p2.Data.Seasonal.Christmas25.Quests[value][value2] or 0

	if flag then
		local quest = p2.Data.Seasonal.Christmas25.Quests[value]

		if v3 < v2 then
			v3 = v2 or v3
		end

		quest[value2] = v3
	else
		p2.Data.Seasonal.Christmas25.Quests[value][value2] = v3 + v2
	end

	local quests = p.Missions[value].Quests
	local v4 = p2 and p2.Data.Seasonal and p2.Data.Seasonal.Christmas25 and p2.Data.Seasonal.Christmas25.Quests and p2.Data.Seasonal.Christmas25.Quests[value]
	local v5 = {}

	for k, quest in pairs(quests) do
		if v4[k] then
			local v6 = v4[k]
			local required = quest.Required

			if v6 < required then
				table.insert(v5, k .. ": " .. v6 .. "/" .. required)
			end
		else
			table.insert(v5, k .. ": not started")
		end
	end

	if #v5 <= 0 then
		if typeof(p2.Data.Seasonal.Christmas25.QuestProgressNotified) ~= "table" then
			p2.Data.Seasonal.Christmas25.QuestProgressNotified = {}
		end

		if p2.Data.Seasonal.Christmas25.QuestProgressNotified[value] == nil then
			p2.Data.Seasonal.Christmas25.QuestProgressNotified[value] = 1
		end
	end

	return true
end

return (setmetatable(v, {
	__index = function(p, p2)
		if p2 == "PreEventCalendar" then
			return (rawget(p, "PreChristmasCalendar"))
		elseif p2 == "PostEventCalendar" then
			return (rawget(p, "PostChristmasCalendar"))
		end

		return p[p2]
	end
}))