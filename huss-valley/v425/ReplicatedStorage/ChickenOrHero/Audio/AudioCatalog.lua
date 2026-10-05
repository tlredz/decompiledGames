local SkinCatalog = require(script.Parent.Parent.Weapons.SkinCatalog)
local AudioCatalog = {
	ChoiceFocus = {
		Path = "04_UI/ChoiceFocus",
		MinInterval = 0.6
	},
	ChoiceFocusResolve = {
		Path = "04_UI/ChoiceFocusResolve",
		MinInterval = 0.6
	},
	GemCollect = {
		Path = "09_Collectibles/GemCollect",
		MinInterval = 0.07
	},
	LobbyMusic = {
		Path = "01_Soundtracks/Lobby",
		MinInterval = 0.08
	},
	MatchMusic = {
		Path = "01_Soundtracks/Match",
		MinInterval = 0.08
	},
	FootstepGrass = {
		Path = "02_Movement/Footsteps/Grass",
		MinInterval = 0.11
	},
	FootstepConcrete = {
		Path = "02_Movement/Footsteps/Concrete",
		MinInterval = 0.11
	},
	FootstepSand = {
		Path = "02_Movement/Footsteps/Sand",
		MinInterval = 0.11
	},
	FootstepDirt = {
		Path = "02_Movement/Footsteps/Dirt",
		MinInterval = 0.11
	},
	FootstepWood = {
		Path = "02_Movement/Footsteps/Wood",
		MinInterval = 0.11
	},
	FootstepMetal = {
		Path = "02_Movement/Footsteps/Metal",
		MinInterval = 0.11
	},
	FootstepSnow = {
		Path = "02_Movement/Footsteps/Snow",
		MinInterval = 0.11
	},
	FootstepWater = {
		Path = "02_Movement/Footsteps/Water",
		MinInterval = 0.11
	},
	MovementStart = {
		Path = "02_Movement/RunStart",
		MinInterval = 0.15
	},
	RunStop = {
		Path = "02_Movement/RunStop",
		MinInterval = 0.15
	},
	SharpTurn = {
		Path = "02_Movement/SharpTurn",
		MinInterval = 0.15
	},
	BoostStart = {
		Path = "02_Movement/BoostStart",
		MinInterval = 0.15
	},
	BoostRecovery = {
		Path = "02_Movement/BoostRecovery",
		MinInterval = 0.15
	},
	BoostReady = {
		Path = "02_Movement/BoostReady",
		MinInterval = 0.15
	},
	Jump = {
		Path = "02_Movement/Jump",
		MinInterval = 0.15
	},
	LandSoft = {
		Path = "02_Movement/LandSoft",
		MinInterval = 0.15
	},
	LandHard = {
		Path = "02_Movement/LandHard",
		MinInterval = 0.15
	},
	ClothesRustle = {
		Path = "02_Movement/ClothesRustle",
		MinInterval = 0.15
	},
	SprintWind = {
		Path = "02_Movement/SprintWind",
		MinInterval = 0.15
	},
	DiveStart = {
		Path = "03_Catching/DiveStart",
		MinInterval = 0.12
	},
	DiveLand = {
		Path = "03_Catching/DiveLand",
		MinInterval = 0.12
	},
	DiveRecover = {
		Path = "03_Catching/DiveRecover",
		MinInterval = 0.12
	},
	CatchImpact = {
		Path = "03_Catching/CatchImpact",
		MinInterval = 0.12
	},
	CatchSuccess = {
		Path = "03_Catching/CatchSuccess",
		MinInterval = 0.12
	},
	CatchReady = {
		Path = "03_Catching/CatchReady",
		MinInterval = 0.12
	},
	RecapLevelUp = {
		Path = "04_UI/MatchSummary/LevelUp",
		MinInterval = 0.5
	},
	RecapOpen = {
		Path = "04_UI/MatchSummary/Reveal",
		MinInterval = 0.3
	},
	RecapTick = {
		Path = "04_UI/MatchSummary/CountTick",
		MinInterval = 0.09
	},
	RecapComplete = {
		Path = "04_UI/MatchSummary/CountComplete",
		MinInterval = 0.3
	},
	DangerPulse = {
		Path = "07_Danger/ApproachingCatcher",
		MinInterval = 0.1
	},
	Hover = {
		Path = "04_UI/Hover",
		MinInterval = 0.09
	},
	Click = {
		Path = "04_UI/Click",
		MinInterval = 0.09
	},
	PanelOpen = {
		Path = "04_UI/PanelOpen",
		MinInterval = 0.09
	},
	PanelClose = {
		Path = "04_UI/PanelClose",
		MinInterval = 0.09
	},
	ChoiceSubmitted = {
		Path = "04_UI/ChoiceSubmitted",
		MinInterval = 0.09
	},
	Notice = {
		Path = "04_UI/Notice",
		MinInterval = 0.09
	},
	MatchCountdown = {
		Path = "05_Rounds/MatchCountdown",
		MinInterval = 0.15
	},
	CountdownTick = {
		Path = "05_Rounds/CountdownTick",
		MinInterval = 0.8
	},
	CountdownFinal = {
		Path = "05_Rounds/CountdownFinal",
		MinInterval = 0.8
	},
	RoundReady = {
		Path = "05_Rounds/RoundReady",
		MinInterval = 0.15
	},
	RunStart = {
		Path = "05_Rounds/RunStart",
		MinInterval = 0.15
	},
	HeroRunStart = {
		Path = "05_Rounds/HeroRunStart",
		MinInterval = 0.15
	},
	FinalRunStart = {
		Path = "05_Rounds/FinalRunStart",
		MinInterval = 0.15
	},
	RunEnd = {
		Path = "05_Rounds/RunEnd",
		MinInterval = 0.15
	},
	TimeWarning = {
		Path = "05_Rounds/TimeWarning",
		MinInterval = 0.8
	},
	MatchEnd = {
		Path = "05_Rounds/MatchEnd",
		MinInterval = 0.15
	},
	SpawnRefresh = {
		Path = "05_Rounds/SpawnRefresh",
		MinInterval = 0.15
	},
	LobbyReturn = {
		Path = "05_Rounds/LobbyReturn",
		MinInterval = 0.15
	},
	HeroChosen = {
		Path = "05_Rounds/HeroChosen",
		MinInterval = 0.15
	},
	ChickenChosen = {
		Path = "05_Rounds/ChickenChosen",
		MinInterval = 0.15
	},
	RoleRunner = {
		Path = "06_PlayerEvents/RoleRunner",
		MinInterval = 0.2
	},
	RoleCatcher = {
		Path = "06_PlayerEvents/RoleCatcher",
		MinInterval = 0.2
	},
	SelectedHero = {
		Path = "06_PlayerEvents/SelectedHero",
		MinInterval = 0.2
	},
	ReachedSafety = {
		Path = "06_PlayerEvents/ReachedSafety",
		MinInterval = 0.2
	},
	Caught = {
		Path = "06_PlayerEvents/Caught",
		MinInterval = 0.2
	},
	Victory = {
		Path = "06_PlayerEvents/Victory",
		MinInterval = 0.2
	},
	Defeat = {
		Path = "06_PlayerEvents/Defeat",
		MinInterval = 0.2
	},
	Respawn = {
		Path = "06_PlayerEvents/Respawn",
		MinInterval = 0.2
	},
	Death = {
		Path = "06_PlayerEvents/Death",
		MinInterval = 0.2
	}
}

for _, skin in SkinCatalog.Skins do
	for _, soundEvent in SkinCatalog.SoundEvents do
		AudioCatalog["Knife_" .. skin.SoundProfile .. "_" .. soundEvent] = {
			Path = "08_Knives/" .. skin.SoundProfile .. "/" .. soundEvent,
			MinInterval = soundEvent == "Windup" and 0.9 or 0.09
		}
	end
end

return AudioCatalog