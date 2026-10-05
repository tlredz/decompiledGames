local createVector = vector.create
local RunService = game:GetService("RunService")
local GachaClient = require(game.ReplicatedStorage.Controllers.GachaClient)
local Util = require(script.Parent.Util)
local SubclassMenu = require(game.ReplicatedStorage.Controllers.UI.SubclassMenu)
local SubclassController = require(game.ReplicatedStorage.Controllers.SubclassController)
local Net = require(game.ReplicatedStorage.Modules.Net)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local BoatInfo = require(game.ReplicatedStorage.Modules.BoatInfo)
require(script.Parent.Types)
local remoteFunction = Net:RemoteFunction("InteractSubclassQuest")
local remoteFunction2 = Net:RemoteFunction("StartSubclassQuest")
local localPlayer = game.Players.LocalPlayer
local commF_ = game.ReplicatedStorage.Remotes.CommF_
local Library = {}

function Library.luckymax()
	local v = commF_:InvokeServer("Cousin", "CheckAprilFools26Luckymaxer")
	local gachaAsync = GachaClient.GetGachaAsync("AprilFoolsGacha26")

	if v == true then
		return {
			Text = { "AIN'T NO WAY YOU ACTUALLY <Color=Yellow>BEAT ME<Color=/>." },
			Option1 = {
				Label = "Hack the gacha",
				JumpTo = function()
					local function aprilFoolsGacha()
						if not gachaAsync.ENABLED then
							return {
								Text = { "..." }
							}
						end

						local v2 = commF_:InvokeServer("Cousin", "CheckAprilFools26Luckymaxer")

						if v2 == true then
							return {
								Text = { "Argh... fine. I'll hack the gacha system for you." },
								Option1 = {
									Label = "YAY",
									JumpTo = function()
										return Library.doLuckymaxRoll()
									end
								}
							}
						end

						return {
							Text = { v2 }
						}
					end

					return (aprilFoolsGacha())
				end
			}
		}
	end

	local function getPatchedDialogue()
		return {
			Text = { "Looks like they patched it..." }
		}
	end

	if commF_:InvokeServer("Cousin", "CheckAprilFools26LuckymaxerBegState") == true then
		return {
			Text = { "Looks like they patched it..." },
			Option1 = {
				Label = "More rolls",
				JumpTo = function()
					return Library.aprilFoolsBeg()
				end
			}
		}
	end

	return {
		Text = { "Looks like they patched it..." }
	}
end

function Library.luckymaxRoll()
	local v = commF_:InvokeServer("Cousin", GachaClient.GetGachaAsync("AprilFoolsGacha26").BOX_NAME)

	if v == 1 then
		return Library.luckymax()
	end

	return {
		Text = { typeof(v) == "string" and v or "..." }
	}
end

function Library.scroll(_, p: string)
	local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "Progress", p)
	local v2 = v[p]

	if v.Good >= 4 and v.Evil >= 4 then
		local proximityPrompt = workspace.Map:WaitForChild("Turtle"):WaitForChild("Cursed"):WaitForChild("Pedestal3"):WaitForChild("ProximityPrompt")
		proximityPrompt.Enabled = true
	end

	if v.Good >= 3 and p == "Good" then
		workspace.Map:WaitForChild("Turtle"):WaitForChild("Cursed"):WaitForChild("Pedestal1"):WaitForChild("ProximityPrompt"):SetAttribute(
			"Enabled",
			false
		)
		local proximityPrompt_2 = workspace.Map:WaitForChild("Turtle"):WaitForChild("Cursed"):WaitForChild("Pedestal1"):WaitForChild("ProximityPrompt")
		proximityPrompt_2.Enabled = false
	end

	if v.Evil >= 3 and p == "Evil" then
		workspace.Map:WaitForChild("Turtle"):WaitForChild("Cursed"):WaitForChild("Pedestal2"):WaitForChild("ProximityPrompt"):SetAttribute(
			"Enabled",
			false
		)
		local proximityPrompt_3 = workspace.Map:WaitForChild("Turtle"):WaitForChild("Cursed"):WaitForChild("Pedestal2"):WaitForChild("ProximityPrompt")
		proximityPrompt_3.Enabled = false
	end

	if v2 == -1 then
		return {
			Text = { "The inscription is too hard to read..." }
		}
	elseif v2 == -2 then
		return {
			Text = { "The scroll appears to be blank." }
		}
	end

	if v2 < -2 then
		local v3 = (v2 + 2) * -1

		if p == "Evil" then
			return {
				Text = { ({ "Pain and Suffering.", "Haze of Misery.", "Fear the Reaper." })[v3] }
			}
		end

		return {
			Text = { ({ "Dock Legend.", "Sense of Duty.", "Soulless." })[v3] }
		}
	elseif v2 < 3 then
		return {
			Text = p == "Evil" and { [[
Pain and Suffering.
Haze of Misery.
Fear the Reaper.]] } or { [[
Dock Legend.
Sense of Duty.
Soulless.]] },
			Option1 = {
				Label = (v2 == 0 and "First" or v2 == 1 and "Second" or "Third") .. " Trial",
				Text = {},
				JumpTo = function(_)
					if not game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", p) then
						return {
							Text = { "..." }
						}
					end

					if p == "Evil" then
						return {
							Text = { ({ "Pain and Suffering.", "Haze of Misery.", "Fear the Reaper." })[v2 + 1] }
						}
					end

					return {
						Text = { ({ "Dock Legend.", "Sense of Duty.", "Soulless." })[v2 + 1] }
					}
				end
			}
		}
	else
		return {
			Text = { "The scroll bursts into flames and disappears." }
		}
	end
end

function Library.aprilFoolsBeg(value: number?)
	if not GachaClient.GetGachaAsync("AprilFoolsGacha26").ENABLED then
		return {
			Text = { "..." }
		}
	end

	local v = value or 1
	assert(v, "bad persist")
	local v2 = commF_:InvokeServer("Cousin", "AprilFools26LuckymaxerBeg")

	if typeof(v2) ~= "table" then
		return {
			Text = { "..." }
		}
	end

	local v3 = {
		Text = { v2.Text or "NO!" }
	}

	if v2.Granted then
		v3.Option1 = {
			Label = "YESSS",
			JumpTo = function()
				return Library.luckymaxRoll()
			end
		}
	elseif not v2.Done then
		v3.RandomizeCancelSwap = true
		v3.CancelText = "Ok"
		local v4 = {
			"Please",
			"But I want em",
			"MORE",
			"I promise not to ask again",
			"Pretty please",
			"PLEASEEEE",
			"Just one moreeeeee"
		}
		v3.Option1 = {
			Label = v4[v % #v4 + 1],
			JumpTo = function()
				return Library.aprilFoolsBeg(v + 1)
			end
		}
	end

	return v3
end

function Library.candiesTrader(p)
	local v, v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Candies", "Check")

	if not v then
		return {
			Text = { "..." }
		}
	end

	local v3

	if v == 1 then
		v3 = 1 .. " Candy"
	else
		v3 = v .. " Candies"
	end

	local result = {
		Text = { "You currently have <Color=Red>" .. v3 .. "<Color=/>." }
	}
	local v4 = v2[p]

	for k, v5 in pairs(v4) do
		local v6 = v5
		local v7 = k
		result["Option" .. k] = {
			Label = v5[1],
			JumpTo = function()
				return {
					Text = { "Would you like to buy <" .. v6[1] .. "> for <Color=Red>" .. v6[2] .. " Candies<Color=/>?" },
					Option1 = {
						Label = "Buy",
						JumpTo = function()
							local v8 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Candies", "Buy", p, v7)

							if v8 == 1 then
								Util.playAction("Positive")
								return {
									Text = { "[Trade completed.]" }
								}
							elseif v8 == 2 then
								Util.playAction("Negative")
								return {
									Text = { "[You don't have enough candies.]" }
								}
							elseif v8 == 3 then
								Util.playAction("Negative")
								return {
									Text = { "[You already have this item.]" }
								}
							end

							if v8 then
								return {
									Text = { v8 }
								}
							end

							return {
								Text = { "[Error.]" }
							}
						end
					},
					Option2 = {
						Label = "Return",
						JumpTo = function()
							return result
						end
					}
				}
			end
		}
	end

	return result
end

function Library.ectoplasmTrader(p)
	local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Ectoplasm", "BuyCheck", p)
	local v2 = ({
		{ "Bizarre Revolver", 25 },
		{ "Ghoul Mask", 50 },
		{ "Midnight Blade", 100 },
		{ "Ghoul Race", 100 }
	})[p]

	if v == 3 then
		return {
			Text = { "It's so cold..." }
		}
	elseif v == 2 then
		return {
			Text = { "Howdy, fellow Ghoul." }
		}
	elseif v == 1 then
		return {
			Text = { "Would you like to change your race to Ghoul again?" },
			Option1 = {
				Label = "Yes",
				Text = { "" },
				JumpTo = function()
					if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Ectoplasm", "Change", 4) == 1 then
						Util.playAction("Positive")
						return {
							Text = { "[Race changed to <Ghoul>.]" }
						}
					end

					Util.playAction("Negative")
					return {
						Text = { "You already seem to be a Ghoul..." }
					}
				end
			}
		}
	elseif v == 0 then
		return {
			Text = { "Hello again." }
		}
	end

	if v then
		return {
			Text = { "Would you like to trade <Color=Orange>" .. v2[2] .. " Ectoplasm<Color=/> for <" .. v2[1] .. ">?" },
			Option1 = {
				Label = "Trade",
				Text = { "" },
				JumpTo = function()
					local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Ectoplasm", "Buy", p)

					if v3 == 1 then
						Util.playAction("Positive")
						return {
							Text = { "[Trade completed.]" }
						}
					end

					if v3 ~= 2 then
						return {
							Text = { "..." }
						}
					end

					Util.playAction("Negative")
					return {
						Text = { "[You already own this item.]" }
					}
				end
			}
		}
	end

	return {
		Text = { "Sorry, you need <Color=Orange>" .. v2[2] .. " Ectoplasm<Color=/> to make a deal with me." }
	}
end

function Library.loveLetter(p)
	local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("LoveLetter", p)

	if v == 0 then
		return {
			Text = { "\"YO BRO when i say mygame43 master of me it for get unban not for him be my real master. only you my master. you my master. forever bro.\"" },
			Option1 = {
				Label = "LOL",
				JumpTo = function()
					return {
						Text = { "[Love Letter #1 acquired.]" }
					}
				end
			}
		}
	elseif v == 1 then
		return {
			Text = { "\"omg frien me in discor again plz bro ill respect u from now on omg u have all my respect for defeating my enemies in nsuns :c\"" },
			Option1 = {
				Label = "LOL",
				JumpTo = function()
					return {
						Text = { "[Love Letter #2 acquired.]" }
					}
				end
			}
		}
	elseif v == 2 then
		return {
			Text = { "\"omg u know well i hate wenlock dont interfere the son vs the son! yes masta i have a respect but dont try to surpass my limite\"" },
			Option1 = {
				Label = "LOL",
				JumpTo = function()
					return {
						Text = { "[Love Letter #3 acquired.]" }
					}
				end
			}
		}
	end

	return {
		Text = { "..." }
	}
end

function Library.buyAbility(p, p2: string)
	local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", p)

	if v == 1 then
		Util.playAction("Positive")
		return {
			Text = { "[" .. p2 .. " learned.]" }
		}
	elseif v == 0 then
		Util.playAction("Negative")
		return {
			Text = { "[Not enough Money.]" }
		}
	end

	if v == 2 then
		Util.playAction("Negative")
		return {
			Text = { "[You already know this ability.]" }
		}
	else
		error((`unexpected r value: {v}`))
	end
end

Library.itemPurchase = require(script.Parent.ItemPurchase)

function Library.boatPurchase(p: string)
	local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBoat", p)

	if v == 1 then
		Util.playAction("Positive")
		return {
			Text = { "[Boat purchased.]" }
		}, true
	elseif v == 0 then
		Util.playAction("Negative")
		return {
			Text = { "[Not enough Money.]" }
		}, false
	elseif v == 2 then
		Util.playAction("Explain")
		return {
			Text = { "[Purchase failed because the boat spawn is being obstructed by another boat.]" }
		}, false
	elseif v == 3 then
		Util.playAction("Negative")
		return {
			Text = { "[You don't own this Game Pass.]" }
		}, false
	end

	if v == 4 then
		Util.playAction("Negative")
		return {
			Text = { "[Boat locked. You cannot purchase this boat yet.]" }
		}, false
	else
		error((`unsupported r: {v}`))
	end
end

function Library.talkBoatDealer(callback, p: string)
	local v = DialogueController.new()
	v:setTitle(p)
	v:setSubtitle("Merchant")
	return v:addPage("Main", function(object)
		local v2

		if typeof(callback) == "function" then
			v2 = callback()
		else
			v2 = callback
		end

		local NPC = v:getNPC()
		local GuideData = require(game.ReplicatedStorage.GuideModule.GuideData)
		local _ = game.Players.LocalPlayer.Character

		if GuideData.Data.CanUnlockCompass and not GuideData.Data.CompassUnlocked and NPC then
			object:addText("Finally starting your journey? Take this compass, it'll help you find your way.")
			object:addOptionType("Accept", function(object2)
				object2:setText("Accept")
				object2:onSelected(function()
					task.spawn(function()
						if not Net:RemoteFunction("GuideDataUpdate"):InvokeServer("UnlockCompass") then
							return
						end

						AttributeCounter.add(localPlayer, "NPC_INTERACTION_LOCK")
						local CompassTracker = require(game.ReplicatedStorage.GuideModule.CompassTracker)
						local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
						local v3 = CameraController.new()
						local leftHand = NPC:getModel():FindFirstChild("LeftHand")
						local SideCompass = require(game.ReplicatedStorage.GuideModule.SideCompass)
						local v4, v5 = SideCompass.spawnAtCFrameAndTweenToScreen(leftHand.CFrame * CFrame.new(
							0,
							-0.2,
							0
						) * CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966))
						v4.Size = createVector(0.05, 0.75, 0.75)
						local animator = NPC:getAnimator()
						local animation = Instance.new("Animation")
						animation.Name = "Compass"
						animation.AnimationId = "rbxassetid://110180049276123"
						local track = animator:LoadAnimation(animation)
						local thread = task.spawn(function()
							while RunService.Stepped:Wait() do
								v4.CFrame = leftHand.CFrame * CFrame.new(0, -0.2, 0) * CFrame.Angles(
									0,
									1.5707963267948966,
									1.5707963267948966
								)
							end
						end)
						v3.Animations:AnimateTo(CFrame.lookAt(
							(NPC:getModel():GetPivot() * CFrame.new(-7, 6, -4)).Position,
							leftHand.Position
						))
						track:Play(0.4, 0.8)
						task.wait(1)
						track:AdjustSpeed(0.0001)
						task.wait(0.5)
						task.spawn(task.cancel, thread)
						v5()
						task.wait(0.2)
						v5()
						task.wait(0.5)
						track:Stop()
						task.wait(1.5)
						v5()

						while not CompassTracker.isTrackingDefault() do
							task.wait()
						end

						v5()
						local tracker = CompassTracker.getTracker()
						v3.Animations:AnimateTo(CFrame.lookAt(
							(NPC:getModel():GetPivot() * CFrame.new(-7, 6, -4)).Position + createVector(0, 20, 0),
							tracker.TrackedPosition
						))
						task.wait(1)
						v3:Destroy()
						AttributeCounter.remove(localPlayer, "NPC_INTERACTION_LOCK")
						DialogueController.unhideWindow()
						local data = localPlayer:FindFirstChild("Data")

						if data then
							local level = data:FindFirstChild("Level")

							if level and level.Value < 10 then
								DialogueController.start(DialogueController.new():addPage("Main", function(object3)
									object3:addText("One of my buddies has a quest for you. Use the compass to find him!")
									object3:advanceAfterDelay(2)
								end):setTitle(v._title):setSubtitle(v._subtitle):build(), NPC)
							end
						end
					end)
				end)
			end)
		else
			local v3 = BoatInfo.getForDealer(v2)
			local v4, _, v5 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("GetUnlockables", "BoatDealer")
			local v6

			if v5 then
				table.sort(v3, function(a, b)
					local v7 = BoatInfo.List[a]
					local v8 = BoatInfo.List[b]

					if v7.Cost == v8.Cost then
						return v7.DisplayName < v8.DisplayName
					end

					return v7.Cost < v8.Cost
				end)
				v6 = true
			else
				v6 = false
			end

			Net:RemoteEvent("RobloxAnalytics"):FireServer({
				Context = "SpokeToNPC",
				InternalName = "BoatDealer"
			})
			object:addText("Select a " .. (v2 == "Premium" and "[Game Pass] " or "") .. "boat to purchase it.")
			local children = workspace._WorldOrigin.BoatSpawns:GetChildren()
			local v7 = 1e999
			local cFrame = nil

			for _, v8 in children do
				local magnitude = (localPlayer.Character.HumanoidRootPart.Position - v8.Position).Magnitude

				if not (magnitude < v7) then
					continue
				end

				cFrame = v8.CFrame
				v7 = magnitude
			end

			if not v6 then
				object:toggleSpecialReactComponent("FastBoatsGamepassPopup")
				object:getMaid():GiveTask(game.ReplicatedStorage.Remotes.CommE.OnClientEvent:Connect(function(p2)
					if p2 == "FastBoatsGamepassPurchased" then
						object:refresh()
					end
				end))
			end

			for _, v8 in v3 do
				local v9 = BoatInfo.List[v8]
				local displayName = v9.DisplayName
				local unlockable = v9.Unlockable
				local requiresFastBoat = v9.RequiresFastBoat
				local v10 = v9.Cost == 0 and "FREE" or "$" .. TextUtil.commaValue(v9.Cost)

				if requiresFastBoat and not v6 then
					object:addPurchaseOption("PREMIUM", displayName, function(object2)
						object2:setLocked(true)
					end, "#FFD700")
				elseif unlockable and not v4[unlockable] then
					object:addPurchaseOption("LOCKED", displayName, function(object2)
						object2:setLocked(true)
					end, "White")
				else
					local v11 = v8
					local v12 = displayName
					local v13 = v10
					object:addPurchaseOption(v10, displayName, function(object2)
						object2:jumpToPage(function(object3)
							local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
							local v14 = CameraController.new()
							local v15 = CFrame.lookAt(
								((workspace.CurrentCamera.CFrame + createVector(0, 3, 0)) * CFrame.new(0, 0, 3)).Position,
								cFrame.Position
							) * CFrame.new(0, 0, 5)
							v14.Animations:AnimateTo(v15)
							local maid = object3:getMaid()

							function maid.BoatPurchaseCameraController()
								v14:FadeOut(0.5)
							end

							if not localPlayer.Character then
								return
							end

							local child = game.ReplicatedStorage.BoatDisplayCache:FindFirstChild(v11)

							if child then
								local GetBoatSpawnData = require(game.ReplicatedStorage.Util.GetBoatSpawnData)
								local boatSpawnData = GetBoatSpawnData(
									localPlayer.Character:GetPivot().Position,
									child,
									nil
								)
								local v17

								if boatSpawnData.Closest then
									v17 = boatSpawnData.Closest.CFrame
								else
									v17 = cFrame
								end

								cFrame = v17
								local rotation = cFrame.Rotation
								local X = cFrame.X
								local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
								local v18 = rotation + Vector3.new(
									X,
									GetWaterHeightAtLocation(cFrame.Position),
									cFrame.Z
								)
								child:PivotTo(v18)
								child.Parent = workspace
								local maid_2 = object3:getMaid()

								function maid_2.returnDisplayBoat()
									child.Parent = game.ReplicatedStorage.BoatDisplayCache
								end

								local maid_3 = object3:getMaid()
								maid_3.delayedReturnCamera = nil
								v14.Animations:AnimateTo(
									(CFrame.lookAt(v15.Position + createVector(0, 5, 0), v18.Position) + createVector(
										0,
										0,
										0
									)) * CFrame.new(0, child:GetModelSize().Y * 0.25, child:GetModelSize().Y * 0.8),
									0.9,
									0.5
								)
							end

							object3:setTitle("Confirm Purchase")
							object3:setSubtitle((`{v12}`))
							object3:addText((`Are you sure you want to purchase this boat for <color="Green">{v13}</color>?`))
							object3:addOptionType("Purchase", function(object4)
								object4:setText("Confirm")
								object4:jumpToPage(function(object5)
									local boatPurchase, v16 = Library.boatPurchase(v11)

									if v16 then
										object5:close()
										return
									end

									object5:addText(boatPurchase.Text[1])
									object5:addOptionType("Chat", function(object6)
										object6:setText("Return")
										object6:jumpTo("Main")
									end)
								end)
							end)
							object3:addOptionType("Chat", function(object4)
								object4:setText("Return")
								object4:jumpTo("Main")
							end)
						end)
					end)
				end
			end

			if game.Players.LocalPlayer:FindFirstChild("BoatQuest") then
				local v8 = { 1e999 }

				for _, child in pairs(workspace.NPCs:GetChildren()) do
					if not child.Name:match("Boat Dealer$") then
						continue
					end

					local character = localPlayer.Character
					assert(character, "bad character")
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
					local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

					if magnitude < v8[1] then
						v8 = { magnitude, child }
					end
				end

				if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "BoatQuest", v8[2], "Check") then
					object:addOptionType("Chat", function(object2)
						object2:setText("Pardon me")
						object2:jumpToPage(function(object3)
							game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "BoatQuest", v8[2])
							object3:addText("Hey traveler, I recognize you. It's pleasant to see a familiar face around here.")
						end)
					end)
				end
			end
		end
	end):build()
end

function Library.openFruitShop(p: string)
	if p ~= "ShopGui" then
		local Shop = require(game.ReplicatedStorage.Controllers.UI.Shop)
		Shop:Close()
	end

	local FruitShop = require(game.ReplicatedStorage.Controllers.UI.FruitShop)
	FruitShop:Open(p)
	return {
		Text = { "..." }
	}
end

function Library.subclassNPC(p)
	local rawData = SubclassController:GetRawData()
	local v = SubclassController:GetSubclassData().Purchased[p] ~= nil
	local v2 = rawData[p]
	local fragments = v2.Passives.Base.Levels[1].Cost.Fragments
	local v3, v4 = remoteFunction:InvokeServer(p)

	if v3 == 0 then
		return {
			Text = { "How did you make it in here...?" }
		}
	elseif v3 == 1 then
		Util.playAction("Explain")
		return {
			Text = { string.format(
					"You want to become a %s? You'll need to %s. If you accept my quest, the progress of your other active Subclass quests will reset.",
					p,
					({
						Shipwright = "kill 20 Sharks",
						Helmsman = "find 15 Treasure Islands"
					})[p]
				) },
			Option1 = {
				Label = "Accept",
				JumpTo = function()
					task.spawn(function()
						remoteFunction2:InvokeServer(p)
					end)
					return {
						Text = { "Cool. You can check back in with me to see your progress." }
					}
				end
			}
		}
	end

	if v3 == 2 then
		local v6 = v2.Description .. string.format(
			" Would you like to purchase the %s subclass for <Color=Purple>ƒ%s<Color=/>?",
			p,
			TextUtil.commaValue(fragments)
		)

		if v then
			v6 = ("Would you like to equip the %s subclass?"):format(p)
		end

		Util.playAction("Explain")
		return {
			Text = { v6 },
			Option1 = {
				Label = v and "Equip" or "Buy",
				JumpTo = function()
					local function openSubclassWindow(p2)
						if not game.ReplicatedStorage.Remotes:FindFirstChild("SubclassNetwork"):FindFirstChild("EquipSubclass"):InvokeServer(p2) then
							return {
								Text = { "Error" }
							}
						end

						SubclassMenu:Open(p2)
						SubclassMenu.screen:GetPropertyChangedSignal("Enabled"):Wait()
						return {
							Text = { "..." }
						}
					end

					if v then
						return (openSubclassWindow(p))
					end

					local v6 = fragments - localPlayer:FindFirstChild("Data"):FindFirstChild("Fragments").Value

					if v6 < 1 then
						if game.ReplicatedStorage.Remotes:FindFirstChild("SubclassNetwork"):FindFirstChild("PurchaseSubclass"):InvokeServer(p) then
							return (openSubclassWindow(p))
						end

						return {
							Text = { "..." }
						}
					else
						Util.playAction("Negative")
						return {
							Text = { string.format("You need %s more Fragments.", v6) }
						}
					end
				end
			}
		}
	elseif v3 == 3 then
		local v5 = v4[1]
		local v6 = nil

		if p == "Shipwright" then
			v6 = string.format("You've got to kill %s more Sharks, kid.", v5)
		elseif p == "Helmsman" then
			v6 = string.format("You need to discover %s more Mini Islands.", v5)
		end

		return {
			Text = { v6 }
		}
	elseif v3 == 4 then
		Util.playAction("Positive")
		return {
			Text = { string.format("Here's your reward. Talk to me again to become a %s.", p) }
		}
	else
		error((`unexpected response: {v3}`))
	end
end

function Library.useTool(p: string)
	assert(p == "HolidayGift" or p == "Potion" or p == "Food")
	local title = "???"
	local v2 = "???"

	if p == "HolidayGift" then
		title = "Gift"
		v2 = "Gift"
	elseif p == "Potion" then
		title = "Potion"
		v2 = "Potion"
	elseif p == "Food" then
		title = "Food"
		v2 = "Food"
	end

	return {
		Title = title,
		Get = function(_)
			return {
				Text = { (`What do you wish to do with this {v2}?<AnimateYield=3>`) },
				Option1 = {
					Label = p == "HolidayGift" and "Open" or "Use",
					JumpTo = function()
						local consumeEvent = localPlayer.Character:FindFirstChild("ConsumeEvent", true)

						if not consumeEvent then
							return {
								Text = { (`[You must be holding out the {v2} to open it.]`) }
							}
						end

						local v3 = consumeEvent:InvokeServer("Use")

						if typeof(v3) == "string" then
							return {
								Text = { v3 }
							}
						end

						if v3 then
							return {
								Text = { (`[Using {v2}.]`) }
							}
						end

						return {
							Text = { "[An error has occurred. Please try again.]" }
						}
					end
				},
				Option2 = {
					Label = "Drop",
					JumpTo = function()
						local consumeEvent = localPlayer.Character:FindFirstChild("ConsumeEvent", true)

						if not consumeEvent then
							return {
								Text = { (`[You must be holding out the {v2} to drop it.]`) }
							}
						end

						if consumeEvent:InvokeServer("Drop") then
							return {
								Text = { (`[{v2} dropped.]`) }
							}
						end

						return {
							Text = { "..." }
						}
					end
				},
				Option3 = {
					Label = "Store",
					JumpTo = function()
						if not localPlayer.Character:FindFirstChild("ConsumeEvent", true) then
							return {
								Text = { (`[You must be holding out the {v2} to store it.]`) }
							}
						end

						if p == "HolidayGift" then
							if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreHolidayGift") then
								return {
									Text = { (`[{v2} stored.]`) }
								}
							end
						else
							if p ~= "Potion" and p ~= "Food" then
								return {
									Text = { "[???]" }
								}
							end

							if Net:RemoteFunction("ConsumablesNetworkRF"):InvokeServer({
								Context = "StoreConsumable"
							}) then
								return {
									Text = { (`[{v2} stored.]`) }
								}
							end
						end

						return {
							Text = { "[Storage full.]" }
						}
					end
				}
			}
		end
	}
end

function Library.recruiterDialogue(p: string)
	local spiritTree = game.ReplicatedStorage.Remotes.SpiritTree
	local eventActive = spiritTree:GetAttribute("EventActive")
	spiritTree:GetAttribute("NextStart")
	local v = spiritTree:GetAttribute("Faction") == p
	local v2 = p == "Rip" and "<Color=Purple>Rip Family<Color=/>" or "<Color=Red>Red Army<Color=/>"
	local v3 = p == "Rip" and "Rip Family" or "Red Army"
	local option = {
		Label = "Change Teams",
		JumpTo = function()
			Util.playAction("Observe")
			return {
				Text = { "Ready to join us?" },
				Option1 = {
					Label = "Yes",
					JumpTo = function()
						if game.Players.LocalPlayer.Team.Name == v3 then
							Util.playAction("Negative")
							return {
								Text = { "You're already one of us." }
							}
						end

						Util.playAction("Welcome")
						return {
							Text = { "Welcome to the " .. v2 .. "!" },
							Function = function()
								game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam2", v3)
							end
						}
					end
				}
			}
		end
	}

	if eventActive then
		if v then
			Util.playAction("Explain")
			return {
				Text = { "They've already begun attacking! I can bring you to the island if you wish." },
				Option1 = {
					Label = "Teleport",
					JumpTo = function()
						game.ReplicatedStorage.Remotes.SpiritTree:InvokeServer("TeleportToEvent")
						return false
					end
				},
				Option2 = option
			}
		end

		Util.playAction("Explain")
		return {
			Text = { "The battle has already started. The <Color=Yellow>Spirit Tree<Color=/> will be ours." },
			Option1 = option
		}
	else
		if not v then
			Util.playAction("Observe")
			return {
				Text = { "We're planning something big. Good luck." },
				Option1 = option
			}
		end

		local v5 = p == "Red" and "<Color=Purple>Rip Family<Color=/>" or "<Color=Red>Red Army<Color=/>"

		if not game.Players.LocalPlayer:GetAttribute("RegisteredSpiritTree") then
			return {
				Text = {
					"The " .. v5 .. " is planning an invasion. They're trying to destroy our realm by taking our <Color=Yellow>Spirit Tree<Color=/>.",
					"We need your help defending the island! Can I count on you during the invasion?"
				},
				Option1 = {
					Label = "Yes",
					JumpTo = function()
						Util.playAction("Positive")
						game.ReplicatedStorage.Remotes.SpiritTree:InvokeServer("AttemptRegistration")
						return {
							Text = { "Thanks for agreeing to help. I'll bring you to the island when the invasion starts." }
						}
					end
				},
				Option2 = option
			}
		end

		Util.playAction("Positive")
		return {
			Text = { "Thanks for agreeing to help. I'll bring you to the island when the invasion starts." },
			Option1 = option
		}
	end
end

return Library