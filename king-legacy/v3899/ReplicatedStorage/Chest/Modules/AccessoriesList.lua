return {
	["Lunar Bunny Head"] = {
		Tier = "Limited",
		TierImage = "rbxassetid://131879367645344",
		Image = "rbxassetid://79799906812241",
		Info = "A gentle bunny blessed by moonlight. Radiates calm energy and soft power.",
		InfoTH = "กระต่ายที่ได้รับพรจากแสงจันทร์ เปล่งพลังอ่อนโยนและสงบ",
		Upgrade = {
			[0] = {
				Info = "+12.5k Health & 12.5% Fruit damage",
				InfoTH = "+12.5k พลังชีวิต & เพิ่มพลังผลไม้ 12.5%",
				Buff = {
					Health = { 12500, "Normal" },
					Damage = { 12.5, "Fruit" }
				}
			},
			[1] = {
				Info = "+15k Health & 15% Fruit damage",
				InfoTH = "+15k พลังชีวิต & เพิ่มพลังผลไม้ 15%",
				Buff = {
					Health = { 15000, "Normal" },
					Damage = { 15, "Fruit" }
				},
				MaterialNeed = {
					Leather = 200,
					Lunafin = 50,
					Moonbite = 25,
					Fragment = 50,
					Pearl = 75,
					["Lost Ruby"] = 5
				}
			},
			[2] = {
				Info = "+20k Health & 17.5% Fruit damage",
				InfoTH = "+20k พลังชีวิต & เพิ่มพลังผลไม้ 17.5%",
				Buff = {
					Health = { 20000, "Normal" },
					Damage = { 17.5, "Fruit" }
				},
				MaterialNeed = {
					Leather = 300,
					Lunafin = 75,
					Moonbite = 50,
					Fragment = 75,
					Pearl = 100,
					["Lost Ruby"] = 10
				}
			},
			[3] = {
				Info = "+27.5k Health & 20% Fruit damage",
				InfoTH = "+27.5k พลังชีวิต & เพิ่มพลังผลไม้ 20%",
				Buff = {
					Health = { 27500, "Normal" },
					Damage = { 20, "Fruit" }
				},
				MaterialNeed = {
					Leather = 500,
					Lunafin = 100,
					Moonbite = 75,
					Fragment = 100,
					Pearl = 125,
					["Lost Ruby"] = 25
				}
			}
		}
	},
	["Abyss Bunny Head"] = {
		Tier = "Limited",
		TierImage = "rbxassetid://131879367645344",
		Image = "rbxassetid://71434034187781",
		Info = "A mysterious bunny born from the abyss. Its gaze holds dark, overwhelming power.",
		InfoTH = "กระต่ายลึกลับจากห้วงอเวจี สายตาแฝงพลังมืดอันน่าหวาดหวั่น",
		Upgrade = {
			[0] = {
				Info = "+12.5% Fruit damage & Reduce damage received from All 10% & +10K Health",
				InfoTH = "เพิ่มพลังผลไม้ +12.5% & ลดการโจมตีทุกศาสตร์ 10% & +10k พลังชีวิต",
				Buff = {
					Damage = { 12.5, "Fruit" },
					Defense = { 10, "All" },
					Health = { 10000, "Normal" }
				}
			},
			[1] = {
				Info = "+15% Fruit damage & Reduce damage received from All 15% & +15K Health",
				InfoTH = "เพิ่มพลังผลไม้ +15% & ลดการโจมตีทุกศาสตร์ 15% & +15k พลังชีวิต",
				Buff = {
					Damage = { 15, "Fruit" },
					Defense = { 15, "All" },
					Health = { 15000, "Normal" }
				},
				MaterialNeed = {
					Leather = 300,
					Celestafin = 50,
					["Dragon Scale"] = 50,
					Obsidian = 25,
					["Void Core"] = 25,
					["Noir Pearl"] = 3
				}
			},
			[2] = {
				Info = "+20% Fruit damage & Reduce damage received from All 20% & +20K Health",
				InfoTH = "เพิ่มพลังผลไม้ +20% & ลดการโจมตีทุกศาสตร์ 20% & +20k พลังชีวิต",
				Buff = {
					Damage = { 20, "Fruit" },
					Defense = { 20, "All" },
					Health = { 20000, "Normal" }
				},
				MaterialNeed = {
					Leather = 500,
					Celestafin = 75,
					["Dragon Scale"] = 75,
					Obsidian = 40,
					["Void Core"] = 40,
					["Noir Pearl"] = 5
				}
			},
			[3] = {
				Info = "+27.5% Fruit damage & Reduce damage received from All 25% & +25K Health",
				InfoTH = "เพิ่มพลังผลไม้ +27.5% & ลดการโจมตีทุกศาสตร์ 25% & +25k พลังชีวิต",
				Buff = {
					Damage = { 27.5, "Fruit" },
					Defense = { 25, "All" },
					Health = { 25000, "Normal" }
				},
				MaterialNeed = {
					Leather = 750,
					Celestafin = 100,
					["Dragon Scale"] = 100,
					Obsidian = 50,
					["Void Core"] = 50,
					["Noir Pearl"] = 7
				}
			}
		}
	},
	["Samurai Hat"] = {
		Tier = "Epic",
		Image = "rbxassetid://120644843824768",
		Info = "The straw hat of a nameless samurai no one has ever seen his face.",
		InfoTH = "หมวกฟางของซามูไรไร้นาม ไม่เคยมีใครได้เห็นใบหน้าของเขา",
		Upgrade = {
			[0] = {
				Info = "+15% Sword damage & Reduce damage received from fruit 10%",
				InfoTH = "เพิ่มพลังโจมตีดาบ +15% & ลดการถูกโจมตีจากผลไม้ 10%",
				Buff = {
					Damage = { 15, "Sword" },
					Defense = { 10, "Fruit" }
				}
			},
			[1] = {
				Info = "+17.5% Sword damage & Reduce damage received from fruit 15%",
				InfoTH = "เพิ่มพลังโจมตีดาบ +17.5% & ลดการถูกโจมตีจากผลไม้ 15%",
				Buff = {
					Damage = { 17.5, "Sword" },
					Defense = { 15, "Fruit" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 300,
					["Pile of Bones"] = 225,
					["Iron Ingot"] = 100,
					Pearl = 50,
					["Samurai's Badage"] = 10
				}
			},
			[2] = {
				Info = "+20% Sword damage & Reduce damage received from fruit 20%",
				InfoTH = "เพิ่มพลังโจมตีดาบ +20% & ลดการถูกโจมตีจากผลไม้ 20%",
				Buff = {
					Damage = { 20, "Sword" },
					Defense = { 20, "Fruit" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 600,
					["Pile of Bones"] = 450,
					["Iron Ingot"] = 200,
					Pearl = 75,
					["Samurai's Badage"] = 15
				}
			},
			[3] = {
				Info = "+22.5% Sword damage & Reduce damage received from fruit 25%",
				InfoTH = "เพิ่มพลังโจมตีดาบ +22.5% & ลดการถูกโจมตีจากผลไม้ 25%",
				Buff = {
					Damage = { 22.5, "Sword" },
					Defense = { 25, "Fruit" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 1000,
					["Pile of Bones"] = 675,
					["Iron Ingot"] = 300,
					Pearl = 100,
					["Samurai's Badage"] = 25
				}
			}
		}
	},
	["Gold Serpent"] = {
		Tier = "Legendary",
		Image = "rbxassetid://106753033213024",
		Info = "A helm forged from the Gold Serpent’s fin, symbolizing oceanic power and prestige.",
		InfoTH = "หมวกเหล็กจากครีบ Gold Serpent สื่อถึงพลังและศักดิ์ศรีแห่งท้องทะเล",
		Upgrade = {
			[0] = {
				Info = "Reduces Serpent damage by 15% & +10% Health & +10 Run Speed",
				InfoTH = "ลดความเสียหายจากเซอร์เพนต์ 15% & เพิ่มพลังชีวิต +10% & เพิ่มความว่องไว +10",
				Buff = {
					Defense = { 15, "Serpent" },
					Health = { 10, "Extra" },
					Speed = 10
				}
			},
			[1] = {
				Info = "Reduces Serpent damage by 20% & +15% Health & +15 Run Speed",
				InfoTH = "ลดความเสียหายจากเซอร์เพนต์ 20% & เพิ่มพลังชีวิต +15% & เพิ่มความว่องไว +15",
				Buff = {
					Defense = { 20, "Serpent" },
					Health = { 15, "Extra" },
					Speed = 15
				},
				MaterialNeed = {
					["Fresh Fish"] = 250,
					Lunafin = 25,
					["Sea King's Blood"] = 10,
					["Serpent Fin"] = 3,
					["Hydra's Tail"] = 1
				}
			},
			[2] = {
				Info = "Reduces Serpent damage by 30% & +20% Health & +20 Run Speed",
				InfoTH = "ลดความเสียหายจากเซอร์เพนต์ 30% & เพิ่มพลังชีวิต +20% & เพิ่มความว่องไว +20",
				Buff = {
					Defense = { 30, "Serpent" },
					Health = { 20, "Extra" },
					Speed = 20
				},
				MaterialNeed = {
					["Fresh Fish"] = 500,
					Moonbite = 25,
					["Sea King's Blood"] = 15,
					["Serpent Fin"] = 6,
					Orca = 1
				}
			},
			[3] = {
				Info = "Reduces Serpent damage by 40% & +25% Health & +25 Run Speed",
				InfoTH = "ลดความเสียหายจากเซอร์เพนต์ 40% & เพิ่มพลังชีวิต +25% & เพิ่มความว่องไว +25",
				Buff = {
					Defense = { 40, "Serpent" },
					Health = { 25, "Extra" },
					Speed = 25
				},
				MaterialNeed = {
					["Fresh Fish"] = 500,
					Stormcatfish = 15,
					["Sea King's Blood"] = 20,
					["Serpent Fin"] = 6,
					["Sapphire Razer"] = 5,
					["Serpent Heart"] = 1
				}
			}
		},
		CraftList = {
			MaterialNeed = {
				["Rusted Scrap"] = 3000,
				["Iron Ingot"] = 1000,
				["Sea King's Blood"] = 25,
				["Sea King's Fin"] = 5,
				["Serpent Fin"] = 5,
				["Serpent Heart"] = 1
			},
			CraftWith = "Whirlseer"
		}
	},
	["Infernal Manehelm"] = {
		["Drop Boost"] = {
			Max = 1000
		},
		Tier = "Mythical",
		Image = "rbxassetid://115275501698372",
		Upgrade = {
			[0] = {
				Info = "+15% Sword damage & Reduce damage received from All 15% & +15K Health",
				InfoTH = "เพิ่มพลังโจมตีดาบ +15% & ลดการโจมตีทุกศาสตร์ 15% & +15K พลังชีวิต",
				Buff = {
					Damage = { 15, "Sword" },
					Defense = { 15, "All" },
					Health = { 15000, "Normal" }
				}
			},
			[1] = {
				Info = "+20% Sword damage & Reduce damage received from All 20% & +20K Health",
				InfoTH = "เพิ่มพลังโจมตีดาบ +20% & ลดการโจมตีทุกศาสตร์ 20% & +20K พลังชีวิต",
				Buff = {
					Damage = { 20, "Sword" },
					Defense = { 20, "All" },
					Health = { 20000, "Normal" }
				},
				MaterialNeed = {
					Crustar = 5,
					["Void Core"] = 5,
					Voltix = 5,
					["Iron Ingot"] = 100,
					["Dragon Scale"] = 15,
					["Samurai's Badage"] = 5
				}
			},
			[2] = {
				Info = "+22.5% Sword damage & Reduce damage received from All 22.5% & +22.5K Health",
				InfoTH = "เพิ่มพลังโจมตีดาบ +22.5% & ลดการโจมตีทุกศาสตร์ 22.5% & +22.5K พลังชีวิต",
				Buff = {
					Damage = { 22.5, "Sword" },
					Defense = { 22.5, "All" },
					Health = { 22500, "Normal" }
				},
				MaterialNeed = {
					Crustar = 10,
					["Void Core"] = 10,
					Voltix = 10,
					["Iron Ingot"] = 200,
					["Dragon Scale"] = 30,
					["Samurai's Badage"] = 10
				}
			},
			[3] = {
				Info = "+25% Sword damage & Reduce damage received from All 25% & +25K Health",
				InfoTH = "เพิ่มพลังโจมตีดาบ +25% & ลดการโจมตีทุกศาสตร์ 25% & +25K พลังชีวิต",
				Buff = {
					Damage = { 25, "Sword" },
					Defense = { 25, "All" },
					Health = { 25000, "Normal" }
				},
				MaterialNeed = {
					Crustar = 20,
					["Void Core"] = 20,
					Voltix = 20,
					["Iron Ingot"] = 300,
					["Crab Meat"] = 10,
					["Samurai's Badage"] = 10
				}
			}
		}
	},
	["Dragon Band"] = {
		Tier = "Legendary",
		Image = "rbxassetid://103862839399497",
		Upgrade = {
			[0] = {
				Info = "+10% Melee damage & Reduce damage received from All 5% ",
				InfoTH = "เพิ่มพลังโจมตีหมัด +10% & ลดการโจมตีทุกศาสตร์ 5%",
				Buff = {
					Damage = { 10, "Melee" },
					Defense = { 5, "All" }
				}
			},
			[1] = {
				Info = "+15% Melee damage & Reduce damage received from All 10% ",
				InfoTH = "เพิ่มพลังโจมตีหมัด +15% & ลดการโจมตีทุกศาสตร์ 10%",
				Buff = {
					Damage = { 15, "Melee" },
					Defense = { 10, "All" }
				},
				MaterialNeed = {
					Fragment = 25,
					Leather = 100,
					["Iron Ingot"] = 50,
					["Dragon Scale"] = 30,
					["Samurai's Badage"] = 5
				}
			},
			[2] = {
				Info = "+20% Melee damage & Reduce damage received from All 15% ",
				InfoTH = "เพิ่มพลังโจมตีหมัด +20% & ลดการโจมตีทุกศาสตร์ 15%",
				Buff = {
					Damage = { 20, "Melee" },
					Defense = { 15, "All" }
				},
				MaterialNeed = {
					Fragment = 50,
					Leather = 100,
					["Iron Ingot"] = 75,
					["Samurai's Badage"] = 7,
					["Dragon's Orb"] = 3
				}
			},
			[3] = {
				Info = "+25% Melee damage & Reduce damage received from All 20% ",
				InfoTH = "เพิ่มพลังโจมตีหมัด +25% & ลดการโจมตีทุกศาสตร์ 20%",
				Buff = {
					Damage = { 25, "Melee" },
					Defense = { 20, "All" }
				},
				MaterialNeed = {
					Fragment = 100,
					Leather = 100,
					["Iron Ingot"] = 100,
					["Samurai's Badage"] = 10,
					["Dragon Fang"] = 1
				}
			}
		}
	},
	Acromask = {
		["Drop Boost"] = {
			Max = 1000
		},
		Tier = "Mythical",
		Image = "rbxassetid://92981565784597",
		Upgrade = {
			[0] = {
				Info = "+25% Sword damage & Reduce damage received from All 7.5% ",
				InfoTH = "เพิ่มพลังโจมตีดาบ +25% & ลดการโจมตีทุกศาสตร์ 7.5%",
				Buff = {
					Damage = { 25, "Sword" },
					Defense = { 7.5, "All" }
				}
			},
			[1] = {
				Info = "+30% Sword damage & Reduce damage received from All 15% ",
				InfoTH = "เพิ่มพลังโจมตีดาบ +30% & ลดการโจมตีทุกศาสตร์ 15%",
				Buff = {
					Damage = { 30, "Sword" },
					Defense = { 15, "All" }
				},
				MaterialNeed = {
					["Eye of Acro"] = 8,
					["Dragon Scale"] = 125,
					["Void Core"] = 20
				}
			},
			[2] = {
				Info = "+35% Sword damage & Reduce damage received from All 20% & +10K Health",
				InfoTH = "เพิ่มพลังโจมตีดาบ +35% & ลดการโจมตีทุกศาสตร์ 20% & +10K พลังชีวิต",
				Buff = {
					Damage = { 35, "Sword" },
					Health = { 10000, "Normal" },
					Defense = { 20, "All" }
				},
				MaterialNeed = {
					["Eye of Acro"] = 12,
					["Hydra's Tail"] = 25,
					["Serpent Fin"] = 25,
					["Dragon Scale"] = 250,
					["Void Core"] = 30,
					Voltix = 20
				}
			},
			[3] = {
				Info = "+35% Sword damage & Reduce damage received from All 20% & +12.5K Health & Acropurged Passive",
				InfoTH = "เพิ่มพลังโจมตีดาบ +35% & ลดการโจมตีทุกศาสตร์ 20% & +12.5K พลังชีวิต & Acropurged Passive",
				Buff = {
					Damage = { 40, "Sword" },
					Defense = { 25, "All" },
					Health = { 12500, "Normal" },
					Passives = { "Acropurged" }
				},
				MaterialNeed = {
					["Eye of Acro"] = 15,
					["Serpent Fin"] = 75,
					["Serpent Heart"] = 3,
					["Phoenix's Tear"] = 12
				}
			}
		}
	},
	["Night Necklace"] = {
		Tier = "Legendary",
		Image = "rbxassetid://7518840280",
		Upgrade = {
			[0] = {
				Info = "+10% Sword damage & Reduce damage received from Sword 5% ",
				InfoTH = "เพิ่มพลังโจมตีดาบ +10% & ลดการถูกโจมตีด้วยดาบ 5%",
				Buff = {
					Damage = { 10, "Sword" },
					Defense = { 5, "Sword" }
				}
			},
			[1] = {
				Info = "+15% Sword damage & Reduce damage received from Sword 20% ",
				InfoTH = "เพิ่มพลังโจมตีดาบ +15% & ลดการถูกโจมตีด้วยดาบ 20%",
				Buff = {
					Damage = { 15, "Sword" },
					Defense = { 20, "Sword" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 100,
					Leather = 100,
					["Iron Ingot"] = 50,
					["Samurai's Badage"] = 7,
					["Phoenix's Tear"] = 1
				}
			},
			[2] = {
				Info = "+16% Sword damage & Reduce damage received from Sword 21% ",
				InfoTH = "เพิ่มพลังโจมตีดาบ +16% & ลดการถูกโจมตีด้วยดาบ 21%",
				Buff = {
					Damage = { 16, "Sword" },
					Defense = { 21, "Sword" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 100,
					Leather = 100,
					["Iron Ingot"] = 50,
					["Samurai's Badage"] = 7,
					["Phoenix's Tear"] = 1
				}
			},
			[3] = {
				Info = "+17% Sword damage & Reduce damage received from Sword 22% ",
				InfoTH = "เพิ่มพลังโจมตีดาบ +17% & ลดการถูกโจมตีด้วยดาบ 22%",
				Buff = {
					Damage = { 17, "Sword" },
					Defense = { 22, "Sword" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 100,
					Leather = 100,
					["Iron Ingot"] = 50,
					["Samurai's Badage"] = 7,
					["Phoenix's Tear"] = 1
				}
			}
		}
	},
	["EXP Crown"] = {
		Tier = "Limited",
		Image = "rbxassetid://15176556869",
		TierImage = "rbxassetid://17583659411",
		Upgrade = {
			[0] = {
				Info = "+20% EXP",
				InfoTH = "+20% ค่าประสบการณ์",
				Buff = {
					EXP = 20
				}
			},
			[1] = {
				Info = "+35% EXP",
				InfoTH = "+35% ค่าประสบการณ์",
				Buff = {
					EXP = 35
				},
				MaterialNeed = {
					["Angellic's Feather"] = 75
				}
			},
			[2] = {
				Info = "+40% EXP",
				InfoTH = "+35% ค่าประสบการณ์",
				Buff = {
					EXP = 40
				},
				MaterialNeed = {
					["Angellic's Feather"] = 150
				}
			},
			[3] = {
				Info = "+45% EXP",
				InfoTH = "+45% ค่าประสบการณ์",
				Buff = {
					EXP = 45
				},
				MaterialNeed = {
					["Angellic's Feather"] = 225
				}
			}
		}
	},
	["Shoulder Armor"] = {
		Tier = "Uncommon",
		Image = "rbxassetid://7518841831",
		Upgrade = {
			[0] = {
				Info = "+1% Health & 2% Melee damage",
				InfoTH = "เพิ่มพลังชีวิต +1% & เพิ่มพลังโจมตีหมัด 2% ",
				Buff = {
					Health = { 1, "Extra" },
					Damage = { 2, "Melee" }
				}
			},
			[1] = {
				Info = "+2% Health & 4% Melee damage",
				InfoTH = "เพิ่มพลังชีวิต +2% & เพิ่มพลังโจมตีหมัด 4% ",
				Buff = {
					Health = { 2, "Extra" },
					Damage = { 4, "Melee" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 28,
					["Iron Ingot"] = 12
				}
			},
			[2] = {
				Info = "+3% Health & 5% Melee damage",
				InfoTH = "เพิ่มพลังชีวิต +3% & เพิ่มพลังโจมตีหมัด 5% ",
				Buff = {
					Health = { 3, "Extra" },
					Damage = { 5, "Melee" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 28,
					["Iron Ingot"] = 12
				}
			},
			[3] = {
				Info = "+4% Health & 6% Melee damage",
				InfoTH = "เพิ่มพลังชีวิต +4% & เพิ่มพลังโจมตีหมัด 6% ",
				Buff = {
					Health = { 4, "Extra" },
					Damage = { 6, "Melee" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 28,
					["Iron Ingot"] = 12
				}
			}
		}
	},
	["Blue Straw Hat"] = {
		Tier = "Common",
		Image = "rbxassetid://7518838900",
		Upgrade = {
			[0] = {
				Info = "+100 Health & 3% Fruit damage",
				InfoTH = "+100 พลังชีวิต & เพิ่มพลังผลไม้ 3%",
				Buff = {
					Health = { 100, "Normal" },
					Damage = { 3, "Fruit" }
				}
			},
			[1] = {
				Info = "+150 Health & 5% Fruit damage",
				InfoTH = "+150 พลังชีวิต & เพิ่มพลังผลไม้ 5%",
				Buff = {
					Health = { 150, "Normal" },
					Damage = { 5, "Fruit" }
				},
				MaterialNeed = {
					Leather = 33
				}
			},
			[2] = {
				Info = "+200 Health & 6% Fruit damage",
				InfoTH = "+200 พลังชีวิต & เพิ่มพลังผลไม้ 6%",
				Buff = {
					Health = { 200, "Normal" },
					Damage = { 6, "Fruit" }
				},
				MaterialNeed = {
					Leather = 35
				}
			},
			[3] = {
				Info = "+250 Health & 7% Fruit damage",
				InfoTH = "+250 พลังชีวิต & เพิ่มพลังผลไม้ 7%",
				Buff = {
					Health = { 250, "Normal" },
					Damage = { 7, "Fruit" }
				},
				MaterialNeed = {
					Leather = 40
				}
			}
		}
	},
	["Gladiator Helmet"] = {
		Tier = "Rare",
		Image = "rbxassetid://7518839497",
		Upgrade = {
			[0] = {
				Info = "+ 4% Melee damage & Reduce damage received from Melee 5%",
				InfoTH = "เพิ่มพลังโจมตีหมัด +4% & ลดการถูกโจมตีจากหมัด 5%",
				Buff = {
					Defense = { 5, "Melee" },
					Damage = { 4, "Melee" }
				}
			},
			[1] = {
				Info = "+ 8% Melee damage & Reduce damage received from Melee 10%",
				InfoTH = "เพิ่มพลังโจมตีหมัด +8% & ลดการถูกโจมตีจากหมัด 10%",
				Buff = {
					Defense = { 10, "Melee" },
					Damage = { 8, "Melee" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 50,
					["Iron Ingot"] = 8
				}
			},
			[2] = {
				Info = "+ 9% Melee damage & Reduce damage received from Melee 11%",
				InfoTH = "เพิ่มพลังโจมตีหมัด +9% & ลดการถูกโจมตีจากหมัด 11%",
				Buff = {
					Defense = { 11, "Melee" },
					Damage = { 9, "Melee" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 50,
					["Iron Ingot"] = 8
				}
			},
			[3] = {
				Info = "+ 10% Melee damage & Reduce damage received from Melee 12%",
				InfoTH = "เพิ่มพลังโจมตีหมัด +10% & ลดการถูกโจมตีจากหมัด 12%",
				Buff = {
					Defense = { 12, "Melee" },
					Damage = { 10, "Melee" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 50,
					["Iron Ingot"] = 8
				}
			}
		}
	},
	["Bear Hat"] = {
		Tier = "Rare",
		Image = "http://www.roblox.com/asset/?id=13325741645",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from Melee 15%",
				InfoTH = "ลดการถูกโจมตีจากหมัด 15%",
				Buff = {
					Defense = { 15, "Melee" }
				}
			},
			[1] = {
				Info = "Reduce damage received from Melee 20%",
				InfoTH = "ลดการถูกโจมตีจากหมัด 20%",
				Buff = {
					Defense = { 20, "Melee" }
				},
				MaterialNeed = {
					Leather = 100
				}
			},
			[2] = {
				Info = "Reduce damage received from Melee 21%",
				InfoTH = "ลดการถูกโจมตีจากหมัด 21%",
				Buff = {
					Defense = { 21, "Melee" }
				},
				MaterialNeed = {
					Leather = 100
				}
			},
			[3] = {
				Info = "Reduce damage received from Melee 22%",
				InfoTH = "ลดการถูกโจมตีจากหมัด 22%",
				Buff = {
					Defense = { 22, "Melee" }
				},
				MaterialNeed = {
					Leather = 100
				}
			}
		}
	},
	["Shimenawa Belt"] = {
		Tier = "Epic",
		Image = "http://www.roblox.com/asset/?id=13325743005",
		Upgrade = {
			[0] = {
				Info = "+15% Sword damage",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +15%",
				Buff = {
					Damage = { 15, "Sword" }
				}
			},
			[1] = {
				Info = "+20% Sword damage",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +20%",
				Buff = {
					Damage = { 20, "Sword" }
				},
				MaterialNeed = {
					Leather = 125,
					["Thief's rag"] = 25,
					["Sea's Wraith"] = 1
				}
			},
			[2] = {
				Info = "+21% Sword damage",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +21%",
				Buff = {
					Damage = { 21, "Sword" }
				},
				MaterialNeed = {
					Leather = 125,
					["Thief's rag"] = 25,
					["Sea's Wraith"] = 1
				}
			},
			[3] = {
				Info = "+22% Sword damage",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +22%",
				Buff = {
					Damage = { 22, "Sword" }
				},
				MaterialNeed = {
					Leather = 125,
					["Thief's rag"] = 25,
					["Sea's Wraith"] = 1
				}
			}
		}
	},
	["Guardian Raven Chestpiece"] = {
		Tier = "Exotic",
		Image = "rbxassetid://7003983449",
		Upgrade = {
			[0] = {
				Info = "+20% All Damage + 3M Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +20% & เพิ่มพลังชีวิต 3 ล้าน",
				Buff = {
					Health = { 3000000, "Normal" },
					Damage = { 20, "All" }
				}
			},
			[1] = {
				Info = "+25% All Damage + 4M Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +25% & เพิ่มพลังชีวิต 4 ล้าน",
				Buff = {
					Health = { 4000000, "Normal" },
					Damage = { 25, "All" }
				},
				MaterialNeed = {
					Log = 100000
				}
			},
			[2] = {
				Info = "+26% All Damage + 5M Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +25% & เพิ่มพลังชีวิต 5 ล้าน",
				Buff = {
					Health = { 5000000, "Normal" },
					Damage = { 26, "All" }
				},
				MaterialNeed = {
					Log = 100000
				}
			},
			[3] = {
				Info = "+27% All Damage + 6M Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +25% & เพิ่มพลังชีวิต 6 ล้าน",
				Buff = {
					Health = { 6000000, "Normal" },
					Damage = { 27, "All" }
				},
				MaterialNeed = {
					Log = 100000
				}
			}
		}
	},
	["Big Floppa"] = {
		Tier = "Exotic",
		Image = "rbxassetid://9728059752",
		Upgrade = {
			[0] = {
				Info = "+1000% All Damage & +1M Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +1000% พร้อม 1 ล้านพลังชีวิต",
				Buff = {
					Health = { 1000000, "Normal" },
					Damage = { 1000, "All" }
				}
			},
			[1] = {
				Info = "+1100% All Damage & +1M Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +1100% พร้อม 1 ล้านพลังชีวิต",
				Buff = {
					Health = { 1000000, "Normal" },
					Damage = { 1100, "All" }
				},
				MaterialNeed = {
					Log = 100000
				}
			},
			[2] = {
				Info = "+1200% All Damage & +1M Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +1200% พร้อม 1 ล้านพลังชีวิต",
				Buff = {
					Health = { 1000000, "Normal" },
					Damage = { 1200, "All" }
				},
				MaterialNeed = {
					Log = 100000
				}
			},
			[3] = {
				Info = "+1300% All Damage & +1M Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +1300% พร้อม 1 ล้านพลังชีวิต",
				Buff = {
					Health = { 1000000, "Normal" },
					Damage = { 1100, "All" }
				},
				MaterialNeed = {
					Log = 100000
				}
			}
		}
	},
	["Dark Floppa"] = {
		Tier = "Exotic",
		Image = "rbxassetid://9728059752",
		Upgrade = {
			[0] = {
				Info = "+1000000% All Damage & God Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +999K% พร้อมโลหิตของพระเจ้า",
				Buff = {
					Health = { 100000000000000, "Extra" },
					Damage = { 1000000, "All" },
					Regen = {
						Percentage = 2,
						Rate = 10
					}
				}
			},
			[1] = {
				Info = "+1M% All Damage & God Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +1M% พร้อมโลหิตของพระเจ้า",
				Buff = {
					Health = { 100000000000000, "Extra" },
					Damage = { 1000000, "All" },
					Regen = {
						Percentage = 2,
						Rate = 10
					}
				},
				MaterialNeed = {
					Log = 100000
				}
			},
			[2] = {
				Info = "+2M% All Damage & God Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +2M% พร้อมโลหิตของพระเจ้า",
				Buff = {
					Health = { 100000000000000, "Extra" },
					Damage = { 2000000, "All" },
					Regen = {
						Percentage = 3,
						Rate = 10
					}
				},
				MaterialNeed = {
					Log = 100000
				}
			},
			[3] = {
				Info = "+3M% All Damage & God Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +3M% พร้อมโลหิตของพระเจ้า",
				Buff = {
					Health = { 100000000000000, "Extra" },
					Damage = { 3000000, "All" },
					Regen = {
						Percentage = 4,
						Rate = 10
					}
				},
				MaterialNeed = {
					Log = 100000
				}
			}
		}
	},
	Lannis = {
		Tier = "Exotic",
		Image = "rbxassetid://6710041075",
		Upgrade = {
			[0] = {
				Info = "+10M Health",
				InfoTH = "เพิ่มพลังชีวิต +10 ล้าน",
				Buff = {
					Health = { 10000000, "Normal" }
				}
			},
			[1] = {
				Info = "+20M Health",
				InfoTH = "เพิ่มพลังชีวิต +20 ล้าน",
				Buff = {
					Health = { 20000000, "Normal" }
				},
				MaterialNeed = {
					Log = 100000
				}
			}
		}
	},
	["Red Cloak"] = {
		Tier = "Uncommon",
		Image = "rbxassetid://7518841432",
		Upgrade = {
			[0] = {
				Info = "+250 Health & +1% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +250 & เพิ่มพลังทุกศาสตร์ +1%",
				Buff = {
					Health = { 250, "Normal" },
					Damage = { 1, "All" }
				}
			},
			[1] = {
				Info = "+300 Health & +2% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +300 & เพิ่มพลังทุกศาสตร์ +2%",
				Buff = {
					Health = { 300, "Normal" },
					Damage = { 2, "All" }
				},
				MaterialNeed = {
					Leather = 75
				}
			},
			[2] = {
				Info = "+400 Health & +3% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +400 & เพิ่มพลังทุกศาสตร์ +3%",
				Buff = {
					Health = { 400, "Normal" },
					Damage = { 3, "All" }
				},
				MaterialNeed = {
					Leather = 75
				}
			},
			[3] = {
				Info = "+500 Health & +4% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +500 & เพิ่มพลังทุกศาสตร์ +4%",
				Buff = {
					Health = { 500, "Normal" },
					Damage = { 4, "All" }
				},
				MaterialNeed = {
					Leather = 75
				}
			}
		}
	},
	["Green Cloak"] = {
		Tier = "Uncommon",
		Image = "rbxassetid://7518839919",
		Upgrade = {
			[0] = {
				Info = "+250 Health & +1% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +250 & เพิ่มพลังทุกศาสตร์ +1%",
				Buff = {
					Health = { 250, "Normal" },
					Damage = { 1, "All" }
				}
			},
			[1] = {
				Info = "+325 Health & +2% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +325 & เพิ่มพลังทุกศาสตร์ +2%",
				Buff = {
					Health = { 325, "Normal" },
					Damage = { 2, "All" }
				},
				MaterialNeed = {
					Leather = 75
				}
			},
			[2] = {
				Info = "+425 Health & +3% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +425 & เพิ่มพลังทุกศาสตร์ +3%",
				Buff = {
					Health = { 425, "Normal" },
					Damage = { 3, "All" }
				},
				MaterialNeed = {
					Leather = 75
				}
			},
			[3] = {
				Info = "+525Health & +4% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +525 & เพิ่มพลังทุกศาสตร์ +4%",
				Buff = {
					Health = { 525, "Normal" },
					Damage = { 4, "All" }
				},
				MaterialNeed = {
					Leather = 75
				}
			}
		}
	},
	["Blue Cloak"] = {
		Tier = "Uncommon",
		Image = "rbxassetid://7518838481",
		Upgrade = {
			[0] = {
				Info = "+250 Health & +1% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +250 & เพิ่มพลังทุกศาสตร์ +1%",
				Buff = {
					Health = { 250, "Normal" },
					Damage = { 1, "All" }
				}
			},
			[1] = {
				Info = "+350 Health & +2% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +350 & เพิ่มพลังทุกศาสตร์ +2%",
				Buff = {
					Health = { 350, "Normal" },
					Damage = { 2, "All" }
				},
				MaterialNeed = {
					Leather = 75
				}
			},
			[2] = {
				Info = "+450 Health & +3% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +450 & เพิ่มพลังทุกศาสตร์ +3%",
				Buff = {
					Health = { 450, "Normal" },
					Damage = { 3, "All" }
				},
				MaterialNeed = {
					Leather = 75
				}
			},
			[3] = {
				Info = "+550 Health & +4% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +550 & เพิ่มพลังทุกศาสตร์ +4%",
				Buff = {
					Health = { 550, "Normal" },
					Damage = { 4, "All" }
				},
				MaterialNeed = {
					Leather = 75
				}
			}
		}
	},
	["Black Cloak"] = {
		Tier = "Uncommon",
		Image = "rbxassetid://7518837856",
		Upgrade = {
			[0] = {
				Info = "+250 Health & +1% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +250 & เพิ่มพลังทุกศาสตร์ +1%",
				Buff = {
					Health = { 250, "Normal" },
					Damage = { 1, "All" }
				}
			},
			[1] = {
				Info = "+375 Health & +2% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +375 & เพิ่มพลังทุกศาสตร์ +2%",
				Buff = {
					Health = { 375, "Normal" },
					Damage = { 2, "All" }
				},
				MaterialNeed = {
					Leather = 150
				}
			},
			[2] = {
				Info = "+475 Health & +3% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +475 & เพิ่มพลังทุกศาสตร์ +3%",
				Buff = {
					Health = { 475, "Normal" },
					Damage = { 3, "All" }
				},
				MaterialNeed = {
					Leather = 75
				}
			},
			[3] = {
				Info = "+575 Health & +4% All Damage",
				InfoTH = "เพิ่มพลังชีวิต +575 & เพิ่มพลังทุกศาสตร์ +4%",
				Buff = {
					Health = { 575, "Normal" },
					Damage = { 4, "All" }
				},
				MaterialNeed = {
					Leather = 75
				}
			}
		}
	},
	["Traveler's Hat"] = {
		Tier = "Uncommon",
		Image = "http://www.roblox.com/asset/?id=13267613471",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from All 2%",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 2%",
				Buff = {
					Defense = { 2, "All" }
				}
			},
			[1] = {
				Info = "Reduce damage received from All 5%",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 5%",
				Buff = {
					Defense = { 5, "All" }
				},
				MaterialNeed = {
					Leather = 45,
					["Iron Ingot"] = 15
				}
			},
			[2] = {
				Info = "Reduce damage received from All 6%",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 6%",
				Buff = {
					Defense = { 6, "All" }
				},
				MaterialNeed = {
					Leather = 45,
					["Iron Ingot"] = 15
				}
			},
			[3] = {
				Info = "Reduce damage received from All 7%",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 7%",
				Buff = {
					Defense = { 7, "All" }
				},
				MaterialNeed = {
					Leather = 45,
					["Iron Ingot"] = 15
				}
			}
		}
	},
	["Cyborg Goggles"] = {
		Tier = "Uncommon",
		Image = "http://www.roblox.com/asset/?id=13267614234",
		Upgrade = {
			[0] = {
				Info = "+2% Health",
				InfoTH = "เพิ่มพลังชีวิต +2%",
				Buff = {
					Health = { 2, "Extra" }
				}
			},
			[1] = {
				Info = "+5% Health",
				InfoTH = "เพิ่มพลังชีวิต +5%",
				Buff = {
					Health = { 5, "Extra" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 35,
					["Iron Ingot"] = 5
				}
			},
			[2] = {
				Info = "+6% Health",
				InfoTH = "เพิ่มพลังชีวิต +6%",
				Buff = {
					Health = { 6, "Extra" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 35,
					["Iron Ingot"] = 5
				}
			},
			[3] = {
				Info = "+7% Health",
				InfoTH = "เพิ่มพลังชีวิต +7%",
				Buff = {
					Health = { 7, "Extra" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 35,
					["Iron Ingot"] = 5
				}
			}
		}
	},
	["Blue Admiral Coat"] = {
		Tier = "Epic",
		Image = "rbxassetid://7518838173",
		Upgrade = {
			[0] = {
				Info = "+5% Health & Reduce damage received from All 5%",
				InfoTH = "เพิ่มพลังชีวิต +5% & ลดการโจมตีทุกศาสตร์ 5%",
				Buff = {
					Health = { 5, "Extra" },
					Defense = { 5, "All" }
				}
			},
			[1] = {
				Info = "+10% Health & Reduce damage received from All 10%",
				InfoTH = "เพิ่มพลังชีวิต +10% & ลดการโจมตีทุกศาสตร์ 10%",
				Buff = {
					Health = { 10, "Extra" },
					Defense = { 10, "All" }
				},
				MaterialNeed = {
					Leather = 50,
					["Thief's rag"] = 5,
					["Vampire's Vital fluid"] = 3
				}
			},
			[2] = {
				Info = "+11% Health & Reduce damage received from All 11%",
				InfoTH = "เพิ่มพลังชีวิต +11% & ลดการโจมตีทุกศาสตร์ 11%",
				Buff = {
					Health = { 11, "Extra" },
					Defense = { 11, "All" }
				},
				MaterialNeed = {
					Leather = 50,
					["Thief's rag"] = 5,
					["Vampire's Vital fluid"] = 3
				}
			},
			[3] = {
				Info = "+12% Health & Reduce damage received from All 12%",
				InfoTH = "เพิ่มพลังชีวิต +12% & ลดการโจมตีทุกศาสตร์ 12%",
				Buff = {
					Health = { 12, "Extra" },
					Defense = { 12, "All" }
				},
				MaterialNeed = {
					Leather = 50,
					["Thief's rag"] = 5,
					["Vampire's Vital fluid"] = 3
				}
			}
		}
	},
	["Crown Of The Sea"] = {
		Tier = "Epic",
		Image = "http://www.roblox.com/asset/?id=13267610070",
		Upgrade = {
			[0] = {
				Info = "+10% Health & +5% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +10% เเละ เพิ่มพลังผลไม้ +5%",
				Buff = {
					Health = { 10, "Extra" },
					Damage = { 5, "Fruit" }
				}
			},
			[1] = {
				Info = "+15% Health & +10% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +15% เเละ เพิ่มพลังผลไม้ +10%",
				Buff = {
					Health = { 15, "Extra" },
					Damage = { 10, "Fruit" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 75,
					["Dragon Scale"] = 7,
					["Lost Ruby"] = 2,
					["Sea King's Fin"] = 1
				}
			},
			[2] = {
				Info = "+16% Health & +11% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +16% เเละ เพิ่มพลังผลไม้ +11%",
				Buff = {
					Health = { 16, "Extra" },
					Damage = { 11, "Fruit" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 75,
					["Dragon Scale"] = 7,
					["Lost Ruby"] = 2,
					["Sea King's Fin"] = 1
				}
			},
			[3] = {
				Info = "+17% Health & +12% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +17% เเละ เพิ่มพลังผลไม้ +12%",
				Buff = {
					Health = { 17, "Extra" },
					Damage = { 12, "Fruit" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 75,
					["Dragon Scale"] = 7,
					["Lost Ruby"] = 2,
					["Sea King's Fin"] = 1
				}
			}
		}
	},
	["Straw Helmet"] = {
		Tier = "Epic",
		Image = "http://www.roblox.com/asset/?id=13267612345",
		Upgrade = {
			[0] = {
				Info = "+15% Fruit damage & +1% Health",
				InfoTH = "เพิ่มพลังผลไม้ +15% & เพิ่มพลังชีวิต +1%",
				Buff = {
					Health = { 1, "Extra" },
					Damage = { 15, "Fruit" }
				}
			},
			[1] = {
				Info = "+20% Fruit damage & +2% Health",
				InfoTH = "เพิ่มพลังผลไม้ +20% & เพิ่มพลังชีวิต +2%",
				Buff = {
					Health = { 2, "Extra" },
					Damage = { 20, "Fruit" }
				},
				MaterialNeed = {
					["Thief's rag"] = 15,
					["Samurai's Badage"] = 7,
					["Hydra's Tail"] = 1
				}
			},
			[2] = {
				Info = "+21% Fruit damage & +3% Health",
				InfoTH = "เพิ่มพลังผลไม้ +21% & เพิ่มพลังชีวิต +3%",
				Buff = {
					Health = { 3, "Extra" },
					Damage = { 21, "Fruit" }
				},
				MaterialNeed = {
					["Thief's rag"] = 15,
					["Samurai's Badage"] = 7,
					["Hydra's Tail"] = 1
				}
			},
			[3] = {
				Info = "+22% Fruit damage & +4% Health",
				InfoTH = "เพิ่มพลังผลไม้ +22% & เพิ่มพลังชีวิต +4%",
				Buff = {
					Health = { 4, "Extra" },
					Damage = { 22, "Fruit" }
				},
				MaterialNeed = {
					["Thief's rag"] = 15,
					["Samurai's Badage"] = 7,
					["Hydra's Tail"] = 1
				}
			}
		}
	},
	["Prestige Dagger"] = {
		Tier = "Legendary",
		Image = "http://www.roblox.com/asset/?id=13270520112",
		Upgrade = {
			[0] = {
				Info = "+15% Sword damage & +5% Health",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +15% & เพิ่มพลังชีวิต +5%",
				Buff = {
					Health = { 5, "Extra" },
					Damage = { 15, "Sword" }
				}
			},
			[1] = {
				Info = "+20% Sword damage & +10% Health",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +20% & เพิ่มพลังชีวิต +10%",
				Buff = {
					Health = { 10, "Extra" },
					Damage = { 20, "Sword" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 50,
					["Samurai's Badage"] = 5,
					["Essence of Fire"] = 3,
					["Phoenix's Tear"] = 1,
					["Hydra's Tail"] = 1
				}
			},
			[2] = {
				Info = "+21% Sword damage & +11% Health",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +21% & เพิ่มพลังชีวิต +11%",
				Buff = {
					Health = { 11, "Extra" },
					Damage = { 21, "Sword" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 50,
					["Samurai's Badage"] = 5,
					["Essence of Fire"] = 3,
					["Phoenix's Tear"] = 1,
					["Hydra's Tail"] = 1
				}
			},
			[3] = {
				Info = "+22% Sword damage & +12% Health",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +22% & เพิ่มพลังชีวิต +12%",
				Buff = {
					Health = { 12, "Extra" },
					Damage = { 22, "Sword" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 50,
					["Samurai's Badage"] = 5,
					["Essence of Fire"] = 3,
					["Phoenix's Tear"] = 1,
					["Hydra's Tail"] = 1
				}
			}
		}
	},
	["Water Kimono"] = {
		Tier = "Epic",
		Image = "http://www.roblox.com/asset/?id=16609959915",
		Upgrade = {
			[0] = {
				Info = "+10% Sword damage & Reduce damage received from All 4%",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +10% & ลดการโจมตีทุกศาสตร์ 4%",
				Buff = {
					Defense = { 4, "All" },
					Damage = { 10, "Sword" }
				}
			},
			[1] = {
				Info = "+15% Sword damage & Reduce damage received from All 8%",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +15% & ลดการโจมตีทุกศาสตร์ 8%",
				Buff = {
					Defense = { 8, "All" },
					Damage = { 15, "Sword" }
				},
				MaterialNeed = {
					Leather = 50,
					["Samurai's Badage"] = 3
				}
			},
			[2] = {
				Info = "+16% Sword damage & Reduce damage received from All 9%",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +16% & ลดการโจมตีทุกศาสตร์ 9%",
				Buff = {
					Defense = { 9, "All" },
					Damage = { 16, "Sword" }
				},
				MaterialNeed = {
					Leather = 50,
					["Samurai's Badage"] = 3
				}
			},
			[3] = {
				Info = "+17% Sword damage & Reduce damage received from All 10%",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +17% & ลดการโจมตีทุกศาสตร์ 10%",
				Buff = {
					Defense = { 10, "All" },
					Damage = { 17, "Sword" }
				},
				MaterialNeed = {
					Leather = 50,
					["Samurai's Badage"] = 3
				}
			}
		}
	},
	["Golden Shoulder"] = {
		Tier = "Uncommon",
		Image = "http://www.roblox.com/asset/?id=13270518540",
		Upgrade = {
			[0] = {
				Info = "+5% Health & Reduce damage received from All 5%",
				InfoTH = "เพิ่มพลังชีวิต +5% & ลดการโจมตีทุกศาสตร์ 5%",
				Buff = {
					Health = { 5, "Extra" },
					Defense = { 5, "All" }
				}
			},
			[1] = {
				Info = "+10% Health & Reduce damage received from All 10%",
				InfoTH = "เพิ่มพลังชีวิต +10% & ลดการโจมตีทุกศาสตร์ 10%",
				Buff = {
					Health = { 10, "Extra" },
					Defense = { 10, "All" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 88,
					["Dragon Scale"] = 11,
					["Sea King's Fin"] = 1
				}
			},
			[2] = {
				Info = "+11% Health & Reduce damage received from All 11%",
				InfoTH = "เพิ่มพลังชีวิต +11% & ลดการโจมตีทุกศาสตร์ 11%",
				Buff = {
					Health = { 11, "Extra" },
					Defense = { 11, "All" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 88,
					["Dragon Scale"] = 11,
					["Sea King's Fin"] = 1
				}
			},
			[3] = {
				Info = "+12% Health & Reduce damage received from All 12%",
				InfoTH = "เพิ่มพลังชีวิต +12% & ลดการโจมตีทุกศาสตร์ 12%",
				Buff = {
					Health = { 12, "Extra" },
					Defense = { 12, "All" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 88,
					["Dragon Scale"] = 11,
					["Sea King's Fin"] = 1
				}
			}
		}
	},
	["Iratus Mask"] = {
		Tier = "Epic",
		Image = "http://www.roblox.com/asset/?id=13270519381",
		Upgrade = {
			[0] = {
				Info = "+15% Health & Reduce damage received from All 5%",
				InfoTH = "เพิ่มพลังชีวิต +15% & ลดการโจมตีทุกศาสตร์ 5%",
				Buff = {
					Health = { 15, "Extra" },
					Defense = { 5, "All" }
				}
			},
			[1] = {
				Info = "+20% Health & Reduce damage received from All 10%",
				InfoTH = "เพิ่มพลังชีวิต +20% & ลดการโจมตีทุกศาสตร์ 10%",
				Buff = {
					Health = { 20, "Extra" },
					Defense = { 10, "All" }
				},
				MaterialNeed = {
					Leather = 50,
					["Dragon Scale"] = 6,
					["Sea King's Fin"] = 2
				}
			},
			[2] = {
				Info = "+21% Health & Reduce damage received from All 11%",
				InfoTH = "เพิ่มพลังชีวิต +21% & ลดการโจมตีทุกศาสตร์ 11%",
				Buff = {
					Health = { 21, "Extra" },
					Defense = { 11, "All" }
				},
				MaterialNeed = {
					Leather = 50,
					["Dragon Scale"] = 6,
					["Sea King's Fin"] = 2
				}
			},
			[3] = {
				Info = "+22% Health & Reduce damage received from All 12%",
				InfoTH = "เพิ่มพลังชีวิต +22% & ลดการโจมตีทุกศาสตร์ 12%",
				Buff = {
					Health = { 22, "Extra" },
					Defense = { 12, "All" }
				},
				MaterialNeed = {
					Leather = 50,
					["Dragon Scale"] = 6,
					["Sea King's Fin"] = 2
				}
			}
		}
	},
	["Flame Hair"] = {
		Tier = "Epic",
		Image = "rbxassetid://7529098268",
		Upgrade = {
			[0] = {
				Info = "+5% Fruit damage & Reduce damage received from All 5%",
				InfoTH = "เพิ่มพลังผลไม้ 5% & ลดการถูกโจมตีจากผลไม้ 5%",
				Buff = {
					Damage = { 5, "Fruit" },
					Defense = { 5, "All" }
				}
			},
			[1] = {
				Info = "+10% Fruit damage & Reduce damage received from All 10%",
				InfoTH = "เพิ่มพลังผลไม้ 10% & ลดการถูกโจมตีจากผลไม้ 10%",
				Buff = {
					Damage = { 10, "Fruit" },
					Defense = { 10, "All" }
				},
				MaterialNeed = {
					["Angellic's Feather"] = 80,
					["Undead's Ooze"] = 75,
					["Essence of Fire"] = 3
				}
			},
			[2] = {
				Info = "+11% Fruit damage & Reduce damage received from All 11%",
				InfoTH = "เพิ่มพลังผลไม้ 10% & ลดการถูกโจมตีจากผลไม้ 11%",
				Buff = {
					Damage = { 11, "Fruit" },
					Defense = { 11, "All" }
				},
				MaterialNeed = {
					["Angellic's Feather"] = 80,
					["Undead's Ooze"] = 75,
					["Essence of Fire"] = 3
				}
			},
			[3] = {
				Info = "+12% Fruit damage & Reduce damage received from All 12%",
				InfoTH = "เพิ่มพลังผลไม้ 12% & ลดการถูกโจมตีจากผลไม้ 12%",
				Buff = {
					Damage = { 12, "Fruit" },
					Defense = { 12, "All" }
				},
				MaterialNeed = {
					["Angellic's Feather"] = 80,
					["Undead's Ooze"] = 75,
					["Essence of Fire"] = 3
				}
			}
		}
	},
	["Sea King Jaw"] = {
		Tier = "Epic",
		Image = "rbxassetid://7529098668",
		Upgrade = {
			[0] = {
				Info = "Reduce sea king damage 20% & +2% All Damage",
				InfoTH = "ลดการโจมตีจากเจ้าทะเล 20% & เพิ่มพลังทุกศาสตร์ +2%",
				Buff = {
					Damage = { 2, "All" },
					Defense = { 20, "SeaKing" }
				}
			},
			[1] = {
				Info = "Reduce sea king damage 30% & +5% All Damage",
				InfoTH = "ลดการโจมตีจากเจ้าทะเล 30% & เพิ่มพลังทุกศาสตร์ +5%",
				Buff = {
					Damage = { 5, "All" },
					Defense = { 30, "SeaKing" }
				},
				MaterialNeed = {
					["Pile of Bones"] = 225,
					["Fresh Fish"] = 50,
					["Sea King's Blood"] = 5
				}
			},
			[2] = {
				Info = "Reduce sea king damage 31% & +6% All Damage",
				InfoTH = "ลดการโจมตีจากเจ้าทะเล 31% & เพิ่มพลังทุกศาสตร์ +6%",
				Buff = {
					Damage = { 6, "All" },
					Defense = { 31, "SeaKing" }
				},
				MaterialNeed = {
					["Pile of Bones"] = 225,
					["Fresh Fish"] = 50,
					["Sea King's Blood"] = 5
				}
			},
			[3] = {
				Info = "Reduce sea king damage 32% & +7% All Damage",
				InfoTH = "ลดการโจมตีจากเจ้าทะเล 32% & เพิ่มพลังทุกศาสตร์ +7%",
				Buff = {
					Damage = { 7, "All" },
					Defense = { 32, "SeaKing" }
				},
				MaterialNeed = {
					["Pile of Bones"] = 225,
					["Fresh Fish"] = 50,
					["Sea King's Blood"] = 5
				}
			}
		}
	},
	["Blue Scarf"] = {
		Tier = "Epic",
		Image = "rbxassetid://7529097972",
		Upgrade = {
			[0] = {
				Info = "+5% Fruit damage & Reduce damage received from fruit 10%",
				InfoTH = "เพิ่มพลังผลไม้ +5% & ลดการถูกโจมตีจากผลไม้ 10%",
				Buff = {
					Damage = { 5, "Fruit" },
					Defense = { 10, "Fruit" }
				}
			},
			[1] = {
				Info = "+10% Fruit damage & Reduce damage received from fruit 20%",
				InfoTH = "เพิ่มพลังผลไม้ +10% & ลดการถูกโจมตีจากผลไม้ 20%",
				Buff = {
					Damage = { 10, "Fruit" },
					Defense = { 20, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Angellic's Feather"] = 35,
					["Bread Crumbs"] = 25
				}
			},
			[2] = {
				Info = "+11% Fruit damage & Reduce damage received from fruit 21%",
				InfoTH = "เพิ่มพลังผลไม้ +11% & ลดการถูกโจมตีจากผลไม้ 21%",
				Buff = {
					Damage = { 11, "Fruit" },
					Defense = { 21, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Angellic's Feather"] = 35,
					["Bread Crumbs"] = 25
				}
			},
			[3] = {
				Info = "+12% Fruit damage & Reduce damage received from fruit 22%",
				InfoTH = "เพิ่มพลังผลไม้ +12% & ลดการถูกโจมตีจากผลไม้ 22%",
				Buff = {
					Damage = { 12, "Fruit" },
					Defense = { 22, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Angellic's Feather"] = 35,
					["Bread Crumbs"] = 25
				}
			}
		}
	},
	["Biscuit Shoulder"] = {
		Tier = "Rare",
		Image = "rbxassetid://7529097618",
		Upgrade = {
			[0] = {
				Info = "+3% Sword damage",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +3%",
				Buff = {
					Damage = { 3, "Sword" }
				}
			},
			[1] = {
				Info = "+6% Sword damage",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +6%",
				Buff = {
					Damage = { 6, "Sword" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 35,
					["Bread Crumbs"] = 25
				}
			},
			[2] = {
				Info = "+7% Sword damage",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +7%",
				Buff = {
					Damage = { 7, "Sword" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 35,
					["Bread Crumbs"] = 25
				}
			},
			[3] = {
				Info = "+8% Sword damage",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +8%",
				Buff = {
					Damage = { 8, "Sword" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 35,
					["Bread Crumbs"] = 25
				}
			}
		}
	},
	["Pumpkin Head"] = {
		Tier = "Limited",
		Image = "rbxassetid://7718456369",
		TierImage = "rbxassetid://17583658130",
		Info = "A carved pumpkin, embedded with the very soul of Halloween.",
		InfoTH = "ฟักทองที่ถูกแกะสลักพร้อมผนึกด้วยจิตวิญญาณแห่งฮาโลวีน",
		Upgrade = {
			[0] = {
				Info = "+4% All Damage & Reduce damage received from All 5%",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +4% & ลดการถูกโจมตีทุกศาสตร์ 5%",
				Buff = {
					Damage = { 4, "All" },
					Defense = { 5, "All" }
				}
			},
			[1] = {
				Info = "+8% All Damage & Reduce damage received from All 10%",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +8% & ลดการถูกโจมตีทุกศาสตร์ 10%",
				Buff = {
					Damage = { 8, "All" },
					Defense = { 10, "All" }
				},
				MaterialNeed = {
					Candy = 130,
					["Undead's Ooze"] = 125,
					["Vampire's Vital fluid"] = 5
				}
			},
			[2] = {
				Info = "+12% All Damage & Reduce damage received from All 15%",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +12% & ลดการถูกโจมตีทุกศาสตร์ 15%",
				Buff = {
					Damage = { 12, "All" },
					Defense = { 15, "All" }
				},
				MaterialNeed = {
					Candy = 170,
					["Undead's Ooze"] = 150,
					["Vampire's Vital fluid"] = 6,
					["Sea's Wraith"] = 1
				}
			},
			[3] = {
				Info = "+16% All Damage & Reduce damage received from All 20%",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +16% & ลดการถูกโจมตีทุกศาสตร์ 20%",
				Buff = {
					Damage = { 16, "All" },
					Defense = { 20, "All" }
				},
				MaterialNeed = {
					Candy = 200,
					["Undead's Ooze"] = 175,
					["Vampire's Vital fluid"] = 7,
					["Sea's Wraith"] = 1
				}
			}
		},
		CraftList = {
			MaterialNeed = {
				Candy = 350
			},
			CraftWith = "Hexley Hallow"
		}
	},
	["Hallo Lamp"] = {
		Tier = "Limited",
		Image = "rbxassetid://7795826540",
		TierImage = "rbxassetid://17583658130",
		Info = "Some say this lamp misguides lost spirits, making its holder stronger.",
		InfoTH = "ตะเกียงไฟนำพาเหล่าวิญญาณลุ่มหลงทำให้ผู้ที่ถือครองมันแกร่งขึ้น",
		Upgrade = {
			[0] = {
				Info = "+5% Sword damage & Reduce damage received from Sword 7.5%",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +5% & ลดการถูกโจมตีด้วยดาบ 7.5%",
				Buff = {
					Damage = { 5, "Sword" },
					Defense = { 7.5, "Sword" }
				}
			},
			[1] = {
				Info = "+10% Sword damage & Reduce damage received from Sword 15%",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +10% & ลดการถูกโจมตีด้วยดาบ 15%",
				Buff = {
					Damage = { 10, "Sword" },
					Defense = { 15, "Sword" }
				},
				MaterialNeed = {
					Candy = 150,
					["Undead's Ooze"] = 50,
					["Vampire's Vital fluid"] = 5,
					["Sea's Wraith"] = 1
				}
			},
			[2] = {
				Info = "+15% Sword damage & Reduce damage received from Sword 20%",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +15% & ลดการถูกโจมตีด้วยดาบ 20%",
				Buff = {
					Damage = { 15, "Sword" },
					Defense = { 16, "Sword" }
				},
				MaterialNeed = {
					Candy = 200,
					["Undead's Ooze"] = 75,
					["Vampire's Vital fluid"] = 5,
					["Sea's Wraith"] = 1
				}
			},
			[3] = {
				Info = "+20% Sword damage & Reduce damage received from Sword 25%",
				InfoTH = "เพิ่มพลังการโจมตีของดาบ +20% & ลดการถูกโจมตีด้วยดาบ 25%",
				Buff = {
					Damage = { 20, "Sword" },
					Defense = { 25, "Sword" }
				},
				MaterialNeed = {
					Candy = 250,
					["Undead's Ooze"] = 100,
					["Vampire's Vital fluid"] = 5,
					["Sea's Wraith"] = 1
				}
			}
		},
		CraftList = {
			MaterialNeed = {
				Candy = 500
			},
			CraftWith = "Hexley Hallow"
		}
	},
	["Hallo Shawl"] = {
		Tier = "Limited",
		Image = "rbxassetid://7795826847",
		TierImage = "rbxassetid://17583658130",
		Info = "Torn cape, some say it was worn by the scariest soldier of the dead.",
		InfoTH = "ผ้าคลุมที่ฉีกขาด,ว่ากันว่ามันถูกใส่ด้วยนักรบแห่งความตาย",
		Upgrade = {
			[0] = {
				Info = "+5% Fruit damage & Reduce damage received from fruit 7.5%",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ +5% & ลดการถูกโจมตีด้วยผลไม้ 7.5%",
				Buff = {
					Damage = { 5, "Fruit" },
					Defense = { 7.5, "Fruit" }
				}
			},
			[1] = {
				Info = "+10% Fruit damage & Reduce damage received from fruit 15%",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ +10% & ลดการถูกโจมตีด้วยผลไม้ 15%",
				Buff = {
					Damage = { 10, "Fruit" },
					Defense = { 15, "Fruit" }
				},
				MaterialNeed = {
					Candy = 75,
					Leather = 28,
					["Vampire's Vital fluid"] = 1,
					["Sea's Wraith"] = 1
				}
			},
			[2] = {
				Info = "+15% Fruit damage & Reduce damage received from fruit 20%",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ +15% & ลดการถูกโจมตีด้วยผลไม้ 20%",
				Buff = {
					Damage = { 15, "Fruit" },
					Defense = { 20, "Fruit" }
				},
				MaterialNeed = {
					Candy = 150,
					Leather = 44,
					["Vampire's Vital fluid"] = 2,
					["Sea's Wraith"] = 3
				}
			},
			[3] = {
				Info = "+20% Fruit damage & Reduce damage received from fruit 25%",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ +20% & ลดการถูกโจมตีด้วยผลไม้ 25%",
				Buff = {
					Damage = { 20, "Fruit" },
					Defense = { 25, "Fruit" }
				},
				MaterialNeed = {
					Candy = 200,
					Leather = 55,
					["Vampire's Vital fluid"] = 3,
					["Sea's Wraith"] = 3
				}
			}
		},
		CraftList = {
			MaterialNeed = {
				Candy = 750
			},
			CraftWith = "Hexley Hallow"
		}
	},
	["Sea King Skull"] = {
		Tier = "Limited",
		Image = "rbxassetid://7795827196",
		TierImage = "rbxassetid://17583658130",
		Info = "Anomaly Skull, haunted by the power of the Sea King.",
		InfoTH = "หัวกะโหลกที่ผิดปรกติ เพราะมันถูกสิงโดยเจ้าทะเล",
		Upgrade = {
			[0] = {
				Info = "Reduce sea king damage 30% & +3% All Damage",
				InfoTH = "ลดการถูกโจมตีจากเจ้าทะเล 30% & เพิ่มพลังทุกศาสตร์ +3% ",
				Buff = {
					Damage = { 3, "All" },
					Defense = { 30, "SeaKing" }
				}
			},
			[1] = {
				Info = "Reduce sea king damage 40% & +6% All Damage",
				InfoTH = "ลดการถูกโจมตีจากเจ้าทะเล 40% & เพิ่มพลังทุกศาสตร์ +6% ",
				Buff = {
					Damage = { 6, "All" },
					Defense = { 40, "SeaKing" }
				},
				MaterialNeed = {
					Candy = 150,
					["Pile of Bones"] = 33,
					["Sea King's Blood"] = 5,
					["Sea King's Fin"] = 2,
					["Hydra's Tail"] = 1
				}
			},
			[2] = {
				Info = "Reduce sea king damage 50% & +7% All Damage",
				InfoTH = "ลดการถูกโจมตีจากเจ้าทะเล 50% & เพิ่มพลังทุกศาสตร์ +7% ",
				Buff = {
					Damage = { 7, "All" },
					Defense = { 50, "SeaKing" }
				},
				MaterialNeed = {
					Candy = 150,
					["Pile of Bones"] = 33,
					["Sea King's Blood"] = 5,
					["Sea King's Fin"] = 2,
					["Hydra's Tail"] = 1
				}
			},
			[3] = {
				Info = "Reduce sea king damage 55% & +8% All Damage",
				InfoTH = "ลดการถูกโจมตีจากเจ้าทะเล 55% & เพิ่มพลังทุกศาสตร์ +8% ",
				Buff = {
					Damage = { 8, "All" },
					Defense = { 55, "SeaKing" }
				},
				MaterialNeed = {
					Candy = 150,
					["Pile of Bones"] = 33,
					["Sea King's Blood"] = 5,
					["Sea King's Fin"] = 2,
					["Hydra's Tail"] = 1
				}
			}
		},
		CraftList = {
			MaterialNeed = {
				Candy = 750,
				["Sea King's Blood"] = 25
			},
			CraftWith = "Hexley Hallow"
		}
	},
	Cervus = {
		Tier = "Limited",
		Image = "rbxassetid://8418434005",
		TierImage = "rbxassetid://17583658909",
		Upgrade = {
			[0] = {
				Info = "+5% Sword damage & +5 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีด้วยดาบ +5% & เพิ่มความว่องไว +5 ",
				Buff = {
					Damage = { 5, "Sword" },
					Speed = 5
				}
			},
			[1] = {
				Info = "+10% Sword damage & +10 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีด้วยดาบ +10% & เพิ่มความว่องไว +10 ",
				Buff = {
					Damage = { 10, "Sword" },
					Speed = 10
				},
				MaterialNeed = {
					["Santa's Candy"] = 125,
					Leather = 35,
					["Dragon Scale"] = 8,
					Candy = 5
				}
			},
			[2] = {
				Info = "+11% Sword damage & +15 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีด้วยดาบ +11% & เพิ่มความว่องไว +15 ",
				Buff = {
					Damage = { 11, "Sword" },
					Speed = 15
				},
				MaterialNeed = {
					["Santa's Candy"] = 125,
					Leather = 35,
					["Dragon Scale"] = 8,
					Candy = 5
				}
			},
			[3] = {
				Info = "+12% Sword damage & +20 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีด้วยดาบ +12% & เพิ่มความว่องไว +20 ",
				Buff = {
					Damage = { 12, "Sword" },
					Speed = 20
				},
				MaterialNeed = {
					["Santa's Candy"] = 125,
					Leather = 35,
					["Dragon Scale"] = 8,
					Candy = 5
				}
			}
		}
	},
	["Glacies Shoulder"] = {
		Tier = "Limited",
		Image = "rbxassetid://8418434287",
		TierImage = "rbxassetid://17583658909",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from fruit 10% & +5% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 10% & เพิ่มพลังการโจมตีของผลไม้ +5%",
				Buff = {
					Damage = { 5, "Fruit" },
					Defense = { 10, "Fruit" }
				}
			},
			[1] = {
				Info = "Reduce damage received from fruit 20% & +10% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 20% & เพิ่มพลังการโจมตีของผลไม้ +10%",
				Buff = {
					Damage = { 10, "Fruit" },
					Defense = { 20, "Fruit" }
				},
				MaterialNeed = {
					["Santa's Candy"] = 145,
					["Bread Crumbs"] = 20,
					["Lost Ruby"] = 1,
					Candy = 5
				}
			},
			[2] = {
				Info = "Reduce damage received from fruit 21% & +11% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 21% & เพิ่มพลังการโจมตีของผลไม้ +11%",
				Buff = {
					Damage = { 11, "Fruit" },
					Defense = { 21, "Fruit" }
				},
				MaterialNeed = {
					["Santa's Candy"] = 145,
					["Bread Crumbs"] = 20,
					["Lost Ruby"] = 1,
					Candy = 5
				}
			},
			[3] = {
				Info = "Reduce damage received from fruit 22% & +12% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 22% & เพิ่มพลังการโจมตีของผลไม้ +12%",
				Buff = {
					Damage = { 12, "Fruit" },
					Defense = { 22, "Fruit" }
				},
				MaterialNeed = {
					["Santa's Candy"] = 145,
					["Bread Crumbs"] = 20,
					["Lost Ruby"] = 1,
					Candy = 5
				}
			}
		}
	},
	["Green Dryadalis"] = {
		Tier = "Limited",
		Image = "rbxassetid://8418434614",
		TierImage = "rbxassetid://17583658909",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from Sword 10% & +5% Sword damage",
				InfoTH = "ลดการโจมตีจากดาบ 10% & เพิ่มการโจมตีด้วยดาบ +5%",
				Buff = {
					Damage = { 5, "Sword" },
					Defense = { 10, "Sword" }
				}
			},
			[1] = {
				Info = "Reduce damage received from Sword 20% & +10% Sword damage",
				InfoTH = "ลดการโจมตีจากดาบ 20% & เพิ่มการโจมตีด้วยดาบ +10%",
				Buff = {
					Damage = { 10, "Sword" },
					Defense = { 20, "Sword" }
				},
				MaterialNeed = {
					["Santa's Candy"] = 100,
					Leather = 23,
					["Thief's rag"] = 10,
					Candy = 5
				}
			},
			[2] = {
				Info = "Reduce damage received from Sword 21% & +11% Sword damage",
				InfoTH = "ลดการโจมตีจากดาบ 21% & เพิ่มการโจมตีด้วยดาบ +11%",
				Buff = {
					Damage = { 11, "Sword" },
					Defense = { 21, "Sword" }
				},
				MaterialNeed = {
					["Santa's Candy"] = 100,
					Leather = 23,
					["Thief's rag"] = 10,
					Candy = 5
				}
			},
			[3] = {
				Info = "Reduce damage received from Sword 22% & +12% Sword damage",
				InfoTH = "ลดการโจมตีจากดาบ 22% & เพิ่มการโจมตีด้วยดาบ +12%",
				Buff = {
					Damage = { 12, "Sword" },
					Defense = { 22, "Sword" }
				},
				MaterialNeed = {
					["Santa's Candy"] = 100,
					Leather = 23,
					["Thief's rag"] = 10,
					Candy = 5
				}
			}
		}
	},
	Nativitatis = {
		Tier = "Limited",
		Image = "rbxassetid://8418435024",
		TierImage = "rbxassetid://17583658909",
		Upgrade = {
			[0] = {
				Info = "+5% Health & Reduce damage received from fruit 10%",
				InfoTH = "เพิ่มพลังชีวิต +5% & ลดการโจมตีจากผลไม้ 10%",
				Buff = {
					Health = { 5, "Extra" },
					Defense = { 10, "Fruit" }
				}
			},
			[1] = {
				Info = "+10% Health & Reduce damage received from fruit 20%",
				InfoTH = "เพิ่มพลังชีวิต +10% & ลดการโจมตีจากผลไม้ 20%",
				Buff = {
					Health = { 10, "Extra" },
					Defense = { 20, "Fruit" }
				},
				MaterialNeed = {
					["Santa's Candy"] = 75,
					Leather = 36,
					["Thief's rag"] = 10,
					Candy = 5
				}
			},
			[2] = {
				Info = "+11% Health & Reduce damage received from fruit 21%",
				InfoTH = "เพิ่มพลังชีวิต +11% & ลดการโจมตีจากผลไม้ 21%",
				Buff = {
					Health = { 11, "Extra" },
					Defense = { 21, "Fruit" }
				},
				MaterialNeed = {
					["Santa's Candy"] = 75,
					Leather = 36,
					["Thief's rag"] = 10,
					Candy = 5
				}
			},
			[3] = {
				Info = "+12% Health & Reduce damage received from fruit 22%",
				InfoTH = "เพิ่มพลังชีวิต +12% & ลดการโจมตีจากผลไม้ 22%",
				Buff = {
					Health = { 12, "Extra" },
					Defense = { 22, "Fruit" }
				},
				MaterialNeed = {
					["Santa's Candy"] = 75,
					Leather = 36,
					["Thief's rag"] = 10,
					Candy = 5
				}
			}
		}
	},
	Bullitus = {
		Tier = "Common",
		Image = "rbxassetid://8418433249",
		Upgrade = {
			[0] = {
				Info = "Grant you access to go underwater",
				InfoTH = "เพิ่มความสามารถในการดำน้ำ",
				Buff = {}
			}
		}
	},
	["Eye Patch"] = {
		Tier = "Uncommon",
		Image = "rbxassetid://8458134651",
		Upgrade = {
			[0] = {
				Info = "+150 Health & +3% Sword damage",
				InfoTH = "เพิ่มพลังชีวิต +150 & เพิ่มพลังการโจมตีด้วยดาบ +3%",
				Buff = {
					Health = { 150, "Normal" },
					Damage = { 3, "Sword" }
				}
			},
			[1] = {
				Info = "+200 Health & +6% Sword damage",
				InfoTH = "เพิ่มพลังชีวิต +200 & เพิ่มพลังการโจมตีด้วยดาบ +6%",
				Buff = {
					Health = { 200, "Normal" },
					Damage = { 6, "Sword" }
				},
				MaterialNeed = {
					Leather = 35,
					["Thief's rag"] = 1
				}
			},
			[2] = {
				Info = "+300 Health & +7% Sword damage",
				InfoTH = "เพิ่มพลังชีวิต +300 & เพิ่มพลังการโจมตีด้วยดาบ +7%",
				Buff = {
					Health = { 300, "Normal" },
					Damage = { 7, "Sword" }
				},
				MaterialNeed = {
					Leather = 35,
					["Thief's rag"] = 1
				}
			},
			[3] = {
				Info = "+400 Health & +8% Sword damage",
				InfoTH = "เพิ่มพลังชีวิต +400 & เพิ่มพลังการโจมตีด้วยดาบ +8%",
				Buff = {
					Health = { 400, "Normal" },
					Damage = { 8, "Sword" }
				},
				MaterialNeed = {
					Leather = 35,
					["Thief's rag"] = 1
				}
			}
		}
	},
	["Dragon Necklace"] = {
		Tier = "Legendary",
		Image = "rbxassetid://8458134321",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from All 15% & +10% Fruit damage",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 15% & เพิ่มพลังการโจมตีด้วยผลไม้ +10%",
				Buff = {
					Defense = { 15, "All" },
					Damage = { 10, "Fruit" }
				}
			},
			[1] = {
				Info = "Reduce damage received from All 20% & +20% Fruit damage",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 20% & เพิ่มพลังการโจมตีด้วยผลไม้ +20%",
				Buff = {
					Defense = { 20, "All" },
					Damage = { 20, "Fruit" }
				},
				MaterialNeed = {
					["Angellic's Feather"] = 75,
					["Dragon Scale"] = 15,
					["Sea's Wraith"] = 2,
					["Phoenix's Tear"] = 1
				}
			},
			[2] = {
				Info = "Reduce damage received from All 21% & +21% Fruit damage",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 21% & เพิ่มพลังการโจมตีด้วยผลไม้ +21%",
				Buff = {
					Defense = { 21, "All" },
					Damage = { 21, "Fruit" }
				},
				MaterialNeed = {
					["Angellic's Feather"] = 75,
					["Dragon Scale"] = 15,
					["Sea's Wraith"] = 2,
					["Phoenix's Tear"] = 1
				}
			},
			[3] = {
				Info = "Reduce damage received from All 22% & +22% Fruit damage",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 22% & เพิ่มพลังการโจมตีด้วยผลไม้ +22%",
				Buff = {
					Defense = { 22, "All" },
					Damage = { 22, "Fruit" }
				},
				MaterialNeed = {
					["Angellic's Feather"] = 75,
					["Dragon Scale"] = 15,
					["Sea's Wraith"] = 2,
					["Phoenix's Tear"] = 1
				}
			}
		}
	},
	["Night Cap"] = {
		Tier = "Legendary",
		Image = "http://www.roblox.com/asset/?id=13267611314",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from All 20% & +5% Fruit damage",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 20% & เพิ่มพลังการโจมตีด้วยผลไม้ +5%",
				Buff = {
					Damage = { 5, "Fruit" },
					Defense = { 20, "All" }
				}
			},
			[1] = {
				Info = "Reduce damage received from All 30% & +10% Fruit damage",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 30% & เพิ่มพลังการโจมตีด้วยผลไม้ +10%",
				Buff = {
					Damage = { 10, "Fruit" },
					Defense = { 30, "All" }
				},
				MaterialNeed = {
					Leather = 75,
					["Dragon Scale"] = 50,
					["Samurai's Badage"] = 3,
					["Phoenix's Tear"] = 1
				}
			},
			[2] = {
				Info = "Reduce damage received from All 31% & +11% Fruit damage",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 31% & เพิ่มพลังการโจมตีด้วยผลไม้ +11%",
				Buff = {
					Damage = { 11, "Fruit" },
					Defense = { 31, "All" }
				},
				MaterialNeed = {
					Leather = 75,
					["Dragon Scale"] = 50,
					["Samurai's Badage"] = 3,
					["Phoenix's Tear"] = 1
				}
			},
			[3] = {
				Info = "Reduce damage received from All 32% & +12% Fruit damage",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 32% & เพิ่มพลังการโจมตีด้วยผลไม้ +12%",
				Buff = {
					Damage = { 12, "Fruit" },
					Defense = { 32, "All" }
				},
				MaterialNeed = {
					Leather = 75,
					["Dragon Scale"] = 50,
					["Samurai's Badage"] = 3,
					["Phoenix's Tear"] = 1
				}
			}
		}
	},
	["Pirate Necklace"] = {
		Tier = "Rare",
		Image = "rbxassetid://8458134972",
		Upgrade = {
			[0] = {
				Info = "Reduce ghost ship (cannon/slash) Damage 15%",
				InfoTH = "ลดจำนวนการโจมตีจาก Ghost Ship (จำพวก ปืนใหญ่/ฟาดฟัน) 15%",
				Buff = {
					Defense = { 15, "Ghost Ship" }
				}
			},
			[1] = {
				Info = "Reduce ghost ship (cannon/slash) Damage 30%",
				InfoTH = "ลดความเสียหายจากการโจมตีจาก Ghost Ship (จำพวก ปืนใหญ่/ฟาดฟัน) 30%",
				Buff = {
					Defense = { 30, "Ghost Ship" }
				},
				MaterialNeed = {
					Leather = 50,
					["Sea's Wraith"] = 2
				}
			},
			[2] = {
				Info = "Reduce ghost ship (cannon/slash) Damage 32%",
				InfoTH = "ลดความเสียหายจากการโจมตีจาก Ghost Ship (จำพวก ปืนใหญ่/ฟาดฟัน) 32%",
				Buff = {
					Defense = { 32, "Ghost Ship" }
				},
				MaterialNeed = {
					Leather = 50,
					["Sea's Wraith"] = 2
				}
			},
			[3] = {
				Info = "Reduce ghost ship (cannon/slash) Damage 34%",
				InfoTH = "ลดความเสียหายจากการโจมตีจาก Ghost Ship (จำพวก ปืนใหญ่/ฟาดฟัน) 34%",
				Buff = {
					Defense = { 34, "Ghost Ship" }
				},
				MaterialNeed = {
					Leather = 50,
					["Sea's Wraith"] = 2
				}
			}
		}
	},
	["Raptor Head"] = {
		Tier = "Exotic",
		Image = "rbxassetid://9150519993",
		Upgrade = {
			[0] = {
				Info = "+50 Run Speed & Reduce damage received from All 99% & +300k HP",
				InfoTH = "เพิ่มความว่องไว +50 & ลดการโจมตีทุกศาสตร์ 99% & +300k พลังชีวิต",
				Buff = {
					Health = { 300000, "Normal" },
					Defense = { 99, "All" },
					Speed = 50
				}
			},
			[1] = {
				Info = "+75 Run Speed & Reduce damage received from All 99% & +300k HP",
				InfoTH = "เพิ่มความว่องไว +75 & ลดการโจมตีทุกศาสตร์ 99% & +300k พลังชีวิต",
				Buff = {
					Health = { 300000, "Normal" },
					Defense = { 99, "All" },
					Speed = 75
				},
				MaterialNeed = {
					Leather = 10000
				}
			},
			[2] = {
				Info = "+100 Run Speed & Reduce damage received from All 99% & +350k HP",
				InfoTH = "เพิ่มความว่องไว +100 & ลดการโจมตีทุกศาสตร์ 99% & +350k พลังชีวิต",
				Buff = {
					Health = { 350000, "Normal" },
					Defense = { 99, "All" },
					Speed = 100
				},
				MaterialNeed = {
					Leather = 10000
				}
			},
			[3] = {
				Info = "+125 Run Speed & Reduce damage received from All 99% & +400k HP",
				InfoTH = "เพิ่มความว่องไว +125 & ลดการโจมตีทุกศาสตร์ 99% & +400k พลังชีวิต",
				Buff = {
					Health = { 400000, "Normal" },
					Defense = { 99, "All" },
					Speed = 125
				},
				MaterialNeed = {
					Leather = 10000
				}
			}
		}
	},
	["Oni Mask"] = {
		Tier = "Epic",
		Image = "rbxassetid://9319963722",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from fruit 7.5% & +10% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 7.5% & เพิ่มพลังการโจมตีด้วยผลไม้ +10%",
				Buff = {
					Defense = { 7.5, "Fruit" },
					Damage = { 10, "Fruit" }
				}
			},
			[1] = {
				Info = "Reduce damage received from fruit 15% & +20% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 15% & เพิ่มพลังการโจมตีด้วยผลไม้ +20%",
				Buff = {
					Defense = { 15, "Fruit" },
					Damage = { 20, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Ice Crystal"] = 12
				}
			},
			[2] = {
				Info = "Reduce damage received from fruit 16% & +21% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 16% & เพิ่มพลังการโจมตีด้วยผลไม้ +21%",
				Buff = {
					Defense = { 16, "Fruit" },
					Damage = { 21, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Ice Crystal"] = 12
				}
			},
			[3] = {
				Info = "Reduce damage received from fruit 17% & +22% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 17% & เพิ่มพลังการโจมตีด้วยผลไม้ +22%",
				Buff = {
					Defense = { 17, "Fruit" },
					Damage = { 22, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Ice Crystal"] = 12
				}
			}
		}
	},
	["Tengu Mask"] = {
		Tier = "Epic",
		Image = "rbxassetid://9319962805",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from fruit 10% & +7.5% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 10% & เพิ่มพลังการโจมตีด้วยผลไม้ +7.5%",
				Buff = {
					Defense = { 10, "Fruit" },
					Damage = { 7.5, "Fruit" }
				}
			},
			[1] = {
				Info = "Reduce damage received from fruit 20% & +15% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 20% & เพิ่มพลังการโจมตีด้วยผลไม้ +15%",
				Buff = {
					Defense = { 20, "Fruit" },
					Damage = { 15, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Magma Crystal"] = 12
				}
			},
			[2] = {
				Info = "Reduce damage received from fruit 21% & +16% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 21% & เพิ่มพลังการโจมตีด้วยผลไม้ +16%",
				Buff = {
					Defense = { 21, "Fruit" },
					Damage = { 16, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Magma Crystal"] = 12
				}
			},
			[3] = {
				Info = "Reduce damage received from fruit 22% & +17% Fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 22% & เพิ่มพลังการโจมตีด้วยผลไม้ +17%",
				Buff = {
					Defense = { 22, "Fruit" },
					Damage = { 17, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Magma Crystal"] = 12
				}
			}
		}
	},
	["Stainless Jaw"] = {
		Tier = "Common",
		Image = "rbxassetid://9671745654",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from Sword 3%",
				InfoTH = "ลดการโจมตีจากดาบ 3%",
				Buff = {
					Defense = { 3, "Sword" }
				}
			},
			[1] = {
				Info = "Reduce damage received from Sword 6%",
				InfoTH = "ลดการโจมตีจากดาบ 6%",
				Buff = {
					Defense = { 6, "Sword" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 25
				}
			},
			[2] = {
				Info = "Reduce damage received from Sword 7%",
				InfoTH = "ลดการโจมตีจากดาบ 7%",
				Buff = {
					Defense = { 7, "Sword" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 25
				}
			},
			[3] = {
				Info = "Reduce damage received from Sword 8%",
				InfoTH = "ลดการโจมตีจากดาบ 8%",
				Buff = {
					Defense = { 8, "Sword" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 25
				}
			}
		}
	},
	["Horned Hat"] = {
		Tier = "Uncommon",
		Image = "rbxassetid://9671745147",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from Melee 3% & +3% Melee damage",
				InfoTH = "ลดการโจมตีจากหมัด 3% & เพิ่มพลังการโจมตีหมัด +3%",
				Buff = {
					Defense = { 3, "Melee" },
					Damage = { 3, "Melee" }
				}
			},
			[1] = {
				Info = "Reduce damage received from Melee 6% & +6% Melee damage",
				InfoTH = "ลดการโจมตีจากหมัด 6% & เพิ่มพลังการโจมตีหมัด +6%",
				Buff = {
					Defense = { 6, "Melee" },
					Damage = { 6, "Melee" }
				},
				MaterialNeed = {
					Leather = 15
				}
			},
			[2] = {
				Info = "Reduce damage received from Melee 7% & +7% Melee damage",
				InfoTH = "ลดการโจมตีจากหมัด 7% & เพิ่มพลังการโจมตีหมัด +7%",
				Buff = {
					Defense = { 7, "Melee" },
					Damage = { 7, "Melee" }
				},
				MaterialNeed = {
					Leather = 15
				}
			},
			[3] = {
				Info = "Reduce damage received from Melee 8% & +8% Melee damage",
				InfoTH = "ลดการโจมตีจากหมัด 8% & เพิ่มพลังการโจมตีหมัด +8%",
				Buff = {
					Defense = { 8, "Melee" },
					Damage = { 8, "Melee" }
				},
				MaterialNeed = {
					Leather = 15
				}
			}
		}
	},
	["Gazelle Mask"] = {
		Tier = "Uncommon",
		Image = "rbxassetid://10590610733",
		Upgrade = {
			[0] = {
				Info = "+15 Run Speed",
				InfoTH = "เพิ่มความว่องไว +15",
				Buff = {
					Speed = 15
				}
			},
			[1] = {
				Info = "+30 Run Speed",
				InfoTH = "เพิ่มความว่องไว +30",
				Buff = {
					Speed = 30
				},
				MaterialNeed = {
					Leather = 55,
					["Thief's rag"] = 6
				}
			},
			[2] = {
				Info = "+40 Run Speed",
				InfoTH = "เพิ่มความว่องไว +40",
				Buff = {
					Speed = 40
				},
				MaterialNeed = {
					Leather = 55,
					["Thief's rag"] = 6
				}
			},
			[3] = {
				Info = "+50 Run Speed",
				InfoTH = "เพิ่มความว่องไว +50",
				Buff = {
					Speed = 50
				},
				MaterialNeed = {
					Leather = 55,
					["Thief's rag"] = 6
				}
			}
		}
	},
	["Hefty Glasses"] = {
		Tier = "Rare",
		Image = "rbxassetid://10556197296",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from Melee 10%",
				InfoTH = "ลดการโจมตีจากหมัด 10%",
				Buff = {
					Defense = { 10, "Melee" }
				}
			},
			[1] = {
				Info = "Reduce damage received from Melee 20%",
				InfoTH = "ลดการโจมตีจากหมัด 20%",
				Buff = {
					Defense = { 20, "Melee" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 125,
					["Iron Ingot"] = 35,
					["Lucidus's Totem"] = 13
				}
			},
			[2] = {
				Info = "Reduce damage received from Melee 21%",
				InfoTH = "ลดการโจมตีจากหมัด 21%",
				Buff = {
					Defense = { 21, "Melee" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 125,
					["Iron Ingot"] = 35,
					["Lucidus's Totem"] = 13
				}
			},
			[3] = {
				Info = "Reduce damage received from Melee 22%",
				InfoTH = "ลดการโจมตีจากหมัด 22%",
				Buff = {
					Defense = { 22, "Melee" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 125,
					["Iron Ingot"] = 35,
					["Lucidus's Totem"] = 13
				}
			}
		}
	},
	["Hefty Coat"] = {
		Tier = "Epic",
		Image = "rbxassetid://10556194798",
		Upgrade = {
			[0] = {
				Info = "+10% Health & 5% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +10% & พลังการโจมตีด้วยผลไม้ 5%",
				Buff = {
					Health = { 10, "Extra" },
					Damage = { 5, "Fruit" }
				}
			},
			[1] = {
				Info = "+15% Health & 10% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +15% & พลังการโจมตีด้วยผลไม้ 10%",
				Buff = {
					Health = { 15, "Extra" },
					Damage = { 10, "Fruit" }
				},
				MaterialNeed = {
					Leather = 50,
					["Lucidus's Totem"] = 13
				}
			},
			[2] = {
				Info = "+16% Health & 11% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +16% & พลังการโจมตีด้วยผลไม้ 11%",
				Buff = {
					Health = { 16, "Extra" },
					Damage = { 11, "Fruit" }
				},
				MaterialNeed = {
					Leather = 50,
					["Lucidus's Totem"] = 13
				}
			},
			[3] = {
				Info = "+17% Health & 12% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +17% & พลังการโจมตีด้วยผลไม้ 12%",
				Buff = {
					Health = { 17, "Extra" },
					Damage = { 12, "Fruit" }
				},
				MaterialNeed = {
					Leather = 50,
					["Lucidus's Totem"] = 13
				}
			}
		}
	},
	["Pondere Coat"] = {
		Tier = "Rare",
		Image = "rbxassetid://10556195303",
		Upgrade = {
			[0] = {
				Info = "+12% Fruit damage",
				InfoTH = "เพิ่มพลังการโจมตีด้วยผลไม้ +12%",
				Buff = {
					Damage = { 12, "Fruit" }
				}
			},
			[1] = {
				Info = "+20% Fruit damage",
				InfoTH = "เพิ่มพลังการโจมตีด้วยผลไม้ +20%",
				Buff = {
					Damage = { 20, "Fruit" }
				},
				MaterialNeed = {
					Leather = 50,
					["Lucidus's Totem"] = 12
				}
			},
			[2] = {
				Info = "+21% Fruit damage",
				InfoTH = "เพิ่มพลังการโจมตีด้วยผลไม้ +21%",
				Buff = {
					Damage = { 21, "Fruit" }
				},
				MaterialNeed = {
					Leather = 50,
					["Lucidus's Totem"] = 12
				}
			},
			[3] = {
				Info = "+22% Fruit damage",
				InfoTH = "เพิ่มพลังการโจมตีด้วยผลไม้ +22%",
				Buff = {
					Damage = { 22, "Fruit" }
				},
				MaterialNeed = {
					Leather = 50,
					["Lucidus's Totem"] = 12
				}
			}
		}
	},
	["Lucidus Coat"] = {
		Tier = "Epic",
		Image = "rbxassetid://10556195930",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from fruit 10% & +5% fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 10% & เพิ่มพลังการโจมตีของผลไม้ +5%",
				Buff = {
					Damage = { 5, "Fruit" },
					Defense = { 10, "Fruit" }
				}
			},
			[1] = {
				Info = "Reduce damage received from fruit 20% & +10% fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 20% & เพิ่มพลังการโจมตีของผลไม้ +10%",
				Buff = {
					Damage = { 10, "Fruit" },
					Defense = { 20, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Lucidus's Totem"] = 15
				}
			},
			[2] = {
				Info = "Reduce damage received from fruit 21% & +11% fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 21% & เพิ่มพลังการโจมตีของผลไม้ +11%",
				Buff = {
					Damage = { 11, "Fruit" },
					Defense = { 21, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Lucidus's Totem"] = 15
				}
			},
			[3] = {
				Info = "Reduce damage received from fruit 22% & +12% fruit damage",
				InfoTH = "ลดการโจมตีจากผลไม้ 22% & เพิ่มพลังการโจมตีของผลไม้ +12%",
				Buff = {
					Damage = { 12, "Fruit" },
					Defense = { 22, "Fruit" }
				},
				MaterialNeed = {
					Leather = 75,
					["Lucidus's Totem"] = 15
				}
			}
		}
	},
	["Sally Crown"] = {
		Tier = "Epic",
		Image = "rbxassetid://10590612266",
		Upgrade = {
			[0] = {
				Info = "+10% Sword damage & + 5 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีด้วยดาบ +10% & ความว่องไว +5",
				Buff = {
					Damage = { 10, "Sword" },
					Speed = 5
				}
			},
			[1] = {
				Info = "+20% Sword damage & + 10 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีด้วยดาบ +20% & ความว่องไว +10",
				Buff = {
					Damage = { 20, "Sword" },
					Speed = 10
				},
				MaterialNeed = {
					["Pile of Bones"] = 50,
					["Undead's Ooze"] = 30,
					["Sea's Wraith"] = 1
				}
			},
			[2] = {
				Info = "+21% Sword damage & + 15 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีด้วยดาบ +21% & ความว่องไว +15",
				Buff = {
					Damage = { 21, "Sword" },
					Speed = 15
				},
				MaterialNeed = {
					["Pile of Bones"] = 50,
					["Undead's Ooze"] = 30,
					["Sea's Wraith"] = 1
				}
			},
			[3] = {
				Info = "+22% Sword damage & + 20 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีด้วยดาบ +22% & ความว่องไว +20",
				Buff = {
					Damage = { 22, "Sword" },
					Speed = 20
				},
				MaterialNeed = {
					["Pile of Bones"] = 50,
					["Undead's Ooze"] = 30,
					["Sea's Wraith"] = 1
				}
			}
		}
	},
	["Dark Beard Cloak"] = {
		Tier = "Rare",
		Image = "rbxassetid://10556193902",
		Upgrade = {
			[0] = {
				Info = "+5% Health & +5% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +5% & เพิ่มพลังการโจมตีของผลไม้ +5%",
				Buff = {
					Health = { 5, "Extra" },
					Damage = { 5, "Fruit" }
				}
			},
			[1] = {
				Info = "+8% Health & +10% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต 8% & เพิ่มพลังการโจมตีของผลไม้ +10%",
				Buff = {
					Health = { 8, "Extra" },
					Damage = { 10, "Fruit" }
				},
				MaterialNeed = {
					Leather = 50,
					["Dark Beard's Totem"] = 15
				}
			},
			[2] = {
				Info = "+9% Health & +11% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต 9% & เพิ่มพลังการโจมตีของผลไม้ +11%",
				Buff = {
					Health = { 9, "Extra" },
					Damage = { 11, "Fruit" }
				},
				MaterialNeed = {
					Leather = 50,
					["Dark Beard's Totem"] = 15
				}
			},
			[3] = {
				Info = "+10% Health & +12% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต 10% & เพิ่มพลังการโจมตีของผลไม้ +12%",
				Buff = {
					Health = { 10, "Extra" },
					Damage = { 12, "Fruit" }
				},
				MaterialNeed = {
					Leather = 50,
					["Dark Beard's Totem"] = 15
				}
			}
		}
	},
	["Dark Beard Hat"] = {
		Tier = "Legendary",
		Image = "rbxassetid://10776183102",
		Upgrade = {
			[0] = {
				Info = "+10% Health & Reduce damage received from fruit 25%",
				InfoTH = "เพิ่มพลังชีวิต +10% & ลดการโจมตีจากผลไม้ 25%",
				Buff = {
					Health = { 10, "Extra" },
					Defense = { 25, "Fruit" }
				}
			},
			[1] = {
				Info = "+15% Health & Reduce damage received from fruit 40%",
				InfoTH = "เพิ่มพลังชีวิต +15% & ลดการโจมตีจากผลไม้ 40%",
				Buff = {
					Health = { 15, "Extra" },
					Defense = { 40, "Fruit" }
				},
				MaterialNeed = {
					Leather = 100,
					["Angellic's Feather"] = 125,
					["Dark Beard's Totem"] = 15
				}
			},
			[2] = {
				Info = "+16% Health & Reduce damage received from fruit 41%",
				InfoTH = "เพิ่มพลังชีวิต +16% & ลดการโจมตีจากผลไม้ 41%",
				Buff = {
					Health = { 16, "Extra" },
					Defense = { 41, "Fruit" }
				},
				MaterialNeed = {
					Leather = 100,
					["Angellic's Feather"] = 125,
					["Dark Beard's Totem"] = 15
				}
			},
			[3] = {
				Info = "+17% Health & Reduce damage received from fruit 42%",
				InfoTH = "เพิ่มพลังชีวิต +17% & ลดการโจมตีจากผลไม้ 42%",
				Buff = {
					Health = { 17, "Extra" },
					Defense = { 42, "Fruit" }
				},
				MaterialNeed = {
					Leather = 100,
					["Angellic's Feather"] = 125,
					["Dark Beard's Totem"] = 15
				}
			}
		}
	},
	["Tomoe Taiko"] = {
		Tier = "Epic",
		Image = "rbxassetid://11385198024",
		Upgrade = {
			[0] = {
				Info = "+10% Health & +15% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +10% & เพิ่มพลังการโจมตีของผลไม้ +15%",
				Buff = {
					Health = { 10, "Extra" },
					Damage = { 15, "Fruit" }
				}
			},
			[1] = {
				Info = "+15% Health & +30% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +15% & เพิ่มพลังการโจมตีของผลไม้ +30%",
				Buff = {
					Health = { 15, "Extra" },
					Damage = { 30, "Fruit" }
				},
				MaterialNeed = {
					["Angellic's Feather"] = 300,
					["Sea King's Blood"] = 3,
					["Hydra's Tail"] = 1
				}
			},
			[2] = {
				Info = "+16% Health & +31% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +16% & เพิ่มพลังการโจมตีของผลไม้ +31%",
				Buff = {
					Health = { 16, "Extra" },
					Damage = { 31, "Fruit" }
				},
				MaterialNeed = {
					["Angellic's Feather"] = 300,
					["Sea King's Blood"] = 3,
					["Hydra's Tail"] = 1
				}
			},
			[3] = {
				Info = "+17% Health & +32% Fruit damage",
				InfoTH = "เพิ่มพลังชีวิต +17% & เพิ่มพลังการโจมตีของผลไม้ +32%",
				Buff = {
					Health = { 17, "Extra" },
					Damage = { 32, "Fruit" }
				},
				MaterialNeed = {
					["Angellic's Feather"] = 300,
					["Sea King's Blood"] = 3,
					["Hydra's Tail"] = 1
				}
			}
		}
	},
	["Water Hydra Mask"] = {
		Tier = "Epic",
		Image = "rbxassetid://11407820199",
		Upgrade = {
			[0] = {
				Info = "Reduces Hydra damage by 30% & regenerates 0.75% health per second.",
				InfoTH = "ลดความเสียหายจากไฮดร้า 30% & ฟื้นฟูพลังชีวิต 0.75% ทุก 1 วินาที",
				Buff = {
					Regen = {
						Percentage = 1.5,
						Rate = 1
					},
					Damage = { 30, "HydraSeaKing" }
				}
			},
			[1] = {
				Info = "Reduces Hydra damage by 45% & regenerates 1% health per second.",
				InfoTH = "ลดความเสียหายจากไฮดร้า 45% & ฟื้นฟูพลังชีวิต 1% ทุก 1 วินาที",
				Buff = {
					Regen = {
						Percentage = 2,
						Rate = 1
					},
					Damage = { 45, "HydraSeaKing" }
				},
				MaterialNeed = {
					["Fresh Fish"] = 150,
					["Sea King's Blood"] = 5,
					["Hydra's Tail"] = 1
				}
			},
			[2] = {
				Info = "Reduces Hydra damage by 46% & regenerates 1.25% health per second.",
				InfoTH = "ลดความเสียหายจากไฮดร้า 46% & ฟื้นฟูพลังชีวิต 1.25% ทุก 1 วินาที",
				Buff = {
					Regen = {
						Percentage = 2.5,
						Rate = 1
					},
					Damage = { 46, "HydraSeaKing" }
				},
				MaterialNeed = {
					["Fresh Fish"] = 150,
					["Sea King's Blood"] = 5,
					["Hydra's Tail"] = 1
				}
			},
			[3] = {
				Info = "Reduces Hydra damage by 47% & regenerates 1.5% health per second.",
				InfoTH = "ลดความเสียหายจากไฮดร้า 47% & ฟื้นฟูพลังชีวิต 1.5% ทุก 1 วินาที",
				Buff = {
					Regen = {
						Percentage = 3,
						Rate = 1
					},
					Damage = { 47, "HydraSeaKing" }
				},
				MaterialNeed = {
					["Fresh Fish"] = 150,
					["Sea King's Blood"] = 5,
					["Hydra's Tail"] = 1
				}
			}
		}
	},
	["Inferno Cloak"] = {
		Tier = "Legendary",
		Image = "rbxassetid://11390228036",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from All 20% & + 10 Run Speed",
				InfoTH = "ลดพลังการถูกโจมตีทุกศาสตร์ 20% & เพิ่มความว่องไว +10",
				Buff = {
					Speed = 10,
					Defense = { 20, "All" }
				}
			},
			[1] = {
				Info = "Reduce damage received from All 22.5% & + 15 Run Speed",
				InfoTH = "ลดพลังการถูกโจมตีทุกศาสตร์ 22.5% & เพิ่มความว่องไว +15",
				Buff = {
					Speed = 15,
					Defense = { 22.5, "All" }
				},
				MaterialNeed = {
					Leather = 400,
					["Sea King's Blood"] = 6,
					["Hydra's Tail"] = 1
				}
			},
			[2] = {
				Info = "Reduce damage received from All 24% & + 20 Run Speed",
				InfoTH = "ลดพลังการถูกโจมตีทุกศาสตร์ 24% & เพิ่มความว่องไว +20",
				Buff = {
					Speed = 20,
					Defense = { 24, "All" }
				},
				MaterialNeed = {
					Leather = 400,
					["Sea King's Blood"] = 6,
					["Hydra's Tail"] = 1
				}
			},
			[3] = {
				Info = "Reduce damage received from All 25.5% & + 25 Run Speed",
				InfoTH = "ลดพลังการถูกโจมตีทุกศาสตร์ 25.5% & เพิ่มความว่องไว +25",
				Buff = {
					Speed = 25,
					Defense = { 25.5, "All" }
				},
				MaterialNeed = {
					Leather = 400,
					["Sea King's Blood"] = 6,
					["Hydra's Tail"] = 1
				}
			}
		}
	},
	["Crimson Scarf"] = {
		Tier = "Epic",
		Image = "rbxassetid://12079938778",
		Upgrade = {
			[0] = {
				Info = "+7.5% Fruit damage & Reduce damage received from fruit 7.5%",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ 7.5% & ลดการโจมตีจากผลไม้ 7.5%",
				Buff = {
					Damage = { 7.5, "Fruit" },
					Defense = { 7.5, "Fruit" }
				}
			},
			[1] = {
				Info = "+15% Fruit damage & Reduce damage received from fruit 15%",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ 15% & ลดการโจมตีจากผลไม้ 15%",
				Buff = {
					Damage = { 15, "Fruit" },
					Defense = { 15, "Fruit" }
				},
				MaterialNeed = {
					Leather = 150,
					["Thief's rag"] = 12,
					Gunpowder = 10
				}
			},
			[2] = {
				Info = "+16% Fruit damage & Reduce damage received from fruit 16%",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ 16% & ลดการโจมตีจากผลไม้ 16%",
				Buff = {
					Damage = { 16, "Fruit" },
					Defense = { 16, "Fruit" }
				},
				MaterialNeed = {
					Leather = 150,
					["Thief's rag"] = 12,
					Gunpowder = 10
				}
			},
			[3] = {
				Info = "+17% Fruit damage & Reduce damage received from fruit 17%",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ 17% & ลดการโจมตีจากผลไม้ 17%",
				Buff = {
					Damage = { 17, "Fruit" },
					Defense = { 17, "Fruit" }
				},
				MaterialNeed = {
					Leather = 150,
					["Thief's rag"] = 12,
					Gunpowder = 10
				}
			}
		}
	},
	["Floffy Cloak"] = {
		Tier = "Rare",
		Image = "rbxassetid://12079936296",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from fruit 15%",
				InfoTH = "ลดการโจมตีจากผลไม้ 15%",
				Buff = {
					Defense = { 15, "Fruit" }
				}
			},
			[1] = {
				Info = "Reduce damage received from fruit 30%",
				InfoTH = "ลดการโจมตีจากผลไม้ 30%",
				Buff = {
					Defense = { 30, "Fruit" }
				},
				MaterialNeed = {
					Leather = 60,
					["Thief's rag"] = 5
				}
			},
			[2] = {
				Info = "Reduce damage received from fruit 32%",
				InfoTH = "ลดการโจมตีจากผลไม้ 32%",
				Buff = {
					Defense = { 32, "Fruit" }
				},
				MaterialNeed = {
					Leather = 60,
					["Thief's rag"] = 5
				}
			},
			[3] = {
				Info = "Reduce damage received from fruit 34%",
				InfoTH = "ลดการโจมตีจากผลไม้ 34%",
				Buff = {
					Defense = { 34, "Fruit" }
				},
				MaterialNeed = {
					Leather = 60,
					["Thief's rag"] = 5
				}
			}
		}
	},
	["Floffy Glasses"] = {
		Tier = "Legendary",
		Image = "rbxassetid://12079935531",
		Upgrade = {
			[0] = {
				Info = "+20% Fruit damage & + 10 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ 20% & เพิ่มความว่องไว +10",
				Buff = {
					Damage = { 20, "Fruit" },
					Speed = 10
				}
			},
			[1] = {
				Info = "+35% Fruit damage & + 20 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ 35% & เพิ่มความว่องไว +20",
				Buff = {
					Damage = { 35, "Fruit" },
					Speed = 20
				},
				MaterialNeed = {
					Carrot = 100,
					Gunpowder = 10,
					["Lost Ruby"] = 2,
					["Phoenix's Tear"] = 1
				}
			},
			[2] = {
				Info = "+35.5% Fruit damage & + 30 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ 35.5% & เพิ่มความว่องไว +30",
				Buff = {
					Damage = { 36, "Fruit" },
					Speed = 30
				},
				MaterialNeed = {
					Carrot = 100,
					Gunpowder = 10,
					["Lost Ruby"] = 2,
					["Phoenix's Tear"] = 1
				}
			},
			[3] = {
				Info = "+36% Fruit damage & + 40 Run Speed",
				InfoTH = "เพิ่มพลังการโจมตีของผลไม้ 36% & เพิ่มความว่องไว +40",
				Buff = {
					Damage = { 36, "Fruit" },
					Speed = 40
				},
				MaterialNeed = {
					Carrot = 100,
					Gunpowder = 10,
					["Lost Ruby"] = 2,
					["Phoenix's Tear"] = 1
				}
			}
		}
	},
	["Crustacean Armor"] = {
		Tier = "Legendary",
		Image = "http://www.roblox.com/asset/?id=15042336882",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from All 30% & +5,000 Health",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 30% & +5,000 Health",
				Buff = {
					Defense = { 30, "All" },
					Health = { 5000, "Normal" }
				}
			},
			[1] = {
				Info = "Reduce damage received from All 40% & +10,500 Health",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 40% & +10,500 พลังชีวิต",
				Buff = {
					Defense = { 40, "All" },
					Health = { 10500, "Normal" }
				},
				MaterialNeed = {
					["Pile of Bones"] = 500,
					["Shark's Canine"] = 30,
					["Sea King's Fin"] = 10,
					["Hydra's Tail"] = 1
				}
			},
			[2] = {
				Info = "Reduce damage received from All 41% & +15,500 Health",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 41% & +15,500 พลังชีวิต",
				Buff = {
					Defense = { 41, "All" },
					Health = { 15500, "Normal" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 100,
					Coral = 100,
					["Crab Meat"] = 2,
					["Hydra's Tail"] = 1
				}
			},
			[3] = {
				Info = "Reduce damage received from All 42% & +16,000 Health",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 42% & +16,000 พลังชีวิต",
				Buff = {
					Defense = { 42, "All" },
					Health = { 16000, "Normal" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 100,
					Coral = 100,
					["Crab Meat"] = 3,
					["Hydra's Tail"] = 1
				}
			}
		}
	},
	["Metal Fin"] = {
		Tier = "Epic",
		Image = "http://www.roblox.com/asset/?id=14839893601",
		Upgrade = {
			[0] = {
				Info = "+15% Water Style damage & Reduce damage received from Melee 10%",
				InfoTH = "เพิ่มพลังการโจมตีด้วย Water Style +15% & ลดการโจมตีจากหมัด 10%",
				Buff = {
					Damage = { 15, "Water Style" },
					Defense = { 10, "Melee" }
				}
			},
			[1] = {
				Info = "+25% Water Style damage & Reduce damage received from Melee 20%",
				InfoTH = "เพิ่มพลังการโจมตีด้วย Water Style +25% & ลดการโจมตีจากหมัด 20%",
				Buff = {
					Damage = { 25, "Water Style" },
					Defense = { 20, "Melee" }
				},
				MaterialNeed = {
					["Iron Ingot"] = 100,
					["Shark's Canine"] = 5,
					["Sea King's Fin"] = 5,
					["Hydra's Tail"] = 1
				}
			},
			[2] = {
				Info = "+26% Water Style damage & Reduce damage received from Melee 21%",
				InfoTH = "เพิ่มพลังการโจมตีด้วย Water Style +26% & ลดการโจมตีจากหมัด 21%",
				Buff = {
					Damage = { 26, "Water Style" },
					Defense = { 21, "Melee" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 100,
					["Shark's Canine"] = 5,
					["Sea King's Fin"] = 5,
					["Hydra's Tail"] = 1
				}
			},
			[3] = {
				Info = "+27% Water Style damage & Reduce damage received from Melee 22%",
				InfoTH = "เพิ่มพลังการโจมตีด้วย Water Style +27% & ลดการโจมตีจากหมัด 22%",
				Buff = {
					Damage = { 27, "Water Style" },
					Defense = { 22, "Melee" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 100,
					["Shark's Canine"] = 5,
					["Sea King's Fin"] = 5,
					["Hydra's Tail"] = 1
				}
			}
		}
	},
	["Oceanic Tentacle"] = {
		Tier = "Epic",
		Image = "rbxassetid://14839892649",
		Upgrade = {
			[0] = {
				Info = "+10% Melee damage & Reduce damage received from Melee 5%",
				InfoTH = "เพิ่มพลังโจมตีหมัด +10% & ลดการโจมตีจากหมัด 5%",
				Buff = {
					Damage = { 10, "Melee" },
					Defense = { 5, "Melee" }
				}
			},
			[1] = {
				Info = "+15% Melee damage & Reduce damage received from Melee 10%",
				InfoTH = "เพิ่มพลังโจมตีหมัด +15% & ลดการโจมตีจากหมัด 10%",
				Buff = {
					Damage = { 15, "Melee" },
					Defense = { 10, "Melee" }
				},
				MaterialNeed = {
					["Fresh Fish"] = 75,
					["Shark's Canine"] = 5,
					["Sea King's Fin"] = 5,
					["Severed Kraken"] = 3
				}
			},
			[2] = {
				Info = "+16% Melee damage & Reduce damage received from Melee 11%",
				InfoTH = "เพิ่มพลังโจมตีหมัด +16% & ลดการโจมตีจากหมัด 11%",
				Buff = {
					Damage = { 16, "Melee" },
					Defense = { 11, "Melee" }
				},
				MaterialNeed = {
					["Fresh Fish"] = 100,
					["Shark's Canine"] = 10,
					["Sea King's Fin"] = 10,
					["Severed Kraken"] = 5
				}
			},
			[3] = {
				Info = "+17% Melee damage & Reduce damage received from Melee 12%",
				InfoTH = "เพิ่มพลังโจมตีหมัด +17% & ลดการโจมตีจากหมัด 12%",
				Buff = {
					Damage = { 17, "Melee" },
					Defense = { 12, "Melee" }
				},
				MaterialNeed = {
					["Fresh Fish"] = 125,
					["Shark's Canine"] = 20,
					["Sea King's Fin"] = 20,
					["Severed Kraken"] = 10
				}
			}
		}
	},
	["Shadow Cloak"] = {
		Tier = "Uncommon",
		Image = "http://www.roblox.com/asset/?id=14839889363",
		Upgrade = {
			[0] = {
				Info = "+500 Health & + 13 Run Speed",
				InfoTH = "เพิ่มพลังชีวิต +500 & ความว่องไว + 13",
				Buff = {
					Health = { 500, "Normal" },
					Speed = 13
				}
			},
			[1] = {
				Info = "+500 Health & + 20 Run Speed",
				InfoTH = "เพิ่มพลังชีวิต +500 & ความว่องไว + 20",
				Buff = {
					Health = { 500, "Normal" },
					Speed = 20
				},
				MaterialNeed = {
					Leather = 50,
					["Shark's Canine"] = 5
				}
			},
			[2] = {
				Info = "+600 Health & + 25 Run Speed",
				InfoTH = "เพิ่มพลังชีวิต +600 & ความว่องไว + 25",
				Buff = {
					Health = { 600, "Normal" },
					Speed = 25
				},
				MaterialNeed = {
					Leather = 50,
					["Shark's Canine"] = 5
				}
			},
			[3] = {
				Info = "+700 Health & + 30 Run Speed",
				InfoTH = "เพิ่มพลังชีวิต +700 & ความว่องไว + 30",
				Buff = {
					Health = { 700, "Normal" },
					Speed = 30
				},
				MaterialNeed = {
					Leather = 50,
					["Shark's Canine"] = 5
				}
			}
		}
	},
	["Sentinel Armor"] = {
		Tier = "Uncommon",
		Image = "http://www.roblox.com/asset/?id=14839895623",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from All 5% & + 2 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 5% & ความว่องไว + 2",
				Buff = {
					Defense = { 5, "All" },
					Speed = 2
				}
			},
			[1] = {
				Info = "Reduce damage received from All 10% & +10 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 10% & ความว่องไว +10",
				Buff = {
					Defense = { 10, "All" },
					Speed = 10
				},
				MaterialNeed = {
					["Rusted Scrap"] = 30,
					["Iron Ingot"] = 10
				}
			},
			[2] = {
				Info = "Reduce damage received from All 12% & +20 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 12% & ความว่องไว +20",
				Buff = {
					Defense = { 12, "All" },
					Speed = 20
				},
				MaterialNeed = {
					["Rusted Scrap"] = 30,
					["Iron Ingot"] = 10
				}
			},
			[3] = {
				Info = "Reduce damage received from All 14% & +30 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 14% & ความว่องไว +30",
				Buff = {
					Defense = { 14, "All" },
					Speed = 30
				},
				MaterialNeed = {
					["Rusted Scrap"] = 30,
					["Iron Ingot"] = 10
				}
			}
		}
	},
	["Abyss Sentinel Armor"] = {
		Tier = "Epic",
		Image = "http://www.roblox.com/asset/?id=14839894949",
		Upgrade = {
			[0] = {
				Info = "+15% Dark damage & Reduce damage received from fruit 10%",
				InfoTH = "เพิ่มพลังการโจมตีด้วยผลความมืด +15% & ลดการโจมตีจากผลไม้ 10%",
				Buff = {
					Damage = { 15, "Dark" },
					Defense = { 10, "Fruit" }
				}
			},
			[1] = {
				Info = "+25% Dark damage & Reduce damage received from fruit 15%",
				InfoTH = "เพิ่มพลังการโจมตีด้วยผลความมืด +25% & ลดการโจมตีจากผลไม้ 15%",
				Buff = {
					Damage = { 25, "Dark" },
					Defense = { 15, "Fruit" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 100,
					["Iron Ingot"] = 35,
					["Dark Beard's Totem"] = 15
				}
			},
			[2] = {
				Info = "+26% Dark damage & Reduce damage received from fruit 16%",
				InfoTH = "เพิ่มพลังการโจมตีด้วยผลความมืด +26% & ลดการโจมตีจากผลไม้ 16%",
				Buff = {
					Damage = { 26, "Dark" },
					Defense = { 16, "Fruit" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 100,
					["Iron Ingot"] = 35,
					["Dark Beard's Totem"] = 20
				}
			},
			[3] = {
				Info = "+27% Dark damage & Reduce damage received from fruit 17%",
				InfoTH = "เพิ่มพลังการโจมตีด้วยผลความมืด +27% & ลดการโจมตีจากผลไม้ 17%",
				Buff = {
					Damage = { 27, "Dark" },
					Defense = { 17, "Fruit" }
				},
				MaterialNeed = {
					["Rusted Scrap"] = 100,
					["Iron Ingot"] = 35,
					["Dark Beard's Totem"] = 25
				}
			}
		}
	},
	["Polar Bear Hat"] = {
		Tier = "Uncommon",
		Image = "http://www.roblox.com/asset/?id=14839896260",
		Upgrade = {
			[0] = {
				Info = "+500 Health & Reduce damage received from Melee 5%",
				InfoTH = "เพิ่มพลังชีวิต +500 & ลดการถูกโจมตีจากหมัด 5%",
				Buff = {
					Health = { 500, "Normal" },
					Damage = { 5, "Melee" }
				}
			},
			[1] = {
				Info = "+1000 Health & Reduce damage received from Melee 10%",
				InfoTH = "เพิ่มพลังชีวิต +1000 & ลดการถูกโจมตีจากหมัด 10%",
				Buff = {
					Health = { 1000, "Normal" },
					Damage = { 10, "Melee" }
				},
				MaterialNeed = {
					Leather = 75,
					["Thief's rag"] = 5
				}
			},
			[2] = {
				Info = "+2000 Health & Reduce damage received from Melee 12%",
				InfoTH = "เพิ่มพลังชีวิต +2000 & ลดการถูกโจมตีจากหมัด 12%",
				Buff = {
					Health = { 2000, "Normal" },
					Damage = { 12, "Melee" }
				},
				MaterialNeed = {
					Leather = 75,
					["Thief's rag"] = 5
				}
			},
			[3] = {
				Info = "+3000 Health & Reduce damage received from Melee 14%",
				InfoTH = "เพิ่มพลังชีวิต +3000 & ลดการถูกโจมตีจากหมัด 14%",
				Buff = {
					Health = { 3000, "Normal" },
					Damage = { 14, "Melee" }
				},
				MaterialNeed = {
					Leather = 75,
					["Thief's rag"] = 5
				}
			}
		}
	},
	["Stealth Cape"] = {
		Tier = "Epic",
		Image = "http://www.roblox.com/asset/?id=14839889990",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from All 12% & + 8 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 12% & ความว่องไว + 8",
				Buff = {
					Defense = { 12, "All" },
					Speed = 8
				}
			},
			[1] = {
				Info = "Reduce damage received from All 20% & + 16 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 20% & ความว่องไว + 16",
				Buff = {
					Defense = { 20, "All" },
					Speed = 16
				},
				MaterialNeed = {
					Leather = 75,
					["Bread Crumbs"] = 20,
					Gunpowder = 8
				}
			},
			[2] = {
				Info = "Reduce damage received from All 21% & + 20 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 21% & ความว่องไว + 20",
				Buff = {
					Defense = { 21, "All" },
					Speed = 20
				},
				MaterialNeed = {
					Leather = 75,
					["Bread Crumbs"] = 20,
					Gunpowder = 8
				}
			},
			[3] = {
				Info = "Reduce damage received from All 22% & + 24 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 22% & ความว่องไว + 24",
				Buff = {
					Defense = { 22, "All" },
					Speed = 24
				},
				MaterialNeed = {
					Leather = 75,
					["Bread Crumbs"] = 20,
					Gunpowder = 8
				}
			}
		}
	},
	["Empress Kimono"] = {
		Tier = "Legendary",
		Image = "http://www.roblox.com/asset/?id=14839888626",
		Upgrade = {
			[0] = {
				Info = "Reduce damage received from All 17% & +5% Fruit damage & + 4 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 17% & เพิ่มพลังการโจมตีด้วยผลไม้ +5% & ความว่องไว + 4",
				Buff = {
					Defense = { 17, "All" },
					Damage = { 5, "Fruit" },
					Speed = 4
				}
			},
			[1] = {
				Info = "Reduce damage received from All 22% & +10% Fruit damage & + 8 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 22% & เพิ่มพลังการโจมตีด้วยผลไม้ +10% & ความว่องไว + 8",
				Buff = {
					Defense = { 22, "All" },
					Damage = { 10, "Fruit" },
					Speed = 8
				},
				MaterialNeed = {
					Leather = 77,
					["Thief's rag"] = 7,
					["Samurai's Badage"] = 2,
					["Phoenix's Tear"] = 1
				}
			},
			[2] = {
				Info = "Reduce damage received from All 24% & +12% Fruit damage & + 12 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 24% & เพิ่มพลังการโจมตีด้วยผลไม้ +12% & ความว่องไว + 12",
				Buff = {
					Defense = { 24, "All" },
					Damage = { 12, "Fruit" },
					Speed = 12
				},
				MaterialNeed = {
					Leather = 77,
					["Thief's rag"] = 7,
					["Samurai's Badage"] = 2,
					["Phoenix's Tear"] = 1
				}
			},
			[3] = {
				Info = "Reduce damage received from All 26% & +14% Fruit damage & + 16 Run Speed",
				InfoTH = "ลดการโจมตีทุกศาสตร์ 26% & เพิ่มพลังการโจมตีด้วยผลไม้ +14% & ความว่องไว + 16",
				Buff = {
					Defense = { 26, "All" },
					Damage = { 14, "Fruit" },
					Speed = 16
				},
				MaterialNeed = {
					Leather = 77,
					["Thief's rag"] = 7,
					["Samurai's Badage"] = 2,
					["Phoenix's Tear"] = 1
				}
			}
		}
	},
	["Oceanic Tanto"] = {
		Tier = "Legendary",
		Image = "rbxassetid://110029110858842",
		Upgrade = {
			[0] = {
				Info = "+11% Sword damage & Reduce damage received from Sword 11% ",
				InfoTH = "เพิ่มพลังโจมตีดาบ +11% & ลดการถูกโจมตีด้วยดาบ 11%",
				Buff = {
					Damage = { 11, "Sword" },
					Defense = { 11, "Sword" }
				}
			},
			[1] = {
				Info = "+17% Sword damage & Reduce damage received from Sword 22% ",
				InfoTH = "เพิ่มพลังโจมตีดาบ +17% & ลดการถูกโจมตีด้วยดาบ 22%",
				Buff = {
					Damage = { 17, "Sword" },
					Defense = { 22, "Sword" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 100,
					Coral = 50,
					Pearl = 25,
					["Noir Pearl"] = 2,
					["Heart of Sea"] = 1
				}
			},
			[2] = {
				Info = "+20% Sword damage & Reduce damage received from Sword 28% ",
				InfoTH = "เพิ่มพลังโจมตีดาบ +20% & ลดการถูกโจมตีด้วยดาบ 28%",
				Buff = {
					Damage = { 20, "Sword" },
					Defense = { 28, "Sword" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 150,
					Coral = 75,
					Pearl = 35,
					["Noir Pearl"] = 3,
					["Heart of Sea"] = 2
				}
			},
			[3] = {
				Info = "+22% Sword damage & Reduce damage received from Sword 35% ",
				InfoTH = "เพิ่มพลังโจมตีดาบ +22% & ลดการถูกโจมตีด้วยดาบ 35%",
				Buff = {
					Damage = { 22, "Sword" },
					Defense = { 35, "Sword" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 250,
					Coral = 100,
					Pearl = 40,
					["Noir Pearl"] = 5,
					["Heart of Sea"] = 3
				}
			}
		}
	},
	["Dominion Cloak"] = {
		Tier = "Legendary",
		Image = "rbxassetid://133256129376426",
		Upgrade = {
			[0] = {
				Info = "+20% Control damage & +7% Health",
				InfoTH = "เพิ่มพลังการโจมตีด้วย Control +20% & เพิ่มพลังชีวิต +7%",
				Buff = {
					Damage = { 20, "Control" },
					Health = { 7, "Extra" }
				}
			},
			[1] = {
				Info = "+25% Control damage & +12% Health",
				InfoTH = "เพิ่มพลังการโจมตีด้วย Control +25% & เพิ่มพลังชีวิต +12%",
				Buff = {
					Damage = { 25, "Control" },
					Health = { 12, "Extra" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 50,
					["Shark's Fin"] = 25,
					["Sea King's Blood"] = 10,
					["Kraken's Ink"] = 2,
					["Dragon Fang"] = 1
				}
			},
			[2] = {
				Info = "+30% Control damage & +17% Health",
				InfoTH = "เพิ่มพลังการโจมตีด้วย Control +30% & เพิ่มพลังชีวิต +17%",
				Buff = {
					Damage = { 30, "Control" },
					Health = { 17, "Extra" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 100,
					["Shark's Fin"] = 50,
					["Sea King's Blood"] = 20,
					["Kraken's Ink"] = 3,
					["Dragon Fang"] = 1
				}
			},
			[3] = {
				Info = "+35% Control damage & +22% Health",
				InfoTH = "เพิ่มพลังการโจมตีด้วย Control +35% & เพิ่มพลังชีวิต +22%",
				Buff = {
					Damage = { 35, "Control" },
					Health = { 22, "Extra" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 150,
					["Shark's Fin"] = 75,
					["Sea King's Blood"] = 30,
					["Kraken's Ink"] = 5,
					["Dragon Fang"] = 2
				}
			}
		}
	},
	["Drakenfyr Cape"] = {
		["Drop Boost"] = {
			Max = 100
		},
		Tier = "Legendary",
		Image = "rbxassetid://74561017638742",
		Upgrade = {
			[0] = {
				Info = "+10% All Damage & +5K Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +10% & +5,000 พลังชีวิต",
				Buff = {
					Damage = { 10, "All" },
					Health = { 5000, "Normal" }
				}
			},
			[1] = {
				Info = "+15% All Damage & +10K Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +10% & +10,000 พลังชีวิต",
				Buff = {
					Damage = { 15, "All" },
					Health = { 10000, "Normal" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 70,
					["Shark's Fin"] = 30,
					["Sea King's Blood"] = 10,
					["Severed Kraken"] = 5,
					["Dragon Fang"] = 1
				}
			},
			[2] = {
				Info = "+17.5% All Damage & +15K Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +17.5% & +15,000 พลังชีวิต",
				Buff = {
					Damage = { 17.5, "All" },
					Health = { 15000, "Normal" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 100,
					["Shark's Fin"] = 50,
					["Sea King's Blood"] = 15,
					["Severed Kraken"] = 10,
					["Dragon Fang"] = 2
				}
			},
			[3] = {
				Info = "+20% All Damage & +20K Health",
				InfoTH = "เพิ่มพลังทุกศาสตร์ +20% & +20,000 พลังชีวิต",
				Buff = {
					Damage = { 20, "All" },
					Health = { 20000, "Normal" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 150,
					["Shark's Fin"] = 75,
					Pearl = 20,
					["Noir Pearl"] = 5,
					["Dragon Bones"] = 1
				}
			}
		}
	},
	["Steel Knight Armor"] = {
		Tier = "Legendary",
		Image = "rbxassetid://94957725826932",
		Info = "Heavy armor forged with the power of the sea.",
		InfoTH = "ชุดเกราะนักรบที่หลอมเข้ากับพลังแห่งโลกใต้โลกา",
		Upgrade = {
			[0] = {
				Info = "+7% Sword Damage & Reduce damage received from fruit 20% & +10% Health",
				InfoTH = "เพิ่มพลังโจมตีดาบ +7% & ลดการโจมตีจากผลไม้ 20% & +10% พลังชีวิต",
				Buff = {
					Damage = { 7, "Sword" },
					Defense = { 20, "Fruit" },
					Health = { 10, "Extra" }
				}
			},
			[1] = {
				Info = "+12% Sword Damage & Reduce damage received from fruit 30% & +15% Health",
				InfoTH = "เพิ่มพลังโจมตีดาบ +12% & ลดการโจมตีจากผลไม้ 30% & +15% พลังชีวิต",
				Buff = {
					Damage = { 12, "Sword" },
					Defense = { 30, "Fruit" },
					Health = { 15, "Extra" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 70,
					["Shark's Fin"] = 30,
					["Dragon Scale"] = 15,
					["Sea King's Blood"] = 10,
					["Severed Kraken"] = 5
				}
			},
			[2] = {
				Info = "+17% Sword Damage & Reduce damage received from fruit 40% & +20% Health",
				InfoTH = "เพิ่มพลังโจมตีดาบ +17% & ลดการโจมตีจากผลไม้ 40% & +20% พลังชีวิต",
				Buff = {
					Damage = { 17, "Sword" },
					Defense = { 40, "Fruit" },
					Health = { 20, "Extra" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 100,
					["Shark's Fin"] = 35,
					["Dragon Scale"] = 20,
					["Sea King's Blood"] = 15,
					["Severed Kraken"] = 10
				}
			},
			[3] = {
				Info = "+20% Sword Damage & Reduce damage received from fruit 50% & +25% Health",
				InfoTH = "เพิ่มพลังโจมตีดาบ +20% & ลดการโจมตีจากผลไม้ 50% & +25% พลังชีวิต",
				Buff = {
					Damage = { 20, "Sword" },
					Defense = { 50, "Fruit" },
					Health = { 25, "Extra" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 150,
					["Shark's Fin"] = 50,
					["Dragon Scale"] = 30,
					["Sea King's Blood"] = 20,
					["Severed Kraken"] = 15
				}
			}
		},
		CraftList = {
			MaterialNeed = {
				["Sea Artifact"] = 300,
				["Iron Ingot"] = 150,
				["Dragon Scale"] = 50,
				["Sea King's Blood"] = 25,
				["Noir Pearl"] = 10,
				["Dragon Fang"] = 3
			},
			CraftWith = "Serpentforger Elwyn"
		}
	},
	["Abyssal Tyrant Armor"] = {
		["Drop Boost"] = {
			Max = 500
		},
		Tier = "Mythical",
		Image = "rbxassetid://111727677212381",
		Upgrade = {
			[0] = {
				Info = "+13% Sword Damage & Reduce damage received from All 15% & +20% Health & +2 Extra Dodges",
				InfoTH = "เพิ่มพลังโจมตีดาบ +13% & ลดการโจมตีทุกศาสตร์ 15% & +20% พลังชีวิต & +2 การหลบหลีก",
				Buff = {
					Damage = { 13, "Sword" },
					Defense = { 15, "All" },
					Health = { 20, "Extra" }
				}
			},
			[1] = {
				Info = "+17.5% Sword Damage & Reduce damage received from All 20% & +25% Health & +2 Extra Dodges",
				InfoTH = "เพิ่มพลังโจมตีดาบ +17.5% & ลดการโจมตีทุกศาสตร์ 20% & +25% พลังชีวิต & +2 การหลบหลีก",
				Buff = {
					Damage = { 17.5, "Sword" },
					Defense = { 20, "All" },
					Health = { 25, "Extra" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 100,
					["Iron Ingot"] = 50,
					Coral = 30,
					Pearl = 10,
					["Noir Pearl"] = 3,
					["Dragon Fang"] = 1
				}
			},
			[2] = {
				Info = "+22% Sword Damage & Reduce damage received from All 25% & +30% Health & +2 Extra Dodges",
				InfoTH = "เพิ่มพลังโจมตีดาบ +22% & ลดการโจมตีทุกศาสตร์ 25% & +30% พลังชีวิต & +2 การหลบหลีก",
				Buff = {
					Damage = { 22, "Sword" },
					Defense = { 25, "All" },
					Health = { 30, "Extra" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 150,
					["Iron Ingot"] = 75,
					Coral = 50,
					Pearl = 15,
					["Noir Pearl"] = 5,
					["Dragon Fang"] = 2
				}
			},
			[3] = {
				Info = "+27% Sword Damage & Reduce damage received from All 30% & +35% Health & +2 Extra Dodges",
				InfoTH = "เพิ่มพลังโจมตีดาบ +27% & ลดการโจมตีทุกศาสตร์ 30% & +35% พลังชีวิต & +2 การหลบหลีก",
				Buff = {
					Damage = { 27, "Sword" },
					Defense = { 30, "All" },
					Health = { 35, "Extra" }
				},
				MaterialNeed = {
					["Sea Artifact"] = 250,
					["Iron Ingot"] = 100,
					Coral = 75,
					Pearl = 25,
					["Dragon Fang"] = 3,
					["Dragon Bones"] = 1
				}
			}
		}
	},
	["Eclipse Tyrant Armor"] = {
		Tier = "Exotic",
		Image = "rbxassetid://92548536801428",
		Upgrade = {
			[0] = {
				Info = "+50 Run Speed & +5000% All Damage & + 500 Extra Dodges & + 500 Sky Jumps",
				InfoTH = "ของดราโก้",
				Buff = {
					Damage = { 5000, "All" },
					Speed = 50
				}
			},
			[1] = {
				Info = "+50 Run Speed & +5000% All Damage & + 500 Extra Dodges & + 500 Sky Jumps",
				InfoTH = "ของดราโก้",
				Buff = {
					Damage = { 5000, "All" },
					Speed = 50
				},
				MaterialNeed = {
					["Dragon Bones"] = 999
				}
			},
			[2] = {
				Info = "+50 Run Speed & +5000% All Damage & + 500 Extra Dodges & + 500 Sky Jumps",
				InfoTH = "ของดราโก้",
				Buff = {
					Damage = { 5000, "All" },
					Speed = 50
				},
				MaterialNeed = {
					["Dragon Bones"] = 999
				}
			},
			[3] = {
				Info = "+50 Run Speed & +5000% All Damage & + 500 Extra Dodges & + 500 Sky Jumps",
				InfoTH = "ของดราโก้",
				Buff = {
					Damage = { 5000, "All" },
					Speed = 50
				},
				MaterialNeed = {
					["Dragon Bones"] = 999
				}
			}
		}
	}
}