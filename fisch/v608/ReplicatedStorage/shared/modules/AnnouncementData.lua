local ReplicatedStorage = game:GetService("ReplicatedStorage")
local sfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx")
local AnnouncementData = {
	SharkHunt = {
		Category = "Hunt",
		Name = "Shark Hunt",
		Color = Color3.fromRGB(255, 62, 120),
		Sounds = {
			Start = sfx.event.shark,
			Caught = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> has been spotted <e>%s</e>!",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			}
		}
	},
	MegalodonHunt = {
		Category = "Hunt",
		Name = "Megalodon Hunt",
		Color = Color3.fromRGB(228, 8, 10),
		RequiredDiscoveredLocation = "Ancient Isle",
		Sounds = {
			Start = sfx.event.meg,
			Caught = sfx.ui.topnotify
		},
		Variants = {
			Normal = {
				Color = Color3.fromRGB(228, 8, 10),
				SoundPitches = {
					Start = 0.85
				}
			},
			Ancient = {
				Color = Color3.fromRGB(212, 71, 71),
				SoundPitches = {
					Start = 0.8
				}
			},
			Phantom = {
				Color = Color3.fromRGB(105, 127, 255),
				SoundPitches = {
					Start = 0.75
				}
			}
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> has been spotted past Ancient Isle!",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> got away..."
			}
		}
	},
	KrakenHunt = {
		Category = "Hunt",
		Name = "Kraken Hunt",
		Color = Color3.fromRGB(255, 0, 127),
		RequiredDiscoveredLocation = "Atlantis",
		Sounds = {
			Start = sfx.event.kraken,
			Caught = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>Kraken</e> has been spotted in Atlantis!",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> got away..."
			}
		}
	},
	ScyllaHunt = {
		Category = "Hunt",
		Name = "Scylla Hunt",
		Color = Color3.fromRGB(15, 255, 163),
		RequiredDiscoveredLocation = "Veil of the Forsaken",
		Sounds = {
			Start = sfx.event.scylla,
			Caught = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> has been spotted in the Veil of the Forsaken!",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> got away..."
			}
		}
	},
	ColossalBlueDragon = {
		Category = "Hunt",
		Name = "Colossal Blue Dragon Hunt",
		Color = Color3.fromRGB(59, 209, 255),
		RequiredDiscoveredLocation = "Luminescent Cavern",
		Sounds = {
			Start = sfx.event.colossalDragon,
			Caught = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> has been emerged in the %s!",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> retreats into the cavern's depths..."
			}
		}
	},
	ColossalAncientDragon = {
		Category = "Hunt",
		Name = "Colossal Ancient Dragon Hunt",
		Color = Color3.fromRGB(228, 8, 10),
		RequiredDiscoveredLocation = "Crimson Cavern",
		Sounds = {
			Start = sfx.event.colossalDragon,
			Caught = sfx.ui.topnotify
		},
		SoundPitches = {
			Start = 0.65
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> has been emerged in the %s!",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> retreats into the cavern's depths..."
			}
		}
	},
	ColossalEtherealDragon = {
		Category = "Hunt",
		Name = "Colossal Ethereal Dragon Hunt",
		Color = ColorSequence.new(Color3.fromRGB(255, 150, 231), Color3.fromRGB(255, 255, 255)),
		RequiredDiscoveredLocation = "Luminescent Cavern",
		Sounds = {
			Start = sfx.event.colossalDragonEthereal,
			Caught = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> has been emerged in the %s!",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> retreats into the cavern's depths..."
			}
		}
	},
	PlesiosaurHunt = {
		Category = "Hunt",
		Name = "Plesiosaur Hunt",
		Color = Color3.fromRGB(143, 211, 255),
		RequiredDiscoveredLocation = "Tidefall",
		Sounds = {
			Start = sfx.event.plesiosaur,
			Caught = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> lurks in Tidefall's inner castle...",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> vanishes into the castle's depths..."
			}
		},
		CustomUnlock = function(_, p)
			return p.Tidefall.Obelisks.GateOpen
		end
	},
	ReefTitanHunt = {
		Category = "Hunt",
		Name = "Reef Titan Hunt",
		Color = Color3.fromRGB(66, 142, 255),
		RequiredDiscoveredLocation = "Coral Bastion",
		Sounds = {
			Start = sfx.event.reeftitan,
			Caught = sfx.ui.topnotify
		},
		Variants = {
			Normal = {
				Color = Color3.fromRGB(66, 142, 255)
			},
			Ancient = {
				Color = ColorSequence.new(Color3.fromRGB(57, 128, 190), Color3.fromRGB(63, 172, 136)),
				SoundPitches = {
					Start = 0.6
				}
			}
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> awakens in the Coral Bastion...",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> sinks back into the reef..."
			}
		}
	},
	OmnithalHunt = {
		Category = "Hunt",
		Name = "Omnithal Hunt",
		Color = Color3.fromRGB(156, 131, 255),
		RequiredDiscoveredLocation = "Sunken Reliquary",
		Sounds = {
			Start = sfx.event.omnithal,
			Caught = sfx.ui.topnotify
		},
		Variants = {
			Normal = {
				Color = Color3.fromRGB(156, 131, 255)
			},
			Ancient = {
				Color = ColorSequence.new(Color3.fromRGB(87, 92, 194), Color3.fromRGB(113, 71, 172)),
				SoundPitches = {
					Start = 0.75
				}
			}
		},
		Messages = {
			Start = {
				PrimaryText = "An <e>%s</e> manifests in the Sunken Reliquary...",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> dissolves into the reliquary's gloom..."
			}
		}
	},
	PliosaurHunt = {
		Category = "Hunt",
		Name = "Pliosaur Hunt",
		Color = Color3.fromRGB(255, 172, 172),
		RequiredDiscoveredLocation = "Collapsed Ruins",
		Sounds = {
			Start = sfx.event.pliosaur,
			Caught = sfx.ui.topnotify
		},
		Variants = {
			Normal = {
				Color = Color3.fromRGB(255, 172, 172)
			},
			Ancient = {
				Color = ColorSequence.new(Color3.fromRGB(255, 172, 172), Color3.fromRGB(255, 170, 248)),
				SoundPitches = {
					Start = 0.6
				}
			}
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> stalks the Collapsed Ruins...",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> crumbles into the ruins..."
			}
		}
	},
	GoldwraithHunt = {
		Category = "Hunt",
		Name = "Goldwraith Hunt",
		Color = Color3.fromRGB(255, 215, 90),
		RequiredDiscoveredLocation = "Crowned Ruins",
		Sounds = {
			Start = sfx.event.goldwraith,
			Caught = sfx.ui.topnotify
		},
		Variants = {
			Normal = {
				Color = Color3.fromRGB(255, 215, 90)
			},
			Ancient = {
				Color = ColorSequence.new(Color3.fromRGB(112, 41, 0), Color3.fromRGB(90, 71, 0)),
				SoundPitches = {
					Start = 0.6
				}
			}
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> drifts through the Crowned Ruins...",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> fades into crowned shadows..."
			}
		}
	},
	NarwhalHunt = {
		Category = "Hunt",
		Name = "Narwhal Hunt",
		Color = Color3.fromRGB(255, 0, 0),
		Sounds = {
			Start = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> has been spotted near <e>%s</e>!",
				SecondaryText = "[Catch rare fish while they're still around!]"
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> got away..."
			}
		}
	},
	MosslurkerHunt = {
		Category = "Hunt",
		Name = "Mosslurker Hunt",
		Color = Color3.fromRGB(255, 0, 0),
		Sounds = {
			Start = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s</e> has been spotted near <e>%s</e>!",
				SecondaryText = "[Catch rare fish while they're still around!]"
			},
			Escaped = {
				ChatMessage = "The <e>%s</e> got away..."
			}
		}
	},
	OrcaMigration = {
		Category = "Hunt",
		Name = "Orca Migration",
		Color = Color3.fromRGB(113, 196, 214),
		Sounds = {
			Start = sfx.event.orcaMigration,
			AllCaught = sfx.ui.topnotify
		},
		Variants = {
			Normal = {
				Color = Color3.fromRGB(113, 196, 214)
			},
			Ancient = {
				Color = Color3.fromRGB(124, 164, 168)
			}
		},
		Messages = {
			Start = {
				PrimaryText = "An <e>%s Migration</e> has started near %s!"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught an <e>%s</e>! (%d/%d)",
				Small = true,
				NoChat = true
			},
			AllCaught = {
				PrimaryText = "All <e>%ss</e> have been caught!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%ss</e> continue their migration..."
			}
		}
	},
	BlueWhaleMigration = {
		Category = "Hunt",
		Name = "Blue Whale Migration",
		Color = Color3.fromRGB(23, 105, 182),
		Sounds = {
			Start = sfx.event.whaleMigration,
			AllCaught = sfx.ui.topnotify,
			CaughtMoby = sfx.ui.topnotify
		},
		Variants = {
			Normal = {
				Color = Color3.fromRGB(23, 105, 182)
			},
			Moby = {
				Color = Color3.fromRGB(54, 85, 132)
			}
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>%s Migration</e> has started near %s!"
			},
			Caught = {
				PrimaryText = "<e>%s</e> has caught a <e>%s</e>! (%d/%d)",
				Small = true,
				NoChat = true
			},
			CaughtMoby = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			AllCaught = {
				PrimaryText = "All <e>Whales</e> have been caught!",
				Small = true
			},
			Escaped = {
				ChatMessage = "The <e>%ss</e> continue their migration..."
			}
		}
	},
	BloopHunt = {
		Category = "Hunt",
		Name = "Bloop Hunt",
		Color = Color3.fromRGB(255, 0, 0),
		Sounds = {
			StartBaby = sfx.event.babyBloop,
			CaughtBabyAll = sfx.ui.topnotify,
			StartAdult = sfx.event.bloop,
			CaughtAdult = sfx.ui.topnotify
		},
		Variants = {
			Baby = {
				Color = Color3.fromRGB(255, 181, 217)
			},
			Adult = {
				Color = Color3.fromRGB(255, 0, 0)
			}
		},
		Messages = {
			StartBaby = {
				PrimaryText = "Several <e>%s</e> have been spotted %s!",
				SecondaryText = "[Catch as many as possible to awaken their mother...]"
			},
			CaughtBaby = {
				PrimaryText = "<e>%s</e> has caught a <e>%s</e>! (%d/%d)",
				Small = true,
				NoChat = true
			},
			CaughtBabyAll = {
				PrimaryText = "All <e>%s</e> have been caught! Something is awakening...",
				Small = true
			},
			StartAdult = {
				PrimaryText = "The <e>%s</e> has been awakened!",
				SecondaryText = "[Be the first and only to catch it!]"
			},
			CaughtAdult = {
				PrimaryText = "<e>%s</e> has caught the <e>%s</e>!",
				Small = true
			},
			Escaped = {
				PrimaryText = "The <e>%s</e> got away... (%d/%d)",
				Small = true
			}
		}
	},
	AbsoluteDarkness = {
		Category = "Hunt",
		Name = "Absolute Darkness",
		Color = ColorSequence.new(Color3.fromRGB(83, 79, 58), Color3.fromRGB(40, 57, 34)),
		RequiredDiscoveredLocation = "The Depths",
		OnlyInZones = { "The Depths" },
		Sounds = {
			Start = sfx.event.absoluteDarkness
		},
		Messages = {
			Start = {
				PrimaryText = "The Depths have grown darker!",
				SecondaryText = "[An ancient presence stirs...]"
			},
			End = {
				PrimaryText = "Light has returned to The Depths.",
				Small = true
			}
		}
	},
	Eruption = {
		Category = "Hunt",
		Name = "Eruption",
		Color = Color3.fromRGB(255, 69, 0),
		RequiredDiscoveredLocation = "Roslit Volcano",
		Sounds = {
			Start = sfx.event.blackmarket,
			Caught = sfx.ui.topnotify,
			Fail = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "The <e>Roslit Volcano</e> trembles violently — <e>Ashclaw</e> stirs within the magma!",
				SecondaryText = "[Catch it before the eruption begins!]"
			},
			Caught = {
				PrimaryText = "<e>%s</e> captured <e>Ashclaw</e> and quelled the <e>Roslit Volcano</e>!",
				SecondaryText = "The land breathes a sigh of relief."
			},
			Fail = {
				PrimaryText = "The <e>Roslit Volcano</e> has <e>erupted</e>, hope you weren't too close!"
			}
		}
	},
	Earthquake = {
		Category = "Hunt",
		Name = "Earthquake",
		Color = Color3.fromRGB(255, 170, 0),
		Sounds = {
			Start = sfx.event.blackmarket,
			Fail = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "An <e>Earthquake</e> is happening, awakening Apex fish in the ocean!"
			},
			Fail = {
				ChatMessage = "The <e>Earthquake</e> has subsided."
			}
		}
	},
	Blizzard = {
		Category = "LocalEvent",
		Name = "Blizzard",
		Color = Color3.fromRGB(184, 224, 255),
		RequiredDiscoveredLocation = "Overgrowth Caves",
		OnlyInZones = {
			"Cryogenic Canal",
			"Frigid Cavern",
			"Glacial Grotto",
			"Northern Summit",
			"Overgrowth Caves"
		},
		Sounds = {
			Start = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>Blizzard</e> has begun!"
			}
		}
	},
	Avalanche = {
		Category = "LocalEvent",
		Name = "Avalanche",
		Color = Color3.fromRGB(147, 185, 203),
		RequiredDiscoveredLocation = "Overgrowth Caves",
		OnlyInZones = {
			"Cryogenic Canal",
			"Frigid Cavern",
			"Glacial Grotto",
			"Northern Summit",
			"Overgrowth Caves"
		},
		Sounds = {
			Start = sfx.event.avalanche
		},
		Messages = {
			Start = {
				PrimaryText = "⚠️ <e>Avalanche Warning!</e> ⚠️",
				SecondaryText = "[Watch out for falling debris!]",
				ChatMessage = "An <e>Avalanche</e> is starting!"
			},
			End = {
				PrimaryText = "The mountainside returns to normal...",
				Small = true
			}
		}
	},
	BrineStorm = {
		Category = "LocalEvent",
		Name = "Brine Storm",
		Color = Color3.fromRGB(147, 185, 203),
		RequiredDiscoveredLocation = "Brine Pool",
		OnlyInZones = { "Brine Pool", "Desolate Deep" },
		Sounds = {
			Start = sfx.event.brineStorm,
			End = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>Brine Storm</e> has begun at the Brine Pool!",
				SecondaryText = "[Unique fish are now appearing! Lure speed is halved...]"
			},
			End = {
				PrimaryText = "The <e>Brine Storm</e> has subsided.",
				Small = true
			}
		}
	},
	CursedStorm = {
		Category = "ServerEvent",
		Name = "Cursed Storm",
		Color = Color3.fromRGB(8, 243, 153),
		Sounds = {
			Start = sfx.ui.topnotify
		},
		Messages = {
			Start = {
				PrimaryText = "A <e>Cursed Storm</e> has occurred by %s!"
			}
		}
	},
	BlueMoon = {
		Category = "ServerEvent",
		Name = "Blue Moon",
		Color = Color3.fromRGB(109, 169, 228),
		Sounds = {
			Start = sfx.event.bluemoon
		},
		Messages = {
			Start = {
				PrimaryText = "There is a <e>Blue Moon</e> in the sky!"
			}
		}
	},
	SunkenChests = {
		Category = "OtherCommon",
		Name = "Blue Moon",
		Color = Color3.fromRGB(109, 169, 228),
		Sounds = {
			Start = sfx.event.bluemoon
		},
		Messages = {
			Start = {
				PrimaryText = "There is a <e>Blue Moon</e> in the sky!"
			}
		}
	}
}

for k, v in AnnouncementData do
	v.Id = k

	for k2, variant in v.Variants do
		variant.Id = k2
	end
end

return AnnouncementData