local v = {
	casual = {
		{
			country = "NL",
			maxPlayers = 16,
			serverType = "Normal",
			friends = { "Awokein", "AMSStudios" }
		},
		{
			country = "DE",
			maxPlayers = 16,
			serverType = "Normal"
		},
		{
			country = "FR",
			maxPlayers = 16,
			serverType = "Normal"
		},
		{
			country = "UK",
			maxPlayers = 16,
			serverType = "Normal",
			friends = { "Stackyz" }
		},
		{
			country = "US",
			maxPlayers = 16,
			serverType = "Normal"
		},
		{
			country = "US",
			maxPlayers = 16,
			serverType = "Normal"
		},
		{
			country = "BR",
			maxPlayers = 16,
			serverType = "Normal"
		},
		{
			country = "BR",
			maxPlayers = 16,
			serverType = "Normal"
		},
		{
			country = "JP",
			maxPlayers = 16,
			serverType = "Normal"
		},
		{
			country = "SG",
			maxPlayers = 16,
			serverType = "Normal"
		},
		{
			country = "AU",
			maxPlayers = 16,
			serverType = "Normal"
		},
		{
			country = "ZA",
			maxPlayers = 16,
			serverType = "Normal"
		}
	},
	Pro = {
		{
			country = "DE",
			maxPlayers = 16,
			serverType = "Pro"
		},
		{
			country = "US",
			maxPlayers = 16,
			serverType = "Pro"
		},
		{
			country = "SG",
			maxPlayers = 16,
			serverType = "Pro"
		}
	},
	Voice = {
		{
			country = "UK",
			maxPlayers = 16,
			serverType = "Voice",
			friends = { "Awokein" }
		},
		{
			country = "US",
			maxPlayers = 16,
			serverType = "Voice"
		}
	},
	TradingPlaza = {
		{
			country = "NL",
			maxPlayers = 30,
			serverType = "TradingPlaza"
		},
		{
			country = "US",
			maxPlayers = 30,
			serverType = "TradingPlaza"
		},
		{
			country = "BR",
			maxPlayers = 30,
			serverType = "TradingPlaza"
		}
	},
	Fifty = {
		{
			country = "US",
			maxPlayers = 50,
			serverType = "Normal"
		},
		{
			country = "BR",
			maxPlayers = 50,
			serverType = "Normal"
		},
		{
			country = "DE",
			maxPlayers = 50,
			serverType = "Normal",
			friends = { "AMSStudios" }
		}
	},
	Duels = {
		{
			country = "UK",
			maxPlayers = 2,
			serverType = "Normal"
		},
		{
			country = "US",
			maxPlayers = 2,
			serverType = "Normal"
		},
		{
			country = "BR",
			maxPlayers = 2,
			serverType = "Normal",
			friends = { "Awokein" }
		}
	},
	Ranked = {
		{
			country = "DE",
			maxPlayers = 10,
			serverType = "Normal"
		},
		{
			country = "US",
			maxPlayers = 10,
			serverType = "Normal"
		},
		{
			country = "SG",
			maxPlayers = 10,
			serverType = "Normal"
		}
	}
}
local v2 = {
	Normal = "casual",
	Default = "casual",
	Duel = "Duels",
	FiftyPlayers = "Fifty"
}
local random = Random.new()
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function makeJobId(p: number, p2: string)
	local v4 = string.format("sim-%s-%02i-", p2, p)
	return v4 .. string.rep("0", 36 - #v4)
end

local function spawnServer(data, _: string)
	local v4 = random:NextNumber() < 0.4
	local integer = random:NextInteger(math.ceil(data.maxPlayers * 0.35), data.maxPlayers - 1)
	return {
		country = data.country,
		maxPlayers = data.maxPlayers,
		serverType = data.serverType,
		friends = data.friends,
		players = integer,
		targetPlayers = integer,
		fps = random:NextNumber(38, 60),
		memMb = random:NextInteger(1800, 7200),
		roundSeconds = v4 and 0 or random:NextInteger(1, 100),
		roundLength = random:NextInteger(60, 180),
		phase = v4 and 0 or 1,
		uptimeMin = random:NextInteger(2, 320),
		versionOffset = random:NextNumber() < 0.1 and -1 or 0,
		playerDelta = 0,
		nextTick = os.clock() + random:NextNumber(1, 3)
	}
end

local function world(p: string)
	if v3[p] then
		return v3[p]
	end

	local result = {}

	for _, v4 in v[p] or {} do
		table.insert(result, (spawnServer(v4, p)))
	end

	v3[p] = result
	return result
end

local function advance(state)
	if os.clock() < state.nextTick then
		return
	end

	state.nextTick = os.clock() + random:NextNumber(1, 3)
	local players = state.players
	local v4 = math.sign(state.targetPlayers - state.players)
	state.players = math.clamp(state.players + v4 + random:NextInteger(-1, 1), 0, state.maxPlayers)
	state.playerDelta = state.players - players

	if state.phase == 1 then
		state.roundSeconds += random:NextInteger(1, 4)

		if state.roundSeconds >= state.roundLength then
			state.roundSeconds = 0
			state.phase = 0
		end
	elseif random:NextNumber() < 0.25 and state.players >= 2 then
		state.phase = 1
		state.roundSeconds = 0
		state.roundLength = random:NextInteger(60, 180)
	end

	local v5 = 60 - state.players / state.maxPlayers * 18
	state.fps = math.clamp(state.fps + (v5 - state.fps) * 0.3 + random:NextNumber(-1.5, 1.5), 25, 60)
	state.memMb = math.clamp(state.memMb + random:NextInteger(-80, 120), 1500, 8000)
	state.uptimeMin += 1
end

local function toServerData(data, k: number, p: string)
	return {
		jobId = makeJobId(k, p),
		players = data.players,
		maxPlayers = data.maxPlayers,
		country = data.country,
		region = data.country,
		serverType = data.serverType,
		placeId = game.PlaceId,
		fps = data.fps,
		jitter = (1 - data.fps / 60) * 2 + 1,
		heartbeatMs = 1000 / math.max(data.fps, 1),
		memMb = data.memMb,
		luaHeapMb = math.floor(data.memMb * 0.4),
		instanceCount = data.players * 800 + 40000,
		avgPing = math.floor(data.players * 1.5) + 40,
		playerDelta = data.playerDelta,
		bouncePct = 4,
		errorsPerMin = 0,
		datastoreFailPct = 0,
		phase = data.phase,
		gamemode = 0,
		map = 0,
		roundSeconds = data.roundSeconds,
		uptimeMin = data.uptimeMin,
		placeVersion = math.max(1, game.PlaceVersion + data.versionOffset),
		lastUpdate = os.time(),
		flags = {
			ShuttingDown = false,
			Joinable = data.players < data.maxPlayers,
			MidRound = data.phase == 1,
			EventActive = false
		}
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tagFor(p: string?, value: string?)
	local v4 = p or value or "casual"
	local v5 = v2[v4] or v4

	if v[v5] then
		return v5
	end

	return "casual"
end

local Simulation = {}

function Simulation.getServers(p: string?, value: string?, p2: string?)
	local v4 = tagFor(p, value) -- equivalent call inferred; original call site unknown
	local v5 = world(v4)
	local result = {}

	for k, v6 in v5 do
		advance(v6)
		local v7 = toServerData(v6, k, v4)

		if p2 and k <= 2 then
			v7.country = p2
			v7.region = p2
			v7.fps = 60
			v7.players = math.max(v7.players, (math.floor(v7.maxPlayers * 0.6)))
			v7.flags.Joinable = v7.players < v7.maxPlayers
		end

		table.insert(result, v7)
	end

	return result
end

function Simulation.getFriends()
	local friends = {}

	for k, v4 in v do
		for k2, v5 in v4 do
			if v5.friends then
				friends[makeJobId(k2, k)] = v5.friends
			end
		end
	end

	return friends
end

function Simulation.describeJoin(p: string, items)
	for _, item in items do
		if item.jobId == p then
			return (`would teleport to {item.country} {item.players}/{item.maxPlayers} at {math.round(item.fps)} fps`)
		end
	end

	return (`would teleport to {p}`)
end

return Simulation