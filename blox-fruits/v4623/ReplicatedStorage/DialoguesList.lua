local Lighting = game:GetService("Lighting")
local PlayerProfileLookup = require(game.ReplicatedStorage.Controllers.UI.PlayerProfileLookup)
local Realm = require(game.ReplicatedStorage.Util.Realm)
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local Net = require(game.ReplicatedStorage.Modules.Net)
local CraftWindow = require(game.ReplicatedStorage.Controllers.UI.CraftWindow)
require(script.Types)
local Util = require(script.Util)
local Library = require(script.Library)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local remoteEvent = Net:RemoteEvent("TouchKitsuneStatue")
local remoteFunction = Net:RemoteFunction("KitsuneStatuePray")
local remoteFunction2 = Net:RemoteFunction("Craft")
local remoteFunction3 = Net:RemoteFunction("EnchantInvoke")
local remoteFunction4 = Net:RemoteFunction("GetPlayerFlag")

local function withGuideClaim(p: string, p2, flag: boolean?)
	local BonusMomentsGuide = require(game.ReplicatedStorage.BonusMomentsGuide)
	local interactQuestGiver = BonusMomentsGuide.interactQuestGiver(p)
	local openingDialogue

	if interactQuestGiver then
		openingDialogue = interactQuestGiver.OpeningDialogue
	end

	if not openingDialogue or #openingDialogue == 0 then
		return p2
	end

	local text = {}

	for _, v2 in openingDialogue do
		table.insert(text, v2)
	end

	if flag then
		return {
			Text = text
		}
	end

	local clone = table.clone(p2)

	for _, v2 in clone.Text or {} do
		table.insert(text, v2)
	end

	clone.Text = text
	return clone
end

local DialoguesList = {
	DragonWizard = require(script.NPCs.DragonWizard),
	WeaponDealer = {
		Title = "Weapon Dealer",
		Get = function(p)
			return {
				Text = { "Which gun would you like to purchase?" },
				Option1 = {
					Label = "Slingshot",
					JumpTo = function()
						return Library.itemPurchase("Slingshot", p)
					end
				},
				Option2 = {
					Label = "Musket",
					JumpTo = function()
						return Library.itemPurchase("Musket", p)
					end
				},
				Option3 = {
					Label = "Flintlock",
					JumpTo = function()
						return Library.itemPurchase("Flintlock", p)
					end
				}
			}
		end
	},
	AdvancedWeaponDealer = {
		Title = "Advanced Weapons Dealer",
		Get = function(p)
			return {
				Text = { "Got a keen eye for the finer things eh? Which weapon would you like to purchase?" },
				Option1 = {
					Label = "Refined Slingshot",
					JumpTo = function()
						return Library.itemPurchase("Refined Slingshot", p)
					end
				},
				Option2 = {
					Label = "Dual Flintlock",
					JumpTo = function()
						return Library.itemPurchase("Dual Flintlock", p)
					end
				},
				Option3 = {
					Label = "Cannon",
					JumpTo = function()
						return Library.itemPurchase("Cannon", p)
					end
				}
			}
		end
	},
	SwordDealer1 = {
		Title = "Sword Dealer",
		Get = function(p)
			Net:RemoteEvent("RobloxAnalytics"):FireServer({
				Context = "SpokeToNPC",
				InternalName = "SwordDealer1"
			})
			return {
				Text = { "Greetings, fellow swordsman. I sell beginner level swords of equal strength and skills. Which will you choose?" },
				Option1 = {
					Label = "Katana",
					JumpTo = function()
						return Library.itemPurchase("Katana", p)
					end
				},
				Option2 = {
					Label = "Cutlass",
					JumpTo = function()
						return Library.itemPurchase("Cutlass", p)
					end
				}
			}
		end
	},
	SwordDealer2 = {
		Title = "Sword Dealer of the West",
		Get = function(p)
			return {
				Text = { "Well go on then, which sword would you like to purchase?" },
				Option1 = {
					Label = "Dual Katana",
					JumpTo = function()
						return Library.itemPurchase("Dual Katana", p)
					end
				},
				Option2 = {
					Label = "Iron Mace",
					JumpTo = function()
						return Library.itemPurchase("Iron Mace", p)
					end
				}
			}
		end
	},
	SwordDealer3 = {
		Title = "Sword Dealer of the East",
		Get = function(p)
			return {
				Text = { "A bit far from home aren't ya? Which sword would you like to purchase?" },
				Option1 = {
					Label = "Triple Katana",
					JumpTo = function()
						return Library.itemPurchase("Triple Katana", p)
					end
				},
				Option2 = {
					Label = "Pipe",
					JumpTo = function()
						return Library.itemPurchase("Pipe", p)
					end
				}
			}
		end
	},
	SwordDealer4 = {
		Title = "Master Sword Dealer",
		Get = function(p)
			return {
				Text = { "Welcome, student of the blade. Which sword would you like to purchase?" },
				Option1 = {
					Label = "Dual-Headed Blade",
					JumpTo = function()
						return Library.itemPurchase("Dual-Headed Blade", p)
					end
				},
				Option2 = {
					Label = "Bisento",
					JumpTo = function()
						return Library.itemPurchase("Bisento", p)
					end
				}
			}
		end
	},
	SwordDealer5 = {
		Title = "Hidden Sword Dealer",
		Get = function(_)
			if game.Players.LocalPlayer:GetAttribute("MagmaDrillPlugged") == true then
				return {
					Text = {
						"...You brought that drill down. I felt the whole mountain go quiet from up here.",
						"Take the <Color=Orange>Soul Cane<Color=/>. No charge, not after what you did down there.",
						"I patched up the old lift behind the drill site while I was at it. Ride it whenever you like, it'll carry you straight back up."
					},
					Option1 = {
						Label = "Accept",
						JumpTo = function()
							local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ClaimDrillReward")

							if v == 1 then
								Util.playAction("Positive")
								return {
									Text = { "[Received <Color=Orange>Soul Cane<Color=/>.]" }
								}
							elseif v == 2 then
								Util.playAction("Explain")
								return {
									Text = { "...You already carry one. Keep it sharp." }
								}
							end

							Util.playAction("Negative")
							return {
								Text = { "..." }
							}
						end
					}
				}
			end

			return {
				Text = {
					"...Listen. That grinding, deep under the mountain.",
					"Some crew dragged a drill into the volcano cave and it hasn't stopped since. It's tearing the island apart from the inside.",
					"Put an end to it, and I'll see you're paid for the trouble."
				}
			}
		end
	},
	BoatDealer = Library.talkBoatDealer(function()
		if game.Players.LocalPlayer.Team == game.Teams.Pirates then
			return "Pirate"
		end

		return "Marine"
	end, "Boat Dealer"),
	LuxuryBoatDealer = Library.talkBoatDealer("Premium", "Luxury Boat Dealer"),
	BoatDealerMarines = Library.talkBoatDealer("Marine", "Boat Dealer"),
	BoatDealerMarines2 = Library.talkBoatDealer("Marine2", "Advanced Boat Dealer"),
	PartyShop = require(script.NPCs.PartyShop),
	FruitShop = require(script.NPCs.FruitShop),
	FruitShop2 = require(script.NPCs.FruitShop2),
	Lookout = require(script.NPCs.Lookout),
	JoinPirates = {
		Title = "Pirate Recruiter",
		Get = function(_)
			Net:RemoteEvent("RobloxAnalytics"):FireServer({
				Context = "SpokeToNPC",
				InternalName = "JoinPirates"
			})
			return {
				Text = { "Would you like to change your team to <Color=Red>pirates<Color=/>? Stop obeying all of these rules and fight for your own treasures!" },
				Option1 = {
					Label = "Join",
					JumpTo = function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam2", "Pirates") == 0 then
							Util.playAction("Positive")
							return {
								Text = { "Welcome to the <Color=Red>pirates<Color=/> side!" }
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "You can't change teams when you're In Combat!" }
						}
					end
				}
			}
		end
	},
	JoinMarines = {
		Title = "Marine Recruiter",
		Get = function(_)
			Net:RemoteEvent("RobloxAnalytics"):FireServer({
				Context = "SpokeToNPC",
				InternalName = "JoinMarines"
			})
			return {
				Text = { "Would you like to change your team to <Color=Blue>marines<Color=/>? Help us get rid of these no good thieves and bring them to justice!" },
				Option1 = {
					Label = "Join",
					JumpTo = function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam2", "Marines") == 0 then
							Util.playAction("Positive")
							return {
								Text = { "Welcome to the <Color=Blue>marines<Color=/> side!" }
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "You can't change teams when you're In Combat!" }
						}
					end
				}
			}
		end
	}
}
local v = DialogueController.new()
v:setTitle("Set Home Point")

local function buildSetSpawnPointResultPage(object)
	local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")

	if v2 == 0 then
		Util.playAction("Negative")
		object:addText("[<Color=Red>Only Pirates can set Spawn Points!<Color=/>]")
	elseif v2 == -1 then
		Util.playAction("Negative")
		object:addText("[<Color=Red>Failed to set Spawn Point.<Color=/>]")
	else
		Util.playAction("Positive")
		object:addText("[<Color=Blue>Home Point<Color=/> set.]")
		object:advanceAfterDelay(1)
	end
end

v:addPage(function(object)
	Net:RemoteEvent("RobloxAnalytics"):FireServer({
		Context = "SpokeToNPC",
		InternalName = "SpawnPoint"
	})
	object:addText("Would you like set your <Color=Blue>Home Point<Color=/> here? You can press the home button from any safe zone to return here!")
	object:addOptionType("Accept", function(object2)
		object2:setText("Accept")
		object2:jumpToPage(buildSetSpawnPointResultPage)
	end)
end)
DialoguesList.SpawnPoint = v:build()
DialoguesList.SickMan = {
	Title = "Sick Man",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Help",
				JumpTo = function()
					return ((function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "SickMan") ~= 0 then
							return {
								Text = { "I'm so thirsty..." }
							}
						end

						Util.playAction("Explain")
						return {
							Text = { "Thank you so much! Please meet up with my son, I'm sure he will reward you." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.RichMan = {
	Title = "Rich Man",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon")

						if v2 == 0 then
							Util.playAction("Positive")
							return {
								Text = { "Thanks for helping my father, but a mob leader has stolen all my money! Please find and take him down as soon as possible so I can reward you..." }
							}
						elseif v2 == 1 then
							Util.playAction("Positive")
							return {
								Text = { "Thank you for getting my money back, you can keep this ancient relic as your reward." }
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "Get lost." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Detective = {
	Title = "Military Detective",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
							"DressrosaQuestProgress",
							"Detective"
						)

						if v2 == 0 then
							Util.playAction("Explain")
							return {
								Text = {
									"<AnimateYield=1>DON SWAN HAS ESCAPED!",
									"We need help tracking him down before he takes over the world!",
									"My latest intel says he is hiding out with the <Color=Blue>Ice Admiral<Color=/> at the <Color=Blue>Frozen Village<Color=/>. Take this key and track him down!"
								}
							}
						elseif v2 == 1 then
							Util.playAction("Explain")
							return {
								Text = { "Have you found the <Color=Blue>Ice Admiral<Color=/> at the <Color=Blue>Frozen Village<Color=/> yet? Get the information!" }
							}
						elseif v2 == 2 then
							Util.playAction("Explain")
							return {
								Text = {
									"Oh... Interesting. He thinks Swan is in the <Color=Blue>Second Sea<Color=/> .",
									"I have a captain who can take you there. He will meet you at the <Color=Blue>Middle Town<Color=/> . Good luck!"
								}
							}
						end

						Util.playAction("Explain")
						return {
							Text = { "You must be Level 700 to speak to me." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.TravelDressrosa = {
	Title = "Experienced Captain",
	Get = function(_)
		local BonusMomentsGuide = require(game.ReplicatedStorage.BonusMomentsGuide)
		local interactQuestGiver = BonusMomentsGuide.interactQuestGiver("TravelDressrosa")
		return {
			Text = not (interactQuestGiver and interactQuestGiver.OpeningDialogue) and { "..." } or interactQuestGiver.OpeningDialogue,
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Dressrosa") == 0 then
							return {
								Text = { "I can take you to the second sea. Would you like to go?" },
								Option1 = {
									Label = "Yes",
									Text = { "" },
									JumpTo = function()
										return {
											Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")) }
										}
									end
								}
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "Keep it moving." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.TravelZou = {
	Title = "Mr. Captain",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ZQuestProgress", "Zou") == 0 then
							return {
								Text = { "I can take you to the third sea. Would you like to go?" },
								Option1 = {
									Label = "Yes",
									Text = { "" },
									JumpTo = function()
										return {
											Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")) }
										}
									end
								}
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "Keep it moving." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.TravelMain = {
	Title = "Sea Captain",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						Util.playAction("Explain")
						return {
							Text = { "I can take you back to the main world. Would you like to go?" },
							Option1 = {
								Label = "Yes",
								Text = { "" },
								JumpTo = function()
									return {
										Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelMain")) }
									}
								end
							}
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Bartilo = {
	Title = "Bartilo",
	Get = function(_)
		return {
			Text = { "Hey." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BartiloQuestProgress", "Bartilo")
						Util.playAction("Explain")

						if v2 == 0 then
							return {
								Text = {
									"Thank God you are here! The Swan Pirates are raiding the towns to prevent any new fighters from entering the tournament.",
									"Will you help defeat 50 of the Swan Pirates?"
								},
								Option1 = {
									Label = "Yes",
									Text = { "" },
									JumpTo = Util.generateQuest("BartiloQuest", {
										NoReturn = true
									}).Get
								}
							}
						elseif v2 == 1 then
							return {
								Text = { "Great work! Now for their leader. Find and defeat Jeremy, the Spring-Spring user!" }
							}
						elseif v2 == 2 then
							return {
								Text = { "The tournament is back to normal! Go now, free the imprisoned gladiators who are jailed beneath the stadium." }
							}
						elseif v2 == 3 then
							return {
								Text = { "That's it! Thank you for your help." }
							}
						end

						return {
							Text = { "THE COLOSSEUM IS IN PERIL!" }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Citizen = {
	Title = "Citizen",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CitizenQuestProgress", "Citizen")
						Util.playAction("Explain")

						if v2 == 0 then
							return {
								Text = {
									"The Forest Pirates are destroying the town! Please help us!",
									"Will you help defeat 50 of them?"
								},
								Option1 = {
									Label = "Yes",
									Text = { "" },
									JumpTo = Util.generateQuest("CitizenQuest", {
										NoReturn = true
									}).Get
								}
							}
						elseif v2 == 1 then
							return {
								Text = { "Thank you so much! Now, please defeat their leader to stop them from coming back. Find and defeat Captain Elephant!" }
							}
						elseif v2 == 2 then
							return {
								Text = { "The town is now safer. I heard their leader left a treasure hidden in this island. You can keep the reward if you manage to find it." }
							}
						elseif v2 == 3 then
							return {
								Text = { "Thanks. Enjoy your reward! Let me know if you ever need help with anything, I'm a known chef around this area." }
							}
						elseif v2 == 4 then
							return {
								Text = { "So you need help preparing these 3 fruits? Alright, here you go." }
							}
						end

						return {
							Text = { "The town is being attacked!" }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.RedHead = {
	Title = "King Red Head",
	Get = function(_)
		return {
			Text = { "Yooooo!" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ZQuestProgress", "Check")

						if v2 == 0 then
							return {
								Text = { "I'm sad :(." },
								Option1 = {
									Label = "Why admin?",
									Text = { "Can you go disrespect rip_indra for me? I need him to pop his rune so we can finish Update 15!" },
									Option1 = {
										Label = "Of course, admin",
										Text = { "" },
										JumpTo = function()
											return {
												Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
														"ZQuestProgress",
														"Begin"
													)) }
											}
										end
									}
								}
							}
						elseif v2 == 1 then
							return {
								Text = { "Hi. This is a mental image of myself. I'm currently sealed in the third sea." }
							}
						end

						return {
							Text = { "I'm busy right now. Come back when you've reached Level 1,500 and defeated Don Swan!" }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.BountyHonorExpert = {
	Title = "Bounty/Honor Expert",
	Get = function(_)
		return {
			Text = { "You see those leaderboards? They display the top players of this game, I wouldn't mess with them if I were you." },
			Option1 = {
				Label = "Why?",
				Text = { "Bounty and honor increase your damage and defense in PvP every 500,000 points. Would you like to know your current PvP boosts?" },
				Option1 = {
					Label = "Yes",
					JumpTo = function()
						local value = game.Players.LocalPlayer.leaderstats["Bounty/Honor"].Value
						local v2 = { 0, 0 }

						for k, v3 in pairs(require(game.ReplicatedStorage.PvPBoosts)) do
							if not (k <= value) then
								continue
							end

							v2[1] += v3[1]
							v2[2] += v3[2]
						end

						Util.playAction("Explain")
						return {
							Text = { "You currently have +" .. string.format("%.14g", v2[1] * 100) .. "% defense and +" .. string.format(
									"%.14g",
									v2[2] * 100
								) .. "% damage on PvP." }
						}
					end
				}
			}
		}
	end
}
DialoguesList.MysteriousMan = {
	Title = "Mysterious Man",
	Get = function(_)
		return {
			Text = { "... Hey." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("MysteriousMan", "1")

						if v2 == 0 then
							Util.playAction("Explain")
							return {
								Text = {
									"Hello, fellow swordsman. It appears you've mastered all the legendary swords.",
									"Do you wish to learn the true triple katana style for <Color=Green>$2,000,000<Color=/>?"
								},
								Option1 = {
									Label = "Pay",
									Text = { "" },
									JumpTo = function()
										return {
											Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
													"MysteriousMan",
													"2"
												)) }
										}
									end
								}
							}
						elseif v2 == -1 then
							return {
								Text = { "[You already own this item.]" }
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "Go away." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.MartialArtsMaster = {
	Title = "Martial Arts Master",
	Get = function(_)
		return {
			Text = { "Hmmm..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function(_)
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySuperhuman", true)

						if v2 ~= 3 then
							return {
								Text = { v2 == 1 and "It seems you already know this style. Would you like to start using it again?" or "Would you like to learn the Superhuman fighting style for <Color=Green>$3,000,000<Color=/>? This style allows you to destroy your opponents body with powerful attacks and has 3 special skills." },
								Option1 = {
									Label = "Learn",
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySuperhuman")

										if v3 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Superhuman learned.]" }
											}
										elseif v3 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough Money.]" }
											}
										elseif v3 == 2 then
											Util.playAction("Negative")
											return {
												Text = { "[You already know this fighting style.]" }
											}
										end

										if v3 ~= 3 then
											return
										end

										Util.playAction("Negative")
										return {
											Text = { "[You're not strong enough yet.]" }
										}
									end
								}
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "You're not strong enough yet. Keep practicing your martial arts!" }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Manager = {
	Title = "Manager",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Manager", "1")

						if v2 == 0 then
							return {
								Text = {
									"What's up, warrior?",
									"Do you wish to hear where <Color=Red>he<Color=/> was last seen?"
								},
								Option1 = {
									Label = "Yeah",
									Text = { "" },
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Manager", "2")
										Util.playAction("Explain")
										return {
											Text = { v3 }
										}
									end
								}
							}
						elseif v2 == -1 then
							Util.playAction("Negative")
							return {
								Text = { "Are you new to this island?" }
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "It's still too early for you to be here." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Customer = {
	Title = "Customer",
	Get = function(_)
		return {
			Text = { "What's up?" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local text = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Customer")
						Util.playAction("Explain")

						if text then
							return {
								Text = text
							}
						end

						return {
							Text = { "..." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Butler = {
	Title = "Butler",
	Get = function(_)
		return {
			Text = { "Howdy." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local text = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Butler")
						Util.playAction("Explain")

						if text then
							return {
								Text = text
							}
						end

						return {
							Text = { "..." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Nerd = {
	Title = "Nerd",
	Get = function(_)
		return {
			Text = { "PFFFFTTTTTTTTTTTT..." },
			Option1 = {
				Label = "Sir...?",
				JumpTo = function()
					return ((function()
						return {
							Text = { "I guess I could spare some of my time and intellect to help you out... What do you want me to analyze?" },
							Option1 = {
								Label = "Stats",
								Text = { "" },
								JumpTo = function()
									local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Nerd")

									if v2 then
										Util.playAction("Explain")
										return {
											Text = { v2 }
										}
									end

									Util.playAction("Negative")
									return {
										Text = { "You aren't wearing any accessories. Stop wasting my time!" }
									}
								end
							},
							Option2 = {
								Label = "Profiles",
								Text = { "" },
								JumpTo = function()
									assert(PlayerProfileLookup.IsInitialized, "bad player profile lookup")
									PlayerProfileLookup:Open(false)

									repeat
										task.wait()
									until not PlayerProfileLookup:IsOpen()

									return {
										Text = { "..." }
									}
								end
							}
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Alchemist = require(script.NPCs.Alchemist)
DialoguesList.Wenlocktoad = require(script.NPCs.Wenlocktoad)
DialoguesList.CyborgTrainer = {
	Title = "",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "...",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CyborgTrainer", "Check")

						if v2 == 2 then
							return {
								Text = { "> Hello, cyborg." }
							}
						end

						if v2 then
							return {
								Text = { "> Would you like to change your race to Cyborg for <Color=Purple>ƒ2,500<Color=/>? This race is specialized in defense and energy." },
								Option1 = {
									Label = "Accept",
									Text = { "" },
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"CyborgTrainer",
											"Buy"
										)

										if v3 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Race changed to <Cyborg>.]" }
											}
										end

										if v3 ~= 2 then
											return {
												Text = { "..." }
											}
										end

										Util.playAction("Negative")
										return {
											Text = { "[You don't have enough money.]" }
										}
									end
								}
							}
						end

						return {
							Text = { "..." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Sabi = require(script.NPCs.Sabi)
DialoguesList.Divine = {
	Title = "Divine",
	Get = function(_)
		return {
			Text = { "Hello." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return {
						Text = { "..." }
					}
				end
			}
		}
	end
}
DialoguesList.Cyborg = {
	Title = "Cyborg",
	Get = function(_)
		return {
			Text = { "!!!" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Ship", "1")

						if not v2 then
							Util.playAction("Negative")
							return {
								Text = { "I'm busy!" }
							}
						end

						if v2 ~= 1 then
							return {
								Text = { "Dang, you're rich! Would you be willing take one of my best ships at the cost of <Color=Purple>ƒ1,500<Color=/>?" },
								Option1 = {
									Label = "Trade",
									Text = { "" },
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"BlackbeardReward",
											"Ship",
											"2"
										)

										if v3 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Trade completed.]" }
											}
										elseif v3 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough fragments.]" }
											}
										end

										if v3 ~= 2 then
											return {
												Text = { "..." }
											}
										end

										Util.playAction("Explain")
										return {
											Text = { "[You already own this item.]" }
										}
									end
								}
							}
						end

						Util.playAction("Explain")
						return {
							Text = { "You already took my ship!" }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.tort = {
	Title = "tort",
	Get = function(_)
		return {
			Text = { "Hey." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "1") then
							return {
								Text = { "hey sir, i will write something for you in JS that rerolls your race to a random one (only works once) if you pay me <Color=Purple>ƒ3000<Color=/>. deal?" },
								Option1 = {
									Label = "Trade",
									Text = { "" },
									JumpTo = function()
										local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"BlackbeardReward",
											"Reroll",
											"2"
										)

										if v2 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Trade completed.]" }
											}
										elseif v2 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough fragments.]" }
											}
										end

										if v2 ~= 2 then
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

						Util.playAction("Negative")
						return {
							Text = { "I'm busy right now." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.HornedMan = {
	Title = "Horned Man",
	Get = function(_)
		return {
			Text = { "Hey." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("HornedMan")

						if typeof(v2) == "string" then
							return {
								Text = { v2 },
								Option1 = {
									Label = "Alright",
									JumpTo = function()
										game.ReplicatedStorage.Remotes.CommF_:InvokeServer("HornedMan", "Bet")
										return {
											Text = { "Talk to me again when you're done." }
										}
									end
								}
							}
						end

						if v2 == 1 then
							return {
								Text = { "Excellent work. I don't have anything for you anymore. Enjoy your reward." }
							}
						end

						return {
							Text = { "..." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Flashback = {
	Title = "erin",
	Get = function(_)
		return {
			Text = { "NOOOOO I'M GETTING A FLASHBACK AGAIN!" },
			Option1 = {
				Label = "Let me see",
				JumpTo = function()
					local Global = require(game.ReplicatedStorage.Global)

					if Global.flashbacking then
						return {
							Text = { "Scene is already loading..." }
						}
					end

					local Global2 = require(game.ReplicatedStorage.Global)
					Global2.flashbacking = true
					game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Flashback")
					task.delay(66, function()
						local Global3 = require(game.ReplicatedStorage.Global)
						Global3.flashbacking = nil
					end)
					return {
						Text = { "Ok... wait a bit." }
					}
				end
			}
		}
	end
}
DialoguesList.layandikit12 = {
	Title = "layandikit12",
	Get = function(_)
		return {
			Text = { "[Releasing next update.]" }
		}
	end
}
DialoguesList.ArenaTrainer = {
	Title = "Arena Trainer",
	Get = function(_)
		return {
			Text = { "Hey, wanna test your strength?" },
			Option1 = {
				Label = "Sure",
				JumpTo = function()
					return {
						Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ArenaTrainer")) }
					}
				end
			}
		}
	end
}
DialoguesList.Lunoven = {
	Title = "Lunoven",
	Get = function(_)
		return {
			Text = { "Hey." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return {
						Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TokenAccessory", "Elite")) }
					}
				end
			}
		}
	end
}
DialoguesList.Tacomura = {
	Title = "Tacomura",
	Get = function(_)
		return {
			Text = { "Greetings." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return {
						Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer("TokenAccessory", "Player")) }
					}
				end
			}
		}
	end
}
DialoguesList.Plokster = {
	Title = "Plokster",
	Get = function(_)
		return {
			Text = { "Hi." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "1") then
							return {
								Text = { "I can refund your stat points if you hand over <Color=Purple>ƒ2500<Color=/>. Deal?" },
								Option1 = {
									Label = "Trade",
									Text = { "" },
									JumpTo = function()
										local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"BlackbeardReward",
											"Refund",
											"2"
										)

										if v2 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Trade completed.]" }
											}
										elseif v2 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough fragments.]" }
											}
										end

										if v2 ~= 2 then
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
							Text = { "The weather is nice today." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Usoapp = {
	Title = "The Strongest God",
	Get = function(_)
		return {
			Text = { "!?" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
							"BlackbeardReward",
							"Slingshot",
							"1"
						)

						if not v2 then
							Util.playAction("Negative")
							return {
								Text = { "Who are you, weakling?" }
							}
						end

						if v2 == 1 then
							return {
								Text = { "You already have my slingshot!" }
							}
						end

						return {
							Text = { "S-SIR WOULD YOU TAKE MY SLINGSHOT FOR <Color=Purple>ƒ1500<Color=/>?" },
							Option1 = {
								Label = "Trade",
								Text = { "" },
								JumpTo = function()
									local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
										"BlackbeardReward",
										"Slingshot",
										"2"
									)

									if v3 == 1 then
										Util.playAction("Positive")
										return {
											Text = { "[Trade completed.]" }
										}
									elseif v3 == 0 then
										Util.playAction("Negative")
										return {
											Text = { "[Not enough fragments.]" }
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
					end)())
				end
			}
		}
	end
}
DialoguesList.Trevor = require(script.NPCs.Trevor)
DialoguesList.LegendarySwordDealer = {
	Title = "Legendary Sword Dealer",
	Get = function(_)
		return {
			Text = { "You found me!" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "1")

						if v2 then
							return {
								Text = { "Interested in buying this sword I recently acquired?\nName: " .. v2 .. "\nPrice: <Color=Green>$2,000,000<Color=/>" },
								Option1 = {
									Label = "Purchase",
									Text = { "" },
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"LegendarySwordDealer",
											"2"
										)

										if v3 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Item purchased.]" }
											}
										elseif v3 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough Money.]" }
											}
										end

										if v3 ~= 2 then
											return {
												Text = { "[Gone.]" }
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
							Text = { "[Gone.]" }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.MasterOfEnhancement = {
	Title = "Barista Cousin",
	Get = function(_)
		return {
			Text = { "You found me!" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2, v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ColorsDealer", "1")

						if v2 == 1 then
							return {
								Text = { "Sorry, your Aura ability is not strong enough yet." }
							}
						end

						if v2 then
							return {
								Text = { "Want to learn the <Recipe> for this Aura drink?\nName: " .. v2 .. "\nTier: " .. (v3 >= 3 and "<Color=Purple>LEGENDARY<Color=/>" or "Rare") },
								Option1 = {
									Label = "Learn",
									Text = { "" },
									JumpTo = function()
										local v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"ColorsDealer",
											"2"
										)

										if v4 == 1 then
											return {
												Text = { "[Recipe obtained.]" }
											}
										elseif v4 == 0 then
											return {
												Text = { "[Not enough money.]" }
											}
										elseif v4 == 2 then
											return {
												Text = { "[You already know this recipe.]" }
											}
										end

										return {
											Text = { "[Gone.]" }
										}
									end
								}
							}
						end

						return {
							Text = { "[Gone.]" }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.HakiTeacher = require(script.NPCs.HakiTeacher)
DialoguesList.KenTeacher = {
	Title = "Instinct Teacher",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk", "Start")

						if v2 == 0 then
							return {
								Text = { "Do you want to know about your Instinct mastery status, rookie?" },
								Option1 = {
									Label = "Status",
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"KenTalk",
											"Status"
										)
										Util.playAction("Explain")
										return {
											Text = { "Hmm... Your current mastery exp. seems to be " .. (v3 or "[error]") }
										}
									end
								}
							}
						elseif v2 == 1 then
							return {
								Text = {
									"Hey... want to learn Instinct?",
									"The power of Instinct allows you to <Color=Yellow>sense the presence<Color=/> of others as well <Color=Yellow>dodging attacks<Color=/>.",
									"Your Instinct will be <Color=Red>weak<Color=/> at first, allowing you only to dodge twice and have a small range of sense, but through constant dodging you will be able to <Color=Green>train<Color=/> it and gain a maximum of eight dodges as well as an extended vision range.",
									"Would you like to purchase Instinct for <Color=Green>$750,000<Color=/>?"
								},
								Option1 = {
									Label = "Learn",
									JumpTo = function()
										if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk", "Buy") == 0 then
											Util.playAction("Positive")
											return {
												Text = { "[Instinct learned. Press [E] to activate it.]" }
											}
										end

										Util.playAction("Negative")
										return {
											Text = { "[Not enough money.]" }
										}
									end
								}
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "I am the strongest pirate to ever live, I will not have any weaklings among my crew. Come back when you're stronger." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.ObservationV2 = require(script.NPCs.ObservationV2)
DialoguesList.BlackLegTeacher = {
	Title = "Dark Step Teacher",
	Get = function(_)
		return {
			Text = { "Yo." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function(_)
						return {
							Text = { game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBlackLeg", true) == 1 and "It seems you already know this style. Would you like to start using it again?" or "Would you like to learn the Dark Step fighting style for <Color=Green>$150,000<Color=/>? This style allows you to attack your opponents with powerful kicks and has 4 special skills." },
							Option1 = {
								Label = "Learn",
								JumpTo = function()
									local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBlackLeg")

									if v2 == 1 then
										Util.playAction("Positive")
										return {
											Text = { "[Dark Step learned.]" }
										}
									elseif v2 == 0 then
										Util.playAction("Negative")
										return {
											Text = { "[Not enough Money.]" }
										}
									end

									if v2 ~= 2 then
										return
									end

									Util.playAction("Negative")
									return {
										Text = { "[You already know this fighting style.]" }
									}
								end
							}
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.ElectroTeacher = {
	Title = "Mad Scientist",
	Get = function(_)
		return (withGuideClaim("SkyElectroTeacher", {
			Text = { "Hmmm... I have spent my years of research to teach every race the powers of Electric." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ElectroQuestState")

					local function fn()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("AcceptElectroQuest") == 1 then
							Util.playAction("Positive")
							return {
								Text = {}
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "[Come back later.]" }
						}
					end

					if v2 == 0 then
						return {
							Text = {
								"So you want the Electric style... Hmm. My money is no good to me if you cannot survive the lesson.",
								"The storm clouds around these islands are carrying an unusual amount of electrical energy. I need you to capture a lightning bolt and bring it back to me.",
								"While you're out there, keep an eye out for a dark cloud. Your best chance of finding a lightning bolt is by going through one of those."
							},
							Option1 = {
								Label = "I'll get you one",
								JumpTo = fn
							}
						}
					elseif v2 == 5 then
						return {
							Text = {
								"Ah. You already carry the current, so there is nothing left for me to teach you.",
								"Bring me a Lightning Bolt anyway. I still want a sample for the work, and your best chance of finding one is by going through a dark cloud."
							},
							Option1 = {
								Label = "I'll get you one",
								JumpTo = fn
							}
						}
					elseif v2 == 1 then
						return {
							Text = { "Still empty-handed? Keep an eye out for a dark cloud. Your best chance of finding a lightning bolt is by going through one of those." }
						}
					end

					if v2 == 3 then
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("DeliverLightningBolt") == 1 then
							Util.playAction("Positive")
							return {
								Text = {
									"Excellent... this current is stronger than I expected. With the right technique, this energy could even be channeled through the body.",
									"If you're interested in learning how to use electricity to your advantage, come back to me and I'll teach you some skills."
								}
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "[Come back later.]" }
						}
					elseif v2 == 4 then
						return {
							Text = { "There it is, still humming. You already know the style, so keep your money. Hand the bolt over and we are square." },
							Option1 = {
								Label = "Hand it over",
								JumpTo = function()
									if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("DeliverLightningBolt") == 1 then
										Util.playAction("Positive")
										return {
											Text = { "Good. Off to the notes with it. You did the work, even if you did not need the lesson." }
										}
									end

									Util.playAction("Negative")
									return {
										Text = { "[Come back later.]" }
									}
								end
							}
						}
					else
						return ((function()
							local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectro", true) == 1
							return {
								Text = { v3 and "It seems you already know this style. Would you like to start using it again?" or "Now for my fee: <Color=Green>$500,000<Color=/>, and the Electric fighting style is yours. It shocks your opponents with electric attacks and has 3 special skills." },
								Option1 = {
									Label = v3 and "Learn" or "Pay $500,000",
									JumpTo = function()
										local v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectro")

										if v4 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Electric learned.]" }
											}
										elseif v4 == 3 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough Money.]" }
											}
										elseif v4 == 4 then
											Util.playAction("Negative")
											return {
												Text = { "[You are still in combat.]" }
											}
										elseif v4 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[You need a Lightning Bolt.]" }
											}
										end

										if v4 ~= 2 then
											return {
												Text = { "..." }
											}
										end

										Util.playAction("Negative")
										return {
											Text = { "[You already know this fighting style.]" }
										}
									end
								}
							}
						end)())
					end
				end
			}
		}))
	end
}
DialoguesList.AngelGuard = {
	Title = "Angel Guard",
	Get = function(_)
		return {
			Text = { "You know there's a secret to why the skylands people are so rich..." },
			Option1 = {
				Label = "Go on",
				JumpTo = function()
					return {
						Text = {
							"Clowns came up out of the clouds and took the Skylands treasure while I stood here holding a post I am not allowed to leave.",
							"Every jewel in that hoard belongs to the people below us. The bandits keep it in the castle now, and the guardian they woke is worse than the bandits."
						}
					}
				end
			}
		}
	end
}
DialoguesList.FishmanKarateTeacher = {
	Title = "Water Kung-fu Teacher",
	Get = function(_)
		if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CheckFishmanKarate") then
			return (withGuideClaim("FishmanKarateTeacher", {
				Text = { "Hello." },
				Option1 = {
					Label = "Talk",
					JumpTo = function()
						return ((function()
							return {
								Text = { game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyFishmanKarate", true) == 1 and "It seems you already know this style. Would you like to start using it again?" or "Would you like to learn the Water Kung-fu fighting style for <Color=Green>$750,000<Color=/>? This style allows the manipulation of water to attack your opponents with it. It also has 3 special skills." },
								Option1 = {
									Label = "Learn",
									JumpTo = function()
										local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyFishmanKarate")

										if v2 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Water Kung-fu learned.]" }
											}
										elseif v2 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough Money.]" }
											}
										end

										if v2 ~= 2 then
											return
										end

										Util.playAction("Negative")
										return {
											Text = { "[You already know this fighting style.]" }
										}
									end
								}
							}
						end)())
					end
				}
			}))
		end

		return {
			Text = { "How ?" }
		}
	end
}
DialoguesList.DeathStepTeacher = {
	Title = "Phoeyu, the Reformed",
	Get = function(_)
		return {
			Text = { "hi" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function(_)
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDeathStep", true)

						if v2 ~= 3 then
							return {
								Text = { v2 == 1 and "It seems you already know this style. Would you like to start using it again?" or "Would you like to learn the Death Step fighting style for <Color=Green>$2,500,000<Color=/> and <Color=Purple>ƒ5,000<Color=/>? This style allows you to destroy your opponents body with powerful kicks and has 4 special skills." },
								Option1 = {
									Label = "Learn",
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDeathStep")

										if v3 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Death Step learned.]" }
											}
										elseif v3 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough money or fragments.]" }
											}
										elseif v3 == 2 then
											Util.playAction("Negative")
											return {
												Text = { "[You already know this fighting style.]" }
											}
										end

										if v3 ~= 3 then
											return
										end

										Util.playAction("Negative")
										return {
											Text = { "[You're not strong enough yet.]" }
										}
									end
								}
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "Come back when you're prepared enough." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.GodhumanTeacher = {
	Title = "Ancient Monk",
	Get = function(_)
		return {
			Text = { "Ah." },
			Option1 = {
				Label = "Hey",
				JumpTo = function()
					return ((function(_)
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyGodhuman", true)

						if typeof(v2) == "string" then
							return {
								Text = { v2 }
							}
						end

						if v2 ~= 3 then
							return {
								Text = { v2 == 1 and "It seems you already know this style. Would you like to start using it again?" or "Would you like to learn the Godhuman fighting style for <Color=Green>$5,000,000<Color=/> and <Color=Purple>ƒ5,000<Color=/>? This style allows you to annihilate your opponents with godlike attacks and has 4 special skills." },
								Option1 = {
									Label = "Learn",
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyGodhuman")

										if v3 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Godhuman learned.]" }
											}
										elseif v3 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough money or fragments.]" }
											}
										elseif v3 == 2 then
											Util.playAction("Negative")
											return {
												Text = { "[You already know this fighting style.]" }
											}
										end

										if v3 ~= 3 then
											return
										end

										Util.playAction("Negative")
										return {
											Text = { "[You're not strong enough yet.]" }
										}
									end
								}
							}
						end

						Util.playAction("Negative")
						return {
							Text = { "Come back when you're prepared enough." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.LeviathanGate = {
	Title = "Frozen Watcher",
	Get = function(_)
		return {
			Text = { "I've remained watch over this gate for millennia. Prove you have what it takes to face my master." },
			Option1 = {
				Label = "Very well",
				JumpTo = function()
					local v2, v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("OpenLeviathanGate")

					if v2 then
						Util.playAction("Positive")
						return {
							Text = { "Very well. You won't succeed, but I'll open the gate anyways." }
						}
					end

					if v3 == -3 then
						Util.playAction("Negative")
						return {
							Text = { "There's already a crew fighting the leviathan." }
						}
					end

					Util.playAction("Negative")
					return {
						Text = { "You need more allies before I can open the gate." }
					}
				end
			}
		}
	end
}
DialoguesList.SharkmanTeacher = {
	Title = "Sharkman Teacher",
	Get = function(_)
		return {
			Text = { "Hello!" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function(_)
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)

						if typeof(v2) == "string" then
							return {
								Text = { v2 }
							}
						end

						if v2 ~= 3 then
							return {
								Text = { v2 == 1 and "As an apprentice, I can only teach you so much. You should speak with my master in the Submerged Island to learn more. In the meantime, would you like to start using this fighting style again?" or "Would you like to learn the Sharkman Karate fighting style for <Color=Green>$2,500,000<Color=/> and <Color=Purple>ƒ5,000<Color=/>? This style allows the manipulation of water to attack your opponents with it. It also has 3 special skills." },
								Option1 = {
									Label = "Learn",
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate")

										if v3 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Sharkman Karate learned.]" }
											}
										elseif v3 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough money or fragments.]" }
											}
										elseif v3 == 2 then
											Util.playAction("Negative")
											return {
												Text = { "[You already know this fighting style.]" }
											}
										end

										if v3 ~= 3 then
											return
										end

										Util.playAction("Negative")
										return {
											Text = { "[You're not strong enough yet.]" }
										}
									end
								}
							}
						end

						Util.playAction("Explain")
						return {
							Text = { "Thanks for finding my keys, but I can't teach you anything yet! Come back when you're prepared enough." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.TalonTeacher = require(script.NPCs.TalonTeacher)
DialoguesList.SanguineTeacher = {
	Title = "Shafi",
	Get = function(_)
		return {
			Text = { "Hey man." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function(_)
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySanguineArt", true)

						if typeof(v2) == "string" then
							return {
								Text = { v2 }
							}
						end

						return {
							Text = { v2 == 1 and "It seems you already know this style. Would you like to start using it again?" or "Would you like to learn the Sanguine Art fighting style for <Color=Green>$5,000,000<Color=/> and <Color=Purple>ƒ5,000<Color=/>? This style allows the manipulation of darkness to attack your opponents with it. It also has 3 special skills." },
							Option1 = {
								Label = "Learn",
								JumpTo = function()
									local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySanguineArt")

									if v3 == 1 then
										Util.playAction("Positive")
										return {
											Text = { "[Sanguine Art learned.]" }
										}
									elseif v3 == 0 then
										Util.playAction("Negative")
										return {
											Text = { "[Not enough money or fragments.]" }
										}
									elseif v3 == 2 then
										Util.playAction("Negative")
										return {
											Text = { "[You already know this fighting style.]" }
										}
									end

									if v3 ~= 3 then
										return
									end

									Util.playAction("Negative")
									return {
										Text = { "[You're not strong enough yet.]" }
									}
								end
							}
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.PreviousHero = {
	Title = "Previous Hero",
	Get = function(_)
		return {
			Text = { "Hmm..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function(_)
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectricClaw", true)

						if typeof(v2) == "string" then
							return {
								Text = { v2 }
							}
						end

						if v2 == 4 then
							Util.playAction("Explain")
							return {
								Text = { "You seem to have potential. Alright, if you can go to the <Color=Yellow>Mansion<Color=/> within <Color=Red>30 seconds<Color=/>, I'll consider telling you." },
								Option1 = {
									Label = "Ok",
									JumpTo = function()
										game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectricClaw", "Start")
										return {
											Text = { "GO, YOU HAVE 30 SECONDS!" }
										}
									end
								}
							}
						end

						if v2 ~= 3 then
							return {
								Text = { v2 == 1 and "It seems you already know this style. Would you like to start using it again?" or "Would you like to learn the Electric Claw fighting style for <Color=Green>$3,000,000<Color=/> and <Color=Purple>ƒ5,000<Color=/>? This style allows the use of electric claws to pierce your opponents. It also has 3 special skills." },
								Option1 = {
									Label = "Learn",
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectricClaw")

										if v3 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Electric Claw learned.]" }
											}
										elseif v3 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough money or fragments.]" }
											}
										elseif v3 == 2 then
											Util.playAction("Negative")
											return {
												Text = { "[You already know this fighting style.]" }
											}
										end

										if v3 ~= 3 then
											return
										end

										Util.playAction("Negative")
										return {
											Text = { "[You're not strong enough yet.]" }
										}
									end
								}
							}
						end

						Util.playAction("Explain")
						return {
							Text = { "Good job, but I can't teach you anything yet! Come back when you're prepared enough." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.ThunderGod = {
	Title = "Thunder God",
	Get = function(_)
		return {
			Text = { "What do you need?" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function(_)
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ThunderGodTalk", true)

						if not v2 then
							Util.playAction("Negative")
							return {
								Text = { "Sorry, I can't teach you anything yet. Talk to me again once you unlock all your skills on Pole (1st Form) and Rumble." }
							}
						end

						if v2 ~= 2 then
							return {
								Text = { "Would you like me to teach you about Pole (2nd Form) for <Color=Purple>ƒ5,000<Color=/>?" },
								Option1 = {
									Label = "Sure",
									Text = { "" },
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ThunderGodTalk")

										if v3 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Item purchased.]" }
											}
										elseif v3 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough fragments.]" }
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

						Util.playAction("Negative")
						return {
							Text = { "[You already own this item.]" }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.Parlus = {
	Title = "Parlus",
	Get = function(_)
		return (withGuideClaim("MarineParlus", {
			Text = { "...? Speak." },
			Option1 = {
				Label = "Shop",
				Type = "Purchase",
				JumpTo = function()
					return ((function(_)
						local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("AccessoryTalk", "Parlus")

						if v2 == 0 then
							return {
								Text = { "LOL DUDE I JUST BOUGHT THIS BLACK CAPE FOR 100K ROBUX FROM SOME KID, HE SAID IT BOOSTS MY ATTACKS AND STUFF. WANNA BUY IT FOR <Color=Green>$50,000<Color=/> BRO? DUDE FAST I GTG CHURCH!!" },
								Option1 = {
									Label = "Deal.",
									Text = { "" },
									JumpTo = function()
										local v3 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"BuyItem",
											"Black Cape"
										)

										if v3 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Item purchased.]" }
											}
										elseif v3 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough Money.]" }
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

						Util.playAction("Negative")

						if v2 == 3 then
							return {
								Text = { "Bro I'm not sellin' MY drip to some guy who won't even put my FACE on that flagpole. Raise it first." }
							}
						end

						return {
							Text = { "Dude. You're not ready yet, bro." }
						}
					end)())
				end
			}
		}, true))
	end
}
DialoguesList.Yoshi = {
	Title = "Yoshi",
	Get = function(_)
		return {
			Text = { "What do you need?" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function(_)
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("AccessoryTalk", "Yoshi") == 0 then
							return {
								Text = { "Would you like to buy a Tomoe Ring accessory for <Color=Green>$500,000<Color=/>? It will boost the damage from your Blox Fruit attacks." },
								Option1 = {
									Label = "Sure.",
									Text = { "" },
									JumpTo = function()
										local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"BuyItem",
											"Tomoe Ring"
										)

										if v2 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Item purchased.]" }
											}
										elseif v2 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough Money.]" }
											}
										end

										if v2 ~= 2 then
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

						Util.playAction("Negative")
						return {
							Text = { "You're not ready yet, brat." }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.FamousPirate = {
	Title = "Crew Captain",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "MaxMembers", "1") then
							return {
								Text = { "Hello, fellow crew captain. Would you like to increase the members capacity of your crew by 1 for only <Color=Purple>ƒ2000<Color=/>?" },
								Option1 = {
									Label = "Trade",
									Text = { "" },
									JumpTo = function()
										local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"BlackbeardReward",
											"MaxMembers",
											"2"
										)

										if v2 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Trade completed.]" }
											}
										elseif v2 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough fragments.]" }
											}
										elseif v2 == 2 then
											Util.playAction("Negative")
											return {
												Text = { "[You already reached the maximum capacity.]" }
											}
										end

										if v2 ~= 3 then
											return {
												Text = { "..." }
											}
										end

										Util.playAction("Negative")
										return {
											Text = { "[You're not a crew captain.]" }
										}
									end
								}
							}
						end

						return {
							Text = { "What's up?" }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.GhostPuzzle = {
	Title = "Ghost",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Hello?",
				JumpTo = function()
					if workspace.Map["Haunted Castle"]:FindFirstChild("RoomBlock") then
						return {
							Text = { "..." }
						}
					end

					local Effect = require(game.ReplicatedStorage.Effect)
					Effect.new("BlindCam"):replicate({
						Color = Color3.new(0.03, 0.03, 0.03),
						Duration = 2,
						Fade = 0.25,
						ZIndex = -10
					})
					local Sound = require(game.ReplicatedStorage.Util.Sound)
					Sound:Play("Thunder", workspace.CurrentCamera.CFrame.p)
					wait(0.25)
					game.ReplicatedStorage.Remotes.CommF_:InvokeServer("GuitarPuzzleProgress", "Ghost")
					return {
						Text = { "..." }
					}
				end
			}
		}
	end
}
DialoguesList.CDKDoor = {
	Title = "???",
	Get = function(_)
		if not game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", "Boss") then
			return {
				Text = { "..." }
			}
		end

		local proximityPrompt = workspace.Map:WaitForChild("Turtle"):WaitForChild("Cursed"):WaitForChild("Pedestal3"):WaitForChild("ProximityPrompt")
		proximityPrompt.Enabled = false
		return {
			Text = { "The 6 shards of the legendary <Color=Red>Alucard Gem<Color=/> react to each other, forming the gem anew." }
		}
	end
}
DialoguesList.CryptMaster = {
	Title = "Crypt Master",
	Get = function(_)
		local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "OpenDoor")

		if v2 == "can" then
			return {
				Text = {
					"Have you seen the entrance behind this building? It feels cursed...",
					"I think you can handle it, I can open the way for you if you want."
				},
				Option1 = {
					Label = "Okay",
					JumpTo = function()
						if not game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "OpenDoor", true) then
							return {
								Text = { "..." }
							}
						end

						workspace.Map.Turtle.Cursed.Breakable:Destroy()
						Util.playAction("Positive")
						return {
							Text = { "It should be open now, good luck in there." }
						}
					end
				}
			}
		end

		if v2 ~= "opened" then
			return {
				Text = {
					"Have you seen the entrance behind this building? It feels cursed...",
					"You're not ready to go in there yet."
				}
			}
		end

		pcall(function()
			workspace.Map.Turtle.Cursed.Breakable:Destroy()
		end)
		Util.playAction("Positive")
		return {
			Text = { "It should be open now, good luck in there." }
		}
	end
}
DialoguesList.KilledIceBoss = {
	Title = "Ice Admiral",
	Get = function(_)
		return {
			Text = { "Well, I lost. It happens to the best of us. I'm assuming you were sent here because of my little encounter with Swan right?" },
			Option1 = {
				Label = "Exactly",
				Text = {
					"I cannot say that this is the correct way. Justice changes based on your perspective. But you have to believe me when I tell you I did not break out Swan. On the contrary, I was trying to stop him.",
					"You see, it seems like my old 'friend', the Magma Admiral, made a deal with the Dragon Emperor to stage Swan's escape when in reality he was just allowed to walk free.",
					"The Dragon Emperor has a business making artificial blox fruits known, and Swan happened to be in charge of the operation.",
					"Hence, he threatened my friend with war if he didn't free Swan and return him to his home in the Kingdom of Rose. The Magma Admiral decided that it was not worth the casualties so he agreed to free Swan.",
					"When I found out about this, I tried to stop Swan from going to the second sea, but as it so happens his blox fruit allows him to travel at high speeds through the air using strings.",
					"If you wanna help bring justice and take down Swan you're gonna have to go into the second sea and find him... He will most likely be hiding as he knows that the revolutionary army is trying to find him.",
					"They want to make him pay for his tyranny now that the marines failed to keep him restrained.",
					"[Talk to the Detective again.]<AnimateYield=2>"
				}
			}
		}
	end
}
DialoguesList.KilledIndraBoss = {
	Title = "Mental Message",
	Get = function(_)
		return {
			Text = { [[
<Color=Yellow>You've got mail!<Color=/>
New message from: King Red Head AKA mygame43.]] },
			Option1 = {
				Label = "Read",
				Text = { [[
My dear friend,
This is a mental message.
I've been sealed by rip_indra in the third sea. I need your help ASAP, please come save me.
XOXO, King Red Head AKA mygame43 (Owner)]], "[Talk to <Mr. Captain> at <Green Zone>.]<AnimateYield=2>" }
			}
		}
	end
}
DialoguesList.SealedKing = require(script.NPCs.SealedKing)
DialoguesList.FossilExpert = {
	Title = "Fossil Expert",
	Get = function(_)
		local function craft(p)
			local v2 = remoteFunction2:InvokeServer("Check", p)

			if not v2 then
				return {
					Text = { "..." }
				}
			end

			Util.promptCraftAndWaitForGuiToClose(v2.Required, v2.Result, v2.ResultStats)
			return {
				Text = { "..." }
			}
		end

		local function craftList()
			local v2 = {
				{ "T-Rex Skull", "TRexSkull" },
				{ "Dino Hood", "DinoHood" }
			}
			local result = {
				Text = { "Select a recipe." }
			}

			for i = 1, #v2 do
				local v3 = i
				result["Option" .. i] = {
					Label = v2[i][1],
					JumpTo = function()
						return (craft(v2[v3][2]))
					end
				}
			end

			return result
		end

		return {
			Text = { "Digging for fossils, or just wasting my time? If you can bring me the right bones, I might just whip up some prehistoric gear for you." },
			Option1 = {
				Label = "Craft",
				JumpTo = function()
					return (craftList())
				end
			}
		}
	end
}
DialoguesList.SharkHunter = {
	Title = "Shark Hunter",
	Get = function(_)
		local function craft(p)
			local v2 = remoteFunction2:InvokeServer("Check", p)

			if not v2 then
				return {
					Text = { "..." }
				}
			end

			Util.promptCraftAndWaitForGuiToClose(v2.Required, v2.Result, v2.ResultStats)
			return {
				Text = { "..." }
			}
		end

		local function craftList()
			local v2 = {
				{ "Tooth Necklace", "ToothNecklace" },
				{ "Terror Jaw", "TerrorJaw" },
				{ "Monster Magnet", "SharkAnchor" }
			}
			local v3 = remoteFunction2:InvokeServer("PossibleHardcode", "SharkAnchor")
			local result = {
				Text = { "Select a recipe." }
			}

			for i = 1, #v2 do
				local v4 = i ~= #v2 or v3
				local v5 = i
				result["Option" .. i] = {
					Label = v4 ~= true and "LOCKED" or v2[i][1],
					JumpTo = function()
						if v4 == true then
							return (craft(v2[v5][2]))
						end

						Util.playAction("Negative")
						return {
							Text = { "You lack the mastery to create this item. Come back once you've crafted the first two items." }
						}
					end
				}
			end

			return result
		end

		return {
			Text = { "Lookin' for trouble, or you gonna keep botherin' me? If you can create these two accessories, I've got something for you." },
			Option1 = {
				Label = "Craft",
				JumpTo = function()
					return (craftList())
				end
			}
		}
	end
}
DialoguesList.BeastHunter = {
	Title = "Beast Hunter",
	Get = function(_)
		local function craft(p)
			local v2 = remoteFunction2:InvokeServer("Check", p)

			if not v2 then
				return {
					Text = { "..." }
				}
			end

			Util.promptCraftAndWaitForGuiToClose(v2.Required, v2.Result, v2.ResultStats)
			return {
				Text = { "..." }
			}
		end

		local function craftList()
			local v2 = {
				{ "Leviathan Crown", "LeviathanCrown" },
				{ "Leviathan Shield", "LeviathanShield" },
				{ "Beast Hunter", "LeviathanBoat" }
			}
			local result = {
				Text = { "Select a recipe." }
			}

			for i = 1, #v2 do
				local v3 = i
				result["Option" .. i] = {
					Label = v2[i][1],
					JumpTo = function()
						return (craft(v2[v3][2]))
					end
				}
			end

			return result
		end

		return {
			Text = { "You seem like someone who knows their way between a batch of wood and a toolkit! Try making these, if you can handle it." },
			Option1 = {
				Label = "Craft",
				JumpTo = function()
					return (craftList())
				end
			}
		}
	end
}

local function promptCraftAndWaitForGuiToCloseWithCleanup(object, required, result, resultStats)
	local craft = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Craft")

	if not DialogueController.Active then
		return false
	end

	local flag = false
	local maid = object:getMaid()

	function maid.CloseCraftMenu()
		if flag then
			return
		end

		flag = true
		CraftWindow:Close()
	end

	CraftWindow:Open("NPC", required, result, resultStats)

	if not DialogueController.Active then
		CraftWindow:Close()
	end

	while craft.Enabled do
		if DialogueController.Active then
			task.wait()
		else
			maid.CloseCraftMenu()
			break
		end
	end

	flag = true
	maid.CloseCraftMenu = nil
	return DialogueController.Active
end

local v2 = DialogueController.new()
v2:setTitle("Dragon Talon Sage")
local v3 = {
	{ "Common", "CommonScroll", "Common Scroll" },
	{ "Rare", "RareScroll", "Rare Scroll" },
	{ "Legendary", "LegendaryScroll", "Legendary Scroll" },
	{ "Mythical", "MythicalScroll", "Mythical Scroll" }
}

local function findEnchantItem(p: string)
	local localPlayer = game.Players.LocalPlayer
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if tool and tool.ToolTip == p then
		return tool
	end

	for _, tool2 in localPlayer.Backpack:GetChildren() do
		if tool2:IsA("Tool") and (tool2.ToolTip == p or tool2.Name == p and tool2.ToolTip == "JobTool") then
			return tool2
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideDialogueForMenu()
	DialogueController.hideFrame()
end

local function waitForEnchantMenuToClose(object, object2, name: string)
	local enchant = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Popups"):WaitForChild("EnchantUI"):WaitForChild("Enchant")

	if not DialogueController.Active then
		object:close()
		return
	end

	local flag = false
	local maid = object2:getMaid()

	function maid.CloseEnchantMenu()
		if flag then
			return
		end

		flag = true
		enchant:SetAttribute("CurrentItem", false)
	end

	enchant:SetAttribute("CurrentItem", name)

	if not DialogueController.Active then
		enchant:SetAttribute("CurrentItem", false)
	end

	repeat
		task.wait()
	until not enchant:GetAttribute("CurrentItem")

	flag = true
	maid.CloseEnchantMenu = nil
end

local function buildEnchantResultPage(object, object2, p: string)
	local enchantItem = findEnchantItem(p)

	if enchantItem then
		local v4

		if Flags.ENCHANT_USES_NEW_SERVICE then
			v4 = remoteFunction3:InvokeServer("Check1", enchantItem)
		else
			v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("EnchantItem", "Check1", enchantItem)
		end

		if not DialogueController.Active then
			object:close()
		elseif v4 == "low" then
			Util.playAction("Negative")
			object:addText("Your <" .. enchantItem.Name .. "> is too weak, it would break if I <Color=Purple>enchanted<Color=/> it. Perhaps try upgrading it first.")
		else
			if v4 == true then
				if DialogueController.Active then
					hideDialogueForMenu() -- equivalent call inferred; original call site unknown
					waitForEnchantMenuToClose(object, object2, enchantItem.Name)
				else
					object:close()
					return
				end
			end

			object:close()
		end
	else
		Util.playAction("Negative")
		object:addText("Where's the item? Please equip a " .. p .. " first.")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addEnchantOption(object, p: string)
	object:addOptionType("Chat", function(object2)
		object2:setText(p)
		object2:jumpToPage(function(p2)
			buildEnchantResultPage(p2, object, p)
		end)
	end)
end

local function buildEnchantListPage(object)
	object:addText("I can help you with <Color=Purple>item enchantments<Color=/>. Please select a weapon type.")
	addEnchantOption(object, "Sword") -- equivalent call inferred; original call site unknown
	addEnchantOption(object, "Gun") -- equivalent call inferred; original call site unknown
	local JobsReplicated = require(game.ReplicatedStorage.JobsReplicated)
	local equippedJobToolOnCharacterOrInBackpack = JobsReplicated.GetEquippedJobToolOnCharacterOrInBackpack()

	if equippedJobToolOnCharacterOrInBackpack then
		addEnchantOption(object, equippedJobToolOnCharacterOrInBackpack.Name) -- equivalent call inferred; original call site unknown
	end
end

local function buildCraftResultPage(object, object2, p: string)
	local v4 = remoteFunction2:InvokeServer("Check", p)

	if v4 then
		if DialogueController.Active then
			hideDialogueForMenu() -- equivalent call inferred; original call site unknown
			promptCraftAndWaitForGuiToCloseWithCleanup(object2, v4.Required, v4.Result, v4.ResultStats)
		else
			object:close()
			return
		end
	end

	object:close()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildLockedScrollPage(object, p)
	Util.playAction("Negative")
	object:addText("You lack the mastery to create this item. Come back once you've crafted " .. p.Remaining .. " more <Color=Yellow>" .. p.Item .. "s<Color=/>.")
end

local buildScrollListPage

buildScrollListPage = function(object, value: number?)
	local v4 = remoteFunction2:InvokeServer("Progression", "Scroll")

	if not DialogueController.Active then
		object:close()
		return
	end

	warn(v4)
	local v5 = value or 1
	local v6 = math.ceil(#v3 / 2)
	local v7 = (v5 - 1) * 2 + 1
	local v8 = math.min(v7 + 1, #v3)
	object:addText("Select a Scroll type. (" .. v5 .. "/" .. v6 .. ")")

	for i = v7, v8 do
		local v9 = v3[i]
		local v11 = v4[v9[3]]
		object:addOptionType("Chat", function(object2)
			object2:setText(v11 ~= true and "LOCKED" or v9[1])
			object2:jumpToPage(function(object3)
				if v11 == true then
					buildCraftResultPage(object3, object, v9[2])
					return
				end

				buildLockedScrollPage(object3, v11) -- equivalent call inferred; original call site unknown
			end)
		end)
	end

	if v5 < v6 then
		object:addOptionType("Chat", function(object2)
			object2:setText("Next")
			object2:jumpToPage(function(p)
				buildScrollListPage(p, v5 + 1)
			end)
		end)
	elseif v6 > 1 then
		object:addOptionType("Chat", function(object2)
			object2:setText("Back")
			object2:jumpToPage(function(p)
				buildScrollListPage(p, 1)
			end)
		end)
	end
end

local function addMainOptions(object, flag: boolean)
	object:addOptionType("Chat", function(object2)
		object2:setText("Enchant")
		object2:jumpToPage(buildEnchantListPage)
	end)

	if flag then
		object:addOptionType("Chat", function(object2)
			object2:setText("Craft")
			object2:jumpToPage(function(p)
				buildScrollListPage(p, 1)
			end)
		end)
	end
end

v2:addPage("Main", function(object)
	local currentRealmDifficultyAsync = Realm.getCurrentRealmDifficultyAsync()

	if currentRealmDifficultyAsync < 3 and not remoteFunction4:InvokeServer("RECEIVED_COMMON_SCROLL_FROM_SAGE_IN_SEA_1") and Flags.ENCHANT_USES_NEW_SERVICE then
		task.spawn(function()
			remoteFunction3:InvokeServer("ReceiveScroll")
		end)
		object:addText("Don't think we've met before. Here, take this <Color=Yellow>Common Scroll<Color=/> I found on the beach earlier.")
		object:addText("Once you've upgraded your weapons, you can enchant them with these scrolls. You can even enchant Fishing Rods!")
		addMainOptions(object, currentRealmDifficultyAsync > 1)
	else
		object:addText("Greetings.. What interests you today?")
		addMainOptions(object, true)
	end
end)
DialoguesList.Scroll = v2:build()
DialoguesList.Spy = {
	Title = "Spy",
	Get = function(_)
		return {
			Text = { "Hey, curious about the Leviathan?" },
			Option1 = {
				Label = "Origin",
				Text = {
					"So you wish to learn more about its origin..? Here's what I heard:",
					"Long ago, the Leviathan began as a tiny whelping born from primordial essence in a world gripped by an eternal winter.",
					"A millennia passed, and the 10,000-year Solstice's radiant energy warmed the planet, breaking the icy grasp of winter.",
					"Yet, this whelping remained hidden in the ocean's darkest depths, honing its frosty abilities amidst other oceanic creatures.",
					"Now, with the Red King's release, it emerges to fulfill a chilling destiny, freezing the once-thawed oceans at the Red King's command."
				}
			},
			Option2 = {
				Label = "Clues",
				Text = { "" },
				JumpTo = function()
					local v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("InfoLeviathan", "1")

					if v4 == -1 then
						Util.playAction("Negative")
						return {
							Text = { "I don't know anything yet." }
						}
					end

					local v5 = {
						"I haven't heard a thing, mate. It's quiet as a ghost ship out there.",
						"Some citizens claim they heard something strange, I doubt it though..",
						"I heard it's been a bit chilly outside. That's a bit strange..",
						"It's just downright freezing out! What's with these ominous clouds? Something's happening..",
						"The Leviathan is out there! Go find it before it causes more destruction."
					}
					local v6 = {
						Text = { v5[v4] }
					}

					if v4 < 5 then
						v6.Option1 = {
							Label = "Bribe",
							Text = { "You're itching to know more? I'll see what I can do... for an easy <Color=Purple>ƒ1,500<Color=/>." },
							Option1 = {
								Label = "Say less",
								Text = { "" },
								JumpTo = function()
									local v7 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("InfoLeviathan", "2")

									if v7 == 0 then
										Util.playAction("Negative")
										return {
											Text = { "[Not enough fragments.]" }
										}
									end

									Util.playAction("Positive")
									return {
										Text = { "Say less. This is what I've learned:", v5[v7] }
									}
								end
							}
						}
					end

					return v6
				end
			}
		}
	end
}
DialoguesList.DracoV4Upgrader = require(script.NPCs.DracoV4Upgrader)
DialoguesList.RaceV4Upgrader = require(script.NPCs.RaceV4Upgrader)
DialoguesList.Blacksmith = require(script.NPCs.Blacksmith)
DialoguesList.TempleTeleport = {
	Title = "Mysterious Force",
	Get = function(_)
		if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4Progress", "Check") >= 2 then
			return {
				Text = { "You feel a force here... A remnant of the past." },
				Option1 = {
					Label = "Use it",
					JumpTo = function()
						if game.ReplicatedStorage.MapStash:FindFirstChild("Temple of Time") then
							game.ReplicatedStorage.MapStash["Temple of Time"].Parent = workspace.Map
							game.Players.LocalPlayer.CharacterAdded:Once(function()
								if workspace:GetAttribute("RestartingTemple") then
									return
								end

								workspace:SetAttribute("RestartingTemple", true)
								task.delay(0.1, function()
									workspace:SetAttribute("RestartingTemple", nil)
								end)

								if workspace.Map:FindFirstChild("Temple of Time") then
									workspace.Map["Temple of Time"].Parent = game.ReplicatedStorage.MapStash
								end
							end)
						end

						return {
							Text = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4Progress", "Teleport") or { "..." }
						}
					end
				}
			}
		end

		return {
			Text = { "There's something here, but you can't quite place it." }
		}
	end
}
DialoguesList.TempleTeleportBack = {
	Title = "Mysterious Force",
	Get = function(_)
		if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4Progress", "Check") >= 2 then
			return {
				Text = { "You feel a force here..." },
				Option1 = {
					Label = "Use it",
					JumpTo = function()
						return {
							Text = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4Progress", "TeleportBack") or { "..." }
						}
					end
				}
			}
		end

		return {
			Text = { "There's something here, but you can't quite place it." }
		}
	end
}
DialoguesList.KilledSpringBoss = {
	Title = "Jeremy",
	Get = function(_)
		return {
			Text = { "Agh... you have defeated me." },
			Option1 = {
				Label = "Now speak!",
				Text = {
					"Very well... I was brought into the Swan Pirates family and given the position of Colosseum Director.",
					"I have been rigging the events so that my fighters always win.",
					"When you find Master Swan... Tell him I have failed him."
				}
			}
		}
	end
}
DialoguesList.KilledCitizenBoss = {
	Title = "...",
	Get = function(_)
		return {
			Text = { "I've been... defeated. I accept my defeat." },
			Option1 = {
				Label = "It's normal",
				Text = {
					"You may have been able to defeat me, but you're never gonna be able to defeat that man...",
					"He will avenge me, that man..."
				}
			}
		}
	end
}
DialoguesList.PrisonersThanks = {
	Title = "Prisoners",
	Get = function(_)
		return {
			Text = {
				"<AnimateYield=3>WE ARE FREE AT LAST!",
				"Please sir, take this helmet as a token of our appreciation."
			}
		}
	end
}
DialoguesList.CitizenThanks = {
	Title = "Citizen",
	Get = function(_)
		return {
			Text = { "Seems that you have found it. Great work!" }
		}
	end
}
DialoguesList.Exploiter = {
	Title = "EXPLOITS DETECTED.",
	Get = function(self)
		return {
			Text = { "You were caught <Color=Red>EXPLOITING/HACKING<Color=/> and have been punished.<AnimateYield=3> YOUR DATA HAS BEEN <Color=Red>ALTERED<Color=/> BUT NOT RESET. <AnimateYield=3> If you exploit again, you will be <Color=Red>PERMANENTLY BANNED<Color=/> from the game!<AnimateYield=7> " },
			Option1 = {
				Label = "Português",
				Text = { "Você foi pego <Color=Red>TRAPACEANDO<Color=/> e foi punido. SUA DATA FOI <Color=Red>ALTERADA<Color=/> MAS NÃO APAGADA. se você trapacear alguém você será <Color=Red>PERMANENTEMENTE BANIDO<Color=/> do jogo!" },
				Option1 = {
					Label = "English",
					JumpTo = function()
						return self:Get()
					end
				}
			},
			Option2 = {
				Label = "Español",
				Text = { "Has sido atrapado y castigado por hacer <Color=Red>TRAMPA<Color=/>. SUS DATOS HAN SIDO <Color=Red>ALTERADOS<Color=/> PERO NO BORRADOS. ¡Si haces trampa nuevamente, serás <Color=Red>PERMANENTEMENTE BANEADO<Color=/> del juego!" },
				Option1 = {
					Label = "English",
					JumpTo = function()
						return self:Get()
					end
				}
			},
			Option3 = {
				Label = "Thai",
				Text = { "Unsupported. Please use Google Translate." },
				Option1 = {
					Label = "English",
					JumpTo = function()
						return self:Get()
					end
				}
			}
		}
	end
}
DialoguesList.HolidayGiftToolActivated = Library.useTool("HolidayGift")
DialoguesList.PotionToolActivated = Library.useTool("Potion")
DialoguesList.FoodToolActivated = Library.useTool("Food")
DialoguesList.EatFruit = require(script.NPCs.EatFruit)
DialoguesList.EatPlasticFruit = require(script.NPCs.EatPlasticFruit)
DialoguesList.DoghouseSpike = {
	Title = "Wenlock",
	Get = function(_)
		return {
			Text = { "WOOF WOOF. YO BRO, wanna buy a physical Rocket fruit for <Color=Green>97 Robux<Color=/>? You can trade it to that noob scientist for a Special Microchip." },
			Option1 = {
				Label = "Sure",
				JumpTo = function()
					game.ReplicatedStorage.Remotes.CommF_:InvokeServer("buyRobuxShop", "Physical Rocket Fruit")
					return {
						Text = { "Ayt." }
					}
				end
			}
		}
	end
}
DialoguesList.SweetChalice = {
	Title = "Sweet Crafter",
	Get = function(_)
		return {
			Text = { "You think you can handle the <Color=Red>Dough King<Color=/>?" },
			Option1 = {
				Label = "Yes",
				JumpTo = function()
					return {
						Text = { "Very well. I can exchange a God's Chalice and 10 Conjured Cocoa for something worthy of him." },
						Option1 = {
							Label = "Trade",
							JumpTo = function()
								return {
									Text = { game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SweetChaliceNpc") or "..." }
								}
							end
						}
					}
				end
			}
		}
	end
}
DialoguesList.CakeScientist = require(script.NPCs.CakeScientist)
DialoguesList.CakeSpawner = {
	Title = "drip_mama",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Hey",
				JumpTo = function()
					local v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner", true) or "Error."
					local v5 = {
						Text = { v4 }
					}

					if v4:find("open the portal now") then
						v5.Option1 = {
							Label = "Yes",
							JumpTo = function()
								return {
									Text = { game.ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner") or "Error." }
								}
							end
						}
					end

					return v5
				end
			}
		}
	end
}
DialoguesList.Gravestone = {
	Title = "Gravestone",
	Get = function(_)
		return {
			Text = { "[You see a gravestone.]" },
			Option1 = {
				Label = "Try luck",
				JumpTo = function()
					return {
						Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer("gravestoneEvent", 1)) }
					}
				end
			},
			Option2 = {
				Label = "Pray",
				JumpTo = function()
					local v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("gravestoneEvent", 2)

					if v4 == true then
						return {
							Text = { "[Your prayers have been answered!]", "... Would you like to play a game?" },
							Option1 = {
								Label = "Yes",
								JumpTo = function()
									local Effect = require(game.ReplicatedStorage.Effect)
									Effect.new("BlindCam"):replicate({
										Color = Color3.new(0.03, 0.03, 0.03),
										Duration = 2,
										Fade = 0.25,
										ZIndex = -10
									})
									local Sound = require(game.ReplicatedStorage.Util.Sound)
									Sound:Play("Thunder", workspace.CurrentCamera.CFrame.p)
									wait(0.25)
									return {
										Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
												"gravestoneEvent",
												2,
												true
											)) }
									}
								end
							}
						}
					end

					return {
						Text = { v4 }
					}
				end
			}
		}
	end
}
DialoguesList.SkeletonMachine = {
	Title = "Weird Machine",
	Get = function(_)
		local v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("soulGuitarBuy", true)

		if v4 then
			return {
				Text = { v4 }
			}
		end

		return {
			Text = { [[
Would you like to craft <Color=Yellow><Skull Guitar><Color=/> for:
- 500 Bones
- 250 Ectoplasm
- 1 Dark Fragment
This will cost you <Color=Purple>ƒ5,000<Color=/>.]] },
			Option1 = {
				Label = "Craft",
				JumpTo = function()
					return {
						Text = { (game.ReplicatedStorage.Remotes.CommF_:InvokeServer("soulGuitarBuy")) }
					}
				end
			}
		}
	end
}
DialoguesList.Robotmega = require(script.NPCs.Robotmega)
DialoguesList.SickScientist = require(script.NPCs.SickScientist)
DialoguesList.MysteriousScientist = require(script.NPCs.MysteriousScientist)
DialoguesList.Cupid_ValentineDailyQuests = require(script.NPCs.Cupid_ValentineDailyQuests)
DialoguesList.MysteriousEntity = require(script.NPCs.MysteriousEntity)
local v4 = DialogueController.new()
v4:setTitle("Titles Specialist (Axiore)")

local function closeTitlesMenu(titlesMenu)
	local closed = titlesMenu:FindFirstChild("Closed")
	local flag = false
	local eventConnection = nil

	if closed and closed:IsA("BindableEvent") then
		eventConnection = closed.Event:Connect(function()
			flag = true

			if eventConnection then
				eventConnection:Disconnect()
				eventConnection = nil
			end
		end)
	end

	local ROOT = titlesMenu:FindFirstChild("ROOT")
	local close

	if ROOT then
		close = ROOT:FindFirstChild("close", true)
	else
		close = nil
	end

	if close and close:IsA("GuiButton") then
		pcall(function()
			close:Activate()
		end)
	end

	task.delay(0.1, function()
		if eventConnection then
			eventConnection:Disconnect()
			eventConnection = nil
		end

		if flag then
			return
		end

		titlesMenu.Enabled = false

		if closed and closed:IsA("BindableEvent") then
			closed:Fire()
		end
	end)
end

local function openTitlesMenu(object, object2)
	hideDialogueForMenu() -- equivalent call inferred; original call site unknown
	local titlesMenu = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TitlesMenu")

	if not DialogueController.Active then
		object:close()
		return
	end

	titlesMenu.Enabled = true
	local flag = false
	local maid = object2:getMaid()

	function maid.CloseTitlesMenu()
		if flag then
			return
		end

		flag = true
		closeTitlesMenu(titlesMenu)
	end

	titlesMenu.Open:Fire()
	titlesMenu.Closed.Event:Wait()
	flag = true
	maid.CloseTitlesMenu = nil
	object:close()
end

v4:addPage(function(object)
	object:addText("Bro, would you like to see your list of titles?")
	object:addOptionType("Chat", function(object2)
		object2:setText("Sure")
		object2:jumpToPage(function(p)
			openTitlesMenu(p, object)
		end)
	end)
end)
DialoguesList.TitlesSpecialist = v4:build()
local v5 = DialogueController.new()
v5:setTitle("Awakenings Expert")

local function openAwakeningToggler(object, object2)
	local v6 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("AwakeningChanger", "Check")

	if not DialogueController.Active then
		object:close()
	elseif v6 then
		hideDialogueForMenu() -- equivalent call inferred; original call site unknown
		local awakeningToggler = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Popups"):WaitForChild("AwakeningTogglerUI"):WaitForChild("AwakeningToggler")

		if not DialogueController.Active then
			object:close()
			return
		end

		local flag = false
		local maid = object2:getMaid()

		function maid.CloseAwakeningToggler()
			if flag then
				return
			end

			flag = true
			awakeningToggler.Visible = false
		end

		awakeningToggler.Visible = true
		awakeningToggler:GetPropertyChangedSignal("Visible"):Wait()
		flag = true
		maid.CloseAwakeningToggler = nil
		object:close()
	else
		Util.playAction("Negative")
		object:addText("Come back to me when you awaken your fruit.")
	end
end

v5:addPage(function(object)
	object:addText("Greetings, is your fruit awakened?")
	object:addOptionType("Chat", function(object2)
		object2:setText("Talk")
		object2:jumpToPage(function(p)
			openAwakeningToggler(p, object)
		end)
	end)
end)
DialoguesList.AwakeningsExpert = v5:build()
DialoguesList.EnhancementEditor = require(script.NPCs.EnhancementEditor)
DialoguesList.rip_indra = {
	Title = "rip_indra",
	Get = function(_)
		return {
			Text = { "Hi X." },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ToggleDarkYoru", "Check") then
						return {
							Text = { "What do you wish to do with your Dark Blade skin?" },
							Option1 = {
								Label = "Enable",
								JumpTo = function()
									game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ToggleDarkYoru", "Enable")
									Util.playAction("Positive")
									return {
										Text = { "Alright. It's done." }
									}
								end
							},
							Option2 = {
								Label = "Disable",
								JumpTo = function()
									game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ToggleDarkYoru", "Disable")
									Util.playAction("Positive")
									return {
										Text = { "Alright. It's done." }
									}
								end
							}
						}
					end

					Util.playAction("Negative")
					return {
						Text = { "I'm busy!" }
					}
				end
			}
		}
	end
}
DialoguesList.Halloween1 = require(script.NPCs.Halloween1)
DialoguesList.Xmas1 = {
	Title = "Magic Elf",
	Get = function(_)
		return {
			Text = { "Welcome to my shop! Ready to make a deal?" },
			Option1 = {
				Label = "Yeah",
				JumpTo = function()
					return Library.candiesTrader(1)
				end
			}
		}
	end
}
DialoguesList.Xmas2 = {
	Title = "Greedy Elf",
	Get = function(_)
		return {
			Text = { "Yo. Got any candies for me?" },
			Option1 = {
				Label = "Maybe",
				JumpTo = function()
					return Library.candiesTrader(2)
				end
			}
		}
	end
}
DialoguesList.Xmas3 = {
	Title = "Santa Claws",
	Get = function(_)
		return {
			Text = { "<AnimateStyle=Wiggle><Color=Green>Merry<Color=/> <Color=Red>Christmas!<Color=/><AnimateStyle=/> Are you interested in trading for any of my <Color=Yellow>LIMITED TIME<Color=/> special items?" },
			Option1 = {
				Label = "Let's see",
				JumpTo = function()
					return Library.candiesTrader(3)
				end
			}
		}
	end
}
DialoguesList.Xmas4 = {
	Title = "Cousin Remastered",
	Get = function(_)
		return {
			Text = { "Hi..." },
			Option1 = {
				Label = "Alright",
				JumpTo = function()
					return Library.candiesTrader(4)
				end
			}
		}
	end
}
DialoguesList.CelebrationGacha = {
	Title = "Party Gacha",
	Get = function(_)
		return {
			Text = { "..." }
		}
	end
}
DialoguesList.RandomFruitSeller = require(script.NPCs.RandomFruitSeller)
DialoguesList.EliteHunter = {
	Title = "Elite Hunter",
	Get = function(_)
		return {
			Text = { "Aye aye aye, looking for any difficult tasks?" },
			Option1 = {
				Label = "Yeah",
				JumpTo = function()
					local success, result = pcall(function()
						return game.ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter")
					end)
					return {
						Text = { not success and "[An error has occured. Please try again.]" or result }
					}
				end
			},
			Option2 = {
				Label = "Progress",
				JumpTo = function()
					local v6 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter", "Progress")
					Util.playAction("Explain")
					return {
						Text = { "So far, you have defeated " .. v6 .. " elite enemies for me." }
					}
				end
			}
		}
	end
}
DialoguesList.PlayerHunter = {
	Title = "Player Hunter",
	Get = function(_)
		return {
			Text = { "Yo yo yo, looking for any PvP tasks?" },
			Option1 = {
				Label = "Yeah",
				JumpTo = function()
					local success, result = pcall(function()
						return game.ReplicatedStorage.Remotes.CommF_:InvokeServer("PlayerHunter")
					end)
					return {
						Text = { not success and "[An error has occured. Please try again.]" or result }
					}
				end
			},
			Option2 = {
				Label = "Progress",
				JumpTo = function()
					local v6 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("PlayerHunter", "Progress")

					if v6 and typeof(v6) == "string" and v6:find("public server") then
						return {
							Text = { v6 }
						}
					end

					Util.playAction("Explain")
					return {
						Text = { "So far, you have defeated " .. v6 .. " players for me." }
					}
				end
			}
		}
	end
}
DialoguesList.EctoplasmChecker = {
	Title = "Guashiem",
	Get = function(_)
		return {
			Text = { "Would you like to know how much <Color=Orange>Ectoplasm<Color=/> you have collected?" },
			Option1 = {
				Label = "Sure",
				JumpTo = function()
					local v6 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Ectoplasm", "Check")
					Util.playAction("Explain")
					return {
						Text = { "[You currently have <Color=Orange>" .. (v6 or 0) .. " Ectoplasm<Color=/>.]" }
					}
				end
			}
		}
	end
}
DialoguesList.ClockRoomExit = {
	Title = "???",
	Get = function(_)
		return {
			Text = { "Are you sure you wish to leave? You cannot come back without passing the trials again." },
			Option1 = {
				Label = "Yes",
				JumpTo = function()
					game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ExitClockRoom")
					return {
						Text = { "..." }
					}
				end
			}
		}
	end
}
DialoguesList.Ectoplasm1 = {
	Title = "El Rodolfo",
	Get = function(_)
		return {
			Text = { "...!" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return Library.ectoplasmTrader(1)
				end
			}
		}
	end
}
DialoguesList.Ectoplasm2 = {
	Title = "El Perro",
	Get = function(_)
		return {
			Text = { "...!" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return Library.ectoplasmTrader(2)
				end
			}
		}
	end
}
DialoguesList.Ectoplasm3 = {
	Title = "El Admin",
	Get = function(_)
		return {
			Text = { "...!" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return Library.ectoplasmTrader(3)
				end
			}
		}
	end
}
DialoguesList.GhoulGiver = {
	Title = "Experimic",
	Get = function(_)
		return {
			Text = { "Ahh... Guashiem..." },
			Option1 = {
				Label = "What?",
				JumpTo = function()
					return Library.ectoplasmTrader(4)
				end
			}
		}
	end
}
DialoguesList.junior = {
	Title = "arlthmetic A.K.A. Junior J. Five",
	Get = function(_)
		return {
			Text = { "here to make a bargain i see.. make yourself at home!" },
			Option1 = {
				Label = "Talk",
				JumpTo = function()
					return ((function()
						if game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Microchip", "1") then
							return {
								Text = { "want to buy a microchip for <Color=Purple>ƒ1000<Color=/>? just so you know, this will turn out much better for me than it will for you. <AnimateYield=0.5> <Color=Red><AnimateStyle=Wiggle><AnimateStepFrequency=2>no refunds<AnimateStyle=/><AnimateStepFrequency=/><Color=/>!" },
								Option1 = {
									Label = "Trade",
									Text = { "" },
									JumpTo = function()
										local v6 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
											"BlackbeardReward",
											"Microchip",
											"2"
										)

										if v6 == 1 then
											Util.playAction("Positive")
											return {
												Text = { "[Trade completed.]" }
											}
										elseif v6 == 0 then
											Util.playAction("Negative")
											return {
												Text = { "[Not enough fragments.]" }
											}
										end

										if v6 ~= 2 then
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

						Util.playAction("Negative")
						return {
							Text = { "no fragments? pfft. have you not been taught any manners bro?" }
						}
					end)())
				end
			}
		}
	end
}
DialoguesList.LoveLetter1 = {
	Title = "Love Letter",
	Get = function(_)
		return {
			Text = { "'For: master'" },
			Option1 = {
				Label = "Read",
				JumpTo = function()
					return Library.loveLetter(1)
				end
			}
		}
	end
}
DialoguesList.LoveLetter2 = {
	Title = "Love Letter",
	Get = function(_)
		return {
			Text = { "'For: master'" },
			Option1 = {
				Label = "Read",
				JumpTo = function()
					return Library.loveLetter(2)
				end
			}
		}
	end
}
DialoguesList.LoveLetter3 = {
	Title = "Love Letter",
	Get = function(_)
		return {
			Text = { "'For: master'" },
			Option1 = {
				Label = "Read",
				JumpTo = function()
					return Library.loveLetter(3)
				end
			}
		}
	end
}
DialoguesList.Indra = require(script.NPCs.Indra)
DialoguesList.ShipwrightNPC = {
	Title = "Shipwright Teacher",
	Get = function(_)
		return Library.subclassNPC("Shipwright")
	end
}
DialoguesList.HelmsmanNPC = {
	Title = "Helmsman NPC",
	Get = function(_)
		return Library.subclassNPC("Helmsman")
	end
}
DialoguesList.MergeNPC = require(script.NPCs.MergeNPC)
DialoguesList.ReforgeNPC = require(script.NPCs.ReforgeNPC)
DialoguesList.BlueMoonShrine = {
	Title = "Kitsune Shrine",
	Get = function(_)
		return {
			Text = { "..." },
			Option1 = {
				Label = "Touch Statue",
				JumpTo = function()
					local v6 = Lighting:GetAttribute("MoonPhase") == 5
					local isBlueMoon = Lighting:GetAttribute("IsBlueMoon")
					local blueMoonEnded = Lighting:GetAttribute("BlueMoonEnded")

					if v6 and not isBlueMoon then
						remoteEvent:FireServer()
						return {
							Text = {
								"A blue moon awakens...",
								"Go forth and collect Azure Embers. Bring them back to me before the Blue Moon fades away, or they will fade with it."
							}
						}
					end

					if blueMoonEnded then
						return {
							Text = { "You call to the moon, but the moon doesn't answer..." }
						}
					end

					return {
						Text = { "..." }
					}
				end
			}
		}
	end
}
DialoguesList.BlueMoonShrinePray = {
	Title = "Kitsune Shrine",
	Get = function(_)
		return {
			Text = { "Do you offer your Azure Embers to the Shrine?" },
			Option1 = {
				Label = "Submit",
				JumpTo = function()
					return {
						Text = { remoteFunction:InvokeServer() or "..." }
					}
				end
			}
		}
	end
}
DialoguesList.DracoStatue = {
	Title = "Statue",
	Get = function(_)
		return {
			Text = {
				"The ancient energies are thick in this place. I can use them to upgrade your race, but you'll need to gather the energy in one place.",
				"When you're ready, the doors will unlock, allowing you to gather relics.",
				"Bring each relic to the top, and place it on an extractor.",
				"When you've collected all the energies, the final door will open for you to leave.",
				"Beware, this place is unstable. The relics can protect you, but they take time to channel the barrier.",
				"Are you ready to begin?"
			},
			Option1 = {
				Label = "Yes",
				JumpTo = function()
					game.ReplicatedStorage.Remotes.DracoTrial:InvokeServer()
					return {
						Text = { "Good luck mortal." }
					}
				end
			}
		}
	end
}
DialoguesList.Barista = {
	Title = "Barista",
	Get = function(_)
		return {
			Text = { "Would you like to view some recipes?" },
			Option1 = {
				Label = "Sure",
				JumpTo = function()
					local JuiceWindow = require(game.ReplicatedStorage.Controllers.UI.JuiceWindow)
					assert(JuiceWindow.IsInitialized, "bad JuiceWindow")

					if JuiceWindow:GetIfCanView() ~= true then
						return {
							Text = { "Sorry, I have nothing for you." }
						}
					end

					JuiceWindow:Open({
						Window = "First",
						Mode = "Bartender"
					})
					JuiceWindow:WaitForClose()
					return {
						Text = { "..." }
					}
				end
			}
		}
	end
}
DialoguesList.RipRecruiter = {
	Title = "Rip Family Recruiter",
	Get = function(_)
		return Library.recruiterDialogue("Rip")
	end
}
DialoguesList.RedRecruiter = {
	Title = "Red Army Recruiter",
	Get = function(_)
		return Library.recruiterDialogue("Red")
	end
}
DialoguesList.HalloweenWitch = {
	Title = "Witch",
	Get = function(_)
		return {
			Text = { "Ah, a fellow troublemaker! Looking to mix up some throwable potions?" },
			Option1 = {
				Label = "Yeah!",
				JumpTo = function()
					if not CraftWindow:IsOpen() then
						CraftWindow:Open("Campfire", {
							Name = "HalloweenCauldron",
							GetAttribute = function(self, p)
								if p == "WhitelistedRecipes" then
									return "Big Head Elixir, Disguise Elixir, Lava Bomb Elixir, Pumpkin Potion, Suspicious Growth Potion, Monster Mash Elixir"
								end
							end
						})
					end
				end
			}
		}
	end
}
DialoguesList.HalloweenGachaDealer = {
	Title = "Haunted Gacha Dealer",
	Get = function(_)
		return {
			Text = { "..." }
		}
	end
}
DialoguesList.AprilFoolsHackerStart = {
	Title = "Luckymaxer",
	Get = function(_)
		local humanoidRootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		humanoidRootPart.Anchored = true
		task.spawn(function()
			while true do
				local Global = require(game.ReplicatedStorage.Global)

				if not Global.DialogueController.Active then
					break
				end

				task.wait(0.1)
			end

			humanoidRootPart.Anchored = false
		end)
		humanoidRootPart.Anchored = true
		return {
			Text = { [[
<Color=Green>> Oh? Another 'hero' enters the terminal?
> You really think you can stop me??<Color=/>]], [[
<Color=Green>> I'm literally editing your character data as we speak;
> You're just a line of code for me to /delete;<Color=/>]] }
		}
	end
}
DialoguesList.AprilFoolsLuckmax = {
	Title = "Luckymaxer",
	Get = function(_)
		return Library.luckymax()
	end
}
DialoguesList.DojoHiddenRoom = {
	Title = "",
	Get = function(p)
		local InstanceWatch = require(game.ReplicatedStorage.Util.InstanceWatch)
		local v6 = assert(
			InstanceWatch.group("Hydra").ObjectsOfType("IslandModel"):first(),
			"IslandModel wasn't found in Hydra"
		)
		local v7

		if workspace:FindFirstChild("HydraIslandClient") then
			v7 = workspace.HydraIslandClient.RemoteFunction:InvokeServer("Interacted")
		end

		if v7 ~= 1 and v7 ~= 2 and v7 ~= 3 and v7 ~= 4 then
			return {
				Text = { "..." }
			}
		end

		if v7 == 3 then
			v6.Island.SpawnHologram()
			return {
				Text = { "Your journey is nearing the end. You must complete the final trial." }
			}
		elseif v7 == 4 then
			return {
				Text = { "..." },
				Option1 = {
					Label = "Archive",
					JumpTo = function()
						v6.Island.SpawnHologram()
						return {
							Text = { "Your journey is nearing the end. You must complete the final trial." }
						}
					end
				},
				Option2 = {
					Label = "Training",
					JumpTo = function()
						return DialoguesList.DracoV4Upgrader.Get(p)
					end
				}
			}
		end
	end
}
DialoguesList.YamaScroll = {
	Title = "Yama Scroll",
	Get = function(p)
		return Library.scroll(p, "Evil")
	end
}
DialoguesList.TushitaScroll = {
	Title = "Tushita Scroll",
	Get = function(p)
		return Library.scroll(p, "Good")
	end
}
DialoguesList.DragonTamer = require(script.NPCs.DragonTamer)
DialoguesList.DojoTrainer = require(script.NPCs.DojoTrainer)
DialoguesList.DragonHunter = require(script.NPCs.DragonHunter)
DialoguesList.SecretSanta = require(script.NPCs.SecretSanta)
DialoguesList.FruitRemover = require(script.NPCs.FruitRemover)
DialoguesList.SecretsMaster = require(script.NPCs.SecretsMaster)
DialoguesList.BuggyQuest1 = Util.generateQuest("BuggyQuest1", {
	NPCName = "Pirate Adventurer"
})
DialoguesList.MarineQuest = Util.generateQuest("MarineQuest", {
	NPCName = "Marine Leader"
})
DialoguesList.BanditQuest1 = Util.generateQuest("BanditQuest1", {
	NPCName = "Bandit Quest Giver"
})
DialoguesList.JungleQuest = Util.generateQuest("JungleQuest", {
	NPCName = "Adventurer"
})
DialoguesList.SnowQuest = Util.generateQuest("SnowQuest", {
	NPCName = "Villager"
})
DialoguesList.DesertQuest = Util.generateQuest("DesertQuest", {
	NPCName = "Desert Adventurer"
})
DialoguesList.SkyQuest = Util.generateQuest("SkyQuest", {
	NPCName = "Sky Adventurer"
})
DialoguesList.MarineQuest2 = Util.generateQuest("MarineQuest2", {
	NPCName = "Marine"
})
DialoguesList.ColosseumQuest = Util.generateQuest("ColosseumQuest", {
	NPCName = "Colosseum Quest Giver"
})
DialoguesList.PrisonerQuest = Util.generateQuest("PrisonerQuest", {
	NPCName = "Jail Keeper"
})
DialoguesList.ImpelQuest = Util.generateQuest("ImpelQuest", {
	NPCName = "Head Jailer"
})
DialoguesList.MagmaQuest = Util.generateQuest("MagmaQuest", {
	NPCName = "The Mayor"
})
DialoguesList.FishmanQuest = Util.generateQuest("FishmanQuest", {
	NPCName = "King Neptune"
})
DialoguesList.SkyExp1Quest = Util.generateQuest("SkyExp1Quest", {
	NPCName = "Mole"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function templeIntelMoment()
	local BonusMomentsController = require(game.ReplicatedStorage.Controllers.BonusMomentsController)
	return BonusMomentsController:GetLoadedMoments()["Temple Intel"]
end

local function templeIntelCompleted()
	local Map = require(game.ReplicatedStorage.Definitions.Map)
	local bonusMoment = Map.getBonusMoment(Map.getIsland(Map.getMap("Sea1"), "SkyArea2"), "Temple Intel")
	local success, result = pcall(function()
		return Net:RemoteFunction("RequestBonusMomentReplication"):InvokeServer({
			Type = "GetMomentProgress"
		})
	end)

	if success then
		if typeof(result) == "table" then
			success = result.Data[Map.getAddress(bonusMoment)] == true
		else
			success = false
		end
	end

	return success
end

local function templeIntelHandIn()
	local templeIntel = templeIntelMoment() -- equivalent call inferred; original call site unknown

	if not templeIntel or templeIntel.Completed or templeIntel:InvokeServer("DeliverIntel") ~= true then
		return nil
	end

	Util.playAction("Positive")
	return { "Hah! Would you look at that.", "Most people who go up there come back as a story." }
end

local function templeIntelOption(object)
	object:addOptionType("Quest", function(object2)
		object2:setText("The old temple")
		object2:jumpToPage(function(object3)
			local v6 = templeIntelMoment() -- equivalent call inferred; original call site unknown

			if v6 and v6.Completed or not v6 and templeIntelCompleted() then
				object3:addText("You already brought that relic down. Once was enough for any lifetime.")
				return
			end

			if not v6 then
				object3:addText("That pile of rocks? Nothing up there but dust and bad weather. Forget it.")
				return
			end

			local v7 = v6:InvokeServer("QuestState")

			if v7 == nil then
				object3:addText("Step closer if you want to talk about the temple.")
			elseif v7 == 3 then
				object3:addText("You already brought that relic down. Once was enough for any lifetime.")
			elseif v7 == 2 then
				local v8 = templeIntelHandIn()

				if not v8 then
					object3:addText("You went in there and walked back out? Let me see it, then.")
					return
				end

				local BonusMomentsGuide = require(game.ReplicatedStorage.BonusMomentsGuide)
				local interactQuestGiver = BonusMomentsGuide.interactQuestGiver("SkyExp2Quest")

				for _, v9 in v8 do
					object3:addText(v9)
				end

				if interactQuestGiver and interactQuestGiver.OpeningDialogue then
					for _, v9 in interactQuestGiver.OpeningDialogue do
						object3:addText(v9)
					end
				end
			else
				if v7 == 1 then
					object3:addText("Still standing here? The temple's not going to empty itself.")
					return
				end

				object3:addText("The old temple, huh. Been up there since before my time. Before anyone's, if you believe the drunks.")
				object3:addText("Story goes the folk who built it left something behind. A relic, cut so clean it doesn't look natural.")
				object3:addText("It floats in a ring of old coils, and it won't come down until every one of them is feeding the next.")
				object3:addText("Every few years someone goes up to take it. They talk big on the way.")
				object3:addText("And then the sky opens on them. Thunder like the place is angry about it.")
				object3:addText("It's a dangerous place. But you don't look like the type that listens.")
				object3:addOptionType("Accept", function(object4)
					object4:setText("I'll get it")
					object4:jumpToPage(function(object5)
						if v6:InvokeServer("AcceptQuest") ~= true then
							object5:addText("...")
							return
						end

						Util.playAction("Positive")
						object5:addText("Course you will. Break your way in.")
						object5:addText("When it comes down, don't stand there admiring it. Bring it straight back.")
					end)
				end)
			end
		end)
	end)
end

DialoguesList.SkyExp2Quest = Util.generateQuest("SkyExp2Quest", {
	NPCName = "Sky Quest Giver 2",
	ExtraOptions = templeIntelOption,
	BeforeGuide = templeIntelHandIn
})
DialoguesList.FountainQuest = Util.generateQuest("FountainQuest", {
	NPCName = "Freezeburg Quest Giver"
})
DialoguesList.Area1Quest = Util.generateQuest("Area1Quest", {
	NPCName = "Area 1 Quest Giver"
})
DialoguesList.Area2Quest = Util.generateQuest("Area2Quest", {
	NPCName = "Area 2 Quest Giver"
})
DialoguesList.MarineQuest3 = Util.generateQuest("MarineQuest3", {
	NPCName = "Marine Quest Giver"
})
DialoguesList.ZombieQuest = Util.generateQuest("ZombieQuest", {
	NPCName = "Graveyard Quest Giver"
})
DialoguesList.SnowMountainQuest = Util.generateQuest("SnowMountainQuest", {
	NPCName = "Snow Quest Giver"
})
DialoguesList.IceSideQuest = Util.generateQuest("IceSideQuest", {
	NPCName = "Ice Quest Giver"
})
DialoguesList.FireSideQuest = Util.generateQuest("FireSideQuest", {
	NPCName = "Fire Quest Giver"
})
DialoguesList.ShipQuest1 = Util.generateQuest("ShipQuest1", {
	NPCName = "Rear Crew Quest Giver"
})
DialoguesList.ShipQuest2 = Util.generateQuest("ShipQuest2", {
	NPCName = "Front Crew Quest Giver"
})
DialoguesList.FrostQuest = Util.generateQuest("FrostQuest", {
	NPCName = "Frost Quest Giver"
})
DialoguesList.ForgottenQuest = Util.generateQuest("ForgottenQuest", {
	NPCName = "Forgotten Quest Giver"
})
DialoguesList.PiratePortQuest = Util.generateQuest("PiratePortQuest", {
	NPCName = "Pirate Port Quest Giver"
})
DialoguesList.DragonCrewQuest = Util.generateQuest("DragonCrewQuest", {
	NPCName = "Dragon Crew Quest Giver"
})
DialoguesList.VenomCrewQuest = Util.generateQuest("VenomCrewQuest", {
	NPCName = "Hydra Town Quest Giver"
})
DialoguesList.MarineTreeIsland = Util.generateQuest("MarineTreeIsland", {
	NPCName = "Marine Tree Quest Giver"
})
DialoguesList.DeepForestIsland = Util.generateQuest("DeepForestIsland", {
	NPCName = "Deep Forest Quest Giver"
})
DialoguesList.DeepForestIsland2 = Util.generateQuest("DeepForestIsland2", {
	NPCName = "Deep Forest Area 2 Quest Giver"
})
DialoguesList.DeepForestIsland3 = Util.generateQuest("DeepForestIsland3", {
	NPCName = "Turtle Adventure Quest Giver"
})
DialoguesList.HauntedQuest1 = Util.generateQuest("HauntedQuest1", {
	NPCName = "Haunted Castle Quest Giver 1"
})
DialoguesList.HauntedQuest2 = Util.generateQuest("HauntedQuest2", {
	NPCName = "Haunted Castle Quest Giver 2"
})
DialoguesList.NutsIslandQuest = Util.generateQuest("NutsIslandQuest", {
	NPCName = "Peanut Quest Giver"
})
DialoguesList.IceCreamIslandQuest = Util.generateQuest("IceCreamIslandQuest", {
	NPCName = "Ice Cream Quest Giver"
})
DialoguesList.CakeQuest1 = Util.generateQuest("CakeQuest1", {
	NPCName = "Cake Quest Giver 1"
})
DialoguesList.CakeQuest2 = Util.generateQuest("CakeQuest2", {
	NPCName = "Cake Quest Giver 2"
})
DialoguesList.ChocQuest1 = Util.generateQuest("ChocQuest1", {
	NPCName = "Chocolate Quest Giver 1"
})
DialoguesList.ChocQuest2 = Util.generateQuest("ChocQuest2", {
	NPCName = "Chocolate Quest Giver 2"
})
DialoguesList.CandyQuest1 = Util.generateQuest("CandyQuest1", {
	NPCName = "Candy Cane Quest Giver"
})
DialoguesList.TikiQuest1 = Util.generateQuest("TikiQuest1", {
	NPCName = "Tiki Quest Giver 1"
})
DialoguesList.TikiQuest2 = Util.generateQuest("TikiQuest2", {
	NPCName = "Tiki Quest Giver 2"
})
DialoguesList.TikiQuest3 = Util.generateQuest("TikiQuest3", {
	NPCName = "Tiki Quest Giver 3"
})
DialoguesList.SubmergedQuest1 = Util.generateQuest("SubmergedQuest1", {
	NPCName = "Submerged Quest Giver 1"
})
DialoguesList.SubmergedQuest2 = Util.generateQuest("SubmergedQuest2", {
	NPCName = "Submerged Quest Giver 2"
})
DialoguesList.SubmergedQuest3 = Util.generateQuest("SubmergedQuest3", {
	NPCName = "Submerged Quest Giver 3"
})
DialoguesList.ColosseumEmperor = require(script.NPCs.ColosseumEmperor)
DialoguesList.Hasan = require(script.NPCs.Hasan)
DialoguesList.DesertMerchant = require(script.NPCs.DesertMerchant)
local v6 = {}

for k, v7 in pairs(DialoguesList) do
	local title = v7.Title or v7._title

	if title ~= nil then
		v6[title] = k
	end
end

setmetatable(DialoguesList, {
	__index = function(p, p2)
		if v6[p2] then
			p2 = v6[p2]
		end

		local v7 = rawget(p, p2)

		if v7 ~= nil then
			return v7
		end

		error((`no Dialogue Tree at key "{p2}"`))
	end
})
return DialoguesList