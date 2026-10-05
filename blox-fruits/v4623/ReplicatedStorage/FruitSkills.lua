local BuildUtil = require(game.ReplicatedStorage.BuildUtil)
local FruitSkillUtil = require(game.ReplicatedStorage.Modules.FruitSkillUtil)
local FruitSkills = {
	["Flame-Flame"] = {
		{
			{ "Z", 1, "Fire Bullets" },
			{ "X", 20, "Burning Blast" },
			{ "C", 50, "Fire Column" },
			{ "V", 100, "Flame Destroyer" },
			{ "F", 10, "Fire Flight" }
		},
		{
			{ "Z", 1, "Blue Fire Bullets" },
			{ "X", 20, "Prominence Burst" },
			{ "C", 50, "Flaming Vortex" },
			{ "V", 100, "Hell's Core" },
			{ "F", 10, "Rocket Flight" }
		}
	},
	["Dark-Dark"] = {
		{
			{ "Z", 1, "Dark Rocks" },
			{ "X", 20, "Black Spiral" },
			{ "C", 50, "Black Hole" },
			{ "V", 100, "Dark Bomb" }
		},
		{
			{ "Z", 1, "Dimensional Slash" },
			{ "X", 20, "Abyssal Darkness" },
			{ "C", 50, "Endless Hole" },
			{ "V", 100, "World of Darkness" },
			{ "F", 10, "Ghastly Step" }
		}
	},
	["Quake-Quake"] = {
		{
			{ "Z", 1, "Quake Punch" },
			{ "X", 20, "Quake Wave" },
			{ "C", 50, "Quake Erupt" },
			{ "V", 100, "Dual Tsunami" }
		},
		{
			{ "Z", 1, "Fatal Demolisher" },
			{ "X", 20, "Air Crusher" },
			{ "C", 50, "Spatial Shockwave" },
			{ "V", 100, "Seaquake" }
		}
	},
	["Light-Light"] = {
		{
			{ "Z", 1, "Light Ray" },
			{ "X", 50, "Barrage of Light" },
			{ "C", 20, "Reflection Kick" },
			{ "V", 100, "Sky Beam Barrage" },
			{ "F", 10, "Light Flight" }
		},
		{
			{ "Z", 1, "Divine Arrow" },
			{ "X", 50, "Hand of the Emperor" },
			{ "C", 20, "Lightspeed Destroyer" },
			{ "V", 100, "Wrath of God" },
			{ "F", 10, "Shining Flight" }
		}
	},
	["Buddha-Buddha"] = {
		{
			{ "Z", 1, "Transform" },
			{ "X", 20, "Impact" },
			{ "C", 50, "Buddha Leap" },
			{ "V", 100, "Buddha Explosion" }
		},
		{
			{ "Z", 1, "Shift" },
			{ "X", 20, "Heavenly Impact" },
			{ "C", 50, "Light of Annihilation" },
			{ "V", 100, "Twilight of the Gods" },
			{ "F", 100, "Retribution Dash" }
		}
	},
	["Rubber-Rubber"] = {
		{
			{ "Z", 1, "Cannon" },
			{ "X", 25, "Smash" },
			{ "C", 75, "Rush" },
			{ "V", 150, "Transformation" },
			{ "F", 75, "Slingshot" }
		}
	},
	["Spring-Spring"] = {
		{
			{ "Z", 1, "Knock" },
			{ "X", 25, "Spring Snipe" },
			{ "C", 60, "Spring Cannon" },
			{ "V", 60, "Spring Emperor" },
			{ "F", 80, "Spring Leap" }
		}
	},
	["Lightning-Lightning"] = {
		{
			{ "Z", 1, "Lightning Orb" },
			{ "X", 25, "Thunderstorm" },
			{ "C", 60, "Sky Judgement" },
			{ "V", 60, "Thunderball Destruction" },
			{ "F", 80, "Electric Flash" }
		}
	},
	["Kilo-Kilo"] = {
		{
			{ "Z", 1, "10,000 Kg" },
			{ "X", 25, "20,000 Kg" },
			{ "C", 60, "50,000 Kg" },
			{ "F", 80, "Lighten" }
		}
	},
	["Rocket-Rocket"] = {
		{
			{ "Z", 1, "Missile Fist" },
			{ "X", 25, "Air Strike" },
			{ "C", 60, "Rocket Crash" },
			{ "F", 80, "Blast Off" }
		}
	},
	["Diamond-Diamond"] = {
		{
			{ "Z", 1, "Encrust" },
			{ "X", 25, "Shard Storm" },
			{ "C", 60, "Shimmering Disruption" },
			{ "V", 80, "Prismatic Reflection" }
		}
	},
	["Love-Love"] = {
		{
			{ "Z", 1, "Heart Shot" },
			{ "X", 25, "Cupid's Zone" },
			{ "C", 60, "Irresistible Attraction" },
			{ "V", 80, "Besto Friendo" },
			{ "F", 80, "Flamingo Ride" }
		}
	},
	["Spin-Spin"] = {
		{
			{ "Z", 1, "Razor Wind" },
			{ "X", 25, "Tornado Assault" },
			{ "C", 60, "Air Slasher" },
			{ "F", 80, "Helicopter Flight" }
		}
	},
	["Ghost-Ghost"] = {
		{
			{ "Z", 1, "Shivering Possession" },
			{ "X", 25, "Spectral Release" },
			{ "C", 60, "Cries of the Underworld" },
			{ "V", 80, "Ghost Busters" },
			{ "F", 80, "Wandering Soul" }
		}
	},
	["Shadow-Shadow"] = {
		{
			{ "Z", 1, "Somber Rebellion" },
			{ "X", 20, "Shade Nest" },
			{ "C", 20, "Nightmare Leech" },
			{ "V", 20, "Corvus Torment" },
			{ "F", 20, "Umbrage" }
		}
	},
	["Door-Door"] = {
		{
			{ "Z", 1, "Spinning Door" },
			{ "X", 25, "Dimensional Door" },
			{ "C", 60, "Door Gateway" },
			{ "F", 80, "Hallway" }
		}
	},
	["Portal-Portal"] = {
		{
			{ "Z", 1, "Portal Dash" },
			{ "X", 20, "Parallel Escape" },
			{ "C", 20, "World Warp" },
			{ "V", 20, "Dimensional Rift" },
			{ "F", 20, "Quantum Leap" }
		}
	},
	["Ice-Ice"] = {
		{
			{ "Z", 1, "Ice Spears" },
			{ "X", 20, "Ice Surge" },
			{ "C", 50, "Ice Bird" },
			{ "V", 100, "Glacial Epoch" }
		},
		{
			{ "Z", 1, "Cold Storm" },
			{ "X", 20, "Glacial Surge" },
			{ "C", 50, "Frozen Dragon" },
			{ "V", 100, "Absolute Zero" },
			{ "F", 100, "Ice Skating" }
		}
	},
	["Control-Control"] = {
		{
			{ "Z", 1, "Domain Control" },
			{ "X", 20, "Slice N’ Dice" },
			{ "C", 50, "Gamma Blade" },
			{ "V", 100, "Total Concentration" },
			{ "F", 10, "Transmutation" }
		}
	},
	["Dragon (Classic)-Dragon (Classic)"] = {
		{
			{ "Z", 1, "Heatwave Beam" },
			{ "X", 20, "Dragonic Claw" },
			{ "C", 50, "Fire Shower" },
			{ "V", 100, "Transformation" },
			{ "F", 10, "Dragon Flight" }
		}
	},
	["Dragon-Dragon"] = {
		{
			{ "Z", 1, "Heatwave Cannon" },
			{ "X", 20, "Infernal Pincer" },
			{ "C", 50, "Scorching Downfall" },
			{ "V", 100, "Imperial Evolution" },
			{ "F", 10, "Draconic Soar" }
		}
	},
	["Gas-Gas"] = {
		{
			{ "Z", 1, "Suffocating Fumes" },
			{ "X", 20, "Bursting Vapor" },
			{ "C", 50, "Smog Demons" },
			{ "V", 100, "Vapor Condensation" },
			{ "F", 10, "Traveling Gas" }
		}
	},
	["Magma-Magma"] = {
		{
			{ "Z", 1, "Magma Clap" },
			{ "X", 20, "Magma Eruption" },
			{ "C", 50, "Magma Fist" },
			{ "V", 100, "Magma Meteors" },
			{ "F", 10, "Magma Floor" }
		},
		{
			{ "Z", 1, "Magma Shower" },
			{ "X", 20, "Volcanic Assault" },
			{ "C", 50, "Great Magma Hound" },
			{ "V", 100, "Volcanic Storm" },
			{ "F", 10, "Beast Ride" }
		}
	},
	["Magnet-Magnet"] = {
		{
			{ "Z", 1, "Scrap Arsenal" },
			{ "X", 20, "Magnetic Overcharge" },
			{ "C", 50, "Polarizing Drop" },
			{ "V", 100, "Maximum Overdrive" },
			{ "F", 10, "Polarity Drive" }
		}
	},
	["Venom-Venom"] = {
		{
			{ "Z", 1, "Poison Daggers" },
			{ "X", 20, "Noxious Shot" },
			{ "C", 20, "Toxic Fog" },
			{ "V", 20, "Transformation" },
			{ "F", 20, "Serpent's Wrath" }
		}
	},
	["Tiger-Tiger"] = {
		{
			{ "Z", 1, "Finger Revolver" },
			{ "X", 20, "Spiraling Kick" },
			{ "C", 20, "Afterimage Assault" },
			{ "V", 20, "Transformation" },
			{ "F", 20, "Body Flicker" }
		}
	},
	["Werewolf (Tiger)-Werewolf (Tiger)"] = {
		{
			{ "Z", 1, "Finger Revolver" },
			{ "X", 20, "Spiraling Kick" },
			{ "C", 20, "Afterimage Assault" },
			{ "V", 20, "Transformation" },
			{ "F", 20, "Body Flicker" }
		}
	},
	["Yeti-Yeti"] = {
		{
			{ "Z", 1, "Arctic Clap" },
			{ "X", 20, "Frostbite Boulder" },
			{ "C", 20, "Glacial Execution" },
			{ "V", 20, "Transformation" },
			{ "F", 20, "Tundra Rush" }
		}
	},
	["Fiend (Yeti)-Fiend (Yeti)"] = {
		{
			{ "Z", 1, "Incinerating Blaze" },
			{ "X", 20, "Hellburst Impact" },
			{ "C", 20, "Infernal Execution " },
			{ "V", 20, "Transformation" },
			{ "F", 20, "Abyssal Rush" }
		}
	},
	["Sand-Sand"] = {
		{
			{ "Z", 1, "Desert Sword" },
			{ "X", 20, "Desert Funeral" },
			{ "C", 50, "Sand Tornado" },
			{ "V", 100, "Heavy Sand" },
			{ "F", 10, "Sand Flight" }
		},
		{
			{ "Z", 1, "Desert Blade" },
			{ "X", 20, "Sand Coffin" },
			{ "C", 50, "Sandstorm" },
			{ "V", 100, "Deep Sand" },
			{ "F", 100, "Tornado Flight" }
		}
	},
	["Soul-Soul"] = {
		{
			{ "Z", 1, "Soul Snatcher" },
			{ "X", 20, "Wrath of Ra" },
			{ "C", 20, "Outraged Raijin" },
			{ "V", 20, "End of Times" },
			{ "F", 20, "Sky Ruler" }
		}
	},
	["Spirit-Spirit"] = {
		{
			{ "Z", 1, "Frostfire Grasp" },
			{ "X", 20, "Wrath of Ra" },
			{ "C", 20, "Wrath of Shu" },
			{ "V", 20, "End of Times" },
			{ "F", 20, "Sky Ruler" }
		}
	},
	["Hollow-Hollow"] = {
		{
			{ "Z", 1, "Kamikaze Ghosts" },
			{ "X", 20, "Gloomy Spirit" },
			{ "C", 20, "Starved Phantom" },
			{ "V", 20, "Revenant Lift" },
			{ "F", 20, "Spirit Projection" }
		}
	},
	["Blizzard-Blizzard"] = {
		{
			{ "Z", 1, "Snowflake Shuriken" },
			{ "X", 20, "White Out" },
			{ "C", 20, "Howling Wind" },
			{ "V", 20, "Blizzard Domain" },
			{ "F", 20, "Tornado Flight" }
		}
	},
	["Bomb-Bomb"] = {
		{
			{ "Z", 1, "Targeted Bomb" },
			{ "X", 20, "Bomb Grab" },
			{ "C", 20, "Land Mines" },
			{ "V", 20, "Self Destruct" },
			{ "F", 20, "Explosive Jump" }
		}
	},
	["Spike-Spike"] = {
		{
			{ "Z", 1, "Spike Summon" },
			{ "X", 20, "Whirlwind" },
			{ "C", 20, "Spiky Ball" },
			{ "V", 20, "Spike Barrage" }
		}
	},
	["Chop-Chop"] = {
		{
			{ "Z", 1, "Tackle" },
			{ "X", 20, "Dance" },
			{ "C", 20, "Party" },
			{ "F", 20, "Helicopter" }
		}
	},
	["Blade-Blade"] = {
		{
			{ "Z", 1, "Razor Cyclone" },
			{ "X", 20, "Blade Dance" },
			{ "C", 20, "Saw Shredder" },
			{ "F", 20, "Turbine Flight" }
		}
	},
	["Smoke-Smoke"] = {
		{
			{ "Z", 1, "Smoke Slam" },
			{ "X", 20, "Smoke Blast" },
			{ "C", 20, "Smoke Liberation" },
			{ "F", 20, "Smoke Bomber" }
		}
	},
	["Phoenix-Phoenix"] = {
		{
			{ "Z", 1, "Cannon" },
			{ "X", 20, "Regeneration Flames" },
			{ "C", 20, "Fast Kick" },
			{ "V", 20, "Full Transformation" },
			{ "F", 20, "Hybrid Flight" }
		},
		{
			{ "Z", 1, "Cremation Cannon" },
			{ "X", 20, "Blue Flames" },
			{ "C", 20, "Flame Exodus" },
			{ "V", 20, "Blazing Plumage" },
			{ "F", 20, "Swift Flight" }
		}
	},
	["Eagle-Eagle"] = {
		{
			{ "Z", 1, "Wind Burst" },
			{ "X", 20, "Feather Storm" },
			{ "C", 20, "Bone Crusher" },
			{ "V", 20, "Soaring Talon" },
			{ "F", 20, "Flight" }
		}
	},
	["Sound-Sound"] = {
		{
			{ "Z", 1, "Rhapsody Notes" },
			{ "X", 20, "Fortissimo" },
			{ "C", 20, "Symphonic Radiance" },
			{ "V", 20, "Glorious Harmony" },
			{ "F", 20, "Tempo: Prestissimo" }
		}
	},
	["Mammoth-Mammoth"] = {
		{
			{ "Z", 1, "Ancient Cutter" },
			{ "X", 20, "True Prehistoric Punt" },
			{ "C", 20, "Colossal Crusher" },
			{ "V", 20, "Transformation" },
			{ "F", 20, "Stampede" }
		}
	},
	["Spider-Spider"] = {
		{
			{ "Z", 1, "Spider Wraith" },
			{ "X", 20, "Multi-string Attack" },
			{ "C", 20, "Over-heated Sniper" },
			{ "V", 20, "Ultimate Thread" },
			{ "F", 20, "Spider Path" }
		},
		{
			{ "Z", 1, "Thermal Laceration" },
			{ "X", 20, "Silk Prison" },
			{ "C", 20, "Eternal White" },
			{ "V", 20, "Heavenly Punishment" },
			{ "F", 20, "Spider Highway" }
		}
	},
	["Gravity-Gravity"] = BuildUtil.getIfNewGravityEnabled() and {
		{
			{ "Z", 1, "Singularity" },
			{ "X", 20, "Orbital Chain" },
			{ "C", 20, "Gravitational Prison" },
			{ "V", 20, "Asteroid Crash" },
			{ "F", 20, "Shooting Star" }
		}
	} or {
		{
			{ "Z", 1, "Gravity Push" },
			{ "X", 20, "Gravity Obeisance" },
			{ "C", 20, "Meteor Pitch" },
			{ "V", 20, "Meteors Rain" },
			{ "F", 20, "Boulder Flight" }
		}
	},
	["Pain-Pain"] = {
		{
			{ "Z", 1, "Fury Jab" },
			{ "X", 20, "Rage Release" },
			{ "C", 20, "Agony Nuke" },
			{ "V", 20, "Torturing Pulse" },
			{ "F", 20, "Torment Warp" }
		}
	},
	["Barrier-Barrier"] = {
		{
			{ "Z", 1, "Barrier Wall" },
			{ "X", 20, "Surprise Attack" },
			{ "C", 20, "Barrier Prison" },
			{ "V", 20, "Barrier Towers" },
			{ "F", 20, "Stairs" }
		}
	},
	["Creation-Creation"] = {
		{
			{ "Z", 1, "Batter Up" },
			{ "X", 20, "Sleight of Hand" },
			{ "C", 20, "Sword Box" },
			{ "V", 20, "Magic City" },
			{ "F", 20, "Fortify" }
		}
	},
	["Kitsune-Kitsune"] = {
		{
			{ "Z", 1, "Accursed Enchantment" },
			{ "X", 20, "Tails of Burning Agony" },
			{ "C", 20, "Fox Fire Disruption" },
			{ "V", 20, "Transformation" },
			{ "F", 20, "Wild Assault" }
		}
	},
	["Empyrean (Kitsune)-Empyrean (Kitsune)"] = {
		{
			{ "Z", 1, "Sweeping Firestorm" },
			{ "X", 20, "Tails of Burning Agony" },
			{ "C", 20, "Burstfire Cannon" },
			{ "V", 20, "Transformation" },
			{ "F", 20, "Wild Assault" }
		}
	},
	["T-Rex-T-Rex"] = {
		{
			{ "Z", 1, "Tail Swipe" },
			{ "X", 20, "Predatory Screech" },
			{ "C", 20, "Hunter's Rage" },
			{ "V", 20, "Reptilian Scales" },
			{ "F", 20, "Gigantic Leap" }
		}
	},
	["Dough-Dough"] = {
		{
			{ "Z", 1, "Fried Dough" },
			{ "X", 20, "Sticky Dough" },
			{ "C", 20, "Carved Dough" },
			{ "V", 20, "Restless Dough Barrage" },
			{ "F", 20, "Roller Donut" }
		},
		{
			{ "Z", 1, "Missile Jab" },
			{ "X", 20, "Pastry River" },
			{ "C", 20, "Piercing Clothesline" },
			{ "V", 20, "Dough Fist Fusillade" },
			{ "F", 20, "Scorching Donut" }
		}
	},
	["Bastar-Bastar"] = {
		{
			{ "Z", 1, "Room" }
		}
	},
	["Meme-Meme"] = {
		{
			{ "Z", 1, "Traffic Cone" },
			{ "X", 5, "Cone Flight" }
		}
	},
	["Rogue-Rogue"] = {
		{
			{ "Z", 1, "Mori" },
			{ "X", 1, "Snap Mori" }
		}
	},
	Disguiser = {
		{
			{ "Z", 1, "Disguise" },
			{ "X", 1, "Stance Switch" },
			{ "C", 1, "Reveal" },
			{ "V", 1, "Grant" }
		}
	},
	Combat = {
		{
			{ "Z", 1, "Quick Tackle" },
			{ "X", 20, "Ground Smash" }
		}
	},
	["Advanced Combat"] = {
		{
			{ "Z", 1, "Meteor Tackle" },
			{ "X", 100, "Ground Breaker" },
			{ "C", 200, "Charged Punch" }
		}
	},
	["Black Leg"] = {
		{
			{ "Z", 1, "Flying Kick" },
			{ "X", 20, "Breakdance" },
			{ "C", 50, "Barrage" },
			{ "V", 100, "Overheat" }
		}
	},
	["Death Step"] = {
		{
			{ "Z", 1, "Rocket Kick" },
			{ "X", 20, "Wind Bullet" },
			{ "C", 50, "Vermillion Drill" },
			{ "V", 100, "Maximum Overheat" }
		}
	},
	Electro = {
		{
			{ "Z", 1, "Stomp" },
			{ "X", 20, "Electrical Tackle" },
			{ "C", 50, "Electrical Floor" }
		}
	},
	["Electric Claw"] = {
		{
			{ "Z", 1, "Electric Rampage" },
			{ "X", 20, "Lightning Thrust" },
			{ "C", 50, "Thunderclap and Flash" }
		}
	},
	["Fishman Karate"] = {
		{
			{ "Z", 1, "Steam-Charged Fist" },
			{ "X", 20, "Deadly Shower" },
			{ "C", 50, "Heavy Water Punch" }
		}
	},
	["Sharkman Karate"] = {
		{
			{ "Z", 1, "Twelve Water Palms" },
			{ "X", 20, "Pressure Vortex" },
			{ "C", 50, "Great Sea Spear" }
		}
	},
	["Dragon Claw"] = {
		{
			{ "Z", 1, "Dragon Rush" },
			{ "X", 20, "Dragon Flames" },
			{ "C", 50, "Dragon Explosion" }
		}
	},
	Superhuman = {
		{
			{ "Z", 1, "Beast Owl Pounce" },
			{ "X", 20, "Thunder Clap" },
			{ "C", 50, "Conqueror Gun" }
		}
	},
	Godhuman = {
		{
			{ "Z", 1, "Soaring Beast" },
			{ "X", 20, "Heaven and Earth" },
			{ "C", 50, "Sixth Realm Gun" }
		}
	},
	["Dragon Talon"] = {
		{
			{ "Z", 1, "Talon Lighter" },
			{ "X", 20, "Ember Annihilation" },
			{ "C", 50, "Infernal Vortex" }
		}
	},
	["Sanguine Art"] = {
		{
			{ "Z", 1, "Bloodbane Drain" },
			{ "X", 20, "Scarlet Tear" },
			{ "C", 50, "Devourer of Worlds" }
		}
	},
	["Divine Art"] = {
		{
			{ "Z", 1, "Fool's Demise" },
			{ "X", 20, "Judgement of the Pitiful" },
			{ "C", 50, "Timeless Misery" }
		}
	},
	["Twin Hooks"] = {
		{
			{ "Z", 1, "Sky Cyclone" },
			{ "X", 20, "Prehistoric Punt" }
		}
	},
	["Spikey Trident"] = {
		{
			{ "Z", 1, "Dough Hurricane" },
			{ "X", 20, "Flying Trident Pull" }
		}
	},
	["Buddy Sword"] = {
		{
			{ "Z", 1, "Heat Slash" },
			{ "X", 20, "Lightning Wave" }
		}
	},
	["Dual Katana"] = {
		{
			{ "Z", 1, "Whirlwind" },
			{ "X", 20, "Tornado" }
		}
	},
	Katana = {
		{
			{ "Z", 1, "Quiet Rush" },
			{ "X", 20, "Air Slash" }
		}
	},
	Cutlass = {
		{
			{ "Z", 1, "Quiet Rush" },
			{ "X", 20, "Air Slash" }
		}
	},
	["Dark Blade"] = {
		{
			{ "Z", 1, "One Thousand Slices" },
			{ "X", 20, "Dark Air Slash" }
		}
	},
	["Triple Dark Blade"] = {
		{
			{ "Z", 1, "One Thousand Slices" },
			{ "X", 20, "Dark Air Slash" }
		}
	},
	["Fishing Trophy"] = {
		{
			{ "Z", 1, "Trophy Aura" }
		}
	},
	["Bronze Trophy"] = {
		{
			{ "Z", 1, "Trophy Aura" }
		}
	},
	["Silver Trophy"] = {
		{
			{ "Z", 1, "Trophy Aura" }
		}
	},
	["Gold Trophy"] = {
		{
			{ "Z", 1, "Trophy Aura" }
		}
	},
	["Platinum Trophy"] = {
		{
			{ "Z", 1, "Trophy Aura" }
		}
	},
	["Diamond Trophy"] = {
		{
			{ "Z", 1, "Trophy Aura" }
		}
	},
	["Master Trophy"] = {
		{
			{ "Z", 1, "Trophy Aura" }
		}
	},
	["Dark Dagger"] = {
		{
			{ "Z", 1, "Proficient Impale" },
			{ "X", 20, "Shaming Slash" }
		}
	},
	["Shark Anchor"] = {
		{
			{ "Z", 1, "Typhoon Toss" },
			{ "X", 20, "Armor Breaker" }
		}
	},
	["Fox Lamp"] = {
		{
			{ "Z", 1, "Scorching Azure" },
			{ "X", 20, "Infernal Firestorm" }
		}
	},
	Bisento = {
		{
			{ "Z", 1, "Wind Breaker" },
			{ "X", 20, "Quake Sphere" }
		}
	},
	Flail = {
		{
			{ "Z", 1, "Smoke Tiger" },
			{ "X", 20, "Smoke Apparition" }
		}
	},
	Koko = {
		{
			{ "Z", 1, "Electric Stab" },
			{ "X", 20, "Injection Shot" }
		}
	},
	["Triple Katana"] = {
		{
			{ "Z", 1, "Air Slashes Barrage" },
			{ "X", 20, "Violent Rush" }
		}
	},
	["True Triple Katana"] = {
		{
			{ "Z", 1, "Wolf Fang Rush" },
			{ "X", 20, "Dragon Hurricane" }
		}
	},
	["Hallow Scythe"] = {
		{
			{ "Z", 1, "Death Cyclone" },
			{ "X", 20, "Soul Execution" }
		}
	},
	Trident = {
		{
			{ "Z", 1, "Trident Throw" },
			{ "X", 20, "Water Pulse" }
		}
	},
	["Dragon Trident"] = {
		{
			{ "Z", 1, "Sea Dragon Fury" },
			{ "X", 20, "Water Dragon Shower" }
		}
	},
	Rengoku = {
		{
			{ "Z", 1, "Demon Slayer" },
			{ "X", 20, "Burning Slash" }
		}
	},
	Saber = {
		{
			{ "Z", 1, "Deadly Rush" },
			{ "X", 20, "Triple Slash" }
		}
	},
	["Shark Saw"] = {
		{
			{ "Z", 1, "Consecutive Slashes" },
			{ "X", 20, "Execution" }
		}
	},
	["Iron Mace"] = {
		{
			{ "Z", 1, "Mace Smash" },
			{ "X", 20, "Killer Combo" }
		}
	},
	["Wardens Sword"] = {
		{
			{ "Z", 1, "Multi-Target Slash" },
			{ "X", 20, "Tornado Slash" }
		}
	},
	Pipe = {
		{
			{ "Z", 1, "Pipe Ignition" },
			{ "X", 20, "Dragon Blast" }
		}
	},
	["Dual-Headed Blade"] = {
		{
			{ "Z", 1, "Assassinate" },
			{ "X", 20, "Raging Wind" }
		}
	},
	["Soul Cane"] = {
		{
			{ "Z", 1, "Soul Beam" },
			{ "X", 20, "Soul Slashes" }
		}
	},
	["Pole (1st Form)"] = {
		{
			{ "Z", 1, "Explosive Cloud" },
			{ "X", 20, "Lightning Rain" }
		}
	},
	["Pole (2nd Form)"] = {
		{
			{ "Z", 1, "Hand of God" },
			{ "X", 20, "Electric Prison" }
		}
	},
	["Gravity Blade"] = {
		{
			{ "Z", 1, "Dimensional Grasp" },
			{ "X", 20, "Lunar Blitz" }
		}
	},
	Shizu = {
		{
			{ "Z", 1, "True Quiet Rush" },
			{ "X", 20, "Focus Shot" }
		}
	},
	Canvander = {
		{
			{ "Z", 1, "Piercing Dash" },
			{ "X", 20, "Scattering Gust" }
		}
	},
	Yama = {
		{
			{ "Z", 1, "Hellish Slash" },
			{ "X", 20, "Infernal Hurricane" }
		}
	},
	["Cursed Dual Katana"] = {
		{
			{ "Z", 1, "Revolving Ravager" },
			{ "X", 20, "Slayer of Goliath" }
		}
	},
	Tushita = {
		{
			{ "Z", 1, "Heavenly Lunges" },
			{ "X", 20, "Celestial Ravager" }
		}
	},
	Saishi = {
		{
			{ "Z", 1, "Swords Dance" },
			{ "X", 20, "True Air Slash" }
		}
	},
	Oroshi = {
		{
			{ "Z", 1, "Continuous Slashing" },
			{ "X", 20, "Dragon Gust" }
		}
	},
	Longsword = {
		{
			{ "Z", 1, "Annihilate" },
			{ "X", 20, "Glorious Smash" }
		}
	},
	["Midnight Blade"] = {
		{
			{ "Z", 1, "Portal Opening" },
			{ "X", 20, "Crescent Dash" }
		}
	},
	Dragonheart = {
		{
			{ "Z", 1, "Draconic Blitz" },
			{ "X", 20, "Infernal Catastrophe" }
		}
	},
	["The Sword Of The Brat"] = {
		{
			{ "Z", 1, "Spoiled Strike" },
			{ "X", 20, "Tantrum Mode" }
		}
	},
	Slingshot = {
		{
			{ "Z", 1, "Ink Bomb" },
			{ "X", 20, "Proximity Bomb" }
		}
	},
	["Refined Slingshot"] = {
		{
			{ "Z", 1, "Ink Swarm" },
			{ "X", 20, "Cluster Bomb" }
		}
	},
	Flintlock = {
		{
			{ "Z", 1, "Concentrated Shot" },
			{ "X", 20, "Marksman Fury" }
		}
	},
	["Dual Flintlock"] = {
		{
			{ "Z", 1, "Splitting Beam" },
			{ "X", 20, "Bullet Storm" }
		}
	},
	Musket = {
		{
			{ "Z", 1, "Draconic Bullet" },
			{ "X", 20, "Torching Shot" }
		}
	},
	["Magma Blaster"] = {
		{
			{ "Z", 1, "Scorching Burst" },
			{ "X", 20, "Magmatic Pressure" }
		}
	},
	Cannon = {
		{
			{ "Z", 1, "Chain Detonation" },
			{ "X", 20, "Incendiary Ammo" }
		}
	},
	Bazooka = {
		{
			{ "Z", 1, "Heat Wave" },
			{ "X", 20, "Flaring Missiles" }
		}
	},
	Kabucha = {
		{
			{ "Z", 1, "Blazing Phoenix" },
			{ "X", 20, "Dragon Tempest" }
		}
	},
	["Venom Bow"] = {
		{
			{ "Z", 1, "Venomous Spit" },
			{ "X", 20, "Serpent Bite" }
		}
	},
	["Skull Guitar"] = {
		{
			{ "Z", 1, "Soul Shaker" },
			{ "X", 20, "El Diablo" }
		}
	},
	["Acidum Rifle"] = {
		{
			{ "Z", 1, "Spiky Bomb" },
			{ "X", 20, "Acidic Smoke" }
		}
	},
	["Bizarre Revolver"] = {
		{
			{ "Z", 1, "Space Bending Blast" },
			{ "X", 20, "Dimensional Surge" }
		}
	},
	Dragonstorm = {
		{
			{ "Z", 1, "Draconic Cascade" },
			{ "X", 20, "Infernal Comet" }
		}
	},
	Gun = {}
}

function decodeLegacyEntry(list)
	local trigger = list[1]
	assert(typeof(trigger) == "string", (`bad trigger: "{trigger}"`))
	local lvl = list[2]
	assert(typeof(lvl) == "number", (`bad level: "{lvl}"`))
	local name = list[3]
	assert(typeof(name) == "string", (`bad name: "{name}"`))
	return {
		Lvl = lvl,
		Trigger = trigger,
		Name = name
	}
end

function encodeLegacyEntry(data)
	return { data.Trigger, data.Lvl, data.Name }
end

function patchRowSet(list, p)
	for i, v in ipairs(list) do
		local v2 = decodeLegacyEntry(v)
		v2.Lvl = p.Lvl[v2.Trigger] or v2.Lvl
		list[i] = encodeLegacyEntry(v2)
	end
end

local fruitDataAsync = FruitSkillUtil.getFruitDataAsync()

for k, v in pairs(FruitSkills) do
	local v2 = fruitDataAsync[k]

	if not v2 then
		continue
	end

	local v3 = v[1]
	assert(v3, (`empty entry: "{k}"`))
	patchRowSet(v3, v2)
	local v4 = v[2]

	if v4 then
		patchRowSet(v4, v2)
	end
end

return FruitSkills