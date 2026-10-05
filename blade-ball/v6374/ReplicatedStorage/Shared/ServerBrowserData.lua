local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local _ = {
	players = 0,
	maxPlayers = 1,
	country = 2,
	serverType = 4,
	fps = 5,
	jitter = 6,
	flags = 7,
	playerDelta = 8,
	bouncePct = 9,
	errorsPerMin = 10,
	datastoreFailPct = 11,
	phase = 12,
	gamemode = 13,
	memMb = 14,
	luaHeapMb = 16,
	avgPing = 18,
	uptimeMin = 20,
	roundSeconds = 22,
	instanceCount = 24,
	placeVersion = 28,
	lastUpdate = 32,
	placeId = 36,
	regionLen = 44,
	region = 45
}
local _ = {
	ShuttingDown = 1,
	Joinable = 2,
	MidRound = 4,
	EventActive = 8
}
local v = {}
local ServerBrowserData = {
	ServersToShow = 30,
	ServersPerContinent = 12,
	JobIdSize = 36,
	HeaderSize = 45,
	StaleAfterSeconds = 150,
	Regions = {
		US = "USA",
		CA = "Canada",
		MX = "Mexico",
		BR = "Brazil",
		CL = "Chile",
		AR = "Argentina",
		UK = "United Kingdom",
		GB = "United Kingdom",
		FR = "France",
		DE = "Germany",
		NL = "Netherlands",
		PL = "Poland",
		IT = "Italy",
		ES = "Spain",
		SE = "Sweden",
		TR = "Turkey",
		SG = "Singapore",
		HK = "Hong Kong",
		JP = "Japan",
		KR = "South Korea",
		TW = "Taiwan",
		IN = "India",
		AE = "United Arab Emirates",
		AU = "Australia",
		NZ = "New Zealand",
		ZA = "South Africa"
	},
	ServerTypes = {
		"Normal",
		"Pro",
		"Voice",
		"TradingPlaza",
		"ProTradingPlaza",
		"Fifty",
		"Duel",
		"Ranked",
		"Mobile"
	},
	Continents = {
		NA = {
			DisplayName = "North America",
			Countries = { "US", "CA", "MX" },
			LayoutOrder = 1
		},
		SA = {
			DisplayName = "South America",
			Countries = { "BR", "CL", "AR" },
			LayoutOrder = 2
		},
		EU = {
			DisplayName = "Europe",
			Countries = {
				"UK",
				"GB",
				"FR",
				"DE",
				"NL",
				"PL",
				"IT",
				"ES",
				"SE",
				"TR"
			},
			LayoutOrder = 3
		},
		AS = {
			DisplayName = "Asia",
			Countries = {
				"SG",
				"HK",
				"JP",
				"KR",
				"TW",
				"IN",
				"AE"
			},
			LayoutOrder = 4
		},
		OC = {
			DisplayName = "Oceania",
			Countries = { "AU", "NZ" },
			LayoutOrder = 5
		},
		AF = {
			DisplayName = "Africa",
			Countries = { "ZA" },
			LayoutOrder = 6
		}
	}
}

for k, v2 in {
	NA = {
		"US",
		"CA",
		"MX",
		"GL",
		"PM",
		"BM",
		"BZ",
		"CR",
		"SV",
		"GT",
		"HN",
		"NI",
		"PA",
		"AI",
		"AG",
		"AW",
		"BS",
		"BB",
		"BQ",
		"VG",
		"KY",
		"CU",
		"CW",
		"DM",
		"DO",
		"GD",
		"GP",
		"HT",
		"JM",
		"MQ",
		"MS",
		"PR",
		"BL",
		"KN",
		"LC",
		"MF",
		"SX",
		"TT",
		"TC",
		"VC",
		"VI"
	},
	SA = {
		"AR",
		"BO",
		"BR",
		"CL",
		"CO",
		"EC",
		"FK",
		"GF",
		"GY",
		"PE",
		"PY",
		"SR",
		"UY",
		"VE"
	},
	EU = {
		"AX",
		"AL",
		"AD",
		"AT",
		"BY",
		"BE",
		"BA",
		"BG",
		"HR",
		"CY",
		"CZ",
		"DK",
		"EE",
		"FO",
		"FI",
		"FR",
		"DE",
		"GI",
		"GR",
		"GG",
		"VA",
		"HU",
		"IS",
		"IE",
		"IM",
		"IT",
		"JE",
		"LV",
		"LI",
		"LT",
		"LU",
		"MK",
		"MT",
		"MD",
		"MC",
		"ME",
		"NL",
		"NO",
		"PL",
		"PT",
		"RO",
		"RS",
		"RU",
		"SM",
		"SK",
		"SI",
		"ES",
		"SJ",
		"SE",
		"CH",
		"TR",
		"UA",
		"GB",
		"UK"
	},
	AS = {
		"AF",
		"AM",
		"AZ",
		"BH",
		"BD",
		"BT",
		"IO",
		"BN",
		"KH",
		"CN",
		"CX",
		"CC",
		"GE",
		"HK",
		"IN",
		"ID",
		"IR",
		"IQ",
		"IL",
		"JP",
		"JO",
		"KZ",
		"KP",
		"KR",
		"KW",
		"KG",
		"LA",
		"LB",
		"MO",
		"MY",
		"MV",
		"MN",
		"MM",
		"NP",
		"OM",
		"PK",
		"PS",
		"PH",
		"QA",
		"SA",
		"SG",
		"LK",
		"SY",
		"TW",
		"TJ",
		"TH",
		"TL",
		"TM",
		"AE",
		"UZ",
		"VN",
		"YE"
	},
	OC = {
		"AS",
		"AU",
		"CK",
		"FJ",
		"PF",
		"GU",
		"KI",
		"MH",
		"FM",
		"NR",
		"NC",
		"NZ",
		"NU",
		"NF",
		"MP",
		"PW",
		"PG",
		"PN",
		"WS",
		"SB",
		"TK",
		"TO",
		"TV",
		"UM",
		"VU",
		"WF"
	},
	AF = {
		"DZ",
		"AO",
		"BJ",
		"BW",
		"BF",
		"BI",
		"CM",
		"CV",
		"CF",
		"TD",
		"KM",
		"CG",
		"CD",
		"CI",
		"DJ",
		"EG",
		"GQ",
		"ER",
		"ET",
		"GA",
		"GM",
		"GH",
		"GN",
		"GW",
		"KE",
		"LS",
		"LR",
		"LY",
		"MG",
		"MW",
		"ML",
		"MR",
		"MU",
		"YT",
		"MA",
		"MZ",
		"NA",
		"NE",
		"NG",
		"RE",
		"RW",
		"SH",
		"ST",
		"SN",
		"SC",
		"SL",
		"SO",
		"ZA",
		"SS",
		"SD",
		"SZ",
		"TZ",
		"TG",
		"TN",
		"UG",
		"EH",
		"ZM",
		"ZW"
	}
} do
	for _, v3 in v2 do
		v[v3] = k
	end
end

for k, continent in ServerBrowserData.Continents do
	for _, country in continent.Countries do
		v[country] = k
	end
end

function ServerBrowserData.getContinent(p: string)
	return v[p]
end

function ServerBrowserData.isLocated(p: string)
	return ServerBrowserData.getContinent(p) ~= nil
end

function ServerBrowserData.getDisplayName(p: string)
	return ServerBrowserData.Regions[p] or p
end

ServerBrowserData.Gamemodes = { "FFA", "TeamVTeam", "MysteryBall" }
local v2 = {}

for k, gamemode in ServerBrowserData.Gamemodes do
	v2[gamemode] = k
end

function ServerBrowserData.getGamemodeIndex(p: string)
	return v2[p] or 0
end

local v3 = {}
local v4 = {}

for k in require3(script.Parent.MapData) do
	table.insert(v3, k)
end

table.sort(v3)

for k, v5 in v3 do
	v4[v5] = k
end

function ServerBrowserData.getMapIndex(p: string)
	return v4[p] or 0
end

function ServerBrowserData.getMapName(p: number)
	return v3[p]
end

function ServerBrowserData.getGamemodeName(p: number)
	return ServerBrowserData.Gamemodes[p]
end

local v5 = {
	NA = {
		NA = 45,
		SA = 120,
		EU = 105,
		AS = 180,
		OC = 170,
		AF = 220
	},
	SA = {
		NA = 120,
		SA = 45,
		EU = 190,
		AS = 300,
		OC = 280,
		AF = 320
	},
	EU = {
		NA = 105,
		SA = 190,
		EU = 40,
		AS = 160,
		OC = 270,
		AF = 150
	},
	AS = {
		NA = 180,
		SA = 300,
		EU = 160,
		AS = 60,
		OC = 130,
		AF = 240
	},
	OC = {
		NA = 170,
		SA = 280,
		EU = 270,
		AS = 130,
		OC = 40,
		AF = 330
	},
	AF = {
		NA = 220,
		SA = 320,
		EU = 150,
		AS = 240,
		OC = 330,
		AF = 60
	}
}

function ServerBrowserData.getContinentDistance(p: string, p2: string)
	local v6 = v5[p]

	if v6 and v6[p2] then
		return v6[p2]
	end

	return 150
end

function ServerBrowserData.getPropagation(p: string, p2: string)
	if p == p2 then
		return 20
	end

	local continent = ServerBrowserData.getContinent(p)
	local continent2 = ServerBrowserData.getContinent(p2)

	if continent and continent2 then
		return v5[continent][continent2]
	end

	return 150
end

function ServerBrowserData.getEstimatedPing(p: number, p2: string, p3: string, p4: string)
	return math.max(0, p - ServerBrowserData.getPropagation(p2, p3)) + ServerBrowserData.getPropagation(p2, p4)
end

function ServerBrowserData.packFlags(data)
	local total = 0

	if data.ShuttingDown then
		total += 1
	end

	if data.Joinable then
		total += 2
	end

	if data.MidRound then
		total += 4
	end

	if data.EventActive then
		total += 8
	end

	return total
end

function ServerBrowserData.unpackFlags(p: number)
	return {
		ShuttingDown = bit32.btest(p, 1),
		Joinable = bit32.btest(p, 2),
		MidRound = bit32.btest(p, 4),
		EventActive = bit32.btest(p, 8)
	}
end

local function clampToU8(value: number)
	return (math.clamp(math.floor(value or 0), 0, 255))
end

local function clampToU16(value: number)
	return (math.clamp(math.floor(value or 0), 0, 65535))
end

local function clampToU32(value: number)
	return (math.clamp(math.floor(value or 0), 0, 4294967295))
end

function ServerBrowserData.writeServerBuffer(data)
	local v6 = string.sub(data.country .. "??", 1, 2)
	local region = data.region
	local v7 = math.min(#region, 255)
	local buf = buffer.create(45 + v7 + 1)
	buffer.writeu8(buf, 0, (math.clamp(math.floor(data.players or 0), 0, 255)))
	buffer.writeu8(buf, 1, (math.clamp(math.floor(data.maxPlayers or 0), 0, 255)))
	buffer.writestring(buf, 2, v6, 2)
	buffer.writeu8(
		buf,
		4,
		(math.clamp(
			math.floor(not data.serverType and 1 or table.find(ServerBrowserData.ServerTypes, data.serverType) or 1 or 0),
			0,
			255
		))
	)
	buffer.writeu8(buf, 5, (math.clamp(math.floor(data.fps * 4 or 0), 0, 255)))
	buffer.writeu8(buf, 6, (math.clamp(math.floor(data.jitter * 32 or 0), 0, 255)))
	buffer.writeu8(buf, 7, (ServerBrowserData.packFlags(data.flags)))
	buffer.writei8(buf, 8, (math.clamp(math.floor(data.playerDelta), -128, 127)))
	buffer.writeu8(buf, 9, (math.clamp(math.floor(data.bouncePct or 0), 0, 255)))
	buffer.writeu8(buf, 10, (math.clamp(math.floor(data.errorsPerMin or 0), 0, 255)))
	buffer.writeu8(buf, 11, (math.clamp(math.floor(data.datastoreFailPct or 0), 0, 255)))
	buffer.writeu8(buf, 12, (math.clamp(math.floor(data.phase or 0), 0, 255)))
	buffer.writeu8(buf, 13, (math.clamp(math.floor(data.gamemode or 0), 0, 255)))
	buffer.writeu16(buf, 14, (math.clamp(math.floor(data.memMb or 0), 0, 65535)))
	buffer.writeu16(buf, 16, (math.clamp(math.floor(data.luaHeapMb or 0), 0, 65535)))
	buffer.writeu16(buf, 18, (math.clamp(math.floor(data.avgPing or 0), 0, 65535)))
	buffer.writeu16(buf, 20, (math.clamp(math.floor(data.uptimeMin or 0), 0, 65535)))
	buffer.writeu16(buf, 22, (math.clamp(math.floor(data.roundSeconds or 0), 0, 65535)))
	buffer.writeu32(buf, 24, (math.clamp(math.floor(data.instanceCount or 0), 0, 4294967295)))
	buffer.writeu32(buf, 28, (math.clamp(math.floor(data.placeVersion or 0), 0, 4294967295)))
	buffer.writeu32(buf, 32, (math.clamp(math.floor(data.lastUpdate or 0), 0, 4294967295)))
	buffer.writef64(buf, 36, data.placeId)
	buffer.writeu8(buf, 44, v7)
	buffer.writestring(buf, 45, region, v7)
	buffer.writeu8(buf, 45 + v7, (math.clamp(math.floor(data.map or 0), 0, 255)))
	return buf
end

function ServerBrowserData.readServerBuffer(buf: buffer)
	if buffer.len(buf) < 45 then
		return nil
	end

	local v6 = buffer.readu8(buf, 44)

	if buffer.len(buf) < 45 + v6 then
		return nil
	end

	local v7 = 45 + v6
	return {
		map = not (v7 < buffer.len(buf)) and 0 or buffer.readu8(buf, v7),
		players = buffer.readu8(buf, 0),
		maxPlayers = buffer.readu8(buf, 1),
		country = buffer.readstring(buf, 2, 2),
		region = buffer.readstring(buf, 45, v6),
		serverType = ServerBrowserData.ServerTypes[buffer.readu8(buf, 4)],
		placeId = buffer.readf64(buf, 36),
		fps = buffer.readu8(buf, 5) / 4,
		jitter = buffer.readu8(buf, 6) / 32,
		heartbeatMs = 0,
		memMb = buffer.readu16(buf, 14),
		luaHeapMb = buffer.readu16(buf, 16),
		instanceCount = buffer.readu32(buf, 24),
		avgPing = buffer.readu16(buf, 18),
		playerDelta = buffer.readi8(buf, 8),
		bouncePct = buffer.readu8(buf, 9),
		errorsPerMin = buffer.readu8(buf, 10),
		datastoreFailPct = buffer.readu8(buf, 11),
		phase = buffer.readu8(buf, 12),
		gamemode = buffer.readu8(buf, 13),
		roundSeconds = buffer.readu16(buf, 22),
		uptimeMin = buffer.readu16(buf, 20),
		placeVersion = buffer.readu32(buf, 28),
		lastUpdate = buffer.readu32(buf, 32),
		flags = ServerBrowserData.unpackFlags((buffer.readu8(buf, 7)))
	}
end

function ServerBrowserData.readReplicationBuffer(buf: buffer)
	local jobIdSize = ServerBrowserData.JobIdSize

	if buffer.len(buf) <= jobIdSize then
		return nil
	end

	local jobId = buffer.readstring(buf, 0, ServerBrowserData.JobIdSize)
	local buf2 = buffer.create(buffer.len(buf) - jobIdSize)
	buffer.copy(buf2, 0, buf, jobIdSize)
	local serverBuffer = ServerBrowserData.readServerBuffer(buf2)

	if serverBuffer then
		serverBuffer.jobId = jobId
	end

	return serverBuffer
end

function ServerBrowserData.getCountryFromBuffer(buf: buffer)
	return buffer.readstring(buf, 2, 2)
end

function ServerBrowserData.getServersDataFromBuffers(list)
	local result = table.create(#list)

	for _, v6 in list do
		local serverBuffer = ServerBrowserData.readServerBuffer(v6)

		if serverBuffer then
			table.insert(result, serverBuffer)
		end
	end

	return result
end

return ServerBrowserData