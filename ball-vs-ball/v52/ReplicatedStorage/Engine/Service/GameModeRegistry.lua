local GameModeRegistry = {}
local seats = {
	{
		seatName = "座位1",
		slotId = "Blue",
		team = "Blue",
		teamIndex = 1,
		lightName = "座位1灯",
		panelName = "玩家1"
	},
	{
		seatName = "座位2",
		slotId = "Yellow",
		team = "Yellow",
		teamIndex = 1,
		lightName = "座位2灯",
		panelName = "玩家2"
	}
}
local v2 = {
	Duel = {
		id = "Duel",
		defaultHp = 3,
		reselectBallEachRound = false,
		raceCnId = "极速模式",
		teamSize = 1,
		seats = seats
	},
	RPS = {
		id = "RPS",
		defaultHp = 3,
		reselectBallEachRound = true,
		raceCnId = "剪刀石头布",
		teamSize = 1,
		seats = seats
	},
	TwoVTwo = {
		id = "TwoVTwo",
		defaultHp = 3,
		reselectBallEachRound = true,
		raceCnId = "2v2模式",
		teamSize = 2,
		boardCnId = "2v2棋盘",
		seats = {
			{
				seatName = "红队座位1",
				slotId = "Blue1",
				team = "Blue",
				teamIndex = 1,
				boardMarkerName = "红队位置1",
				panelName = "红方头像1"
			},
			{
				seatName = "红队座位2",
				slotId = "Blue2",
				team = "Blue",
				teamIndex = 2,
				boardMarkerName = "红队位置2",
				panelName = "红方头像2"
			},
			{
				seatName = "蓝队座位1",
				slotId = "Yellow1",
				team = "Yellow",
				teamIndex = 1,
				boardMarkerName = "蓝队位置1",
				panelName = "蓝方头像1"
			},
			{
				seatName = "蓝队座位2",
				slotId = "Yellow2",
				team = "Yellow",
				teamIndex = 2,
				boardMarkerName = "蓝队位置2",
				panelName = "蓝方头像2"
			}
		}
	}
}

function GameModeRegistry.get(value: string?)
	if typeof(value) == "string" and v2[value] then
		return v2[value]
	end

	return v2.Duel
end

function GameModeRegistry.getForTable(instance)
	local gameMode = instance:GetAttribute("GameMode")
	local get = GameModeRegistry.get

	if typeof(gameMode) ~= "string" then
		gameMode = nil
	end

	return get(gameMode)
end

function GameModeRegistry.isTeamMode(p)
	return p.teamSize > 1
end

return GameModeRegistry