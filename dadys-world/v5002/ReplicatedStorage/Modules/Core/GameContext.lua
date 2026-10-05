local GameContext = {
	Player = nil,
	Gui = nil,
	Character = nil,
	skillchecking = false,
	currentgenerator = nil,
	currentMinigameType = "default",
	cooldown = false,
	renderstep = nil,
	sprinton = false,
	localPlayerReady = false,
	playerReadyStates = {},
	toonCatalogPopulated = false,
	trinketCatalogPopulated = false,
	CircleSkillCheckHandler = nil,
	TreadmillTapSkillCheck = nil,
	HapticEffectsController = nil,
	CubertPlayers = nil,
	updateSkillCheckPromptText = nil,
	hideAllSkillCheckUI = nil,
	setupStats = nil,
	updateStaminaGui = nil,
	updateHealthGui = nil,
	setUpAbility = nil,
	TextMessage = nil,
	QueueTextMessage = nil,
	ErrorMessage = nil,
	ClearTextMessages = nil,
	updateTextWithDropSupport = nil,
	getCurrentlySelectedTrinket = nil,
	Update_Stats = nil,
	Update_Slots = nil,
	ensureToonCatalogPopulated = nil,
	ensureTrinketCatalogPopulated = nil,
	sprintchanged = nil,
	sprintchanged2 = nil,
	fatiguechanged = nil,
	healthchanged = nil,
	changed = nil,
	slot1changed = nil,
	slot2changed = nil,
	slot3changed = nil,
	slot4changed = nil,
	trinket1changed = nil,
	trinket2changed = nil,
	decodechanged = nil,
	tokenchanged = nil,
	ichorchanged = nil,
	playerIchorCount = nil
}

function GameContext.init(player)
	GameContext.Player = player.Player
	GameContext.Gui = player.Gui
	GameContext.Character = player.Character
end

function GameContext.setCharacter(character)
	GameContext.Character = character
end

return GameContext