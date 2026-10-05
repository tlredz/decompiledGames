require(game.ReplicatedStorage.DialoguesList.Types)

local function fontify(p: string)
	return (`<font face="IndieFlower" size="40">{p}</font>`)
end

return {
	Title = "xindra_tentashun",
	Get = function(self)
		if workspace:GetAttribute("DogHouseAdminAbuseActive") == true then
			if workspace:GetAttribute("DogHouseJoinable") == true then
				return {
					Text = { "<Color=White><AnimateStyle=Wiggle><AnimateStyleTime=0.1><AnimateStyleAmplitude=1.8><AnimateStepFrequency=1><AnimateStepTime=0.065>I ASKED FOR THE BOSS ADMIN! HE TREATS ME AS DOG! UNFAIR! DO NOT BOTHER ME!<Color=/>" },
					Option1 = {
						Label = "fight me then",
						Text = { "<Color=Red>OK THEN COME 😠<Color=/>" },
						Function = function()
							game.ReplicatedStorage.Remotes.CommF_:InvokeServer("DogHouse", "indra")
						end
					}
				}
			end

			return {
				Text = { "NOT YET NOOB!! THE SHOW NO START YET!! U WAIT UR TURN!!" }
			}
		else
			local Players = game:GetService("Players")
			local localPlayer = Players.LocalPlayer

			if localPlayer and localPlayer:HasTag("DogHouseLorePending") then
				task.spawn(function()
					pcall(function()
						game.ReplicatedStorage.Remotes.CommF_:InvokeServer("DogHouse", "SeenIndraLore")
					end)
				end)
				return {
					Text = {
						"you.. you FIHGT him? the robot one?? that thing is NOT me bro..",
						"<Color=White><AnimateStyle=Wiggle><AnimateStyleTime=0.1><AnimateStyleAmplitude=1.8><AnimateStepFrequency=1><AnimateStepTime=0.065>WHEN I GET DELETED HE TOOK MY USERNAME AND PUT RIP_ INFRONT!!<Color=/>",
						"my name was <Color=Red>indraxxchan<Color=/>... now that fake robot walk around as <Color=Red>rip_indra<Color=/> like he is ME.."
					},
					Option1 = {
						Label = "so ur the real indra?",
						Text = {
							"YES!! im the OG!! the REAL me!! he just copy paste noob!! he stealed MY name and slap it on him!!",
							"they delete ME and keep HIM.. so unfair.. so UNFAIR.."
						}
					},
					Option2 = {
						Label = "thats messed up bro",
						Text = { "ye.. so nex time u see 'rip_indra'.. u remember good.. that was MY name FIRST!! that robot is big THIEF noob!!" }
					}
				}
			else
				return {
					Text = { [[
<font face="IndieFlower" size="40">HI BRO can i have <Color=Red>97<Color=/> <AnimateStyle=Wiggle><Color=Green>robux<Color=/>!<AnimateYield=1><AnimateStyle=/>
??????<AnimateYield=1>
</font>]] },
					Option1 = {
						Label = "ye sure bro",
						Text = {
							"<font face=\"IndieFlower\" size=\"40\"><AnimateYield=0.3>hahaha</font>",
							"<font face=\"IndieFlower\" size=\"40\">mentality of child i scammed u like a noob</font>"
						}
					},
					Option2 = {
						Label = "say me why",
						Text = { "<font face=\"IndieFlower\" size=\"40\">i hate you if u say no but if u say ok and u give me we by frien</font>" },
						Option1 = {
							Label = "for say no",
							Text = { "<font face=\"IndieFlower\" size=\"40\">for tell bye dont talk me again</font>" }
						},
						Option2 = {
							Label = "(give nothing)",
							Text = { "<font face=\"IndieFlower\" size=\"40\">xomg give it well and we are frien im sirius</font>" },
							Option1 = {
								Label = "(give good)",
								JumpTo = function()
									return ((function()
										local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("IndraTalk")

										if v == 0 then
											return {
												Text = { "<font face=\"IndieFlower\" size=\"40\">OMG IF U HAVE ALL THE LOVE LETTERS TALK TO MASTER ROBOT NO ME!!</font>" },
												Option1 = {
													Label = "k",
													JumpTo = function()
														return {
															Text = { "<font face=\"IndieFlower\" size=\"40\">vroom vroom homie</font>" }
														}
													end
												}
											}
										elseif v == 1 then
											return {
												Text = { "<font face=\"IndieFlower\" size=\"40\">omg yo bro are u frien with my masta robot??</font>" },
												Option1 = {
													Label = "u know well",
													Text = { "<font face=\"IndieFlower\" size=\"40\">omg can u say him to forgive me plz bro? i has sayed mygame43 is my master but i lie for i get unban in blox fruits after using autofarm hack</font>" },
													Option1 = {
														Label = "sure thing bro",
														Text = {
															"<font face=\"IndieFlower\" size=\"40\">omg thx bro go find my love letters and expose them at my masta. plz!</font>",
															"[Son quest started.]"
														}
													}
												}
											}
										elseif v == 2 then
											return {
												Text = { "<font face=\"IndieFlower\" size=\"40\">me and robot are homie now he has gived me rumble fruit</font>" },
												Option1 = {
													Label = "k",
													JumpTo = function()
														return {
															Text = { "<font face=\"IndieFlower\" size=\"40\">dont talk to my masta or ill hakai u</font>" }
														}
													end
												}
											}
										end

										return {
											Text = { "<font face=\"IndieFlower\" size=\"40\">thx noob i scam u now i block!!</font>" }
										}
									end)())
								end
							},
							Option2 = {
								Label = "mm nvm kbye",
								Text = { "<font face=\"IndieFlower\" size=\"40\">XOMG BRO HOW U DARE 😠😠😠</font>" },
								Function = function()
									print("rejected quest grrr how u dare")
								end
							}
						},
						Option3 = {
							Label = "resay",
							JumpTo = function()
								return self:Get()
							end
						}
					},
					Option3 = {
						Label = "ur who idk of u",
						Text = { "<font face=\"IndieFlower\" size=\"40\">u dont see that why i dont talk u so much now... <AnimateYield=1> kkkk <AnimateYield=0.5> bye i dont never talk u again</font>" },
						Option1 = {
							Label = "k idc",
							Text = { "<font face=\"IndieFlower\" size=\"40\">u wild never see me again and im block u</font>" }
						},
						Option2 = {
							Label = "YO SON WAIT",
							Text = { "<font face=\"IndieFlower\" size=\"40\">??? what say it fast 😠 im in angry during this moment me</font>" },
							Option1 = {
								Label = "we are homie",
								Text = {
									"<font face=\"IndieFlower\" size=\"40\">idc of homie all time u never give me rubox that why i hate u now</font>",
									"<font face=\"IndieFlower\" size=\"40\">and dont say me homie its finish idk of u</font>",
									"<font face=\"IndieFlower\" size=\"40\">i doing the countrdown for banning u on roblox nsuns4 and this discrd in 10h</font>"
								},
								Option1 = {
									Label = "CANCEL BRO",
									Text = {
										"<font face=\"IndieFlower\" size=\"40\">i cant cancel</font>",
										"<font face=\"IndieFlower\" size=\"40\">nvm cancelet</font>",
										"<font face=\"IndieFlower\" size=\"40\">d</font>"
									},
									Option1 = {
										Label = "can we play",
										Text = {
											"<font face=\"IndieFlower\" size=\"40\">im not supossed to play  in this moment im supposed to study</font>",
											"<font face=\"IndieFlower\" size=\"40\">i have just 10 min im doing something too important homework  of school</font>"
										},
										Option1 = {
											Label = "ill pay robux",
											Text = { "<font face=\"IndieFlower\" size=\"40\">KK IM IN COMING WAIT ME</font>" },
											Option1 = {
												Label = "...",
												Text = {
													"<font face=\"IndieFlower\" size=\"40\">For d'Ay</font>",
													"<font face=\"IndieFlower\" size=\"40\">For say</font>",
													"<font face=\"IndieFlower\" size=\"40\">I can kill all personne</font>",
													"<font face=\"IndieFlower\" size=\"40\">I have a other glich Who click with my mouse</font>"
												},
												Option1 = {
													Label = "proof it",
													Text = {
														"<font face=\"IndieFlower\" size=\"40\">no ur gonna expose to all</font>",
														"<font face=\"IndieFlower\" size=\"40\">can i say u something??</font>"
													},
													Option1 = {
														Label = "say it no shame",
														Text = {
															"<font face=\"IndieFlower\" size=\"40\">I never believe a person</font>",
															"<font face=\"IndieFlower\" size=\"40\">I am a young son yeah I have a sin</font>",
															"<font face=\"IndieFlower\" size=\"40\">I believe Just my parents and the parents of my wife and my wife it's done</font>",
															"<font face=\"IndieFlower\" size=\"40\">One day in highschool I gived 290$to my. Best friend he at used all after he has do like if I gived nothing</font>",
															"<font face=\"IndieFlower\" size=\"40\">When I haved 14 or 15</font>",
															"<font face=\"IndieFlower\" size=\"40\">So one day a unknown has said me do not trust anyone</font>",
															"<font face=\"IndieFlower\" size=\"40\">...</font>",
															"<font face=\"IndieFlower\" size=\"40\">I venged me</font>",
															"<font face=\"IndieFlower\" size=\"40\">2 month later I said him i forgive him</font>",
															"<font face=\"IndieFlower\" size=\"40\">After he has invited me to play in his house</font>",
															"<font face=\"IndieFlower\" size=\"40\">U know what I doing??</font>",
															"<font face=\"IndieFlower\" size=\"40\">A sec</font>",
															"<font face=\"IndieFlower\" size=\"40\">I stole 4 different shoes but one foot each</font>",
															"<font face=\"IndieFlower\" size=\"40\">Of hin</font>",
															"<font face=\"IndieFlower\" size=\"40\">Him</font>",
															"<font face=\"IndieFlower\" size=\"40\">He has never know it's me</font>",
															"<font face=\"IndieFlower\" size=\"40\">you know it's pissing off when you look for a shoe and you do not find the other foot</font>",
															"<font face=\"IndieFlower\" size=\"40\">I'm not stupid</font>",
															"<font face=\"IndieFlower\" size=\"40\">I have everything planned</font>"
														},
														Option1 = {
															Label = "go sleep",
															Text = {
																"<font face=\"IndieFlower\" size=\"40\">Kk bye</font>",
																"<font face=\"IndieFlower\" size=\"40\">😠</font>",
																"<font face=\"IndieFlower\" size=\"40\">Ur not my dad</font>"
															}
														}
													}
												}
											}
										}
									}
								}
							},
							Option2 = {
								Label = "i joke bye",
								Text = { "<font face=\"IndieFlower\" size=\"40\">kk idk same dont talk at me no more</font>" }
							}
						},
						Option3 = {
							Label = "dont forgot am master",
							Text = {
								"<font face=\"IndieFlower\" size=\"40\">OMG HOW DARE</font>",
								"<font face=\"IndieFlower\" size=\"40\">xomg shut up im block u im not ur son anymore</font>",
								"<font face=\"IndieFlower\" size=\"40\">i have a new master he give me all i want</font>"
							}
						}
					}
				}
			end
		end
	end
}