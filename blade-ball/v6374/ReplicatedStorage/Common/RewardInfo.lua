local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Common.BoostsInfo)
local v2 = require3(ReplicatedStorage2.Shared.EmoteIds)
local v3 = require3(script.Parent.Utils)
local v4 = require3(ReplicatedStorage2.ClientGameModules.TextUtility)
local v5 = require3(ReplicatedStorage2.Shared.InfiniteBattlepass.InfiniteBattlepassData.External)
local v6 = RunService:IsStudio() and RunService:IsServer() and true
local v7 = {
	Small = "rbxassetid://14713797174",
	Med = "rbxassetid://14713794582",
	Big = "rbxassetid://14713779371",
	Huge = "rbxassetid://14713785287",
	Massive = "rbxassetid://14713787523",
	Biggest = "rbxassetid://17268587386",
	BiggestPlus = "rbxassetid://17268587949"
}
local v8 = {
	Small = "rbxassetid://15695607674",
	Big = "rbxassetid://15739687675"
}

local function createCrateKeyReward(explosionCrateId: string, value: number, explosionCrate: string?, p: string?)
	return {
		DisplayName = `{not (value > 1) and "" or `x{value} ` or ""}` .. (explosionCrate or `{explosionCrateId} Crate`),
		Icon = p or v3.Icons:GetIcon(explosionCrateId) or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "CrateKey",
		Value = explosionCrateId,
		Amount = value or 1
	}
end

local v9 = {
	Default = "rbxassetid://75081821862618",
	Arachnic = "rbxassetid://75081821862618",
	Arachnic10 = "rbxassetid://78242332513296",
	Arachnic50 = "rbxassetid://90961812987716",
	Arachnic250 = "rbxassetid://130583449334615",
	New = "rbxassetid://16100521434",
	New50 = "rbxassetid://16100521042",
	Reindeer = "rbxassetid://80173688296546",
	Heart = "rbxassetid://120884704380246",
	Heart10 = "rbxassetid://95297260551619",
	Heart50 = "rbxassetid://77500706452831",
	Heart250 = "rbxassetid://99972188838496",
	Mech = "rbxassetid://95482578481973",
	Mech10 = "rbxassetid://71045735940099",
	Mech50 = "rbxassetid://95320088863843",
	Mech250 = "rbxassetid://94085071621996",
	Easter = "rbxassetid://73649099306797",
	Easter10 = "rbxassetid://137613361246238",
	Easter50 = "rbxassetid://117585170625715",
	Easter250 = "rbxassetid://105284045374918",
	Ronin = "rbxassetid://114973899532380",
	Ronin10 = "rbxassetid://98439456523022",
	Ronin50 = "rbxassetid://135799424159267",
	Ronin250 = "rbxassetid://87283823544907",
	Pixel = "rbxassetid://123079268217589",
	Pixel10 = "rbxassetid://105173961409354",
	Pixel50 = "rbxassetid://128855775298364",
	Pixel250 = "rbxassetid://81577953665434",
	Ninja = "rbxassetid://79311249434487",
	Ninja10 = "rbxassetid://109553006890199",
	Ninja50 = "rbxassetid://122805281053328",
	Ninja250 = "rbxassetid://74059074963109",
	Mermaid = "rbxassetid://138314861362794",
	Mermaid10 = "rbxassetid://94025420271407",
	Mermaid50 = "rbxassetid://118321779233318",
	Mermaid250 = "rbxassetid://82916621480579",
	Halloween = "rbxassetid://122860952542117",
	Halloween10 = "rbxassetid://90074703033354",
	Halloween50 = "rbxassetid://114079128654382",
	Halloween250 = "rbxassetid://101208994181623",
	Blizzard = "rbxassetid://119775735694245",
	Blizzard10 = "rbxassetid://105738698256009",
	Blizzard50 = "rbxassetid://101986712518148",
	Blizzard250 = "rbxassetid://85726675883491",
	Christmas = "rbxassetid://81824211907466",
	Christmas10 = "rbxassetid://97472002333792",
	Christmas50 = "rbxassetid://106767635399769",
	Christmas250 = "rbxassetid://92042585467291",
	Blackhole = "rbxassetid://104422371381618",
	Blackhole10 = "rbxassetid://92684677178009",
	Blackhole50 = "rbxassetid://128471076601323",
	Blackhole250 = "rbxassetid://121180638831768",
	Mythology = "rbxassetid://118241425561509",
	Mythology10 = "rbxassetid://139461726383380",
	Mythology50 = "rbxassetid://79876864965296",
	Mythology250 = "rbxassetid://87628689597514",
	Sheriff = "rbxassetid://130630033225102",
	Sheriff10 = "rbxassetid://116774507007035",
	Sheriff50 = "rbxassetid://130347542925281",
	Sheriff250 = "rbxassetid://130477513948907",
	Soccer = "rbxassetid://114520714577919",
	Soccer10 = "rbxassetid://110517488711787",
	Soccer50 = "rbxassetid://82479181641282",
	Soccer250 = "rbxassetid://83177531754796",
	Kraken = "rbxassetid://105847627469908",
	Kraken10 = "rbxassetid://107073298864072",
	Kraken50 = "rbxassetid://71507470035731",
	Kraken250 = "rbxassetid://137637564995963",
	Kawaii = "rbxassetid://140577413650708",
	Kawaii10 = "rbxassetid://87230818976548",
	Kawaii50 = "rbxassetid://71165181053439",
	Kawaii250 = "rbxassetid://124613146669984"
}
local RewardInfo = {}

function RewardInfo.createCoinsReward(p: number, p2: string)
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} Coins`,
		Icon = v7[p2] or "rbxassetid://14713797174",
		Type = "Coins",
		Value = p
	}
end

function RewardInfo.createSwordReward(displayName: string)
	local swordIcon = v3.Icons:GetSwordIcon(displayName)

	if v6 and not swordIcon then
		warn(
			`[!] Sword "{displayName}" does not exist, but it's being used in RewardInfo.createSwordReward()!`,
			debug.traceback(nil, 2)
		)
	end

	return {
		DisplayName = displayName,
		Icon = swordIcon or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "Sword",
		Value = displayName
	}
end

function RewardInfo.createBoostReward(p, p2: number)
	return {
		DisplayName = `{v.Boosts[p].DisplayName} - {p2} Minutes`,
		Icon = v.Boosts[p].Icon or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "Boost",
		Value = p,
		Duration = p2 * 60
	}
end

function RewardInfo.createEmoteReward(value: string)
	local v10, v11

	if string.match(value, "^Emote(%d+)$") then
		v10 = v2.IdsToEmotes[value]
		v11 = value
	else
		v11 = v2.EmotesToIds[value]
		v10 = value
	end

	if v6 and not v11 or not v10 then
		task.spawn(error, (`Emote "{value}" wasn't found, returning placeholder\n{debug.traceback()}`))
		return {
			DisplayName = "PLACEHOLDER [WORK IN PROGRESS]",
			Icon = v3.Icons:GetIcon("DEFAULT_MISSING"),
			Type = "Emote",
			Value = "PLACEHOLDER"
		}
	end

	local emoteIcon = v11 and v3.Icons:GetEmoteIcon(v11)

	if v6 and not emoteIcon then
		warn(
			`[!] Emote "{value}" does not exist, but it's being used in RewardInfo.createEmoteReward()!`,
			debug.traceback(nil, 2)
		)
	end

	return {
		DisplayName = string.gsub(`{v10} Emote`, "Emote Emote", "Emote"),
		Icon = emoteIcon or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "Emote",
		Value = v11
	}
end

function RewardInfo.createExplosionReward(p: string)
	local explosionIcon = v3.Icons:GetExplosionIcon(p)

	if v6 and not explosionIcon then
		warn(
			`[!] Explosion "{p}" does not exist, but it's being used in RewardInfo.createExplosionReward()!`,
			debug.traceback(nil, 2)
		)
	end

	return {
		DisplayName = `{p} Explosion`,
		Icon = explosionIcon or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "Explosion",
		Value = p
	}
end

function RewardInfo.createCrateReward(p: string, crateType: string, p3: string?, p4: string?)
	return {
		DisplayName = p3 or `{p} Crate`,
		Icon = p4 or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "Crate",
		Value = p,
		CrateType = crateType
	}
end

RewardInfo.createCrateKeyReward = createCrateKeyReward

function RewardInfo.createBattlepassExplosionCrateReward(p: number)
	return (createCrateKeyReward(v5.ExplosionCrateId, p, v5.ExplosionCrate))
end

function RewardInfo.createWheelSpinReward(value: number?)
	local v10 = value or 1
	return {
		DisplayName = `x{v10} Wheel Spin`,
		Icon = "rbxassetid://15051770001",
		Type = "WheelSpin",
		Value = v10
	}
end

function RewardInfo.createAbilityFreeTrialReward(p: string, duration)
	return {
		DisplayName = `{p} Trial ({v3.ValueConvertor:FormatShortTime(duration)})`,
		Icon = ReplicatedStorage2.Misc.DataAbilities[p]:GetAttribute("Icon") or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "AbilityFreeTrial",
		Value = p,
		Duration = duration
	}
end

function RewardInfo.createSciFiSpinReward(p: number)
	return {
		DisplayName = `x{p} Sci-Fi Spin`,
		Icon = "rbxassetid://15455896861",
		Type = "SciFiSpin",
		Value = p
	}
end

function RewardInfo.createNebulaSpinReward(p: number)
	return {
		DisplayName = `x{p} Nebula Spin`,
		Icon = "rbxassetid://16588091872",
		Type = "SciFiSpin",
		Value = p
	}
end

function RewardInfo.createSeasonPassCurrencyReward(p: number)
	return {
		DisplayName = `{p} {v5.Currency.Name}`,
		Icon = v5.Currency.Icon or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "SeasonPassCurrency",
		Value = p
	}
end

function RewardInfo.createLegoBricksReward(p: number, p2: string?)
	return {
		DisplayName = `{p} LEGO Brick{p > 1 and "s" or ""}`,
		Icon = p2 or v3.Icons:GetIcon("LegoBrick"),
		Type = "LegoBrick",
		Value = p
	}
end

function RewardInfo.createGachaSpinsReward(p: number, p2: string?)
	local v10 = p2 or v5.Gacha
	local match = v10:match("^%w+")
	local icon = v9[`{match}{p}`] or p >= 50 and v9[`{match}50`] or v9[match] or "rbxassetid://75081821862618"
	return {
		DisplayName = `x{p} {v10}`,
		Icon = icon,
		Type = "GachaSpins",
		Value = p
	}
end

function RewardInfo.createChristmasSpinsReward(p: number, p2: string)
	return {
		DisplayName = `x{p} {p2}`,
		Icon = "rbxassetid://15517349738",
		Type = "ChristmasSpins",
		Value = p
	}
end

function RewardInfo.createNewYearSpinsReward(p: number, p2: string)
	return {
		DisplayName = `x{p} {p2}`,
		Icon = "rbxassetid://15785934484",
		Type = "NewYearSpins",
		Value = p
	}
end

function RewardInfo.createBrazilSpinsReward(p: number, p2: string)
	return {
		DisplayName = `x{p} {p2}`,
		Icon = "rbxassetid://15569859909",
		Type = "BrazilSpins",
		Value = p
	}
end

function RewardInfo.createSocksCurrencyReward(p: number, p2: string)
	return {
		DisplayName = `{p} Socks`,
		Icon = v8[p2] or "rbxassetid://15695607674",
		Type = "SockCurrency",
		Value = p
	}
end

function RewardInfo.createCookiesCurrencyReward(p: number)
	return {
		DisplayName = `{p} Cookies`,
		Icon = "rbxassetid://15714926698",
		Type = "SockCurrency",
		Value = p
	}
end

function RewardInfo.createTournamentTicketReward(p: number)
	return {
		DisplayName = `{p} Tournament Tickets`,
		Icon = "rbxassetid://16455722863",
		Type = "TournamentTicket",
		Value = p
	}
end

function RewardInfo.createTournamentTrophyReward(p: number)
	return {
		DisplayName = `{p} Tournament Trophies`,
		Icon = "rbxassetid://16498847112",
		Type = "TournamentTrophy",
		Value = p
	}
end

function RewardInfo.createBattlepassTierSkipReward(p: number)
	return {
		DisplayName = `+{p} Tier Skip{p > 1 and "s" or ""}`,
		Icon = v3.Icons:GetIcon("BattlepassTierSkip"),
		Type = "BattlepassTierSkip",
		Value = p
	}
end

function RewardInfo.createBattlepassSelectionCrateReward(p: number, crateType: string)
	local v10 = crateType == "Premium"
	local v11 = {
		DisplayName = `+{p} {v10 and "Premium" or ""} Selection Crate`,
		Icon = 0,
		Type = "BattlepassSelectionCrate",
		Value = 0,
		CrateType = 0
	}
	local icon

	if v10 then
		icon = v3.Icons:GetIcon("BattlepassPremiumSelectionCrate")
	else
		icon = v3.Icons:GetIcon("BattlepassSelectionCrate")
	end

	v11.Icon = icon
	v11.Value = p
	v11.CrateType = crateType
	return v11
end

function RewardInfo.createLTMTicketReward(p: number, value: string?)
	return {
		DisplayName = `{p} {value or "Tickets"}`,
		Icon = "rbxassetid://16822236592",
		Type = "LTMTicket",
		Value = p
	}
end

function RewardInfo.createReturnCoinsReward(p: number)
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} Return Coins`,
		Icon = "rbxassetid://17286763390",
		Type = "ReturnCoins",
		Value = p
	}
end

function RewardInfo.createDungeonRunesReward(p: number)
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} Runes`,
		Icon = "rbxassetid://17294426866",
		Type = "DungeonRunes",
		Value = p
	}
end

function RewardInfo.createDungeonXPReward(p: number)
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} XP`,
		Icon = "rbxassetid://17302672193",
		Type = "DungeonXP",
		Value = p
	}
end

function RewardInfo.createDungeonIngredientReward(displayName: string, _: string, p2: string?)
	return {
		DisplayName = displayName,
		Icon = p2 or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "DungeonIngredient",
		Value = displayName
	}
end

function RewardInfo.createBunnyCurrencyReward(p: number)
	return {
		DisplayName = `{p} Bunny Coins`,
		Icon = "rbxassetid://16928881024",
		Type = "BunnyCoins",
		Value = p
	}
end

function RewardInfo.createEasterSwordCrate(p: number)
	return {
		DisplayName = `{p} Easter Sword Crate{p > 1 and "s" or ""}`,
		Icon = "rbxassetid://16930407838",
		Type = "EasterSwordCrate",
		Value = p
	}
end

function RewardInfo.createMerchantCrate(p: string)
	return {
		DisplayName = `{p == "Robux" and "Pumpkin King" or "Spiderweb"} Crate`,
		Icon = p == "Robux" and "rbxassetid://131340000492997" or "rbxassetid://124841776158070",
		Type = "MerchantCrate",
		Value = p
	}
end

function RewardInfo.createEasterWheelSpinsReward(p: number)
	return {
		DisplayName = `x{p} Easter Spins`,
		Icon = "rbxassetid://16901784772",
		Type = "EasterWheelSpins",
		Value = p
	}
end

function RewardInfo.createSummerWheelSpinsReward(p: number)
	return {
		DisplayName = `x{p} Summer Spins`,
		Icon = "rbxassetid://18161636925",
		Type = "SummerWheelSpins",
		Value = p
	}
end

function RewardInfo.createSynthWheelSpinsReward(p: number)
	return {
		DisplayName = `x{p} Synth Spins`,
		Icon = "rbxassetid://18679469160",
		Type = "SynthWheelSpins",
		Value = p
	}
end

function RewardInfo.createCyborgWheelSpinsReward(p: number)
	return {
		DisplayName = `x{p} Cyborg Spins`,
		Icon = "rbxassetid://133614300387881",
		Type = "CyborgWheelSpins",
		Value = p
	}
end

function RewardInfo.createHourlyWheelSpinsReward(p: number, p2: string)
	return {
		DisplayName = `x{p} {p2} Spins`,
		Icon = v3.Icons:GetIcon((`HourlyWheelSpin_{p2}`)),
		Type = "HourlyWheelSpins",
		Value = p
	}
end

function RewardInfo.createRabbitTokenReward(p: number)
	return {
		DisplayName = `{p} Rabbit Token{p > 1 and "s" or ""}`,
		Icon = "rbxassetid://16932049524",
		Type = "RabbitToken",
		Value = p
	}
end

function RewardInfo.createEasterGachaSpinReward(p: number)
	return {
		DisplayName = `x{p} Easter Eggs`,
		Icon = "rbxassetid://16931624135",
		Type = "EasterGachaSpins",
		Value = p
	}
end

function RewardInfo.createFinisherReward(p: string, p2: string?)
	local v10 = p2 or v3.Icons:GetFinisherIcon(p)

	if v6 and not v10 then
		warn(
			`[!] Finisher "{p}" does not exist, but it's being used in RewardInfo.createFinisherReward()!`,
			debug.traceback(nil, 2)
		)
	end

	return {
		DisplayName = `{p} Finisher`,
		Icon = v10 or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "Finisher",
		Value = p
	}
end

function RewardInfo.createSwordAccessoryReward(p: string, p2: string?)
	local v10 = p2 or v3.Icons:GetSwordAccessoryIcon(p)

	if v6 and not v10 then
		warn(
			`[!] Sword Accessory "{p}" does not exist, but it's being used in RewardInfo.createSwordAccessoryReward()!`,
			debug.traceback(nil, 2)
		)
	end

	return {
		DisplayName = `{p} Accessory`,
		Icon = v10 or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "SwordAccessory",
		Value = p
	}
end

function RewardInfo.createListReward(list, joined: string?, p: string?, flag: boolean?)
	local v10 = list[1]
	assert(v10, "Tried to create a List RewardInfo without ONE reward...")

	if flag and not joined then
		local displayNames = {}

		for _, v11 in list do
			table.insert(displayNames, v11.DisplayName)
		end

		joined = table.concat(displayNames, ", ")
	end

	return {
		DisplayName = joined or v10.DisplayName,
		Icon = p or v10.Icon or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "List",
		Value = list
	}
end

function RewardInfo.createCrownsReward(p: number)
	return {
		DisplayName = `{p} Crowns`,
		Icon = "rbxassetid://15579450524",
		Type = "Crowns",
		Value = p
	}
end

function RewardInfo.createActivityPointsReward(p: number)
	return {
		DisplayName = `{p} Activity Points`,
		Icon = "rbxassetid://15579452478",
		Type = "ActivityPoints",
		Value = p
	}
end

function RewardInfo.createChestReward(p: string, amount: number, p3: string?)
	return {
		DisplayName = `{p} Chest`,
		Icon = p3 or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "Chest",
		Value = p,
		Amount = amount
	}
end

function RewardInfo.createClanPointsReward(p: number, p2: string?)
	return {
		DisplayName = `{v4.commify(p)} Clan Points`,
		Icon = p2 or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "ClanPoints",
		Value = p
	}
end

function RewardInfo.createAbilityReward(displayName: string)
	return {
		DisplayName = displayName,
		Icon = ReplicatedStorage2.Misc.DataAbilities[displayName]:GetAttribute("Icon") or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "Ability",
		Value = displayName
	}
end

function RewardInfo.createAbilityUpgradeReward(childName: string, amount: number, p2: string?)
	local child = ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(childName)
	return {
		DisplayName = `{childName} Upgrade {amount}`,
		Icon = p2 or child:GetAttribute((`Icon{amount}`)) or child:GetAttribute("Icon") or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "AbilityUpgrade",
		Value = childName,
		Amount = amount
	}
end

function RewardInfo.createBadgeReward(p: number, value: string?, p2: string?)
	return {
		DisplayName = value or "",
		Icon = p2 or `rbxthumb://type=BadgeIcon&id={p}&w=150&h=150`,
		Type = "Badge",
		Value = p
	}
end

function RewardInfo.createCustomReward(displayName: string, value2: string?, p)
	if v6 and (displayName:upper() == "PLACEHOLDER" or displayName:upper() == "TBD") then
		warn(
			`[!] CustomReward "{displayName}" does not exist, but it's being used in RewardInfo.createCustomReward()!`,
			debug.traceback(nil, 2)
		)
	end

	return {
		DisplayName = displayName,
		Icon = value2 or "rbxassetid://6034407076",
		Type = "Custom",
		Value = p
	}
end

function RewardInfo.createCandyReward(p: number)
	local v10 = p == 1 and "Candy" or "Candies"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://94754671990303",
		Type = "Candy",
		Value = p
	}
end

function RewardInfo.createTennisBallReward(p: number)
	local v10 = p == 1 and "Tennis Ball" or "Tennis Balls"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://18652805305",
		Type = "TennisBalls",
		Value = p
	}
end

function RewardInfo.createShiniesReward(p: number)
	local v10 = p == 1 and "Shiny" or "Shinies"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://18655368230",
		Type = "Shinies",
		Value = p
	}
end

function RewardInfo.createSilverReward(p: number)
	local v10 = p == 1 and "Silver" or "Silvers"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://18655368107",
		Type = "Silver",
		Value = p
	}
end

function RewardInfo.createBloxyColaReward(p: number)
	local v10 = p == 1 and "Bloxy Cola" or "Bloxy Colas"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://17488812377",
		Type = "BloxyCola",
		Value = p
	}
end

function RewardInfo.createOGTokenReward(p: number)
	local v10 = p == 1 and "OG Token" or "OG Tokens"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://17488704705",
		Type = "OGToken",
		Value = p
	}
end

function RewardInfo.createTixReward(p: number)
	local v10 = p == 1 and "Tix" or "Tixs"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://17488704816",
		Type = "Tix",
		Value = p
	}
end

function RewardInfo.createTournamentDuoTicketsReward(p: number)
	local v10 = p == 1 and "Tournament Duo Ticket" or "Tournament Duo Tickets"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://17762954957",
		Type = "TournamentDuoTickets",
		Value = p
	}
end

function RewardInfo.createOctoCoinsReward(p: number)
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} Octo Coins`,
		Icon = "rbxassetid://18262225536",
		Type = "OctoCoins",
		Value = p
	}
end

function RewardInfo.createStarfishReward(p: number)
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} Starfish`,
		Icon = "rbxassetid://18248922628",
		Type = "Starfish",
		Value = p
	}
end

function RewardInfo.createBoothReward(displayName: string)
	return {
		DisplayName = displayName,
		Icon = "TODO",
		Type = "Booth",
		Value = displayName
	}
end

function RewardInfo.createTournamentEventCurrency(p: number)
	return {
		DisplayName = `{p} {p > 1 and "Trophies" or "Trophy"}`,
		Icon = "rbxassetid://120909105860865",
		Type = "TournamentEventCurrency",
		Value = p
	}
end

function RewardInfo.createCandyCanesReward(p: number)
	local v10 = p == 1 and "Candy Cane" or "Candy Canes"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://121074050598600",
		Type = "CandyCanes",
		Value = p
	}
end

function RewardInfo.createChristmasSelectionCrate(p: number)
	return {
		DisplayName = `+{p} Santa's Crate`,
		Icon = "rbxassetid://73120052471110",
		Type = "ChristmasSelectionCrate",
		Value = p
	}
end

function RewardInfo.createGenericGachaSpinReward(p: number, p2: string)
	return {
		DisplayName = `+{p} {p2}`,
		Icon = "rbxassetid://93834239892474",
		Type = "GenericGachaSpin",
		Value = p
	}
end

function RewardInfo.createCloverReward(p: number)
	local v10 = p == 1 and "Snowflake" or "Snowflakes"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://15423842964",
		Type = "Clover",
		Value = p
	}
end

function RewardInfo.createLimitedEggReward(displayName: string)
	return {
		DisplayName = displayName,
		Icon = "rbxassetid://14503265310",
		Type = "LimitedEgg",
		Value = 1
	}
end

function RewardInfo.createLegoLimitedUgcReward(displayName: string)
	return {
		DisplayName = displayName,
		Icon = v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "LegoLimitedUgc",
		Value = 1
	}
end

function RewardInfo.createGoldenNuggetReward(p: number)
	return {
		DisplayName = `{p} Golden Nugget{p > 1 and "s" or ""}`,
		Icon = v3.Icons:GetIcon("GoldenNugget"),
		Type = "GoldenNugget",
		Value = p
	}
end

function RewardInfo.createUGCItemReward(p: number, initialStock: number, displayName: string, p4: string?)
	return {
		DisplayName = displayName,
		Icon = p4 or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "UGCItem",
		InitialStock = initialStock,
		Value = p
	}
end

function RewardInfo.createPeriodEventIngredientReward(p: string, p2: string?, p3: string?)
	return {
		DisplayName = p2 or p,
		Icon = p3 or v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "PeriodEventIngredient",
		Value = p
	}
end

function RewardInfo.createLanternsReward(p: number)
	local v10 = p == 1 and "Lantern" or "Lanterns"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://128631139619256",
		Type = "Lanterns",
		Value = p
	}
end

function RewardInfo.createSpecialTrainingEventCurrency(p: number)
	local v10 = p == 1 and "Eternal Snowflake" or "Eternal Snowflakes"
	return {
		DisplayName = `{v3.ValueConvertor:AddCommas(p)} {v10}`,
		Icon = "rbxassetid://15423842964",
		Type = "SpecialTrainingEventCurrency",
		Value = p
	}
end

function RewardInfo.createTitleReward(p: string)
	return {
		DisplayName = `"{p}" Title`,
		Icon = v3.Icons:GetIcon("DEFAULT_MISSING"),
		Type = "Title",
		Value = p
	}
end

return RewardInfo