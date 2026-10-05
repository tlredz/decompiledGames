local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Universe = require(ReplicatedStorage.SharedUtils.Universe)
local HolidayCollectionHunting = require(ReplicatedStorage.SharedUtils.HolidayCollectionHunting)
HolidayCollectionHunting.Init(require(ReplicatedStorage.SharedData.Halloween26Collectables))
task.defer(function()
	local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)

	if not HolidayEventConfig.ENABLED then
		return
	end

	local holidayPuzzles = ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("HolidayPuzzles", 30)

	if not holidayPuzzles then
		warn("[Halloween26] SharedUtils.HolidayPuzzles never replicated — the Gourdy quest is disabled")
		return
	end

	local GourdyLockboxQuest = require(holidayPuzzles:WaitForChild("GourdyLockboxQuest"))
	GourdyLockboxQuest.Start()
end)
local metaInfo = {
	Tiles = {
		CalendarPage1 = {
			TL = "rbxassetid://79212401249618",
			TR = "rbxassetid://134961391109682",
			BL = "rbxassetid://140294468419194",
			BR = "rbxassetid://119431040667013"
		},
		CalendarPage2 = {
			TL = "rbxassetid://131033659322489",
			TR = "rbxassetid://104794351872342",
			BL = "rbxassetid://75969316850272",
			BR = "rbxassetid://78174151270677"
		},
		CalendarPage1Schedule = {
			TL = "rbxassetid://135926875006873",
			TR = "rbxassetid://89105363541214"
		},
		CalendarPage2Schedule = {
			TL = "rbxassetid://130157396853528",
			TR = "rbxassetid://131280118165279"
		},
		CalendarPage1Dates = {
			TL = "rbxassetid://137169539509585",
			TR = "rbxassetid://87000525153530"
		},
		CalendarPage2Dates = {
			TL = "rbxassetid://87448744135607",
			TR = "rbxassetid://133261633759919"
		},
		MissionsPage1 = {
			TL = "rbxassetid://140188096161336",
			TR = "rbxassetid://74277889134909",
			BL = "rbxassetid://85354626849380",
			BR = "rbxassetid://72375203939174"
		}
	},
	Icons = {
		Reward = "rbxassetid://111715100848538",
		RewardGold = "rbxassetid://6794188517",
		RewardDouble = "rbxassetid://126761416493258",
		DoubleEarnings = "rbxassetid://100411650095318",
		SkinDrop = "rbxassetid://94440026336841",
		RewardBackground = "rbxassetid://122024393527107",
		HeaderIcon = "rbxassetid://88073950688765",
		CalendarTabIcon = "rbxassetid://88073950688765",
		QuestTab = "rbxassetid://133323806759129",
		CalendarTab = "rbxassetid://95357639601292"
	},
	Templates = {
		Missed = "MissedHalloween"
	},
	Currency = {
		Gradient = "Halloween"
	},
	Shop = {
		YearColors = {
			[2025] = Color3.fromRGB(86, 41, 11),
			[2026] = Color3.fromRGB(106, 57, 176)
		}
	},
	Previews = {
		PreEventCalendar = {
			Thumbnail = "rbxassetid://102451632248450",
			CompletionImage = "rbxassetid://102451632248450"
		},
		PostEventCalendar = {
			Thumbnail = "rbxassetid://104548386083098",
			CompletionImage = "rbxassetid://104548386083098"
		},
		Gourdy = {
			Thumbnail = "rbxassetid://86811145167738"
		},
		Ribecca = {
			Thumbnail = "rbxassetid://135559181377019"
		},
		Soulvester = {
			Thumbnail = "rbxassetid://130227836578764"
		},
		Eclipse = {
			Thumbnail = "rbxassetid://116200735933931"
		}
	},
	Text = {
		MissionsTitle = "Holiday Quests #%d"
	},
	Calendars = {
		PreEventCalendar = {
			Note = "<stroke color=\"#604f26\" thickness=\"1px\"><b>TO DO:</b></stroke> log in each day to collect Pumpkins, join <u>ALL 12 DAYS</u><br/> to unlock the exclusive calendar skin!"
		},
		PostEventCalendar = {
			Note = "<stroke color=\"#604f26\" thickness=\"1px\"><b>TO DO:</b></stroke> log in each day to collect Pumpkins, join <u>ALL 13 DAYS</u><br/> to unlock the exclusive calendar skin!"
		}
	}
}

local function standard_gift_action(p, _, p2)
	local number = p.Number or 1
	local pumpkins = p2.Data.Seasonal.Halloween26.Pumpkins or 0
	p2.Data.Seasonal.Halloween26.Pumpkins = pumpkins + number
	return true, {
		rewardType = "Pumpkins",
		amount = number,
		newBalance = p2.Data.Seasonal.Halloween26.Pumpkins
	}
end

local function standard_and_sticker_gift_action(p, p2, p3)
	local number = p.Number or 1
	local stickerName = p.StickerName
	local stickerGiven = false
	local pumpkins = p3.Data.Seasonal.Halloween26.Pumpkins or 0
	p3.Data.Seasonal.Halloween26.Pumpkins = pumpkins + number

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
		rewardType = "PumpkinsAndSticker",
		amount = number,
		newBalance = p3.Data.Seasonal.Halloween26.Pumpkins,
		stickerName = stickerName,
		stickerGiven = stickerGiven
	}
end

local function standard_and_print_gift_action(p, p2, p3)
	local number = p.Number or 1
	local printName = p.PrintName
	local printGiven = false
	local pumpkins = p3.Data.Seasonal.Halloween26.Pumpkins or 0
	p3.Data.Seasonal.Halloween26.Pumpkins = pumpkins + number

	if printName and printName ~= "" then
		if not p3.Data.BackgroundsOwned then
			p3.Data.BackgroundsOwned = {}
		end

		if table.find(p3.Data.BackgroundsOwned, printName) then
			print(string.format("[Calendar] %s already owns print '%s'", p2.Name, printName))
		else
			printGiven = true
		end
	end

	return true, {
		rewardType = "PumpkinsAndPrint",
		amount = number,
		newBalance = p3.Data.Seasonal.Halloween26.Pumpkins,
		printName = printName,
		printGiven = printGiven
	}
end

local function give_skin(data, p, p2, object)
	local skinName = data.SkinName
	local key = data.Key
	local required = data.Required
	local v2 = p2 and p2.Data.Seasonal and p2.Data.Seasonal.Halloween26 and p2.Data.Seasonal.Halloween26.Calendars and p2.Data.Seasonal.Halloween26.Calendars[key]

	if v2 then
		local login = v2.Login or {}
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

local Halloween26 = {
	CurrencyModelName = "Pumpkin",
	MetaInfo = metaInfo,
	CurrencyPickupSound = nil,
	Active = {
		Start = DateTime.fromUniversalTime(2026, 10, 2, 4, 0, 0),
		End = DateTime.fromUniversalTime(2026, 11, 6, 19, 0, 0)
	},
	PreEventCalendar = {
		Start = DateTime.fromUniversalTime(2026, 10, 7, 4, 0, 0),
		Start_Day = 7,
		Rewards = {
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.RewardDouble,
				IsDoubleWeekend = true,
				IsSkinDrop = true,
				Number = 100,
				StickerName = "Happy Halloween!",
				Action = standard_and_sticker_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				IsDoubleWeekend = true,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				IsDoubleWeekend = true,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				PrintName = "HauntedHouse",
				Action = standard_and_print_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.RewardDouble,
				IsDoubleWeekend = true,
				IsSkinDrop = true,
				Number = 100,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				IsDoubleWeekend = true,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.RewardDouble,
				IsDoubleWeekend = true,
				Number = 300,
				Action = standard_gift_action
			}
		},
		CompletionReward = {
			Image = metaInfo.Previews.PreEventCalendar.CompletionImage,
			Required = 12,
			SkinName = "UnearthedSpirit",
			Key = "PreEventCalendar",
			Action = give_skin
		}
	},
	PostEventCalendar = {
		Start = DateTime.fromUniversalTime(2026, 10, 19, 4, 0, 0),
		Start_Day = 19,
		Rewards = {
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				IsDoubleWeekend = true,
				IsSkinDrop = true,
				Number = 50,
				StickerName = "Trick or Treat!",
				Action = standard_and_sticker_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				IsDoubleWeekend = true,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				IsDoubleWeekend = true,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.Reward,
				Number = 50,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.RewardDouble,
				IsDoubleWeekend = true,
				IsSkinDrop = true,
				Number = 300,
				Action = standard_gift_action
			},
			{
				Icon = metaInfo.Icons.RewardDouble,
				IsDoubleWeekend = true,
				Number = 300,
				Action = standard_gift_action
			}
		},
		CompletionReward = {
			Image = metaInfo.Previews.PostEventCalendar.CompletionImage,
			Required = 13,
			SkinName = "FoundKnight",
			Key = "PostEventCalendar",
			Action = give_skin
		}
	},
	Missions = {
		Ribecca = {
			Start = DateTime.fromUniversalTime(2026, 10, 2, 19, 0, 0),
			RewardSkin = "GoldenSkeleton",
			Order = 1,
			Quests = {
				Encounter = {
					Order = 1,
					Required = 10,
					Title = "Ribecca's Encounter!",
					Description = "Encounter Twisted Ribecca <font color='#83ff00'>10</font> times as Ribecca."
				},
				Puddles = {
					Order = 2,
					Required = 15,
					Title = "Ribecca's Wander!",
					Description = "Walk through <font color='#83ff00'>15</font> unique ichor puddles as Ribecca."
				},
				Floor = {
					Order = 3,
					Required = 10,
					Title = "Ribecca's Haunt!",
					Description = "Complete a Halloween Floor <font color='#83ff00'>10</font> times as Ribecca."
				}
			}
		},
		Soulvester = {
			Start = DateTime.fromUniversalTime(2026, 10, 2, 19, 0, 0),
			RewardSkin = "GoldenKnight",
			Order = 2,
			Quests = {
				Encounter = {
					Order = 1,
					Required = 10,
					Title = "Soulvester's Encounter!",
					Description = "Encounter Twisted Soulvester <font color='#83ff00'>10</font> times as Soulvester."
				},
				Floor = {
					Order = 2,
					Required = 20,
					Title = "Soulvester's Company!",
					Description = "Complete <font color='#83ff00'>20</font> Floors alongside at least one Halloween Toon or Connie as Soulvester."
				},
				Protect = {
					Order = 3,
					Required = 10,
					Title = "Soulvester's Guard!",
					Description = "Protect another Toon from taking damage <font color='#83ff00'>10</font> times."
				}
			}
		},
		Eclipse = {
			Start = DateTime.fromUniversalTime(2026, 10, 9, 19, 0, 0),
			RewardSkin = "PLACEHOLDER_GoldenEclipse",
			Order = 3,
			Quests = {
				Encounter = {
					Order = 1,
					Required = 5,
					Title = "Eclipse's Encounter!",
					Description = "Encounter Twisted Eclipse <font color='#83ff00'>5</font> times as Eclipse."
				},
				Blackout = {
					Order = 2,
					Required = 5,
					Title = "Eclipse's Darkness!",
					Description = "Experience the Blackout event <font color='#83ff00'>5</font> times as Eclipse."
				},
				Floor = {
					Order = 3,
					Required = 35,
					Title = "Eclipse's Endurance!",
					Description = "Complete <font color='#83ff00'>35</font> total Floors as Eclipse."
				}
			}
		},
		Gourdy = {
			Start = DateTime.fromUniversalTime(2026, 10, 9, 19, 0, 0),
			RewardSkin = "PLACEHOLDER_GoldenGourdy",
			Order = 4,
			Quests = {
				Encounter = {
					Order = 1,
					Required = 5,
					Title = "Gourdy's Encounter!",
					Description = "Encounter Twisted Gourdy <font color='#83ff00'>5</font> times as Gourdy."
				},
				Floor = {
					Order = 2,
					Required = 20,
					Title = "Gourdy's Keepsake!",
					Description = "Complete <font color='#83ff00'>Floor 20</font> as Gourdy with the Memory Locket trinket equipped."
				},
				Doors = {
					Order = 3,
					Required = 20,
					Title = "Gourdy's Trick or Treat!",
					Description = "Open <font color='#83ff00'>20</font> Trick or Treat doors as Gourdy."
				}
			}
		}
	}
}
local SimulatedTime

if RunService:IsServer() then
	SimulatedTime = require(script.Parent.Parent:WaitForChild("SharedUtils"):WaitForChild("SimulatedTime"))

	if Universe:IsGame() then
		local Players = game:GetService("Players")
		local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
		local v2 = nil
		task.defer(function()
			local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)
			v2 = HolidayEventConfig
		end)

		local function isHolidayEnabled()
			return v2 and v2.ENABLED
		end

		local editData = ReplicatedStorage:WaitForChild("editData")

		local function runOnProfile(p, fn)
			if not (v2 and v2.ENABLED) then
				return false, "Holiday disabled"
			end

			local v3 = true
			local v4 = "N/A"
			editData:Invoke(p, function(p2)
				if p2 then
					local success, result = pcall(fn, p2)

					if not success then
						v4 = result
						v3 = false
					end
				else
					v4 = "Profile does not exist"
					v3 = false
				end
			end)

			if not v3 then
				warn("[Halloween26] mission update failed:", (tostring(v4)))
			end

			return v3, v4
		end

		local ServerScriptService = game:GetService("ServerScriptService")
		local ReplicaUpdater = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("ReplicaUpdater"))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateMission(p, p2, p3, p4, p5)
			runOnProfile(p, function(p6)
				if not Halloween26:UpdateMission(p6, p2, p3, p4, p5) then
					return
				end

				local halloween26 = p6.Data.Seasonal.Halloween26
				ReplicaUpdater:UpdateValue(p, "Seasonal." .. "Halloween26" .. ".Quests." .. p2, halloween26.Quests[p2])

				if typeof(halloween26.QuestProgressNotified) == "table" then
					ReplicaUpdater:UpdateValue(
						p,
						"Seasonal.Halloween26.QuestProgressNotified",
						halloween26.QuestProgressNotified
					)
				end
			end)
		end

		local function isAlive(instance)
			local humanoid = instance and instance:FindFirstChildOfClass("Humanoid")
			return humanoid ~= nil and humanoid.Health > 0
		end

		local v3 = {
			Ribecca = {
				RibeccaMonster = true
			},
			Soulvester = {
				SoulvesterMonster = true
			},
			Eclipse = {
				EclipseMonster = true,
				EclipseMonsterMoon = true
			},
			Gourdy = {
				GourdyMonster = true
			}
		}
		ActionEvent:ListenForEvent("EncounterTwisted", function(p, p2)
			local v4 = v3[p2.ToonName]

			if v4 and v4[p2.Args[1]] then
				updateMission(p, p2.ToonName, "Encounter", false, 1) -- equivalent call inferred; original call site unknown
			end
		end)
		local v4 = {}
		Players.PlayerRemoving:Connect(function(player)
			v4[player] = nil
		end)
		ActionEvent:ListenForEvent("EnterIchorPuddle", function(p, p2)
			local arg = p2.Args[1]

			if p2.ToonName ~= "Ribecca" or typeof(arg) ~= "Instance" then
				return
			end

			local v5 = v4[p]

			if not v5 then
				v5 = setmetatable({}, {
					__mode = "k"
				})
				v4[p] = v5
			end

			if v5[arg] then
				return
			end

			v5[arg] = true
			updateMission(p, "Ribecca", "Puddles", false, 1) -- equivalent call inferred; original call site unknown
		end)
		ActionEvent:ListenForEvent("CompleteFloor", function(player, p)
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local v5

			if humanoid == nil then
				v5 = false
			else
				v5 = humanoid.Health > 0
			end

			if not v5 then
				return
			end

			if p.ToonName == "Ribecca" and v2 and v2.IsHolidayMap(p.Args[1]) then
				updateMission(player, "Ribecca", "Floor", false, 1) -- equivalent call inferred; original call site unknown
			end
		end)
		local v5 = {
			Gourdy = true,
			Ribecca = true,
			Soulvester = true,
			Eclipse = true,
			Connie = true
		}
		ActionEvent:ListenForEvent("CompleteFloor", function(player, p)
			if p.ToonName == "Soulvester" then
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local v6

				if humanoid == nil then
					v6 = false
				else
					v6 = humanoid.Health > 0
				end

				if v6 then
					for _, child in ipairs(workspace.InGamePlayers:GetChildren()) do
						if child == player.Character or child:GetAttribute("IsBotCharacter") then
							continue
						end

						local humanoid2 = child and child:FindFirstChildOfClass("Humanoid")
						local v7

						if humanoid2 == nil then
							v7 = false
						else
							v7 = humanoid2.Health > 0
						end

						if not (v7 and v5[child:GetAttribute("ToonName")]) then
							continue
						end

						updateMission(player, "Soulvester", "Floor", false, 1) -- equivalent call inferred; original call site unknown
						return
					end
				end
			end
		end)
		ActionEvent:ListenForEvent("ProtectToon", function(p, p2)
			if p2.ToonName ~= "Soulvester" then
				return
			end

			updateMission(p, "Soulvester", "Protect", false, 1) -- equivalent call inferred; original call site unknown
		end)
		ActionEvent:ListenForEvent("ExperiencedFloorEvent", function(p, p2)
			if p2.ToonName == "Eclipse" and p2.Args[1] == "Blackout" then
				updateMission(p, "Eclipse", "Blackout", false, 1) -- equivalent call inferred; original call site unknown
			end
		end)
		ActionEvent:ListenForEvent("CompleteFloor", function(player, p)
			if p.ToonName == "Eclipse" then
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local v6

				if humanoid == nil then
					v6 = false
				else
					v6 = humanoid.Health > 0
				end

				if v6 then
					updateMission(player, "Eclipse", "Floor", false, 1) -- equivalent call inferred; original call site unknown
				end
			end
		end)
		ActionEvent:ListenForEvent("CompleteFloor", function(player, data)
			local v6 = data.Trinket1 == "MemoryLocket" or data.Trinket2 == "MemoryLocket"

			if data.ToonName == "Gourdy" and v6 then
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local v7

				if humanoid == nil then
					v7 = false
				else
					v7 = humanoid.Health > 0
				end

				if v7 then
					updateMission(player, "Gourdy", "Floor", true, math.clamp(tonumber(data.FloorNumber) or 0, 0, 20)) -- equivalent call inferred; original call site unknown
				end
			end
		end)
		ActionEvent:ListenForEvent("OpenTrickOrTreatDoor", function(p, p2)
			if p2.ToonName == "Gourdy" then
				updateMission(p, "Gourdy", "Doors", false, 1) -- equivalent call inferred; original call site unknown
			end
		end)
		local ServerStorage = game:GetService("ServerStorage")
		local AchievementGiver = require(ServerStorage:WaitForChild("SharedModules"):WaitForChild("AchievementGiver"))
		ActionEvent:ListenForEvent("OpenTrickOrTreatDoor", function(p)
			if v2 and v2.ENABLED then
				AchievementGiver:UpdateKey(p, "ID_62_TrickOrTreat26", false, 1)
			end
		end)
		ActionEvent:ListenForEvent("ExperiencedFloorEvent", function(p, p2)
			if not (v2 and v2.ENABLED) or p2.Args[1] ~= "HauntedGala" then
				return
			end

			AchievementGiver:UpdateKey(p, "ID_63_HauntedGala26", false, 1)
		end)
	end
else
	SimulatedTime = nil
end

function Halloween26:UpdateMission(p2, value: string, value2: string, flag: boolean, p3: number?)
	if RunService:IsClient() then
		return
	end

	local unixTimestamp = SimulatedTime.now().UnixTimestamp
	local v2 = (tonumber(p3) or 0) > 0 and tonumber(p3) or 1

	if not value or typeof(value) ~= "string" or (not value2 or typeof(value2) ~= "string") then
		return
	end

	if not self.Missions[value] or not self.Missions[value].Quests or typeof(self.Missions[value].Quests) ~= "table" then
		return
	end

	if not self.Missions[value].Quests[value2] or typeof(self.Missions[value].Quests[value2]) ~= "table" then
		return
	end

	if not Universe:IsTestRealm() and unixTimestamp < self.Missions[value].Start.UnixTimestamp then
		return
	end

	local halloween26 = p2.Data.Seasonal.Halloween26

	if not halloween26 or not halloween26.Quests or typeof(halloween26.Quests) ~= "table" then
		return
	end

	if not p2.Data.Seasonal.Halloween26.Quests[value] then
		p2.Data.Seasonal.Halloween26.Quests[value] = {}
	end

	local v3 = p2.Data.Seasonal.Halloween26.Quests[value][value2] or 0

	if flag then
		local quest = p2.Data.Seasonal.Halloween26.Quests[value]

		if v3 < v2 then
			v3 = v2 or v3
		end

		quest[value2] = v3
	else
		p2.Data.Seasonal.Halloween26.Quests[value][value2] = v3 + v2
	end

	local quests = self.Missions[value].Quests
	local v4 = p2 and p2.Data.Seasonal and p2.Data.Seasonal.Halloween26 and p2.Data.Seasonal.Halloween26.Quests and p2.Data.Seasonal.Halloween26.Quests[value]
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
		if typeof(p2.Data.Seasonal.Halloween26.QuestProgressNotified) ~= "table" then
			p2.Data.Seasonal.Halloween26.QuestProgressNotified = {}
		end

		if p2.Data.Seasonal.Halloween26.QuestProgressNotified[value] == nil then
			p2.Data.Seasonal.Halloween26.QuestProgressNotified[value] = 1
		end
	end

	return true
end

return Halloween26