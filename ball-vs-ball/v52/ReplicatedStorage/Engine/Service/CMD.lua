local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local service = ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service")

-- equivalent calls inferred from this helper; original call sites unknown
local function getConfig()
	return require(service:WaitForChild("Config"))
end

local function getPackGroupCandidates()
	local config = getConfig() -- equivalent call inferred; original call site unknown
	local result = {}

	for _, v in config.limitedPack.list do
		result[v.group] = true
	end

	return result
end

local function getAdminMailCandidates()
	local config = getConfig() -- equivalent call inferred; original call site unknown
	local result = {}

	for _, v in config.mail.list do
		if v.scope == "管理员发放" then
			result[v.cnId] = true
		end
	end

	return result
end

local v = {
	["Rewards & Items"] = {
		emoji = "🎁",
		commands = {
			["Give Diamonds"] = {
				order = 100,
				params = {
					Amount = {
						type = "integer",
						min = 1
					}
				},
				desc = "Give diamonds to the selected player.",
				serverFn = function(p, p2)
					local amount = p2.Amount
					local CurrencyService = require(service:WaitForChild("CurrencyService"))

					if typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Enter a whole number greater than 0."
						}
					end

					CurrencyService.server.give(p, CurrencyService.ref.Diamonds, amount)
				end
			},
			["Give Coins"] = {
				order = 110,
				params = {
					Amount = {
						type = "integer",
						min = 1
					}
				},
				desc = "Give coins to the selected player.",
				serverFn = function(p, p2)
					local amount = p2.Amount
					local CurrencyService = require(service:WaitForChild("CurrencyService"))

					if typeof(amount) ~= "number" or amount <= 0 or amount % 1 ~= 0 then
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Enter a whole number greater than 0."
						}
					end

					CurrencyService.server.give(p, CurrencyService.ref.Coins, amount)
				end
			},
			["Give Balls"] = {
				order = 120,
				params = {
					Ball = function()
						local config = getConfig() -- equivalent call inferred; original call site unknown
						return config.ball.byCnId
					end,
					Amount = {
						type = "integer",
						min = 1
					}
				},
				paramOrder = { "Ball", "Amount" },
				desc = "Give balls to the selected player. These balls cannot be traded or fused.",
				serverFn = function(p, p2)
					local ball = p2.Ball
					local amount = p2.Amount
					local ItemService = require(service:WaitForChild("ItemService"))

					if typeof(ball) == "string" then
						local config = getConfig() -- equivalent call inferred; original call site unknown

						if config.ball.byCnId[ball] ~= nil then
							if typeof(amount) ~= "number" or amount < 1 or amount % 1 ~= 0 then
								return {
									ok = false,
									code = "COMMAND_REJECTED",
									message = "Enter a whole number greater than 0."
								}
							end

							for _ = 1, amount do
								ItemService.server.grant(p, "Ball", ball, {
									tradable = false,
									canFusion = false,
									source = "管理员发小球"
								})
							end

							return
						end
					end

					return {
						ok = false,
						code = "COMMAND_REJECTED",
						message = "Choose a valid ball."
					}
				end
			},
			["Give Reward"] = {
				order = 130,
				params = {
					Reward = function()
						local config = getConfig() -- equivalent call inferred; original call site unknown
						return config.reward.byCnId
					end
				},
				desc = "Give the selected reward to the selected player.",
				serverFn = function(p, p2)
					local reward = p2.Reward
					local RewardItemService = require(service:WaitForChild("RewardItemService"))

					if typeof(reward) ~= "string" or reward == "" then
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Choose a reward."
						}
					end

					if RewardItemService.grant(p, reward).ok then
						return
					else
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Could not give the reward."
						}
					end
				end
			},
			["Grant Code"] = {
				order = 140,
				params = {
					Username = "playerName",
					Code = function()
						local config = getConfig() -- equivalent call inferred; original call site unknown
						return config.codes.byCode
					end
				},
				paramOrder = { "Username", "Code" },
				desc = "Allow a username to redeem the selected code. Works for offline players.",
				serverFn = function(_, p)
					local username = p.Username
					local code = p.Code
					local RedeemCodeService = require(service:WaitForChild("RedeemCodeService"))
					local v2, _ = RedeemCodeService.server.grantToPlayerName(username, code)

					if v2 then
						return
					else
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Could not grant the code. Check the username and code."
						}
					end
				end
			},
			["Send Mail"] = {
				order = 150,
				params = {
					Username = "playerName",
					Mail = function()
						return (getAdminMailCandidates())
					end
				},
				paramOrder = { "Username", "Mail" },
				desc = "Send mail to a username. It arrives on their next visit, even if they are offline.",
				serverFn = function(p, p2)
					local username = p2.Username
					local mail = p2.Mail
					local MailService = require(service:WaitForChild("MailService"))
					local v2, _ = MailService.server.enqueueAdmin(username, mail, p.UserId)

					if not v2 then
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Could not send mail. Check the username and mail."
						}
					end

					print((`[CMD] 已向 {username} 发送邮件 {mail}，对方下次进服时投递`))
				end
			},
			["Give All Balls"] = {
				order = 300,
				desc = "Give one of each available ball. These balls cannot be traded or fused. Can be repeated.",
				serverFn = function(p, _)
					local ItemService = require(service:WaitForChild("ItemService"))
					require(service:WaitForChild("Config"))
					local config = getConfig() -- equivalent call inferred; original call site unknown

					for _, v2 in config.ball.list do
						if v2.canPlayerUse then
							ItemService.server.grant(p, "Ball", v2.cnId, {
								tradable = false,
								canFusion = false,
								source = "管理员发放"
							})
						end
					end
				end
			},
			["Complete Collection"] = {
				order = 310,
				desc = "Give all missing balls, explosion effects, and vehicles. These items cannot be traded or fused.",
				serverFn = function(p, _)
					local ItemService = require(service:WaitForChild("ItemService"))
					require(service:WaitForChild("Config"))
					local PlayerData = require(service:WaitForChild("PlayerData"))
					local items = PlayerData.server[p].items()
					local v2 = {
						Ball = {},
						["爆炸特效"] = {},
						["飞行器"] = {}
					}

					for _, item in items do
						if typeof(item) == "table" and v2[item.itemType] then
							v2[item.itemType][item.itemId] = true
						end
					end

					local count = 0

					-- equivalent calls inferred from this helper; original call sites unknown
					local function fillMissing(p2: string, cnId: string)
						if v2[p2][cnId] then
							return
						end

						ItemService.server.grant(p, p2, cnId, {
							tradable = false,
							canFusion = false,
							source = "全库存补全"
						})
						v2[p2][cnId] = true
						count += 1
					end

					local config = getConfig() -- equivalent call inferred; original call site unknown

					for _, v3 in config.ball.list do
						if not v3.canPlayerUse then
							continue
						end

						fillMissing("Ball", v3.cnId) -- equivalent call inferred; original call site unknown
					end

					local config2 = getConfig() -- equivalent call inferred; original call site unknown

					for _, v3 in config2.skin.bySkinType["爆炸特效"] or {} do
						fillMissing("爆炸特效", v3.cnId) -- equivalent call inferred; original call site unknown
					end

					local config3 = getConfig() -- equivalent call inferred; original call site unknown

					for _, v3 in config3.skin.bySkinType["飞行器"] or {} do
						fillMissing("飞行器", v3.cnId) -- equivalent call inferred; original call site unknown
					end

					print(("[CMD] 全库存补全完成，共发放 %d 件锁交易物品"):format(count))
				end
			},
			["Give All Titles"] = {
				order = 320,
				desc = "Give all missing titles and equip the last one.",
				serverFn = function(p, _)
					local PlayerTitleService = require(service:WaitForChild("PlayerTitleService"))
					print(("[CMD] 已发放 %d 个头衔"):format(PlayerTitleService.server.grantAll(p)))
				end
			},
			["Clear Titles"] = {
				order = 330,
				desc = "Remove all titles from the selected player.",
				serverFn = function(p, _)
					local PlayerTitleService = require(service:WaitForChild("PlayerTitleService"))
					PlayerTitleService.server.clearAll(p)
				end
			}
		}
	},
	["Daily Rewards"] = {
		emoji = "📅",
		commands = {
			["Claim Invite Reward"] = {
				order = 90,
				desc = "Claim the friend invite reward for the selected player.",
				serverFn = function(p, _)
					local FriendInviteRewardService = require(service:WaitForChild("FriendInviteRewardService"))
					FriendInviteRewardService.server.claimInviterReward(p)
				end
			},
			["Complete Daily Quests"] = {
				order = 160,
				desc = "Complete today's quests without claiming rewards.",
				serverFn = function(p, _)
					local DailyQuestService = require(service:WaitForChild("DailyQuestService"))
					DailyQuestService.server.finishAllQuests(p)
				end
			},
			["Add Playtime"] = {
				order = 170,
				params = {
					Minutes = {
						type = "number",
						min = 0,
						exclusiveMin = true
					}
				},
				desc = "Add minutes to today's playtime for the selected player.",
				serverFn = function(p, p2)
					local minutes = p2.Minutes
					local OnlineRewardService = require(service:WaitForChild("OnlineRewardService"))

					if OnlineRewardService.addMinutes(p, minutes) then
						return
					else
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Enter minutes greater than 0."
						}
					end
				end
			},
			["Unlock Check-In Rewards"] = {
				order = 180,
				desc = "Unlock all seven days in the current check-in round without claiming rewards.",
				serverFn = function(p, _)
					local CheckInService = require(service:WaitForChild("CheckInService"))
					CheckInService.server.debugUnlockAll(p)
				end
			},
			["Start Repeat Check-In"] = {
				order = 280,
				desc = "Skip the starter check-in and reset to day one of the repeating round.",
				serverFn = function(p, _)
					local CheckInService = require(service:WaitForChild("CheckInService"))
					CheckInService.server.debugEnterLoop(p)
				end
			},
			["Reset First Match Reward"] = {
				order = 190,
				desc = "Allow the next completed match to grant today's first-match coin boost again.",
				serverFn = function(p, _)
					local BoostService = require(service:WaitForChild("BoostService"))
					BoostService.server.resetDailyFirstMatch(p)
				end
			},
			["Clear Coin Boost"] = {
				order = 210,
				desc = "End the selected player's coin boost.",
				serverFn = function(p, _)
					local BoostService = require(service:WaitForChild("BoostService"))
					BoostService.server.clearBoost(p, "金币加成")
				end
			}
		}
	},
	["Shop & Draw"] = {
		emoji = "🛒",
		commands = {
			["Refresh Daily Shop"] = {
				order = 220,
				desc = "Replace today's shop items and allow them to be bought again.",
				serverFn = function(p, _)
					local DailyShopService = require(service:WaitForChild("DailyShopService"))
					DailyShopService.server.debugReroll(p)
				end
			},
			["Reset Daily Diamond Deal"] = {
				order = 230,
				desc = "Allow the next daily diamond deal to be bought today. Keep the purchase streak.",
				serverFn = function(p, _)
					local DailyDiamondDealService = require(service:WaitForChild("DailyDiamondDealService"))

					if DailyDiamondDealService.server.resetTodayPurchase(p) then
						return
					else
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "No daily diamond deal purchase to reset today."
						}
					end
				end
			},
			["Reset Daily Diamonds"] = {
				order = 240,
				desc = "Allow the next daily diamonds offer to be bought today. Keep the purchase streak.",
				serverFn = function(p, _)
					local DailyDiamondsService = require(service:WaitForChild("DailyDiamondsService"))

					if DailyDiamondsService.server.resetTodayPurchase(p) then
						return
					else
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "No daily diamonds purchase to reset today."
						}
					end
				end
			},
			["Give Draw Tickets"] = {
				order = 250,
				params = {
					Amount = {
						type = "integer",
						min = 1
					}
				},
				desc = "Add diamond draw tickets. If entries are closed, tickets go to the next round.",
				serverFn = function(p, p2)
					local amount = p2.Amount

					if typeof(amount) ~= "number" or amount < 1 or amount % 1 ~= 0 then
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Enter a whole number greater than 0."
						}
					end

					local DiamondDrawService = require(service:WaitForChild("DiamondDrawService"))
					DiamondDrawService.server.addTickets(p, amount)
				end
			},
			["Add to Prize Pool"] = {
				order = 260,
				params = {
					Diamonds = {
						type = "number",
						min = 0,
						exclusiveMin = true
					}
				},
				desc = "Add diamonds to the shared prize pool without spending the player's diamonds.",
				serverFn = function(p, p2)
					local diamonds = p2.Diamonds

					if typeof(diamonds) ~= "number" or diamonds <= 0 then
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Enter diamonds greater than 0."
						}
					end

					local DiamondDrawService = require(service:WaitForChild("DiamondDrawService"))
					DiamondDrawService.server.debugAddContribution(p, diamonds)
				end
			},
			["Draw Now"] = {
				order = 270,
				desc = "Draw the current round early across all servers in this game. The scheduled draw will be skipped.",
				serverFn = function(_, _)
					local DiamondDrawService = require(service:WaitForChild("DiamondDrawService"))

					if DiamondDrawService.server.debugDrawNow() then
						return
					else
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Could not complete the draw. Please try again later."
						}
					end
				end
			}
		}
	},
	["XP & Levels"] = {
		emoji = "📊",
		commands = {
			["Give XP"] = {
				order = 350,
				params = {
					Amount = {
						type = "integer",
						min = 1
					}
				},
				paramOrder = { "Amount" },
				desc = "Give XP to the selected player.",
				serverFn = function(p, p2)
					local amount = p2.Amount
					local ExperienceService = require(service:WaitForChild("ExperienceService"))

					if ExperienceService.server.add(p, amount) then
						return
					else
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Enter a whole number greater than 0."
						}
					end
				end
			},
			["Reset XP"] = {
				order = 360,
				desc = "Reset the selected player's XP and daily first-match XP reward.",
				serverFn = function(p, _)
					local ExperienceService = require(service:WaitForChild("ExperienceService"))
					ExperienceService.server.reset(p)
				end
			},
			["Clear XP Boost"] = {
				order = 200,
				desc = "End the selected player's XP boost.",
				serverFn = function(p, _)
					local BoostService = require(service:WaitForChild("BoostService"))
					BoostService.server.clearBoost(p, "经验加成")
				end
			}
		}
	},
	Battle = {
		emoji = "⚔️",
		commands = {
			["Battle Simulator"] = {
				order = 30,
				desc = "Open the battle simulator.",
				hideUIAfterExec = true,
				clientFn = function(_, _)
					local SimBattlePanelService = require(service:WaitForChild("SimBattlePanelService"))
					SimBattlePanelService.open()
				end
			},
			["Join 2v2"] = {
				order = 40,
				desc = "Join an available 2v2 seat. Four players are needed to start.",
				clientFn = function(_, _)
					local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
					Net:RemoteEvent("Duel2v2QuickPlayRequest"):FireServer()
				end
			},
			["Battle Analysis"] = {
				order = 50,
				desc = "Open battle analysis. Only available in Studio.",
				hideUIAfterExec = true,
				clientFn = function(_, _)
					local BattleAnalysisPanelService = require(service:WaitForChild("BattleAnalysisPanelService"))
					BattleAnalysisPanelService.open()
				end
			},
			["Ball Collection"] = {
				order = 60,
				desc = "View ball win rates and match results.",
				hideUIAfterExec = true,
				clientFn = function(_, _)
					local UIManager = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Gui"):WaitForChild("UIManager"))
					UIManager.Get("BallIndex").Open()
				end
			},
			["Set Win Streak"] = {
				order = 290,
				params = {
					Streak = {
						type = "integer",
						min = 0
					}
				},
				desc = "Set the selected player's current win streak.",
				serverFn = function(p, p2)
					local streak = p2.Streak

					if typeof(streak) ~= "number" or streak < 0 or streak % 1 ~= 0 then
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Enter a whole number of 0 or more."
						}
					end

					local WinStreakDisplay = require(service:WaitForChild("WinStreakDisplay"))
					WinStreakDisplay.setStreak(p, streak)
				end
			}
		}
	},
	Testing = {
		emoji = "🔧",
		commands = {
			["Test Bundle Switch"] = {
				order = 10,
				params = {
					Bundle = function()
						local config = getConfig() -- equivalent call inferred; original call site unknown
						local result = {}

						for _, v2 in config.limitedPack.list do
							result[v2.group] = true
						end

						return result
					end,
					["Delay (seconds)"] = {
						type = "number",
						default = 30,
						min = 0
					}
				},
				paramOrder = { "Bundle", "Delay (seconds)" },
				desc = "Switch the bundle shown to you after a delay. Default: 30 seconds.",
				hideUIAfterExec = true,
				clientFn = function(_, p)
					local bundle = p.Bundle
					local delayseconds = p["Delay (seconds)"]
					local countdown = (delayseconds == nil or delayseconds == "") and 30 or tonumber(delayseconds)

					if countdown == nil then
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Enter a delay of 0 seconds or more."
						}
					end

					local LimitedPackService = require(service.LimitedPackService)
					local v3, _ = LimitedPackService.startSwitchTest(bundle, countdown)

					if v3 then
						return {
							ok = true,
							code = "STARTED",
							message = "Bundle test started.",
							data = {
								group = bundle,
								countdown = countdown,
								state = countdown == 0 and "active" or "pending"
							}
						}
					end

					return {
						ok = false,
						code = "COMMAND_REJECTED",
						message = "Could not start the bundle test. Check the bundle and delay."
					}
				end
			},
			["End Bundle Test"] = {
				order = 20,
				desc = "Cancel the test and restore your normal bundle offers.",
				hideUIAfterExec = true,
				clientFn = function(_, _)
					local LimitedPackService = require(service.LimitedPackService)
					LimitedPackService.endSwitchTest()
					return {
						ok = true,
						message = "Normal bundle offers restored."
					}
				end
			},
			["Test Weekly Leaderboard Settlement"] = {
				order = 30,
				params = {
					["Delay (seconds)"] = {
						type = "number",
						default = 30,
						min = 0,
						max = 3600
					}
				},
				desc = "After a countdown, read this week's real ranks and send claimable test reward mail to online winners in this server. Does not reset the real board.",
				hideUIAfterExec = true,
				serverFn = function(_, p)
					local delayseconds = p["Delay (seconds)"]
					local v2 = (delayseconds == nil or delayseconds == "") and 30 or delayseconds
					local MailService = require(service.MailService)
					local ok, message = MailService.server.startWeeklySettlementTest(v2)
					return {
						ok = ok,
						code = ok and "STARTED" or "COMMAND_REJECTED",
						message = message
					}
				end
			},
			["End Weekly Leaderboard Test"] = {
				order = 40,
				desc = "Cancel the pending weekly leaderboard test and restore its normal countdown. Already delivered rewards are kept.",
				serverFn = function(_, _)
					local MailService = require(service.MailService)
					local ok, message = MailService.server.endWeeklySettlementTest()
					return {
						ok = ok,
						message = message
					}
				end
			},
			["Test Rainbow Fusion Announcement"] = {
				order = 60,
				params = {
					Ball = function()
						local config = getConfig() -- equivalent call inferred; original call site unknown
						return config.ball.byCnId
					end,
					Serial = {
						type = "integer",
						min = 1,
						max = 9007199254740991
					}
				},
				paramOrder = { "Ball", "Serial" },
				desc = "Broadcast a Rainbow Fusion announcement across servers. No items are granted.",
				serverFn = function(p, p2)
					local FusionAnnouncementService = require(service.FusionAnnouncementService)

					if FusionAnnouncementService.enqueue(p, p2.Ball, p2.Serial) then
						return {
							ok = true,
							message = "Announcement queued for cross-server broadcast."
						}
					end

					return {
						ok = false,
						code = "COMMAND_REJECTED",
						message = "Choose a valid ball and positive serial, or try again when the queue has space."
					}
				end
			},
			["Add Test Ball Stats"] = {
				order = 70,
				desc = "Show random sample ball stats, visible only to you.",
				hideUIAfterExec = true,
				clientFn = function(_, _)
					local BallBattleStatsService = require(service:WaitForChild("BallBattleStatsService"))
					require(service:WaitForChild("Config"))
					local config = getConfig() -- equivalent call inferred; original call site unknown
					local list = config.ball.list
					local v2 = {}

					for _, v3 in list do
						v2[v3.cnId] = {
							opponents = {},
							mirror = {
								games = 0,
								draws = 0
							}
						}
					end

					for i = 1, #list do
						local cnId = list[i].cnId

						for i2 = i + 1, #list do
							local cnId2 = list[i2].cnId
							local v3 = math.random(0, 400)

							if not (v3 > 0) then
								continue
							end

							local draws = math.random(0, v3 // 6)
							local v5 = math.random(0, v3 - draws)
							local v6 = v3 - draws - v5
							v2[cnId].opponents[cnId2] = {
								wins = v5,
								losses = v6,
								draws = draws
							}
							v2[cnId2].opponents[cnId] = {
								wins = v6,
								losses = v5,
								draws = draws
							}
						end

						local games = math.random(0, 200)
						v2[cnId].mirror = {
							games = games,
							draws = math.random(0, games)
						}
					end

					BallBattleStatsService.debugSeedClient(v2)
					print(("[CMD] 已为 %d 个小球注入图鉴测试数据（仅本地缓存），重新打开图鉴即可看到"):format(#list))
				end
			},
			["Add Test Players"] = {
				order = 80,
				params = {
					["Player Count"] = {
						type = "integer",
						min = 0,
						max = 200
					}
				},
				desc = "Add temporary entries to your player list. Enter 0 to clear them.",
				clientFn = function(_, p)
					local playerCount = p["Player Count"]

					if typeof(playerCount) ~= "number" or playerCount < 0 or playerCount % 1 ~= 0 or playerCount > 200 then
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Enter a whole number from 0 to 200."
						}
					end

					local scrollingFrame = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("右侧菜单"):WaitForChild("右侧区域"):WaitForChild("大厅玩家列表"):WaitForChild("ScrollingFrame")

					for _, child in ipairs(scrollingFrame:GetChildren()) do
						if child:GetAttribute("PlayerListScrollTest") then
							child:Destroy()
						end
					end

					local textButton = scrollingFrame:FindFirstChildWhichIsA("TextButton")

					if not textButton then
						return {
							ok = false,
							code = "COMMAND_REJECTED",
							message = "Player list is unavailable."
						}
					end

					for i = 1, playerCount do
						local clone = textButton:Clone()
						clone.Name = "__临时玩家_" .. i
						clone.Visible = true
						clone.Active = true
						clone.LayoutOrder = i + 10000
						clone:SetAttribute("PlayerListScrollTest", true)
						local label = clone:FindFirstChild("姓名")

						if label and label:IsA("TextLabel") then
							label.Text = "Test Player " .. i
						end

						local label2 = clone:FindFirstChild("等级")

						if label2 and label2:IsA("TextLabel") then
							label2.Text = tostring(i)
						end

						clone.Parent = scrollingFrame
					end
				end
			},
			["Refresh Stickers"] = {
				order = 340,
				desc = "Replace all six quick stickers with different ones, without spending diamonds.",
				serverFn = function(p, _)
					local StickerService = require(service:WaitForChild("StickerService"))
					StickerService.server.reroll(p)
				end
			}
		}
	}
}
local CMD = {}

for k, category in {
	"Rewards & Items",
	"Daily Rewards",
	"Shop & Draw",
	"XP & Levels",
	"Battle",
	"Testing"
} do
	local v3 = v[category]
	assert(v3, "分类排序存在未定义分类：" .. category)

	for k2, command in v3.commands do
		assert(CMD[k2] == nil, "指令名称重复：" .. k2)
		command.category = category
		command.categoryOrder = k
		command.categoryEmoji = v3.emoji
		CMD[k2] = command
	end
end

for k, v2 in CMD do
	if not (v2.serverFn and k ~= "Draw Now" and k ~= "Send Mail" and k ~= "Grant Code") then
		continue
	end

	if not (k ~= "Test Rainbow Fusion Announcement" and k ~= "Test Weekly Leaderboard Settlement" and k ~= "End Weekly Leaderboard Test") then
		continue
	end

	v2.beneficiary = true
end

return CMD