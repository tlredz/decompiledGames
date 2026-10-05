local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("Debris")
game:GetService("Players")
ReplicatedStorage.RewardScreen:WaitForChild("Reward")
local assets = ReplicatedStorage:WaitForChild("Assets", 15)
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript", 15)
assets:WaitForChild("InstanceTemplate", 15)
require(moduleScript:WaitForChild("SetText"))
require(moduleScript:WaitForChild("Abbreviate"))
local sine = Enum.EasingStyle.Sine
local out = Enum.EasingDirection.Out

local function FloorNumber(p)
	return (math.floor((math.floor(p))))
end

local Setting = {
	Setting = {
		Hitbox_Transparency = 1,
		Health_Multipliers = 20,
		NoSkillCooldown = 0.01,
		IgnoreSpawnPoints = { "Heaven", "Spawn" },
		MaxLevel = 2400,
		Max_Money = 100000000000,
		Max_Gem = 100000000,
		MaxQuest = 3,
		MaxBounty = 1000000,
		MaxKillsPerDay = 5,
		ResetScoreTime = 86400,
		MaxPop = 1000000000000,
		MaxMoney_Admin = 100000000000,
		MaxGem_Admin = 100000000,
		CodeLevel_Required = 25,
		InCombat_Duration = 30,
		PvpDisabled_Time = 600,
		MaxAuraLevel = 2,
		Aura_Cooldown = 1,
		MaxDodgeLevel = 2,
		Instinct_Info = {
			Max_Distance = 1000,
			Dodge_Multiplier = 5,
			Broke_Cooldown = 3,
			Dodge_Charge = 30
		},
		MaxFlashStepLevel = 2,
		FlashStepCooldown = 15,
		MaxJump = 15,
		RaceSkill_Cooldown = 30,
		RandomPower_Money = 25000,
		RandomPower_Gem = 25,
		RandomPower_LevelRequired = 50,
		RerollColor_Price = 10,
		Max_Luck = 25,
		StatsRefund_Price = 50,
		Race_Settings = {
			RerollRace_Price = 250,
			RaceChance_Table = {
				Human = 1,
				Fish = 1,
				Bird = 1,
				Rabbit = 1
			}
		},
		SecondSeaPlaceId = 11487720177,
		FirstSeaPlaceId = 10260193230,
		SecondSeaPlaceIdTest = 11488142660,
		FirstSeaPlaceIdTest = 10495019552,
		Gamepasses_Cost = {
			DoubleExp = 15000,
			DoubleMoney = 15000,
			DoubleGem = 30000,
			Lucky = 20000,
			Capybara = 10000,
			Noob = 10000,
			DoubleDrop = 50000
		},
		Gamepass_RobuxCosts = {
			DoubleExp = 30,
			DoubleMoney = 30,
			Lucky = 40,
			DoubleGem = 60,
			Capybara = 20,
			Noob = 20,
			DoubleDrop = 100
		},
		Boss_GemRewards = {
			["Big Floppa"] = {
				MinAmount = 3,
				MaxAmount = 5
			},
			["Walter Dog"] = {
				MinAmount = 4,
				MaxAmount = 6
			},
			["Snow Tree"] = {
				MinAmount = 5,
				MaxAmount = 7
			},
			["Sus Face"] = {
				MinAmount = 6,
				MaxAmount = 8
			},
			["Gorilla King"] = {
				MinAmount = 7,
				MaxAmount = 9
			},
			Obamid = {
				MinAmount = 8,
				MaxAmount = 10
			},
			["Pink Absorber"] = {
				MinAmount = 9,
				MaxAmount = 11
			},
			Moai = {
				MinAmount = 10,
				MaxAmount = 12
			},
			["Rick Roller"] = {
				MinAmount = 11,
				MaxAmount = 13
			},
			MrBeast = {
				MinAmount = 12,
				MaxAmount = 14
			},
			["Giant Pumpkin"] = {
				MinAmount = 100,
				MaxAmount = 150
			},
			["Evil Noob"] = {
				MinAmount = 150,
				MaxAmount = 200
			},
			["Lord Sus"] = {
				MinAmount = 200,
				MaxAmount = 250
			},
			["Meme Beast"] = {
				MinAmount = 1000,
				MaxAmount = 1250
			}
		},
		SpawnTime = {
			["Meme Beast"] = 1800,
			Powers = 3600,
			Powers_Despawn = 1800,
			Auto_Save = 1800
		},
		Summon_Boss = {
			["Giant Pumpkin"] = {
				Required_Item = {
					Item_Name = "Flame Orb",
					Amount = 1
				}
			},
			["Evil Noob"] = {
				Required_Item = {
					Item_Name = "Noob Head",
					Amount = 1
				}
			},
			["Lord Sus"] = {
				Required_Item = {
					Item_Name = "Sussy Orb",
					Amount = 1
				}
			}
		},
		Reflex_Power = {
			"Flame Power",
			"Ice Power",
			"Water Power",
			"Sand Power",
			"Snow Power",
			"Dark Power",
			"Dough Power"
		},
		Message = {
			Maxwell = {
				Title = "Would you like to learn the <font color=\"rgb(75,200,255)\">Combat</font> Fighting Style for <font color=\"rgb(100,235,100)\">$0?</font>",
				Title_TH = "คุณต้องการเรียนรู้ทักษะการต่อสู้ <font color=\"rgb(75,200,255)\">Combat</font> ในราคา <font color=\"rgb(100,235,100)\">$0</font> หรือเปล่า?"
			},
			Baller = {
				Title = "Would you like to learn the <font color=\"rgb(75,200,255)\">Baller</font> Fighting Style for <font color=\"rgb(100,235,100)\">$10,000,000</font> and <font color=\"rgb(175,125,255)\">10x Balls?</font>",
				Title_TH = "คุณต้องการเรียนรู้ทักษะการต่อสู้ <font color=\"rgb(75,200,255)\">Baller</font> ในราคา <font color=\"rgb(100,235,100)\">$10,000,000</font> และ <font color=\"rgb(175,125,255)\">x10 Ball</font> หรือเปล่า?"
			},
			Doge = {
				Title = "Would you like to purchase the <font color=\"rgb(75,200,255)\">Katana</font> for <font color=\"rgb(100,235,100)\">$5,000?</font> This is the best weapon in the game. Not gonna lie!",
				Title_TH = "คุณต้องการซื้อดาบที่มีชื่อว่า <font color=\"rgb(75,200,255)\">Katana</font> ในราคา <font color=\"rgb(100,235,100)\">$5,000</font> หรือเปล่า? นี่น่ะคืออาวุธที่ดีที่สุดในเกมเลยนะ. ถ้าคุณไม่เชื่อก็ลองซื้อดูสิ!"
			},
			Hanger = {
				Title = "Would you like to purchase this weapon for <font color=\"rgb(100,235,100)\">$25,000?</font> I'm the most powerful weapon in the game!",
				Title_TH = "คุณต้องการซื้ออาวุธชิ้นนี้ในราคา <font color=\"rgb(100,235,100)\">$25,000</font> หรือเปล่า? ข้านี่แหละคืออาวุธที่ทรงพลังที่สุดในเกม!"
			},
			Cheems = {
				Title = "I'm so thirsty for some cola. Would you like to trade your <font color=\"rgb(175,125,255)\">1x Cheems Cola</font> and <font color=\"rgb(100,235,100)\">$50,000</font> for <font color=\"rgb(75,200,255)\">Flame Katana?</font>",
				Title_TH = "ฉันหิวโคล่าสุดๆไปเลยล่ะ คุณต้องการแลกเปลี่ยนไอเทม <font color=\"rgb(175,125,255)\">x1 Cheems Cola</font> กับเงินจำนวน <font color=\"rgb(100,235,100)\">$50,000</font> ของคุณสำหรับดาบ <font color=\"rgb(75,200,255)\">Flame Katana</font> ไหมล่ะ? ดาบนี้สามารถฟาดฟันศัตรูของคุณให้ติดไฟได้ด้วยนะ!"
			},
			["Smiling Cat"] = {
				Title = "Meow! Would you like to take my <font color=\"rgb(75,200,255)\">Banana</font> for <font color=\"rgb(100,235,100)\">$350,000</font> and <font color=\"rgb(175,125,255)\">1x Cat Food?</font>",
				Title_TH = "เหมียว! คุณต้องการซื้อ <font color=\"rgb(75,200,255)\">Banana</font> ด้วยเงินจำนวน <font color=\"rgb(100,235,100)\">$350,000</font> และไอเทม <font color=\"rgb(175,125,255)\">x1 Cat Food</font> หรือเปล่า?"
			},
			Gravestone = {
				Title = "What’s up? Would you like to purchase the <font color=\"rgb(75,200,255)\">Pumpkin</font> for <font color=\"rgb(175,125,255)\">1x Nugget Man</font> and <font color=\"rgb(100,235,100)\">$3,500,000?</font> If not, I will haunt you everywhere you go!",
				Title_TH = "ว่าไง? คุณสนใจซื้อ <font color=\"rgb(75,200,255)\">Pumpkin</font> ด้วยไอเทม <font color=\"rgb(175,125,255)\">x1 Nugget Man</font> และเงินจำนวน <font color=\"rgb(100,235,100)\">$3,500,000</font> หรือเปล่า? ถ้าไม่ล่ะก็ฉันจะตามหลอกหลอนคุณไปทุกที่! "
			},
			["Ohio Popcat"] = {
				Title = "Hey there! Would you like to purchase the <font color=\"rgb(75,200,255)\">Popcat</font> for <font color=\"rgb(225,150,255)\">10,000 Pops?</font> You can get pops by popping the Pop Cat on the Floppa Island.",
				Title_TH = "เฮ้! คุณต้องการซื้อ <font color=\"rgb(75,200,255)\">Popcat</font> ในราคา <font color=\"rgb(225,150,255)\">10,000 Pop</font> หรือเปล่า? คุณสามารถหา Pop ได้โดยการกดคลิก Pop Cat ที่เกาะ Floppa Island."
			},
			MrBeast = {
				Title = "Hello, I'm MrBeast. Would you like to purchase the <font color=\"rgb(75,200,255)\">Dual Katana</font> for <font color=\"rgb(100,235,100)\">$750,000</font> and <font color=\"rgb(175,125,255)\">3 Money Bags?</font> By the way, I'm the real MrBeast!",
				Title_TH = "สวัสดีครับ, ผมมิสเตอร์บีสต์เอง. คุณสนใจที่จะซื้อสินค้าใหม่ของผม <font color=\"rgb(75,200,255)\">Dual Katana</font> ด้วย <font color=\"rgb(175,125,255)\">3 Money Bag</font> และเงินจำนวน <font color=\"rgb(100,235,100)\">$750,000</font> หรือเปล่า? ยังไงก็ตาม, ผมนี่แหละคือ MrBeast ตัวจริง!"
			},
			["Meme Man"] = {
				Title = "Hello ladies and gentlemen. Would you like to trade your <font color=\"rgb(100,235,100)\">$1,000,000</font> and <font color=\"rgb(175,125,255)\">5x Money Bags</font> for my weapon called <font color=\"rgb(75,200,255)\">Bonk?</font> This is an absolutely stonks trade!",
				Title_TH = "สวัสดีสุภาพบุรุษและสุภาพสตรีทุกท่าน! คุณสนใจที่จะแลกเปลี่ยนเงินจำนวน <font color=\"rgb(100,235,100)\">$1,000,000</font> และไอเทม <font color=\"rgb(175,125,255)\">x5 Money Bag</font> ของคุณสำหรับอาวุธ <font color=\"rgb(75,200,255)\">Bonk</font> ของผมหรือเปล่า? นี่เป็นการแลกเปลี่ยนที่คุ้มมากนะครับบอกเลย!"
			},
			["Giga Chad"] = {
				Title = "Would you like to learn the <font color=\"rgb(75,200,255)\">Flash Step</font> ability for a cheap price <font color=\"rgb(100,235,100)\">$100,000?</font> This ability allows you to teleport over short distances. You can train this ability to teleport more further.",
				Title_TH = "คุณต้องการเรียนรู้ทักษะ <font color=\"rgb(75,200,255)\">ก้าวพริบตา</font> ในราคา <font color=\"rgb(100,235,100)\">$100,000</font> หรือเปล่า? ทักษะนี้จะทำให้คุณสามารถเทเลพอร์ตในระยะทางสั้นๆได้! คุณยังสามารถฝึกฝนทักษะนี้ให้เทเลพอร์ตได้ไกลยิ่งขึ้นได้ด้วยนะ."
			},
			["Aura Master"] = {
				Title = "Hey you! Would you like to learn the <font color=\"rgb(75,200,255)\">Aura</font> ability for <font color=\"rgb(175,125,255)\">1x Meme Cube</font> and a small price <font color=\"rgb(100,235,100)\">$10,000,000?</font> Aura allows you to boost your damage and defense.",
				Title_TH = "เฮ้คุณน่ะ! คุณสนใจเรียนรู้ทักษะ <font color=\"rgb(75,200,255)\">ออร่า</font> ด้วยไอเทม <font color=\"rgb(175,125,255)\">x1 Meme Cube</font> และเงินจำนวนเล็กน้อยเพียง <font color=\"rgb(100,235,100)\">$10,000,000</font> หรือเปล่า? ออร่าช่วยเพิ่มดาเมจที่คุณทำต่อศัตรูและช่วยเพิ่มพลังป้องกันของคุณได้."
			},
			["Nugget Man"] = {
				Title = "Would you like to learn the <font color=\"rgb(75,200,255)\">Instinct</font> ability for a great price <font color=\"rgb(100,235,100)\">$2,500,000?</font> You can see your enemies from a distance and dodge incoming attacks with this ability.",
				Title_TH = "คุณต้องการเรียนรู้ทักษะ <font color=\"rgb(75,200,255)\">สัญชาตญาณ</font> ในราคา <font color=\"rgb(100,235,100)\">$2,500,000</font> หรือไม่? คุณสามารถมองเห็นศัตรูของคุณจากระยะไกลและหลบการโจมตีที่เข้ามาด้วยทักษะนี้ได้. นี่มันเป็นทักษะที่ดีสุดๆไปเลยนะคุณว่ามั้ย?"
			},
			["Watermelon Man"] = {
				Title = "Hey stranger, would you like to reroll your <font color=\"rgb(75,200,255)\">Race</font> for <font color=\"rgb(175,125,255)\">250 Gem?</font>",
				Title_TH = "ว่าไงคนแปลกหน้า! คุณต้องการที่จะ<font color=\"rgb(75,200,255)\">สุ่มเผ่า</font>ของคุณในราคาเพียง <font color=\"rgb(175,125,255)\">250 เพชร</font> ไหมล่ะ?"
			},
			Spawn_Boat = {
				Title = "Please select a boat you want to spawn.",
				Title_TH = "โปรดเลือกเรือที่คุณต้องการที่จะเสกได้เลยนะครับ."
			},
			["Halved Sorcerer"] = {
				Title = "Hey adventurer! Would you like to reroll your <font color=\"rgb(75,200,255)\">Aura Color</font> for <font color=\"rgb(175,125,255)\">10 Gem?</font> You can view the chance of rolling each color by clicking the \"Chances\" button.",
				Title_TH = "โยวายโม! คุณต้องการที่จะสุ่ม <font color=\"rgb(75,200,255)\">สีออร่า</font> ของคุณในราคา <font color=\"rgb(175,125,255)\">10 เพชร</font> หรือเปล่า? คุณสามารถดูโอกาสที่จะสุ่มได้แต่ละสีโดยการคลิกที่ปุ่ม \"ดูโอกาส\" บนหน้าจอได้เลยนะครับ."
			},
			["Floppa Gacha"] = {
				Title = "Meow! Would you like to buy a <font color=\"rgb(75,200,255)\">Random Power</font> for <font color=\"rgb(100,235,100)\">$25,000?</font> You can view the chance of getting each power by clicking the \"Chances\" button.",
				Title_TH = "เหมี๊ยว! คุณต้องการที่จะ <font color=\"rgb(75,200,255)\">สุ่มพลังพิเศษ</font> ในราคา <font color=\"rgb(100,235,100)\">$25,000</font> หรือเปล่า? คุณสามารถดูโอกาสที่จะสุ่มได้แต่ละพลังโดยการคลิกที่ปุ่ม \"ดูโอกาส\" บนหน้าจอได้เลยนะเหมียว."
			},
			["Doge Gacha"] = {
				Title = "Woof! Would you like to buy a <font color=\"rgb(75,200,255)\">Random Power</font> for <font color=\"rgb(175,125,255)\">25 Gem?</font> You can view the chance of getting each power by clicking the \"Chances\" button.",
				Title_TH = "โฮ่งๆ! คุณต้องการที่จะ <font color=\"rgb(75,200,255)\">สุ่มพลังพิเศษ</font> ในราคา <font color=\"rgb(175,125,255)\">25 เพชร</font> หรือเปล่า? คุณสามารถดูโอกาสที่จะสุ่มได้แต่ละพลังโดยการคลิกที่ปุ่ม \"ดูโอกาส\" บนหน้าจอได้เลยนะโฮ่ง."
			},
			["The Bed"] = {
				Title = "Would you like to set your <font color=\"rgb(175,125,255)\">Bed Point</font> here? You can press the ufo button from anywhere to teleport back here!",
				Title_TH = "คุณต้องการเซ็ต<font color=\"rgb(175,125,255)\">เตียง</font>ของคุณที่นี่หรือไม่? คุณสามารถกดปุ่มยูเอฟโอจากที่ไหนก็ได้เพื่อเทเลพอร์ตกลับมาที่นี่!"
			},
			Popcat = {
				Title = "Hey human! Would you like to purchase my item called <font color=\"rgb(75,200,255)\">Quest Scroll</font> for <font color=\"rgb(100,235,100)\">$1,000,000?</font> This item can upgrade your quest limit. Are you interested?",
				Title_TH = "เฮ้เจ้ามนุษย์! ต้องการซื้อไอเทมที่เรียกว่า <font color=\"rgb(75,200,255)\">Quest Scroll</font> ในราคา <font color=\"rgb(100,235,100)\">$1,000,000</font> หรือเปล่า? ไอเทมชิ้นนี้สามารถอัปเกรดขีดจำกัดภารกิจของคุณได้นะ! สนใจที่จะซื้อหรือเปล่า?"
			},
			["Floppa Recruiter"] = {
				Title = "Would you like to switch your team to <font color=\"rgb(255,89,89)\">Floppa?</font> Just forget about all of the rules and let's fight for our goals!",
				Title_TH = [[
คุณต้องการเปลี่ยนทีมของคุณเป็นทีม <font color="rgb(255,89,89)">Floppa</font> หรือเปล่า? จงลืมพวกกฎเกณฑ์ทั้งหมดแล้วมาต่อสู้เพื่อเป้าหมายของพวกเรา
กันดีกว่า!]]
			},
			["Cheems Recruiter"] = {
				Title = "Would you like to switch your team to <font color=\"rgb(175,221,255)\">Cheems?</font> Help us get rid of those bad cats on the <font color=\"rgb(255,89,89)\">Floppa</font> team and bring peace to the sea!",
				Title_TH = "คุณต้องการเปลี่ยนทีมของคุณเป็นทีม <font color=\"rgb(175,221,255)\">Cheems</font> หรือเปล่า? จงมาช่วยพวกเรากำจัดเหล่าแมวสุดแสนชั่วร้ายเหล่านั้นในทีม <font color=\"rgb(255,89,89)\">Floppa</font> และนำพาความสงบสุขกลับมาสู่ทะเลแห่งนี้กันเถอะ!"
			},
			Quest_Scroll = {
				Title = "What do you want to do with this scroll?",
				Title_TH = "คุณต้องการที่จะทำอะไรกับคำภีร์นี้?"
			},
			Awakening_Orb = {
				Title = "This orb can evolve your race. What do you wish to do with this orb?",
				Title_TH = "ลูกแก้วนี้สามารถวิวัฒนาการเผ่าคุณได้. คุณปรารถนาที่จะทำสิ่งใดกับลูกแก้วนี้?"
			},
			Storage_Item = {
				Title = "What do you wish to do with this item?",
				Title_TH = "คุณต้องการที่จะทำอะไรกับไอเทมชิ้นนี้ดีล่ะ?"
			},
			Eatable_Power = {
				Title = "What do you wish to do with this power?",
				Title_TH = "คุณต้องการที่จะทำอะไรกับพลังพิเศษชิ้นนี้ดีล่ะ?"
			}
		},
		BuyItem = {
			Maxwell = {
				Name = "Combat",
				Cost = 0,
				ItemNeed = "Ball",
				Amount = 0,
				Currency = "Money"
			},
			Baller = {
				Name = "Baller",
				Cost = 10000000,
				ItemNeed = "Ball",
				Amount = 10,
				Currency = "Money"
			},
			Doge = {
				Name = "Katana",
				Cost = 5000,
				ItemNeed = "Ball",
				Amount = 0,
				Currency = "Money"
			},
			Hanger = {
				Name = "Hanger",
				Cost = 25000,
				ItemNeed = "Ball",
				Amount = 0,
				Currency = "Money"
			},
			Cheems = {
				Name = "Flame Katana",
				Cost = 50000,
				ItemNeed = "Cheems Cola",
				Amount = 1,
				Currency = "Money"
			},
			["Smiling Cat"] = {
				Name = "Banana",
				Cost = 350000,
				ItemNeed = "Cat Food",
				Amount = 1,
				Currency = "Money"
			},
			Gravestone = {
				Name = "Pumpkin",
				Cost = 3500000,
				ItemNeed = "Nugget Man",
				Amount = 1,
				Currency = "Money"
			},
			["Ohio Popcat"] = {
				Name = "Popcat",
				Cost = 10000,
				ItemNeed = "Ball",
				Amount = 0,
				Currency = "Pop"
			},
			MrBeast = {
				Name = "Dual Katana",
				Cost = 750000,
				ItemNeed = "Money Bag",
				Amount = 3,
				Currency = "Money"
			},
			["Meme Man"] = {
				Name = "Bonk",
				Cost = 1000000,
				ItemNeed = "Money Bag",
				Amount = 5,
				Currency = "Money"
			},
			["Giga Chad"] = {
				Name = "FlashStep",
				Cost = 100000,
				ItemNeed = "Ball",
				Amount = 0,
				Currency = "Money"
			},
			["Aura Master"] = {
				Name = "Aura",
				Cost = 10000000,
				ItemNeed = "Meme Cube",
				Amount = 1,
				Currency = "Money"
			},
			["Nugget Man"] = {
				Name = "Instinct",
				Cost = 2500000,
				ItemNeed = "Ball",
				Amount = 0,
				Currency = "Money"
			},
			["Quest Scroll"] = {
				Name = "Quest Scroll",
				Currency = "Money",
				Cost = 1000000
			}
		},
		Badges = {
			Floppa_Badge = 2127546720,
			Welcome_Badge = 2127588014
		},
		BoatSettings = {
			Floppa = {
				Cost = 50,
				MaxSpeed = 75,
				Acceleration = 1,
				TurnSpeed = 0.01
			},
			Doge = {
				Cost = 500,
				MaxSpeed = 125,
				Acceleration = 2,
				TurnSpeed = 0.01
			},
			Cheems = {
				Cost = 5000,
				MaxSpeed = 200,
				Acceleration = 2,
				TurnSpeed = 0.005
			},
			Capybara = {
				Cost = 1000,
				MaxSpeed = 375,
				Acceleration = 4,
				TurnSpeed = 0.01,
				Image = "rbxassetid://17763913816"
			},
			Noob = {
				Cost = 1500,
				MaxSpeed = 400,
				Acceleration = 3,
				TurnSpeed = 0.01,
				Image = "rbxassetid://16995147482"
			}
		},
		TestServer_Access = {
			"drybones223",
			"drybones224",
			"tream46",
			"RealNoobx001",
			"NingKak12345",
			"MemeSea_Lover"
		}
	},
	SetCooldown = function(p, _, state, duration)
		local function CooldownSet()
			if state.Value == true then
				if p.Visible == false then
					p.Visible = true
				end

				local tween = TweenService:Create(p, TweenInfo.new(duration, sine, out), {
					Size = UDim2.new(0, 0, 1, 0)
				})
				tween:Play()
				tween.Completed:Connect(function()
					p.Visible = false
					TweenService:Create(p, TweenInfo.new(0.01, sine, out), {
						Size = UDim2.new(1, 0, 1, 0)
					}):Play()
					state.Value = false
				end)
			end
		end

		CooldownSet()
		state.Changed:Connect(CooldownSet)
	end,
	PlayAnimation = function(instance, p)
		task.spawn(function()
			local humanoid = instance:FindFirstChild("Humanoid")
			local animation_Folder = ReplicatedStorage:FindFirstChild("Animation_Folder")
			local v = nil
			local lastTime = tick()

			if humanoid then
				for _, descendant in pairs(animation_Folder:GetDescendants()) do
					if descendant.Name ~= p then
						continue
					end

					v = descendant
					break
				end

				repeat
					wait()
				until v ~= nil or tick() - lastTime >= 15 or humanoid == nil

				if v then
					local track = nil
					local success, _ = pcall(function()
						track = humanoid:LoadAnimation(v)
					end)

					if not success then
						local lastTime2 = tick()

						repeat
							wait(0.1)
							local success2, _ = pcall(function()
								track = humanoid:LoadAnimation(v[instance])
							end)
						until tick() - lastTime2 > 5 or success2 or humanoid == nil
					end

					if track then
						track:Play()
					end
				end
			end
		end)
	end
}
local Folders = {
	workspace.Skills,
	workspace.Region,
	workspace.Visuals,
	workspace.Location,
	workspace.Sea,
	workspace.Leaderboard,
	workspace.CameraFolder,
	workspace.SpawningPower
}
local Folders2 = {
	workspace.Skills,
	workspace.Region,
	workspace.Visuals,
	workspace.Island,
	workspace.Raids,
	workspace.Sea,
	workspace.Leaderboard,
	workspace.Location,
	workspace.NPCs,
	workspace.BoatFolder,
	workspace.CameraFolder,
	workspace.Dropped_Items,
	workspace.SpawningPower,
	workspace.Location
}

function Setting.GetIgnoreRayForAttackable(p)
	local v = Folders2

	if p and not table.find(v, p) then
		table.insert(v, p)
	end

	return v
end

function Setting.GetIgnoreRayForExplosion(p)
	local v = Folders

	if p and not table.find(v, p) then
		table.insert(v, p)
	end

	return v
end

function Setting.GenerateSkillHolding(player, p)
	if not (player and _G.CheckAlive_Character(player.Character)) then
		return
	end

	_G.ClearBV(player.Character)
	player.Character:SetAttribute("OldSpeed", player.Character.Humanoid.WalkSpeed)
	local bodyGyro = Instance.new("BodyGyro", player.Character.HumanoidRootPart)
	bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
	bodyGyro.CFrame = p.Hit
	bodyGyro.D = 100
	bodyGyro.P = 20000
	local bodyVelocity = Instance.new("BodyVelocity", player.Character.HumanoidRootPart)
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.P = 500000
	bodyVelocity.Velocity = Vector3.new()
	player.Character.Humanoid.WalkSpeed = 0
	return bodyGyro, bodyVelocity
end

return Setting