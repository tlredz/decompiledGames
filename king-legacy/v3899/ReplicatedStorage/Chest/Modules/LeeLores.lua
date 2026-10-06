local class = {}
class.__index = class
local v = {
	["Sea Monster"] = {
		Name = "Isolated Warrior",
		THName = "นักรบสันโดษ",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ให้ตายสิพับผ่า!  มันแกร่งกว่า เจ้าทะเล และ ไฮดร้า ซะเสียอีก!?!",
			[2] = "<AnimateStyle=Appear> ข้าเห็นจริงๆนะ ข้าไม่ได้โม้ หรือ ลวงแต่อย่างใด!?!",
			Yes = "อ่า..เชื่อๆ",
			No = "โม้,เพ้อเจ้อแล้วเจ้า!"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>For goodness' sake, it's stronger than Sea King and Hydra combined at once!?",
			[2] = "<AnimateStyle=Appear><Color=/>I really saw it! I'm not lying or anything!",
			Yes = "Ah..I trust you..",
			No = "Insane.."
		}
	},
	["Hidden Warrior"] = {
		Name = "Suffered Warrior",
		THName = "นักรบปางตาย",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>อย่ามายุ่งกับข้า...",
			[2] = "<AnimateStyle=Appear>ได้โปรด...ปล่อยข้าเถิด..",
			Yes = "อ่า..",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/> Leave me alone..",
			[2] = "<AnimateStyle=Appear><Color=/> Please...Let me be..",
			Yes = "Okay!",
			No = "..."
		}
	},
	Nemesis = {
		Name = "Stranded Pirate",
		THName = "สลัดผู้เดียวดาย",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>เจ้ามีนัยน์ตา..",
			[2] = "<AnimateStyle=Appear><Color=/>ดินแดนแห่งนี้ไม่เหมาะกับเจ้า!",
			Yes = "นัยน์ตา?",
			No = "เหอะๆ.."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>You possess that same deadly gaze, just like him..",
			[2] = "<AnimateStyle=Appear><Color=/>This land is not the place for someone like you!",
			Yes = "Deadly gaze?!",
			No = "whatever.."
		}
	},
	["Lost Lover"] = {
		Name = "Sea Girl",
		THName = "สาวท้องทะเล",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ข้ายังคงเฝ้าคอย...เฝ้ารอต่อไป",
			[2] = "<AnimateStyle=Appear><Color=/>การที่ รอ มันเจ็บปวดขนาดนั้นเลยเหรอ?",
			Yes = "ข้าเข้าใจ..",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>I'm still waiting...no matter what",
			[2] = "<AnimateStyle=Appear><Color=/>Why is it so painful to wait for someone?",
			Yes = "I understand",
			No = "..."
		}
	},
	["Master Light"] = {
		Name = "Young Trainee",
		THName = "หนุ่มน้อยฝึกหัด",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>เจ้าเชื่อข้ามั้ยหล่ะ! ข้าจะฝึก ฝึกจนแกร่งและมาท้าสู้กับเจ้า!",
			[2] = "<AnimateStyle=Appear><Color=/>อย่าชะล่าใจหล่ะ! ข้าทำได้จริงๆ รอดูเลยแล้วกัน!",
			Yes = "ข้าจะรอดู",
			No = "เหอะๆ"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Won't you believe that I'll train even harder and become stronger to challenge you!",
			[2] = "<AnimateStyle=Appear><Color=/>Don't underestimate me! I'll prove it... just wait and see.",
			Yes = "I'll see...",
			No = "whatever.."
		}
	},
	["Island Guy"] = {
		["Island Guy 1"] = {
			Name = "Withness Citizen",
			THName = "ชาวบ้านผู้ประจักษ์",
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ฉันจำการสั่นสะเทือนของมันได้.. ฉันว่าต้องเป็นมันแน่ๆ!?!",
				[2] = "<AnimateStyle=Appear><Color=Red>ใช่! มัน! ผู้ที่จะแหวกว่ายมาจากใต้โลกา!",
				Yes = "มัน?",
				No = "ปรกติ..หนิ"
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>I recognize that previous quake... Could it be the one!?",
				[2] = "<AnimateStyle=Appear><Color=Red>YES! IT'S THE ONE WHO WILL RISE!",
				Yes = "that one?",
				No = "Its normal"
			}
		}
	},
	["Kraken Codex Easy"] = {
		Name = "Sea's Researcher",
		THName = "นักค้นคว้าใต้โลกา",
		QuestName = "Krakenci Codes (Easy)",
		QuestGiven = {
			Name = "Krakenci Codes (Easy)",
			LvRequired = 3000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>...เจ้าจักเป็นคนที่แก้ไขปริศนาเหล่านี้ได้หรือไม่...",
			[2] = "<AnimateStyle=Appear>แก้ปริศนาไหม?",
			Yes = "ปริศนา?",
			No = "ไม่สนใจ..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Will you solve this puzzle or not?...",
			[2] = "<AnimateStyle=Appear>Wanna solve the Puzzle?",
			Yes = "Puzzle?!",
			No = "Whatever..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>...แก้ปริศนาให้จงได้...",
				[2] = "<AnimateStyle=Appear>อย่าได้หา หรือ หวังคำตอบจากข้าเลย..",
				Yes = "ใบ้ข้าที",
				No = "ไม่เข้าใจ"
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>...Solve the Puzzle...",
				[2] = "<AnimateStyle=Appear>Don't seek the answer from here...",
				Yes = "Hint,Please",
				No = "Don't get it."
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>ปริศนาที่จะท้าทายสติปัญญาของเจ้า.. <Color=Green> (ระดับง่าย)",
				[2] = "<AnimateStyle=Appear>จงตามหาผู้คุมอสูร เจ้าจักได้เครื่องมือถอดรหัส...",
				Yes = "ปริศนา?",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear>The puzzle that would challenge your mind... <Color=Green> (Easy)",
				[2] = "<AnimateStyle=Appear>Find the Kraken's Guard, you will find the Codex's Kit.",
				Yes = "Puzzle?",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>เจ้าเหมาะสมที่จะพบกับนายท่าน...เพียงแค่รอเวลาเท่านั้น ",
				[2] = "<AnimateStyle=Appear>แล้วพบกันใหม่...",
				Yes = "นายท่าน?",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>You are prepared to meet the Master, just wait for the proper time.",
				[2] = "<AnimateStyle=Appear>We shall meet again...",
				Yes = "Alright",
				No = "..."
			}
		}
	},
	["Puzzle First"] = {
		Name = "Sea Mechanic",
		THName = "ช่างกลแห่งท้องทะเล",
		QuestName = "Puzzle Mania",
		QuestGiven = {
			Name = "Puzzle Mania",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/> ติ๊ก..ตอก...ติ๊ก..ตอก..มนุษย์อย่างเจ้าทำได้ไหม?",
			[2] = "<AnimateStyle=Appear><Color=/> ติ๊ก...",
			Yes = "อะไรฟะ?",
			No = "เหอะๆ"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/> Tick...Tick...Tick, Human like you can solve it?",
			[2] = "<AnimateStyle=Appear><Color=/>  Tick...",
			Yes = "What?!",
			No = "Whatever..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>แก้ปริศนาเหล่านี้..ของง่ายๆสำหรับนักท่องใต้ภิภพ",
				[2] = "<AnimateStyle=Appear>...แค่เรียงมันให้ถูก...",
				Yes = "ง่าย?",
				No = "ไม่เข้าใจ"
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Solve this puzzle...by sorting these out,Easy peasy for Sea Traveler.",
				[2] = "<AnimateStyle=Appear>Just sort'em right...",
				Yes = "Sort?",
				No = "Don't get it."
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>ปลา? ปลาหมึก? ปะการัง? จ้าวทะเล?",
				[2] = "<AnimateStyle=Appear>แก้ไขให้ถูก..เจ้าจักได้..รางวัล",
				Yes = "จะรู้ไหม?",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear>Fish? Kraken? Corals? Sea Beast?",
				[2] = "<AnimateStyle=Appear>Solve it...And the prize shall be yours",
				Yes = "How should I know",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ขอแสดงความยินดีด้วย! คุณได้ไขปริศนาปริศนาที่ง๊ายง่ายแล้ว!",
				[2] = "<AnimateStyle=Appear>ไว้กลับมาอีกครั้ง หากต้องการที่จะไขปริศนาอีกช่วง...",
				Yes = "",
				No = ""
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Congrats! You've solved the Basic Puzzle!",
				[2] = "<AnimateStyle=Appear>Comeback again to solve the Puzzle around...",
				Yes = "Alright",
				No = "..."
			}
		}
	},
	["the Depth"] = {
		Name = "The Lucky Diver",
		THName = "นักประดาน้ำผู้โชคดี",
		QuestName = "Rolling in the Depth",
		QuestGiven = {
			Name = "Rolling in the Depth",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ว่าแล้วต้องมีมนุษย์มาที่แห่งนี้จนได้!",
			[2] = "<AnimateStyle=Appear><Color=/>ว่ายังไง?",
			Yes = "อ่า..",
			No = "เพิ่งรู้เหรอ?"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>I knew it! Finally, a human has set foot in this place!",
			[2] = "<AnimateStyle=Appear><Color=/>What's up?",
			Yes = "Uh...",
			No = "Whatever..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>รีบๆเข้ามัวรออะไรอยู่?!",
				[2] = "<AnimateStyle=Appear>ถ้ามัวแต่กลัวเมื่อไหร่จะกล้า!?!",
				Yes = "กลัวหน่ะ",
				No = "เข้าใจแล้ว"
			},
			US = {
				[1] = "<AnimateStyle=Appear>Hurry! What are you waiting for?",
				[2] = "<AnimateStyle=Appear>If you're scared, where is your courage?!",
				Yes = "Scared.",
				No = "Understood."
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>โชคดีที่เจ้าไม่ต้องมนต์สะกดของเจ้า<Color=Yellow> ปลาหมึกยักษ์<Color=/> นั่น",
				[2] = "<AnimateStyle=Appear>ใช่...พรรคพวกของข้าที่อยู่บริเวณนั้นเสร็จมันจนได้..",
				Yes = "มนต์?",
				No = "ไม่หรอก"
			},
			US = {
				[1] = "<AnimateStyle=Appear>Luckily, you're not possessed by mythical magic from that <Color=Yellow> gigantic squid.",
				[2] = "<AnimateStyle=Appear>Yes, my friend over there already got them...",
				Yes = "Magic?",
				No = "No"
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ขอบคุณเจ้ามากๆนะ เพียงเท่านี้เพื่อนๆของข้าคงไปสบายแล้ว...",
				[2] = "<AnimateStyle=Appear>แต่อย่าเพิ่งนิ่งนอนใจไป...มนต์นั่นอาจจะกลับมาอีก!",
				Yes = "ระวังตัวด้วยหล่ะ",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Thank you! They deserved to rest in peace.",
				[2] = "<AnimateStyle=Appear>But don't be at ease... A mythical magic might come back again!",
				Yes = "Be careful!",
				No = "..."
			}
		}
	},
	["Lost Fugitive"] = {
		Name = "Shaw - The Guard",
		THName = "ผู้คุมชอว์",
		QuestName = "Redemption",
		QuestGiven = {
			Name = "Redemption",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>เจ้า! มนุษย์! เห็นนักโทษหลบหนีไปบ้างไหม?",
			[2] = "<AnimateStyle=Appear><Color=/>ว่ายังไง เห็นมันไหม?",
			Yes = "?",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>You there! Human! Have you seen the prisoner?",
			[2] = "<AnimateStyle=Appear><Color=/>What's up? Have you seen the prisoner?",
			Yes = "?",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ฟังนะ! นักโทษมันไม่กลับมาหาผู้คุมหรอก",
				[2] = "<AnimateStyle=Appear>ถ้าคุกมันสบายมันจะหลบหนีไปทำไหมวะ?",
				Yes = "เดี๋ยวก็กลับมา",
				No = "จริง.."
			},
			US = {
				[1] = "<AnimateStyle=Appear>Listen! That prisoner won't come back by itself.",
				[2] = "<AnimateStyle=Appear>If the prison is safe, why are they trying to escape?",
				Yes = "They will come back.",
				No = "Understood."
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>ใช่...เจ้าบ้านั่นมันแหกคุกโดยใช้ <Color=Red> ช้อน <Color=/> บ้าไหมหล่ะ?",
				[2] = "<AnimateStyle=Appear>ยังไงข้าฝากเจ้าสั่งสอนมันหน่อยได้ไหม? หวดมักซัก <Color=Red> 3 <Color=/> ครั้งพอ",
				Yes = "บ้าสิ",
				No = "ไม่เห็น"
			},
			US = {
				[1] = "<AnimateStyle=Appear>Yes... that convict escaped from the prison using a <Color=Red>Spoon<Color=/>. That's crazy, isn't it?",
				[2] = "<AnimateStyle=Appear>Whatever, are you willing to punish them, like <Color=Red>3<Color=/> times?",
				Yes = "Yes,it is",
				No = "No"
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>เจ้าเก่งมากๆ สนใจลองมาเป็น<Color=Green>ผู้คุม<Color=/>บ้างมั้ยหล่ะ?",
				[2] = "<AnimateStyle=Appear>ล้อเล่นหน่ะ! ยังไงซะพวกนักโทษเดี๋ยวมันก็หลบหนีใหม่อีก...",
				Yes = "ไม่หล่ะ",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>You're really good at this. If you have time, <Color=Green> would you like to be a guard?",
				[2] = "<AnimateStyle=Appear>Kidding! It's only a matter of time before those prisoners try to escape again...",
				Yes = "No",
				No = "..."
			}
		}
	},
	["Into Deep First"] = {
		Name = "The Annoying Sea Citizen ",
		THName = "ชาวทะเลผู้หงุดหงิด",
		QuestName = "Kill 4 Deep Diver",
		QuestGiven = {
			Name = "Kill 4 Deep Diver",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>มนุษย์!? ข้าได้ยินว่าเจ้ากล้าหาญชาญชัย ยิ่งนัก!",
			[2] = "<AnimateStyle=Appear><Color=/>ว่ายังไง?",
			Yes = "ธรรมดา~",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Human!? I heard that you're skilled!",
			[2] = "<AnimateStyle=Appear><Color=/>What's up?",
			Yes = "?",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>สรุปเจ้าจัดการพวกมันหรือยัง?",
				[2] = "<AnimateStyle=Appear>ให้ไวเลย! ข้าไม่อยากหงุดหงิดไปมากกว่านี้!",
				Yes = "ยัง...",
				No = "กำลังไป"
			},
			US = {
				[1] = "<AnimateStyle=Appear>Have you defeated all of them?",
				[2] = "<AnimateStyle=Appear>Hurry up! I don't want to get more upset!",
				Yes = "Not yet.",
				No = "On my way."
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>เจ้าอยากจะช่วยข้าจัดการพวก<Color=Red>นักประดาน้ำประหลาด<Color=/>สินะ!",
				[2] = "<AnimateStyle=Appear>เยี่ยมไปเลย, เจ้าเก่งจริงๆด้วย...งั้นจัดการพวกมัน <Color=Red> 4 <Color=/> ครั้งพอ",
				Yes = "แน่นอน",
				No = "ไม่อะ"
			},
			US = {
				[1] = "<AnimateStyle=Appear>You would like to help me defeat those <Color=Red>Deep Divers<Color=/>, wouldn't you?",
				[2] = "<AnimateStyle=Appear>Great! You're very talented...So, how about defeating them <Color=Red>4<Color=/> times?",
				Yes = "Sure",
				No = "No"
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>",
				[2] = "<AnimateStyle=Appear>",
				Yes = "",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>",
				[2] = "<AnimateStyle=Appear>",
				Yes = "",
				No = "..."
			}
		}
	},
	["Into Deep Second"] = {
		Name = "Wandering Sea Citizen",
		THName = "ชาวทะเลพเนจร",
		Multi = "Quest",
		BulkQuest = {
			{
				QuestName = "Kill Fugitive",
				QuestGiven = {
					Name = "Kill Fugitive",
					LvRequired = 4050
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/>เจ้าอยากจะจัดการ<Color=Red>นักโทษ<Color=/>หลบหนีสินะ!?",
					[2] = "<AnimateStyle=Appear>ถ้างั้นก็ฝากด้วยแล้วกัน เจ้านั่นคงอยู่แถวๆนี้แหละ",
					Yes = "แน่นอน",
					No = "ไม่อะ"
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>Oh! You want to defeat that <Color=Red>Fugitive <Color=/> aren't you!?",
					[2] = "<AnimateStyle=Appear><Color=/>Welp...good luck, that Fugitive might be around here...",
					Yes = "Alright",
					No = "No!"
				},
				Quest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>มัวรออะไรอยู่หล่ะ!",
						[2] = "<AnimateStyle=Appear><Color=/>เจ้ามนุษย์นี่จริงๆเลย ใช้ทักษะของเจ้าสิฟะ!",
						Yes = "มันอยู่ไหนนะ?",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>What are you waiting for!?!",
						[2] = "<AnimateStyle=Appear><Color=/>What kind of human are you? Use your sense!",
						Yes = "Where?",
						No = "..."
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/> ",
						[2] = "<AnimateStyle=Appear><Color=/>",
						Yes = "??",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>",
						[2] = "<AnimateStyle=Appear><Color=/>",
						Yes = "??",
						No = "..."
					}
				}
			},
			{
				QuestName = "Kill 4 Deep one Villager",
				QuestGiven = {
					Name = "Kill 4 Deep one Villager",
					LvRequired = 4100
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/>ดูเหมือนเจ้าจะไม่กลัวเลยสินะ..",
					[2] = "<AnimateStyle=Appear>ไหนๆแล้วก็ลองจัดการเจ้าพวก<Color=Red>อสูรใต้น้ำ<Color=/> ที่ครั้งนึงพวกมันเคยชนชาวเราหน่อยแล้วกัน...",
					Yes = "ไม่กลัว..",
					No = "..."
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>So you are not scared at all..",
					[2] = "<AnimateStyle=Appear><Color=/>Alright, let's try to defeat those <Color=Red>Deep One Villagers<Color=/>,they were once our kind...",
					Yes = "Yes",
					No = "..."
				},
				Quest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>เป็นยังไงจัดการพวกมันได้ไหม?",
						[2] = "<AnimateStyle=Appear><Color=/>เอ้า! ไหงงั้นหล่ะ? เจ้าควรจะไม่กลัว และเป็นผู้กล้าจัดการพวกมันหนิ...",
						Yes = "ยังเลย...",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>Have you defeated all of them?",
						[2] = "<AnimateStyle=Appear><Color=/>What happened? You're not supposed to scare them and act like a hero.",
						Yes = "Not yet...",
						No = "..."
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>",
						[2] = "<AnimateStyle=Appear><Color=/>",
						Yes = "..",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>",
						[2] = "<AnimateStyle=Appear><Color=/>",
						Yes = "",
						No = "..."
					}
				}
			}
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>มนุษย์! ออกไปจากที่แห่งนี้ถ้าเจ้าไม่อยากเป็นอะไรไป!",
			[2] = "<AnimateStyle=Appear>ว่ายังไง!?!",
			Yes = "..",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Human, get out of this place if you don't want to get in trouble!",
			[2] = "<AnimateStyle=Appear><Color=/>What's up?",
			Yes = "..",
			No = "..."
		}
	},
	["Into Deep Third"] = {
		Name = "Undersea's Guard",
		THName = "ผู้คุมใต้ทะเล",
		Multi = "Quest",
		BulkQuest = {
			{
				QuestName = "Kill 6 Fishman Guardian",
				QuestGiven = {
					Name = "Kill 6 Fishman Guardian",
					LvRequired = 4150
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/>โอ้! อยากจะลองของกับพวก <Color=Red> Fishman Guardian<Color=/> สินะ!",
					[2] = "<AnimateStyle=Appear>งั้นก็ฝากจัดการพวกมันซัก <Color=Red> 6 <Color=/> ครั้งก็แล้วกันนะ,เจ้ามนุษย์เอ๋ย..",
					Yes = "แน่นอน",
					No = "ไม่อะ"
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>Oh! Wanna beat those <Color=Red> Fishman Guardians<Color=/> aren't you!?",
					[2] = "<AnimateStyle=Appear><Color=/>Defeat them,Let's say <Color=Red> 6 <Color=/> of them, Good luck Human...",
					Yes = "Absolutely",
					No = "No!"
				},
				Quest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/> ทำไมใช้เวลานานจังหล่ะ?",
						[2] = "<AnimateStyle=Appear><Color=/>ไม่ต้องมาก็...มนุษย์อย่างเจ้าขี้เกียจจริงๆสินะ",
						Yes = "ก็..",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>Why are you taking so long?",
						[2] = "<AnimateStyle=Appear><Color=/>Because you're lazy, that's all, Human like you...",
						Yes = "Because...",
						No = "..."
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>",
						[2] = "<AnimateStyle=Appear><Color=/>",
						Yes = "??",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>",
						[2] = "<AnimateStyle=Appear><Color=/>",
						Yes = "??",
						No = "..."
					}
				}
			},
			{
				QuestName = "Kill The deep one",
				QuestGiven = {
					Name = "Kill The deep one",
					LvRequired = 4200
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/>อยากลองจัดการ <Color=Red> The deep one <Color=/> ,หน่อยไหมเจ้ามนุษย์?",
					[2] = "<AnimateStyle=Appear>ครั้งนี้ขอแบบจัดเต็มให้ข้าได้รู้ว่าเจ้าแกร่งจริงๆ...",
					Yes = "ได้เลย!",
					No = "..."
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>Wanna try beat <Color=Red> The Deep one <Color=/>?,What do you say, Human?",
					[2] = "<AnimateStyle=Appear><Color=/>This time I'd like to see you act like a real hero..",
					Yes = "Yes",
					No = "..."
				},
				Quest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>ข้าไม่อยากพูดเป็นซ้ำสองหรอกนะ...",
						[2] = "<AnimateStyle=Appear><Color=/>อย่าให้มีครั้งที่สามก็แล้วกัน...รีบไปจัดการ!",
						Yes = "พูดสิ",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>I don't want to say this again...",
						[2] = "<AnimateStyle=Appear><Color=/>Don't ever tease me like this... Defeat them!",
						Yes = "Say it",
						No = "..."
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>",
						[2] = "<AnimateStyle=Appear><Color=/> ",
						Yes = "ธรรมดา..",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>",
						[2] = "<AnimateStyle=Appear><Color=/>.",
						Yes = "Absolutely",
						No = "..."
					}
				}
			},
			{
				QuestName = "Kill Fishman King's Guard",
				QuestGiven = {
					Name = "Kill Fishman King's Guard",
					LvRequired = 4250
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/>เจ้าอีกแล้วรึ!?!  ไหนๆก็มาแล้วก็ไปจัดการพวก <Color=Red> Fishman King's Guard <Color=/> แล้วกัน",
					[2] = "<AnimateStyle=Appear>เลิกยุ่งกับข้าซักที...แล้วไปจัดการพวกมันซะ!",
					Yes = "อีกแล้ว?",
					No = "..."
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>This human again...Really? , Whatever defeat <Color=Red> Fishman King's Guard<Color=/> then..",
					[2] = "<AnimateStyle=Appear><Color=/>Leave me alone already...defeat'em will you!",
					Yes = "Again,what?",
					No = "..."
				},
				Quest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>เจ้ามนุษย์ฟังนะ! ข้าให้ภารกิจ ไม่ใช่ให้เจ้ามาถามข้าซ้ำ!",
						[2] = "<AnimateStyle=Appear><Color=/>ข้ามีหน้าที่ให้ภารกิจ! ไปจัดการพวกมันได้แล้ว!",
						Yes = "ถามไม่ได้หรอ?",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>Listen, Landwalker! I'm giving you a task, not giving you a speech!",
						[2] = "<AnimateStyle=Appear><Color=/>Why!? I'm a task giver! Go get'em!",
						Yes = "Why!?",
						No = "..."
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>",
						[2] = "<AnimateStyle=Appear><Color=/> ",
						Yes = "..",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>",
						[2] = "<AnimateStyle=Appear><Color=>",
						Yes = "",
						No = "..."
					}
				}
			}
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ว่ายังไงเจ้ามนุษย์เดินดิน...",
			[2] = "<AnimateStyle=Appear>แล้วไงต่อ?",
			Yes = "...",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>What about it,Landwalker?",
			[2] = "<AnimateStyle=Appear><Color=/>So?",
			Yes = "Yes..",
			No = "..."
		}
	},
	["Ain't my Fault"] = {
		Name = "Unlucky One",
		THName = "ผู้โชคร้าย",
		QuestName = "Ain't my Fault",
		QuestGiven = {
			Name = "Ain't my Fault",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ข้าคงไม่ใช่คนเดียวสินะที่ลงมาที่แห่งนี้น่ะ",
			[2] = "<AnimateStyle=Appear><Color=/>อยากออกไปจากที่นี้ไหมสรุป?",
			Yes = "ใช่แล้ว..",
			No = "เหอะๆ"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>I'm not the only one down here...",
			[2] = "<AnimateStyle=Appear><Color=/>Wanna get out of this place?",
			Yes = "It is...",
			No = "Whatever..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ว่ายังไง เจ้าเจอ หรือ เก็บได้บ้างหรือยัง?",
				[2] = "<AnimateStyle=Appear>ไม้กระดานมันจะลอยมาหาเจ้าเองหรอกนะ หามันสิ!",
				Yes = "ข้าไม่รู้มันอยู่ไหนหน่ะ",
				No = ""
			},
			US = {
				[1] = "<AnimateStyle=Appear>Well, found or collected anything yet?",
				[2] = "<AnimateStyle=Appear>Look! Wood Plank doesn't float by itself, find it!",
				Yes = "Where?",
				No = "Don't get it."
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>เจ้าเองก็อยากจะออกไปจากที่นี้เหมือนกันอย่างงั้นรึ?",
				[2] = "<AnimateStyle=Appear>ช่วยข้าเก็บ <Color=Green> ไม้กระดาน <Color=/> หน่อยได้มั้ยหล่ะ? ข้าอยากจะลองอะไรซักหน่อย",
				Yes = "คงงั้น?",
				No = "ไม่หรอก"
			},
			US = {
				[1] = "<AnimateStyle=Appear>So you want to get out of this place too, don't you?",
				[2] = "<AnimateStyle=Appear>Help me collect <Color=Green> Wood Plank <Color=/> will you? I'd like to try something",
				Yes = "Maybe?",
				No = "No"
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ขอบคุณเจ้ามากๆ เดี๋ยวข้าขอนำไม้เหล่านี้ไปลองอะไรซักหน่อย",
				[2] = "<AnimateStyle=Appear>ยังไงซะไว้เจอกันอีกทีประมาณ ",
				Yes = "โชคดี",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Very kind of you! Let me try something with these Wood Plank.",
				[2] = "<AnimateStyle=Appear>Anyway will see you again around ",
				Yes = "Alright",
				No = "..."
			}
		}
	},
	["Until Pond"] = {
		Name = "Strange Pond",
		THName = "ธารน้ำประหลาด",
		QuestName = "Until Pond",
		QuestGiven = {
			Name = "Until Pond",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>บุ๋ง บุ๋ง บุ๋ง~",
			[2] = "<AnimateStyle=Appear><Color=/>บุ๋ง บุ๋ง?",
			Yes = "อะไรคือ บุ๋ง?",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Blub Blub Blub~",
			[2] = "<AnimateStyle=Appear><Color=/>Blub Blub?",
			Yes = "Blub,What?",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ข้าเข้าใจแล้วว่าเจ้าพูดได้ มัวรออะไรอยู่หล่ะ?",
				[2] = "<AnimateStyle=Appear>ถ้าข้าบอกว่าถูกสาปเจ้าจะเชื่อไหม? เอาหล่ะรีบไปจัดการให้เสร็จซะ",
				Yes = "ทำไมเจ้าถึงพูดได้?",
				No = "รับทราบ!"
			},
			US = {
				[1] = "<AnimateStyle=Appear>I understand that you can speak. What are you waiting for?",
				[2] = "<AnimateStyle=Appear>If I tell you that I'm cursed, will you believe me? Keep going with the task!",
				Yes = "Speaking?",
				No = "Got it!"
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>พูดภาษาคนได้ก็ไม่บอก โถ่ว! ",
				[2] = "<AnimateStyle=Appear>ไหนๆก็เข้าใจข้าอย่างดี อย่างน้อยจัดการพวกปีศาจนั่นทีได้ไหมหล่ะ?",
				Yes = "เอ้า!",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear>You can communicate?! Why didn't you tell me?",
				[2] = "<AnimateStyle=Appear>Seems like you understand me well. Just defeat that monster for me, will you?",
				Yes = "What!",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>เยี่ยมมากๆ ขอบคุณจริงๆ คราวนี้ข้าจะได้พักซักที",
				[2] = "<AnimateStyle=Appear>ถ้าเจ้าอยากจะจัดการพวกมันอีก ค่อยกลับมาอีกที ",
				Yes = "โชคดี",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Great! Appreciated. I'm finally at rest now.",
				[2] = "<AnimateStyle=Appear>If you want to defeat them again, meet me around ",
				Yes = "Alright",
				No = "..."
			}
		}
	},
	["Can't Kelp,But Wait?"] = {
		Name = "Kelp Eater",
		THName = "ตัวกินสาหร่าย",
		QuestName = "Can't Kelp,But Wait?",
		QuestGiven = {
			Name = "Can't Kelp,But Wait?",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>เจ้าหน่ะ! ใช่! เจ้านั่นแหละ!",
			[2] = "<AnimateStyle=Appear><Color=/>..ว่ายังไง",
			Yes = "ข้าหรอ?",
			No = "(ไม่สนใจ)"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>You there! Yes, you! You!",
			[2] = "<AnimateStyle=Appear><Color=/>What'sup",
			Yes = "Me?",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>หาเจอไหม? ถ้าหาไม่เจอข้าอาจจะกินเจ้าแทนนะ!",
				[2] = "<AnimateStyle=Appear>งั้นก็เร็วๆหน่อยสิ! เจ้าไม่เข้าใจหรอกว่า ข้าหิวมากแค่ไหน",
				Yes = "อย่าเลย!",
				No = "!"
			},
			US = {
				[1] = "<AnimateStyle=Appear>Found it? If you can't find it, I'll consider you as food then.",
				[2] = "<AnimateStyle=Appear>Hurry then! You don't understand how much I'm starved.",
				Yes = "Please,Don't!",
				No = "!"
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>ข้าหิวไม่ไหวแล้ว ​ไม่มีสิ่งมีชีวิตใดมาช่วยให้อาหารข้าเลย ช่วยข้าหน่อยได้ไหม?",
				[2] = "<AnimateStyle=Appear>คืองี้ข้าหน่ะชื่นชอบ <Color=Green> สาหร่าย <Color=/> มากๆ พอจะหาให้ได้ไหมหล่ะ",
				Yes = "ได้เลย",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear>I'm so starved, there's no one who can feed me well. Would you rather help?",
				[2] = "<AnimateStyle=Appear>Well, I'm really enjoying the <Color=Green> Kelp.<Color=/> Find it and collect them for me.",
				Yes = "Alright",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ขอบคุณเจ้ามากๆ เท่านี้ก็น่าจะมีอะไรกินได้ซักพัก แต่ว่า...",
				[2] = "<AnimateStyle=Appear>ก็นะ...ข้าก็ต้องกินอีกหน่ะสิ ไว้กลับมาใหม่แล้วกัน ช่วง",
				Yes = "แต่ว่า?",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Much appreciated, finally I have something to eat, but...",
				[2] = "<AnimateStyle=Appear>Well... either way, I have to eat again. Just come back again tomorrow around...",
				Yes = "But?",
				No = "..."
			}
		}
	},
	["The Bubble Two"] = {
		Name = "Man In The Bubble",
		THName = "ชายผู้อยู่ในฟองสบู่",
		QuestName = "We'll Float too!",
		QuestGiven = {
			Name = "We'll Float too!",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>",
			[2] = "<AnimateStyle=Appear><Color=/>",
			Yes = "เหงา?",
			No = "(ไม่สนใจ)"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>",
			[2] = "<AnimateStyle=Appear><Color=/>",
			Yes = "lonely?",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/> ",
				[2] = "<AnimateStyle=Appear>",
				Yes = "ใช่!",
				No = "!"
			},
			US = {
				[1] = "<AnimateStyle=Appear> ",
				[2] = "<AnimateStyle=Appear> ",
				Yes = "Yes!",
				No = "!"
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>",
				[2] = "<AnimateStyle=Appear>",
				Yes = "โอเค",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear> ",
				[2] = "<AnimateStyle=Appear>",
				Yes = "Alright",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>",
				[2] = "<AnimateStyle=Appear>",
				Yes = "รับทราบ",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>",
				[2] = "<AnimateStyle=Appear>",
				Yes = "Got it!",
				No = "..."
			}
		}
	},
	["The Bubble One"] = {
		Name = "Man In The Bubble",
		THName = "ชายผู้อยู่ในฟองสบู่",
		QuestName = "Hide'n Seek!",
		QuestGiven = {
			Name = "Hide'n Seek!",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>เฮ้! เจ้ามนุษย์ ว่างพอที่จะลองทำอะไรสนุกๆดูมั้ยหล่ะ...",
			[2] = "<AnimateStyle=Appear><Color=/>ว่ายังไง? สรุปสนใจหรือไม่...",
			Yes = "เหงา?",
			No = "(ไม่สนใจ)"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Hey Human! Do you want to try something fun?",
			[2] = "<AnimateStyle=Appear><Color=/>so? what do you think...",
			Yes = "lonely?",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/> ยังหาของพวกนั้นยังไมเจอหล่ะสิ?",
				[2] = "<AnimateStyle=Appear>ลองหาพวก 'พุ่มไม้' หรือ 'กล่อง' อะไรก็ตามที่เป็นของหน่ะ",
				Yes = "ใช่!",
				No = "!"
			},
			US = {
				[1] = "<AnimateStyle=Appear> Still can't find those objects, right?",
				[2] = "<AnimateStyle=Appear> Try to find or hunt <Color=Yellow>'Bushes'<Color=/> or <Color=Yellow>'Boxes'<Color=/>  that look like a prop",
				Yes = "Yes!",
				No = "!"
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>เรื่องสนุกที่ว่าก็คือ <Color=Green> ซ่อนแอบ <Color=/> หน่ะ",
				[2] = "<AnimateStyle=Appear>เพราะว่าข้าอยากให้แน่ใจว่าพวกของที่กระจัดกระจายแถวนี้มัน ซ่อน ได้หน่ะ",
				Yes = "โอเค",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear> The fun thing is <Color=Green> 'Hide n' Seek'",
				[2] = "<AnimateStyle=Appear> I want to make sure those things that scattered around are able to <Color=Yellow>'Hide'",
				Yes = "Alright",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ขอบคุณเจ้ามากๆ ไว้ข้ามีเพื่อนใต้โลกาผ่านมา จะลองนัดเล่นดู...",
				[2] = "<AnimateStyle=Appear>ไว้กลับมาทดสอบอีกรอบประมาณ...",
				Yes = "รับทราบ",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Appreciated, I'll wait for my underworld friend to stop by...",
				[2] = "<AnimateStyle=Appear> If you want to test it, come back again around...<Color=Green>",
				Yes = "Got it!",
				No = "..."
			}
		}
	},
	["Ring Ring Ring"] = {
		Name = "Tower Guard",
		THName = "ผู้คุมอาคาร",
		QuestName = "Ring Ring Ring",
		QuestGiven = {
			Name = "Ring Ring Ring",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ให้ตายซิ..เอายังไงดี เอายังไงดีนะ",
			[2] = "<AnimateStyle=Appear><Color=/> เอายังไงดีนะ...",
			Yes = "",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>For God's sake... what should I do...",
			[2] = "<AnimateStyle=Appear><Color=/>What should I do....",
			Yes = "",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ข้ายังไม่ได้ยินเสียง ระฆัง ซักนิดเลย...เจ้าตีมันแล้วเหรอ?",
				[2] = "<AnimateStyle=Appear>งั้นก็ให้ไวเลย! ระฆังนั่นต้องถูกตีทุกวัน ไม่เช่นนั้นข้า หรือ เจ้าจะถูกตีแทน",
				Yes = "ยังหน่ะ",
				No = "!"
			},
			US = {
				[1] = "<AnimateStyle=Appear>I can't hear any rings from that Bell...have you rung it already?",
				[2] = "<AnimateStyle=Appear>Be quick! That bell's supposed to ring every day, unless either you or me is gonna get hit, though.",
				Yes = "No..",
				No = ""
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>เจ้า! เจ้าผู้เดินดิน ได้โปรดทำแทนข้าหน่อยได้มั้ย หาทางขึ้นไปข้างบนนั้น และ ตี <Color=Yellow> ระฆัง",
				[2] = "<AnimateStyle=Appear>ขอบใจเจ้ามากๆนะ จริงๆไม่ใช่หน้าที่ข้าหรอก ข้าแค่เฝ้ายามพื้นที่แห่งนี้เฉยๆ...",
				Yes = "ได้สิ!",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear>You! Landwalker, please do it for me. Find a way to get up there and ring that <Color=Yellow> Bell!",
				[2] = "<AnimateStyle=Appear>Appreciated! Actually, this isn't my duty. I'm just a guard who watches over this area...",
				Yes = "Sure!",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ขอบคุณเจ้ามากๆ ไว้ถ้ามีโอกาสข้าจะตอบแทนบุญคุณนะ..",
				[2] = "<AnimateStyle=Appear>ยังไงซะ ไม่ช้าก็เร็ว ระฆัง ก็ต้องถูกตีอีกในช่วง...",
				Yes = "ไม่เป็นไรหรอก",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Appreciated. If I do have time, I'll return you something..",
				[2] = "<AnimateStyle=Appear>Whatever, sooner or later, that bell's gonna need someone to ring it again.",
				Yes = "No need to",
				No = "..."
			}
		}
	},
	["Give me Fuel"] = {
		Name = "Sea's Coal Keeper",
		THName = "เงือกผู้เก็บถ่าน",
		QuestName = "Give me Fuel",
		QuestGiven = {
			Name = "Give me Fuel",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>มีแต่เรื่องจริงๆ ข้าไม่ได้พักซักวันเลย...",
			[2] = "<AnimateStyle=Appear><Color=/>โชคร้ายอะไรนะข้า...",
			Yes = "",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Every day, every problem...",
			[2] = "<AnimateStyle=Appear><Color=/>What a bad day for me...",
			Yes = "",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ว่ายังไงเจอบ้างหรือยัง?",
				[2] = "<AnimateStyle=Appear>ค่อยๆหานะ มนุษย์อย่างเจ้าอาจจะต้องเรียนรู้อะไรอีกเยอะ ณ ใต้โลกา แห่งนี้",
				Yes = "ยังเลย..",
				No = "!"
			},
			US = {
				[1] = "<AnimateStyle=Appear>How's it going? Found it yet?",
				[2] = "<AnimateStyle=Appear>Take it easy, there's a lot to learn for a human like you at this depth.",
				Yes = "No..",
				No = ""
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>มนุษย์!? กล้าดีอย่างไรถึงอยู่ที่แห่งนี้ได้...ช่างเถอะ เจ้าพอจะช่วยข้าหน่อยได้ไหม?",
				[2] = "<AnimateStyle=Appear>พอดีงานข้าล้นมือมากๆ อีกอย่างเชื้อเพลิงก็ใกล้จะหมด หา <Color=Yellow> เชื้อเพลิง <Color=/> ให้ข้าที",
				Yes = "ช่วย?",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear>Landwalker!? How dare you live in this place... forget that. Are you available for help?",
				[2] = "<AnimateStyle=Appear>My works are overloaded, and besides, the fuel almost ran out. Look for <Color=Yellow> fuel <Color=/> for me, will you?",
				Yes = "Help?",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ขอบคุณเจ้ามากมนุษย์! ไม่คิดว่าเจ้าจะมีชีวิตรอด เอ้ย หมายถึงทำได้หน่ะ!",
				[2] = "<AnimateStyle=Appear>ยังไงซะถ้าอยากจะช่วยข้าใหม่ ลองกลับมาประมาณ...",
				Yes = "ถือว่าชมละกัน",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Thank you, human! Never thought that you're alive, I mean, doing this!",
				[2] = "<AnimateStyle=Appear>Also, if you want to help me again, just come back at...",
				Yes = "Alright",
				No = "..."
			}
		}
	},
	["The Sea's Files"] = {
		Name = "Sea Detective",
		THName = "นักสืบใต้โลกา",
		QuestName = "The Sea's Files",
		QuestGiven = {
			Name = "The Sea's Files",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>หนึ่ง...สอง...สาม... ปริศนาขึ้นบก?",
			[2] = "<AnimateStyle=Appear><Color=/>หืม...",
			Yes = "",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>One... two... three... Puzzle, maybe?",
			[2] = "<AnimateStyle=Appear><Color=/>Hm..",
			Yes = "",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>โอ้..เจ้ามนุษย์นั่นเอง! เป็นยังไงหาเจอมั้ย?",
				[2] = "<AnimateStyle=Appear>ไม่เป็นไร ทักษะของมนุษย์ทำอะไรไม่ได้มาก ณ ที่แห่งนี้ อาจจะใช้เวลานิดนึง..",
				Yes = "ไม่เจอเลย",
				No = "ขอไปหาอีกรอบ.."
			},
			US = {
				[1] = "<AnimateStyle=Appear>Oh, human! Found anything yet?",
				[2] = "<AnimateStyle=Appear>That's okay. Human abilities are not capable of doing this. It might take some time.",
				Yes = "No",
				No = "I'll try again.."
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>มนุษย์ตัวเป็นๆอย่างงั้นหรอกรึ! น่าอัศจรรย์ยิ่งนัก ว่าแต่เจ้าพอจะเห็น <Color=Yellow> เอกสาร <Color=/> ข้าไหม?",
				[2] = "<AnimateStyle=Appear>ใช่ เอกสาร จะว่าอย่างไงดีหล่ะ ถ้าเจอหามันเจอ ข้ามีรางวัลให้กับเจ้า",
				Yes = "เอกสาร?",
				No = "ไม่อะ"
			},
			US = {
				[1] = "<AnimateStyle=Appear>Such amazing! A Landwalker! Also, have you seen my <Color=Yellow> Document <Color=/> ?",
				[2] = "<AnimateStyle=Appear>Yes, the document. What can I say? If you found it, I'll reward you.",
				Yes = "Document?",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ขอบคุณเจ้ามากๆ ที่จริงมันไม่ได้มีแค่ชิ้นเดียว มันมีมากกว่านั้น..",
				[2] = "<AnimateStyle=Appear>ใช่! ปริศนา และหลายสิ่งอีกมากมายรอให้เจ้าได้ค้นพบ ไว้เจอกันอีกทีประมาณ...",
				Yes = "มากกว่า?!",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Thank you! Obviously, that wasn't the only one. There are more of them...",
				[2] = "<AnimateStyle=Appear>Yes! There's a lot of puzzles that need to be solved and await you. Well, I'll see you around.",
				Yes = "More!?",
				No = "..."
			}
		}
	},
	["Kraken Codex Medium"] = {
		Name = "Sea's Codex",
		THName = "รหัสลับใต้โลกา",
		QuestName = "Krakenci Codes (Medium)",
		QuestGiven = {
			Name = "Krakenci Codes (Medium)",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>...เจ้าจักเป็นคนที่แก้ไขปริศนาเหล่านี้ได้หรือไม่...",
			[2] = "<AnimateStyle=Appear>แก้ปริศนาไหม?",
			Yes = "ปริศนา?",
			No = "ไม่สนใจ..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Will you solve this puzzle or not?...",
			[2] = "<AnimateStyle=Appear>Wanna solve the Puzzle?",
			Yes = "Puzzle?!",
			No = "Whatever..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>...แก้ปริศนาให้จงได้...",
				[2] = "<AnimateStyle=Appear>อย่าได้หา หรือ หวังคำตอบจากข้าเลย..",
				Yes = "ใบ้ข้าที",
				No = "ไม่เข้าใจ"
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>...Solve the Puzzle...",
				[2] = "<AnimateStyle=Appear>Don't seek the answer from here...",
				Yes = "Hint,Please",
				No = "Don't get it."
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>ปริศนาที่จะท้าทายสติปัญญาของเจ้า.. <Color=Yellow> (ระดับปานกลาง)",
				[2] = "<AnimateStyle=Appear>จงตามหาผู้คุมอสูร เจ้าจักได้เครื่องมือถอดรหัส...",
				Yes = "ปริศนา?",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear>The puzzle that would challenge your mind... <Color=Yellow> (Medium)",
				[2] = "<AnimateStyle=Appear>Find the Kraken's Guard, you will find the Codex's Kit.",
				Yes = "Puzzle?",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>เจ้าเหมาะสมที่จะพบกับนายท่าน...เพียงแค่รอเวลาเท่านั้น ",
				[2] = "<AnimateStyle=Appear>แล้วพบกันใหม่...",
				Yes = "นายท่าน?",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>You are prepared to meet the Master, just wait for the proper time.",
				[2] = "<AnimateStyle=Appear>We shall meet again...",
				Yes = "Alright",
				No = "..."
			}
		}
	},
	["The Pillar"] = {
		Name = "Pillar Seeker",
		THName = "ผู้แสวงหา",
		QuestName = "The Pillar",
		QuestGiven = {
			Name = "The Pillar",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ได้โปรดแสงสว่างนำทางข้าด้วยเถิด...",
			[2] = "<AnimateStyle=Appear><Color=/>...อย่าเข้ามาใกล้นะ..",
			Yes = "",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>The Light bless me, and grant me the path...",
			[2] = "<AnimateStyle=Appear><Color=/> Don't come any closer!",
			Yes = "",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>...(หวาดกลัว)...",
				[2] = "<AnimateStyle=Appear>..เจ้าจะช่วยข้า...อย่างงั้นหรือ?",
				Yes = "?",
				No = "!"
			},
			US = {
				[1] = "<AnimateStyle=Appear>...(Fear)..",
				[2] = "<AnimateStyle=Appear>...will you....Help me?",
				Yes = "?",
				No = ""
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>เจ้า! อย่าเข้ามาใกล้นะ! อย่ามายุ่งกับข้า!",
				[2] = "<AnimateStyle=Appear>ไม่! ถอยไป เจ้ามันพวกเดินดิน! แสงสว่างช่วยข้าด้วย!",
				Yes = "ใจเย็น!",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear>You! Don't come any closer! Leave me alone!",
				[2] = "<AnimateStyle=Appear>No! Step back! You're a Landwalker! Light, grant me aid!",
				Yes = "Calm down!",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>...แสงสว่างนำพาให้เจ้าได้ล่วงรู้ถึง <Color=Green> เสา แห่งสัจธรรม <Color=/> เช่นนั้นหรือ?",
				[2] = "<AnimateStyle=Appear>กลัว? เจ้าคือใครหรอ? ข้าอยู่ที่ไหน? แสงสว่างนำทางให้ข้าแล้ว!",
				Yes = "ไม่กลัวข้าแล้วหรือ?",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>...The Light grants you knowledge to make you realize the truth about the <Color=Green/ Pillar <Color=/>, isn't it? ?",
				[2] = "<AnimateStyle=Appear>Scare? Who are you? Where am I? Light, show me the way!",
				Yes = "Ain't Scare me?",
				No = "..."
			}
		}
	},
	["Mossy Must Gone"] = {
		Name = "Sea's Cleaner",
		THName = "เงือกผู้รักสะอาด",
		QuestName = "Mossy Must Gone",
		QuestGiven = {
			Name = "Mossy Must Gone",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>มนุษย์!? ไม่อยากจะเชื่อสายตาตนเอง..",
			[2] = "<AnimateStyle=Appear>ว่ายังไง?",
			Yes = "",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Human!? I can't believe my own eyes...",
			[2] = "<AnimateStyle=Appear>What's up?",
			Yes = "",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ไหนหล่ะ! ข้ายังไม่เห็นว่ามันสะอาดเลย!",
				[2] = "<AnimateStyle=Appear>เจ้ามองไม่เห็นอย่างนั้นหรือ? ลองตามหา <Color=Yellow> สาหร่าย <Color=/> เดี๋ยวก็เจอเองแหละ",
				Yes = "ตะไคร่น้ำ?",
				No = "!"
			},
			US = {
				[1] = "<AnimateStyle=Appear>Where!? I didn't see it clean",
				[2] = "<AnimateStyle=Appear>You cannot see them? Try around <Color=Yellow> Kelp <Color=/> you will find it.",
				Yes = "Moss?",
				No = ""
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear> เจ้าขัดใจเหมือนกับข้าไหม? ข้าหล่ะไม่ชอบจริงๆ ที่เวลาเห็นอะไรสกปรก...",
				[2] = "<AnimateStyle=Appear>ว่าแล้ว! มนุษย์ต้องรักสะอาดจริงๆ เจ้าช่วยทำความสะอาดพวก <Color=Green> ตะไคร่น้ำ <Color=/> ทีนะ",
				Yes = "อ่า...ใช่",
				No = "ไม่ขัด"
			},
			US = {
				[1] = "<AnimateStyle=Appear>Are you annoying? I don't really like it when I see things dirty.",
				[2] = "<AnimateStyle=Appear>Thought so! Humans do love things clean. Will you get rid of those <Color=Green> mossy <Color=/> things?",
				Yes = "Uh..Yes",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>สวยงามตามท้องเรื่อง! สมกับเป็นมนุษย์จริงๆ!",
				[2] = "<AnimateStyle=Appear>ยังไงซะไม่ช้าก็เร็วพวกตะไคร่น้ำก็จะปรากฏมาอีก...",
				Yes = "ธรรมดา~",
				No = "ก็ชมเกิ๊น"
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Wonderful! Such a marvelous human!",
				[2] = "<AnimateStyle=Appear>Sooner or later, those mossy things are gonna grow back again.",
				Yes = "Absolutely I am!",
				No = "What a Compliment"
			}
		}
	},
	["Into the Bubble-Verse"] = {
		Name = "Sea's Wanderer",
		THName = "นักผจญภัยมหาสมุทร",
		QuestName = "Into the Bubble-Verse",
		QuestGiven = {
			Name = "Into the Bubble-Verse",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>เอะ เอ เอ้ เอ~ (พึมพำ)...",
			[2] = "<AnimateStyle=Appear>ว่าไงมนุษย์?",
			Yes = "",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/> Ayy,Ayy,Ayy,Ayy~ (Singing)",
			[2] = "<AnimateStyle=Appear>What's up Human?",
			Yes = "",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ไหนหล่ะ? ความสามารถของเจ้าหน่ะ...",
				[2] = "<AnimateStyle=Appear>อะไรก็ได้...ต่อกรปีศาจ สัตว์ประหลาด อะไรก็ได้..",
				Yes = "สามารถแบบไหน?",
				No = "ข้าตื่นเต้น.."
			},
			US = {
				[1] = "<AnimateStyle=Appear>Where? Where is your talent...",
				[2] = "<AnimateStyle=Appear>Whatever...abilities or talent to defeat those monsters, any kind.",
				Yes = "Talent?",
				No = "I'm nervous.."
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>มนุษย์! เรื่องเล่าจากท่านอาเป็นเรื่องจริงสินะ!",
				[2] = "<AnimateStyle=Appear>ไหนพอจะโชว์ความสามารถอะไรให้ข้าดูหน่อยได้มั้ย?!",
				Yes = "จริงสิ",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear>Human! All the stories from my uncle are true!",
				[2] = "<AnimateStyle=Appear>Can you show your fascinating talent?",
				Yes = "What!",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>สุดยอดไปเลย! ข้าอยากจะมีพลังเฉกเช่นแบบเจ้าบ้างจัง..",
				[2] = "<AnimateStyle=Appear>หวังว่าเจ้าคงไม่กัด แล้วทำให้ข้ามีพลังใช่มั้ย? ฮาๆ (ขำ)...",
				Yes = "พยายามเข้าหล่ะ!",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>A-Amazing! I'd like to have abilities like you someday...",
				[2] = "<AnimateStyle=Appear>Hope you ain't bite and give me a power right? (Laugh)",
				Yes = "Alright",
				No = "..."
			}
		}
	},
	["Kraken Codex Hard"] = {
		Name = "Sea's Codex",
		THName = "รหัสลับใต้โลกา",
		QuestName = "Krakenci Codes (Hard)",
		QuestGiven = {
			Name = "Krakenci Codes (Hard)",
			LvRequired = 4000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>...เจ้าจักเป็นคนที่แก้ไขปริศนาเหล่านี้ได้หรือไม่...",
			[2] = "<AnimateStyle=Appear>แก้ปริศนาไหม?",
			Yes = "ปริศนา?",
			No = "ไม่สนใจ..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Will you solve this puzzle or not?...",
			[2] = "<AnimateStyle=Appear>Wanna solve the Puzzle?",
			Yes = "Puzzle?!",
			No = "Whatever..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>...แก้ปริศนาให้จงได้...",
				[2] = "<AnimateStyle=Appear>อย่าได้หา หรือ หวังคำตอบจากข้าเลย..",
				Yes = "ใบ้ข้าที",
				No = "ไม่เข้าใจ"
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>...Solve the Puzzle...",
				[2] = "<AnimateStyle=Appear>Don't seek the answer from here...",
				Yes = "Hint,Please",
				No = "Don't get it."
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear>ปริศนาที่จะท้าทายสติปัญญาของเจ้า.. <Color=Red> (ระดับยาก)",
				[2] = "<AnimateStyle=Appear>จงตามหาผู้คุมอสูร เจ้าจักได้เครื่องมือถอดรหัส...",
				Yes = "ปริศนา?",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear>The puzzle that would challenge your mind... <Color=Red> (Hard)",
				[2] = "<AnimateStyle=Appear>Find the Kraken's Guard, you will find the Codex's Kit.",
				Yes = "Puzzle?",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>เจ้าเหมาะสมที่จะพบกับนายท่าน...เพียงแค่รอเวลาเท่านั้น ",
				[2] = "<AnimateStyle=Appear>แล้วพบกันใหม่...",
				Yes = "นายท่าน?",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>You are prepared to meet the Master, just wait for the proper time.",
				[2] = "<AnimateStyle=Appear>We shall meet again...",
				Yes = "Alright",
				No = "..."
			}
		}
	},
	["Kraken Codex Giver"] = {
		Name = "Kraken's Guard",
		THName = "ผู้คุมอสูรใต้ทะเล",
		Gui = {
			Quest = "Krakenci Codes",
			GuiName = "PuzzleLibs"
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ดูเหมือนเจ้ากำลังหลงทางเช่นนั้นรือ?",
			[2] = "<AnimateStyle=Appear>ข้าไม่สามารถบอกเจ้าได้หรอก...เจ้าไม่ได้แบกรับภารกิจอันทรงเกียรติไว้",
			Yes = "ใช่?",
			No = "เหอะๆ",
			Special = {
				[1] = "<AnimateStyle=Appear><Color=/>เจ้า! เจ้ากำลังตามหาสิ่งนี้อยู่สินะ!",
				[2] = "ใช่แล้ว..เอานี้ไปซะ ภารกิจอันทรงเกียรติ!",
				Yes = "ตามหา?",
				No = "ไม่"
			}
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/> Are you lost or somethin'?",
			[2] = "<AnimateStyle=Appear>I wish I could help you, but you don't bear the <Color=Red>honor task <Color=/> within you..",
			Yes = "Yes?!",
			No = "Whatever...",
			Special = {
				[1] = "<AnimateStyle=Appear><Color=/>You! Looking something right? Aren't you",
				[2] = "Yes, here take this for the honor task!",
				Yes = "Looking?!",
				No = "Whatever..."
			}
		}
	},
	["Coral One"] = {
		Name = "Strange Coral",
		THName = "ปะการังประหลาด",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>...ข้าจักกระซิบให้เจ้าในสิ่งที่เจ้าตามหา...",
			[2] = "<AnimateStyle=Appear><Color=/>ล่วงลับ..ทมิฬ...วีรบุรุษ",
			Yes = "ตามหา?",
			No = "ข้าไม่เข้าใจ"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>...The undersea whisper thing you seek...",
			[2] = "<AnimateStyle=Appear><Color=/>Fallen...Dark...Heroic...!",
			Yes = "Seek?",
			No = "I don't understand"
		}
	},
	["Coral Two"] = {
		Name = "Strange Coral",
		THName = "ปะการังประหลาด",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>...ข้าจักกระซิบให้เจ้าได้รับรู้..!",
			[2] = "<AnimateStyle=Appear><Color=/>...กู้...สว่าง..",
			Yes = "ข้าจะเข้าใจไหม?",
			No = "ไม่เห็นเข้าใจเลย"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>...The undersea whisper thing you seek...!",
			[2] = "<AnimateStyle=Appear><Color=/>...Vior..Ight...",
			Yes = "How!?",
			No = "I don't understand"
		}
	},
	["Coral Three"] = {
		Name = "Strange Coral",
		THName = "ปะการังประหลาด",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>...เมื่อเผชิญหน้ากับสิ่งมืดมิด...",
			[2] = "<AnimateStyle=Appear><Color=/>สิ่งใดกันเล่าที่เชิดชายยามค่ำคืนคอยหวาดกลัวเจ้าอยู่ร่ำไป?",
			Yes = "!?!",
			No = "!!"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>...When facing the darkness...",
			[2] = "<AnimateStyle=Appear><Color=/>...What natural companion might illuminate the night and soothe your fears?",
			Yes = "!?!",
			No = "!!"
		}
	},
	["Myth of Kraken"] = {
		Name = "Sea Citizen",
		THName = "ชาวบาดาล",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>หยุดนะ! เจ้าหน่ะ! อย่าคิดริอาจย่างกรายไปในพื้นที่แห่งนั้นเชียวนะ! ",
			[2] = "<AnimateStyle=Appear><Color=/>ใช่..เพียงแค่การปรากฏตัวของเจ้าก็นำภัยพิบัติมาให้ใต้โลกาแล้ว!",
			Yes = "พื้นที่?",
			No = "ไม่สน"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Halt! You there! Don't ever think to step foot on that sacred place!",
			[2] = "<AnimateStyle=Appear><Color=/>Yes...just your presence alone is enough to call chaos upon this realm!",
			Yes = "Place?",
			No = "Don't care"
		}
	},
	["Old God"] = {
		Name = "Draken The Obsession",
		THName = "ดราเคน ผู้หมกมุ่น",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>นายท่านของข้า...ได้โปรดมอบกายาที่สมบูรณ์ บูรณะใต้โลกา กำจัดพวกมันทั้งปวง..",
			[2] = "<AnimateStyle=Appear><Color=/>...ไม่ช้าก็เร็ว",
			Yes = "นายท่าน?",
			No = "???"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>My lord... please, command me to find a perfect way to reconstruct this realm and eliminate them all...",
			[2] = "<AnimateStyle=Appear><Color=/>...not soon, Even the Kraken will yield and obey my lord's command.",
			Yes = "Lord?!",
			No = "???"
		}
	},
	["Forsaken Beast"] = {
		Name = "Mysterious Shell",
		THName = "เปลือกหอยปริศนา",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>อันตรธานไปตามกาลเวลา~ เหลือไว้เพียงแค่ความทรมาน...",
			[2] = "<AnimateStyle=Appear><Color=/>มนุษย์มาใต้โลกาได้เยี่ยงไร? เจ้าได้ยินเสียงข้าด้วยงั้นรึ?",
			Yes = "หอยพูดได้?",
			No = ""
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Vanished through time~ only torment has been held within...",
			[2] = "<AnimateStyle=Appear><Color=/>How have humans proceeded to this depth? Can you hear my voice?",
			Yes = "Talking Shell?",
			No = "...."
		}
	},
	["Lost Trident"] = {
		Name = "Forasken Trident",
		THName = "ตรีศูลที่ถูกลืม",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>(อาวุธลึกลับชิ้นนี้ถูกทิ้งไว้ยาวนาน เหมือนรอคอยผู้ที่ถูกเลือกเท่านั้น)",
			[2] = "<AnimateStyle=Appear><Color=/>('ผู้พิชิตเท่านั้น ถึงจะครอบครองทั้งอาณาจักรได้', ข้อความที่สลักไว้ข้างอาวุธ)",
			Yes = "...",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>(The Mysterious Forsaken Trident, which has been gone for so long, awaits the chosen one.)",
			[2] = "<AnimateStyle=Appear><Color=/>('Only the Chosen one who shall conquer all the realms'),the message carved along its trident.",
			Yes = "!?!",
			No = "...."
		}
	},
	["Sea Eater"] = {
		Name = "Sea Eater",
		THName = "จอมเขมือบ",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>มนุษย์โง่เขลา กล้าดีอย่างไรมาย่างกรายดินแดนแห่งนี้!?",
			[2] = "<AnimateStyle=Appear><Color=/>ข้าสัมผัสได้เจ้าพูดความจริง โชคดียิ่งนักที่ข้าอยู่ในช่วงจำศีล...",
			Yes = "ข้าไม่ได้ตั้งใจ...",
			No = "อภัยให้ข้าด้วย"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Foolish human, how dare you step into this realm?!",
			[2] = "<AnimateStyle=Appear><Color=/>I'm sensing that you spoke the truth. Luckily, I'm in <Color=Red> hibernation <Color=/> mode...",
			Yes = "I didn't mean to...",
			No = "Forgive me..."
		}
	},
	Underworld = {
		Name = "Sea Monster",
		THName = "ปีศาจท้องทะเล",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>เจ้าจงระวัง..ทุกๆการเคลื่อนไหวของเจ้า อาจจะนำหายนะมาสู่เจ้าก็เป็นได้..",
			[2] = "<AnimateStyle=Appear><Color=/>ไม่ใช่แค่อสูรหลายขาที่น่ากลัว แต่มีสิ่งอื่นอีกที่มนุษย์อย่างเจ้าควรหวั่นเกรง",
			Yes = "เคลื่อนไหว?",
			No = "ไม่สนใจหรอก..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Watch your step... every <Color=Yellow> movement <Color=/> of yours shall lead to destruction within you..",
			[2] = "<AnimateStyle=Appear><Color=/>Not only that mythical colossal tentacle, but there's something a human like you should obey!",
			Yes = "Movement?",
			No = "I don't care.."
		}
	},
	["Sea Sick!"] = {
		Name = "Sea Challenger",
		THName = "ผู้ท้าทายแห่งท้องทะเล",
		QuestName = "I'm not,YOU ARE!",
		QuestGiven = {
			Name = "I'm not,YOU ARE!",
			LvRequired = 3000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ฉันเดาเลยว่า..น่าไม่สามารถต้านทานมนต์ของฉันได้!",
			[2] = "<AnimateStyle=Appear>หวังว่าแกพร้อมนะ..หึหึ",
			Yes = "จัดมา..",
			No = "ก็จริง..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>I'm guessing...that you won't able to resist my Magic!",
			[2] = "<AnimateStyle=Appear><Color=/>Hope you're ready...Huh Huh",
			Yes = "Bring it!",
			No = "True..."
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ไม่ไหวๆ กระจอกแต่บอกเก่ง...",
				[2] = "<AnimateStyle=Appear><Color=/>เร็วๆ!",
				Yes = "@#@#!",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Such a shame... you're not that great after all!",
				[2] = "<AnimateStyle=Appear><Color=/>Quickly!",
				Yes = "@#@#!",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ก็ไม่แย่ซักเท่าไหร่สำหรับนักผจญภัย...",
				[2] = "<AnimateStyle=Appear><Color=/>ไว้กลับมาอีกรอบก็แล้วกันนะ! อีก",
				Yes = "รับทราบ",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Not bad for an adventurer...",
				[2] = "<AnimateStyle=Appear><Color=/>Comeback! around...",
				Yes = "Got it",
				No = ""
			}
		}
	},
	["Bone Hunter"] = {
		Name = "Lost Prayer",
		THName = "ผู้เสื่อมศรัทธา",
		QuestName = "Bone Hunter",
		QuestGiven = {
			Name = "Bone Hunter",
			LvRequired = 3000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>หากระดูก! กระดูกฉัน! กระดูกของฉัน!",
			[2] = "<AnimateStyle=Appear>ถ้าหามันครบ มาเรียงกัน ข้าจักอัญเชิญนายท่านของข้า..",
			Yes = "ใจเย็นๆ",
			No = "บ้าแน่ๆ"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Bone! Bone! My <Color=Red> PRECIOUS BONE!",
			[2] = "<AnimateStyle=Appear><Color=/>Once gather them all, I will summon my lord!",
			Yes = "Take it easy",
			No = "Crazy"
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ไหนหล่ะ! ไหน!",
				[2] = "<AnimateStyle=Appear><Color=/>!@@#@#!@!",
				Yes = "@#@#!",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>WHERE! WHEREl!",
				[2] = "<AnimateStyle=Appear><Color=/>!@@#@#!@!",
				Yes = "@#@#!",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>เอาหล่ะ...นายท่านของข้า!",
				[2] = "<AnimateStyle=Appear><Color=/>นายท่าน! ข้าต้องรองั้นหรอกหรือ ท่านจึงจะปรากฏ...",
				Yes = "...",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Well...<Color=Red>MY LORD!",
				[2] = "<AnimateStyle=Appear><Color=/>My lord, do I have to wait for your arrival...",
				Yes = "...",
				No = "..."
			}
		}
	},
	["Sea Diving"] = {
		Name = "Sea Diver",
		THName = "ผู้ดิ่งแห่งท้องทะเล",
		QuestName = "Under The Sea~",
		QuestGiven = {
			Name = "Under The Sea~",
			LvRequired = 3000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ชอบดำน้ำไหม? แต่ไม่ได้ก็ไม่เป็นไรนะ...",
			[2] = "<AnimateStyle=Appear>งั้นหรอกเหรอ! ข้าคิดว่าจะไม่มีนักผจญภัยคนไหนดำแล้วซะอีก หากไม่มีสมบัติ",
			Yes = "ได้สิ",
			No = "ไม่มีทาง"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Care for a dive? It's okay if you're not up for it.",
			[2] = "<AnimateStyle=Appear><Color=/>Alright! I thought there weren't any adventurers diving into the sea, at least not for treasure.",
			Yes = "Of course!",
			No = "No way!"
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>อย่าปล่อยให้ข้ารอนาน...",
				[2] = "<AnimateStyle=Appear><Color=/>พิสูจน์ให้ข้าเห็นว่าการดำน้ำนั้นมีค่ามากแค่ไหน!",
				Yes = "เข้าใจแล้ว..",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Don't keep me waiting...",
				[2] = "<AnimateStyle=Appear><Color=/>Make me proud that diving is more valuable than ever!",
				Yes = "Got you!",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>เยี่ยมมาก เห็นมั้ยหล่ะว่าสนุกแค่ไหน?",
				[2] = "<AnimateStyle=Appear><Color=/>ไว้อยากลงไปดำน้ำเล่นอีกก็ค่อยกลับมาอีกที",
				Yes = "ขอบคุณ",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Well done! See how fun it was?",
				[2] = "<AnimateStyle=Appear><Color=/>If you want to dive into the sea again, come back another time.",
				Yes = "Thank you",
				No = "..."
			}
		}
	},
	["Sea Madness"] = {
		Name = "Bounty Collector",
		THName = "นักล่าค่าหัว",
		QuestName = "Catch me,If you can",
		QuestGiven = {
			Name = "Catch me,If you can",
			LvRequired = 3000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ข้ากำลังตามหาของมีค่า...เจ้าอย่ายุ่งเลยดีกว่า",
			[2] = "<AnimateStyle=Appear>งั้นรึ? คนอย่างเจ้าหน่ะ เอาแต่สู้ไปวันๆ หาไม่เจอหรอก...",
			Yes = "ฉันช่วยได้นะ",
			No = "โชคดี"
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>I'm looking for my precious treasure... leave me alone.",
			[2] = "<AnimateStyle=Appear><Color=/>Really?! An adventurer like you, who only fought battles, won't be able to find it.",
			Yes = "I can help",
			No = "Good luck!"
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>เหอะๆ ยังหาไม่เจอใช่มั้ยหล่ะ?",
				[2] = "<AnimateStyle=Appear><Color=/>ไม่ต้องรีบๆ ถ้าข้าเจอ มันก็เป็นของข้าอยู่แล้ว...",
				Yes = "ฝันไปเถอะ!",
				No = "ไม่มีทาง"
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Huh... still searching for it, huh?",
				[2] = "<AnimateStyle=Appear><Color=/>Take your time. No matter what, if I find it, it belongs to me anyway.",
				Yes = "You wish!",
				No = "No way!"
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ไม่เลวนี่ สำหรับนักผจญภัย คิดว่าจะสู้เป็นอย่างเดียวซะอีก...",
				[2] = "<AnimateStyle=Appear><Color=/>จริงๆแล้วก็มีสมบัติหลายแห่งนะ...ขอให้โชคดี",
				Yes = "...",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Not bad for an adventurer like you, though I thought you only knew how to wield a weapon.",
				[2] = "<AnimateStyle=Appear><Color=/>Obviously there are still a lot of treasture..Farewell!",
				Yes = "...",
				No = "..."
			}
		}
	},
	["Sea Creature"] = {
		Name = "Storm Chaser",
		THName = "นักล่ามรสุม",
		QuestName = "Left to Dead",
		QuestGiven = {
			Name = "Left to Dead",
			LvRequired = 3000
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>ข้าทนไม่ไหวที่เจ้าพวกตายซากที่มันกลับมามีชีวิต..",
			[2] = "<AnimateStyle=Appear>จัดการพวกมันเพื่อให้ดินแดนนี้สงบสุขอีกครั้งเถอะ...",
			Yes = "เดี๋ยวจัดการให้",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>I can't take it anymore, seeing those living dead come back from the grave.",
			[2] = "<AnimateStyle=Appear><Color=/>Defeat them for the sake of this legacy once and for all...",
			Yes = "Let me handle this!",
			No = "..."
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ไหนหล่ะ! ฉันยังสัมผัสได้ว่าพวกมันยังเพ่นพ่านอยู่เลย!",
				[2] = "<AnimateStyle=Appear><Color=/>ไหนว่าเป็นนักผจญภัย ก็ทำหน้าที่ของเจ้าให้ดีซะสิ!",
				Yes = "@#@#!",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>What! I still sense them, still wandering around!",
				[2] = "<AnimateStyle=Appear><Color=/>What kind of adventurer are you!? Do your Job!",
				Yes = "@#@#!",
				No = "..."
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>อย่างงี้สิที่เรียกว่า สงบสุข.. ",
				[2] = "<AnimateStyle=Appear><Color=/>ไว้เราเจอกันใหม่อีกครั้ง",
				Yes = "ตรงไหนฟะ?",
				No = "..."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>This is what we call 'Peace' ",
				[2] = "<AnimateStyle=Appear><Color=/>We'll meet again!",
				Yes = "Seriously?",
				No = "..."
			}
		}
	},
	Venturer = {
		Name = "Sea Explorer",
		THName = "นักผจญเนิ่นน้ำทะเล",
		QuestName = "Venture Lagoons!",
		QuestGiven = {
			Name = "Venture Lagoons!",
			LvRequired = 10
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/>เจ้าคิดว่าไหวสำหรับการผจญภัยมั้ย? หืม?",
			[2] = "<AnimateStyle=Appear>ว่าไงหล่ะ..",
			Yes = "คงงั้น..",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Do you think you're capable of journey? Hmm?",
			[2] = "<AnimateStyle=Appear><Color=/>What's up?",
			Yes = "Maybe..",
			No = "..."
		},
		OnQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ไหนหล่ะ! เจ้ายังไปไม่ถึงไหนเลย!",
				[2] = "<AnimateStyle=Appear><Color=/>ให้ไวเลย!",
				Yes = "โอเคๆ",
				No = "อ่า..รู้สึกเมา.."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>What are you waiting for? What's up!?",
				[2] = "<AnimateStyle=Appear><Color=/>Be quick!",
				Yes = "Got it",
				No = "I don't feel good"
			}
		},
		Quest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>ได้งั้นก็พิสูจน์ซะสิ!",
				[2] = "<AnimateStyle=Appear><Color=/>พยายามใช้ เรือ ขับไปตามสถานที่ต่างๆ เข้าใจมั้ย?!",
				Yes = "โอเคๆ",
				No = "อ่า..รู้สึกเมา.."
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Fine! Prove it!",
				[2] = "<AnimateStyle=Appear><Color=/>Try sailing the ship around the important area, got it?",
				Yes = "Got it",
				No = "I don't feel good"
			}
		},
		CompletedQuest = {
			TH = {
				[1] = "<AnimateStyle=Appear><Color=/>เก่งมากๆ คิดว่าเจ้าจะล้มเลิกไปซะแล้ว...",
				[2] = "<AnimateStyle=Appear><Color=/>เอาหล่ะ..แล้วเจอกันใหม่เวลา ",
				Yes = "ได้เลย",
				No = "ธรรมดา"
			},
			US = {
				[1] = "<AnimateStyle=Appear><Color=/>Pretty good! I thought you had given up already...",
				[2] = "<AnimateStyle=Appear><Color=/>Well...see you again around",
				Yes = "!",
				No = ""
			}
		}
	},
	["Tomb Talker_test"] = {
		Name = "Scared Pirate",
		THName = "โจรสลัดเสียขวัญ",
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/> อย่านะ..ข้าไม่กลับเข้าไปข้างในอีกแน่ๆ",
			[2] = "<AnimateStyle=wiggly>...ข้ากลัวแล้วอย่าเลย..พอแล้ว",
			Yes = "ไม่เป็นไรนะ..",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>NO! I won't go back to that place again",
			[2] = "<AnimateStyle=wiggly><Color=/>...Please I'm too terify..enough it already",
			Yes = "Yes..",
			No = "..."
		}
	},
	["Tomb Event"] = {
		Name = "Tomb Invader",
		THName = "ผู้ทะลวงโลง",
		Multi = "Quest",
		BulkQuest = {
			{
				QuestName = "Pumpkin Smasher",
				QuestGiven = {
					Name = "Pumpkin Smasher",
					LvRequired = 10
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/>เจ้าคงอยากจะทำลายพวกฟักทองนั่นสินะ?!",
					[2] = "<AnimateStyle=Appear>ดีงั้นมาทำลายมันให้หมด..แถวป้าย หรือ หลุมศพ นี่แหละ",
					Yes = "แน่นอน",
					No = "ไม่อะ"
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>So you wish to destroy these <Color=Red> x6 Pumpkins<Color=/>?",
					[2] = "<AnimateStyle=Appear><Color=/>Alright, let's smash all of them around the grave or coffin!",
					Yes = "Alright",
					No = "No!"
				},
				Quest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/> ไหนหล่ะ? ไหนบอกว่าอยากจะทำลายมัน?",
						[2] = "<AnimateStyle=Appear><Color=/> ก็บอกแล้วไงว่าพวกมันอยู่แถวนี้ บนเกาะ <Color=Green> ฮาโลวีน <Color=/> เนี้ยแหละ!",
						Yes = "ไหนหล่ะ?",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>What? You wish to search and destroy these Pumpkins, why stop it now?",
						[2] = "<AnimateStyle=Appear><Color=/>I've told you that these are scattered around <Color=Green>Halloween Island.<Color=/>",
						Yes = "Where?",
						No = "..."
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/> ทำได้เยี่ยมมากๆ อันที่จริงแล้วน้อยคนมักจะรู้...",
						[2] = "<AnimateStyle=Appear><Color=/>หัว กับ อาวุธ หน่ะ สำคัญมากๆเลยหล่ะ...แล้วพบกันใหม่",
						Yes = "??",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>Excellent! In fact, some people might not know this...",
						[2] = "<AnimateStyle=Appear><Color=Yellow> Head <Color=/> and <Color=Yellow> Weapon <Color=/> are matters,We shall see again..",
						Yes = "??",
						No = "..."
					}
				}
			},
			{
				QuestName = "Tomb Raiding!",
				QuestGiven = {
					Name = "Tomb Raiding!",
					LvRequired = 50
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/>ข้าหล่ะเบื่อจริ๊งจริง, เจ้าพวกผีลืมหลุม...",
					[2] = "<AnimateStyle=Appear>โอ้ว,​ขอบคุณเจ้ามากๆ..ถ้าเป็นไปได้กำจัด <Color=Red> x1 Shadow Master <Color=/> ได้มั้ยหล่ะ? ",
					Yes = "ให้ช่วยมั้ย?",
					No = ""
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>I'm very upset with those Dead Walker!",
					[2] = "<AnimateStyle=Appear><Color=/>Sure, Could you defeat the <Color=Red> x1 Shadow Master ?",
					Yes = "Need Help?",
					No = "No!"
				},
				Quest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>ไหนหล่ะ มัวรออะไรอยู่!? ไปกำจัด...<Color=Red> Shadow Master <Color=/> สิ!",
						[2] = "<AnimateStyle=Appear><Color=/>ฟังนะ! มันอยู่ที่ <Color=Green> เกาะซอมบี้",
						Yes = "ก็ไม่รู้มันอยู่ไหนอะ",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>What are you waiting for!?! Defeat..",
						[2] = "<AnimateStyle=Appear><Color=/>Look! It's <Color=Green> 'Zombie Island' ",
						Yes = "Where!?",
						No = "..."
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>เจ้าจัดการพวกมันพอแล้วหล่ะ...ไม่คิดไม่ฝันจริงๆ",
						[2] = "<AnimateStyle=Appear><Color=/>ข้าคิดว่า นักผจญภัยอย่างเจ้า จะละทิ้งภารกิจเหล่านี้ซะแล้ว... ",
						Yes = "ธรรมดา..",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>You've defeated them enough... I don't think you could have done it...",
						[2] = "<AnimateStyle=Appear><Color=/>I thought an adventurer like you wouldn't take on a task like this...",
						Yes = "Absolutely",
						No = "..."
					}
				}
			},
			{
				QuestName = "Dead Walking",
				QuestGiven = {
					Name = "Dead Walking",
					LvRequired = 100
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/>หืม? แน่ใจแล้วเหรอที่อยากจะจัดการพวกตายซากหน่ะ..",
					[2] = "<AnimateStyle=Appear>เจ้าอยาก ข้าก็จัดให้..จำนวน 20 ตัวพวก ซอมบี้,ไปจัดการซะ!",
					Yes = "ใช่,จัดมา",
					No = ""
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>Hm? Are you sure you want to defeat those zombies?",
					[2] = "<AnimateStyle=Appear><Color=/>If you want to... so be it. Defeat x20 <Color=Red>Zombies!<Color=/> GO!",
					Yes = "Sure!",
					No = "No!"
				},
				Quest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>ไหนหล่ะ มัวรออะไรอยู่!?",
						[2] = "<AnimateStyle=Appear><Color=/>ฟังนะ! พวกตายซากมันอยู่ที่เกาะ <Color=Green> ซอมบี้",
						Yes = "ก็ไม่รู้มันอยู่ไหนอะ",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>What are you waiting for!?!",
						[2] = "<AnimateStyle=Appear><Color=/>Look! They are around the <Color=Green> 'Zombie Island' ",
						Yes = "Where are They!?",
						No = "..."
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>เจ้าจัดการพวกมันพอแล้วหล่ะ...ไม่คิดไม่ฝันจริงๆ",
						[2] = "<AnimateStyle=Appear><Color=/>ข้าคิดว่า นักผจญภัยอย่างเจ้า จะละทิ้งภารกิจเหล่านี้ซะแล้ว... ",
						Yes = "ธรรมดา..",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>You've defeated them enough... I don't think you could have done it...",
						[2] = "<AnimateStyle=Appear><Color=/>I thought an adventurer like you wouldn't take on a task like this...",
						Yes = "Absolutely",
						No = "..."
					}
				}
			}
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/> เจ้าไม่กลัวอย่างงั้นรึ!",
			[2] = "<AnimateStyle=Appear>แล้วไงต่อ?",
			Yes = "ข้าไม่กลัวหรอก..",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>You're not scared at all!?",
			[2] = "<AnimateStyle=Appear><Color=/>So?",
			Yes = "Yes..",
			No = "..."
		}
	},
	["Tomb Event Second"] = {
		Name = "Tomb Invader",
		THName = "ผู้ทะลวงโลง",
		Multi = "Quest",
		BulkQuest = {
			{
				QuestName = "Pumpkin Smasher Ep.2",
				QuestGiven = {
					Name = "Pumpkin Smasher Ep.2",
					LvRequired = 2000
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/>เจ้าคงอยากจะทำลายพวกฟักทองอีกนั่นสินะ?!",
					[2] = "<AnimateStyle=Appear>ดีงั้นมาทำลายมันให้หมด..แถวป้าย หรือ หลุมศพ นี่แหละ",
					Yes = "แน่นอน",
					No = "ไม่อะ"
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>So you wish to destroy those <Color=Red> x12 Pumpkins<Color=/> again,Right?",
					[2] = "<AnimateStyle=Appear><Color=/>Alright, let's smash all of them around the grave or coffin!",
					Yes = "Alright",
					No = "No!"
				},
				Quest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/> เร็วๆสิ ข้ารออยู่...บอกให้ครั้งนี้ข้าซ่อนไว้ดีมากๆเลย",
						[2] = "<AnimateStyle=Appear><Color=/> ก็บอกแล้วไงว่าพวกมันอยู่แถวนี้ บนเกาะ <Color=Green> ฮาโลวีน <Color=/> เนี้ยแหละ!",
						Yes = "ใบ้ที..",
						No = "จัดไป"
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>Quick! I'm waiting... I'm telling you, this time they're really good at finding hiding spots.",
						[2] = "<AnimateStyle=Appear><Color=/>I've told you that these are scattered around <Color=Green>Halloween Island.<Color=/>",
						Yes = "Hint,Please?",
						No = "..."
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/> ทำได้เยี่ยมมากๆ อันที่จริงแล้วน้อยคนมักจะรู้...",
						[2] = "<AnimateStyle=Appear><Color=/>ถ้าเจ้ามี <Color=Green> หัวฟักทอง <Color=/> และ <Color=Green> ค้อนฟักทอง <Color=/> ลองใช้มันโจมตีดูสิ..",
						Yes = "แล้วไงต่อ?",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>Excellent! In fact, some people might not know this...",
						[2] = "Listen, if you have <Color=Green>Pumpkin Head<Color=/> and <Color=Green>Pumpkin Smasher<Color=/>, try to use them regularly.",
						Yes = "So?",
						No = "..."
					}
				}
			},
			{
				QuestName = "Left For Dead?",
				QuestGiven = {
					Name = "Left For Dead?",
					LvRequired = 3500
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/>ข้าหล่ะเบื่อจริ๊งจริง, เจ้าพวกผีลืมหลุม...(อีกแล้ว)",
					[2] = "<AnimateStyle=Appear>โอ้ว,​ขอบคุณเจ้ามากๆ..ถ้าเป็นไปได้กำจัด <Color=Red> x6 Dead Troupe Captain <Color=/> ได้มั้ยหล่ะ? ",
					Yes = "อีกแล้วเหรอ?",
					No = "ไว้คราวหลังนะ.."
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>I'm very upset with those Dead Walker again this time!",
					[2] = "<AnimateStyle=Appear><Color=/>Yes, Could you defeat the <Color=Red> x6 Dead Troupe Captain ?",
					Yes = "Again?",
					No = "Later!"
				},
				Quest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>ไหนหล่ะ มัวรออะไรอยู่!? ไปกำจัด...<Color=Red>Dead Troupe Captain <Color=/> สิ!",
						[2] = "<AnimateStyle=Appear><Color=/>ฟังนะ! มันอยู่ที่..ที่ไหนฟะ..ข้าลืมขอโทษ..",
						Yes = "ก็ไม่รู้มันอยู่ไหนอะ",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>What are you waiting for!?! Defeat..",
						[2] = "<AnimateStyle=Appear><Color=/>Look! It's...It's...I forgot- Sorry ",
						Yes = "Where!?",
						No = "..."
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>เจ้าจัดการพวกมันพอแล้วหล่ะ...ไม่คิดไม่ฝันจริงๆ",
						[2] = "<AnimateStyle=Appear><Color=/>ข้าคิดว่า นักผจญภัยอย่างเจ้า จะละทิ้งภารกิจเหล่านี้ซะแล้ว... ",
						Yes = "ธรรมดา..",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>You've defeated them enough... I don't think you could have done it...",
						[2] = "<AnimateStyle=Appear><Color=/>I thought an adventurer like you wouldn't take on a task like this...",
						Yes = "Absolutely",
						No = "..."
					}
				}
			},
			{
				QuestName = "Is it Thriller?",
				QuestGiven = {
					Name = "Is it Thriller?",
					LvRequired = 3800
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/>มันก็ใกล้จะค่ำละ...บางทีอาจจะมีบางอย่างรอคอยจะจัดการเจ้าอยู่...",
					[2] = "<AnimateStyle=Appear>แหม! ให้มันได้อย่างงี้สิ กล้าหาญชาญชัย ไหนไปจัดการ <Color=Red> x12 Skull Pirate <Color=/> ดูซิ!",
					Yes = "จัดมาดิ,กลัวไร",
					No = ""
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>It's close to midnight... something devilish is lurking in the dark, waiting to hunt you....",
					[2] = "<AnimateStyle=Appear><Color=/>That's the spirit! Such a brave adventurer. Defeat <Color=Red>x12 Skull Pirates<Color=/>! Go!",
					Yes = "You wish!",
					No = "No!"
				},
				Quest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>อะไรกัน! นี่หลง หรืออะไร? ขี้เกียจงั้นเหรอ?",
						[2] = "<AnimateStyle=Appear><Color=/>ฟังนะ! ครั้งนี้ข้าลงทุนบอกตำแหน่งแล้วนะ",
						Yes = "ก็ไม่รู้มันอยู่ไหนอะ",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>What!? Lost or somethin'? Lazy?",
						[2] = "<AnimateStyle=Appear><Color=/>Look! This time I've marked it on your map!",
						Yes = "Don't know...",
						No = "..."
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "<AnimateStyle=Appear><Color=/>เจ้าจัดการพวกมันพอแล้วหล่ะ...ไม่คิดไม่ฝันจริงๆ",
						[2] = "<AnimateStyle=Appear><Color=/>ข้าคิดว่า นักผจญภัยอย่างเจ้า จะละทิ้งภารกิจเหล่านี้ซะแล้ว... ",
						Yes = "ธรรมดา..",
						No = "..."
					},
					US = {
						[1] = "<AnimateStyle=Appear><Color=/>You've defeated them enough... I don't think you could have done it...",
						[2] = "<AnimateStyle=Appear><Color=/>I thought an adventurer like you wouldn't take on a task like this...",
						Yes = "Absolutely",
						No = "..."
					}
				}
			}
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/> โอ้ว! เจอกันอีกแล้วนะสหายนักผจญภัย...",
			[2] = "<AnimateStyle=Appear>แล้วไงต่อ?",
			Yes = "สวัสดี..",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>Oh! We meet again, my dear adventurer friend...",
			[2] = "<AnimateStyle=Appear><Color=/>So?",
			Yes = "Hello..",
			No = "..."
		}
	},
	_TEMPLATED = {
		Name = "Name",
		THName = "ชื่อ",
		Multi = "Quest",
		BulkQuest = {
			{
				QuestName = "ชื่อไอเท็ม",
				TypeItem = {
					Type = "Accessories",
					RequiredLevel = 0,
					RequiredMaterial = {
						Candy = 350
					}
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/> เจ้าต้องการซื้อ<Color=Red> Pumpkin Head<Color=/> ในราคา 1000 แคนดี้?",
					[2] = "<AnimateStyle=Appear>ได้เลยจัดไป!",
					Yes = "แน่นอน",
					No = "ไม่อะ"
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>Do you want to buy<Color=Red> Pumpkin Head<Color=/> for 350 Candy?",
					[2] = "<AnimateStyle=Appear><Color=/>...",
					Yes = "Alright",
					No = "No!"
				},
				Quest = {
					TH = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					},
					US = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					},
					US = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					}
				}
			}
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/> เจ้าไม่กลัวอย่างงั้นรึ!",
			[2] = "<AnimateStyle=Appear>แล้วไงต่อ?",
			Yes = "ข้าไม่กลัวหรอก..",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>You're not scared at all!?",
			[2] = "<AnimateStyle=Appear><Color=/>So?",
			Yes = "Yes..",
			No = "..."
		}
	},
	["Halloween Shop Event"] = {
		Name = "Halloween Market",
		THName = "ร้านค้าฮาโลวีน",
		Multi = "Quest",
		BulkQuest = {
			{
				QuestName = "Pumpkin Head",
				TypeItem = {
					Type = "Accessories",
					RequiredLevel = 1000,
					RequiredMaterial = {
						Candy = 350
					}
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/> เจ้าต้องการซื้อ<Color=Red> Pumpkin Head<Color=/> ในราคา 1000 แคนดี้?",
					[2] = "<AnimateStyle=Appear>ได้เลยจัดไป!",
					Yes = "แน่นอน",
					No = "ไม่อะ"
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>Do you want to buy<Color=Red> Pumpkin Head<Color=/> for 350 Candy?",
					[2] = "<AnimateStyle=Appear><Color=/>...",
					Yes = "Alright",
					No = "No!"
				},
				Quest = {
					TH = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					},
					US = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					},
					US = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					}
				}
			},
			{
				QuestName = "Hallo Lamp",
				TypeItem = {
					Type = "Accessories",
					RequiredLevel = 1000,
					RequiredMaterial = {
						Candy = 500
					}
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/> เจ้าต้องการซื้อ<Color=Red> Hallo Lamp<Color=/> ในราคา 1000 แคนดี้?",
					[2] = "<AnimateStyle=Appear>ได้เลยจัดไป!",
					Yes = "แน่นอน",
					No = "ไม่อะ"
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>Do you want to buy<Color=Red> Hallo Lamp<Color=/> for 500 Candy?",
					[2] = "<AnimateStyle=Appear><Color=/>...",
					Yes = "Alright",
					No = "No!"
				},
				Quest = {
					TH = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					},
					US = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					},
					US = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					}
				}
			},
			{
				QuestName = "Hallo Shawl",
				TypeItem = {
					Type = "Accessories",
					RequiredLevel = 1000,
					RequiredMaterial = {
						Candy = 750
					}
				},
				TH = {
					[1] = "<AnimateStyle=Appear><Color=/> เจ้าต้องการซื้อ<Color=Red> Hallo Shawl<Color=/> ในราคา 1000 แคนดี้?",
					[2] = "<AnimateStyle=Appear>ได้เลยจัดไป!",
					Yes = "แน่นอน",
					No = "ไม่อะ"
				},
				US = {
					[1] = "<AnimateStyle=Appear><Color=/>Do you want to buy<Color=Red> Hallo Shawl<Color=/> for 750 Candy?",
					[2] = "<AnimateStyle=Appear><Color=/>...",
					Yes = "Alright",
					No = "No!"
				},
				Quest = {
					TH = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					},
					US = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					}
				},
				CompletedQuest = {
					TH = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					},
					US = {
						[1] = "",
						[2] = "",
						Yes = "",
						No = ""
					}
				}
			}
		},
		TH = {
			[1] = "<AnimateStyle=Appear><Color=/> เจ้าไม่กลัวอย่างงั้นรึ!",
			[2] = "<AnimateStyle=Appear>แล้วไงต่อ?",
			Yes = "ข้าไม่กลัวหรอก..",
			No = "..."
		},
		US = {
			[1] = "<AnimateStyle=Appear><Color=/>You're not scared at all!?",
			[2] = "<AnimateStyle=Appear><Color=/>So?",
			Yes = "Yes..",
			No = "..."
		}
	}
}

function class.GetLore(list)
	local v2, v3, v4 = unpack(list)
	local self = setmetatable({}, class)

	if not v[v2] then
		return self
	end

	local v5 = v[v2]

	if v3 == "" then
		self.Story = v5[v4] or v5.US
		self.Name = v5.Name

		if v4 == "TH" then
			self.Name = v5.THName
		end

		local quest3

		if v5.Quest then
			quest3 = v5.Quest[v4] or nil
		end

		self.Quest = quest3

		if self.Quest then
			self.Quest.QuestName = v5.QuestName or ""
			local quest = self.Quest
			local completed

			if v5.CompletedQuest then
				completed = v5.CompletedQuest[v4] or nil
			end

			quest.Completed = completed
			local quest2 = self.Quest
			local level

			if v5.QuestGiven then
				level = v5.QuestGiven.LvRequired or nil
			end

			quest2.Level = level
			self.Quest.OnQuest = v5.OnQuest or nil
		end

		self.Scene = v5.Scene or nil

		if v5.Multi then
			local multi = v5.Multi

			if v5["Bulk" .. multi] then
				self.Multi = v5["Bulk" .. multi]
			end
		end

		return self
	else
		local v6 = v2 .. " " .. v3

		if not v5[v6] then
			return self
		end

		self.Story = v5[v6][v4] or v5[v6].US
		self.Name = v5[v6].Name

		if v4 == "TH" then
			self.Name = v5[v6].THName
		end

		local quest3

		if v5.Quest then
			quest3 = v5.Quest[v4] or nil
		end

		self.Quest = quest3

		if self.Quest then
			self.Quest.QuestName = v5.QuestName or ""
			local quest = self.Quest
			local completed

			if v5[v6].CompletedQuest then
				completed = v5[v6].CompletedQuest[v4] or nil
			end

			quest.Completed = completed
			local quest2 = self.Quest
			local level

			if v5[v6].QuestGiven then
				level = v5[v6].QuestGiven.LvRequired or nil
			end

			quest2.Level = level
			self.Quest.OnQuest = v5[v6].OnQuest or nil
		end

		self.Scene = v5[v6].Scene or nil

		if not v5[v6].Multi then
			return self
		end

		local multi = v5[v6].Multi

		if not v5[v6]["Bulk" .. multi] then
			return self
		end

		self.Multi = v5[v6]["Bulk" .. multi]
		return self
	end
end

function class.GetQuest()
	local result = {}

	for k, v2 in pairs(v) do
		if typeof(v2) ~= "table" then
			continue
		end

		if v2.Gui and not (result[k] or result[k]) then
			result[k] = {
				Gui = v2.Gui
			}
		elseif v2.QuestGiven and not result[k] then
			result[k] = v2.QuestGiven
		else
			for k2, v3 in pairs(v2) do
				if typeof(v3) ~= "table" or not v3.QuestGiven or result[k2] then
					continue
				end

				result[k2] = v3.QuestGiven
			end

			if v2.BulkQuest and not result[k] then
				result[k] = {
					Bulk = v2.BulkQuest
				}
			end
		end
	end

	return result
end

function class.ReturnQuestLog(_)
	local result = {}

	for k, v2 in pairs(v) do
		if v2.QuestName or v2.QuestGiven then
			result[k] = {
				v2.Name,
				v2.THName,
				v2.QuestName,
				v2.QuestGiven
			}
		end
	end

	return result
end

return (setmetatable({}, class))