local RoomAudioConfig = {
	CommonSounds = {
		Warehouse = 9112759541,
		Studio = 9112775175,
		Diner = 9125515916,
		Space = 18224111036,
		Forest = 77715219904862,
		DyleStation = 90242390594047,
		Christmas = 99965729393079,
		VeeAmbient = 129284429556998,
		Halloween = 137357619034399,
		LockedAway = 75563390163866,
		TrainHorn = 9114232124,
		TrainMove = 9114234050,
		TrainIdle = 9114235591,
		TrainSteam = 9113993247,
		Chatter1 = 17432316632,
		Chatter2 = 17432316740,
		Chatter3 = 17432316830,
		BigCreak = 9126282111,
		Scare = 3649815935,
		Cave = 3173577378,
		ScarySound = 5742069835,
		ScarySound2 = 6420027936,
		Creak2 = 9125685503,
		Creak3_Wood = 3999387143,
		Creak3_Metal = 6921344480,
		Creak3_Long = 7924080681,
		Ambient = 8232976983,
		Ambient2 = 3179847853,
		Hit = 5876042680,
		Buzz = 1103690959,
		ScarySound3_Whisper = 157636421,
		ScarySound3_Breath = 635822826,
		ScarySound4_Short = 157636218,
		ScarySound4_Long = 3196341435,
		ScarySound5 = 3179846605,
		ScarySound6 = 8234114045,
		Memory = 8813299514,
		Slam = 9116635199,
		SpaceSound = 9114548798,
		ShellyAmbience = 137852994880136,
		Ambient3 = 9043344583,
		Scare2 = 3179847853,
		Scare3 = 3196341435,
		Scare4 = 9113731836
	}
}
RoomAudioConfig.Rooms = {
	ArtistRoom1 = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	ArtistRoom2 = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	ArtistRoom3 = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	RainbowWall1 = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	RainbowWall2 = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	RainbowHallways1 = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.25,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	EmotionMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	EmotionMapTest = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	ProjectorMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	StoryboardMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	GiantPostersMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	AquariumMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	ArtGallery = {
		floor = 2,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	VeeMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.VeeAmbient,
				volume = 1.25
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "ShellyAmbience",
				id = RoomAudioConfig.CommonSounds.ShellyAmbience,
				volume = 0.24,
				playbackSpeed = 0.2
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			}
		},
		randomInterval = {
			min = 18,
			max = 40
		}
	},
	ShellyMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Diner,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "ShellyAmbience",
				id = RoomAudioConfig.CommonSounds.ShellyAmbience,
				volume = 0.24,
				playbackSpeed = 0.2
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			}
		},
		randomInterval = {
			min = 18,
			max = 40
		}
	},
	SproutMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Forest,
				volume = 0.6
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "ShellyAmbience",
				id = RoomAudioConfig.CommonSounds.ShellyAmbience,
				volume = 0.24,
				playbackSpeed = 0.2
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			}
		},
		randomInterval = {
			min = 18,
			max = 40
		}
	},
	HalloweenMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Halloween,
				volume = 0.8
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Buzz",
				id = RoomAudioConfig.CommonSounds.Buzz,
				volume = 0.15
			},
			{
				name = "Chatter1",
				id = RoomAudioConfig.CommonSounds.Chatter1,
				volume = 0.12
			},
			{
				name = "Chatter2",
				id = RoomAudioConfig.CommonSounds.Chatter2,
				volume = 0.12
			},
			{
				name = "Chatter3",
				id = RoomAudioConfig.CommonSounds.Chatter3,
				volume = 0.12
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	Warehouse3 = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Warehouse,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Buzz",
				id = RoomAudioConfig.CommonSounds.Buzz,
				volume = 0.15
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	Diner3 = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Diner,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.24,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound2",
				id = 7076366171,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Long",
				id = RoomAudioConfig.CommonSounds.Creak3_Long,
				volume = 0.33
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound5,
				volume = 0.33,
				playbackSpeed = 0.95
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	ChristmasMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Christmas,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.24,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound2",
				id = 7076366171,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Long",
				id = RoomAudioConfig.CommonSounds.Creak3_Long,
				volume = 0.33
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound5,
				volume = 0.33,
				playbackSpeed = 0.95
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	ChristmasMap2 = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Christmas,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.24,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound2",
				id = 7076366171,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Long",
				id = RoomAudioConfig.CommonSounds.Creak3_Long,
				volume = 0.33
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound5,
				volume = 0.33,
				playbackSpeed = 0.95
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	ChristmasMapPrevious = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Christmas,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.24,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound2",
				id = 7076366171,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Long",
				id = RoomAudioConfig.CommonSounds.Creak3_Long,
				volume = 0.33
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound5,
				volume = 0.33,
				playbackSpeed = 0.95
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	SkateMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Christmas,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.24,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound2",
				id = 7076366171,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Long",
				id = RoomAudioConfig.CommonSounds.Creak3_Long,
				volume = 0.33
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound5,
				volume = 0.33,
				playbackSpeed = 0.95
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	SkateMap2 = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Christmas,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.24,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound2",
				id = 7076366171,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Long",
				id = RoomAudioConfig.CommonSounds.Creak3_Long,
				volume = 0.33
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound5,
				volume = 0.33,
				playbackSpeed = 0.95
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	Diner1 = {
		floor = 2,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Diner,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.24,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound2",
				id = 7076366171,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Long",
				id = RoomAudioConfig.CommonSounds.Creak3_Long,
				volume = 0.33
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	Diner2 = {
		floor = 2,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Diner,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.24,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound2",
				id = 7076366171,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Long",
				id = RoomAudioConfig.CommonSounds.Creak3_Long,
				volume = 0.33
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound5,
				volume = 0.33,
				playbackSpeed = 0.95
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	Greenhouse1 = {
		floor = 2,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.2
			},
			{
				name = "AmbientNoise2",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.25
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			},
			{
				name = "Scare2",
				id = RoomAudioConfig.CommonSounds.Scare2,
				volume = 0.2,
				playbackSpeed = 0.7
			},
			{
				name = "Scare3",
				id = RoomAudioConfig.CommonSounds.Scare3,
				volume = 0.2,
				playbackSpeed = 0.7
			},
			{
				name = "Scare4",
				id = RoomAudioConfig.CommonSounds.Scare4,
				volume = 0.2,
				playbackSpeed = 0.7
			},
			{
				name = "Ambient3",
				id = RoomAudioConfig.CommonSounds.Ambient3,
				volume = 0.1,
				playbackSpeed = 0.8
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	Greenhouse2 = {
		floor = 2,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.2
			},
			{
				name = "AmbientNoise2",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.25
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			},
			{
				name = "Scare2",
				id = RoomAudioConfig.CommonSounds.Scare2,
				volume = 0.2,
				playbackSpeed = 0.7
			},
			{
				name = "Scare3",
				id = RoomAudioConfig.CommonSounds.Scare3,
				volume = 0.2,
				playbackSpeed = 0.7
			},
			{
				name = "Scare4",
				id = RoomAudioConfig.CommonSounds.Scare4,
				volume = 0.2,
				playbackSpeed = 0.7
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	LibraryMap = {
		floor = 2,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.3
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.25,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Long,
				volume = 0.1,
				playbackSpeed = 0.7
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	Warehouse1 = {
		floor = 3,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Warehouse,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Buzz",
				id = RoomAudioConfig.CommonSounds.Buzz,
				volume = 0.15
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	Warehouse2 = {
		floor = 3,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Warehouse,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Hit",
				id = RoomAudioConfig.CommonSounds.Hit,
				volume = 0.15
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Buzz",
				id = RoomAudioConfig.CommonSounds.Buzz,
				volume = 0.15
			},
			{
				name = "Slam",
				id = RoomAudioConfig.CommonSounds.Slam,
				volume = 0.06,
				playbackSpeed = 0.7
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	GiftShop = {
		floor = 3,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Studio,
				volume = 0.35,
				playbackSpeed = 0.89
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.Creak3_Metal,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "ScarySound2",
				id = RoomAudioConfig.CommonSounds.ScarySound2,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.15,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.25,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Whisper,
				volume = 0.15,
				playbackSpeed = 0.5
			},
			{
				name = "Memory",
				id = RoomAudioConfig.CommonSounds.Memory,
				volume = 0.02,
				playbackSpeed = 0.8
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.Scare3,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound6,
				volume = 0.2,
				playbackSpeed = 0.33
			},
			{
				name = "ScarySound6",
				id = 252192446,
				volume = 0.06
			}
		},
		randomInterval = {
			min = 15,
			max = 35
		}
	},
	DyleMap = {
		floor = 3,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.DyleStation,
				volume = 0.8,
				playbackSpeed = 0.8
			},
			{
				name = "TrainIdle",
				id = RoomAudioConfig.CommonSounds.TrainIdle,
				volume = 0.25,
				looped = true
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.24,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound2",
				id = 7076366171,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Long",
				id = RoomAudioConfig.CommonSounds.Creak3_Long,
				volume = 0.33
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound5,
				volume = 0.33,
				playbackSpeed = 0.95
			},
			{
				name = "TrainHorn",
				id = RoomAudioConfig.CommonSounds.TrainHorn,
				volume = 0.35
			},
			{
				name = "TrainSteam",
				id = RoomAudioConfig.CommonSounds.TrainSteam,
				volume = 0.2,
				playbackSpeed = 0.6
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	AstroMap = {
		floor = 4,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Space,
				volume = 0.4
			}
		},
		randomSounds = {
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound2",
				id = 7076366171,
				volume = 0.1,
				playbackSpeed = 0.3
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound5,
				volume = 0.33,
				playbackSpeed = 0.95
			},
			{
				name = "SpaceSound",
				id = RoomAudioConfig.CommonSounds.SpaceSound,
				volume = 0.46,
				playbackSpeed = 0.6
			},
			{
				name = "Scare4",
				id = RoomAudioConfig.CommonSounds.Scare4,
				volume = 0.2,
				playbackSpeed = 0.7
			},
			{
				name = "Scare3",
				id = RoomAudioConfig.CommonSounds.Scare3,
				volume = 0.2,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Metal",
				id = RoomAudioConfig.CommonSounds.Creak3_Metal,
				volume = 0.25
			},
			{
				name = "Ambient3",
				id = RoomAudioConfig.CommonSounds.Ambient3,
				volume = 0.1,
				playbackSpeed = 0.8
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	EasterMap = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Forest,
				volume = 0.5
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.24,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Long",
				id = RoomAudioConfig.CommonSounds.Creak3_Long,
				volume = 0.33
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound5,
				volume = 0.33,
				playbackSpeed = 0.95
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	EasterMap2 = {
		floor = 1,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.Forest,
				volume = 0.5
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.15,
				playbackSpeed = 0.7
			},
			{
				name = "Scare",
				id = RoomAudioConfig.CommonSounds.Scare,
				volume = 0.08,
				playbackSpeed = 0.3
			},
			{
				name = "Creak3",
				id = RoomAudioConfig.CommonSounds.Creak3_Wood,
				volume = 0.25,
				playbackSpeed = 0.5
			},
			{
				name = "ScarySound",
				id = RoomAudioConfig.CommonSounds.ScarySound,
				volume = 0.15,
				playbackSpeed = 0.95
			},
			{
				name = "Cave",
				id = RoomAudioConfig.CommonSounds.Cave,
				volume = 0.1,
				playbackSpeed = 0.76
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.24,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.1,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient",
				id = RoomAudioConfig.CommonSounds.Ambient,
				volume = 0.2,
				playbackSpeed = 0.5
			},
			{
				name = "Ambient2",
				id = RoomAudioConfig.CommonSounds.Ambient2,
				volume = 0.3,
				playbackSpeed = 0.7
			},
			{
				name = "Creak3_Long",
				id = RoomAudioConfig.CommonSounds.Creak3_Long,
				volume = 0.33
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Short,
				volume = 0.1,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound5",
				id = RoomAudioConfig.CommonSounds.ScarySound5,
				volume = 0.33,
				playbackSpeed = 0.95
			}
		},
		randomInterval = {
			min = 12,
			max = 30
		}
	},
	BreakRoomMap = {
		floor = 0,
		ambience = {
			{
				name = "BreakRoomMusic",
				id = 122608336644878,
				volume = 0.1,
				music = true,
				effects = {
					{
						Type = "EqualizerSoundEffect",
						Properties = {
							HighGain = -50,
							LowGain = -5,
							MidGain = -25,
							Enabled = false
						},
						Tags = { "MusicMuffler" }
					}
				}
			}
		}
	},
	LockedAway = {
		floor = 0,
		ambience = {
			{
				name = "AmbientNoise",
				id = RoomAudioConfig.CommonSounds.LockedAway,
				volume = 0.5
			}
		},
		randomSounds = {
			{
				name = "BigCreak",
				id = RoomAudioConfig.CommonSounds.BigCreak,
				volume = 0.2,
				playbackSpeed = 0.7
			},
			{
				name = "ScarySound3",
				id = RoomAudioConfig.CommonSounds.ScarySound3_Breath,
				volume = 0.15,
				playbackSpeed = 0.5
			},
			{
				name = "Creak2",
				id = RoomAudioConfig.CommonSounds.Creak2,
				volume = 0.2,
				playbackSpeed = 0.21
			},
			{
				name = "ScarySound4",
				id = RoomAudioConfig.CommonSounds.ScarySound4_Long,
				volume = 0.15,
				playbackSpeed = 0.7
			}
		},
		randomInterval = {
			min = 20,
			max = 40
		}
	}
}
RoomAudioConfig.Rooms.HalloweenMap2 = RoomAudioConfig.Rooms.HalloweenMap

function RoomAudioConfig.GetRoomConfig(p)
	return RoomAudioConfig.Rooms[p]
end

function RoomAudioConfig.GetRoomsByFloor(p)
	local rooms = {}

	for k, room in pairs(RoomAudioConfig.Rooms) do
		if room.floor == p then
			rooms[k] = room
		end
	end

	return rooms
end

function RoomAudioConfig.GetCommonSoundId(p)
	return RoomAudioConfig.CommonSounds[p]
end

return RoomAudioConfig