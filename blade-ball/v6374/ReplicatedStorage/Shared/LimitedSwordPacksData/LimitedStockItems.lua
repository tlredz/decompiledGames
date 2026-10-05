local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(script.Parent)
require3(script.Parent.Types)
local v3 = require3(ReplicatedStorage2.Shared.CommerceProducts)
local LimitedStockItems = {
	["King Blade"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("King Blade"),
			v.createExplosionReward("King Explosion"),
			v.createEmoteReward("Emote214")
		}
	},
	["Queen Blade"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Queen Blade"),
			v.createExplosionReward("Queen Explosion"),
			v.createEmoteReward("Emote213")
		}
	},
	["Dual Royal Blades"] = {
		Stock = 3500,
		Items = {
			v.createSwordReward("Dual Royal Blades"),
			v.createExplosionReward("Royal Explosion"),
			v.createEmoteReward("Emote215")
		}
	},
	["Devil Greatsword"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Devil Greatsword"),
			v.createEmoteReward("Emote269"),
			v.createExplosionReward("Devil's Curse")
		}
	},
	["Angel Greatsword"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Angel Greatsword"),
			v.createEmoteReward("Emote270"),
			v.createExplosionReward("Judgement")
		}
	},
	["Dual Eternal Greatsword"] = {
		Stock = 3500,
		Items = {
			v.createSwordReward("Dual Eternal Greatsword"),
			v.createEmoteReward("Emote271"),
			v.createExplosionReward("Eternal")
		}
	},
	["Chroma Blade"] = {
		Stock = 10000,
		Items = {
			v.createSwordReward("Chroma Blade"),
			v.createExplosionReward("Chroma Blade Explosion"),
			v.createEmoteReward("Emote348")
		}
	},
	["Chroma Scythe"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Chroma Scythe"),
			v.createExplosionReward("Chroma Scythe Explosion"),
			v.createEmoteReward("Emote349")
		}
	},
	["Dual Chroma Set"] = {
		Stock = 3500,
		Items = {
			v.createSwordReward("Dual Chroma Set"),
			v.createExplosionReward("Dual Chroma Set Explosion"),
			v.createEmoteReward("Emote350")
		}
	},
	["Yin Yang Parasol"] = {
		Stock = 10000,
		Items = {
			v.createSwordReward("Yin Yang Parasol"),
			v.createExplosionReward("Yin Yang Parasol Explosion"),
			v.createEmoteReward("Emote392")
		}
	},
	["Yin Yang Greatsword"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Yin Yang Greatsword"),
			v.createExplosionReward("Yin Yang Greatsword Explosion"),
			v.createEmoteReward("Emote393")
		}
	},
	["Dual Yin Yang Greatsword"] = {
		Stock = 3500,
		Items = {
			v.createSwordReward("Dual Yin Yang Greatsword"),
			v.createExplosionReward("Dual Yin Yang Greatsword Explosion"),
			v.createEmoteReward("Emote394")
		}
	},
	Shark = {
		Stock = 10000,
		Items = {
			v.createSwordReward("Shark"),
			v.createExplosionReward("Shark Feast"),
			v.createEmoteReward("Emote438")
		}
	},
	["Black Ninja Katana"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Black Ninja Katana"),
			v.createExplosionReward("Katana Black Explosion"),
			v.createEmoteReward("Emote449")
		}
	},
	["Red Ninja Katana"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Red Ninja Katana"),
			v.createExplosionReward("Katana Red Explosion"),
			v.createEmoteReward("Emote450")
		}
	},
	["Green Ninja Katana"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Green Ninja Katana"),
			v.createExplosionReward("Katana Green Explosion"),
			v.createEmoteReward("Emote451")
		}
	},
	["Blue Ninja Katana"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Blue Ninja Katana"),
			v.createExplosionReward("Katana Blue Explosion"),
			v.createEmoteReward("Emote452")
		}
	},
	["Pink Ninja Katana"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Pink Ninja Katana"),
			v.createExplosionReward("Katana Pink Explosion"),
			v.createEmoteReward("Emote453")
		}
	},
	["Jellyfish Parasol"] = {
		Stock = 10000,
		Items = {
			v.createSwordReward("Jellyfish Parasol"),
			v.createExplosionReward("Jellyfish Explosion"),
			v.createEmoteReward("Emote469")
		}
	},
	["Nebula Sniper"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Nebula Sniper"),
			v.createExplosionReward("Cosmic Accuracy"),
			v.createEmoteReward("Emote468")
		}
	},
	["Black Ninja Star"] = {
		Stock = 10000,
		Items = {
			v.createSwordReward("Black Ninja Star"),
			v.createExplosionReward("Black Ninja Star Explosion"),
			v.createEmoteReward("Emote512")
		}
	},
	["Red Ninja Star"] = {
		Stock = 10000,
		Items = {
			v.createSwordReward("Red Ninja Star"),
			v.createExplosionReward("Red Ninja Star Explosion"),
			v.createEmoteReward("Emote510")
		}
	},
	["Green Ninja Star"] = {
		Stock = 10000,
		Items = {
			v.createSwordReward("Green Ninja Star"),
			v.createExplosionReward("Green Ninja Star Explosion"),
			v.createEmoteReward("Emote508")
		}
	},
	["Blue Ninja Star"] = {
		Stock = 10000,
		Items = {
			v.createSwordReward("Blue Ninja Star"),
			v.createExplosionReward("Blue Ninja Star Explosion"),
			v.createEmoteReward("Emote509")
		}
	},
	["Pink Ninja Star"] = {
		Stock = 10000,
		Items = {
			v.createSwordReward("Pink Ninja Star"),
			v.createExplosionReward("Pink Ninja Star Explosion"),
			v.createEmoteReward("Emote511")
		}
	},
	["Wonderwisp Greatsword"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Wonderwisp Greatsword"),
			v.createExplosionReward("Ghostwisp"),
			v.createEmoteReward("Emote514")
		}
	},
	["Dual Wonderwisp Greatsword"] = {
		Stock = 3500,
		Items = {
			v.createSwordReward("Dual Wonderwisp Greatsword"),
			v.createExplosionReward("Dual Ghostwisp"),
			v.createEmoteReward("Emote515")
		}
	},
	["Soulrender Scythe"] = {
		Stock = 7000,
		Items = {
			v.createSwordReward("Soulrender Scythe"),
			v.createExplosionReward("Soul Lantern"),
			v.createEmoteReward("Emote553")
		}
	},
	["Kitty Launcher"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Kitty Launcher"),
			v.createExplosionReward("Kitty Rocket"),
			v.createEmoteReward("Emote554")
		}
	},
	Seraphim = {
		Stock = 1500,
		Items = {
			v.createSwordReward("Seraphim"),
			v.createExplosionReward("Seraphim Gate"),
			v.createEmoteReward("Emote555")
		}
	},
	Coffin = {
		Stock = 2500,
		Items = {
			v.createSwordReward("Coffin"),
			v.createExplosionReward("Coffin Explosion"),
			v.createEmoteReward("Emote594")
		}
	},
	["Moonflower Katana"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Moonflower Katana"),
			v.createExplosionReward("Moon Discovery"),
			v.createEmoteReward("Emote600")
		}
	},
	["Moonflower Greatsword"] = {
		Stock = 3500,
		Items = {
			v.createSwordReward("Moonflower Greatsword"),
			v.createExplosionReward("Great Moon Landing"),
			v.createEmoteReward("Emote601")
		}
	},
	["Astraea Staff"] = {
		Stock = 10000,
		Items = {
			v.createSwordReward("Astraea Staff"),
			v.createExplosionReward("Astraea Orb"),
			v.createEmoteReward("Emote655")
		}
	},
	["Dual Leviathan Set"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Dual Leviathan Set"),
			v.createExplosionReward("Serpent Anchor"),
			v.createEmoteReward("Emote657")
		}
	},
	["Dual Astraea Set"] = {
		Stock = 3500,
		Items = {
			v.createSwordReward("Dual Astraea Set"),
			v.createExplosionReward("Astraea Guidance"),
			v.createEmoteReward("Emote656")
		}
	},
	["Snowball Launcher"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Snowball Launcher"),
			v.createExplosionReward("Rocket Tree"),
			v.createEmoteReward("Snowball Launcher Emote")
		}
	},
	Penguin = {
		Stock = 1000,
		Items = {
			v.createSwordReward("Penguin"),
			v.createExplosionReward("Arctic Waddle"),
			v.createEmoteReward("Penguin Emote")
		}
	},
	["Santa's Greatsword"] = {
		Stock = 7500,
		Items = {
			v.createSwordReward("Santa's Greatsword"),
			v.createExplosionReward("Santa's Greatplosion"),
			v.createEmoteReward("Santa's Greatsword Emote")
		}
	},
	["Polar Bear"] = {
		Active = false,
		Stock = 750,
		Items = {
			v.createSwordReward("Polar Bear"),
			v.createExplosionReward("Polar Bear Pop"),
			v.createEmoteReward("Polar Bear Emote")
		}
	},
	["Polar Bear Mount"] = {
		Active = false,
		Stock = 250,
		Items = {
			v.createSwordAccessoryReward("Polar Bear"),
			v.createExplosionReward("Polar Bear Pop"),
			v.createEmoteReward("Polar Bear Emote")
		}
	},
	["Jolly Scythe Set"] = {
		Stock = 10000,
		Items = {
			v.createSwordReward("Jolly Scythe Set"),
			v.createExplosionReward("Bell Light"),
			v.createEmoteReward("Jolly Scythe Set Emote")
		}
	},
	["Candycane Sniper"] = {
		Stock = 7500,
		Items = {
			v.createSwordReward("Candycane Sniper"),
			v.createExplosionReward("Sweet Headshot"),
			v.createEmoteReward("Candycane Sniper Emote")
		}
	},
	["Ban Hammer"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Ban Hammer") }
	},
	["Dragon Scythe"] = {
		Stock = 5000,
		Items = { v.createSwordReward("Dragon Scythe") }
	},
	["Sinister Scythe"] = {
		Stock = 5000,
		Items = { v.createSwordReward("Sinister Scythe") }
	},
	Potato = {
		Stock = 5000,
		Items = { v.createSwordReward("Potato") }
	},
	["Doom's Whisper"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Doom's Whisper") }
	},
	["Eternal Nightmare"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Eternal Nightmare") }
	},
	["Mummy's Slasher"] = {
		Stock = 5000,
		Items = { v.createSwordReward("Mummy's Slasher") }
	},
	["Frostbite Annihilator"] = {
		Stock = 3000,
		Items = { v.createSwordReward("Frostbite Annihilator") }
	},
	["Glacial Dominance"] = {
		Stock = 5000,
		Items = { v.createSwordReward("Glacial Dominance") }
	},
	Crownslayer = {
		Stock = 5000,
		Items = { v.createSwordReward("Crownslayer") }
	},
	["Celestial Whisper"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Celestial Whisper") }
	},
	Frostbane = {
		Stock = 5000,
		Items = { v.createSwordReward("Frostbane") }
	},
	["Frostbound Regal Edge"] = {
		Stock = 5000,
		Items = { v.createSwordReward("Frostbound Regal Edge") }
	},
	["Fragmented Wallblade"] = {
		Stock = 30000,
		Items = { v.createSwordReward("Fragmented Wallblade") }
	},
	["Frog Finisher"] = {
		Stock = 100,
		Items = { v.createFinisherReward("Frog") }
	},
	["Frost Dragon Finisher"] = {
		Stock = 150,
		Items = { v.createFinisherReward("Frost Dragon") }
	},
	["Fire Dragon Finisher"] = {
		Stock = 150,
		Items = { v.createFinisherReward("Fire Dragon") }
	},
	["Bunny Finisher"] = {
		Stock = 500,
		Items = { v.createFinisherReward("Bunny") }
	},
	["Venom's Wrath"] = {
		Stock = 25000,
		Items = { v.createEmoteReward("Emote693") }
	},
	["Astral Enlightenment"] = {
		Stock = 10000,
		Items = { v.createEmoteReward("Emote694") }
	},
	Ethereal = {
		Stock = 5000,
		Items = { v.createEmoteReward("Emote695") }
	},
	["Necrotic Ruler"] = {
		Stock = 2500,
		Items = { v.createEmoteReward("Emote696") }
	},
	["Eternal Clockwork"] = {
		Stock = 999,
		Items = { v.createEmoteReward("Emote697") }
	},
	["Crystal Blade"] = {
		Stock = 5000,
		Items = { v.createSwordReward("Crystal Blade") }
	},
	["Chroma Seal"] = {
		Active = false,
		Stock = 2500,
		Items = { v.createSwordReward("Chroma Seal") }
	},
	["Resolution Reaver"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Resolution Reaver") }
	},
	["Aligned Constellation"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Aligned Constellation") }
	},
	["Timeless Greatsword"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Timeless Greatsword") }
	},
	["Dual Iced Energy Blades"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Dual Iced Energy Blades") }
	},
	Serpent = {
		Stock = 1000,
		Items = {
			v.createSwordReward("Serpent"),
			v.createExplosionReward("Year of the Serpent"),
			v.createEmoteReward("Emote755")
		}
	},
	["Serpent's Greatsword"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Serpent's Greatsword"),
			v.createExplosionReward("Serpent's Judgment"),
			v.createEmoteReward("Emote756")
		}
	},
	["Venomlight Scythe"] = {
		Stock = 3500,
		Items = {
			v.createSwordReward("Venomlight Scythe"),
			v.createExplosionReward("Lunar Lantern"),
			v.createEmoteReward("Emote757")
		}
	},
	["Eternal Shield"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Eternal Shield") }
	},
	["Solblade Sentinel"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Solblade Sentinel") }
	},
	["Twisted Rosemary Blade"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Twisted Rosemary Blade") }
	},
	["Loving Backblade"] = {
		Stock = 2000,
		Items = { v.createSwordReward("Loving Backblade") }
	},
	["Dual Astral Vanguard"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Dual Astral Vanguard") }
	},
	["Frostbound Lantern"] = {
		Active = false,
		Stock = 3500,
		Items = {
			v.createSwordReward("Frostbound Lantern"),
			v.createExplosionReward("Frostbound Enlightenment"),
			v.createEmoteReward("Emote812")
		}
	},
	Ace = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Ace"),
			v.createExplosionReward("Playcards Shuffler"),
			v.createEmoteReward("Emote811")
		}
	},
	["The Conjurer"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("The Conjurer"),
			v.createExplosionReward("Soulforge Explosion"),
			v.createEmoteReward("Emote810")
		}
	},
	Kraken = {
		Stock = 2500,
		Items = { v.createSwordReward("Kraken") }
	},
	["Solar Iceblade"] = {
		Active = false,
		Stock = 5000,
		Items = { v.createSwordReward("Solar Iceblade") }
	},
	["Mecha Axe"] = {
		Active = false,
		Stock = 2000,
		Items = { v.createSwordReward("Mecha Axe") }
	},
	["Chroma Pearlblade"] = {
		Active = false,
		Stock = 5000,
		Items = { v.createSwordReward("Chroma Pearlblade") }
	},
	["Floppy Chicken"] = {
		Stock = 7000,
		Items = {
			v.createSwordReward("Floppy Chicken"),
			v.createExplosionReward("Floppy Chicken Explosion"),
			v.createEmoteReward("Emote853")
		}
	},
	["The Curse"] = {
		Stock = 3500,
		Items = {
			v.createSwordReward("The Curse"),
			v.createExplosionReward("The Curse Explosion"),
			v.createEmoteReward("Emote852")
		}
	},
	["Spring Sun Scythe"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Spring Sun Scythe") }
	},
	["Spring Sun Bow"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Spring Sun Bow") }
	},
	["Blossom Katana"] = {
		Stock = 4000,
		Items = {
			v.createSwordReward("Blossom Katana"),
			v.createExplosionReward("Blossom Katana Explosion"),
			v.createEmoteReward("Blossom Katana Emote")
		}
	},
	["Aquatic Greatsword"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Aquatic Greatsword") }
	},
	["Sunkissed Scythe"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Sunkissed Scythe") }
	},
	["Blooming Katana"] = {
		Active = false,
		Stock = 2000,
		Items = { v.createSwordReward("Blooming Katana") }
	},
	["Hollow Oath Katana"] = {
		Stock = 7000,
		Items = {
			v.createSwordReward("Hollow Oath Katana"),
			v.createExplosionReward("Hollow Oath Explosion"),
			v.createEmoteReward("Emote910")
		}
	},
	["Cat Paw"] = {
		Stock = 5000,
		Items = {
			v.createSwordReward("Cat Paw"),
			v.createExplosionReward("Paw Punch"),
			v.createEmoteReward("Emote909")
		}
	},
	["Shatterflight Bird"] = {
		Stock = 1000,
		Items = {
			v.createSwordReward("Shatterflight Bird"),
			v.createExplosionReward("Shatterflight Bird Explosion"),
			v.createEmoteReward("Emote911")
		}
	},
	Slime = {
		Stock = 2500,
		Items = { v.createSwordReward("Slime") }
	},
	["Block Buster"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Block Buster") }
	},
	Aetherion = {
		Stock = 2500,
		Items = { v.createSwordReward("Aetherion") }
	},
	Ecliptarch = {
		Stock = 2500,
		Items = { v.createSwordReward("Ecliptarch") }
	},
	["Dream Scythe"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Dream Scythe") }
	},
	["Passo Bem Solto"] = {
		Stock = 5000,
		Items = { v.createEmoteReward("Passo Bem Solto") }
	},
	["TUNG TUNG TUNG SAHUR"] = {
		Stock = 2500,
		Items = { v.createSwordReward("TUNG TUNG TUNG SAHUR") }
	},
	Spinalis = {
		Active = false,
		Stock = 1500,
		Items = {
			v.createSwordReward("Spinalis"),
			v.createExplosionReward("Spinalis Explosion"),
			v.createEmoteReward("Emote951")
		}
	},
	["Prismatic Odachi"] = {
		Stock = 7000,
		Items = {
			v.createSwordReward("Prismatic Odachi"),
			v.createExplosionReward("Prismatic Odachi Explosion"),
			v.createEmoteReward("Emote953")
		}
	},
	["Calamity Guardian"] = {
		Active = false,
		Stock = 5000,
		Items = {
			v.createSwordReward("Calamity Guardian"),
			v.createExplosionReward("Calamity Guardian Explosion"),
			v.createEmoteReward("Emote952")
		}
	},
	["Water Slasher"] = {
		Stock = 1000,
		Items = { v.createSwordReward("Water Slasher") }
	},
	["Lumina Spear"] = {
		Stock = 2000,
		Items = { v.createSwordReward("Lumina Spear") }
	},
	["Crimson Backblade"] = {
		Stock = 2000,
		Items = { v.createSwordReward("Crimson Backblade") }
	},
	["Flaming Sword"] = {
		Active = false,
		Stock = 5000,
		Items = { v.createSwordReward("Flaming Sword") }
	},
	["Black Oni Katana"] = {
		Stock = 7000,
		Items = {
			v.createSwordReward("Black Oni Katana"),
			v.createExplosionReward("Black Oni Katana Explosion"),
			v.createEmoteReward("Emote971")
		}
	},
	["Red Oni Katana"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Red Oni Katana"),
			v.createExplosionReward("Red Oni Katana Explosion"),
			v.createEmoteReward("Emote970")
		}
	},
	["Purple Oni Katana"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Purple Oni Katana"),
			v.createExplosionReward("Purple Oni Katana Explosion"),
			v.createEmoteReward("Emote969")
		}
	},
	["Blue Oni Katana"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Blue Oni Katana"),
			v.createExplosionReward("Blue Oni Katana Explosion"),
			v.createEmoteReward("Emote968")
		}
	},
	["Pink Oni Katana"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Pink Oni Katana"),
			v.createExplosionReward("Pink Oni Katana Explosion"),
			v.createEmoteReward("Emote967")
		}
	},
	["Coral Greatsword"] = {
		Stock = 2500,
		Items = { v.createSwordReward("Coral Greatsword") }
	},
	["Retro Backblade"] = {
		Stock = 2000,
		Items = { v.createSwordReward("Retro Backblade") }
	},
	["Sunset Pastelblade"] = {
		Stock = 2000,
		Items = { v.createSwordReward("Sunset Pastelblade") }
	},
	["Crystal Fairyblade"] = {
		Stock = 2000,
		Items = { v.createSwordReward("Crystal Fairyblade") }
	},
	["T Rex"] = {
		Stock = 1000,
		Items = {
			v.createSwordReward("T-Rex"),
			v.createExplosionReward("T-Rex Explosion"),
			v.createEmoteReward("Emote991")
		}
	},
	Stormbane = {
		Active = false,
		Stock = 5000,
		Items = {
			v.createSwordReward("Stormbane"),
			v.createExplosionReward("Stormbane Explosion"),
			v.createEmoteReward("Emote990")
		}
	},
	["Viral Piercer"] = {
		Stock = 1000,
		Items = { v.createSwordReward("Viral Piercer") }
	},
	["Umbra Spear"] = {
		Stock = 2000,
		Items = { v.createSwordReward("Umbra Spear") }
	},
	["Star Wand"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Star Wand"),
			v.createExplosionReward("Star Wand Explosion"),
			v.createEmoteReward("Emote1019")
		}
	},
	["Oni Ghost"] = {
		Active = false,
		Stock = 1500,
		Items = {
			v.createSwordReward("Oni Ghost"),
			v.createExplosionReward("Oni Ghost Explosion"),
			v.createEmoteReward("Emote1018")
		}
	},
	["Golden Champion"] = {
		Active = false,
		Stock = 2000,
		Items = { v.createSwordReward("Golden Champion") }
	},
	["Starshooter Rapier"] = {
		Active = false,
		Stock = 2000,
		Items = { v.createSwordReward("Starshooter Rapier") }
	},
	["Montagem Tomada"] = {
		Active = false,
		Stock = 5000,
		Items = { v.createEmoteReward("Montagem Tomada") }
	},
	Aurelius = {
		Active = false,
		Stock = 5000,
		Items = { v.createSwordReward("Aurelius") }
	},
	["Pulseheart Set"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Pulseheart Set"),
			v.createExplosionReward("Medic Waveform"),
			v.createEmoteReward("Emote1047")
		}
	},
	["Lily Katana"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Lily Katana"),
			v.createExplosionReward("Lily Strike"),
			v.createEmoteReward("Emote1048")
		}
	},
	["Ice King Staff"] = {
		Active = false,
		Stock = 2000,
		Items = { v.createSwordReward("Ice King Staff") }
	},
	["Luna Bala"] = {
		Active = false,
		Stock = 5000,
		Items = { v.createEmoteReward("Luna Bala") }
	},
	["Hellwing Set"] = {
		Active = false,
		Stock = 5000,
		Items = {
			v.createSwordReward("Hellwing Set"),
			v.createExplosionReward("Vampire Light"),
			v.createEmoteReward("Emote1063")
		}
	},
	["Skeleton Bride"] = {
		Active = false,
		Stock = 2500,
		Items = {
			v.createSwordReward("Skeleton Bride"),
			v.createExplosionReward("Bridal Revival"),
			v.createEmoteReward("Emote1062")
		}
	},
	Venomsanct = {
		Active = false,
		Stock = 1000,
		Items = { v.createSwordReward("Venomsanct") }
	},
	["Glacialis Requiem"] = {
		Active = false,
		Stock = 1000,
		Items = { v.createSwordReward("Glacialis Requiem") }
	},
	["Runic Dragonslayer"] = {
		Active = false,
		Stock = 1500,
		Items = { v.createSwordReward("Runic Dragonslayer") }
	},
	["Sakura's Requiem"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Sakura's Requiem"),
			v.createEmoteReward("Emote1087"),
			v.createExplosionReward("Sakura's Requiem Explosion")
		}
	},
	["Wicked Crow"] = {
		Active = false,
		Stock = 3500,
		Items = {
			v.createSwordReward("Wicked Crow"),
			v.createEmoteReward("Emote1086"),
			v.createExplosionReward("Wicked Crow Explosion")
		}
	},
	["Fallen Angel"] = {
		Active = false,
		Stock = 2500,
		Items = {
			v.createSwordReward("Fallen Angel"),
			v.createEmoteReward("Emote1085"),
			v.createExplosionReward("Fallen Angel Explosion")
		}
	},
	["Heart of Winter"] = {
		Active = false,
		Stock = 1500,
		Items = { v.createSwordReward("Heart of Winter") }
	},
	["Wrapped Froststaff"] = {
		Active = false,
		Stock = 1500,
		Items = { v.createSwordReward("Wrapped Froststaff") }
	},
	["Kitty Katana"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Kitty Katana"),
			v.createEmoteReward("Emote1117"),
			v.createExplosionReward("Kitty Katana Explosion")
		}
	},
	Hitman = {
		Active = false,
		Stock = 5000,
		Items = {
			v.createSwordReward("Hitman"),
			v.createEmoteReward("Emote1115"),
			v.createExplosionReward("Bounty Claimed")
		}
	},
	["Poisoned Bunny"] = {
		Active = false,
		Stock = 10000,
		Items = {
			v.createSwordReward("Poisoned Bunny"),
			v.createEmoteReward("Emote1118"),
			v.createExplosionReward("Poisoned Bunny Explosion")
		}
	},
	["Winter Wolf"] = {
		Active = false,
		Stock = 1500,
		Items = {
			v.createSwordReward("Winter Wolf"),
			v.createEmoteReward("Emote1116"),
			v.createExplosionReward("Winter Wolf Explosion")
		}
	},
	["Winter Wolf Mount"] = {
		Active = false,
		Stock = 300,
		Items = {
			v.createSwordAccessoryReward("Winter Wolf"),
			v.createEmoteReward("Emote1116"),
			v.createExplosionReward("Winter Wolf Explosion")
		}
	},
	["Fox Katana"] = {
		Active = false,
		Stock = 3500,
		Items = {
			v.createSwordReward("Fox Katana"),
			v.createEmoteReward("Emote1119"),
			v.createExplosionReward("Fox Katana Explosion")
		}
	},
	["Holy Blade"] = {
		Active = false,
		Stock = 2500,
		Items = { v.createSwordReward("Holy Blade") }
	},
	["Riftflare Katana"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Riftflare Katana"),
			v.createExplosionReward("Riftflare Explosion"),
			v.createEmoteReward("Emote1135")
		}
	},
	["Ethereal Bombardment"] = {
		Active = false,
		Stock = 5000,
		Items = {
			v.createSwordReward("Ethereal Bombardment"),
			v.createExplosionReward("Ethereal Bombardment Explosion"),
			v.createEmoteReward("Emote1133")
		}
	},
	["Guardian of the Underworld"] = {
		Active = false,
		Stock = 2500,
		Items = {
			v.createSwordReward("Guardian of the Underworld"),
			v.createExplosionReward("Guardian of the Underworld Explosion"),
			v.createEmoteReward("Emote1134")
		}
	},
	["Gyaru Katana"] = {
		Active = false,
		Stock = 7000,
		Items = { v.createSwordReward("Gyaru Katana"), v.createExplosionReward("Gyaru's Selfie") }
	},
	Gravelight = {
		Active = false,
		Stock = 5000,
		Items = { v.createSwordReward("Gravelight"), v.createExplosionReward("Cross Admiration") }
	},
	["Night Raver"] = {
		Active = false,
		Stock = 3500,
		Items = { v.createSwordReward("Night Raver"), v.createExplosionReward("Night Raver") }
	},
	["Phantom Pact"] = {
		Active = false,
		Stock = 1500,
		Items = {
			v.createSwordReward("Phantom Pact"),
			v.createExplosionReward("Phantom Pact"),
			v.createEmoteReward("Emote1175")
		}
	},
	["Enchanted Bluerose"] = {
		Active = false,
		Stock = 2000,
		Items = { v.createSwordReward("Enchanted Bluerose") }
	},
	["Love For You"] = {
		Active = false,
		Stock = 5000,
		Items = { v.createEmoteReward("Love For You") }
	},
	["Montagem Miau"] = {
		Active = false,
		Stock = 5000,
		Items = { v.createEmoteReward("Montagem Miau") }
	},
	Overclocked = {
		Active = false,
		Stock = 1500,
		Items = { v.createSwordReward("Overclocked") }
	},
	["Supercharged Amethyst Bow"] = {
		Active = false,
		Stock = 2000,
		Items = { v.createSwordReward("Supercharged Amethyst Bow") }
	},
	["Golden Crescent Bow"] = {
		Active = false,
		Stock = 2000,
		Items = { v.createSwordReward("Golden Crescent Bow") }
	},
	["Amethyst Fireblade"] = {
		Active = false,
		Stock = 1500,
		Items = { v.createSwordReward("Amethyst Fireblade") }
	},
	["Higanbana Katana"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Higanbana Katana"),
			v.createExplosionReward("Higanbana Explosion"),
			v.createEmoteReward("Emote1194")
		}
	},
	["Regret Blades"] = {
		Active = false,
		Stock = 3000,
		Items = {
			v.createSwordReward("Regret Blades"),
			v.createExplosionReward("Regret Blades Explosion"),
			v.createEmoteReward("Emote1197")
		}
	},
	["Wolf Greatsword"] = {
		Active = false,
		Stock = 1000,
		Items = {
			v.createSwordReward("Wolf Greatsword"),
			v.createExplosionReward("Wolf Greatsword Explosion"),
			v.createEmoteReward("Emote1198")
		}
	},
	["Draconic Greatsword"] = {
		Active = false,
		Stock = 1500,
		Items = { v.createSwordReward("Draconic Greatsword") }
	},
	["Evil Cyborg Blade"] = {
		Active = false,
		Stock = 1500,
		Items = { v.createSwordReward("Evil Cyborg Blade") }
	},
	["Pearl Angel Katana"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Pearl Angel Katana"),
			v.createExplosionReward("Pearl Angel Katana Explosion"),
			v.createEmoteReward("Emote1210")
		}
	},
	["Tiger's Katana"] = {
		Active = false,
		Stock = 3500,
		Items = {
			v.createSwordReward("Tiger's Katana"),
			v.createExplosionReward("Tiger Katana Explosion"),
			v.createEmoteReward("Emote1211")
		}
	},
	Cloud = {
		Active = false,
		Stock = 1500,
		Items = {
			v.createSwordReward("Cloud"),
			v.createExplosionReward("Prismatic Cloud Rain"),
			v.createEmoteReward("Emote1209")
		}
	},
	["Nebula Implosion"] = {
		Active = false,
		Stock = 1500,
		Items = { v.createSwordReward("Nebula Implosion") }
	},
	["Crab Rave"] = {
		Active = false,
		Stock = 5000,
		Items = { v.createEmoteReward("Crab Rave") }
	},
	["Orbit Spear"] = {
		Active = true,
		Stock = 2000,
		Items = { v.createSwordReward("Orbit Spear") }
	},
	["Abyssal Sovereign"] = {
		Active = true,
		Stock = 1500,
		Items = { v.createSwordReward("Abyssal Sovereign") }
	},
	["Red Moon Katana"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Red Moon Katana"),
			v.createExplosionReward("Red Moon Katana Explosion"),
			v.createEmoteReward("Emote1225")
		}
	},
	["Brutality Affection Bat"] = {
		Active = false,
		Stock = 3500,
		Items = {
			v.createSwordReward("Brutality Affection Bat"),
			v.createExplosionReward("Brutality Affection Explosion"),
			v.createEmoteReward("Emote1222")
		}
	},
	["Sea Turtle"] = {
		Active = false,
		Stock = 1500,
		Items = {
			v.createSwordReward("Sea Turtle"),
			v.createExplosionReward("Sea Turtle Explosion"),
			v.createEmoteReward("Emote1226")
		}
	},
	["Proyection Sorcery Katana"] = {
		Active = false,
		Stock = 5000,
		Items = {
			v.createSwordReward("Proyection Sorcery Katana"),
			v.createExplosionReward("Proyection Sorcery Explosion"),
			v.createEmoteReward("Emote1248")
		}
	},
	["Astral Seraph Blade"] = {
		Active = false,
		Stock = 7500,
		Items = {
			v.createSwordReward("Astral Seraph Blade"),
			v.createExplosionReward("Astral Seraph Explosion"),
			v.createEmoteReward("Emote1250")
		}
	},
	["Starlit Halo Wings"] = {
		Active = false,
		Stock = 1500,
		Items = {
			v.createSwordReward("Starlit Halo Wings"),
			v.createExplosionReward("Starlit Halo Wings Explosion"),
			v.createEmoteReward("Emote1247")
		}
	},
	["JACKPOT!"] = {
		Active = false,
		Stock = 5000,
		Items = { v.createEmoteReward("Emote1249") }
	},
	["Crimson Kagune"] = {
		Active = false,
		Stock = 7000,
		Items = {
			v.createSwordReward("Crimson Kagune"),
			v.createExplosionReward("Crimson Kagune Explosion"),
			v.createEmoteReward("Emote1268")
		}
	},
	["Phantom Ops"] = {
		Active = false,
		Stock = 5000,
		Items = {
			v.createSwordReward("Phantom Ops"),
			v.createExplosionReward("Phantom Ops Explosion"),
			v.createEmoteReward("Emote1267")
		}
	},
	Deathrider = {
		Active = false,
		Stock = 1500,
		Items = {
			v.createSwordReward("Deathrider"),
			v.createExplosionReward("Deathrider Explosion"),
			v.createEmoteReward("Emote1269")
		}
	},
	["NO BATIDÃO"] = {
		Active = false,
		Stock = 5000,
		Items = { v.createEmoteReward("NO BATIDÃO") }
	},
	["Ryuzakura Katana"] = {
		Active = true,
		Stock = 6000,
		Items = {
			v.createSwordReward("Ryuzakura Katana"),
			v.createExplosionReward("Ryuzakura Katana Explosion"),
			v.createEmoteReward("Emote1288")
		}
	},
	Cherub = {
		Active = true,
		Stock = 5000,
		Items = {
			v.createSwordReward("Cherub"),
			v.createExplosionReward("Kitty's Big Hug"),
			v.createEmoteReward("Emote1287")
		}
	},
	["Swan Serenity"] = {
		Active = true,
		Stock = 1500,
		Items = {
			v.createSwordReward("Swan Serenity"),
			v.createExplosionReward("Swan of Love Explosion"),
			v.createEmoteReward("Emote1286")
		}
	}
}

local function getPackFromStockName(k: string)
	for _, v4 in pairs(v2) do
		for _, reward in pairs(v4.Rewards) do
			if reward.Stock == k then
				return v4
			end

			for _, reward2 in pairs(reward.Rewards) do
				if reward2.Stock == k then
					return v4
				end
			end
		end
	end

	return nil
end

for k, v4 in LimitedStockItems do
	v4.Name = k
	v4.Pack = getPackFromStockName(k)
end

for _, v4 in v3 do
	if v4.LimitedStockKey and v4.LimitedStockAmount then
		LimitedStockItems[v4.LimitedStockKey] = {
			Active = not v4.Disabled,
			Stock = v4.LimitedStockAmount,
			Items = { v4.Reward },
			Name = v4.LimitedStockKey
		}
	end
end

return LimitedStockItems