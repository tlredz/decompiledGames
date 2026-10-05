local NPCFishClient = {}
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
local playAction = Util.playAction
local JobsReplicated = require(game.ReplicatedStorage.JobsReplicated)
local Net = require(game.ReplicatedStorage.Modules.Net)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local runAsync = require(game.ReplicatedStorage.Util.runAsync)
local TimeUtil = require(game.ReplicatedStorage.Modules.Util.TimeUtil)
local Summer25FishingTournament = require(game.ReplicatedStorage.Modules.Data.Summer25FishingTournament)
local remoteFunction = Net:RemoteFunction("Craft")

-- equivalent calls inferred from this helper; original call sites unknown
local function ownsAnyRod(items)
	for _, item in items do
		if item.IsOwned then
			return item
		end
	end
end

local function fishingColorText(p)
	return (`<Color=Yellow>{p}<Color=/>`)
end

local function getServerRecipe(name, fn)
	local v = remoteFunction:InvokeServer("Check", name)
	local Global = require(game.ReplicatedStorage.Global)
	Global.TestGameWarn(v, name)

	if v then
		DialogueController.resumeWhenCallbackFinishes(function()
			local Global2 = require(game.ReplicatedStorage.Global)
			Global2.promptCraftAndWaitForGuiToClose(v.Required, v.Result, v.ResultStats)
		end)

		if fn then
			return (fn())
		end

		return {
			Text = { "..." }
		}
	elseif fn then
		return (fn())
	else
		return {
			Text = { "..." }
		}
	end
end

local function formatBarterDeal(_)
	return ""
end

local rodChangeDialogue

rodChangeDialogue = function(p, p2, value)
	local v = JobsReplicated.InvokeServer("FishingNPC", "Rod", "Check", p)
	local v2 = nil

	local function openRodOptions(data)
		local v3 = {
			Text = { "What would you like to do with this fishing rod?" }
		}

		if data.IsEquipped then
			v3.Option1 = {
				Label = "Unequip",
				JumpTo = function()
					if JobsReplicated.InvokeServer("FishingNPC", "Rod", "Unequip") then
						return {
							Text = { (`{data.Name} successfully unequipped.`) }
						}
					end

					return {
						Text = { "..." }
					}
				end
			}
		elseif data.IsOwned then
			v3.Option1 = {
				Label = "Equip",
				JumpTo = function()
					if JobsReplicated.InvokeServer("FishingNPC", "Rod", "Equip", data.Name) then
						return {
							Text = { (`{data.Name} successfully equipped.`) }
						}
					end

					return {
						Text = { "..." }
					}
				end
			}
		elseif data.Buyable and (p == "Fisherman" or p == "CorruptedFisherman") then
			v3.Option1 = {
				Label = "Purchase",
				JumpTo = function()
					if JobsReplicated.InvokeServer("FishingNPC", "Rod", "Purchase", data.Name, p) then
						return {
							Text = { (`{data.Name} successfully purchased.`) }
						}
					end

					return {
						Text = { "..." }
					}
				end
			}
		elseif data.Barter and (p == "Angler" or data.NPC == p) then
			v3.Option1 = {
				Label = "Barter",
				JumpTo = function()
					return (getServerRecipe(data.Name, function()
						return rodChangeDialogue(p, p2, value)
					end))
				end
			}
		else
			v3.Option1 = {
				Label = "LOCKED",
				Locked = true,
				JumpTo = function()
					playAction("Negative")
					return rodChangeDialogue(p, p2, value)
				end
			}
		end

		v3.ForceCancelButton = true
		v3.CancelText = "Back"

		function v3.CancelOverride()
			return v2
		end

		playAction("Explain")
		return v3
	end

	local v3 = 1
	local result = {
		Text = { value or "What rod are you looking for?" }
	}

	for _, v4 in v do
		if not v4.Display then
			continue
		end

		if v4.IsEquipped or v4.IsOwned or v4.Buyable or v4.Barter then
			if not v4.IsOwned and not v4.IsEquipped and v4.Barter and v4.Display and not value then
				result.Text = { (`What rod are you looking for today? I suggest picking up a {`<Color=Yellow>{v4.Name}<Color=/>`}!`) }
			end

			local v5 = v4
			result[`Option{v3}`] = {
				Label = v4.DisplayName or v4.Name,
				JumpTo = function()
					return (openRodOptions(v5))
				end
			}
		else
			result[`Option{v3}`] = {
				Label = v4.DisplayName or "LOCKED",
				Locked = true,
				JumpTo = function()
					playAction("Negative")
					return {
						Text = { "Don't have any of these right now." }
					}
				end
			}
		end

		v3 += 1
	end

	local Global = require(game.ReplicatedStorage.Global)
	Global.TestGameWarn("RodsData", v, result)
	v2 = result
	result.ForceCancelButton = true
	result.CancelText = "Back"

	function result.CancelOverride()
		return p2
	end

	playAction("Explain")
	return result
end

function baitCraftingDialogue(p, value, p2)
	local v = JobsReplicated.InvokeServer("FishingNPC", "Bait", "Check", p)
	local Global = require(game.ReplicatedStorage.Global)
	Global.TestGameWarn(v)
	local v2 = 1
	local result = {
		Text = { value or "What kind of bait are you looking for?" }
	}

	for _, v3 in v.All do
		if v3.Unlocked then
			local v4 = v3
			result["Option" .. v2] = {
				Label = v3.Name,
				JumpTo = function()
					return (getServerRecipe(v4.Name, function()
						return baitCraftingDialogue(p, value, p2)
					end))
				end
			}
		else
			result["Option" .. v2] = {
				Label = "LOCKED",
				Locked = true,
				JumpTo = function()
					playAction("Negative")
					return baitCraftingDialogue(p, "Sorry, can't sell that to you right now.", p2)
				end
			}
		end

		v2 += 1
	end

	result.ForceCancelButton = true
	result.CancelText = "Back"

	function result.CancelOverride()
		return p2
	end

	return result
end

local function getNumInteractableRods(items)
	local count = 0

	for _, item in items do
		if item.Display and (item.IsOwned or item.Buyable or item.Barter or item.IsEquipped) then
			count += 1
		end
	end

	return count
end

local function getNumInteractableBait(p)
	local count = 0

	for _, v in p.All do
		if v.Unlocked then
			count += 1
		end
	end

	return count
end

local function GetAnglerDialogue()
	local v = runAsync(JobsReplicated.InvokeServer, "FishingNPC", "Angler", "Speak")
	local v2 = runAsync(JobsReplicated.InvokeServer, "FishingNPC", "Rod", "Check", "Angler")
	local v3 = runAsync(JobsReplicated.InvokeServer, "FishingNPC", "Bait", "Check", "Angler"):awaitResult()
	local v4 = v2:awaitResult()
	local v5 = v:awaitResult()
	local trust = v5.Trust
	local levelData = v5.LevelData
	local v6 = nil

	for _, v8 in v5.RodsData do
		if not v8.IsOwned then
			continue
		end

		v6 = v8
		break
	end

	if not v6 then
		playAction("Negative")
		return {
			Text = {
				"Can't you see I'm trying to catch some fish here?",
				(`If you need something, go find my fishing pal. Most folks know him as the {"<Color=Yellow>Fisherman<Color=/>"}.`)
			}
		}
	end

	local Global = require(game.ReplicatedStorage.Global)
	Global.TestGamePrint("Angler trust, level data", trust, levelData)

	if levelData.level < 20 then
		playAction("Negative")
		return {
			Text = { (`I don't have time for rookies. Level up your {"<Color=Yellow>fishing skills<Color=/>"} and we can talk.`) }
		}
	end

	local v8 = v5.canAccept and "What's up? I have a new quest for you!" or "What can I do for ya?"

	if trust > 10 then
		playAction("Welcome")
	else
		playAction("Observe")
	end

	local v9 = nil
	local v10 = {
		Text = { v8 },
		Option1 = {
			Label = "Rods",
			Locked = getNumInteractableRods(v4) == 0,
			JumpTo = function()
				return (rodChangeDialogue("Angler", v9))
			end
		},
		Option2 = 0,
		Option3 = 0
	}
	local count = 0
	local option = {
		Label = "Bait",
		Locked = 0,
		JumpTo = 0
	}

	for _, v12 in v3.All do
		if v12.Unlocked then
			count += 1
		end
	end

	option.Locked = count == 0

	function option.JumpTo()
		return baitCraftingDialogue("Angler", nil, v9)
	end

	v10.Option2 = option
	v10.Option3 = {
		Label = "Quest",
		JumpTo = function()
			local v12 = JobsReplicated.InvokeServer("FishingNPC", "Angler", "CheckQuest")
			local Global2 = require(game.ReplicatedStorage.Global)
			Global2.TestGamePrint("questdata", v12)
			local turnInText = v12.TurnInText

			if turnInText then
				v9.Text = { turnInText }
				v5 = JobsReplicated.InvokeServer("FishingNPC", "Angler", "Speak")
				local Global3 = require(game.ReplicatedStorage.Global)
				Global3.TestGamePrint("anglerspeak", v5)
				return v9
			else
				if v5.canAccept then
					playAction("Explain")
					return {
						Text = { "Lookin' to do something for me?" .. (v5.ReplaceOldQuest and "\n<Color=Red>[This will replace your current quest]<Color=/>" or "") },
						Option1 = {
							Label = "Yes",
							JumpTo = function()
								local v13, v14 = JobsReplicated.InvokeServer("FishingNPC", "Angler", "AskQuest")

								if v13 then
									playAction("Positive")
									return {
										Text = { v14 or "Thanks, buddy!" }
									}
								end

								playAction("Negative")
								return {
									Text = { v14 or "Not now." }
								}
							end
						},
						Option2 = {
							Label = "No",
							JumpTo = function()
								playAction("Explain")
								return {
									Text = { "No worries." }
								}
							end
						},
						ForceCancelButton = true,
						CancelText = "Back",
						CancelOverride = function()
							return v9
						end
					}
				end

				if v5.IsInQuest then
					playAction("Negative")
					return {
						Text = { "Still waitin' on you to get that task done." }
					}
				end

				if v5.FailedAnglerQuest then
					playAction("Negative")
					return {
						Text = { [[
Failed your last quest, huh? 
Don't have any tasks for you right now, maybe come back in a little bit.]] }
					}
				end

				playAction("Negative")
				return {
					Text = { "I don't have any tasks for you right now, come back in a little bit." }
				}
			end
		end
	}
	v9 = v10
	return v9
end

local FishermanDialogue

FishermanDialogue = function(value: string?)
	-- equivalent call inferred; original call site unknown
	if not ownsAnyRod(JobsReplicated.InvokeServer("FishingNPC", "Rod", "Check", "Fisherman")) then
		return {
			Text = {
				"How's it going, what can I help you with?",
				(`<AnimateYield=0.5>.<AnimateYield=0.5>.<AnimateYield=0.5>.<AnimateYield=0.5> Ah, you look like you haven't gone fishing before! Here, I'll set you up with a {"<Color=Yellow>Fishing Rod<Color=/>"} and 10 {"<Color=Yellow>Bait<Color=/>"}.`)
			},
			Option1 = {
				Label = "Thanks!",
				JumpTo = function()
					if JobsReplicated.InvokeServer("FishingNPC", "FirstTimeFreeRod") then
						return FishermanDialogue((`Now that you've received your {"<Color=Yellow>Fishing Rod<Color=/>"} and {"<Color=Yellow>Bait<Color=/>"} you should equip them and start fishing!`))
					end
				end
			}
		}
	end

	local v2 = value or "How's the fishing?"
	local v3 = JobsReplicated.InvokeServer("FishingNPC", "Bait", "Check", "Fisherman")

	if not value then
		if v3.Total < 5 then
			v2 = `You're low on {"<Color=Yellow>Bait<Color=/>"}, you should craft some!`
		elseif v3.Equipped == "None" then
			v2 = `You don't have any {"<Color=Yellow>Bait<Color=/>"} equipped, you should equip some! Fish are much more likely to bite.`
		end
	end

	local v4 = nil
	v4 = {
		Text = { v2 },
		Option2 = {
			Label = "Fishing Index",
			JumpTo = function()
				local localPlayer = game.Players.LocalPlayer
				local playerGui = localPlayer.PlayerGui
				local character = localPlayer.Character

				if not character then
					return
				end

				local humanoid = character:FindFirstChild("Humanoid")

				if not humanoid then
					return
				end

				local DialogueController2 = require(game.ReplicatedStorage.DialogueController)
				DialogueController2.hideFrame()
				playerGui:SetAttribute("FishIndexVisible", true)

				while playerGui:GetAttribute("FishIndexVisible") and humanoid.Health >= 0 and character == localPlayer.Character do
					task.wait()
				end
			end
		},
		Option1 = {
			Label = "Shop",
			JumpTo = function()
				return {
					Text = { "What can I help you with?" },
					Option1 = {
						Label = "Buy Bait",
						JumpTo = function()
							return baitCraftingDialogue("Fisherman", nil, v4)
						end
					},
					Option2 = {
						Label = "Sell Fish",
						JumpTo = function()
							local fishingTournamentEnds = workspace:GetAttribute("FishingTournamentEnds")
							return {
								Text = { (not fishingTournamentEnds or TimeUtil.timeUntil(fishingTournamentEnds) == nil) and "I can take any excess fish off your hands. I won't buy any fish that you have favorited or your heaviest fish of each species. Deal?" or `I can take any excess fish off your hands. I won't buy any fish that you have favorited, your heaviest fish of each species, or your {Summer25FishingTournament.MIN_SUBMISSIONS} heaviest {Summer25FishingTournament.EVENT_FISH.Name}. Deal?` },
								Option1 = {
									Label = "Confirm",
									JumpTo = function()
										local v5 = JobsReplicated.InvokeServer("FishingNPC", "SellFish")

										if v5 then
											return {
												Text = { v5 }
											}
										end
									end
								}
							}
						end
					}
				}
			end
		},
		Option3 = {
			Label = "Job Stats",
			JumpTo = function()
				local JobMenuController = require(game.ReplicatedStorage.JobsReplicated.JobMenuController)
				task.spawn(function()
					local DialogueController2 = require(game.ReplicatedStorage.DialogueController)
					DialogueController2.hideFrame()
				end)
				JobMenuController.OpenJob("Fishing")

				while JobMenuController.context do
					task.wait()
				end

				JobsReplicated.InvokeServer("FishingNPC", "Fisherman", "JobMenu")
				return nil
			end
		}
	}
	return v4
end

local function SpeakCorruptedFisherman()
	local function GetCorruptedFishermanDialogue()
		local runAsync2 = require(game.ReplicatedStorage.Util.runAsync)
		local v = runAsync2(JobsReplicated.InvokeServer, "FishingNPC", "Rod", "Check", "CorruptedFisherman")
		local v2 = nil
		v2 = {
			Text = { "Hmm... If you have any <Color=Maroon>Corrupted<Color=/> fish, I will reward you greatly for them." },
			Option1 = {
				Label = "Bait",
				JumpTo = function()
					return baitCraftingDialogue("Fisherman", nil, v2)
				end
			},
			Option2 = {
				Label = "Rods",
				JumpTo = function()
					local v3 = nil

					for _, v4 in v:awaitResult() do
						if v4.Name ~= "Shark (Corrupted)" or v4.IsOwned then
							continue
						end

						if v4.Buyable or v4.Barter then
							v3 = "I think I have enough <Color=Maroon>corruption<Color=/> now. Ready to corrupt the <Color=Blue>Shark Rod<Color=/> when you are."
						elseif v4.numFishSold > 80 then
							v3 = "I almost have enough <Color=Maroon>corruption<Color=/>..."
						else
							v3 = "If you give me enough <Color=Maroon>Corrupted<Color=/> fish, I might be able to corrupt a <Color=Blue>Shark Rod<Color=/> for you if you have one..."
						end
					end

					return (rodChangeDialogue("CorruptedFisherman", v2, v3))
				end
			},
			Option3 = {
				Label = "Exchange Fish",
				JumpTo = function()
					return {
						Text = { "I want all of them. No refunds." },
						Option1 = {
							Label = "Confirm",
							JumpTo = function()
								if JobsReplicated.InvokeServer("FishingNPC", "SellCorruptedFish") then
									return {
										Text = { "<Color=Maroon>Thank you<Color=/>..." }
									}
								end

								return {
									Text = { "None of those fish had what I was looking for." }
								}
							end
						}
					}
				end
			}
		}

		-- equivalent call inferred; original call site unknown
		if ownsAnyRod(v:awaitResult()) then
			return v2
		end

		return {
			Text = { (`<AnimateYield=0.1>.<AnimateYield=0.1>.<AnimateYield=0.1>.<AnimateYield=0.1> You don't have a fishing rod..? Here, take a {"<Color=Yellow>Fishing Rod<Color=/>"} and 10 {"<Color=Yellow>Bait<Color=/>"}.`) },
			Option1 = {
				Label = "Thanks!",
				JumpTo = function()
					if JobsReplicated.InvokeServer("FishingNPC", "FirstTimeFreeRod") then
						return v2
					end
				end
			}
		}
	end

	return (GetCorruptedFishermanDialogue())
end

local function SpeakCelestialFisherman()
	local function GetCelestialFishermanDialogue()
		local runAsync2 = require(game.ReplicatedStorage.Util.runAsync)
		local v = runAsync2(JobsReplicated.InvokeServer, "FishingNPC", "Rod", "Check", "Celestial Fisherman")
		local v2 = nil
		v2 = {
			Text = { "Got any <Color=BrightPurple>Celestial<Color=/> fish? I can give you <Color=BrightPurple>Celestial Tokens<Color=/> in exchange for them!" },
			Option1 = {
				Label = "Bait",
				JumpTo = function()
					return baitCraftingDialogue("Fisherman", nil, v2)
				end
			},
			Option2 = {
				Label = "Rods",
				JumpTo = function()
					local v3 = nil

					for _, v4 in v:awaitResult() do
						if v4.Name ~= "Shell (Celestial)" or v4.IsOwned then
							continue
						end

						v3 = "If you give me enough <Color=BrightPurple>Celestial<Color=/> fish, I might be able to imbue a <Color=Blue>Shell Rod<Color=/> with <Color=BrightPurple>Celestial<Color=/> properties if you have one..."
					end

					return (rodChangeDialogue("Celestial Fisherman", v2, v3))
				end
			},
			Option3 = {
				Label = "Exchange Fish",
				JumpTo = function()
					return {
						Text = { "I'll take all of your fish with a celestial aura." },
						Option1 = {
							Label = "Confirm",
							JumpTo = function()
								if JobsReplicated.InvokeServer("FishingNPC", "SellCelestialFish") then
									return {
										Text = { "<Color=BrightPurple>Thank you<Color=/>." }
									}
								end

								return {
									Text = { "None of these fish have a celestial aura." }
								}
							end
						}
					}
				end
			}
		}

		-- equivalent call inferred; original call site unknown
		if ownsAnyRod(v:awaitResult()) then
			return v2
		end

		return {
			Text = { (`You don't have a fishing rod..? Here, take a {"<Color=Yellow>Fishing Rod<Color=/>"} and 10 {"<Color=Yellow>Bait<Color=/>"}.`) },
			Option1 = {
				Label = "Thanks!",
				JumpTo = function()
					if JobsReplicated.InvokeServer("FishingNPC", "FirstTimeFreeRod") then
						return v2
					end
				end
			}
		}
	end

	return (GetCelestialFishermanDialogue())
end

function NPCFishClient.FishermanDialogue()
	return (FishermanDialogue())
end

function NPCFishClient.InitializeNPC(p)
	task.spawn(function()
		local function giveRod(parent, instance)
			local thread = coroutine.running()
			local clone = nil
			local ancestryChangedConnection = nil
			ancestryChangedConnection = parent.AncestryChanged:Connect(function(_, parent2)
				if not parent2 or parent2 ~= workspace.NPCs then
					if ancestryChangedConnection then
						ancestryChangedConnection:Disconnect()
						ancestryChangedConnection = nil
					end

					if clone then
						clone:Destroy()
						clone = nil
					end

					if coroutine.status(thread) ~= "dead" then
						task.cancel(thread)
					end
				end
			end)

			while not parent:GetAttribute("NPCReady") do
				task.wait()
			end

			if not parent:FindFirstChild(instance.Name) then
				clone = instance:Clone()
				clone.Parent = parent
				clone.RootPart.Part0 = parent.LeftHand
			end
		end

		local function onNpcAdded(child)
			if child.Name == "Fisherman" or child.Name == "Angler" then
				giveRod(child, script.NPCRod)
			elseif child.Name == "Oni Fisherman" then
				giveRod(child, script["Shark (Corrupted)"])
			elseif child.Name == "Celestial Fisherman" then
				giveRod(child, script["Shell (Celestial)"])
			end
		end

		workspace.NPCs.ChildAdded:Connect(onNpcAdded)

		for _, child in workspace.NPCs:GetChildren() do
			onNpcAdded(child)
		end
	end)
	p.new("Angler", function(_)
		return {
			Title = "Angler",
			Get = function(_)
				return (GetAnglerDialogue())
			end
		}
	end, 4, 5)
	p.new("Fisherman", function(_)
		return {
			Title = "Fisherman",
			Get = function(_)
				return (FishermanDialogue())
			end
		}
	end, 4, 5)
	task.spawn(function()
		p.new("Oni Fisherman", function(_)
			return {
				Title = "Oni Fisherman",
				Get = function(_)
					local function GetCorruptedFishermanDialogue()
						local runAsync2 = require(game.ReplicatedStorage.Util.runAsync)
						local v = runAsync2(
							JobsReplicated.InvokeServer,
							"FishingNPC",
							"Rod",
							"Check",
							"CorruptedFisherman"
						)
						local v2 = nil
						v2 = {
							Text = { "Hmm... If you have any <Color=Maroon>Corrupted<Color=/> fish, I will reward you greatly for them." },
							Option1 = {
								Label = "Bait",
								JumpTo = function()
									return baitCraftingDialogue("Fisherman", nil, v2)
								end
							},
							Option2 = {
								Label = "Rods",
								JumpTo = function()
									local v3 = nil

									for _, v4 in v:awaitResult() do
										if v4.Name ~= "Shark (Corrupted)" or v4.IsOwned then
											continue
										end

										if v4.Buyable or v4.Barter then
											v3 = "I think I have enough <Color=Maroon>corruption<Color=/> now. Ready to corrupt the <Color=Blue>Shark Rod<Color=/> when you are."
										elseif v4.numFishSold > 80 then
											v3 = "I almost have enough <Color=Maroon>corruption<Color=/>..."
										else
											v3 = "If you give me enough <Color=Maroon>Corrupted<Color=/> fish, I might be able to corrupt a <Color=Blue>Shark Rod<Color=/> for you if you have one..."
										end
									end

									return (rodChangeDialogue("CorruptedFisherman", v2, v3))
								end
							},
							Option3 = {
								Label = "Exchange Fish",
								JumpTo = function()
									return {
										Text = { "I want all of them. No refunds." },
										Option1 = {
											Label = "Confirm",
											JumpTo = function()
												if JobsReplicated.InvokeServer("FishingNPC", "SellCorruptedFish") then
													return {
														Text = { "<Color=Maroon>Thank you<Color=/>..." }
													}
												end

												return {
													Text = { "None of those fish had what I was looking for." }
												}
											end
										}
									}
								end
							}
						}

						-- equivalent call inferred; original call site unknown
						if ownsAnyRod(v:awaitResult()) then
							return v2
						end

						return {
							Text = { (`<AnimateYield=0.1>.<AnimateYield=0.1>.<AnimateYield=0.1>.<AnimateYield=0.1> You don't have a fishing rod..? Here, take a {"<Color=Yellow>Fishing Rod<Color=/>"} and 10 {"<Color=Yellow>Bait<Color=/>"}.`) },
							Option1 = {
								Label = "Thanks!",
								JumpTo = function()
									if JobsReplicated.InvokeServer("FishingNPC", "FirstTimeFreeRod") then
										return v2
									end
								end
							}
						}
					end

					return (GetCorruptedFishermanDialogue())
				end
			}
		end, 4, 5)
	end)
	task.spawn(function()
		p.new("Celestial Fisherman", function(_)
			return {
				Title = "Celestial Fisherman",
				Get = function(_)
					local function GetCelestialFishermanDialogue()
						local runAsync2 = require(game.ReplicatedStorage.Util.runAsync)
						local v = runAsync2(
							JobsReplicated.InvokeServer,
							"FishingNPC",
							"Rod",
							"Check",
							"Celestial Fisherman"
						)
						local v2 = nil
						v2 = {
							Text = { "Got any <Color=BrightPurple>Celestial<Color=/> fish? I can give you <Color=BrightPurple>Celestial Tokens<Color=/> in exchange for them!" },
							Option1 = {
								Label = "Bait",
								JumpTo = function()
									return baitCraftingDialogue("Fisherman", nil, v2)
								end
							},
							Option2 = {
								Label = "Rods",
								JumpTo = function()
									local v3 = nil

									for _, v4 in v:awaitResult() do
										if v4.Name ~= "Shell (Celestial)" or v4.IsOwned then
											continue
										end

										v3 = "If you give me enough <Color=BrightPurple>Celestial<Color=/> fish, I might be able to imbue a <Color=Blue>Shell Rod<Color=/> with <Color=BrightPurple>Celestial<Color=/> properties if you have one..."
									end

									return (rodChangeDialogue("Celestial Fisherman", v2, v3))
								end
							},
							Option3 = {
								Label = "Exchange Fish",
								JumpTo = function()
									return {
										Text = { "I'll take all of your fish with a celestial aura." },
										Option1 = {
											Label = "Confirm",
											JumpTo = function()
												if JobsReplicated.InvokeServer("FishingNPC", "SellCelestialFish") then
													return {
														Text = { "<Color=BrightPurple>Thank you<Color=/>." }
													}
												end

												return {
													Text = { "None of these fish have a celestial aura." }
												}
											end
										}
									}
								end
							}
						}

						-- equivalent call inferred; original call site unknown
						if ownsAnyRod(v:awaitResult()) then
							return v2
						end

						return {
							Text = { (`You don't have a fishing rod..? Here, take a {"<Color=Yellow>Fishing Rod<Color=/>"} and 10 {"<Color=Yellow>Bait<Color=/>"}.`) },
							Option1 = {
								Label = "Thanks!",
								JumpTo = function()
									if JobsReplicated.InvokeServer("FishingNPC", "FirstTimeFreeRod") then
										return v2
									end
								end
							}
						}
					end

					return (GetCelestialFishermanDialogue())
				end
			}
		end, 4, 5)
	end)
end

return NPCFishClient