return {
	Luxuriant = {
		Image = "rbxassetid://121060278055582",
		Tier = "Common",
		Info = "Increases $ Money drops from Quest by IncreaseMoneyDrop",
		InfoTH = "เพิ่มเงินที่ดรอปจากภารกิจ IncreaseMoneyDrop",
		LevelRates = {
			500,
			200,
			100,
			50,
			25
		},
		PassiveBuff = {
			IncreaseMoneyDrop = {
				10,
				20,
				35,
				50,
				65
			}
		}
	},
	Wisdom = {
		Image = "rbxassetid://139775284180367",
		Tier = "Common",
		Info = "Increases EXP drops from Quest by IncreaseEXPDrop",
		InfoTH = "เพิ่มค่าประสบการณ์ที่ดรอปจากภารกิจ IncreaseEXPDrop",
		LevelRates = {
			500,
			200,
			100,
			50,
			25
		},
		PassiveBuff = {
			IncreaseEXPDrop = {
				10,
				20,
				35,
				50,
				65
			}
		}
	},
	Chance = {
		Image = "rbxassetid://91993781213662",
		Tier = "Common",
		Info = "Increases drop rates from NPCs by IncreaseDropRate",
		InfoTH = "เพิ่มโอกาสได้รับไอเทมจาก NPC IncreaseDropRate",
		LevelRates = {
			500,
			200,
			100,
			50,
			25
		},
		PassiveBuff = {
			IncreaseDropRate = {
				5,
				10,
				15,
				20,
				25
			}
		}
	},
	Piercing = {
		Image = "rbxassetid://72349909979629",
		Tier = "Common",
		Info = "Armor piercing by IncreasePiercingArmor",
		InfoTH = "เจาะเกราะ IncreasePiercingArmor",
		LevelRates = {
			500,
			300,
			100,
			50,
			30,
			15,
			8,
			3
		},
		PassiveBuff = {
			IncreasePiercingArmor = {
				3,
				6,
				9,
				12,
				15,
				18,
				21,
				24
			}
		}
	},
	Destruction = {
		Image = "rbxassetid://79761941407733",
		Tier = "Common",
		Info = "Increases damage dealt to NPCs by IncreaseNPCsDamage",
		InfoTH = "เพิ่มความเสียหายที่เกิดขึ้นกับ NPC IncreaseNPCsDamage",
		LevelRates = {
			500,
			200,
			100,
			50,
			25
		},
		PassiveBuff = {
			IncreaseNPCsDamage = {
				4,
				8,
				12,
				14,
				16
			}
		}
	},
	Ruin = {
		Image = "rbxassetid://132264315701820",
		Tier = "Common",
		Info = "Increases damage dealt to Player by IncreasePlayerDamage",
		InfoTH = "เพิ่มความเสียหายที่เกิดขึ้นกับผู้เล่น IncreasePlayerDamage",
		LevelRates = {
			500,
			200,
			100,
			50,
			25
		},
		PassiveBuff = {
			IncreasePlayerDamage = {
				2,
				4,
				6,
				8,
				10
			}
		}
	},
	["Skill Haste"] = {
		Image = "rbxassetid://137484995679674",
		Tier = "Common",
		Info = "Reduces Cooldown of all abilities by ReduceCooldown",
		InfoTH = "ลดคูลดาวน์ของทักษะทั้งหมด ReduceCooldown",
		LevelRates = {
			1000,
			100,
			10,
			1
		},
		PassiveBuff = {
			ReduceCooldown = {
				3,
				7,
				10,
				12
			}
		}
	},
	["Sword Sense"] = {
		Image = "rbxassetid://137923683780670",
		Tier = "Common",
		Info = "Increases weapon damage dealt by IncreaseSwordDamage",
		InfoTH = "เพิ่มความเสียหายของอาวุธที่เกิดขึ้น IncreaseSwordDamage",
		LevelRates = {
			500,
			200,
			100,
			50,
			25
		},
		PassiveBuff = {
			IncreaseSwordDamage = {
				2,
				4,
				6,
				8,
				10
			}
		}
	},
	Paradox = {
		Tier = "Paradox",
		Info = "Reduces incoming damage from %s by 90%%.",
		InfoTH = "ต้านทาน %s ทำให้ความเสียหายลดลงถึง 90%%"
	},
	["Last Breath"] = {
		Tier = "Iconic",
		Info = "When dying, you will regain 50% of your health. This ability can be used only once. If you die again, you can use it once more.",
		InfoTH = "เมื่อตาย คุณจะได้รับพลังชีวิตคืน 50% ความสามารถนี้ใช้ได้เพียงครั้งเดียวเท่านั้น หากคุณตายอีกครั้ง คุณสามารถใช้มันได้อีกครั้ง",
		Image = "rbxassetid://107642610926424",
		AlwaysActive = true
	},
	["Stylish Heal"] = {
		Tier = "Iconic",
		Info = "When health is below 50%, it will be restored twice as fast.",
		InfoTH = "เมื่อสุขภาพต่ำกว่า 50% จะฟื้นฟูเร็วขึ้นสองเท่า",
		Image = "rbxassetid://16857487585"
	},
	["Last Stand"] = {
		Tier = "Iconic",
		Info = "When health is below 15%, all attack power will greatly increase.",
		InfoTH = "เมื่อสุขภาพต่ำกว่า 15% พลังโจมตีทั้งหมดจะเพิ่มขึ้นอย่างมาก",
		Image = "rbxassetid://16857452268"
	},
	["Critical Strikes"] = {
		Tier = "Iconic",
		Info = "The damage dealt has a chance to be a critical hit.",
		InfoTH = "ความเสียหายที่เกิดขึ้นมีโอกาสที่จะเป็นการโจมตีคริติคอล",
		Image = "rbxassetid://118920660540611",
		AlwaysActive = true
	},
	Various = {
		Tier = "Iconic",
		Info = "When attacking an enemy, there is a chance of dealing damage multiple times.",
		InfoTH = "เมื่อโจมตีศัตรู มีโอกาสที่จะสร้างความเสียหายได้หลายครั้ง",
		Image = "rbxassetid://138394438327168",
		AlwaysActive = true
	},
	Acropurged = {
		Tier = "Iconic",
		Info = "Enhancement of the vitality-absorbing prowess of Acro weaponry",
		InfoTH = "การเพิ่มความสามารถในการดูดซับพลังชีวิตของอาวุธ Acro",
		Image = "rbxassetid://120574072630974",
		AlwaysActive = true
	},
	Sprinter = {
		Tier = "Iconic",
		Info = "Has a chance to increase movement speed by 400% for 5 seconds after dealing damage.",
		InfoTH = "มีโอกาสเพิ่มความเร็วในการเคลื่อนที่ 400% เป็นเวลา 5 วินาทีหลังจากสร้างความเสียหาย",
		Image = "rbxassetid://115095379415535"
	},
	Dazzle = {
		Tier = "Iconic",
		Info = "Has a chance to blind enemies upon dealing damage.",
		InfoTH = "มีโอกาสทำให้ศัตรูตาบอดเมื่อได้รับความเสียหาย",
		Image = "rbxassetid://16857430900"
	},
	["Healing Havoc"] = {
		Tier = "Iconic",
		Info = "Has a chance to make enemies regenerate their health slowly for 45 seconds upon dealing damage.",
		InfoTH = "มีโอกาสทำให้ศัตรูฟื้นฟูพลังชีวิตช้าลง เป็นเวลา 45 วินาที เมื่อได้รับความเสียหาย",
		Image = "rbxassetid://16857445493"
	},
	Debility = {
		Tier = "Iconic",
		Info = "Has a chance to inflict a weak status on the enemy. Take 15% more damage for 10 seconds upon dealing damage.",
		InfoTH = "มีโอกาสทำให้ศัตรูติดสถานะอ่อนแอ ได้รับความเสียหายเพิ่มขึ้น 15% เป็นเวลา 10 วินาที เมื่อสร้างความเสียหาย",
		Image = "rbxassetid://16857435849"
	},
	Tempest = {
		Tier = "Iconic",
		Info = "After attacking, a small storm will be created around the enemy, causing a slight amount of damage.",
		InfoTH = "หลังจากโจมตีแล้ว จะเกิดพายุเล็กๆ ขึ้นรอบๆ ศัตรู ทำให้เกิดความเสียหายเล็กน้อย",
		Image = "rbxassetid://80626210275958",
		AlwaysActive = true
	},
	Blasting = {
		Tier = "Iconic",
		Info = "Has a chance to create a small explosion on the enemy after attacking.",
		InfoTH = "มีโอกาสสร้างระเบิดเล็กๆ น้อยๆ ใส่ศัตรูหลังจากโจมตี",
		Image = "rbxassetid://106959061173514",
		AlwaysActive = true
	},
	["Hyper Armor"] = {
		Tier = "Iconic",
		Info = "Has a chance to gain Hyper Armor for 5 seconds when damaged, Reduces damage taken by a factor of 4.",
		InfoTH = "มีโอกาสได้รับ Hyper Armor เป็นเวลา 5 วินาที เมื่อได้รับความเสียหาย ลดความเสียหายที่ได้รับลง 4 เท่า",
		Image = "rbxassetid://16857448955"
	},
	Swift = {
		Tier = "Iconic",
		Info = "After being hit, your speed will increase by 200% for 10 seconds.",
		InfoTH = "หลังจากถูกตี ความเร็วของคุณจะเพิ่มขึ้น 200% เป็นเวลา 10 วินาที",
		Image = "rbxassetid://111162213392334"
	},
	Nocturne = {
		Tier = "Celestial",
		Info = "Has a chance to dodge attacks. Afterward, you will be invulnerable for 1 seconds. Cooldown: 30 seconds.",
		InfoTH = "มีโอกาสหลบการโจมตี หลังจากนั้นจะคงกระพันเป็นเวลา 1 วินาที คูลดาวน์ 30 วิ",
		Image = "rbxassetid://138299182268461",
		AlwaysActive = true
	},
	["Reflect Strike"] = {
		Tier = "Celestial",
		Info = "Reflects 10% of the damage received.",
		InfoTH = "สะท้อน 10% ของความเสียหายที่ได้รับ",
		Image = "rbxassetid://99823444916061",
		AlwaysActive = true
	},
	Ronin = {
		Tier = "Celestial",
		Info = "When health falls below 15%, sword damage increases, and damage received from swords is reduced by 90%.",
		InfoTH = "เมื่อพลังชีวิตต่ำกว่า 15% เพิ่มความเสียหายดาบ 15% และลดความเสียหายที่ได้รับจากดาบทั้งหมดลง 90%",
		Image = "rbxassetid://16857457187"
	},
	Eternal = {
		Tier = "Celestial",
		Info = "When health falls below 15%, fruit damage increases, and damage received from fruits is reduced by 90%.",
		InfoTH = "เมื่อพลังชีวิตต่ำกว่า 15% เพิ่มความเสียหายผลไม้ 15% และลดความเสียหายที่ได้รับจากผลไม้ทั้งหมดลง 90%",
		Image = "rbxassetid://16857439514"
	},
	Brawler = {
		Tier = "Celestial",
		Info = "When health falls below 15%, melee damage increases, and damage received from melee is reduced by 90%.",
		InfoTH = "เมื่อพลังชีวิตต่ำกว่า 15% เพิ่มความเสียหาย Melee 15% และลดความเสียหายที่ได้รับจาก Melee ทั้งหมดลง 90%",
		Image = "rbxassetid://16857426894"
	},
	Sentinel = {
		Tier = "Celestial",
		Info = "When health falls below 15%, Reduce all damage by 50%.",
		InfoTH = "เมื่อพลังชีวิตต่ำกว่า 15% ลดความเสียหายทั้งหมดลง 50%",
		Image = "rbxassetid://16857461303"
	},
	["Sinister Hex"] = {
		Tier = "Curse",
		Info = "Decrease all damage by 15%.",
		InfoTH = "ลดความเสียหายทั้งหมดของคุณลง 15%",
		Image = "rbxassetid://134202890179441",
		AlwaysActive = true
	},
	Nightmare = {
		Tier = "Curse",
		Info = "All damage taken is increased by 10%.",
		InfoTH = "ความเสียหายทั้งหมดที่ได้รับเพิ่มขึ้น 10%",
		Image = "rbxassetid://94718377244672",
		AlwaysActive = true
	},
	["Difficult Healing"] = {
		Tier = "Curse",
		Info = "All heals, including those from Phoenix or others, are 25% slower.",
		InfoTH = "การรักษาทั้งหมด รวมถึงการรักษาจากฟีนิกซ์หรือที่อื่น ๆ จะช้าลง 25%",
		Image = "rbxassetid://125164378134248",
		AlwaysActive = true
	},
	Sorrowspell = {
		Tier = "Curse",
		Info = "The cooldown of all skills is 10% longer.",
		InfoTH = "คูลดาวน์สกิลนานขึ้น 10%",
		Image = "rbxassetid://82120665403679",
		AlwaysActive = true
	},
	["Draconic Aura"] = {
		Tier = "Iconic",
		Info = "Increases damage for all dragon-related abilities. (Dragon, Dragon Claw)",
		InfoTH = "เพิ่มความเสียหายของทุกอย่างที่เกี่ยวกับมังกร",
		Image = "rbxassetid://78702832998754"
	},
	["Night Core"] = {
		Tier = "Iconic",
		Info = "Increases damage for all darkness-related abilities. (Dark)",
		InfoTH = "เพิ่มความเสียหายของทุกอย่างที่เกี่ยวกับความมืด",
		Image = "rbxassetid://88768498115995"
	},
	["Pyro Core"] = {
		Tier = "Iconic",
		Info = "Increases damage for all fire-related abilities. (Flame)",
		InfoTH = "เพิ่มความเสียหายของทุกอย่างที่เกี่ยวกับไฟ",
		Image = "rbxassetid://135673133651871"
	},
	["Bolt Core"] = {
		Tier = "Iconic",
		Info = "Increases damage for all lightning-related abilities. (Rumble, Electro)",
		InfoTH = "เพิ่มความเสียหายของทุกอย่างที่เกี่ยวกับสายฟ้า",
		Image = "rbxassetid://112658352351315"
	},
	Fearless = {
		Tier = "Iconic",
		Info = "Deal +10% damage to players with a higher bounty than you.",
		InfoTH = "สร้างความเสียหาย +10% ให้กับผู้เล่นที่มีค่าหัวสูงกว่าคุณ",
		Image = "rbxassetid://138280628432793"
	},
	Pitiless = {
		Tier = "Iconic",
		Info = "Deal +10% damage to players with a bounty lower than yours.",
		InfoTH = "สร้างความเสียหาย +10% ให้กับผู้เล่นที่มีค่าหัวต่ำกว่าคุณ",
		Image = "rbxassetid://137147147727745"
	}
}