local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldsId = require(ReplicatedStorage:WaitForChild("Chest").Modules.WorldsId)
local placeId = game.PlaceId
local v = 1

for _, v2 in pairs(WorldsId) do
	for k, v4 in pairs(v2) do
		if placeId ~= v4 then
			continue
		end

		v = k == "SecondSea" and 2 or k == "ThirdSea" and 3 or 1
		break
	end
end

return {
	Beck = {
		Name = "Beck",
		BorderImage = "rbxassetid://15178389155",
		Distance = 300
	},
	["Pteranodon [Lv. 12500]"] = {
		Name = "Pteranodon [Lv. 12500]",
		BorderImage = "rbxassetid://15178389155",
		Distance = 300,
		Drops = {
			["Essence of Fire"] = "10%",
			["Phoenix's Tear"] = "5%",
			Pyreblade = "0.5%"
		}
	},
	["Allosaurus [Lv. 5350]"] = {
		Name = "Allosaurus [Lv. 5350]",
		BorderImage = "rbxassetid://15178389155",
		Distance = 300,
		Drops = {
			["Sea Artifact"] = "30%",
			Pearl = "10%",
			["Essence of Fire"] = "2%"
		}
	},
	["Spinosaurus [Lv. 5400]"] = {
		Name = "Spinosaurus [Lv. 5400]",
		BorderImage = "rbxassetid://15178389155",
		Distance = 300,
		Drops = {
			["Pile of Bones"] = "30%",
			Pearl = "10%",
			["Essence of Fire"] = "2%"
		}
	},
	Serpent = {
		Name = "Serpent",
		BorderImage = "rbxassetid://15178389155",
		Distance = 400,
		Drops = function()
			if v == 1 then
				return {
					Acrodagger = "0.125%",
					Acromask = "0.225%",
					["Serpent Fin"] = "5%",
					["Serpent Heart"] = "0.5%"
				}
			elseif v == 2 then
				return {
					Acrodagger = "0.15%",
					Acromask = "0.25%",
					["Serpent Fin"] = "6%",
					["Serpent Heart"] = "1%"
				}
			elseif v == 3 then
				return {
					Acrodagger = "0.35%",
					Acromask = "0.5%",
					["Serpent Fin"] = "7%",
					["Serpent Heart"] = "2%"
				}
			end
		end
	},
	["Shark Galleon Boss"] = {
		Name = "Shark Galleon",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Shark Galleon Ability"] = "3%"
		}
	},
	["Royal Galleon Boss"] = {
		Name = "Royal Galleon",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Royal Galleon Ability"] = "3%"
		}
	},
	["Ghost Galleon Boss"] = {
		Name = "Ghost Galleon",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Ghost Galleon Ability"] = "3%"
		}
	},
	["Galleon Boss"] = {
		Name = "Galleon",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Galleon Ability"] = "3%"
		}
	},
	["Kraken Galleon Boss"] = {
		Name = "Kraken Galleon",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Kraken Galleon Ability"] = "3%"
		}
	},
	["Whale Galleon Boss"] = {
		Name = "Whale Galleon",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Whale Galleon Ability"] = "3%"
		}
	},
	["Veyzor [Lv. 10000]"] = {
		Name = "Veyzor [Lv. 10000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Infernal Manehelm"] = "0.1%",
			["Iridium Key"] = "0.3%"
		}
	},
	["Chaos Crab [Lv. 10000]"] = {
		Name = "Chaos Crab [Lv. 10000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Bloodshell Edge"] = "0.2%",
			["Iridium Key"] = "0.5%"
		}
	},
	["Craberno [Lv. 15000]"] = {
		Name = "Craberno [Lv. 15000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			Shellreaper = "0.1%",
			["Iridium Key"] = "1%"
		}
	},
	["Caltherion [Lv. 10000]"] = {
		Name = "Caltherion [Lv. 10000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Wildclaw [Lv. 10000]"] = {
		Name = "Wildclaw [Lv. 10000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Dravhiel [Lv. 10000]"] = {
		Name = "Dravhiel [Lv. 10000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Morzareth [Lv. 10000]"] = {
		Name = "Morzareth [Lv. 10000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Thamior [Lv. 10000]"] = {
		Name = "Thamior [Lv. 10000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Ravthus [Lv. 10000]"] = {
		Name = "Ravthus [Lv. 10000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Ashen Talon [Lv. 10000]"] = {
		Name = "Ashen Talon [Lv. 10000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			Dawnbreaker = "5%"
		}
	},
	["Prisoner of Gravity [Lv. 4875]"] = {
		Name = "Prisoner of Gravity [Lv. 4875]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Sea Artifact"] = "30%"
		}
	},
	["Shadowbane [Lv. 2000]"] = {
		Name = "Shadowbane [Lv. 2000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Magma Warden [Lv. 5000]"] = {
		Name = "Magma Warden [Lv. 5000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Lightbane [Lv. 3000]"] = {
		Name = "Lightbane [Lv. 3000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Anuvaris [Lv. 3250]"] = {
		Name = "Anuvaris [Lv. 3250]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Firelord [Lv. 3500]"] = {
		Name = "Firelord [Lv. 3500]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Darkbane Sentinel [Lv. 3000]"] = {
		Name = "Darkbane Sentinel [Lv. 3000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Shadow Cloak"] = "10%"
		}
	},
	["Shockwarden [Lv. 3750]"] = {
		Name = "Shockwarden [Lv. 3750]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Sentinel Armor"] = "2%"
		}
	},
	["Gravity Warden [Lv. 4000]"] = {
		Name = "Gravity Warden [Lv. 4000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Ice Warden [Lv. 5000]"] = {
		Name = "Ice Warden [Lv. 5000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Mike [Lv. 7500]"] = {
		Name = "Mike [Lv. 7500]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Night Necklace"] = "2%"
		}
	},
	["Bomb Warden [Lv. 3500]"] = {
		Name = "Bomb Warden [Lv. 3500]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Dark Warden [Lv. 5000]"] = {
		Name = "Dark Warden [Lv. 5000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Abyss Sentinel Armor"] = "2%"
		}
	},
	["Flame Warden [Lv. 5000]"] = {
		Name = "Flame Warden [Lv. 5000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Heartbreaker Queen [Lv. 5000]"] = {
		Name = "Heartbreaker Queen [Lv. 5000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Light Warden [Lv. 5000]"] = {
		Name = "Light Warden [Lv. 5000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Volcanus [Lv. 3000]"] = {
		Name = "Volcanus [Lv. 3000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Metal Fin"] = "5%"
		}
	},
	["Smoky [Lv. 20]"] = {
		Name = "Smoky [Lv. 20]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Rusted Scrap"] = "30%",
			Jitter = "25%"
		}
	},
	["Tashi [Lv. 30]"] = {
		Name = "Tashi [Lv. 30]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Rusted Scrap"] = "30%",
			["Tashi Blade"] = "25%"
		}
	},
	["The Clown [Lv. 75]"] = {
		Name = "The Clown [Lv. 75]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Leather = "30%"
		}
	},
	["The Barbaric [Lv. 145]"] = {
		Name = "The Barbaric [Lv. 145]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Barbaric Axe"] = "20%",
			["Stainless Jaw"] = "15%",
			["Rusted Scrap"] = "30%"
		}
	},
	["Ball Man [Lv. 850]"] = {
		Name = "Ball Man [Lv. 850]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Angellic's Feather"] = "30%",
			Gunpowder = "10%"
		}
	},
	["Bomb Man [Lv. 625]"] = {
		Name = "Bomb Man [Lv. 625]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Gunpowder = "10%"
		}
	},
	["Candle Man [Lv. 525]"] = {
		Name = "Candle Man [Lv. 525]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100
	},
	["Captain [Lv. 120]"] = {
		Name = "Captain [Lv. 120]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100
	},
	["Combat Fishman [Lv. 2050]"] = {
		Name = "Combat Fishman [Lv. 2050]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Fresh Fish"] = "20%",
			["Shark's Canine"] = "5%"
		}
	},
	["Dark Leg [Lv. 300]"] = {
		Name = "Dark Leg [Lv. 300]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100
	},
	["Dory [Lv. 350]"] = {
		Name = "Dory [Lv. 350]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Rusted Scrap"] = "30%",
			["Gold Spear"] = "20%",
			Gunpowder = "10%"
		}
	},
	["Giraffe [Lv. 1300]"] = {
		Name = "Giraffe [Lv. 1300]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Leather Scrap"] = "30%"
		}
	},
	["Karate Fishman [Lv. 200]"] = {
		Name = "Karate Fishman [Lv. 200]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Fresh Fish"] = "20%",
			["Shark's Canine"] = "5%"
		}
	},
	["King Snow [Lv. 450]"] = {
		Name = "King Snow [Lv. 450]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Gunpowder = "10%"
		}
	},
	["King of Sand [Lv. 725]"] = {
		Name = "King of Sand [Lv. 725]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Thief's rag"] = "20%"
		}
	},
	["Leader [Lv. 1100]"] = {
		Name = "Leader [Lv. 1100]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Rusted Scrap"] = "30%"
		}
	},
	["Leo [Lv. 1450]"] = {
		Name = "Leo [Lv. 1450]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Leather = "30%"
		}
	},
	["Little Dear [Lv. 500]"] = {
		Name = "Little Dear [Lv. 500]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Leather = "30%",
			["Horned Hat"] = "15%"
		}
	},
	["Pasta [Lv. 1150]"] = {
		Name = "Pasta [Lv. 1150]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Gunpowder = "10%"
		}
	},
	["Quake Woman [Lv. 1925]"] = {
		Name = "Quake Woman [Lv. 1925]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Rusted Scrap"] = "30%",
			Bisento = "5%"
		}
	},
	["Rumble Man [Lv. 950]"] = {
		Name = "Rumble Man [Lv. 950]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Angellic's Feather"] = "30%",
			Pole = "5%"
		}
	},
	["Seasoned Fishman [Lv. 2200]"] = {
		Name = "Seasoned Fishman [Lv. 2200]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Demon Trident"] = "20%",
			["Fresh Fish"] = "20%",
			["Shark's Canine"] = "5%"
		}
	},
	["Shadow Master [Lv. 1650]"] = {
		Name = "Shadow Master [Lv. 1650]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Vampire's Vital fluid"] = "5%",
			["Twilight's Orb"] = "2%"
		}
	},
	["Shark Man [Lv. 230]"] = {
		Name = "Shark Man [Lv. 230]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Shark Blade"] = "20%",
			["Fresh Fish"] = "20%",
			["Shark's Canine"] = "5%"
		}
	},
	["Sword Fishman [Lv. 2100]"] = {
		Name = "Sword Fishman [Lv. 2100]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Fresh Fish"] = "20%",
			["Shark's Canine"] = "5%"
		}
	},
	["True Karate Fishman [Lv. 1850]"] = {
		Name = "True Karate Fishman [Lv. 1850]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Fresh Fish"] = "20%",
			["Shark's Canine"] = "5%"
		}
	},
	["Wolf [Lv. 1250]"] = {
		Name = "Wolf [Lv. 1250]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Leather = "30%"
		}
	},
	["Anubis [Lv. 3150]"] = {
		Name = "Anubis [Lv. 3150]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Iron Ingot"] = "20%",
			["Lost Ruby"] = "5%",
			["Anubis Axe"] = "30%"
		}
	},
	["Bean [Lv. 2800]"] = {
		Name = "Bean [Lv. 2800]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Leather = "30%",
			Carrot = "30%"
		}
	},
	["Bear Man [Lv. 2750]"] = {
		Name = "Bear Man [Lv. 2750]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Leather = "30%",
			Carrot = "30%"
		}
	},
	["Biscuit Man [Lv. 3250]"] = {
		Name = "Biscuit Man [Lv. 3250]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Bread Crumbs"] = "20%",
			["Iron Ingot"] = "20%",
			["Biscuit Shoulder"] = "10%",
			["Cookie Sword"] = "5%"
		}
	},
	["Desert Thief [Lv. 3125]"] = {
		Name = "Desert Thief [Lv. 3125]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Thief's rag"] = "20%"
		}
	},
	["Devastate [Lv. 3725]"] = {
		Name = "Devastate [Lv. 3725]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Gunpowder = "10%"
		}
	},
	["Dough Master [Lv. 3275]"] = {
		Name = "Dough Master [Lv. 3275]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Bread Crumbs"] = "20%",
			["Iron Ingot"] = "20%",
			["Metal Trident"] = "5%",
			["Blue Scarf"] = "3%"
		}
	},
	["The Crimson Demon [Lv. 3375]"] = {
		Name = "The Crimson Demon [Lv. 3375]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Oni Mask"] = "5%"
		}
	},
	["The Ice King [Lv. 3350]"] = {
		Name = "The Ice King [Lv. 3350]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Tengu Mask"] = "5%"
		}
	},
	["Duke [Lv. 2550]"] = {
		Name = "Duke [Lv. 2550]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Leather = "30%",
			Carrot = "30%"
		}
	},
	["Elite Skeleton [Lv. 3100]"] = {
		Name = "Elite Skeleton [Lv. 3100]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Pile of Bones"] = "30%",
			["Dragon's Orb"] = "2%"
		}
	},
	["Flame User [Lv. 3200]"] = {
		Name = "Flame User [Lv. 3200]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Adventure Knife"] = "10%",
			["Essence of Fire"] = "2%"
		}
	},
	["Floffy [Lv. 3775]"] = {
		Name = "Floffy [Lv. 3775]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Gunpowder = "10%",
			["Floffy Cloak"] = "2%",
			["Floffy Glasses"] = "0.8%"
		}
	},
	["Gazelle Man [Lv. 2350]"] = {
		Name = "Gazelle Man [Lv. 2350]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Carrot = "30%",
			Leather = "30%",
			["Gazelle Mask"] = "5%"
		}
	},
	["Hefty [Lv. 3550]"] = {
		Name = "Hefty [Lv. 3550]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 70,
		Drops = {
			["Lucidus's Totem"] = "12.5%",
			["Hefty Glasses"] = "10%",
			["Hefty Coat"] = "2%"
		}
	},
	["Lucidus [Lv. 3575]"] = {
		Name = "Lucidus [Lv. 3575]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Lucidus Coat"] = "5%"
		}
	},
	["Samurai Soul [Lv. 7500]"] = {
		Name = "Samurai Soul [Lv. 7500]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			Leather = "30%"
		}
	},
	["Dark Beard [Lv. 3475]"] = {
		Name = "Dark Beard [Lv. 3475]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Dark Beard Cloak"] = "1%",
			["Dark Beard Hat"] = "0.5%"
		}
	},
	["Joey [Lv. 3000]"] = {
		Name = "Joey [Lv. 3000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Leather = "30%",
			Carrot = "30%"
		}
	},
	["Kappa [Lv. 2950]"] = {
		Name = "Kappa [Lv. 2950]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Samurai's Badage"] = "5%"
		}
	},
	["Kitsune Samurai [Lv. 2650]"] = {
		Name = "Kitsune Samurai [Lv. 2650]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Samurai's Badage"] = "5%"
		}
	},
	["Lomeo [Lv. 3675]"] = {
		Name = "Lomeo [Lv. 3675]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Crimson Scarf"] = "4%"
		}
	},
	["Magician [Lv. 2600]"] = {
		Name = "Magician [Lv. 2600]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Gunpowder = "10%"
		}
	},
	["Meji [Lv. 2850]"] = {
		Name = "Meji [Lv. 2850]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Leather = "30%",
			Carrot = "30%"
		}
	},
	["Petra [Lv. 2900]"] = {
		Name = "Petra [Lv. 2900]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Carrot = "30%"
		}
	},
	["Pharaoh [Lv. 3175]"] = {
		Name = "Pharaoh [Lv. 3175]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Iron Ingot"] = "20%",
			["Lost Ruby"] = "5%"
		}
	},
	["Physicus [Lv. 3750]"] = {
		Name = "Physicus [Lv. 3750]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Gunpowder = "10%"
		}
	},
	["Pondere [Lv. 3525]"] = {
		Name = "Pondere [Lv. 3525]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Lucidus's Totem"] = "10%",
			["Pondere Coat"] = "5%",
			["Pondere Blade"] = "5%"
		}
	},
	["Prince Aria [Lv. 3700]"] = {
		Name = "Prince Aria [Lv. 3700]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			["Iron Ingot"] = "20%",
			Apollos = "2%"
		}
	},
	["Ryu [Lv. 3975]"] = {
		Name = "Ryu [Lv. 3975]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 100,
		Drops = {
			Gunpowder = "10%"
		}
	},
	["Sally [Lv. 3450]"] = {
		Name = "Sally [Lv. 3450]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Iron Ingot"] = "30%",
			["Undead's Ooze"] = "20%",
			["Dark Beard's Totem"] = "16%",
			["Soul Cane"] = "2%",
			["Sally Crown"] = "2%"
		}
	},
	["Sunken Vessel [Lv. 3225]"] = {
		Name = "Sunken Vessel [Lv. 3225]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Bread Crumbs"] = "20%",
			["Iron Ingot"] = "20%",
			["Sunken Blade"] = "5%"
		}
	},
	["Supreme Swordman [Lv. 3425]"] = {
		Name = "Supreme Swordman [Lv. 3425]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Dark Beard's Totem"] = "16%"
		}
	},
	["Violet Samurai [Lv. 2500]"] = {
		Name = "Violet Samurai [Lv. 2500]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Samurai's Badage"] = "5%"
		}
	},
	["Cyborg Gorilla [Lv. 4375]"] = {
		Name = "Cyborg Gorilla [Lv. 4375]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			Leather = "30%",
			["Sea Artifact"] = "30%"
		}
	},
	["Fishman King's Guard [Lv. 4250]"] = {
		Name = "Fishman King's Guard [Lv. 4250]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Shark's Fin"] = "20%"
		}
	},
	["Fugitive [Lv. 4050]"] = {
		Name = "Fugitive [Lv. 4050]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			Coral = "20%",
			Pearl = "10%"
		}
	},
	["The deep one [Lv. 4200]"] = {
		Name = "The deep one [Lv. 4200]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Shark's Fin"] = "20%"
		}
	},
	["Ripcurrent Raider [Lv. 4400]"] = {
		Name = "Ripcurrent Raider [Lv. 4400]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Shark's Fin"] = "20%",
			["Shark's Canine"] = "5%"
		}
	},
	["Tidal Warrior [Lv. 4450]"] = {
		Name = "Tidal Warrior [Lv. 4450]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Shark's Fin"] = "20%",
			["Shark's Canine"] = "5%"
		}
	},
	["Ocean Gladiator [Lv. 4500]"] = {
		Name = "Ocean Gladiator [Lv. 4500]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Shark's Fin"] = "20%",
			["Shark's Canine"] = "5%"
		}
	},
	["Electro Abyss Warrior [Lv. 4600]"] = {
		Name = "Electro Abyss Warrior [Lv. 4600]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Sea Artifact"] = "30%",
			Pearl = "10%"
		}
	},
	["Inferno Diver [Lv. 4650]"] = {
		Name = "Inferno Diver [Lv. 4650]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Sea Artifact"] = "30%",
			["Essence of Fire"] = "5%"
		}
	},
	["Tempest Tidebreaker [Lv. 4700]"] = {
		Name = "Tempest Tidebreaker [Lv. 4700]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Sea Artifact"] = "30%",
			Pearl = "10%"
		}
	},
	["Abyssal Swordsman [Lv. 4750]"] = {
		Name = "Abyssal Swordsman [Lv. 4750]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Sea Artifact"] = "30%",
			Pearl = "10%",
			Coral = "10%",
			["Dominion Cloak"] = "1%"
		}
	},
	["Nightbound Explorer [Lv. 5150]"] = {
		Name = "Nightbound Explorer [Lv. 5150]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			Pearl = "10%",
			["Samurai's Badage"] = "5%",
			["Noir Pearl"] = "1%"
		}
	},
	["Ancient Wayfarer [Lv. 5250]"] = {
		Name = "Ancient Wayfarer [Lv. 5250]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Sea Artifact"] = "30%",
			Pearl = "10%",
			Coral = "10%"
		}
	},
	["Ghost Ship"] = {
		Name = "Ghost Ship",
		BorderImage = "rbxassetid://15178389995",
		Distance = 1000
	},
	HydraSeaKing = {
		Name = "Hydra I",
		BorderImage = "rbxassetid://15178388462",
		Distance = 1250
	},
	SeaKing = {
		Name = "Sea King",
		BorderImage = "rbxassetid://15178389155",
		Distance = 1250,
		Drops = {
			["Sea King's Blood"] = "10%",
			["Sea King's Fin"] = "5%",
			["Sea King Jaw"] = "5%"
		}
	},
	["Skull King"] = {
		Name = "Skull King",
		BorderImage = "rbxassetid://15178389155",
		Distance = 1250,
		Drops = {
			Candy = "100%",
			["Sea King Jaw"] = "5%",
			["Sea King Skull"] = "2%",
			["Bone Scythe"] = "1.5%"
		}
	},
	["Vaelyric [Lv. 5000]"] = {
		Name = "Vaelyric, Edge of the Lost Sky",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300
	},
	["Monster [Lv. 2500]"] = {
		Name = "Monster [Lv. 2500]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 500,
		Drops = {
			["Mom Blade"] = "20%"
		}
	},
	["Expert Swordman [Lv. 3000]"] = {
		Name = "Expert Swordman [Lv. 3000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			Saber = "15%"
		}
	},
	["King Samurai [Lv. 3500]"] = {
		Name = "King Samurai I",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Hell Sword"] = "30%",
			Muramasa = "15%",
			["Samurai's Badage"] = "5%"
		}
	},
	["Dragon [Lv. 5000]"] = {
		Name = "Dragon [Lv. 5000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 1000,
		Drops = {
			["Dragon Scale"] = "10%",
			["Authentic Mace"] = "10%"
		}
	},
	["Ms. Mother [Lv. 7500]"] = {
		Name = "Ms. Mother [Lv. 7500]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 300,
		Drops = {
			["Phoenix Blade"] = "5%",
			["Flame Hair"] = "5%",
			["Phoenix's Tear"] = "5%"
		}
	},
	["Jack o lantern [Lv. 10000]"] = {
		Name = "Jack o lantern [Lv. 10000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 500,
		Drops = {
			["Pumpkin Smasher"] = "1%",
			["Hallo Lamp"] = "4%",
			["Hallo Shawl"] = "3%",
			["Pumpkin Head"] = "2%"
		}
	},
	Tentacle = {
		Name = "Kraken Tentacle",
		BorderImage = "rbxassetid://15617774998",
		Distance = 500,
		Fuse = true,
		Drops = {
			["Title:"] = "Kraken Challenger",
			["Kraken's Cache"] = "100%"
		}
	},
	["Lord of Saber [Lv. 8500]"] = {
		Name = "Lord of Saber [Lv. 8500]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 150,
		Drops = {
			["Random Fruit"] = "(Most Damage)",
			["Fortune Tales"] = "30%",
			["Aqua Gem"] = "2%",
			["Chronicles Lore"] = "10%"
		}
	},
	["Bushido Ape [Lv. 5000]"] = {
		Name = "Bushido Ape [Lv. 5000]",
		BorderImage = "rbxassetid://15185444293",
		Distance = 200,
		Drops = {
			["Sea Artifact"] = "30%",
			Leather = "30%",
			Ethereal = "10%",
			["Fortune Tales"] = "3%",
			["Chronicles Lore"] = "1%"
		}
	},
	["ThirdSeaEldritch Crab"] = {
		Name = "Deepsea Crusher",
		BorderImage = "rbxassetid://135374159738611",
		Distance = 1000,
		Drops = {
			["Crab Meat"] = "5%",
			["Fortune Tales"] = "30%",
			["Chronicles Lore"] = "10%",
			["Crustacean Armor"] = "1%",
			["Abyssal Crab Axe"] = "1%"
		}
	},
	SeaDragon = {
		Name = "Abyssal Tyrant",
		BorderImage = "rbxassetid://72349955876646",
		Distance = 1250,
		Drops = {
			["Sea King's Blood"] = "10%",
			["Dragon Scale"] = "10%",
			["Fortune Tales"] = "30%",
			["Chronicles Lore"] = "10%",
			["Riptide Slayer"] = "1.5%",
			["Abyssal Tyrant Armor"] = "1%"
		}
	},
	ThirdSeaDragon = {
		Name = "Drakenfyr the Inferno King",
		BorderImage = "rbxassetid://111778736200017",
		Distance = 1250,
		Drops = {
			["Dragon Scale"] = "10%",
			["Fortune Tales"] = "30%",
			["Chronicles Lore"] = "10%",
			["Dragon Fang"] = "2.5%",
			["Drakenfyr Cape"] = "2%",
			["Dragon Bones"] = "2%",
			["Draken Fangs"] = "1%"
		}
	},
	FuryTentacle = {
		Name = "Chaos Kraken",
		BorderImage = "rbxassetid://15617774998",
		Distance = 1000,
		Fuse = true,
		Drops = {
			["Fortune Tales"] = "10%",
			["Oceanic Tentacle"] = "1%",
			["Severed Kraken"] = "1%",
			["Kraken's Ink"] = "1%",
			["Oceanic Tanto"] = "0.5%"
		}
	}
}