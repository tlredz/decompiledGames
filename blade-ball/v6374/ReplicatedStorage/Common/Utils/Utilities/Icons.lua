local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(script.Parent.CameraUtils)
require3(script.Parent.SwordUtil)
local v2 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v3 = require3(ReplicatedStorage2.Shared.ReplicatedInstancesUtils)
local v4 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.SwordAccessories)
local v5 = require3(ReplicatedStorage2.Shared.EmoteIds)
local Icons = {}
local v6 = {
	DEFAULT_MISSING = "rbxassetid://6034407076",
	ReturnCoins = "rbxassetid://17286763390",
	Credits = "rbxassetid://9341850470",
	CreditsSingle = "rbxassetid://15013634268",
	Crowns = "rbxassetid://15579450524",
	ActivityPoints = "rbxassetid://15579452478",
	ClanPoints = "rbxassetid://15584529840",
	Heart = "rbxassetid://16186953863",
	DropUp = "rbxassetid://11962873301",
	DropDown = "rbxassetid://11965723580",
	Rolls = "rbxassetid://14993705240",
	SwordSkin = "rbxassetid://14993698130",
	Sword = "rbxassetid://14993698130",
	Explosion = "rbxassetid://14994158309",
	Ability = "rbxassetid://14993692520",
	Finisher = "rbxassetid://6034407076",
	SwordCrate = "rbxassetid://15049301853",
	ExplosionCrate = "rbxassetid://16027425894",
	PremiumExplosionCrate = "rbxassetid://15049303003",
	PremiumSwordCrate = "rbxassetid://160399676f46",
	LunarCrate = "rbxassetid://16303928486",
	PremiumExplosion = "rbxassetid://15049303003",
	PremiumSword = "rbxassetid://16039967646",
	GalaxyExplosion = "rbxassetid://16685544050",
	UnstableExplosion = "rbxassetid://17109532488",
	MagicalExplosion = "rbxassetid://17515280567",
	TropicalExplosion = "rbxassetid://18256197584",
	TechnoExplosion = "rbxassetid://18890088985",
	WickedExplosion = "rbxassetid://138542924584183",
	IceExplosion = "rbxassetid://127871018868006",
	ChristmasExplosion2 = "rbxassetid://83227151775717",
	NewYearExplosion2 = "rbxassetid://16130315794",
	ValentinesExplosion = "rbxassetid://113685110472642",
	ReactorExplosion = "rbxassetid://133416275924749",
	CarrotExplosion = "rbxassetid://73287778141933",
	SamuraiExplosion = "rbxassetid://77622442947999",
	PixelExplosion = "rbxassetid://87245837508215",
	NinjaExplosion = "rbxassetid://106102895119257",
	HydroshockExplosion = "rbxassetid://117773617433133",
	BlizzardExplosion = "rbxassetid://139957144476188",
	ChristmasExplosion3 = "rbxassetid://125192646021360",
	BlackholeExplosion = "rbxassetid://85012076690871",
	MythologyExplosion = "rbxassetid://91367768473425",
	ChristmasSword = "rbxassetid://15721959243",
	Pumpkins = "rbxassetid://15058188929",
	Snowflakes = "rbxassetid://15423842964",
	Socks = "rbxassetid://15695607674",
	Cookies = "rbxassetid://15714926698",
	Balloons = "rbxassetid://16123086920",
	Stars = "rbxassetid://101166383055469",
	LuckyCoins = "rbxassetid://16274039248",
	Souls = "rbxassetid://17096699368",
	Crystals = "rbxassetid://17515245060",
	Shells = "rbxassetid://18225178503",
	Chips = "rbxassetid://18886185625",
	Fireworks = "rbxassetid://118244608295898",
	Hearts = "rbxassetid://95519826058604",
	Screws = "rbxassetid://74085388326308",
	Carrots = "rbxassetid://82347786347872",
	Diamonds = "rbxassetid://104381899386245",
	Yen = "rbxassetid://70545505210335",
	Runes = "rbxassetid://76246792180449",
	BattlepassSelectionCrate = "rbxassetid://107071223406411",
	BattlepassPremiumSelectionCrate = "rbxassetid://84277984428189",
	BattlepassTierSkip = "rbxassetid://131844731122485",
	BattlepassPremium = "rbxassetid://119326915462051",
	ROBUX = "rbxassetid://7979701958",
	Loading = "rbxassetid://6031086176",
	Gift = "rbxassetid://13253134744",
	["Clan Points"] = "rbxassetid://15612091195",
	ZombieTickets = "rbxassetid://16030046667",
	Lava2Tickets = "rbxassetid://75528981538882",
	SkyTickets = "rbxassetid://16548253722",
	RocketTickets = "rbxassetid://16822236592",
	StormTickets = "rbxassetid://17025803567",
	VIPTickets = "rbxassetid://17361829634",
	WaterTickets = "rbxassetid://18323910967",
	SharkTickets = "rbxassetid://18565785410",
	DodgeballTickets = "rbxassetid://15873193310",
	HotPotatoTickets = "rbxassetid://80251487193786",
	WinterRoyaleTickets = "rbxassetid://126815960888144",
	Dodgeball3Tickets = "rbxassetid://15873193310",
	SquadRoyaleTickets = "rbxassetid://118344257477114",
	SheriffsVsOutlawsTickets = "rbxassetid://119917772536477",
	LuckyTickets = "rbxassetid://94469567779600",
	BrainrotTickets = "rbxassetid://17361829634",
	OneAbilityTickets = "rbxassetid://136901927853515",
	RedLightGreenLightTickets = "rbxassetid://17361829634",
	Tag2Tickets = "rbxassetid://17361829634",
	Dodgeball4Tickets = "rbxassetid://15873193310",
	HovergoalTickets = "rbxassetid://17361829634",
	AbilityBlockTickets = "rbxassetid://17361829634",
	BunnyCoins = "rbxassetid://16886603989",
	TournamentTicket = "rbxassetid://16455722863",
	RabbitTokens = "rbxassetid://16932049524",
	DungeonRunes = "rbxassetid://17294426866",
	Tixs = "rbxassetid://17488704816",
	BloxyCola = "rbxassetid://17488812377",
	NoTextBloxyCola = "rbxassetid://17488855500",
	OGToken = "rbxassetid://17488704705",
	HackerTickets = "rbxassetid://17455383966",
	DragonTickets = "rbxassetid://17673739234",
	RebirthTickets = "rbxassetid://17846460275",
	TournamentDuoTickets = "rbxassetid://17762954957",
	OverdriveTickets = "rbxassetid://107343093307477",
	FatesTickets = "rbxassetid://84580728356399",
	AbilityGameTickets = "rbxassetid://136901927853515",
	OctoCoins = "rbxassetid://18262225536",
	Starfish = "rbxassetid://18248922628",
	NormalRaffleTickets = "rbxassetid://18256464704",
	GoldenRaffleTickets = "rbxassetid://18256464829",
	Tokens = "rbxassetid://18887279357",
	TennisBalls = "rbxassetid://18652805305",
	Lanterns = "rbxassetid://128631139619256",
	CandyCanes = "rbxassetid://128400472113107",
	Shinies = "rbxassetid://18655368230",
	Silver = "rbxassetid://18655368107",
	Candy = "rbxassetid://94754671990303",
	LegoBrick = "rbxassetid://85355560167839",
	HourlyWheelSpin_Mummy = "rbxassetid://87170019550546",
	HourlyWheelSpin_Gingerbread = "rbxassetid://127143732141224",
	HourlyWheelSpin_NewYears = "rbxassetid://75454579481248",
	HourlyWheelSpin_Valentines = "rbxassetid://101366455692946",
	HourlyWheelSpin_Poison = "rbxassetid://130609176293856",
	HourlyWheelSpin_Spring = "rbxassetid://110968686001194",
	HourlyWheelSpin_Crystal = "rbxassetid://81831956952568",
	GoldenNugget = "rbxassetid://80596989605291",
	PC = "rbxassetid://125790749303945",
	Console = "rbxassetid://86891379354083",
	Phone = "rbxassetid://86972712920191",
	Tablet = "rbxassetid://88937029747799"
}
Icons.DEFAULT_ICONS = v6

function Icons:GetIcon(p: string)
	return v6[p] or v6.DEFAULT_MISSING
end

function Icons:FitObjectViewportFrame(parent, p, vector2: Vector3, value: number)
	local v7 = vector2 or Vector3.new()
	local currentCamera = parent.CurrentCamera

	if not parent.CurrentCamera then
		currentCamera = Instance.new("Camera")
		currentCamera.Parent = parent
		parent.CurrentCamera = currentCamera
	end

	p.Parent = parent
	local boundingBox, v10 = v:GetBoundingBox(p)
	local fitBoundingBoxToCamera = v.fitBoundingBoxToCamera(
		v10,
		currentCamera.FieldOfView,
		currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y
	)
	currentCamera.CFrame = boundingBox * CFrame.Angles(math.rad(v7.X), math.rad(v7.Y), (math.rad(v7.Z))) * CFrame.new(
		0,
		0,
		fitBoundingBoxToCamera * (value or 1)
	)
end

function Icons:SetSwordIconAsViewport(p, instance)
	self:FitObjectViewportFrame(
		p,
		instance,
		instance:GetAttribute("ViewportOrientation") or createVector(0, 90, -30),
		instance:GetAttribute("ViewportZoom")
	)
end

function Icons:SetSwordIconAsViewportByName(parent, p)
	local model = Instance.new("Model")
	model.Parent = parent
	task.spawn(function()
		local instance = v3.getInstance("Swords", p)

		if not (instance and model.Parent) then
			return
		end

		local clone = instance:Clone()
		clone:PivotTo(model:GetPivot())
		clone.Parent = model
		self:SetSwordIconAsViewport(parent, clone)
	end)
	return model
end

function Icons:GetSwordIcon(p)
	local sword = v2:GetSword(p)

	if not sword then
		return v6.DEFAULT_MISSING
	end

	local icon = sword.Icon

	if not (icon and #icon > 0 and icon) then
		icon = v6.DEFAULT_MISSING
	end

	return icon
end

function Icons:GetAbilityIcon(childName, p: number?)
	local child = ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(childName)

	if child then
		return p and child:GetAttribute((`Icon{p}`)) or child:GetAttribute("Icon") or v6.DEFAULT_MISSING
	end

	return v6.DEFAULT_MISSING
end

function Icons:GetExplosionIcon(childName)
	local child = ReplicatedStorage2.Misc.DataExplosions:FindFirstChild(childName)

	if child then
		return child:GetAttribute("Icon") or v6.DEFAULT_MISSING
	end

	return v6.DEFAULT_MISSING
end

function Icons:GetCharacterIcon(childName)
	local child = ReplicatedStorage2.Misc.DataCharacters:FindFirstChild(childName)

	if child then
		return child:GetAttribute("Icon") or v6.DEFAULT_MISSING
	end
end

function Icons:GetFinisherIcon(childName)
	local child = ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(childName)

	if not child then
		return v6.DEFAULT_MISSING
	end

	local icon = child:GetAttribute("Icon")

	if icon then
		return icon
	end

	return self:GetSwordIcon(childName)
end

function Icons:GetSwordAccessoryIcon(p)
	local v7 = v4:GetCollection()[p]
	return v7 and v7.Icon or v6.DEFAULT_MISSING
end

function Icons:GetEmoteIcon(childName)
	if not string.match(childName, "^Emote(%d+)$") then
		childName = v5.EmotesToIds[childName]
	end

	local child = childName and game.ReplicatedStorage.Misc.Emotes:FindFirstChild(childName)

	if not child then
		warn(`[!] Unable to find the following emote id: {childName}`, debug.traceback())
		return Icons:GetIcon("DEFAULT_MISSING")
	end

	local icon = child:GetAttribute("Icon")

	if not icon then
		warn((`[!] Unable to find the following emote id: {childName}`))
	end

	return icon or Icons:GetIcon("DEFAULT_MISSING")
end

function Icons:GetIconFromData(data)
	if data.IconID then
		return data.IconID
	end

	local elementIcon = data.ElementIcon and self:GetElementIcon(data.ElementIcon)

	if elementIcon then
		return elementIcon
	end

	local swordIcon = data.SwordIcon and self:GetSwordIcon(data.SwordIcon)

	if swordIcon then
		return swordIcon
	end

	local emoteIcon = data.EmoteIcon and self:GetEmoteIcon(data.EmoteIcon)

	if emoteIcon then
		return emoteIcon
	end

	local icon = data.Icon and self:GetIcon(data.Icon)

	if icon then
		return icon
	end
end

function Icons:GetIconFromInfo(player)
	local itemType = player.ItemType

	if itemType == "Sword" then
		return self:GetSwordIcon(player.Sword)
	elseif itemType == "Accessory" then
		return self:GetSwordAccessoryIcon(player.Accessory)
	elseif itemType == "Ability" then
		return self:GetAbilityIcon(player.Ability)
	elseif itemType == "Explosion" then
		return self:GetExplosionIcon(player.Explosion)
	elseif itemType == "Character" then
		return self:GetCharacterIcon(player.Character)
	elseif itemType == "Finisher" then
		return self:GetFinisherIcon(player.Finisher)
	elseif itemType == "Element" then
		return self:GetElementIcon(player.Element)
	elseif itemType == "Emote" then
		return self:GetEmoteIcon(player.Emote)
	end

	return player.Icon or self:GetIcon("DEFAULT_MISSING")
end

return Icons