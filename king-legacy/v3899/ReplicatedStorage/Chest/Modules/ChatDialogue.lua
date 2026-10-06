local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local QuestManager = require(ReplicatedStorage.Chest.Modules.QuestManager)
local MaterialList = require(ReplicatedStorage.Chest.Modules.MaterialList)
local localPlayer = game.Players.LocalPlayer
return {
	["Fish Interaction"] = {
		{
			Chat = "What would you like to do with this fish?",
			ChatTH = "เราควรทำยังไงกับปลาตัวนี้ดี?",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Unequip",
					Action = "UnequipFish"
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	ChaliceInfo = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "What's up, guys? I used to be the Title Master, but now that titles have moved to the player's Status window",
							ChatTH = "ว่าไงพวก ชั้นเคยเป็น Title Master มาก่อน แต่ตอนนี้มันย้ายไปที่หน้าต่าง Status ผู้เล่นแล้ว",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Next",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = "Are you curious about that chalice over there?",
											ChatTH = "คุณสงสัยเกี่ยวกับแท่นบูชาตรงนั้นหรอ ชั้นมีข้อมูลนะ อยากรู้มั้ยล่ะ?",
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Next",
													Action = "NextDialogue",
													Dialogues = {
														{
															Chat = [[
What lies before you is the Chalice of Fruit Offering. As for the countdown timer 
that's when the sea boss will appear.]],
															ChatTH = [[
สิ่งที่อยู่ตรงหน้าเจ้ามันคือจอกบูชาผลไม้ ส่วนนาฬิกานับถอยหลังนั้น
คือเวลาที่บอสกลางทะเลจะเกิด]],
															Buttons = {
																{
																	ButtonType = "Button1",
																	ButtonText = "Next",
																	Action = "NextDialogue",
																	Dialogues = {
																		{
																			Chat = "You’ll also see a faint icon showing which boss it is.",
																			ChatTH = "และรูปจางๆนั่น สามารถบอกว่ามันคือตัวอะไร ที่จะเกิด",
																			Buttons = {
																				{
																					ButtonType = "Button1",
																					ButtonText = "Next",
																					Action = "NextDialogue",
																					Dialogues = {
																						{
																							Chat = [[
You can offer a fruit to speed up the sea monster’s spawn time 
but only during the final 30 minutes.]],
																							ChatTH = [[
คุณสามารถใส่ผลไม้เพื่อเร่งเวลา
ในการเกิดของมอนส์เตอร์ในทะเลได้ 
แต่เร่งได้ถึงแค่ 30 นาทีสุดท้ายเท่านั้น]],
																							Buttons = {
																								{
																									ButtonType = "Button1",
																									ButtonText = "Next",
																									Action = "NextDialogue",
																									Dialogues = {
																										{
																											Chat = "The higher the tier of the fruit you offer, the more time it will shave off the countdown.",
																											ChatTH = "ยิ่งผลไม้ที่คุณใส่ระดับสูงเท่าไหร่ ก็จะยิ่งเร่งเวลาได้มากเท่านั้น",
																											Buttons = {
																												{
																													ButtonType = "Button1",
																													ButtonText = "Next",
																													Action = "NextDialogue",
																													Dialogues = {
																														{
																															Chat = "If the fruit you offer is Epic or Legendary, it can also randomly change the sea monster that will appear.",
																															ChatTH = [[
หากผลไม้เจ้าเป็นระดับอีปิคหรือตำนาน มันจะสามารถเปลี่ยนมอนส์เตอร์
ที่จะเกิดแบบสุ่มได้อีกด้วย]],
																															Buttons = {
																																{
																																	ButtonType = "Button1",
																																	ButtonText = "Next",
																																	Action = "NextDialogue",
																																	Dialogues = {
																																		{
																																			Chat = "Once the timer drops below 30 minutes, the numbers will turn red and you’ll no longer be able to offer any fruits.",
																																			ChatTH = "จนกระทั่งเวลาเหลือต่ำกว่า 30 นาที ตัวเลขจะกลายเป็นสีแดง และไม่สามารถสังเวยผลไม้ได้อีก",
																																			Buttons = {
																																				{
																																					ButtonType = "Button1",
																																					ButtonText = "Next",
																																					Action = "NextDialogue",
																																					Dialogues = {
																																						{
																																							Chat = "But Legendary fruits are an exception—haha! You can use them to speed up the timer all the way until the boss appears",
																																							ChatTH = "แต่ผลไม้ระดับตำนานเป็นข้อยกเว้นนะสิ ฮ่าๆๆ คุณสามารถใช้มันใส่จนบอสเกิดได้เลย",
																																							Buttons = {
																																								{
																																									ButtonType = "Button1",
																																									ButtonText = "Next",
																																									Action = "NextDialogue",
																																									Dialogues = {
																																										{
																																											Chat = "But you won’t be able to change the boss once the timer turns red...",
																																											ChatTH = [[
แต่คุณจะเปลี่ยนบอส
ตอนที่เวลาเป็นสีแดงไม่ได้หรอกนะ...]],
																																											Buttons = {
																																												{
																																													ButtonType = "Button3",
																																													ButtonText = "...",
																																													Action = "Close"
																																												}
																																											}
																																										}
																																									}
																																								},
																																								{
																																									ButtonType = "Button2",
																																									ButtonText = "Return",
																																									Action = "Return"
																																								},
																																								{
																																									ButtonType = "Button3",
																																									ButtonText = "Close",
																																									Action = "Close"
																																								}
																																							}
																																						}
																																					}
																																				},
																																				{
																																					ButtonType = "Button2",
																																					ButtonText = "Return",
																																					Action = "Return"
																																				},
																																				{
																																					ButtonType = "Button3",
																																					ButtonText = "Close",
																																					Action = "Close"
																																				}
																																			}
																																		}
																																	}
																																},
																																{
																																	ButtonType = "Button2",
																																	ButtonText = "Return",
																																	Action = "Return"
																																},
																																{
																																	ButtonType = "Button3",
																																	ButtonText = "Close",
																																	Action = "Close"
																																}
																															}
																														}
																													}
																												},
																												{
																													ButtonType = "Button2",
																													ButtonText = "Return",
																													Action = "Return"
																												},
																												{
																													ButtonType = "Button3",
																													ButtonText = "Close",
																													Action = "Close"
																												}
																											}
																										}
																									}
																								},
																								{
																									ButtonType = "Button2",
																									ButtonText = "Return",
																									Action = "Return"
																								},
																								{
																									ButtonType = "Button3",
																									ButtonText = "Close",
																									Action = "Close"
																								}
																							}
																						}
																					}
																				},
																				{
																					ButtonType = "Button2",
																					ButtonText = "Return",
																					Action = "Return"
																				},
																				{
																					ButtonType = "Button3",
																					ButtonText = "Close",
																					Action = "Close"
																				}
																			}
																		}
																	}
																},
																{
																	ButtonType = "Button2",
																	ButtonText = "Return",
																	Action = "Return"
																},
																{
																	ButtonType = "Button3",
																	ButtonText = "Close",
																	Action = "Close"
																}
															}
														}
													}
												},
												{
													ButtonType = "Button2",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "...",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	TricksterNPC = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						local fightingStyle = localPlayer:WaitForChild("PlayerStats"):WaitForChild("FightingStyle")
						local v = _G.CheckAwakeClient(localPlayer, "Trickster")
						local v2 = _G.CheckQuestProgressClient(localPlayer, "Trickster")

						if v then
							if fightingStyle.Value == "Trickster" then
								return {
									{
										Chat = "That fist style is built on deception and cunning moves.",
										ChatTH = "รูปแบบหมัดนั้นสร้างขึ้นจากการหลอกลวงและการเคลื่อนไหวที่ฉลาดแกมโกง",
										Buttons = {
											{
												ButtonType = "Button3",
												ButtonText = "...",
												Action = "Close"
											}
										}
									}
								}
							end

							return {
								{
									Chat = "Do you wish to switch to the Trickster?",
									ChatTH = "เจ้าอยากจะสลับไปใช้ Trickster หรือไม่?",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Accept",
											Action = "AddQuestProgress",
											QuestProgressData = {
												QuestProgressName = "Trickster",
												QuestChapter = 1
											}
										},
										{
											ButtonType = "Button3",
											ButtonText = "Decline",
											Action = "Close"
										}
									}
								}
							}
						else
							if v then
								return
							end

							if v2 and v2 == 1 then
								return {
									{
										Chat = [[
Melee: Trickster <Img=104094755399687> <Color=Red>(Legendary) 
 <Color=/>Price: <Color=Green> $25,000,000]],
										ChatTH = [[
หมัด: Trickster <Img=104094755399687> <Color=Red>(Legendary) 
 <Color=/>ราคา: <Color=Green> $25,000,000]],
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "Buy",
												Action = "AddQuestProgress",
												QuestProgressData = {
													QuestProgressName = "Trickster",
													QuestChapter = 1
												}
											},
											{
												ButtonType = "Button3",
												ButtonText = "Close",
												Action = "Close"
											}
										}
									}
								}
							end

							if _G.CheckMaterialClient(localPlayer, "Trickshard", 10) then
								return {
									{
										Chat = "Give me 10 Trickshards, and I’ll teach you the Trickster Fist—full of cunning and deception",
										ChatTH = "มอบ Trickshard 10 ชิ้นให้ข้าแล้วข้าจะสอนหมัด Trickster ซึ่งเต็มไปด้วยเล่ห์เหลี่ยมและการหลอกลวง",
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "Accept",
												Action = "AddQuestProgress",
												QuestProgressData = {
													QuestProgressName = "Trickster",
													QuestChapter = 1
												}
											},
											{
												ButtonType = "Button3",
												ButtonText = "Decline",
												Action = "Close"
											}
										}
									}
								}
							end

							return {
								{
									Chat = "Bring me 10 Trickshards. <Img=137517996607567>",
									ChatTH = "ฉันต้องการ Trickshard 10 ชิ้น <Img=137517996607567>",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "How?",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "It’s the Chaos Kraken. Each of its tentacles has a small chance to drop it.",
													ChatTH = "Chaos Kraken ยังไงล่ะ แต่ละหนวดมีโอกาสดรอปเล็กน้อยอยู่นะ",
													Buttons = {
														{
															ButtonType = "Button3",
															ButtonText = "...",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	JusticeFistNPC = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						local playerStats = localPlayer:WaitForChild("PlayerStats")
						local fightingStyle = playerStats:WaitForChild("FightingStyle")
						local v = _G.CheckAwakeClient(localPlayer, "Justice Fist")
						local v2 = _G.CheckQuestProgressClient(localPlayer, "Justice Fist")
						local v3

						if v2 then
							v3 = v2 - 4 or nil
						end

						local v4 = v2 or nil

						if not v2 then
							return {
								{
									Chat = "Eliminate the Abyssal Tyrant.",
									ChatTH = "กำจัด Abyssal Tyrant"
								}
							}
						end

						if v2 < 3 then
							return {
								{
									Chat = "Eliminate the Abyssal Tyrant. <Color=Red>(" .. v4 .. "/3)",
									ChatTH = "กำจัด Abyssal Tyrant <Color=Red>(" .. v4 .. "/3)"
								}
							}
						end

						if v2 == 3 then
							return {
								{
									Chat = "Oh? Looking to learn something intriguing?",
									ChatTH = "โอ้? กำลังมองหาอะไรที่น่าสนใจอยู่เหรอ?",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Indeed",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Find all 5 Orbs of Justice each one is held by a guardian on the final floor of Easy Mode dungeons in the Third Sea.",
													ChatTH = "จงตามหา Orb of Justice ทั้ง 5 ชิ้นซะ ผู้ครอบครองล้วนอยู่ที่ชั้นสุดท้ายของดันเจี้ยนโหมดง่ายในทะเลที่ 3",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Sure",
															Action = "NextDialogue",
															Dialogues = {
																{
																	Chat = "Those who wield Darkness and Lava are all level 5,000. This is the only clue I can offer. Stay strong.",
																	ChatTH = "ผู้ใช้ความมืดและลาวา ทุกคนล้วนมีเลเวล 5,000 ข้าคงใบ้ให้ได้แค่นี้แหละ สู้ๆนะ",
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Accept",
																			Action = "AddQuestProgress",
																			QuestProgressData = {
																				QuestProgressName = "Justice Fist",
																				QuestChapter = 3
																			}
																		},
																		{
																			ButtonType = "Button2",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "Decline",
																			Action = "Close"
																		}
																	}
																}
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nah",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button3",
											ButtonText = "Close",
											Action = "Close"
										}
									}
								}
							}
						end

						if v2 >= 4 and v2 < 9 then
							if v2 == 8 then
								local orbofJustice = HttpService:JSONDecode(playerStats.Material.Value)["Orb of Justice"] or 0

								if v3 and orbofJustice < v3 then
									return {
										{
											Chat = "Defeat the Dark Warden or Magma Warden, then return to me.",
											ChatTH = "ไปกำจัด Dark Warden หรือ Magma Warden แล้วกลับมาหาข้า"
										}
									}
								end
							end

							return {
								{
									Chat = "Orb of Justice (" .. v3 .. "/5)",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "?",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Those who wield Darkness and Lava are all level 5,000. This is the only clue I can offer. Stay strong.",
													ChatTH = "ผู้ใช้ความมืดและลาวา ทุกคนล้วนมีเลเวล 5,000 ข้าคงใบ้ให้ได้แค่นี้แหละ สู้ๆนะ",
													Buttons = {
														{
															ButtonType = "Button3",
															ButtonText = "...",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						else
							if v2 == 9 then
								return {
									{
										Chat = "Well done. The final trial awaits. Defeat a fragment of my true self, and you shall be deemed worthy.",
										ChatTH = "ดีมาก บททดสอบสุดท้ายรอเจ้าอยู่ หากเจ้าสู้กับเศษเสี้ยวของตัวตนข้าได้ ถือว่าผ่านการทดสอบ",
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "Accept",
												Action = "NextDialogue",
												Dialogues = {
													{
														Chat = "Challenge it again and again… until victory is yours.",
														ChatTH = "ท้าทายมันอีกครั้งแล้วครั้งเล่า…จนกระทั่งชัยชนะเป็นของเจ้า",
														Buttons = {
															{
																ButtonType = "Button1",
																ButtonText = "Sure",
																Action = "AddQuestProgress",
																QuestProgressData = {
																	QuestProgressName = "Justice Fist",
																	QuestChapter = 9
																}
															},
															{
																ButtonType = "Button2",
																ButtonText = "Return",
																Action = "Return"
															},
															{
																ButtonType = "Button3",
																ButtonText = "Close",
																Action = "Close"
															}
														}
													}
												}
											},
											{
												ButtonType = "Button3",
												ButtonText = "Decline",
												Action = "Close"
											}
										}
									}
								}
							elseif v2 == 10 then
								return {
									{
										Chat = "May luck be with you, friend.",
										ChatTH = "ขอให้โชคดี สหาย",
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "Fight",
												Action = "AddQuestProgress",
												QuestProgressData = {
													QuestProgressName = "Justice Fist",
													QuestChapter = 10
												}
											},
											{
												ButtonType = "Button3",
												ButtonText = "Decline",
												Action = "Close"
											}
										}
									}
								}
							end

							if v2 == 11 then
								if not v then
									return {
										{
											Chat = [[
Melee: Justice Fist <Img=109109882642812> <Color=Pink>(Mythical) 
 <Color=/>Price: <Color=Green> $49,000,000]],
											ChatTH = [[
หมัด: Justice Fist <Img=109109882642812> <Color=Pink>(Mythical) 
 <Color=/>ราคา: <Color=Green> $49,000,000]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Buy",
													Action = "AddQuestProgress",
													QuestProgressData = {
														QuestProgressName = "Justice Fist",
														QuestChapter = 11
													}
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								end

								if v then
									if fightingStyle.Value == "Justice Fist" then
										return {
											{
												Chat = "That's the strongest fist power on Earth.",
												ChatTH = "นั่นคือหมัดที่แข็งแกร่งในสุดบนโลก.",
												Buttons = {
													{
														ButtonType = "Button3",
														ButtonText = "...",
														Action = "Close"
													}
												}
											}
										}
									end

									return {
										{
											Chat = "Do you wish to switch to the Justice Fist?",
											ChatTH = "เจ้าอยากจะสลับไปใช้ Justice Fist หรือไม่?",
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Accept",
													Action = "AddQuestProgress",
													QuestProgressData = {
														QuestProgressName = "Justice Fist",
														QuestChapter = 11
													}
												},
												{
													ButtonType = "Button3",
													ButtonText = "Decline",
													Action = "Close"
												}
											}
										}
									}
								end
							end
						end
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	DemonRaceNPC = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						local _ = localPlayer.PlayerStats.DFName
						local v = _G.CheckQuestProgressClient(localPlayer, "Demon V1")
						local v2 = _G.CheckQuestProgressClient(localPlayer, "Demon V2")
						local v3

						if v then
							v3 = v - 1 or nil
						end

						local v4

						if v2 then
							v4 = v2 - 1 or nil
						end

						local v5 = _G.CheckAwakeClient(localPlayer, "DemonV1")
						local v6 = _G.CheckAwakeClient(localPlayer, "DemonV2")

						if _G.RaceClient == "Human" and not v5 then
							if not v then
								return {
									{
										Chat = "Think you’ve got what it takes to grow stronger?",
										ChatTH = "เจ้าอยากแข็งแกร่งขึ้นมั้ยล่ะ?",
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "Yes",
												Action = "NextDialogue",
												Dialogues = {
													{
														Chat = "Go defeat 10 Imprisoned Angels.",
														ChatTH = "จงไปกำจัด Imprisoned Angel 10 ตัวซะ",
														Buttons = {
															{
																ButtonType = "Button1",
																ButtonText = "Accept",
																Action = "AddQuestProgress",
																QuestProgressData = {
																	QuestProgressName = "Demon V1",
																	QuestChapter = 1
																}
															},
															{
																ButtonType = "Button3",
																ButtonText = "Decline",
																Action = "Close"
															}
														}
													}
												}
											},
											{
												ButtonType = "Button3",
												ButtonText = "No",
												Action = "Close"
											}
										}
									}
								}
							end

							if v >= 1 and v < 11 then
								return {
									{
										Chat = "Defeat 10 Imprisoned Angels. (" .. v3 .. "/10)",
										ChatTH = "จงกำจัด Imprisoned Angel มา 10 ตน. (" .. v3 .. "/10)",
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "...",
												Action = "Close"
											}
										}
									}
								}
							end

							if v == 11 then
								if _G.CheckAwakeClient(localPlayer, "Demon V1") then
									return {
										{
											Chat = "The power is yours. Will you embrace the Demon race now?",
											ChatTH = "เจ้าได้รับพลังแล้ว อยากรับพลังของเผ่าปีศาจตอนนี้เลยหรือไม่?",
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Accept",
													Action = "AddQuestProgress",
													QuestProgressData = {
														QuestProgressName = "Change Race to Demon",
														QuestChapter = 11
													}
												},
												{
													ButtonType = "Button3",
													ButtonText = "Decline",
													Action = "Close"
												}
											}
										}
									}
								end

								return {
									{
										Chat = [[
Bring <Color=Yellow>100 Angellic's Feather<Color=/>
 and <Color=Green>$5,000,000<Color=/> to obtain the Demon race.]],
										ChatTH = [[
ทำได้ดีมาก ข้าต้องการ <Color=Yellow>Angellic's Feather 100 ชิ้น<Color=/> และ <Color=Green>$5,000,000<Color=/> 
แล้วเจ้าจะได้เป็นส่วนหนึ่งของเผ่าปีศาจ]],
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "Accept",
												Action = "AddQuestProgress",
												QuestProgressData = {
													QuestProgressName = "Demon V1",
													QuestChapter = 11
												}
											},
											{
												ButtonType = "Button3",
												ButtonText = "Decline",
												Action = "Close"
											}
										}
									}
								}
							end
						elseif _G.RaceClient == "Demon" and not v6 then
							if not v2 then
								return {
									{
										Chat = "There's still more potential in our race!",
										ChatTH = "เผ่าพันธุ์ของพวกเราสามารถพัฒนาได้อีก!",
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "...",
												Action = "NextDialogue",
												Dialogues = {
													{
														Chat = "Go defeat 10 Imprisoned Demons.",
														ChatTH = "จงไปกำจัด Imprisoned Demon 10 ตัวซะ",
														Buttons = {
															{
																ButtonType = "Button1",
																ButtonText = "Accept",
																Action = "AddQuestProgress",
																QuestProgressData = {
																	QuestProgressName = "Demon V2",
																	QuestChapter = 1
																}
															},
															{
																ButtonType = "Button3",
																ButtonText = "Decline",
																Action = "Close"
															}
														}
													}
												}
											},
											{
												ButtonType = "Button3",
												ButtonText = "Close",
												Action = "Close"
											}
										}
									}
								}
							end

							if v2 >= 1 and v2 < 11 then
								return {
									{
										Chat = "Defeat 10 Imprisoned Demons. (" .. v4 .. "/10)",
										ChatTH = "จงกำจัด Imprisoned Demon มา 10 ตน. (" .. v4 .. "/10)",
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "...",
												Action = "Close"
											}
										}
									}
								}
							end

							if v2 == 11 then
								if _G.CheckAwakeClient(localPlayer, "Demon V2") then
									return {
										{
											Chat = "The power is yours. Will you embrace the Demon race now?",
											ChatTH = "เจ้าได้รับพลังแล้ว อยากรับพลังของเผ่าปีศาจตอนนี้เลยหรือไม่?",
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Accept",
													Action = "AddQuestProgress",
													QuestProgressData = {
														QuestProgressName = "Change Race to Demon",
														QuestChapter = 11
													}
												},
												{
													ButtonType = "Button3",
													ButtonText = "Decline",
													Action = "Close"
												}
											}
										}
									}
								end

								return {
									{
										Chat = "Well done. Now I need <Color=Yellow>150 Angellic's Feather<Color=/> and <Color=Green>$7,000,000<Color=/> to enhance the demon power within you.",
										ChatTH = "ทำได้ดีมาก ข้าต้องการ <Color=Yellow>Angellic's Feather 150 ชิ้น<Color=/> และ <Color=Green>$7,000,000<Color=/> เพื่อเพื่อพัฒนาพลังปีศาจในตัวเจ้า",
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "Accept",
												Action = "AddQuestProgress",
												QuestProgressData = {
													QuestProgressName = "Demon V2",
													QuestChapter = 11
												}
											},
											{
												ButtonType = "Button3",
												ButtonText = "Decline",
												Action = "Close"
											}
										}
									}
								}
							end
						elseif v5 then
							return {
								{
									Chat = "The power is yours. Will you embrace the Demon race now?",
									ChatTH = "เจ้าได้รับพลังแล้ว อยากรับพลังของเผ่าปีศาจตอนนี้เลยหรือไม่?",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Accept",
											Action = "AddQuestProgress",
											QuestProgressData = {
												QuestProgressName = "Change Race to Demon",
												QuestChapter = 11
											}
										},
										{
											ButtonType = "Button3",
											ButtonText = "Decline",
											Action = "Close"
										}
									}
								}
							}
						else
							return {
								{
									Chat = "Get lost. I hate your kind.",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	Racekeeper = {
		{
			Chat = "You are just another page in my collection.",
			ChatTH = "เจ้าเป็นแค่หน้าอีกหน้าหนึ่งในสมุดสะสมของข้าเท่านั้น.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Human",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = [[
<Img=131562380057662> The <Color=Red>Humans<Color=/>.
 Adaptable creatures, quick to rise,
 yet even quicker to fall.]],
							ChatTH = [[
<Img=131562380057662> <Color=Red>มนุษย์<Color=/>...พวกเจ้าผงาดขึ้นไว
 แต่ร่วงโรยเร็วยิ่งนัก]],
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "V1",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = [[
<Img=131562380057662> Human V1: Teleportation range 
 extended from <Color=Red>150 to 180<Color=/> studs.]],
											ChatTH = [[
<Img=131562380057662> Human V1: เพิ่มระยะเทเลพอร์ต
จาก <Color=Red>150 เป็น 180<Color=/> สตัด]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "V2",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = [[
<Img=131562380057662> Human V2: Teleportation range 
 <Color=Red>increased to 225 studs<Color=/>,
 cooldown reduced by <Color=Green>50% <Color=Red>(15s to 7.5s)<Color=/>.]],
											ChatTH = [[
<Img=131562380057662> Human V2: เทเลพอร์ต
ระยะเพิ่มขึ้น <Color=Red>180 → 225 สตัด<Color=/>
 คูลดาวน์ลดลง <Color=Green>50% <Color=Red>(15s to 7.5s)]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button3",
									ButtonText = "V3",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = "<Img=131562380057662> Human V3: Active Skill - <Color=Green>Reduces<Color=/> all cooldowns by <Color=Green>50% <Color=Red>(10s)<Color=/>.",
											ChatTH = [[
<Img=131562380057662> Human V3: สกิลกดใช้ <Color=Green>ลดคูลดาวน์<Color=/>
ทั้งหมด <Color=Red>50% (10 วินาที)]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button4",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button5",
									ButtonText = "Close",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Fish",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = [[
<Img=76847002837730> The <Color=Red>Fish<Color=/>. Resilient creatures,
 forever bound to the embrace of the tides.]],
							ChatTH = [[
<Img=76847002837730> เหล่า<Color=Red>มนุษย์เงือก<Color=/>ทั้งหลาย... สิ่งมีชีวิตที่แข็งแกร่ง
 ทว่าผูกพันนิรันดร์กับอ้อมกอดของเกลียวคลื่น.]],
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "V1",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = [[
<Img=76847002837730> Fish V1: Swim faster,
 see clearer underwater,
 take <Color=Red>less damage<Color=/> from <Color=Cyan>seawater<Color=/>,
 and <Color=Green>recover health 20% faster<Color=/> in <Color=Cyan>water<Color=/>.]],
											ChatTH = [[
<Img=76847002837730> Fish V1: ว่ายน้ำเร็วขึ้น 
มองเห็นใต้น้ำชัด <Color=Red>ลดความเสียหาย<Color=/>จากน้ำทะเล 
ฟื้นฟูพลังชีวิตเร็วขึ้น <Color=Green>20%<Color=/> เมื่ออยู่ในน้ำ]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "V2",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = [[
<Img=76847002837730> Fish V2: <Color=Red>Immune<Color=/> to seawater damage,
 faster <Color=Green>healing<Color=/>, increased movement <Color=Yellow>speed<Color=/>,
 and <Color=Red>enhanced <Color=Cyan>Water Style <Color=/>attacks.]],
											ChatTH = [[
<Img=76847002837730> Fish V2: <Color=Red>ไม่ได้รับความเสียหาย<Color=/>จากน้ำทะเล 
<Color=Green>ฟื้นฟู<Color=/>เร็วขึ้น เคลื่อนที่ไวขึ้น 
และ<Color=Red>เพิ่มพลังโจมตี<Color=/>ของ <Color=Cyan>Water Style]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button3",
									ButtonText = "V3",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = "<Img=76847002837730> Fish V3: Active Skill - Grants <Color=Green>50%<Color=/> increased <Color=Yellow>durability<Color=/> and doubles HP <Color=Green>regeneration<Color=/> in <Color=Cyan>seawater <Color=Red>(10s)<Color=/>.",
											ChatTH = [[
<Img=76847002837730> Fish V3: สกิลกดใช้ 
 เพิ่มความ<Color=Green>ทนทาน 50% <Color=/>และ<Color=Green>ฟื้นฟูพลังชีวิต<Color=/>
ในน้ำทะเลเร็วขึ้น 2 เท่า <Color=Red>(10 วินาที)]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button4",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button5",
									ButtonText = "Close",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Angel",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = [[
<Img=132683936061250> The <Color=Red>Angels<Color=/>. Celestial beings,
 praised for their wings,
 yet chained by their pride.]],
							ChatTH = [[
<Img=132683936061250> เหล่า<Color=Red>เทวทูต<Color=/>... 
ผู้ได้รับการสรรเสริญจากปีกอันสูงส่ง 
ทว่าโซ่ตรวนของความทะนง
กลับพันธนาการพวกเขาไว้.]],
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "V1",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = [[
<Img=132683936061250> Angel V1: <Color=Red>Higher <Color=/>jumps,
 <Color=Red>additional<Color=/> sky jumps and 
 the ability to <Color=Red>glide<Color=/> across distances.]],
											ChatTH = [[
<Img=132683936061250> Angel V1: กระโดด<Color=Red>สูงขึ้น<Color=/> 
กระโดดกลางอากาศได้<Color=Red>เพิ่ม<Color=/>
 และสามารถ<Color=Red>ร่อน<Color=/>กลางอากาศได้]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "V2",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = [[
<Img=132683936061250> Angel V2: <Color=Red>Enhanced <Color=/>sky jumps and better <Color=Red>gliding<Color=/> capabilities,
 still cannot truly fly.]],
											ChatTH = [[
<Img=132683936061250> Angel V2: <Color=Red>เสริมพลัง<Color=/>การกระโดดกลางอากาศ 
และการ<Color=Red>ร่อน<Color=/> แต่ยังไม่อาจโบยบินอย่างแท้จริง]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button3",
									ButtonText = "V3",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = "<Img=132683936061250> Angel V3: Active Skill - Allows free <Color=Yellow>flight<Color=/> and Gradually <Color=Red>restores damage taken <Color=/>over 3 seconds <Color=Red>(10s)<Color=/>.",
											ChatTH = [[
<Img=132683936061250> Angel V3: สกิลกดใช้ 
 บินได้อย่างอิสระ และค่อยๆ<Color=Red>ฟื้นฟูความเสียหายที่ได้รับ <Color=/>ภายใน 3 วินาที 
<Color=Red>(10 วินาที)]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button4",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button5",
									ButtonText = "Close",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Animal",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = [[
<Img=84995508065012> The <Color=Red>Animals<Color=/>. Primal beings,
 governed by instinct rather than intellect.]],
							ChatTH = [[
<Img=84995508065012> เหล่า<Color=Red>สัตว์ป่า<Color=/>... 
สิ่งมีชีวิตดึกดำบรรพ์ ดำเนินชีวิต 
ด้วยสัญชาตญาณ มากกว่าปัญญา]],
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "V1",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = "<Img=84995508065012> Animal V1: Run speed <Color=Red>increased<Color=/> by <Color=Green>+10<Color=/>.",
											ChatTH = "<Img=84995508065012> Animal V1: <Color=Red>เพิ่ม<Color=/>ความเร็วในการวิ่ง <Color=Green>+10",
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "V2",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = [[
<Img=84995508065012> Animal V2: Run speed <Color=Red>increased<Color=/> by +20,
 <Color=Red>extended<Color=/> dash distance,
 and <Color=Red>higher <Color=Cyan>Electro <Color=/>damages.]],
											ChatTH = [[
<Img=84995508065012> Animal V2: <Color=Red>เพิ่ม<Color=/>ความเร็วในการวิ่ง <Color=Green>+20 
<Color=/>ระยะพุ่งตัวไกลขึ้น 
และเพิ่มพลังโจมตีของ <Color=Cyan>Electro]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button3",
									ButtonText = "V3",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = [[
<Img=84995508065012> Animal V3: Active Skill 
 <Color=Green>Heals 10% HP<Color=/>, dramatically <Color=Red>increases<Color=/> speed and dash capabilities,
 and <Color=Green>allows <Color=Cyan>running on water <Color=Red>(10s)<Color=/>.]],
											ChatTH = [[
<Img=84995508065012> Animal V3: สกิลกดใช้ 
 ฟื้นฟู <Color=Green>HP 10%<Color=/> เพิ่มความเร็ว 
และระยะพุ่งตัวอย่างมาก 
และสามารถวิ่งบนน้ำได้ <Color=Red>(10 วินาที)]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button3",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button4",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button5",
									ButtonText = "Close",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "Next",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Such wondrous races... or so they believe. Which one interests you?",
							ChatTH = [[
เผ่าพันธุ์ที่ว่ากันว่ายิ่งใหญ่... 
หรือแค่ความหลงตัวเอง 
แล้วเจ้าล่ะ อยากรู้เรื่องเผ่าไหน?]],
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Sea Beast",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = "<Img=117582670764674> The <Color=Red>Sea Beasts<Color=/>. Dominant creatures, revealing their strength not through words, but through action.",
											ChatTH = [[
<Img=117582670764674> เหล่า<Color=Red>อสูรทะเล<Color=/>... 
สิ่งมีชีวิตผู้ครองผืนน้ำ 
แสดงพลังด้วยการกระทำ ไม่ใช่คำพูด]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "V1",
													Action = "NextDialogue",
													Dialogues = {
														{
															Chat = [[
<Img=117582670764674> Sea Beast V1: <Color=Red>Increases<Color=/> swimming speed, <Color=Red>enhances<Color=/> underwater vision,
 and <Color=Green>reduces<Color=/> seawater damage.
 Superior to the Fish race in every way.]],
															ChatTH = [[
<Img=117582670764674> Sea Beast V1: ว่ายน้ำ<Color=Yellow>เร็วขึ้น<Color=/> มองเห็นใต้น้ำชัด 
<Color=Red>ลดความเสียหาย<Color=/>จากน้ำทะเล เหนือกว่าเผ่า Fish ทุกด้าน]],
															Buttons = {
																{
																	ButtonType = "Button1",
																	ButtonText = "Return",
																	Action = "Return"
																},
																{
																	ButtonType = "Button3",
																	ButtonText = "Close",
																	Action = "Close"
																}
															}
														}
													}
												},
												{
													ButtonType = "Button2",
													ButtonText = "V2",
													Action = "NextDialogue",
													Dialogues = {
														{
															Chat = [[
<Img=117582670764674> Sea Beast V2:
 Significantly <Color=Red>boosts swimming speed<Color=/>,
 grants complete seawater <Color=Red>immunity<Color=/>,
 and accelerates health <Color=Green>recovery<Color=/> in ocean.]],
															ChatTH = [[
<Img=117582670764674> Sea Beast V2: เพิ่มความเร็วใน 
การว่ายน้ำอย่างมาก <Color=Red>
ไม่ได้รับความเสียหาย<Color=/>จากน้ำทะเล
 และ<Color=Green>ฟื้นฟูพลังชีวิต<Color=/>ในมหาสมุทรได้เร็วขึ้น]],
															Buttons = {
																{
																	ButtonType = "Button1",
																	ButtonText = "Return",
																	Action = "Return"
																},
																{
																	ButtonType = "Button3",
																	ButtonText = "Close",
																	Action = "Close"
																}
															}
														}
													}
												},
												{
													ButtonType = "Button3",
													ButtonText = "V3",
													Action = "NextDialogue",
													Dialogues = {
														{
															Chat = [[
<Img=117582670764674> Sea Beast V3: Active Skill 
 Unleashes a blinding roar <Color=Red>(2s)<Color=/> and creates a <Color=Red>life-stealing<Color=/> whirlpool <Color=Green>(10s, 2% HP/s) up to a maximum of 5,000 HP<Color=/>.]],
															ChatTH = [[
<Img=117582670764674> Sea Beast V3: สกิลกดใช้ 
 ปล่อยเสียงคำรามที่ทำให้ศัตรูตาพร่ามัว <Color=Red>(2 วินาที)<Color=/> 
และสร้างวังน้ำวนดูดพลังชีวิต 
<Color=Red>(10 วินาที ดูดเลือด 2%/วินาที) สูงสุดไม่เกิน 5,000 HP]],
															Buttons = {
																{
																	ButtonType = "Button1",
																	ButtonText = "Return",
																	Action = "Return"
																},
																{
																	ButtonType = "Button3",
																	ButtonText = "Close",
																	Action = "Close"
																}
															}
														}
													}
												},
												{
													ButtonType = "Button4",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button5",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Demon",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = [[
<Img=70986398339264> The <Color=Red>Demons<Color=/>. Ancient beings,
 possessors of forbidden power that few dare to comprehend.]],
											ChatTH = [[
<Img=70986398339264> เหล่า<Color=Red>ปีศาจ<Color=/>... สิ่งมีชีวิตโบราณ
 ผู้ครอบครองพลังต้องห้าม
ที่มีน้อยคนนักกล้าแม้แต่จะเข้าใจ]],
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "V1",
													Action = "NextDialogue",
													Dialogues = {
														{
															Chat = "<Img=70986398339264> Demon V1: Unlocks <Color=Yellow>high-speed gliding<Color=/> and <Color=Red>increases<Color=/> health recovery by <Color=Green>15%<Color=/> during day, <Color=Green>30%<Color=/> at night.",
															ChatTH = [[
<Img=70986398339264> Demon V1: ปลดล็อกการร่อนความเร็วสูง
 ฟื้นฟูพลังชีวิตเพิ่มขึ้น <Color=Red>15% <Color=/>ในเวลากลางวัน 
และ <Color=Red>30%<Color=/> ในเวลากลางคืน]],
															Buttons = {
																{
																	ButtonType = "Button1",
																	ButtonText = "Return",
																	Action = "Return"
																},
																{
																	ButtonType = "Button3",
																	ButtonText = "Close",
																	Action = "Close"
																}
															}
														}
													}
												},
												{
													ButtonType = "Button2",
													ButtonText = "V2",
													Action = "NextDialogue",
													Dialogues = {
														{
															Chat = [[
<Img=70986398339264> Demon V2: Enables <Color=Yellow>faster gliding<Color=/>
 and <Color=Red>improves<Color=/> health regeneration to <Color=Green>25%<Color=/> during day, <Color=Green>50%<Color=/> at night.]],
															ChatTH = [[
<Img=70986398339264> Demon V2: ร่อนได้เร็วขึ้น
 ฟื้นฟูพลังชีวิตเพิ่มเป็น <Color=Red>25% <Color=/>ในเวลากลางวัน
 และ <Color=Red>50%<Color=/> ในเวลากลางคืน]],
															Buttons = {
																{
																	ButtonType = "Button1",
																	ButtonText = "Return",
																	Action = "Return"
																},
																{
																	ButtonType = "Button3",
																	ButtonText = "Close",
																	Action = "Close"
																}
															}
														}
													}
												},
												{
													ButtonType = "Button3",
													ButtonText = "V3",
													Action = "NextDialogue",
													Dialogues = {
														{
															Chat = [[
<Img=70986398339264> Demon V3: Active Skill 
 <Color=Red>Boosts<Color=/> attack power by <Color=Green>10% <Color=Red>(10s)<Color=/>,
 <Color=Red>curses<Color=/> targets reducing their attack by <Color=Red>50% (5s)<Color=/>, and grants <Color=Green>+15<Color=/> run speed during night.]],
															ChatTH = [[
<Img=70986398339264> Demon V3: สกิลกดใช้ 
 <Color=Red>เพิ่ม<Color=/>พลังโจมตี <Color=Red>10% (10 วินาที)<Color=/> 
สาปศัตรูให้โจมตีเบาลง <Color=Red>50% (5 วินาที)<Color=/> 
และเพิ่มความเร็วในการวิ่ง <Color=Green>+15<Color=/> ขณะกลางคืน]],
															Buttons = {
																{
																	ButtonType = "Button1",
																	ButtonText = "Return",
																	Action = "Return"
																},
																{
																	ButtonType = "Button3",
																	ButtonText = "Close",
																	Action = "Close"
																}
															}
														}
													}
												},
												{
													ButtonType = "Button4",
													ButtonText = "Return",
													Action = "Return"
												},
												{
													ButtonType = "Button5",
													ButtonText = "Close",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button3",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button4",
									ButtonText = "Close",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button6",
					ButtonText = "Close",
					Action = "Close"
				}
			}
		}
	},
	["Starter Island Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Soldier",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Soldiers"].Level) .. [[
 
 Objective: Kill 4 Soldiers 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Soldiers"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Soldiers"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Soldiers",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Soldiers"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Soldiers"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Clown Pirate",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 5 Clown Pirates"].Level) .. [[
 
 Objective: Kill 5 Clown Pirates 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 5 Clown Pirates"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 5 Clown Pirates"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 5 Clown Pirates",
									QuestData = {
										LevelNeed = QuestManager["Kill 5 Clown Pirates"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 5 Clown Pirates"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Smoky",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Smoky"].Level) .. [[
 
 Objective: Kill 1 Smoky 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Smoky"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Smoky"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Smoky",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Smoky"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Smoky"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Tashi",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Tashi"].Level) .. [[
 
 Objective: Kill 1 Tashi <Img=15426781268>
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Tashi"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Tashi"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Tashi",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Tashi"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Tashi"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Pirate Island Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Clown Swordman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 6 Clown Swordman"].Level) .. [[
 
 Objective: Kill 6 Clown Swordman 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 6 Clown Swordman"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 6 Clown Swordman"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 6 Clown Swordman",
									QuestData = {
										LevelNeed = QuestManager["Kill 6 Clown Swordman"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 6 Clown Swordman"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "The Clown",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 The Clown"].Level) .. [[
 
 Objective: Kill 1 The Clown 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 The Clown"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 The Clown"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 The Clown",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 The Clown"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 The Clown"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Soldier Town Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Commander",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Commander"].Level) .. [[
 
 Objective: Kill 4 Commander 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Commander"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Commander"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Commander",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Commander"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Commander"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Captain",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Captain"].Level) .. [[
 
 Objective: Kill 1 Captain 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Captain"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Captain"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Captain",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Captain"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Captain"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "The Barbaric",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 The Barbaric"].Level) .. [[
 
 Objective: Kill 1 The Barbaric 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 The Barbaric"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 The Barbaric"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 The Barbaric",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 The Barbaric"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 The Barbaric"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Shark Island Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Fighter Fishmans",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Fighter Fishmans"].Level) .. [[
 
 Objective: Kill 4 Fighter Fishmans 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Fighter Fishmans"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Fighter Fishmans"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Fighter Fishmans",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Fighter Fishmans"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Fighter Fishmans"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Karate Fishman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Karate Fishman"].Level) .. [[
 
 Objective: Kill 1 Karate Fishman 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Karate Fishman"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Karate Fishman"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Karate Fishman",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Karate Fishman"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Karate Fishman"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Shark Man",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Shark Man"].Level) .. [[
 
 Objective: Kill 1 Shark Man 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Shark Man"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Shark Man"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Shark Man",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Shark Man"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Shark Man"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Chef Ship Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Trainer Chef",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Trainer Chef"].Level) .. [[
 
 Objective: Kill 4 Trainer Chef 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Trainer Chef"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Trainer Chef"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Trainer Chef",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Trainer Chef"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Trainer Chef"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Dark Leg",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Dark Leg"].Level) .. [[
 
 Objective: Kill 1 Dark Leg 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Dark Leg"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Dark Leg"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Dark Leg",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Dark Leg"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Dark Leg"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Dory",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Dory"].Level) .. [[
 
 Objective: Kill 1 Dory 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Dory"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Dory"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Dory",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Dory"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Dory"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Snow Island Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Snow Soldier",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 5 Snow Soldier"].Level) .. [[
 
 Objective: Kill 5 Snow Soldier 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 5 Snow Soldier"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 5 Snow Soldier"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 5 Snow Soldier",
									QuestData = {
										LevelNeed = QuestManager["Kill 5 Snow Soldier"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 5 Snow Soldier"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "King Snow",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 King Snow"].Level) .. [[
 
 Objective: Kill 1 King Snow 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 King Snow"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 King Snow"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 King Snow",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 King Snow"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 King Snow"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Little Dear",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Little Dear"].Level) .. [[
 
 Objective: Kill 1 Little Dear 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Little Dear"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Little Dear"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Little Dear",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Little Dear"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Little Dear"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Desert Island Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Candle Man",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Candle Man"].Level) .. [[
 
 Objective: Kill 1 Candle Man 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Candle Man"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Candle Man"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Candle Man",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Candle Man"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Candle Man"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Sand Bandit",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Sand Bandit"].Level) .. [[
 
 Objective: Kill 4 Sand Bandit 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Sand Bandit"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Sand Bandit"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Sand Bandit",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Sand Bandit"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Sand Bandit"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Bomb Man",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Bomb Man"].Level) .. [[
 
 Objective: Kill 1 Bomb Man 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Bomb Man"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Bomb Man"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Bomb Man",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Bomb Man"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Bomb Man"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Desert Marauder",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Desert Marauder"].Level) .. [[
 
 Objective: Kill 4 Desert Marauder 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Desert Marauder"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Desert Marauder"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Desert Marauder",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Desert Marauder"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Desert Marauder"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "King of Sand",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 King of Sand"].Level) .. [[
 
 Objective: Kill 1 King of Sand 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 King of Sand"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 King of Sand"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 King of Sand",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 King of Sand"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 King of Sand"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button6",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Skyland Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Sky Soldier",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Sky Soldier"].Level) .. [[
 
 Objective: Kill 4 Sky Soldier 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Sky Soldier"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Sky Soldier"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Sky Soldier",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Sky Soldier"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Sky Soldier"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Cloud Warrior",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Cloud Warrior"].Level) .. [[
 
 Objective: Kill 4 Cloud Warrior 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Cloud Warrior"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Cloud Warrior"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Cloud Warrior",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Cloud Warrior"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Cloud Warrior"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Skyland 2 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Ball Man",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Ball Man"].Level) .. [[
 
 Objective: Kill 1 Ball Man 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Ball Man"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Ball Man"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Ball Man",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Ball Man"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Ball Man"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Rumble Man",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Rumble Man"].Level) .. [[
 
 Objective: Kill 1 Rumble Man 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Rumble Man"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Rumble Man"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Rumble Man",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Rumble Man"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Rumble Man"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Bubbleland Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Elite Soldiers",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Soldiers"].Level) .. [[
 
 Objective: Kill 4 Elite Soldiers 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Soldiers"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Soldiers"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Elite Soldiers",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Elite Soldiers"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Soldiers"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "High-class Soldier",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 High-class Soldier"].Level) .. [[
 
 Objective: Kill 4 High-class Soldier 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 High-class Soldier"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 High-class Soldier"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 High-class Soldier",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 High-class Soldier"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 High-class Soldier"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Leader",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Leader"].Level) .. [[
 
 Objective: Kill 1 Leader 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Leader"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Leader"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Leader",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Leader"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Leader"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Pasta",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Pasta"].Level) .. [[
 
 Objective: Kill 1 Pasta 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Pasta"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Pasta"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Pasta",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Pasta"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Pasta"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Lobby Island Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Naval personnel",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Naval personnel"].Level) .. [[
 
 Objective: Kill 4 Naval personnel 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Naval personnel"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Naval personnel"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Naval personnel",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Naval personnel"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Naval personnel"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Wolf",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Wolf"].Level) .. [[
 
 Objective: Kill 1 Wolf 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Wolf"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Wolf"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Wolf",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Wolf"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Wolf"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Giraffe",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Giraffe"].Level) .. [[
 
 Objective: Kill 1 Giraffe 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Giraffe"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Giraffe"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Giraffe",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Giraffe"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Giraffe"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Lobby Island Quest 2"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Nautical soldier",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Nautical soldier"].Level) .. [[
 
 Objective: Kill 4 Nautical soldier 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Nautical soldier"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Nautical soldier"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Nautical soldier",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Nautical soldier"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Nautical soldier"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Naval soldier",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Naval soldier"].Level) .. [[
 
 Objective: Kill 4 Naval soldier 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Naval soldier"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Naval soldier"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Naval soldier",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Naval soldier"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Naval soldier"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Leo",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Leo"].Level) .. [[
 
 Objective: Kill 1 Leo 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Leo"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Leo"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Leo",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Leo"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Leo"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Zombie Island Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Zombie",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 5 Zombies"].Level) .. [[
 
 Objective: Kill 5 Zombies 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 5 Zombies"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 5 Zombies"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 5 Zombies",
									QuestData = {
										LevelNeed = QuestManager["Kill 5 Zombies"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 5 Zombies"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Elite Zombie",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Zombies"].Level) .. [[
 
 Objective: Kill 4 Elite Zombies 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Zombies"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Zombies"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Elite Zombies",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Elite Zombies"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Zombies"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Revenant",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Revenant"].Level) .. [[
 
 Objective: Kill 4 Revenant 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Revenant"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Revenant"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Revenant",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Revenant"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Revenant"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Shadow Master",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Shadow Master"].Level) .. [[
 
 Objective: Kill 1 Shadow Master 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Shadow Master"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Shadow Master"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Shadow Master",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Shadow Master"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Shadow Master"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["War Island Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "New World Pirate",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 New World Pirates"].Level) .. [[
 
 Objective: Kill 4 New World Pirates 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 New World Pirates"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 New World Pirates"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 New World Pirates",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 New World Pirates"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 New World Pirates"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Cutlass Pirate",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Cutlass Pirates"].Level) .. [[
 
 Objective: Kill 4 Cutlass Pirates 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Cutlass Pirates"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Cutlass Pirates"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Cutlass Pirates",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Cutlass Pirates"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Cutlass Pirates"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Rear Admirals",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Rear Admirals"].Level) .. [[
 
 Objective: Kill 4 Rear Admirals 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Rear Admirals"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Rear Admirals"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Rear Admirals",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Rear Admirals"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Rear Admirals"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "True Karate Fishman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 True Karate Fishman"].Level) .. [[
 
 Objective: Kill 1 True Karate Fishman 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 True Karate Fishman"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 True Karate Fishman"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 True Karate Fishman",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 True Karate Fishman"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 True Karate Fishman"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "Quake Woman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Quake Woman"].Level) .. [[
 
 Objective: Kill 1 Quake Woman 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Quake Woman"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Quake Woman"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Quake Woman",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Quake Woman"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Quake Woman"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button6",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Fishland Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Fishman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Fishmans"].Level) .. [[
 
 Objective: Kill 4 Fishmans 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Fishmans"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Fishmans"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Fishmans",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Fishmans"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Fishmans"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Combat Fishman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Combat Fishman"].Level) .. [[
 
 Objective: Kill 1 Combat Fishman 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Combat Fishman"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Combat Fishman"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Combat Fishman",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Combat Fishman"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Combat Fishman"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Sword Fishman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Sword Fishman"].Level) .. [[
 
 Objective: Kill 1 Sword Fishman 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Sword Fishman"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Sword Fishman"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Sword Fishman",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Sword Fishman"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Sword Fishman"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Soldier Fishman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Soldier Fishman"].Level) .. [[
 
 Objective: Kill 4 Soldier Fishman 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Soldier Fishman"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Soldier Fishman"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Soldier Fishman",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Soldier Fishman"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Soldier Fishman"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "Seasoned Fishman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Seasoned Fishman"].Level) .. [[
 
 Objective: Kill 1 Seasoned Fishman 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Seasoned Fishman"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Seasoned Fishman"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Seasoned Fishman",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Seasoned Fishman"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Seasoned Fishman"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button6",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Japan 1 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Beast Pirate",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Beast Pirates"].Level) .. [[
 
 Objective: Kill 4 Beast Pirates 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Beast Pirates"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Beast Pirates"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Beast Pirates",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Beast Pirates"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Beast Pirates"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Beast Swordman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Beast Swordman"].Level) .. [[
 
 Objective: Kill 4 Beast Swordman 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Beast Swordman"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Beast Swordman"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Beast Swordman",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Beast Swordman"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Beast Swordman"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Gazelle Man",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Gazelle Man"].Level) .. [[
 
 Objective: Kill 1 Gazelle Man 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Gazelle Man"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Gazelle Man"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Gazelle Man",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Gazelle Man"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Gazelle Man"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Japan 2 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Bandit Beast Pirates",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Bandit Beast Pirates"].Level) .. [[
 
 Objective: Kill 4 Bandit Beast Pirates 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Bandit Beast Pirates"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Bandit Beast Pirates"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Bandit Beast Pirates",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Bandit Beast Pirates"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Bandit Beast Pirates"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Powerful Beast Pirates",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Powerful Beast Pirates"].Level) .. [[
 
 Objective: Kill 4 Powerful Beast Pirates 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Powerful Beast Pirates"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Powerful Beast Pirates"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Powerful Beast Pirates",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Powerful Beast Pirates"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Powerful Beast Pirates"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Violet Samurai",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Violet Samurai"].Level) .. [[
 
 Objective: Kill 1 Violet Samurai 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Violet Samurai"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Violet Samurai"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Violet Samurai",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Violet Samurai"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Violet Samurai"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Japan 3 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Duke",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Duke"].Level) .. [[
 
 Objective: Kill 1 Duke 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Duke"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Duke"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Duke",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Duke"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Duke"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Magician",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Magician"].Level) .. [[
 
 Objective: Kill 1 Magician 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Magician"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Magician"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Magician",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Magician"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Magician"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Kitsune Samurai",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Kitsune Samurai"].Level) .. [[
 
 Objective: Kill 1 Kitsune Samurai 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Kitsune Samurai"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Kitsune Samurai"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Kitsune Samurai",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Kitsune Samurai"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Kitsune Samurai"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Japan 4 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Elite Beast Pirate",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Beast Pirates"].Level) .. [[
 
 Objective: Kill 4 Elite Beast Pirates 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Beast Pirates"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Beast Pirates"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Elite Beast Pirates",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Elite Beast Pirates"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Elite Beast Pirates"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Bear Man",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Bear Man"].Level) .. [[
 
 Objective: Kill 1 Bear Man 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Bear Man"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Bear Man"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Bear Man",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Bear Man"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Bear Man"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Bean",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Bean"].Level) .. [[
 
 Objective: Kill 1 Bean 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Bean"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Bean"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Bean",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Bean"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Bean"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Japan 5 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Meji",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Meji"].Level) .. [[
 
 Objective: Kill 1 Meji 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Meji"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Meji"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Meji",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Meji"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Meji"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Petra",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Petra"].Level) .. [[
 
 Objective: Kill 1 Petra 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Petra"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Petra"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Petra",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Petra"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Petra"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Japan 6 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Kappa",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Kappa"].Level) .. [[
 
 Objective: Kill 1 Kappa 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Kappa"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Kappa"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Kappa",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Kappa"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Kappa"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Joey",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Joey"].Level) .. [[
 
 Objective: Kill 1 Joey 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Joey"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Joey"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Joey",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Joey"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Joey"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Skull Island Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Skull Pirates",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Skull Pirates"].Level) .. [[
 
 Objective: Kill 4 Skull Pirates
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Skull Pirates"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Skull Pirates"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Skull Pirates",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Skull Pirates"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Skull Pirates"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Elite Skeleton",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Elite Skeleton"].Level) .. [[
 
 Objective: Kill 1 Elite Skeleton 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Elite Skeleton"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Elite Skeleton"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Elite Skeleton",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Elite Skeleton"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Elite Skeleton"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Desert 2nd Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Desert Thief",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Desert Thief"].Level) .. [[
 
 Objective: Kill 1 Desert Thief
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Desert Thief"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Desert Thief"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Desert Thief",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Desert Thief"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Desert Thief"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Anubis",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Anubis"].Level) .. [[
 
 Objective: Kill 1 Anubis 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Anubis"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Anubis"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Anubis",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Anubis"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Anubis"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Pharaoh",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Pharaoh"].Level) .. [[
 
 Objective: Kill 1 Pharaoh 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Pharaoh"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Pharaoh"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Pharaoh",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Pharaoh"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Pharaoh"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Flame User",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Flame User"].Level) .. [[
 
 Objective: Kill 1 Flame User 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Flame User"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Flame User"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Flame User",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Flame User"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Flame User"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Loaf 1 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Chess Soldier",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Chess Soldiers"].Level) .. [[
 
 Objective: Kill 4 Chess Soldiers
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Chess Soldiers"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Chess Soldiers"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Chess Soldiers",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Chess Soldiers"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Chess Soldiers"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Sunken Vessel",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Sunken Vessel"].Level) .. [[
 
 Objective: Kill 1 Sunken Vessel 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Sunken Vessel"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Sunken Vessel"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Sunken Vessel",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Sunken Vessel"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Sunken Vessel"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Biscuit Man",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Biscuit Man"].Level) .. [[
 
 Objective: Kill 1 Biscuit Man 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Biscuit Man"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Biscuit Man"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Biscuit Man",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Biscuit Man"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Biscuit Man"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Loaf 2 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Dough Master",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Dough Master"].Level) .. [[
 
 Objective: Kill 1 Dough Master
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Dough Master"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Dough Master"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Dough Master",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Dough Master"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Dough Master"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Shred Endangering Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Azlan",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Azlan"].Level) .. [[
 
 Objective: Kill 4 Azlan
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Azlan"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Azlan"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Azlan",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Azlan"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Azlan"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "The Volcano",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 The Volcano"].Level) .. [[
 
 Objective: Kill 4 The Volcano
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 The Volcano"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 The Volcano"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 The Volcano",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 The Volcano"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 The Volcano"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "The Ice King",
					Action = "NextDialogue",
					Dialogues = function()
						local theIceKingLv3350 = workspace.Monster.Boss:FindFirstChild("The Ice King [Lv. 3350]")

						if theIceKingLv3350 then
							return {
								{
									Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 The Ice King"].Level) .. " \n Objective: " .. "Kill 1 The Ice King" .. "\n <Color=Green>$" .. _G.Suffix_Comma(QuestManager["Kill 1 The Ice King"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 The Ice King"].Rewards.exp) .. " Exp.",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Confirm",
											Action = "QuestAccepted",
											QuestName = "Kill 1 The Ice King",
											QuestData = {
												LevelNeed = QuestManager["Kill 1 The Ice King"].Level,
												SuccessQuest = "Quest Accepted.",
												LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 The Ice King"].Level) .. " to accept this quest."
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Abandon",
											Action = "Close"
										}
									}
								}
							}
						end

						if theIceKingLv3350 then
							return
						end

						if _G.CheckMaterialClient(localPlayer, "Ice Crystal") then
							return {
								{
									Chat = "Do you want to use " .. "Ice Crystal" .. " to \n <Color=Red>summon " .. "The Ice King" .. "<Color=/> and defeat him? \n <Color=Green>$" .. _G.Suffix_Comma(QuestManager["Kill 1 The Ice King"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 The Ice King"].Rewards.exp) .. " Exp.",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Confirm",
											Action = "QuestSpawnBoss",
											QuestName = "Kill 1 The Ice King",
											QuestData = {
												LevelNeed = QuestManager["Kill 1 The Ice King"].Level,
												QuestName = "Kill 1 The Ice King",
												BossName = "The Ice King [Lv. 3350]",
												AI_Name = "The Ice King",
												MaterialNeed = "Ice Crystal",
												SuccessQuest = "Quest Accepted.",
												LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 The Ice King"].Level) .. " to accept this quest."
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Abandon",
											Action = "Close"
										}
									}
								}
							}
						end

						return {
							{
								Chat = "You needed <Color=Red>Ice Crystal <Color=/>in order to start this quests.",
								Buttons = {
									{
										ButtonType = "Button1",
										ButtonText = "How?",
										Action = "NextDialogue",
										Dialogues = {
											{
												Chat = "Try killing <Color=Red>Azlans.",
												Buttons = {
													{
														ButtonType = "Button1",
														ButtonText = "Well",
														Action = "Close"
													},
													{
														ButtonType = "Button3",
														ButtonText = "Return",
														Action = "Return"
													}
												}
											}
										}
									},
									{
										ButtonType = "Button2",
										ButtonText = "Return",
										Action = "Return"
									},
									{
										ButtonType = "Button3",
										ButtonText = "Abandon",
										Action = "Close"
									}
								}
							}
						}
					end
				},
				{
					ButtonType = "Button4",
					ButtonText = "The Crimson Demon",
					Action = "NextDialogue",
					Dialogues = function()
						local theCrimsonDemonLv3375 = workspace.Monster.Boss:FindFirstChild("The Crimson Demon [Lv. 3375]")

						if theCrimsonDemonLv3375 then
							return {
								{
									Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 The Crimson Demon"].Level) .. " \n Objective: " .. "Kill 1 The Crimson Demon" .. "\n <Color=Green>$" .. _G.Suffix_Comma(QuestManager["Kill 1 The Crimson Demon"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 The Crimson Demon"].Rewards.exp) .. " Exp.",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Confirm",
											Action = "QuestAccepted",
											QuestName = "Kill 1 The Crimson Demon",
											QuestData = {
												LevelNeed = QuestManager["Kill 1 The Crimson Demon"].Level,
												SuccessQuest = "Quest Accepted.",
												LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 The Crimson Demon"].Level) .. " to accept this quest."
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Abandon",
											Action = "Close"
										}
									}
								}
							}
						end

						if theCrimsonDemonLv3375 then
							return
						end

						if _G.CheckMaterialClient(localPlayer, "Magma Crystal") then
							return {
								{
									Chat = "Do you want to use " .. "Magma Crystal" .. " to <Color=Red>summon " .. "The Crimson Demon" .. "<Color=/> and defeat him? \n <Color=Green>$" .. _G.Suffix_Comma(QuestManager["Kill 1 The Crimson Demon"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 The Crimson Demon"].Rewards.exp) .. " Exp.",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Confirm",
											Action = "QuestSpawnBoss",
											QuestName = "Kill 1 The Crimson Demon",
											QuestData = {
												LevelNeed = QuestManager["Kill 1 The Crimson Demon"].Level,
												QuestName = "Kill 1 The Crimson Demon",
												BossName = "The Crimson Demon [Lv. 3375]",
												AI_Name = "The Crimson Demon",
												MaterialNeed = "Magma Crystal",
												SuccessQuest = "Quest Accepted.",
												LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 The Crimson Demon"].Level) .. " to accept this quest."
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Abandon",
											Action = "Close"
										}
									}
								}
							}
						end

						return {
							{
								Chat = "You needed <Color=Red>Magma Crystal <Color=/>in order to start this quests.",
								Buttons = {
									{
										ButtonType = "Button1",
										ButtonText = "How?",
										Action = "NextDialogue",
										Dialogues = {
											{
												Chat = "Try killing <Color=Red>The Volcano.",
												Buttons = {
													{
														ButtonType = "Button1",
														ButtonText = "Well",
														Action = "Close"
													},
													{
														ButtonType = "Button3",
														ButtonText = "Return",
														Action = "Return"
													}
												}
											}
										}
									},
									{
										ButtonType = "Button2",
										ButtonText = "Return",
										Action = "Return"
									},
									{
										ButtonType = "Button3",
										ButtonText = "Abandon",
										Action = "Close"
									}
								}
							}
						}
					end
				},
				{
					ButtonType = "Button5",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Skull Pirate Island Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Dark Beard Servant",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Dark Beard Servant"].Level) .. [[
 
 Objective: Kill 4 Dark Beard Servant 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Dark Beard Servant"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Dark Beard Servant"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Dark Beard Servant",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Dark Beard Servant"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Dark Beard Servant"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Supreme Swordman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Supreme Swordman"].Level) .. [[
 
 Objective: Kill 1 Supreme Swordman 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Supreme Swordman"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Supreme Swordman"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Supreme Swordman",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Supreme Swordman"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Supreme Swordman"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Sally",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Sally"].Level) .. [[
 
 Objective: Kill 1 Sally 
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Sally"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Sally"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Sally",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Sally"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Sally"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Dark Beard",
					Action = "NextDialogue",
					Dialogues = function()
						local darkBeardLv3475 = workspace.Monster.Boss:FindFirstChild("Dark Beard [Lv. 3475]")

						if darkBeardLv3475 then
							return {
								{
									Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Dark Beard"].Level) .. " \n Objective: " .. "Kill 1 Dark Beard" .. "\n <Color=Green>$" .. _G.Suffix_Comma(QuestManager["Kill 1 Dark Beard"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Dark Beard"].Rewards.exp) .. " Exp.",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Confirm",
											Action = "QuestAccepted",
											QuestName = "Kill 1 Dark Beard",
											QuestData = {
												LevelNeed = QuestManager["Kill 1 Dark Beard"].Level,
												SuccessQuest = "Quest Accepted.",
												LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Dark Beard"].Level) .. " to accept this quest."
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Abandon",
											Action = "Close"
										}
									}
								}
							}
						end

						if darkBeardLv3475 then
							return
						end

						if _G.CheckMaterialClient(localPlayer, "Dark Beard's Totem") then
							return {
								{
									Chat = "Do you want to use " .. "Dark Beard's Totem" .. " to \n <Color=Red>summon " .. "Dark Beard" .. "<Color=/> and defeat him? \n <Color=Green>$" .. _G.Suffix_Comma(QuestManager["Kill 1 Dark Beard"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Dark Beard"].Rewards.exp) .. " Exp.",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Confirm",
											Action = "QuestSpawnBoss",
											QuestName = "Kill 1 Dark Beard",
											QuestData = {
												LevelNeed = QuestManager["Kill 1 Dark Beard"].Level,
												QuestName = "Kill 1 Dark Beard",
												BossName = "Dark Beard [Lv. 3475]",
												AI_Name = "Dark Beard",
												MaterialNeed = "Dark Beard's Totem",
												SuccessQuest = "Quest Accepted.",
												LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Dark Beard"].Level) .. " to accept this quest."
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Abandon",
											Action = "Close"
										}
									}
								}
							}
						end

						return {
							{
								Chat = "You needed <Color=Red>Dark Beard's Totem <Color=/>in order to start this quests.",
								Buttons = {
									{
										ButtonType = "Button1",
										ButtonText = "How?",
										Action = "NextDialogue",
										Dialogues = {
											{
												Chat = "You can get permission from <Color=Red>any enemies on the island by killing them.",
												Buttons = {
													{
														ButtonType = "Button1",
														ButtonText = "Well",
														Action = "Close"
													},
													{
														ButtonType = "Button3",
														ButtonText = "Return",
														Action = "Return"
													}
												}
											}
										}
									},
									{
										ButtonType = "Button2",
										ButtonText = "Return",
										Action = "Return"
									},
									{
										ButtonType = "Button3",
										ButtonText = "Abandon",
										Action = "Close"
									}
								}
							}
						}
					end
				},
				{
					ButtonType = "Button5",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Soldier Head Quater 1 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Vice Admiral",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 5 Vice Admiral"].Level) .. [[
 
 Objective: Kill 5 Vice Admiral
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 5 Vice Admiral"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 5 Vice Admiral"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 5 Vice Admiral",
									QuestData = {
										LevelNeed = QuestManager["Kill 5 Vice Admiral"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 5 Vice Admiral"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Pondere",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Pondere"].Level) .. [[
 
 Objective: Kill 1 Pondere
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Pondere"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Pondere"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Pondere",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Pondere"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Pondere"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Soldier Head Quater 2 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Hefty",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Hefty"].Level) .. [[
 
 Objective: Kill 1 Hefty
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Hefty"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Hefty"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Hefty",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Hefty"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Hefty"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Lucidus",
					Action = "NextDialogue",
					Dialogues = function()
						local lucidusLv3575 = workspace.Monster.Boss:FindFirstChild("Lucidus [Lv. 3575]")

						if lucidusLv3575 then
							return {
								{
									Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Lucidus"].Level) .. " \n Objective: " .. "Kill 1 Lucidus" .. "\n <Color=Green>$" .. _G.Suffix_Comma(QuestManager["Kill 1 Lucidus"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Lucidus"].Rewards.exp) .. " Exp.",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Confirm",
											Action = "QuestAccepted",
											QuestName = "Kill 1 Lucidus",
											QuestData = {
												LevelNeed = QuestManager["Kill 1 Lucidus"].Level,
												SuccessQuest = "Quest Accepted.",
												LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Lucidus"].Level) .. " to accept this quest."
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Abandon",
											Action = "Close"
										}
									}
								}
							}
						end

						if lucidusLv3575 then
							return
						end

						if _G.CheckMaterialClient(localPlayer, "Lucidus's Totem") then
							return {
								{
									Chat = "Do you want to use " .. "Lucidus's Totem" .. " to \n <Color=Red>summon " .. "Lucidus" .. "<Color=/> and defeat him? \n <Color=Green>$" .. _G.Suffix_Comma(QuestManager["Kill 1 Lucidus"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Lucidus"].Rewards.exp) .. " Exp.",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Confirm",
											Action = "QuestSpawnBoss",
											QuestName = "Kill 1 Lucidus",
											QuestData = {
												LevelNeed = QuestManager["Kill 1 Lucidus"].Level,
												QuestName = "Kill 1 Lucidus",
												BossName = "Lucidus [Lv. 3575]",
												AI_Name = "Lucidus",
												MaterialNeed = "Lucidus's Totem",
												SuccessQuest = "Quest Accepted.",
												LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Lucidus"].Level) .. " to accept this quest."
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Abandon",
											Action = "Close"
										}
									}
								}
							}
						end

						return {
							{
								Chat = "You needed <Color=Red>Lucidus's Totem <Color=/>in order to start this quests.",
								Buttons = {
									{
										ButtonType = "Button1",
										ButtonText = "How?",
										Action = "NextDialogue",
										Dialogues = {
											{
												Chat = "You can get permission from <Color=Red>any enemies on the island by killing them.",
												Buttons = {
													{
														ButtonType = "Button1",
														ButtonText = "Well",
														Action = "Close"
													},
													{
														ButtonType = "Button3",
														ButtonText = "Return",
														Action = "Return"
													}
												}
											}
										}
									},
									{
										ButtonType = "Button2",
										ButtonText = "Return",
										Action = "Return"
									},
									{
										ButtonType = "Button3",
										ButtonText = "Abandon",
										Action = "Close"
									}
								}
							}
						}
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Fiore 1 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Fiore Gladiator",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 6 Fiore Gladiator"].Level) .. [[
 
 Objective: Kill 6 Fiore Gladiator
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 6 Fiore Gladiator"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 6 Fiore Gladiator"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 6 Fiore Gladiator",
									QuestData = {
										LevelNeed = QuestManager["Kill 6 Fiore Gladiator"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 6 Fiore Gladiator"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Fiore Fighter",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 6 Fiore Fighter"].Level) .. [[
 
 Objective: Kill 6 Fiore Fighter
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 6 Fiore Fighter"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 6 Fiore Fighter"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 6 Fiore Fighter",
									QuestData = {
										LevelNeed = QuestManager["Kill 6 Fiore Fighter"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 6 Fiore Fighter"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Fiore 2 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Fiore Pirate",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 7 Fiore Pirate"].Level) .. [[
 
 Objective: Kill 7 Fiore Pirate
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 7 Fiore Pirate"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 7 Fiore Pirate"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 7 Fiore Pirate",
									QuestData = {
										LevelNeed = QuestManager["Kill 7 Fiore Pirate"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 7 Fiore Pirate"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Lomeo",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Lomeo"].Level) .. [[
 
 Objective: Kill 1 Lomeo
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Lomeo"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Lomeo"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Lomeo",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Lomeo"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Lomeo"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Fiore 3 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Prince Aria",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Prince Aria"].Level) .. [[
 
 Objective: Kill 1 Prince Aria
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Prince Aria"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Prince Aria"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Prince Aria",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Prince Aria"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Prince Aria"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Devastate",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Devastate"].Level) .. [[
 
 Objective: Kill 1 Devastate
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Devastate"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Devastate"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Devastate",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Devastate"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Devastate"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Physicus",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Physicus"].Level) .. [[
 
 Objective: Kill 1 Physicus
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Physicus"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Physicus"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Physicus",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Physicus"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Physicus"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Floffy",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Floffy"].Level) .. [[
 
 Objective: Kill 1 Floffy
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Floffy"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Floffy"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Floffy",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Floffy"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Floffy"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Fiore 4 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Dead Troupe",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Dead Troupe"].Level) .. [[
 
 Objective: Kill 4 Dead Troupe
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Dead Troupe"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Dead Troupe"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Dead Troupe",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Dead Troupe"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Dead Troupe"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Dead Troupe Captain",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Dead Troupe Captain"].Level) .. [[
 
 Objective: Kill 4 Dead Troupe Captain
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Dead Troupe Captain"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Dead Troupe Captain"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Dead Troupe Captain",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Dead Troupe Captain"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Dead Troupe Captain"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Ryu",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Ryu"].Level) .. [[
 
 Objective: Kill 1 Ryu
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Ryu"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Ryu"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Ryu",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Ryu"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Ryu"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["The Unearthly 1 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Deep Diver",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Deep Diver"].Level) .. [[
 
 Objective: Kill 4 Deep Diver
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Deep Diver"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Deep Diver"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Deep Diver",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Deep Diver"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Deep Diver"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Fugitive",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill Fugitive"].Level) .. [[
 
 Objective: Kill Fugitive
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill Fugitive"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill Fugitive"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill Fugitive",
									QuestData = {
										LevelNeed = QuestManager["Kill Fugitive"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill Fugitive"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Deep one Villager",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Deep one Villager"].Level) .. [[
 
 Objective: Kill 4 Deep one Villager
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Deep one Villager"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Deep one Villager"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Deep one Villager",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Deep one Villager"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Deep one Villager"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["The Unearthly 2 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Fishman Guardian",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 6 Fishman Guardian"].Level) .. [[
 
 Objective: Kill 6 Fishman Guardian
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 6 Fishman Guardian"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 6 Fishman Guardian"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 6 Fishman Guardian",
									QuestData = {
										LevelNeed = QuestManager["Kill 6 Fishman Guardian"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 6 Fishman Guardian"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "The deep one",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill The deep one"].Level) .. [[
 
 Objective: Kill The deep one
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill The deep one"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill The deep one"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill The deep one",
									QuestData = {
										LevelNeed = QuestManager["Kill The deep one"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill The deep one"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Fishman King's Guard",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill Fishman King's Guard"].Level) .. [[
 
 Objective: Kill Fishman King's Guard
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill Fishman King's Guard"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill Fishman King's Guard"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill Fishman King's Guard",
									QuestData = {
										LevelNeed = QuestManager["Kill Fishman King's Guard"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill Fishman King's Guard"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["The Shallow 1 Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Jungle Gorilla",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 5 Jungle Gorilla"].Level) .. [[
 
 Objective: Kill 5 Jungle Gorilla
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 5 Jungle Gorilla"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 5 Jungle Gorilla"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 5 Jungle Gorilla",
									QuestData = {
										LevelNeed = QuestManager["Kill 5 Jungle Gorilla"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 5 Jungle Gorilla"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Wilderness Gorilla",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 5 Wilderness Gorilla"].Level) .. [[
 
 Objective: Kill 5 Wilderness Gorilla
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 5 Wilderness Gorilla"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 5 Wilderness Gorilla"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 5 Wilderness Gorilla",
									QuestData = {
										LevelNeed = QuestManager["Kill 5 Wilderness Gorilla"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 5 Wilderness Gorilla"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Jungle Ape",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 5 Jungle Ape"].Level) .. [[
 
 Objective: Kill 5 Jungle Ape
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 5 Jungle Ape"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 5 Jungle Ape"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 5 Jungle Ape",
									QuestData = {
										LevelNeed = QuestManager["Kill 5 Jungle Ape"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 5 Jungle Ape"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Cyborg Gorilla",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Cyborg Gorilla"].Level) .. [[
 
 Objective: Kill 1 Cyborg Gorilla
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Cyborg Gorilla"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Cyborg Gorilla"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Cyborg Gorilla",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Cyborg Gorilla"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Cyborg Gorilla"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Drakenhold Fortress Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Ripcurrent Raider",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Ripcurrent Raider"].Level) .. [[
 
 Objective: Kill 1 Ripcurrent Raider
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Ripcurrent Raider"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Ripcurrent Raider"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Ripcurrent Raider",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Ripcurrent Raider"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Ripcurrent Raider"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Tidal Warrior",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Tidal Warrior"].Level) .. [[
 
 Objective: Kill 1 Tidal Warrior
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Tidal Warrior"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Tidal Warrior"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Tidal Warrior",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Tidal Warrior"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Tidal Warrior"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Ocean Gladiator",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Ocean Gladiator"].Level) .. [[
 
 Objective: Kill 1 Ocean Gladiator
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Ocean Gladiator"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Ocean Gladiator"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Ocean Gladiator",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Ocean Gladiator"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Ocean Gladiator"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Forgotten Coliseum Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Deepfire Combatant",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Deepfire Combatant"].Level) .. [[
 
 Objective: Kill 4 Deepfire Combatant
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Deepfire Combatant"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Deepfire Combatant"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Deepfire Combatant",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Deepfire Combatant"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Deepfire Combatant"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Electro Abyss Warrior",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Electro Abyss Warrior"].Level) .. [[
 
 Objective: Kill 1 Electro Abyss Warrior
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Electro Abyss Warrior"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Electro Abyss Warrior"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Electro Abyss Warrior",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Electro Abyss Warrior"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Electro Abyss Warrior"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Inferno Diver",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Inferno Diver"].Level) .. [[
 
 Objective: Kill 1 Inferno Diver
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Inferno Diver"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Inferno Diver"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Inferno Diver",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Inferno Diver"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Inferno Diver"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Forgotten Coliseum Quest 2"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Tempest Tidebreaker",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Tempest Tidebreaker"].Level) .. [[
 
 Objective: Kill 1 Tempest Tidebreaker
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Tempest Tidebreaker"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Tempest Tidebreaker"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Tempest Tidebreaker",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Tempest Tidebreaker"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Tempest Tidebreaker"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Abyssal Swordsman",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Abyssal Swordsman"].Level) .. [[
 
 Objective: Kill 1 Abyssal Swordsman
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Abyssal Swordsman"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Abyssal Swordsman"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Abyssal Swordsman",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Abyssal Swordsman"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Abyssal Swordsman"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Land of Detention Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Rogue Prisoner",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Rogue Prisoner"].Level) .. [[
 
 Objective: Kill 4 Rogue Prisoner
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Rogue Prisoner"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Rogue Prisoner"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Rogue Prisoner",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Rogue Prisoner"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Rogue Prisoner"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Prisoner Buccaneer",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 4 Prisoner Buccaneer"].Level) .. [[
 
 Objective: Kill 4 Prisoner Buccaneer
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 4 Prisoner Buccaneer"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 4 Prisoner Buccaneer"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 4 Prisoner Buccaneer",
									QuestData = {
										LevelNeed = QuestManager["Kill 4 Prisoner Buccaneer"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 4 Prisoner Buccaneer"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Prisoner of Gravity",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Prisoner of Gravity"].Level) .. [[
 
 Objective: Kill 1 Prisoner of Gravity
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Prisoner of Gravity"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Prisoner of Gravity"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Prisoner of Gravity",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Prisoner of Gravity"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Prisoner of Gravity"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Crownfall Isle Quest"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Veyzor",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Veyzor"].Level) .. [[
 
 Objective: Kill 1 Veyzor <Color=Purple>(Normal <Img=116834446841692>)
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Veyzor"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Veyzor"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Veyzor",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Veyzor"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Veyzor"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Chaos Crab",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Chaos Crab"].Level) .. [[
 
 Objective: Kill 1 Chaos Crab <Color=Purple>(Hard <Img=116834446841692>)
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Chaos Crab"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Chaos Crab"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Chaos Crab",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Chaos Crab"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Chaos Crab"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Craberno",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Craberno"].Level) .. [[
 
 Objective: Kill 1 Craberno <Color=Purple>(Hard <Img=116834446841692>)
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Craberno"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Craberno"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Craberno",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Craberno"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Craberno"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Primeval Isle Quest 1"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Obsidian Seeker",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 8 Obsidian Seeker"].Level) .. [[
 
 Objective: Kill 8 Obsidian Seeker
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 8 Obsidian Seeker"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 8 Obsidian Seeker"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 8 Obsidian Seeker",
									QuestData = {
										LevelNeed = QuestManager["Kill 8 Obsidian Seeker"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 8 Obsidian Seeker"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Forgotten Delver",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 8 Forgotten Delver"].Level) .. [[
 
 Objective: Kill 8 Forgotten Delver
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 8 Forgotten Delver"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 8 Forgotten Delver"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 8 Forgotten Delver",
									QuestData = {
										LevelNeed = QuestManager["Kill 8 Forgotten Delver"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 8 Forgotten Delver"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Blackreach Scout",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 8 Blackreach Scout"].Level) .. [[
 
 Objective: Kill 8 Blackreach Scout
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 8 Blackreach Scout"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 8 Blackreach Scout"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 8 Blackreach Scout",
									QuestData = {
										LevelNeed = QuestManager["Kill 8 Blackreach Scout"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 8 Blackreach Scout"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Nightbound Explorer",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Nightbound Explorer"].Level) .. [[
 
 Objective: Kill 1 Nightbound Explorer
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Nightbound Explorer"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Nightbound Explorer"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Nightbound Explorer",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Nightbound Explorer"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Nightbound Explorer"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["Primeval Isle Quest 2"] = {
		{
			Chat = "Select a quest.",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Ruinstep Nomad",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 8 Ruinstep Nomad"].Level) .. [[
 
 Objective: Kill 8 Ruinstep Nomad
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 8 Ruinstep Nomad"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 8 Ruinstep Nomad"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 8 Ruinstep Nomad",
									QuestData = {
										LevelNeed = QuestManager["Kill 8 Ruinstep Nomad"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 8 Ruinstep Nomad"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button2",
					ButtonText = "Ancient Wayfarer",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Ancient Wayfarer"].Level) .. [[
 
 Objective: Kill 1 Ancient Wayfarer
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Ancient Wayfarer"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Ancient Wayfarer"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Ancient Wayfarer",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Ancient Wayfarer"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Ancient Wayfarer"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Depths Voyager",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 8 Depths Voyager"].Level) .. [[
 
 Objective: Kill 8 Depths Voyager
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 8 Depths Voyager"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 8 Depths Voyager"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 8 Depths Voyager",
									QuestData = {
										LevelNeed = QuestManager["Kill 8 Depths Voyager"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 8 Depths Voyager"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button4",
					ButtonText = "Allosaurus",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Allosaurus"].Level) .. [[
 
 Objective: Kill 1 Allosaurus
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Allosaurus"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Allosaurus"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Allosaurus",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Allosaurus"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Allosaurus"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button5",
					ButtonText = "Spinosaurus",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Level Required: " .. _G.Suffix_Comma(QuestManager["Kill 1 Spinosaurus"].Level) .. [[
 
 Objective: Kill 1 Spinosaurus
 <Color=Green>$]] .. _G.Suffix_Comma(QuestManager["Kill 1 Spinosaurus"].Rewards.beli) .. " \n <Color=Yellow>" .. _G.Suffix_Comma(QuestManager["Kill 1 Spinosaurus"].Rewards.exp) .. " Exp.",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "QuestAccepted",
									QuestName = "Kill 1 Spinosaurus",
									QuestData = {
										LevelNeed = QuestManager["Kill 1 Spinosaurus"].Level,
										SuccessQuest = "Quest Accepted.",
										LevelLow = "You must be Level " .. _G.Suffix_Comma(QuestManager["Kill 1 Spinosaurus"].Level) .. " to accept this quest."
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Abandon",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button6",
					ButtonText = "Abandon",
					Action = "Close"
				}
			}
		}
	},
	["A Fruit Remover"] = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						if localPlayer.PlayerStats.DFName.Value == "None" then
							return {
								{
									Chat = "You haven't become a Legacy Fruit user yet.",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "...",
											Action = "Close"
										},
										{
											ButtonType = "Button2",
											ButtonText = "Why?",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Never mind, it's nothing",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "OK",
															Action = "Close"
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "...",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						return {
							{
								Chat = "What's up, adventurer? I am a wizard who can erase the power of Legacy Fruits. What do you want?",
								Buttons = {
									{
										ButtonType = "Button1",
										ButtonText = "Erase",
										Action = "NextDialogue",
										Dialogues = {
											{
												Chat = "Do you truly wish to erase your Legacy Fruit power? <Color=Red>It cannot be reversed once accepted.",
												Buttons = {
													{
														ButtonType = "Button1",
														ButtonText = "Yeah",
														Action = "RemoveDFPower",
														EndChat = "[Your Legacy Fruit power has been removed.]",
														EndChatDoingSkill = "[You are holding skill.]"
													},
													{
														ButtonType = "Button2",
														ButtonText = "Return",
														Action = "Return"
													},
													{
														ButtonType = "Button3",
														ButtonText = "Nah",
														Action = "Close"
													}
												}
											}
										}
									},
									{
										ButtonType = "Button2",
										ButtonText = "Return",
										Action = "Return"
									},
									{
										ButtonType = "Button3",
										ButtonText = "Nevermind",
										Action = "Close"
									}
								}
							}
						}
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	BTQuest1 = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						if not (_G.CheckSwordClient(localPlayer, "Hell Sword") and _G.CheckSwordClient(
							localPlayer,
							"Ethereal"
						)) then
							return {
								{
									Chat = "[Requires 2 related samurai swords.]",
									ChatTH = "[ต้องการดาบซามูไรที่เกี่ยวข้อง 2 เล่ม]",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if not _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") then
							return {
								{
									Chat = "That warrior's spirit is still there. I can feel it.",
									ChatTH = "จิตวิญญาณของนักรบคนนั้นยังอยู่ ข้าสัมผัสได้",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Next",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Go experience it. If i were you, you would definitely know where it is.",
													ChatTH = "ไปสัมผัสมันดูสิ หากเป็นเจ้าจะต้องรู้แน่นอนว่ามันอยู่ที่ไหน",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Chapter 1",
															Action = "AddQuestProgress",
															QuestProgressData = {
																QuestProgressName = "Bloodmoon Twins Quest",
																QuestChapter = 1
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") == 1 then
							return {
								{
									Chat = "You must try looking for it. If i were you, you would definitely know.",
									ChatTH = "เจ้าต้องลองตามหาดู ถ้าเป็นเจ้าต้องรู้แน่นอน",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") == 2 then
							return {
								{
									Chat = "What the spirit said meant: <Color=Red>'Never Say Goodbye...'<Color=/>",
									ChatTH = "ที่วิญญาณนั่นพูดมีความหมายว่า 'Never Say Goodbye...'",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Next",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "I think you need the power to communicate with spirits yourself. Try finding the <Color=Red>Medium<Color=/>, then talk to him.",
													ChatTH = "ข้าว่าเจ้าต้องการพลังที่จะสื่อสารกับวิญญาณเองซะแล้วล่ะ ลองตามหาผู้ส่งสารแล้วคุยกับเขาดูสิ",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Yeah",
															Action = "NextDialogue",
															Dialogues = {
																{
																	Chat = "Well, now I can help as much as I can. Good luck to you!",
																	ChatTH = "เอาล่ะ ตอนนี้ข้าช่วยเท่าที่ทำได้แล้ว ขอให้เจ้าโชคดี",
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Chapter 3",
																			Action = "AddQuestProgress",
																			QuestProgressData = {
																				QuestProgressName = "Bloodmoon Twins Quest",
																				QuestChapter = 3
																			}
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "...",
																			Action = "Close"
																		}
																	}
																}
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						return {
							{
								Chat = "There's nothing more I can do.",
								ChatTH = "ไม่มีสิ่งที่ข้าทำได้อีกแล้ว",
								Buttons = {
									{
										ButtonType = "Button3",
										ButtonText = "...",
										Action = "Close"
									}
								}
							}
						}
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	BTQuest2 = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						if not (_G.CheckSwordClient(localPlayer, "Hell Sword") and _G.CheckSwordClient(
							localPlayer,
							"Ethereal"
						)) then
							return {
								{
									Chat = "[Requires 2 related samurai swords.]",
									ChatTH = "[ต้องการดาบซามูไรที่เกี่ยวข้อง 2 เล่ม]",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if not _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") then
							return {
								{
									Chat = "Who are you!?",
									ChatTH = "เจ้าเป็นใคร",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") == 3 then
							return {
								{
									Chat = "Do you want to learn the power to communicate with spirits?",
									ChatTH = "เจ้าอยากจะเรียนรู้พลังในการสื่อสารกับวิญญาณอย่างนั้นหรอ",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Yeah",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "I have a test. Prepare your Hell sword. Do you insist on starting the test?",
													ChatTH = "ข้ามีบททบสอบ เตรียมดาบนรกของเจ้าให้พร้อม เจ้ายืนยันที่จะเริ่มบททดสอบหรือไม่",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Chapter 4",
															Action = "Bloodmoon Twins Quest Chapter 4"
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") == 4 then
							return {
								{
									Chat = "You now have the power of a <Color=Red>Medium. <Color=/>Try searching for that ghost at night",
									ChatTH = "ตอนนี้เจ้าได้พลังของผู้ส่งสารแล้ว ลองตามหาวิญญาณตนนั้นในตอนกลางคืนดูสิ",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") == 6 then
							return {
								{
									Chat = "You have come to your final test. Are you ready? The ending may be different from the last test.",
									ChatTH = "เจ้ามาถึงบททดสอบสุดท้ายแล้ว เจ้าพร้อมมั้ยล่ะ ตอนนี้ตอนจบอาจจะต่างจากบททดสอบที่แล้ว",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "(Final Chapter)",
											Action = "Bloodmoon Twins Quest Final Chapter"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") ~= 7 then
							return {
								{
									Chat = "???",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckSwordClient(localPlayer, "Bloodmoon Twins") then
							return {
								{
									Chat = "It's actually a good sword. Don't you think?",
									ChatTH = "เป็นดาบที่ไม่เลวเลย เจ้าคิดงั้นมั้ยล่ะ...",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						return {
							{
								Chat = "You have passed all the tests. Now, what do you want next?",
								ChatTH = "เจ้าผ่านบททดสอบทั้งหมดแล้ว เอาล่ะเจ้าอยากได้อะไรต่อ",
								Buttons = {
									{
										ButtonType = "Button1",
										ButtonText = "Bloodmoon Twins",
										Action = "NextDialogue",
										Dialogues = {
											{
												Chat = [[
Sword: Bloodmoon Twins <Img=16982799949> <Color=Pink>(Mythical) 
 <Color=/>Price: <Color=Green> $22,500,000]],
												ChatTH = [[
ดาบ: Bloodmoon Twins <Img=16982799949> <Color=Pink>(Mythical) 
 <Color=/>ราคา: <Color=Green> $22,500,000]],
												Buttons = {
													{
														ButtonType = "Button1",
														ButtonText = "Buy",
														Action = "Buy Bloodmoon Twins",
														ButtonData = {
															Price = 22500000,
															TextSuccess = "<AnimateStyle=Rainbow>Successfully purchased a sword.",
															TextNoMoney = "<AnimateStyle=Appear><Color=Red>Not enough Money $!"
														}
													},
													{
														ButtonType = "Button2",
														ButtonText = "Return",
														Action = "Return"
													},
													{
														ButtonType = "Button3",
														ButtonText = "Nevermind",
														Action = "Close"
													}
												}
											}
										}
									},
									{
										ButtonType = "Button2",
										ButtonText = "Return",
										Action = "Return"
									},
									{
										ButtonType = "Button3",
										ButtonText = "Nevermind",
										Action = "Close"
									}
								}
							}
						}
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	BTQuest3 = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						if not (_G.CheckSwordClient(localPlayer, "Hell Sword") and _G.CheckSwordClient(
							localPlayer,
							"Ethereal"
						)) then
							return {
								{
									Chat = "[Requires 2 related samurai swords.]",
									ChatTH = "[ต้องการดาบซามูไรที่เกี่ยวข้อง 2 เล่ม]",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if not _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") then
							return {
								{
									Chat = "...!?",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") == 4 then
							return {
								{
									Chat = "<Color=Red>The Blood Moon <Color=/>appears only in the 3rd sea every 3 nights.",
									ChatTH = "เจ้าอยากจะเรียนรู้พลังในการสื่อสารกับวิญญาณอย่างนั้นหรอ",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Next",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Alright, let's start the test. Defeat 100 monkeys on the night of the <Color=Red>Blood Moon.",
													ChatTH = "เอาล่ะ มาเริ่มบททดสอบกันเลย กำจัดลิง 100 ตัวในคืนจันทร์สีเลือด",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Chapter 5",
															Action = "AddQuestProgress",
															QuestProgressData = {
																QuestProgressName = "Bloodmoon Twins Quest",
																QuestChapter = 5
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") == 5 then
							local v = _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Monkey")

							if not v then
								return {
									{
										Chat = "Monkeys to be exterminated on the night of the Blood Moon: 100 remaining.",
										ChatTH = "ลิงที่ต้องกำจัดในคืนจันทร์สีเลือด เหลืออยู่: 100 ตัว",
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "Done",
												Action = "Close"
											},
											{
												ButtonType = "Button3",
												ButtonText = "Nevermind",
												Action = "Close"
											}
										}
									}
								}
							end

							if v == 100 then
								return {
									{
										Chat = "You have succeeded. Thank you so much for helping to carry out my will.",
										ChatTH = "เจ้าทำสำเร็จแล้ว ขอบคุณทำทำให้เจตนารมณ์ของข้างเป็นจริง",
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "Chapter 6",
												Action = "AddQuestProgress",
												QuestProgressData = {
													QuestProgressName = "Bloodmoon Twins Quest",
													QuestChapter = 6
												}
											},
											{
												ButtonType = "Button3",
												ButtonText = "Nevermind",
												Action = "Close"
											}
										}
									}
								}
							end

							local v2 = 100 - v
							return {
								{
									Chat = "Monkeys to be exterminated on the night of the Blood Moon: " .. v2 .. " remaining.",
									ChatTH = "ลิงที่ต้องกำจัดในคืนจันทร์สีเลือด เหลืออยู่: " .. v2 .. " ตัว",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Fine",
											Action = "Close"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						elseif _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") == 6 then
							return {
								{
									Chat = "Thank you so much for helping to carry out my will.",
									ChatTH = "ขอบคุณมากที่ทำตามเจตนารมณ์ของข้า",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						else
							return {
								{
									Chat = "???",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	BTStone = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						if not (_G.CheckSwordClient(localPlayer, "Hell Sword") and _G.CheckSwordClient(
							localPlayer,
							"Ethereal"
						)) then
							return {
								{
									Chat = "[Requires 2 related samurai swords.]",
									ChatTH = "[ต้องการดาบซามูไรที่เกี่ยวข้อง 2 เล่ม]",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if not _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") then
							return {
								{
									Chat = "???",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") == 1 then
							return {
								{
									Chat = "<AnimateStyle=DarkGlitch><Color=Red>@!#*(&!@*(%!@)_#*!@)&!@#(*...",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Next",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "<AnimateStyle=Wiggle>HaHaHaHaHa!!",
													ChatTH = "<AnimateStyle=Wiggle>ฮ่าฮ่าฮ่าฮ่า!!",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Chapter 2",
															Action = "AddQuestProgress",
															QuestProgressData = {
																QuestProgressName = "Bloodmoon Twins Quest",
																QuestChapter = 2
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") == 2 then
							return {
								{
									Chat = "<AnimateStyle=Wiggle>HaHaHaHaHa HaHaHaHaHa HaHaHaHaHa HaHaHaHaHa!!",
									ChatTH = "<AnimateStyle=Wiggle>ฮ่าฮ่าฮ่าฮ่า ฮ่าฮ่าฮ่าฮ่า ฮ่าฮ่าฮ่าฮ่า ฮ่าฮ่าฮ่าฮ่า!!",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.CheckQuestProgressClient(localPlayer, "Bloodmoon Twins Quest") >= 3 then
							return {
								{
									Chat = "Never Say Goodbye...",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	["Material Dealer"] = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Hello, I have an offer regarding raw materials. Are you interested in giving it a try?",
							ChatTH = "สวัสดี ข้ามีข้อเสนอเกี่ยวกับวัตถุดิบ คุณสนใจที่จะลองดูมั้ยล่ะ?",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "SpecialShopGui",
									ButtonData = {
										GuiName = "Material Dealer"
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Nevermind",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	["Serpentforger Elwyn"] = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						local v = _G.CheckTitleClient(localPlayer, "Tyrant Slayer")
						local v2 = _G.CheckTitleClient(localPlayer, "Krakenbane")
						local v3 = _G.CheckTitleClient(localPlayer, "Shellbreaker")
						local v4 = _G.CheckTitleClient(localPlayer, "Dragonbane")
						local v5 = _G.CheckTitleClient(localPlayer, "Abyss Breaker")
						local v6 = _G.CheckTitleClient(localPlayer, "The Abyssal Reaper")
						local v7 = _G.CheckTitleClient(localPlayer, "Clawbane Hunter")
						local v8 = _G.CheckTitleClient(localPlayer, "Inferno Stalker")

						if v5 or v6 or v7 or v8 then
							return {
								{
									Chat = "It seems like you've been through a lot. I have a cool offer for you interested in checking it out?",
									ChatTH = "ดูเหมือนเจ้าจะผ่านอะไรมามากมายเลยนะเนี่ย ข้ามีอะไรข้อเสนอเจ๋งๆสนใจดูก่อนมั้ยล่ะ?",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Confirm",
											Action = "SpecialShopGui",
											ButtonData = {
												GuiName = "CraftingUI2",
												CraftWith = "Serpentforger Elwyn"
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						if v or v2 or v3 or v4 then
							return {
								{
									Chat = "You're off to a great start with the hunt. Keep it up! I'm rooting for you!",
									ChatTH = "เจ้ากำลังเริ่มต้นการล่าได้ดีเลย พยายามเข้าล่ะ ข้าเอาใจช่วย!",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						return {
							{
								Chat = "I have nothing to say to you. You're too weak!",
								ChatTH = "ข้าไม่มีอะไรจะพูดกับเจ้า เจ้ามันอ่อนปวกเปียก!",
								Buttons = {
									{
										ButtonType = "Button3",
										ButtonText = "!?",
										Action = "Close"
									}
								}
							}
						}
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	["Hexley Hallow"] = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Only once a year we get to see each other, huh? Did you miss me?",
							ChatTH = "ปีนึงจะเจอกันครั้งนึงนะเนี่ย คิดถึงข้ามั้ยล่ะ?",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Maybe",
									Action = "NextDialogue",
									Dialogues = {
										{
											Chat = "This time, I have something to offer in exchange. I forgot to mention, I really like candy",
											ChatTH = "ครั้งนี้ข้ามีอะไรจะเสนอแลกเปลี่ยน ลืมบอกไป ข้าชอบ Candy มากเลยล่ะ",
											Buttons = {
												{
													ButtonType = "Button1",
													ButtonText = "Craft",
													Action = "SpecialShopGui",
													ButtonData = {
														GuiName = "CraftingUI2",
														CraftWith = "Hexley Hallow"
													}
												},
												{
													ButtonType = "Button2",
													ButtonText = "Candy?",
													Action = "NextDialogue",
													Dialogues = function()
														local WorldsId = require(ReplicatedStorage.Chest.Modules.WorldsId)
														local v = {
															[WorldsId.Testing.FirstSea] = true,
															[WorldsId.KingLegacy.FirstSea] = true
														}
														local v2 = {
															[WorldsId.Testing.SecondSea] = true,
															[WorldsId.KingLegacy.SecondSea] = true
														}
														local v3 = {
															[WorldsId.Testing.ThirdSea] = true,
															[WorldsId.KingLegacy.ThirdSea] = true
														}

														if v[game.PlaceId] then
															return {
																{
																	Chat = "You can find Candy by defeating Zombies on the nearby islands. They only drop during the Halloween Event.",
																	ChatTH = "เจ้าสามารถตามหา Candy ได้จากการจัดการพวกซอมบี้ในเกาะใกล้ๆนี้แหละ มันดรอปเฉพาะช่วง Halloween Event เท่านั้นนะ",
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "...",
																			Action = "Close"
																		}
																	}
																}
															}
														end

														if v2[game.PlaceId] then
															return {
																{
																	Chat = "You can find Candy by defeating Skeletons on the nearby islands. They only drop during the Halloween Event.",
																	ChatTH = "เจ้าสามารถตามหา Candy ได้จากการจัดการพวกโครงกระดูกในเกาะใกล้ๆนี้แหละ มันดรอปเฉพาะช่วง Halloween Event เท่านั้นนะ",
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "...",
																			Action = "Close"
																		}
																	}
																}
															}
														end

														if v3[game.PlaceId] then
															return {
																{
																	Chat = "You can find Candy by defeating gorillas on the nearby island. They only drop during the Halloween Event!",
																	ChatTH = "เจ้าสามารถตามหา Candy ได้จากการจัดการพวกกอริลลาในเกาะใกล้ๆนี้แหละ มันดรอปเฉพาะช่วง Halloween Event เท่านั้นนะ",
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "...",
																			Action = "Close"
																		}
																	}
																}
															}
														end

														return {
															{
																Chat = "...",
																ChatTH = "...",
																Buttons = {
																	{
																		ButtonType = "Button3",
																		ButtonText = "...",
																		Action = "Close"
																	}
																}
															}
														}
													end
												},
												{
													ButtonType = "Button3",
													ButtonText = "Nevermind",
													Action = "Close"
												}
											}
										}
									}
								},
								{
									ButtonType = "Button2",
									ButtonText = "Return",
									Action = "Return"
								},
								{
									ButtonType = "Button3",
									ButtonText = "Nevermind",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	SpecialPassiveInfo = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = {
						{
							Chat = "Some things, when placed in the right spot at the right time, can have wonderful effects. Would you like to try and see what might cause these special effects?",
							ChatTH = "ของบางอย่าง ถ้าอยู่ถูกที่ถูกเวลา ก็จะทำให้มีผลพวงอันแสนวิเศษเกิดขึ้นได้ เจ้าอยากจะลองดูมั้ยล่ะว่าสิ่งไหนบ้างที่ทำให้เกิดเอฟเฟคพิเศษ",
							Buttons = {
								{
									ButtonType = "Button1",
									ButtonText = "Confirm",
									Action = "SpecialShopGui",
									ButtonData = {
										GuiName = "SpecialPassiveGUI"
									}
								},
								{
									ButtonType = "Button3",
									ButtonText = "Nevermind",
									Action = "Close"
								}
							}
						}
					}
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	SeaBeastRaceNPC = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						local v = _G.CheckQuestProgressClient(localPlayer, "Sea Beast Puzzle")

						if not v then
							return {
								{
									Chat = "The Sea Beast Race has the ability to move quickly in water and quickly restore life force.",
									ChatTH = "เผ่าเจ้าทะเลมีความสามารถในการเคลื่อนที่อย่างรวดเร็วในน้ำ และสามารถฟื้นฟูพลังชีวิตได้อย่างรวดเร็ว",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Next",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Are you interested in giving it a try?",
													ChatTH = "เจ้าสนใจที่จะลองดูมั้ยล่ะ?",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Sure",
															Action = "NextDialogue",
															Dialogues = {
																{
																	Chat = "Great, I need 100 Sea Artifacts for testing Puzzle <Color=Red>(only for the first-time payment).",
																	ChatTH = "ดีมาก ข้าต้องการ Sea Artifacts 100 ชิ้นเพื่อทดสอบการไขชิ้นส่วนปริศนา <Color=Red>(จ่ายแค่ครั้งแรกเท่านั้น)",
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Accept",
																			Action = "Sea Beast Puzzle",
																			ButtonData = {
																				Text1 = "Alright, let's get started.",
																				Text2 = "You don't have enough Sea Artifacts."
																			}
																		},
																		{
																			ButtonType = "Button2",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "Nevermind",
																			Action = "Close"
																		}
																	}
																}
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						if not v then
							return
						end

						if v == 1 then
							return {
								{
									Chat = "Would you like to test it again? This time, I won't charge a fee.",
									ChatTH = "เจ้าอยากจะทดสอบอีกรอบมั้ยล่ะ รอบนี้ข้าไม่เก็บค่าใช่จ่ายอะไรทั้งนั้น",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Yes",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "You can keep testing until you pass, little one.",
													ChatTH = "เจ้าสามารถทดสอบได้จนกว่าจะผ่านเลย เจ้าเด็กน้อย",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Puzzle",
															Action = "Sea Beast Puzzle",
															ButtonData = {
																Text1 = "Alright, let's get started."
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						if v ~= 2 then
							return {
								{
									Chat = "Hello, comrades",
									ChatTH = "ว่าไง สหาย",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						if _G.RaceClient ~= "Sea Beast" then
							return {
								{
									Chat = "Do you want to change your race to <Color=Red>Sea Beast?",
									ChatTH = "คุณต้องการเปลี่ยนเป็นเผ่าเจ้าทะเล หรือไม่",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Yeah",
											Action = "Sea Beast Puzzle",
											ButtonData = {
												Text1 = "You have changed your race to a <Color=Red>Sea Beast."
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						local v2 = _G.CheckQuestProgressClient(localPlayer, "Sea Beast V2")

						if not v2 then
							return {
								{
									Chat = "Are you interested in increasing the power of your Race?",
									ChatTH = "เจ้าสนใจที่จะเพิ่มพลังให้กับเผ่าของเจ้าหรือไม่",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Yes",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Very good. Follow my request. Right now, I want 50 Sea Artifacts",
													ChatTH = "ดีมาก จงทำตามคำขอของข้า ตอนนี่ข้าอยากได้ Sea Artifact 50 ชิ้น",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Donate",
															Action = "AddQuestProgress",
															QuestProgressData = {
																QuestProgressName = "Sea Beast V2",
																QuestChapter = 1
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						if v2 == 1 then
							return {
								{
									Chat = "I have a second request. Would you like to continue?",
									ChatTH = "ข้ามีคำขอที่ 2 อีกเจ้าต้องการที่จะทำต่อหรือไม่",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Yes",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Very good, I need 25 corals.",
													ChatTH = "ดีมากข้าต้องการ ปะการัง 25 ชิ้น",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Donate",
															Action = "AddQuestProgress",
															QuestProgressData = {
																QuestProgressName = "Sea Beast V2",
																QuestChapter = 2
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						elseif v2 == 2 then
							return {
								{
									Chat = "I have a third request. Would you like to continue?",
									ChatTH = "ข้ามีคำขอที่ 3 อีกเจ้าต้องการที่จะทำต่อหรือไม่",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Yes",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Very good, I need 10 Shark's Fin.",
													ChatTH = "ดีมากข้าต้องการ Shark's Fin 10 ชิ้น",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Donate",
															Action = "AddQuestProgress",
															QuestProgressData = {
																QuestProgressName = "Sea Beast V2",
																QuestChapter = 3
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						elseif v2 == 3 then
							return {
								{
									Chat = "I have a fourth request. Would you like to continue?",
									ChatTH = "ข้ามีคำขอที่ 4 อีกเจ้าต้องการที่จะทำต่อหรือไม่",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Yes",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Almost complete. Bring me 5 pearls.",
													ChatTH = "ดีมากข้าต้องการ Pearl 5 ชิ้น",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Donate",
															Action = "AddQuestProgress",
															QuestProgressData = {
																QuestProgressName = "Sea Beast V2",
																QuestChapter = 4
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						elseif v2 == 4 then
							return {
								{
									Chat = "I have final request. Would you like to continue?",
									ChatTH = "ข้ามีคำขอที่ 5 อีกเจ้าต้องการที่จะทำต่อหรือไม่",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Yes",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Okay, here's my last request: 1 Aqua Gem.",
													ChatTH = "เอาล่ะนี่คำขอสุดท้ายแล้ว Aqua Gem 1 ชิ้น",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Donate",
															Action = "AddQuestProgress",
															QuestProgressData = {
																QuestProgressName = "Sea Beast V2",
																QuestChapter = 5
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						return {
							{
								Chat = "Hello, comrades",
								ChatTH = "ว่าไง สหาย",
								Buttons = {
									{
										ButtonType = "Button3",
										ButtonText = "...",
										Action = "Close"
									}
								}
							}
						}
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	PassiveTree = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						local v = _G.CheckQuestProgressClient(localPlayer, "IsPassive")

						if not v then
							return {
								{
									Chat = "This is the tree of the gods. It will randomly spawn around the map every night. Do you want to continue listening to the story?",
									ChatTH = "นี่คือต้นไม้แห่งเทพ จะสุ่มเกิดรอบๆแมพทุกๆคืน คุณอยากจะฟังเรื่องราวต่อมั้ยล่ะ",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Next",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "The Godly Tree disappears when the sun rises or when a player receives a blessing from the tree. After that, the tree will disappear too.",
													ChatTH = "ต้นไม้แห่งเทพเจ้าจะหายไปเมื่อพระอาทิตย์ขึ้น หรือ เมื่อมีผู้เล่นรับพรจากต้นไม้ หลังจากนั้นต้นไม้ก็จะหายไปเช่นกัน",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Next",
															Action = "NextDialogue",
															Dialogues = {
																{
																	Chat = "You can receive blessings now, and they affect the people around the tree. When you receive a blessing, you will unlock a new function called 'Passive'.",
																	ChatTH = "คุณสามารถรับพรได้ ตอนนี้ และมันส่งผลต่อคนรอบๆต้นไม้ด้วย เมื่อคุณได้รับพร คุณจะปลดล็อคฟังชั่นใหม่ที่เรียกว่า 'Passive'",
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Next",
																			Action = "NextDialogue",
																			Dialogues = {
																				{
																					Chat = "Do you want to receive the blessing from the Godly Tree? <Color=Red>(When you press Blessing, the tree will immediately disappear.)",
																					ChatTH = "คุณต้องการที่จะรับพรจากต้นไม้เทพเจ้าเลยหรือไม่ (เมื่อกดตกลง ต้มไม้จะหายไปทันที)",
																					Buttons = {
																						{
																							ButtonType = "Button1",
																							ButtonText = "Blessing",
																							Action = "Blessing Passive"
																						},
																						{
																							ButtonType = "Button2",
																							ButtonText = "Return",
																							Action = "Return"
																						},
																						{
																							ButtonType = "Button3",
																							ButtonText = "Later",
																							Action = "Close"
																						}
																					}
																				}
																			}
																		},
																		{
																			ButtonType = "Button2",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "Nevermind",
																			Action = "Close"
																		}
																	}
																}
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Nevermind",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Nevermind",
											Action = "Close"
										}
									}
								}
							}
						end

						if v then
							return {
								{
									Chat = "You have been blessed.",
									ChatTH = "คุณได้รับพรไปแล้ว",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	["Kioru V2 Quest"] = {
		{
			Chat = "...",
			Buttons = {
				{
					ButtonType = "Button1",
					ButtonText = "Talk",
					Action = "NextDialogue",
					Dialogues = function()
						local v = _G.CheckTitleClient(localPlayer, "Tyrant Slayer")
						local v2 = _G.CheckTitleClient(localPlayer, "Krakenbane")
						local v3 = _G.CheckTitleClient(localPlayer, "Shellbreaker")
						local v4 = _G.CheckTitleClient(localPlayer, "Dragonbane")
						local v5 = _G.CheckSwordClient(localPlayer, "Kioru")
						local v6 = _G.CheckSwordClient(localPlayer, "Kioru V2")

						if not (v and v2 and v3 and v4 and v5) then
							return {
								{
									Chat = "Prove how strong you are!",
									ChatTH = "พิสูจน์ความแข็งแกร่งของเจ้าสิ",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "!?",
											Action = "Close"
										}
									}
								}
							}
						end

						if v and v2 and v3 and v4 and v5 and not v6 then
							return {
								{
									Chat = "You are the owner of that sword from the Second Sea, aren't you? You've defeated quite a lot of monsters in this Third World. I'm really impressed.",
									ChatTH = "เจ้าคือผู้เป็นเจ้าของดาบเล่มนั้นจากทะเลที่สองสินะ เจ้าจัดการสัตว์ประหลาดในโลกที่สามนี้ไปเยอะทีเดียว ข้าประทับใจมากเลยล่่ะ",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Next",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "It seems you’re ready to upgrade your sword, huh? Pretty easy, isn’t it? You’ll probably like it because I made sure it was easy to obtain.",
													ChatTH = "ดูเหมือนเจ้าจะพร้อมสำหรับการอัพเกรดดาบแล้วสินะ ง่ายดีมั้ยล่ะ เจ้าคงจะชอบเพราะข้าตั้งใจให้มันได้มาง่ายๆอยู่แล้ว",
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Next",
															Action = "NextDialogue",
															Dialogues = {
																{
																	Chat = [[
Sword: Kioru V2 <Img=74849396058634> <Color=Pink>(Legendary) 
 <Color=/>Price: <Color=Green> $55,555,555.]],
																	ChatTH = [[
ดาบ: Kioru V2 <Img=74849396058634> <Color=Pink>(Legendary) 
 <Color=/>Price: <Color=Green> $55,555,555.]],
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Buy",
																			Action = "Buy Kioru V2",
																			ButtonData = {
																				Price = 55555555,
																				TextSuccess = "<AnimateStyle=Rainbow>Successfully purchased a sword.",
																				TextNoMoney = "<AnimateStyle=Appear><Color=Red>Not enough Money $!"
																			}
																		},
																		{
																			ButtonType = "Button2",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "Later",
																			Action = "Close"
																		}
																	}
																}
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Later",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Cancel",
											Action = "Close"
										}
									}
								}
							}
						end

						if v6 then
							return {
								{
									Chat = "That sword is overpowered, isn’t it?",
									ChatTH = "ดาบนั่นขี้โกงใช่มั้ยล่ะ?",
									Buttons = {
										{
											ButtonType = "Button3",
											ButtonText = "...",
											Action = "Close"
										}
									}
								}
							}
						end

						return {
							{
								Chat = "Error 404...!",
								ChatTH = "Error 404...!",
								Buttons = {
									{
										ButtonType = "Button3",
										ButtonText = "!?",
										Action = "Close"
									}
								}
							}
						}
					end
				},
				{
					ButtonType = "Button3",
					ButtonText = "Nevermind",
					Action = "Close"
				}
			}
		}
	},
	Thalric = function()
		if localPlayer.PlayerStats.lvl.Value < 4500 then
			return {
				{
					Chat = "The whisper of the wind speaks only to those who listen.",
					ChatTH = "เสียงกระซิบของสายลม จะเอื้อนเอ่ยเฉพาะแก่ผู้ที่เงี่ยหูฟัง"
				}
			}
		end

		local v = _G.CheckQuestProgressClient(localPlayer, "Gale Fist Quest")

		if not v then
			return {
				{
					Chat = "It seems the winds themselves have guided you to me.",
					ChatTH = "ดูเหมือนว่าสายลมเองได้พัดพาเจ้าให้มาพบกับข้า..."
				},
				{
					Chat = "The spirits of the wind smile upon you. Are you ready to accept the Trial of the Wind?",
					ChatTH = "เทพแห่งสายลมกำลังยิ้มให้เจ้า... เจ้าพร้อมที่จะยอมรับบททดสอบของพวกเขาหรือไม่?",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "I am ready",
							Action = "NextDialogue",
							Dialogues = {
								{
									Chat = "Let the winds see your worth, and may they grant you their acceptance.",
									ChatTH = "จงให้สายลมเห็นคุณค่าของเจ้า และยอมรับเจ้า",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Accept",
											Action = "AddQuestProgress",
											QuestProgressData = {
												QuestProgressName = "Gale Fist Quest",
												QuestChapter = 1
											}
										},
										{
											ButtonType = "Button3",
											ButtonText = "Not yet",
											Action = "Close"
										}
									}
								}
							}
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v and v >= 1 and v < 80 then
			return {
				{
					Chat = "The Trial of the Wind is not yet yours to claim. <Color=Red>(" .. v / 80 * 100 .. "%)",
					ChatTH = "บททดสอบแห่งสายลมยังมิใช่สิ่งที่เจ้าคู่ควร. <Color=Red>(" .. v / 80 * 100 .. "%)"
				},
				{
					Chat = "Return stronger. Let the skies remember your name.",
					ChatTH = "จงกลับมาอย่างแข็งแกร่ง แล้วสายลมจะขานรับนามของเจ้า.."
				}
			}
		end

		if v and v == 80 then
			return {
				{
					Chat = "It seems you have proven yourself worthy.",
					ChatTH = "ดูเหมือนเจ้าได้พิสูจน์ตนแล้ว.."
				},
				{
					Chat = "But even the winds demand their due.",
					ChatTH = "แต่แม้แต่สายลมเองก็ยังเรียกสิ่งตอบแทน"
				},
				{
					Chat = [[
Melee: Gale Fist <Img=130892917343902> <Color=Pink>(Mythical) 
 <Color=/>Price: <Color=Green> $48,500,000 <Color=/>& <Img=127094343300005><Color=Purple>250]],
					ChatTH = [[
หมัด: Gale Fist <Img=130892917343902> <Color=Pink>(Mythical) 
 <Color=/>ราคา: <Color=Green> $48,500,000 <Color=/>& <Img=127094343300005><Color=Purple>250]],
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Gale Fist Quest",
								QuestChapter = 81
							}
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v and v >= 81 then
			if localPlayer.PlayerStats.FightingStyle.Value == "Gale Fist" then
				return {
					{
						Chat = "The winds stir once more... how long has it been?",
						ChatTH = "สายลมเริ่มพลิ้วไหวอีกครั้ง... นานแค่ไหนแล้วนะ?"
					}
				}
			end

			return {
				{
					Chat = "Do you yearn to walk with the winds once more?",
					ChatTH = "เจ้ายังโหยหาที่จะเดินเคียงข้างสายลมอีกครั้งหรือไม่?",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Walk with the Wind",
							Action = "EquipGaleFist"
						},
						{
							ButtonType = "Button3",
							ButtonText = "Another time",
							Action = "Close"
						}
					}
				}
			}
		end
	end,
	DemonV3Progression = function()
		if localPlayer.PlayerStats.lvl.Value < 4500 or _G.RaceClient ~= "Demon" then
			return {
				{
					Chat = "This path is not yours… Turn back, before the darkness consumes your very being.",
					ChatTH = "เส้นทางนี้ไม่ใช่ของเจ้า... จงกลับไปเถิด ก่อนที่ความมืดจะกลืนกินตัวตนของเจ้า"
				}
			}
		end

		if not _G.CheckAwakeClient(localPlayer, "DemonV2") then
			return {
				{
					Chat = "You are not yet ready… the darkness does not heed your voice.",
					ChatTH = "เจ้ายังไม่พร้อม... ความมืดยังไม่รับฟังเสียงของเจ้า"
				}
			}
		end

		local v = _G.CheckQuestProgressClient(localPlayer, "Demon V3")

		if not v then
			return {
				{
					Chat = "Your power is ready to awaken... Defeat Dravhiel, the gatekeeper of darkness.",
					ChatTH = "พลังของเจ้าพร้อมจะเบิกตาแล้ว จงไปกำราบ Dravhiel ผู้ที่เฝ้าประตูแห่งความมืด"
				},
				{
					Chat = "If you endure the trial, I shall lead you to your true form",
					ChatTH = "หากเจ้าผ่านบททดสอบนี้ ข้าจะนำทางเจ้าไปสู่ร่างที่แท้จริง",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Demon V3",
								QuestChapter = 1
							},
							EndChat = "Good luck!"
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v == 1 then
			return {
				{
					Chat = "The path isn't over… Prove your strength has meaning.",
					ChatTH = "เส้นทางนี้ยังไม่จบ... พิสูจน์ว่าพลังเจ้าไม่ไร้ค่า"
				}
			}
		elseif v == 2 then
			return {
				{
					Chat = "I feel the tremor from beyond… You have broken through your limits.",
					ChatTH = "ข้ารู้สึกถึงแรงสั่นสะเทือนจากอีกฟากหนึ่ง... เจ้าได้ข้ามขีดจำกัดของตนแล้ว"
				},
				{
					Chat = "Now, embrace the power destined for your kind",
					ChatTH = "บัดนี้ จงยอมรับพลังที่คู่ควรกับเผ่าพันธุ์เจ้า",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Demon V3",
								QuestChapter = 2
							}
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v >= 3 then
			return {
				{
					Chat = "Even the darkness… has finally accepted you.",
					ChatTH = "แม้แต่ความมืด... ยังยอมรับเจ้าในที่สุด"
				}
			}
		end
	end,
	HumanV3Progression = function()
		if localPlayer.PlayerStats.lvl.Value < 4500 or _G.RaceClient ~= "Human" then
			return {
				{
					Chat = "I sense roots not bound to the soil of humankind…",
					ChatTH = "ข้าสัมผัสได้ถึงรากเหง้าที่ไม่สอดคล้องกับผืนดินแห่งมนุษย์..."
				},
				{
					Chat = "Turn back, your time has not yet come.",
					ChatTH = "กลับไปเถิด ยังไม่ถึงเวลาของเจ้า"
				}
			}
		end

		if not _G.CheckAwakeClient(localPlayer, "HumanV2") then
			return {
				{
					Chat = "Though born of humankind, your heart has not embraced its true strength.",
					ChatTH = "แม้เจ้าจะถือกำเนิดจากสายพันธุ์มนุษย์ แต่หัวใจเจ้ายังมิได้เปิดรับพลังแท้จริง"
				},
				{
					Chat = "Grow fully… and I shall listen once more.",
					ChatTH = "จงเติบโตให้สมบูรณ์เสียก่อน แล้วข้าจะรับฟังอีกครั้ง"
				}
			}
		end

		local v = _G.CheckQuestProgressClient(localPlayer, "Human V3")

		if not v then
			return {
				{
					Chat = "True power cannot awaken without the heart of life...",
					ChatTH = "พลังแท้จริงจะไม่ตื่นขึ้น หากไร้หัวใจแห่งชีวิต..."
				},
				{
					Chat = "Seek the five Heartroot Gems, and return them to me.",
					ChatTH = "จงตามหา Heartroot Gem ทั้งห้า แล้วนำมันกลับมาหาข้า",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Human V3",
								QuestChapter = 1
							},
							EndChat = "Good luck!"
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v and v < 6 then
			return {
				{
					Chat = "The path is still long… Listen to nature’s whisper, and you will find what you seek.",
					ChatTH = "เส้นทางยังอีกยาวไกล... จงฟังเสียงธรรมชาติ แล้วเจ้าจะพบสิ่งที่ตามหา"
				}
			}
		end

		if v and v == 6 then
			return {
				{
					Chat = "The five Heartroot Gems now rest within you...",
					ChatTH = "ลูกแก้วแห่งชีวิตทั้งห้าสถิตอยู่กับเจ้าแล้ว..."
				},
				{
					Chat = "Now, I shall awaken the true power of humankind within your soul.",
					ChatTH = "บัดนี้ ข้าจะปลุกพลังแท้จริงของเผ่าพันธุ์มนุษย์ในตัวเจ้า",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Human V3",
								QuestChapter = 6
							}
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v and v > 6 then
			return {
				{
					Chat = "Humankind... not entirely lost to the light after all",
					ChatTH = "เผ่าพันธุ์มนุษย์... ยังไม่สิ้นแสงเสียทีเดียว"
				},
				{
					Chat = "Let us hope you wield this power with wisdom, not mere ambition.",
					ChatTH = "หวังว่าเจ้าจะใช้พลังนี้อย่างมีสติ ไม่ใช่เพียงเพื่อความทะเยอทะยาน"
				}
			}
		end
	end,
	FishV3Progression = function()
		if localPlayer.PlayerStats.lvl.Value < 4500 or _G.RaceClient ~= "Fish" then
			return {
				{
					Chat = "You have yet to hear the call of the currents…",
					ChatTH = "เจ้ายังไม่ได้ยินเสียงของกระแสน้ำ..."
				},
				{
					Chat = "Leave now. This place is not meant for the unawakened.",
					ChatTH = "กลับไปเสียเถิด ที่นี่ไม่ใช่ที่ของผู้ที่ยังไม่ตื่น"
				}
			}
		end

		if not _G.CheckAwakeClient(localPlayer, "FishV2") then
			return {
				{
					Chat = "The tides within you are weak… unworthy of the abyss.",
					ChatTH = "คลื่นในตัวเจ้ายังอ่อนนัก… ยังไม่คู่ควรกับห้วงลึก"
				}
			}
		end

		local v = _G.CheckQuestProgressClient(localPlayer, "Fish V3")

		if not v then
			return {
				{
					Chat = "There is something in the deep where even light dares not reach...",
					ChatTH = "มีบางสิ่งในห้วงลึกที่แม้แสงยังไม่กล้าแตะต้อง..."
				},
				{
					Chat = "If you have the will, face Morzareth, keeper of the ocean's secret.",
					ChatTH = "หากเจ้ากล้า จงลงไปเผชิญหน้ากับ Morzareth ที่เฝ้าความลับของท้องทะเล",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Fish V3",
								QuestChapter = 1
							},
							EndChat = "Good luck!"
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v == 2 then
			return {
				{
					Chat = "In the lightless deep… a dragon waits in silence.",
					ChatTH = "ในห้วงลึกที่ไร้แสง... มีมังกรตนหนึ่งยังคงเฝ้าเงียบอยู่"
				},
				{
					Chat = "It is the Abyssal Tyrant, bearing the blade of ruin between its fangs..",
					ChatTH = "มันคือ Abyssal Tyrant, ร่างที่คาบดาบแห่งการล่มสลายไว้ในเขี้ยว"
				},
				{
					Chat = "Defeat it not merely to conquer, but to awaken what sleeps within you.",
					ChatTH = "จงกำราบมัน มิใช่เพียงเพื่อเอาชนะ... แต่เพื่อปลุกพลังของเจ้าให้ตื่น",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Fish V3",
								QuestChapter = 2
							},
							EndChat = "Good luck!"
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		elseif v == 4 then
			return {
				{
					Chat = "You have endured the trial of the deep… even the dragon yielded to your unwavering will.",
					ChatTH = "เจ้าผ่านบททดสอบแห่งห้วงลึก... แม้แต่มังกรยังยอมจำนนต่อจิตแน่วแน่ของเจ้"
				},
				{
					Chat = "Take this power, and become one with the current that never stops flowing.",
					ChatTH = "จงรับพลังนี้ และเป็นหนึ่งเดียวกับกระแสที่ไม่มีวันหยุดนิ่ง",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Fish V3",
								QuestChapter = 4
							},
							EndChat = "Good luck!"
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v >= 5 then
			return {
				{
					Chat = "You dove deeper than I expected… intriguing.",
					ChatTH = "เจ้าดำลึกกว่าที่ข้าคิด... น่าสนใจทีเดียว"
				}
			}
		end

		return {
			{
				Chat = "The tides are stirring... I can sense you drawing closer.",
				ChatTH = "คลื่นกำลังกระเพื่อม... ข้ารู้ว่าเจ้ากำลังเข้าใกล้มันทีละน้อย"
			},
			{
				Chat = "Do not stop. Keep diving deeper.",
				ChatTH = "อย่าหยุด จงดำดิ่งต่อไป"
			}
		}
	end,
	AngelV3Progression = function()
		if localPlayer.PlayerStats.lvl.Value < 4500 or _G.RaceClient ~= "Sky" then
			return {
				{
					Chat = "The light has yet to cast its grace upon you…",
					ChatTH = "แสงสว่างยังไม่ทอดเงามาถึงเจ้า..."
				},
				{
					Chat = "Return for now. The path above remains hidden from your eyes",
					ChatTH = "กลับไปเถิด ยามนี้เจ้ามองไม่เห็นหนทางเบื้องบน"
				}
			}
		end

		if not _G.CheckAwakeClient(localPlayer, "SkyV2") then
			return {
				{
					Chat = "Your wings are still fragile… unfit to reach the second sky.",
					ChatTH = "ปีกของเจ้ายังอ่อนนัก... ยังบินไม่ถึงฟ้าชั้นที่สอง"
				}
			}
		end

		local v = _G.CheckQuestProgressClient(localPlayer, "Angel V3")

		if not v then
			return {
				{
					Chat = "True light reveals itself only to those who understand it.",
					ChatTH = "แสงแท้จริงเปิดทางเพียงให้ผู้ที่เข้าใจมันเท่านั้น"
				},
				{
					Chat = "Solve the riddle above to prove the clarity of your soul.",
					ChatTH = "จงไขปริศนาแห่งเบื้องบน เพื่อพิสูจน์จิตที่มั่นคง"
				},
				{
					Chat = "Then strike down Caltherion, guardian of the gate beyond.",
					ChatTH = "แล้วจงกำจัด Caltherion, ผู้ขวางทางแห่งสวรรค์",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Angel V3",
								QuestChapter = 1
							},
							EndChat = "Good luck!"
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v == 1 then
			return {
				{
					Chat = "Your light has begun to shine…",
					ChatTH = "แสงของเจ้าเริ่มส่องแล้ว..."
				},
				{
					Chat = "But the heavens still await your final proof.",
					ChatTH = "แต่สวรรค์ยังรอการพิสูจน์สุดท้าย"
				}
			}
		elseif v == 2 then
			return {
				{
					Chat = "You have passed the trial of the skies… the light has finally chosen you.",
					ChatTH = "เจ้าผ่านบททดสอบแห่งฟ้าแล้ว… แสงได้เลือกเจ้าแล้วในที่สุด"
				},
				{
					Chat = "Take this power, and soar beyond the limits of all who bear wings..",
					ChatTH = "จงรับพลังนี้ และทะยานเหนือขีดจำกัดของผู้ถือปีกทั้งมวล",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Angel V3",
								QuestChapter = 2
							}
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v >= 3 then
			return {
				{
					Chat = "Few can truly soar… without being weighed down by their own wings.",
					ChatTH = "มีไม่กี่คน... ที่โบยบินได้ โดยไม่ถูกปีกของตนฉุดรั้ง"
				}
			}
		end
	end,
	SeaBeastV3Progression = function()
		if localPlayer.PlayerStats.lvl.Value < 4500 or _G.RaceClient ~= "Sea Beast" then
			return {
				{
					Chat = "The way you are now… you'd be torn apart by the first wave.",
					ChatTH = "ร่างของเจ้าตอนนี้... จะถูกฉีกตั้งแต่คลื่นลูกแรก"
				}
			}
		end

		if not _G.CheckAwakeClient(localPlayer, "Sea BeastV2") then
			return {
				{
					Chat = "You're too early… those muscles haven’t faced a real storm yet",
					ChatTH = "เจ้ายังเร็วไป… กล้ามเนื้อพวกนั้นยังไม่เคยผ่านพายุจริง ๆ"
				}
			}
		end

		local v = _G.CheckQuestProgressClient(localPlayer, "Sea BeastV3")

		if not v then
			return {
				{
					Chat = "Before you get anything more… solve this puzzle first.",
					ChatTH = "ก่อนจะได้มากกว่านี้... เจ้าแก้ปริศนานี่ให้ได้ก่อน"
				},
				{
					Chat = "If you can't, don’t even think about going further.",
					ChatTH = "ถ้าทำไม่ได้ ก็อย่าคิดไปไกลกว่านี้",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Sea BeastV3",
								QuestChapter = 1
							},
							EndChat = "Good luck!"
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v == 1 then
			return {
				{
					Chat = "You cleared the first trial at least you know how to think.",
					ChatTH = "เจ้าผ่านด่านแรกมาได้ นั่นแปลว่าอย่างน้อยก็รู้จักใช้หัว"
				},
				{
					Chat = "But that was just the beginning.",
					ChatTH = "แต่เส้นทางมันเพิ่งเริ่มเท่านั้น"
				},
				{
					Chat = "Get into the dungeon, and take down Ravthus.",
					ChatTH = "เข้าไปในดันเจี้ยน แล้วจัดการ Ravthus ซะ",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Sea BeastV3",
								QuestChapter = 2
							},
							EndChat = "Good luck!"
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		elseif v == 2 then
			return {
				{
					Chat = "It was never meant to be easy… but if you’re one of us, finish it",
					ChatTH = "มันไม่ได้ง่ายอยู่แล้ว... แต่ถ้าจะเป็นหนึ่งในพวกเรา ก็จัดการมันให้ได้"
				}
			}
		elseif v == 3 then
			return {
				{
					Chat = "You made it through without falling… or backing down.",
					ChatTH = "เจ้าผ่านทุกอย่างมาโดยไม่ล้ม... ไม่ถอย"
				},
				{
					Chat = "That’s what survival looks like in these seas..",
					ChatTH = "นั่นแหละสิ่งที่เรียกว่ารอดในท้องทะเล"
				},
				{
					Chat = "Take this power… and stand where only the strong belong",
					ChatTH = "รับพลังนี้... และจงยืนในที่ที่มีแต่ผู้แกร่งเท่านั้นจะยืนได้",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Sea BeastV3",
								QuestChapter = 3
							}
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v > 3 then
			return {
				{
					Chat = "The sea shows no mercy… surviving today is good enough.",
					ChatTH = "ทะเลไม่เคยปรานีใคร… แค่วันนี้เจ้ารอดก็ถือว่าพอแล้ว"
				}
			}
		end
	end,
	AnimalV3Progression = function()
		if localPlayer.PlayerStats.lvl.Value < 4500 or _G.RaceClient ~= "Mink" then
			return {
				{
					Chat = "If you can't even run… you're not ready to step into the wild.",
					ChatTH = "ถ้ายังไม่รู้จักวิ่ง... ก็ยังไม่ควรก้าวเข้าป่า"
				}
			}
		end

		if not _G.CheckAwakeClient(localPlayer, "MinkV2") then
			return {
				{
					Chat = "You've got the instinct… but not the strength.",
					ChatTH = "เจ้ามีสัญชาตญาณ... แต่ยังไม่แกร่งพอ"
				}
			}
		end

		local v = _G.CheckQuestProgressClient(localPlayer, "MinkV3")

		if not v then
			return {
				{
					Chat = "Your first trial is to take down Wildclaw.",
					ChatTH = "บททดสอบแรกของเจ้า คือจัดการ Wildclaw"
				},
				{
					Chat = "It's fast, vicious, and it's dragged hunters off whole",
					ChatTH = "มันเร็ว ดุ และเคยลากนักล่าหายไปทั้งตัว",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "MinkV3",
								QuestChapter = 1
							},
							EndChat = "Good luck!"
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v == 1 then
			return {
				{
					Chat = "You've chosen the right path.",
					ChatTH = "ทางที่เลือกมันถูกแล้ว"
				},
				{
					Chat = "Now it's just a matter of whether you hunt… or get hunted.",
					ChatTH = "เหลือแค่ว่าเจ้าจะล่ามันได้... หรือโดนล่าแทน"
				}
			}
		elseif v == 2 then
			return {
				{
					Chat = "You survived its fangs… good.",
					ChatTH = "เจ้ารอดจากเขี้ยวของมันมาได้... ดี"
				},
				{
					Chat = "But the next part isn’t about strength.",
					ChatTH = "แต่บทต่อไป ไม่ใช่เรื่องของแรง"
				},
				{
					Chat = "Solve the puzzle then we’ll talk again.",
					ChatTH = "ไปแก้ปริศนา แล้วเราค่อยมาคุยกันอีกที",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "MinkV3",
								QuestChapter = 2
							},
							EndChat = "Good luck!"
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		elseif v == 3 then
			return {
				{
					Chat = "You've proven your fangs and your mind… not many get this far.",
					ChatTH = "เจ้าผ่านทั้งเขี้ยวและปัญญา... ไม่มากนักที่ไปถึงตรงนี้"
				},
				{
					Chat = "But true power in our kind doesn’t awaken through strength alone.",
					ChatTH = "แต่พลังที่แท้ของเผ่านี้ ไม่ได้ตื่นขึ้นจากการล่าเพียงอย่างเดียว"
				},
				{
					Chat = "It demands something earned through survival 10 Void Cores.",
					ChatTH = "มันต้องใช้สิ่งที่แลกมาด้วยการเอาชีวิตรอดจริง ๆ Void Core 10 ชิ้น"
				},
				{
					Chat = "Bring them to me, and I’ll awaken it within you.",
					ChatTH = "นำมันมา แล้วข้าจะปลุกสิ่งนั้นให้เจ้า",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "MinkV3",
								QuestChapter = 3
							},
							EndChat = function()
								if _G.CheckMaterialClient(localPlayer, "Void Core", 10) then
									return {
										{
											Chat = "You’ve brought them all… no more words needed.",
											ChatTH = "เจ้าหามาครบแล้ว… ไม่มีคำไหนต้องพูดมาก"
										},
										{
											Chat = "Take this power, and use it like something you hunted for.",
											ChatTH = "รับพลังนี้ แล้วใช้มันให้สมกับที่ล่าเอามา"
										}
									}
								end

								return {
									{
										Chat = "Not enough… come back when you have them all.",
										ChatTH = "ยังไม่พอ… กลับไปหาให้ครบก่อน"
									}
								}
							end
						},
						{
							ButtonType = "Button3",
							ButtonText = "Not yet",
							Action = "Close"
						}
					}
				}
			}
		end

		if v > 3 then
			return {
				{
					Chat = "Some run their whole life and never reach this point… but you did.",
					ChatTH = "บางตัววิ่งทั้งชีวิตยังไม่ไปถึงตรงนี้… เจ้าไปถึงแล้ว"
				}
			}
		end
	end,
	["Captain Bale"] = function()
		return {
			{
				Chat = "The Whale ship, huh? Just hauling its bones nearly broke my back.",
				ChatTH = "เรือวาฬเหรอ? แค่จะยกกระดูกมันมาก็ปวดหลังไปสามวัน"
			},
			{
				Chat = "But hey… if you think you’ve got what it takes, wanna craft one?",
				ChatTH = "แต่เอาเถอะ... ถ้าเจ้าคิดว่าตัวเองแบกได้ สนใจจะคราฟต์ไหมล่ะ?",
				Buttons = {
					{
						ButtonType = "Button1",
						ButtonText = "Let's do it.",
						Action = "SpecialShopGui",
						ButtonData = {
							GuiName = "CraftingUI2",
							CraftWith = "Captain Bale"
						}
					},
					{
						ButtonType = "Button3",
						ButtonText = "Maybe later.",
						Action = "Close"
					}
				}
			}
		}
	end,
	["Captain Morrow"] = function()
		return {
			{
				Chat = "That ship doesn’t sail on ordinary waters…",
				ChatTH = "เรือแบบนั้นไม่ได้แล่นอยู่ในน้ำธรรมดา..."
			},
			{
				Chat = "But if you truly plan to craft it, make sure you’re not afraid of what follows.",
				ChatTH = "แต่ถ้าเจ้าคิดจะคราฟต์มันจริง ๆ ก็จงแน่ใจว่าไม่ได้กลัวสิ่งที่ตามมาด้วย",
				Buttons = {
					{
						ButtonType = "Button1",
						ButtonText = "Let's do it.",
						Action = "SpecialShopGui",
						ButtonData = {
							GuiName = "CraftingUI2",
							CraftWith = "Captain Morrow"
						}
					},
					{
						ButtonType = "Button3",
						ButtonText = "Maybe later.",
						Action = "Close"
					}
				}
			}
		}
	end,
	["Tiki Taka"] = function()
		local fightingStyle = localPlayer:WaitForChild("PlayerStats"):WaitForChild("FightingStyle")
		local v = _G.CheckQuestProgressClient(localPlayer, "Striker")
		local backpack = localPlayer.Backpack

		if not v then
			return {
				{
					Chat = "You want power? Speed? Style? Welcome to Striker.",
					ChatTH = "อยากได้พลัง ความเร็ว และสไตล์ใช่ไหม? ยินดีต้อนรับสู่ Striker"
				},
				{
					Chat = "This isn’t just a game the ball is your weapon.",
					ChatTH = "นี่ไม่ใช่แค่เกม ลูกบอลคืออาวุธของนาย"
				},
				{
					Chat = "Every kick hits like a cannon. Every move breaks bones.",
					ChatTH = "ทุกการเตะคือปืนใหญ่ ทุกท่าสามารถทำให้กระดูกหักได้"
				},
				{
					Chat = "If you’re ready to turn the field into a battlefield… I’ll be your coach!",
					ChatTH = "ถ้านายพร้อมจะเปลี่ยนสนามให้กลายเป็นสมรภูมิ… ฉันจะเป็นโค้ชของนายเอง!",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Striker",
								QuestChapter = 1
							}
						},
						{
							ButtonType = "Button3",
							ButtonText = "...",
							Action = "Close"
						}
					}
				}
			}
		end

		if v == 1 or v < 5 then
			return {
				{
					Chat = "Complete your entire guideline first… then return to me.",
					ChatTH = "จงทำตามแนวทางของเจ้าทั้งหมดให้ครบ แล้วค่อยกลับมาคุยกับข้า"
				},
				{
					Chat = "(Go to Menu > Stats > Profile > Fighting Style > Striker)",
					ChatTH = "(ไปที่ เมนู > ค่าสถานะ > โปรไฟล์ > สไตล์การต่อสู้ > Striker)"
				}
			}
		end

		if v == 5 then
			if backpack:FindFirstChild("BombFruit") then
				return {
					{
						Chat = "Oh, excellent! You’ve brought me the Bomb Fruit thank you very much.",
						ChatTH = "โอ้ เยี่ยมมาก! เจ้านำผลระเบิดมาให้ข้าแล้ว ขอบใจมากนะ",
						Buttons = {
							{
								ButtonType = "Button1",
								ButtonText = "Submit",
								Action = "AddQuestProgress",
								QuestProgressData = {
									QuestProgressName = "Striker",
									QuestChapter = 5
								}
							},
							{
								ButtonType = "Button3",
								ButtonText = "...",
								Action = "Close"
							}
						}
					}
				}
			end

			return {
				{
					Chat = "You completed it surprisingly quickly!",
					ChatTH = "เจ้าทำสำเร็จไวมากเลยนะเนี่ย!"
				},
				{
					Chat = [[
Next, you must give me the Bomb Fruit <Img=18188886589>. 
I want to use it for cooking.]],
					ChatTH = "ต่อไป เจ้าต้องมอบผลระเบิด <Img=18188886589> มาให้ข้า ข้าอยากได้มันไปทำอาหาร"
				}
			}
		elseif v == 6 then
			if _G.CheckMaterialClient(localPlayer, "Pebblefish", 10) and _G.CheckMaterialClient(
				localPlayer,
				"Lunafin",
				10
			) and _G.CheckMaterialClient(localPlayer, "Solray", 5) and _G.CheckMaterialClient(
				localPlayer,
				"Longtooth",
				2
			) and _G.CheckMaterialClient(localPlayer, "Sapphire Razer", 1) then
				return {
					{
						Chat = "<Img=137604731254644> <Img=72993449565996> <Img=130697424014615> <Img=122055740513109> <Img=80799195396743> Awesome job!",
						ChatTH = "<Img=137604731254644> <Img=72993449565996> <Img=130697424014615> <Img=122055740513109> <Img=80799195396743> สุดยอดไปเลย!",
						Buttons = {
							{
								ButtonType = "Button1",
								ButtonText = "Submit",
								Action = "AddQuestProgress",
								QuestProgressData = {
									QuestProgressName = "Striker",
									QuestChapter = 6
								}
							},
							{
								ButtonType = "Button3",
								ButtonText = "...",
								Action = "Close"
							}
						}
					}
				}
			end

			return {
				{
					Chat = "My wife said the Bomb Fruit alone isn’t enough… Do you mind helping me a little more? I’m really sorry",
					ChatTH = "ภรรยาของข้าบอกว่า แค่ Bomb Fruit ไม่พอ… ข้าขอรบกวนอีกสักหน่อยได้ไหม? ขอโทษจริง ๆ นะ"
				},
				{
					Chat = "Fish List: 10 Pebblefish <Img=137604731254644>, 10 Lunafin <Img=72993449565996>, 5 Solray <Img=130697424014615>, 2 Longtooth <Img=122055740513109>, 1 Sapphire Razer <Img=80799195396743>",
					ChatTH = "รายการปลา: 10 Pebblefish <Img=137604731254644>, 10 Lunafin <Img=72993449565996>, 5 Solray <Img=130697424014615>, 2 Longtooth <Img=122055740513109>, 1 Sapphire Razer <Img=80799195396743>"
				}
			}
		else
			if v == 7 then
				return {
					{
						Chat = "Thank you for fulfilling my request. Now then… just one final step remains.",
						ChatTH = "ขอบใจมากสำหรับที่ช่วยทำตามคำขอของข้า เอาล่ะ… เหลือแค่ขั้นตอนสุดท้ายแล้ว"
					},
					{
						Chat = [[
Melee: Striker <Img=105690575603753> <Color=Red>(Legendary) 
 <Color=/>Price: <Color=Green> $20,202,020 <Color=/>& <Img=127094343300005><Color=Purple>20]],
						ChatTH = [[
สไตล์: Striker <Img=105690575603753> <Color=Red>(Legendary) 
 <Color=/>ราคา: <Color=Green> $20,202,020 <Color=/>& <Img=127094343300005><Color=Purple>20]],
						Buttons = {
							{
								ButtonType = "Button1",
								ButtonText = "Accept",
								Action = "AddQuestProgress",
								QuestProgressData = {
									QuestProgressName = "Striker",
									QuestChapter = 7
								}
							},
							{
								ButtonType = "Button3",
								ButtonText = "...",
								Action = "Close"
							}
						}
					}
				}
			end

			if v ~= 8 then
				return
			end

			if fightingStyle.Value == "Striker" then
				return {
					{
						Chat = "Train hard and master it well",
						ChatTH = "ฝึกใช้มันให้ชำนาญล่ะ"
					}
				}
			end

			return {
				{
					Chat = "Wanna use Striker?",
					ChatTH = "อยากจะใช้ Striker มั้ยล่ะ?",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Accept",
							Action = "AddQuestProgress",
							QuestProgressData = {
								QuestProgressName = "Striker",
								QuestChapter = 8
							}
						},
						{
							ButtonType = "Button3",
							ButtonText = "...",
							Action = "Close"
						}
					}
				}
			}
		end
	end,
	["Fisher Frank"] = function()
		local playerStats = localPlayer:WaitForChild("PlayerStats")
		_G.CheckQuestProgressClient(localPlayer, "Striker")
		local backpack = localPlayer.Backpack
		local hasAnyFishClient = _G.HasAnyFishClient(localPlayer)
		local name = nil

		for _, tool in pairs(backpack:GetChildren()) do
			if tool:IsA("Tool") and MaterialList[tool.Name] and MaterialList[tool.Name].Fish then
				name = tool.Name
			end
		end

		local function GetTierFishSummary(localPlayer2)
			local v = {
				Common = {
					Money = 0,
					Amount = 0
				},
				Uncommon = {
					Money = 0,
					Amount = 0
				},
				Rare = {
					Money = 0,
					Amount = 0
				},
				Epic = {
					Money = 0,
					Amount = 0
				},
				Legendary = {
					Money = 0,
					Amount = 0
				},
				Mythical = {
					Money = 0,
					Amount = 0
				}
			}
			local material = localPlayer2:FindFirstChild("PlayerStats") and localPlayer2.PlayerStats:FindFirstChild("Material")

			if not material then
				return v
			end

			local jSONDecode = HttpService:JSONDecode(material.Value)

			for k, v2 in pairs(jSONDecode) do
				local v3 = MaterialList[k]

				if not (v3 and v3.Fish) then
					continue
				end

				local tier = v3.Tier

				if not v[tier] then
					continue
				end

				v[tier].Amount += v2

				if not (v3.Reward and v3.Reward.Money) then
					continue
				end

				v[tier].Money += v3.Reward.Money * v2
			end

			return v
		end

		local tierFishSummary = GetTierFishSummary(localPlayer)
		local v2 = ""
		local money = 0
		local v3 = ""
		local v4 = _G.CheckSwordClient(localPlayer, "Basic Rod")

		if MaterialList[name] then
			if MaterialList[name].Reward and MaterialList[name].Reward.Money then
				money = MaterialList[name].Reward.Money
			end

			if MaterialList[name].Image then
				v2 = tonumber(MaterialList[name].Image:match("%d+"))
			end
		end

		local realBeliX2 = playerStats and playerStats:FindFirstChild("RealBeliX2") and playerStats.RealBeliX2 or 1

		if realBeliX2 and realBeliX2.Value == 2 then
			money *= 2
			v3 = " <Color=Yellow>(2x)"
		end

		if name then
			local v5 = _G.CheckMaterialClient(localPlayer, name) or 0
			local halfNum = math.floor(v5 / 2)
			return {
				{
					Chat = "Would you like to sell the fish in your Backpack?",
					ChatTH = "อยากขายปลาใน Backpack เจ้าไหม?"
				},
				{
					Chat = "How many do you want to sell?",
					ChatTH = "อยากขายกี่ตัวล่ะ?",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "1",
							Action = "NextDialogue",
							Dialogues = {
								{
									Chat = "Species: <Color=Red>" .. name .. "<Color=/> <Img=" .. v2 .. [[
> 
Quantity: <Color=Pink>1<Color=/> 
Sale Price: <Color=Green>$]] .. _G.Suffix_Comma(money) .. v3,
									ChatTH = "สายพันธุ์: <Color=Red>" .. name .. "<Color=/> <Img=" .. v2 .. [[
> 
จำนวน: <Color=Pink>1<Color=/> 
ราคาที่ได้: <Color=Green>$]] .. _G.Suffix_Comma(money) .. v3,
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Sell",
											Action = "Fisher Frank",
											QuestProgressData = {
												SellType = "Sell Backpack Fish",
												FishName = name,
												Quantity = "1"
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Close",
											Action = "Close"
										}
									}
								}
							}
						},
						{
							ButtonType = "Button2",
							ButtonText = "Half",
							Action = "NextDialogue",
							Dialogues = {
								{
									Chat = "Species: <Color=Red>" .. name .. "<Color=/> <Img=" .. v2 .. "> \nQuantity: <Color=Pink>" .. halfNum .. "<Color=/> \nSale Price: <Color=Green>$" .. _G.Suffix_Comma(money * halfNum) .. v3,
									ChatTH = "สายพันธุ์: <Color=Red>" .. name .. "<Color=/> <Img=" .. v2 .. "> \nจำนวน: <Color=Pink>" .. halfNum .. "<Color=/> \nราคาที่ได้: <Color=Green>$" .. _G.Suffix_Comma(money * halfNum) .. v3,
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Sell",
											Action = "Fisher Frank",
											QuestProgressData = {
												SellType = "Sell Backpack Fish",
												FishName = name,
												Quantity = "Half",
												HalfNum = halfNum
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Close",
											Action = "Close"
										}
									}
								}
							}
						},
						{
							ButtonType = "Button3",
							ButtonText = "All",
							Action = "NextDialogue",
							Dialogues = {
								{
									Chat = "Species: <Color=Red>" .. name .. "<Color=/> <Img=" .. v2 .. "> \nQuantity: <Color=Pink>" .. v5 .. "<Color=/> \nSale Price: <Color=Green>$" .. _G.Suffix_Comma(money * v5) .. v3,
									ChatTH = "สายพันธุ์: <Color=Red>" .. name .. "<Color=/> <Img=" .. v2 .. "> \nจำนวน: <Color=Pink>" .. v5 .. "<Color=/> \nราคาที่ได้: <Color=Green>$" .. _G.Suffix_Comma(money * v5) .. v3,
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Sell",
											Action = "Fisher Frank",
											QuestProgressData = {
												SellType = "Sell Backpack Fish",
												FishName = name,
												Quantity = "All"
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Return",
											Action = "Return"
										},
										{
											ButtonType = "Button3",
											ButtonText = "Close",
											Action = "Close"
										}
									}
								}
							}
						},
						{
							ButtonType = "Button4",
							ButtonText = "Close",
							Action = "Close"
						}
					}
				}
			}
		elseif name or not hasAnyFishClient then
			if hasAnyFishClient or v4 then
				return {
					{
						Chat = "I'm only interested in fish.",
						ChatTH = "ข้าสนใจแค่ปลาเท่านั้น"
					}
				}
			end

			return {
				{
					Chat = "Greetings. I sell fish.",
					ChatTH = "สวัสดี ข้าขายปลา"
				},
				{
					Chat = "If you want to try fishing, you can craft a <Color=Red>Basic Rod<Color=/> <Img=87330331189931> with the <Color=Red>Mystic Bookkeeper.",
					ChatTH = "ถ้าเจ้าอยากลองตกปลา ลองไปคราฟเบ็ดไม้ <Img=87330331189931> กับ <Color=Red>Mystic Bookkeeper<Color=/> ได้นะ"
				}
			}
		else
			return {
				{
					Chat = "Greetings. I sell fish.",
					ChatTH = "สวัสดี ข้าขายปลา"
				},
				{
					Chat = "If you want to sell just one type of fish, you can select it from your Inventory and move it to your Backpack.",
					ChatTH = "ถ้าเจ้าอยากขายปลาแค่ 1 สายพันธุ์ ให้กดเลือกจาก Inventory แล้วส่งไปไว้ใน Backpack ได้นะ",
					Buttons = {
						{
							ButtonType = "Button1",
							ButtonText = "Sell",
							Action = "NextDialogue",
							Dialogues = {
								{
									Chat = "Choose the tier of fish you want to sell.",
									ChatTH = "เลือกระดับที่เจ้าต้องการจะขายปลามาสิ",
									Buttons = {
										{
											ButtonType = "Button1",
											ButtonText = "Common",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Tier: <Color=Red>Common<Color=/> \nQuantity: <Color=Pink>" .. tierFishSummary.Common.Amount .. "<Color=/> \nSale Price: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Common.Money * realBeliX2.Value) .. v3,
													ChatTH = "ระดับ: <Color=Green>Common<Color=/> \nจำนวน: <Color=Pink>" .. tierFishSummary.Common.Amount .. "<Color=/> \nราคาที่ได้: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Common.Money * realBeliX2.Value) .. v3,
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Sell",
															Action = "NextDialogue",
															Dialogues = {
																{
																	Chat = "Are you sure you want to\n sell all <Color=Red>Common<Color=/> fish?",
																	ChatTH = [[
เจ้ายืนยันที่จะขายปลาระดับ
 <Color=Red>Common<Color=/> ทั้งหมดเลยหรือไม่]],
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Confirm",
																			Action = "Fisher Frank",
																			QuestProgressData = {
																				SellType = "Sell Inventory Fish",
																				Tier = "Common"
																			}
																		},
																		{
																			ButtonType = "Button2",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "Close",
																			Action = "Close"
																		}
																	}
																}
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Close",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button2",
											ButtonText = "Uncommon",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Tier: <Color=Red>Uncommon<Color=/> \nQuantity: <Color=Pink>" .. tierFishSummary.Uncommon.Amount .. "<Color=/> \nSale Price: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Uncommon.Money * realBeliX2.Value) .. v3,
													ChatTH = "ระดับ: <Color=Green>Uncommon<Color=/> \nจำนวน: <Color=Pink>" .. tierFishSummary.Uncommon.Amount .. "<Color=/> \nราคาที่ได้: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Uncommon.Money * realBeliX2.Value) .. v3,
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Sell",
															Action = "NextDialogue",
															Dialogues = {
																{
																	Chat = "Are you sure you want to\n sell all <Color=Red>Uncommon<Color=/> fish?",
																	ChatTH = [[
เจ้ายืนยันที่จะขายปลาระดับ
 <Color=Red>Uncommon<Color=/> ทั้งหมดเลยหรือไม่]],
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Confirm",
																			Action = "Fisher Frank",
																			QuestProgressData = {
																				SellType = "Sell Inventory Fish",
																				Tier = "Uncommon"
																			}
																		},
																		{
																			ButtonType = "Button2",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "Close",
																			Action = "Close"
																		}
																	}
																}
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Close",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button3",
											ButtonText = "Rare",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Tier: <Color=Red>Rare<Color=/> \nQuantity: <Color=Pink>" .. tierFishSummary.Rare.Amount .. "<Color=/> \nSale Price: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Rare.Money * realBeliX2.Value) .. v3,
													ChatTH = "ระดับ: <Color=Green>Rare<Color=/> \nจำนวน: <Color=Pink>" .. tierFishSummary.Rare.Amount .. "<Color=/> \nราคาที่ได้: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Rare.Money * realBeliX2.Value) .. v3,
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Sell",
															Action = "NextDialogue",
															Dialogues = {
																{
																	Chat = "Are you sure you want to\n sell all <Color=Red>Rare<Color=/> fish?",
																	ChatTH = [[
เจ้ายืนยันที่จะขายปลาระดับ
 <Color=Red>Rare<Color=/> ทั้งหมดเลยหรือไม่]],
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Confirm",
																			Action = "Fisher Frank",
																			QuestProgressData = {
																				SellType = "Sell Inventory Fish",
																				Tier = "Rare"
																			}
																		},
																		{
																			ButtonType = "Button2",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "Close",
																			Action = "Close"
																		}
																	}
																}
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Close",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button4",
											ButtonText = "Epic",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Tier: <Color=Red>Epic<Color=/> \nQuantity: <Color=Pink>" .. tierFishSummary.Epic.Amount .. "<Color=/> \nSale Price: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Epic.Money * realBeliX2.Value) .. v3,
													ChatTH = "ระดับ: <Color=Green>Epic<Color=/> \nจำนวน: <Color=Pink>" .. tierFishSummary.Epic.Amount .. "<Color=/> \nราคาที่ได้: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Epic.Money * realBeliX2.Value) .. v3,
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Sell",
															Action = "NextDialogue",
															Dialogues = {
																{
																	Chat = "Are you sure you want to\n sell all <Color=Red>Epic<Color=/> fish?",
																	ChatTH = [[
เจ้ายืนยันที่จะขายปลาระดับ
 <Color=Red>Epic<Color=/> ทั้งหมดเลยหรือไม่]],
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Confirm",
																			Action = "Fisher Frank",
																			QuestProgressData = {
																				SellType = "Sell Inventory Fish",
																				Tier = "Epic"
																			}
																		},
																		{
																			ButtonType = "Button2",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "Close",
																			Action = "Close"
																		}
																	}
																}
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Close",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button5",
											ButtonText = "Legendary",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Tier: <Color=Red>Legendary<Color=/> \nQuantity: <Color=Pink>" .. tierFishSummary.Legendary.Amount .. "<Color=/> \nSale Price: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Legendary.Money * realBeliX2.Value) .. v3,
													ChatTH = "ระดับ: <Color=Green>Legendary<Color=/> \nจำนวน: <Color=Pink>" .. tierFishSummary.Legendary.Amount .. "<Color=/> \nราคาที่ได้: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Legendary.Money * realBeliX2.Value) .. v3,
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Sell",
															Action = "NextDialogue",
															Dialogues = {
																{
																	Chat = "Are you sure you want to\n sell all <Color=Red>Legendary<Color=/> fish?",
																	ChatTH = [[
เจ้ายืนยันที่จะขายปลาระดับ
 <Color=Red>Legendary<Color=/> ทั้งหมดเลยหรือไม่]],
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Confirm",
																			Action = "Fisher Frank",
																			QuestProgressData = {
																				SellType = "Sell Inventory Fish",
																				Tier = "Legendary"
																			}
																		},
																		{
																			ButtonType = "Button2",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "Close",
																			Action = "Close"
																		}
																	}
																}
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Close",
															Action = "Close"
														}
													}
												}
											}
										},
										{
											ButtonType = "Button6",
											ButtonText = "Mythical",
											Action = "NextDialogue",
											Dialogues = {
												{
													Chat = "Tier: <Color=Red>Mythical<Color=/> \nQuantity: <Color=Pink>" .. tierFishSummary.Mythical.Amount .. "<Color=/> \nSale Price: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Mythical.Money * realBeliX2.Value) .. v3,
													ChatTH = "ระดับ: <Color=Green>Mythical<Color=/> \nจำนวน: <Color=Pink>" .. tierFishSummary.Mythical.Amount .. "<Color=/> \nราคาที่ได้: <Color=Green>$" .. _G.Suffix_Comma(tierFishSummary.Mythical.Money * realBeliX2.Value) .. v3,
													Buttons = {
														{
															ButtonType = "Button1",
															ButtonText = "Sell",
															Action = "NextDialogue",
															Dialogues = {
																{
																	Chat = "Are you sure you want to\n sell all <Color=Red>Mythical<Color=/> fish?",
																	ChatTH = [[
เจ้ายืนยันที่จะขายปลาระดับ
 <Color=Red>Mythical<Color=/> ทั้งหมดเลยหรือไม่]],
																	Buttons = {
																		{
																			ButtonType = "Button1",
																			ButtonText = "Confirm",
																			Action = "Fisher Frank",
																			QuestProgressData = {
																				SellType = "Sell Inventory Fish",
																				Tier = "Mythical"
																			}
																		},
																		{
																			ButtonType = "Button2",
																			ButtonText = "Return",
																			Action = "Return"
																		},
																		{
																			ButtonType = "Button3",
																			ButtonText = "Close",
																			Action = "Close"
																		}
																	}
																}
															}
														},
														{
															ButtonType = "Button2",
															ButtonText = "Return",
															Action = "Return"
														},
														{
															ButtonType = "Button3",
															ButtonText = "Close",
															Action = "Close"
														}
													}
												}
											}
										}
									}
								}
							}
						},
						{
							ButtonType = "Button3",
							ButtonText = "Close",
							Action = "Close"
						}
					}
				}
			}
		end
	end,
	Whirlseer = function()
		localPlayer:WaitForChild("PlayerStats"):WaitForChild("FightingStyle")
		local v = _G.CheckAwakeClient(localPlayer, "WhirlpoolTracking")
		local v2 = _G.CheckTitleClient(localPlayer, "Serpent Reaver")
		local _ = localPlayer.Backpack

		if v then
			if v then
				return {
					{
						Chat = "You have gained Whirlpool Tracking. Check your map. <Img=127091887248937>",
						ChatTH = "เจ้าได้รับพลังติดตาม Whirlpool แล้ว ลองเปิดแผนที่ดูสิ <Img=127091887248937>"
					},
					{
						Chat = "From now on, whenever a Whirlpool appears, I’ll mark its location on your map. Convenient, isn’t it? 🌊",
						ChatTH = "ตั้งแต่นี้ไป เมื่อ Whirlpool ปรากฏ ข้าจะแสดงตำแหน่งมันบนแผนที่ให้เอง สะดวกขึ้นเยอะเลยล่ะ! 🌊"
					},
					{
						Chat = [[
You’ve proven yourself… 
I have an offer for you. 
Are you interested?]],
						ChatTH = [[
เจ้าพิสูจน์ตนเองแล้ว… 
ข้ามีข้อเสนอหนึ่ง 
สนใจหรือไม่?]],
						Buttons = {
							{
								ButtonType = "Button1",
								ButtonText = "Confirm",
								Action = "SpecialShopGui",
								ButtonData = {
									GuiName = "CraftingUI2",
									CraftWith = "Whirlseer"
								}
							},
							{
								ButtonType = "Button3",
								ButtonText = "Close",
								Action = "Close"
							}
						}
					}
				}
			end
		else
			if not v2 then
				return {
					{
						Chat = "…Did the tides lead you to me?",
						ChatTH = "…คลื่นพาเจ้ามาหาข้าหรือ?"
					},
					{
						Chat = "Requires the “Serpent Reaver” title to interact.",
						ChatTH = "ต้องมีฉายา “Serpent Reaver” จึงจะสามารถสนทนาได้"
					}
				}
			end

			if v2 then
				return {
					{
						Chat = "So, you’ve slain the sea serpent… not bad.",
						ChatTH = "โอ้ เจ้าปราบอสูรงูทะเลได้สินะ… ไม่เลวเลย",
						Buttons = {
							{
								ButtonType = "Button1",
								ButtonText = "Whirlpool",
								Action = "NextDialogue",
								Dialogues = {
									{
										Chat = [[
That whirlpool can be hard to find… but I can reveal its location 
if you’re willing to hear my request.]],
										ChatTH = [[
บางที Whirlpool นั่นก็หายากใช่ไหมล่ะ… 
แต่ข้าบอกตำแหน่งให้เจ้าได้ หากเจ้าฟังคำขอของข้า]],
										Buttons = {
											{
												ButtonType = "Button1",
												ButtonText = "Accept",
												Action = "NextDialogue",
												Dialogues = {
													{
														Chat = [[
Bring me 
7x <Color=Green>Serpent Fins<Color=/> <Img=75621930882100> 
1x <Color=Green>Serpent Heart <Color=/><Img=89167920920995>
and I shall reveal the path]],
														ChatTH = [[
ข้าต้องการ 
<Color=Green>Serpent Fin 7 ชิ้น <Color=/><Img=75621930882100> 
<Color=Green>Serpent Heart 1 ชิ้น <Color=/><Img=89167920920995> 
แล้วข้าจะชี้ทางให้เจ้า]],
														Buttons = {
															{
																ButtonType = "Button1",
																ButtonText = "Offer",
																Action = "NextDialogue",
																Dialogues = function()
																	if _G.CheckMaterialClient(
																		localPlayer,
																		"Serpent Fin",
																		7
																	) and _G.CheckMaterialClient(
																		localPlayer,
																		"Serpent Heart"
																	) then
																		return {
																			{
																				Chat = "Thank you… From now on, I’ll mark the Whirlpool’s location on your map when it appears. If there’s no mark, it hasn’t formed yet.",
																				ChatTH = "ขอบใจมาก… ต่อจากนี้ข้าจะปักหมุดตำแหน่ง Whirlpool บนแผนที่ให้เมื่อมันปรากฏ หากไม่มีหมุด แปลว่าตอนนี้มันยังไม่เกิด",
																				Buttons = {
																					{
																						ButtonType = "Button3",
																						ButtonText = "...",
																						Action = "Whirlseer"
																					}
																				}
																			}
																		}
																	end

																	return {
																		{
																			Chat = "Return when you have all the required materials.",
																			ChatTH = "กลับมาเมื่อเจ้ามีวัสดุครบ"
																		}
																	}
																end
															},
															{
																ButtonType = "Button3",
																ButtonText = "...",
																Action = "Close"
															}
														}
													}
												}
											},
											{
												ButtonType = "Button3",
												ButtonText = "...",
												Action = "Close"
											}
										}
									}
								}
							},
							{
								ButtonType = "Button3",
								ButtonText = "...",
								Action = "Close"
							}
						}
					}
				}
			end
		end
	end
}