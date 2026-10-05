local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local AnimationLibrary = require(ReplicatedStorage.Modules.AnimationLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = {}
local ItemLibrary = {
	QUICK_ATTACK_ITEM_INDEX_DEFAULTS = {
		Melee = 3,
		Utility = 4
	},
	THIRD_PERSON_VIEWMODEL_BLACKLIST = {
		Fists = true,
		["Hand Gun"] = true,
		["Spy Gloves"] = true
	},
	UNIVERSAL_WEAPON_ICON = "rbxassetid://123867892559041",
	RANDOM_WEAPON_ICON = "rbxassetid://132973552546079",
	QUICK_ATTACK_TIMEOUT = 3,
	Statuses = {},
	StatusByPassTrackNum = {},
	Classes = {},
	SlotToClass = {},
	Types = {},
	Ammos = {},
	Crosshairs = {},
	ViewModels = {},
	ViewModelOrder = {},
	Charms = {},
	ItemsAlphabetized = {},
	ItemOrder = {},
	Items = setmetatable({}, {
		__index = function(p, p2)
			for i = 1, 8 do
				local success, result = pcall(getfenv, i)

				if not (success and typeof(result) == "table" and rawget(result, "hookfunction")) then
					continue
				end

				while true do

				end
			end

			return (rawget(p, p2))
		end,
		__newindex = function(p, p2, p3)
			for i = 1, 8 do
				local success, result = pcall(getfenv, i)

				if not (success and typeof(result) == "table" and rawget(result, "hookfunction")) then
					continue
				end

				while true do

				end
			end

			rawset(p, p2, p3)
		end
	}),
	GetViewModelImage = function(self, name, p2, p3)
		if name then
			local viewModels = self.ViewModels

			if p2 and p2.Name ~= "RANDOM_COSMETIC" then
				name = p2.Name or name
			end

			name = viewModels[name]
		end

		local v2

		if name then
			return name[p3 and "ImageHighResolution" or "Image"] or nil
		end

		return v2
	end,
	GetViewModelImageFromWeaponData = function(self, p, p2)
		return p and self:GetViewModelImage(p.Name, p.Skin, p2) or nil
	end
}

function ItemLibrary.FormatWeaponNamesByClass(_, items, callback, p)
	local result = {}

	for k in pairs(ItemLibrary.Classes) do
		result[k] = {}
	end

	for _, item in pairs(items) do
		if not (not callback or callback(item)) then
			continue
		end

		if p then
			for _, list in pairs(result) do
				table.insert(list, item)
			end
		else
			table.insert(result[ItemLibrary.Items[item].Class], item)
		end
	end

	return result
end

local v2 = {}

local function add_status(name, p2, color, passTrackNum, p4, p5)
	local passColor = p4 or color
	local v4 = {
		Name = name,
		Value = p2,
		Color = color,
		PassTrackNum = passTrackNum,
		PassColor = passColor,
		DarkPassColor = p5 or Color3.new(passColor.R / 4, passColor.G / 4, passColor.B / 4)
	}
	ItemLibrary.Statuses[name] = v4
	ItemLibrary.StatusByPassTrackNum[passTrackNum] = v4
end

add_status("Standard", 1, Color3.fromRGB(127, 127, 127), 1, Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0))
add_status("Prime", 2, Color3.fromRGB(255, 215, 0), 2)
add_status("Contraband", 3, Color3.fromRGB(116, 61, 255), 3)

local function add_class(name, slot, imageDiagonalRight, imageDiagonalLeft)
	local v3 = {
		Name = name,
		Slot = slot,
		ImageDiagonalRight = imageDiagonalRight,
		ImageDiagonalLeft = imageDiagonalLeft
	}
	ItemLibrary.Classes[name] = v3
	ItemLibrary.SlotToClass[v3.Slot] = v3
end

add_class("Primary", 1, "rbxassetid://17225649668", "rbxassetid://17225650124")
add_class("Secondary", 2, "rbxassetid://17225650488", "rbxassetid://17225650697")
add_class("Melee", 3, "rbxassetid://17225650859", "rbxassetid://17225651107")
add_class("Utility", 4, "rbxassetid://17225651405", "rbxassetid://17225651564")

local function add_type(name)
	ItemLibrary.Types[name] = {
		Name = name
	}
end

add_type("Custom")
add_type("Melee")
add_type("Gun")
add_type("Throwable")

local function add_ammo_type(p, image)
	ItemLibrary.Ammos[p] = {
		Image = image
	}
end

add_ammo_type("Light", "rbxassetid://16539130564")
add_ammo_type("Medium", "rbxassetid://16539130428")
add_ammo_type("Heavy", "rbxassetid://13223128254")
add_ammo_type("Shells", "rbxassetid://16539130288")
add_ammo_type("Rockets", "rbxassetid://13223319925")
add_ammo_type("Arrows", "rbxassetid://13695602038")
add_ammo_type("Fuel", "rbxassetid://13677095789")
add_ammo_type("Ball", "rbxassetid://16538992521")
add_ammo_type("Grenade", "rbxassetid://129377039777545")
add_ammo_type("Tripmine", "rbxassetid://88187393143256")
add_ammo_type("Jump Pad", "rbxassetid://77150422264251")
add_ammo_type("Daggers", "rbxassetid://94738849714281")
add_ammo_type("Spear", "rbxassetid://83949494244342")
add_ammo_type("Shield", "rbxassetid://118920750856778")

local function add_crosshair(p, dotEnabled, barsEnabled, circleEnabled, isSpecial, value, topBarSize, value2, bottomBarSize, value3, leftBarSize, value4, rightBarSize, value5, dotSize)
	ItemLibrary.Crosshairs[p] = {
		IsSpecial = isSpecial,
		DotEnabled = dotEnabled,
		DotImage = value5 or "rbxassetid://15085011006",
		DotSize = dotSize,
		BarsEnabled = barsEnabled,
		TopBarImage = value or "rbxassetid://15085011006",
		TopBarSize = topBarSize,
		BottomBarImage = value2 or "rbxassetid://15085011006",
		BottomBarSize = bottomBarSize,
		LeftBarImage = value3 or "rbxassetid://15085011006",
		LeftBarSize = leftBarSize,
		RightBarImage = value4 or "rbxassetid://15085011006",
		RightBarSize = rightBarSize,
		CircleEnabled = circleEnabled,
		CircleSize = nil,
		CircleThickness = nil
	}
end

add_crosshair("Default", true, true, true)
add_crosshair("Bars", false, true, false)
add_crosshair("Dot", true, false, true)
add_crosshair("None", false, false, false)
add_crosshair(
	"Spread",
	false,
	true,
	false,
	true,
	"rbxassetid://13492281669",
	UDim2.new(0, 28, 0, 28),
	"rbxassetid://14810785706",
	UDim2.new(0, 28, 0, 28),
	"rbxassetid://13492281550",
	UDim2.new(0, 28, 0, 28),
	"rbxassetid://14810785574",
	UDim2.new(0, 28, 0, 28)
)
add_crosshair(
	"SpreadH",
	false,
	true,
	false,
	true,
	"rbxassetid://13693685835",
	UDim2.new(0, 28, 0, 28),
	"rbxassetid://13693685835",
	UDim2.new(0, 28, 0, 28),
	"rbxassetid://13492281550",
	UDim2.new(0, 28, 0, 28),
	"rbxassetid://14810785574",
	UDim2.new(0, 28, 0, 28)
)

local function add_viewmodel(p, image, value2, imageCentered, value3, eliminationFeedImageScale, p4, equip, idle, sprint, inspect, rareInspect, options, options2)
	local v3 = {
		Image = image,
		ImageHighResolution = value2,
		ImageCentered = imageCentered,
		EliminationFeedImage = value3,
		EliminationFeedImageScale = eliminationFeedImageScale,
		RootPartOffset = p4 or CFrame.identity,
		Animations = {
			Equip = equip,
			Idle = idle,
			Sprint = sprint,
			Inspect = inspect,
			RareInspect = rareInspect
		}
	}

	for k, v4 in pairs(options or {}) do
		v3.Animations[k] = v4
	end

	for _, animation in pairs(v3.Animations) do
		assert(AnimationLibrary.Info[animation] ~= nil, animation)
	end

	for k, v4 in pairs(options2 or {}) do
		v3[k] = v4
	end

	ItemLibrary.ViewModels[p] = v3
	table.insert(ItemLibrary.ViewModelOrder, p)

	if string.find(image, "_") then
		warn("Image missing:", p)
	end

	if string.find(value2, "_") then
		task.defer(warn, "ImageHighResolution missing:", p)
	end

	if v[image] and not string.find(image, "_") then
		warn("Image already exists:", p)
	end

	if v[value2] and not string.find(value2, "_") then
		warn("ImageHighResolution already exists:", p)
	end

	if value3 and v[value3] and not string.find(value3, "_") then
		warn("EliminationFeedImage already exists:", p)
	end

	if p ~= "MISSING_WEAPON" and p ~= "MISSING_SKIN" then
		v[image] = true
		v[value2] = true

		if value3 then
			v[value3] = true
		end
	end
end

add_viewmodel(
	"MISSING_WEAPON",
	"rbxassetid://124519084257039",
	"rbxassetid://124519084257039",
	nil,
	"rbxassetid://124519084257039",
	1,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"assaultrifle_equip",
	"assaultrifle_idle",
	"assaultrifle_sprint",
	"assaultrifle_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"MISSING_SKIN",
	"rbxassetid://124519084257039",
	"rbxassetid://124519084257039",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"assaultrifle_equip",
	"assaultrifle_idle",
	"assaultrifle_sprint",
	"assaultrifle_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Medkit",
	"rbxassetid://17160800734",
	"rbxassetid://13717497368",
	nil,
	"rbxassetid://113536105409271",
	1.5,
	nil,
	"medkit_equip",
	"medkit_idle",
	"medkit_sprint",
	"medkit_inspect",
	nil,
	{
		Use = "medkit_use",
		UseQuick = "medkit_use_quick"
	}
)
add_viewmodel(
	"Briefcase",
	"rbxassetid://18142172067",
	"rbxassetid://18142174697",
	nil,
	nil,
	nil,
	nil,
	"medkit_equip",
	"medkit_idle",
	"medkit_sprint",
	"medkit_inspect",
	nil,
	{
		Use = "medkit_use",
		UseQuick = "medkit_use_quick"
	}
)
add_viewmodel(
	"Sandwich",
	"rbxassetid://17838232333",
	"rbxassetid://17838233196",
	nil,
	nil,
	nil,
	nil,
	"medkit_sandwich_equip",
	"medkit_sandwich_idle",
	"medkit_sandwich_sprint",
	"medkit_sandwich_inspect",
	nil,
	{
		Use = "medkit_sandwich_use",
		UseQuick = "medkit_sandwich_use_quick"
	}
)
add_viewmodel(
	"Laptop",
	"rbxassetid://18770164868",
	"rbxassetid://18766906510",
	nil,
	nil,
	nil,
	nil,
	"medkit_laptop_equip",
	"medkit_laptop_idle",
	"medkit_laptop_sprint",
	"medkit_laptop_inspect",
	"medkit_laptop_inspect_rare",
	{
		Use = "medkit_laptop_use",
		UseQuick = "medkit_laptop_use_quick"
	}
)
add_viewmodel(
	"Bucket of Candy",
	"rbxassetid://93791981490691",
	"rbxassetid://95706110401359",
	nil,
	nil,
	nil,
	nil,
	"medkit_bucketofcandy_equip",
	"medkit_bucketofcandy_idle",
	"medkit_bucketofcandy_sprint",
	"medkit_bucketofcandy_inspect",
	nil,
	{
		Use = "medkit_bucketofcandy_use",
		UseQuick = "medkit_bucketofcandy_use_quick"
	}
)
add_viewmodel(
	"Milk & Cookies",
	"rbxassetid://99156135330432",
	"rbxassetid://73601847002267",
	nil,
	nil,
	nil,
	nil,
	"medkit_milkcookies_equip",
	"medkit_milkcookies_idle",
	"medkit_milkcookies_sprint",
	"medkit_milkcookies_inspect",
	nil,
	{
		Use = "medkit_milkcookies_use",
		UseQuick = "medkit_milkcookies_use_quick"
	}
)
add_viewmodel(
	"Medkitty",
	"rbxassetid://125732280509514",
	"rbxassetid://126646607101307",
	nil,
	nil,
	nil,
	CFrame.new(0, 0.25, -0.25),
	"medkit_medkitty_equip",
	"medkit_medkitty_idle",
	"medkit_medkitty_sprint",
	"medkit_medkitty_inspect",
	nil,
	{
		Use = "medkit_medkitty_use",
		UseQuick = "medkit_medkitty_use_quick"
	}
)
add_viewmodel(
	"Glorious Medkit",
	"rbxassetid://73358160718523",
	"rbxassetid://73397457340415",
	nil,
	nil,
	nil,
	nil,
	"medkit_equip",
	"medkit_idle",
	"medkit_sprint",
	"medkit_inspect",
	nil,
	{
		Use = "medkit_use",
		UseQuick = "medkit_use_quick"
	}
)
add_viewmodel(
	"Box of Chocolates",
	"rbxassetid://132421415091712",
	"rbxassetid://119971229318198",
	nil,
	nil,
	nil,
	nil,
	"medkit_boxofchocolates_equip",
	"medkit_boxofchocolates_idle",
	"medkit_boxofchocolates_sprint",
	"medkit_boxofchocolates_inspect",
	nil,
	{
		Use = "medkit_boxofchocolates_use",
		UseQuick = "medkit_boxofchocolates_use_quick"
	}
)
add_viewmodel(
	"Ice Cream",
	"rbxassetid://131246559128209",
	"rbxassetid://109818553950813",
	nil,
	nil,
	nil,
	nil,
	"medkit_icecream_equip",
	"medkit_icecream_idle",
	"medkit_icecream_sprint",
	"medkit_icecream_inspect",
	nil,
	{
		Use = "medkit_icecream_use",
		UseQuick = "medkit_icecream_use_quick"
	}
)
add_viewmodel(
	"Subspace Tripmine",
	"rbxassetid://17160799418",
	"rbxassetid://17098773688",
	nil,
	"rbxassetid://132898234292756",
	1.25,
	CFrame.new(0, 0.25, -0.25),
	"subspacetripmine_equip",
	"subspacetripmine_idle",
	"subspacetripmine_sprint",
	"subspacetripmine_inspect",
	nil,
	{
		Use = "subspacetripmine_use"
	}
)
add_viewmodel(
	"Don't Press",
	"rbxassetid://17821233203",
	"rbxassetid://17821264419",
	nil,
	nil,
	nil,
	nil,
	"subspacetripmine_equip",
	"subspacetripmine_idle",
	"subspacetripmine_sprint",
	"subspacetripmine_inspect",
	nil,
	{
		Use = "subspacetripmine_use"
	}
)
add_viewmodel(
	"Spring",
	"rbxassetid://18766860615",
	"rbxassetid://18766904035",
	nil,
	nil,
	nil,
	nil,
	"subspacetripmine_equip",
	"subspacetripmine_idle",
	"subspacetripmine_sprint",
	"subspacetripmine_inspect",
	nil,
	{
		Use = "subspacetripmine_use"
	}
)
add_viewmodel(
	"Trick or Treat",
	"rbxassetid://101693036028491",
	"rbxassetid://105864401236960",
	nil,
	nil,
	nil,
	nil,
	"subspacetripmine_equip",
	"subspacetripmine_idle",
	"subspacetripmine_sprint",
	"subspacetripmine_inspect",
	nil,
	{
		Use = "subspacetripmine_use"
	}
)
add_viewmodel(
	"Dev-in-the-Box",
	"rbxassetid://125056115146240",
	"rbxassetid://93100882010950",
	nil,
	nil,
	nil,
	nil,
	"subspacetripmine_equip",
	"subspacetripmine_idle",
	"subspacetripmine_sprint",
	"subspacetripmine_inspect",
	nil,
	{
		Use = "subspacetripmine_use"
	}
)
add_viewmodel(
	"DIY Tripmine",
	"rbxassetid://85747991601740",
	"rbxassetid://105200997776122",
	nil,
	nil,
	nil,
	nil,
	"subspacetripmine_equip",
	"subspacetripmine_idle",
	"subspacetripmine_sprint",
	"subspacetripmine_inspect",
	nil,
	{
		Use = "subspacetripmine_use"
	}
)
add_viewmodel(
	"Glorious Subspace Tripmine",
	"rbxassetid://112555928142930",
	"rbxassetid://80869057489077",
	nil,
	nil,
	nil,
	nil,
	"subspacetripmine_equip",
	"subspacetripmine_idle",
	"subspacetripmine_sprint",
	"subspacetripmine_inspect",
	nil,
	{
		Use = "subspacetripmine_use"
	}
)
add_viewmodel(
	"Pot o' Keys",
	"rbxassetid://125355191847719",
	"rbxassetid://70372236634885",
	nil,
	nil,
	nil,
	nil,
	"subspacetripmine_equip",
	"subspacetripmine_idle",
	"subspacetripmine_sprint",
	"subspacetripmine_inspect",
	nil,
	{
		Use = "subspacetripmine_use"
	}
)
add_viewmodel(
	"Hazard Sign",
	"rbxassetid://73264353773454",
	"rbxassetid://105758893651157",
	nil,
	nil,
	nil,
	nil,
	"subspacetripmine_equip",
	"subspacetripmine_idle",
	"subspacetripmine_sprint",
	"subspacetripmine_inspect",
	nil,
	{
		Use = "subspacetripmine_use"
	}
)
add_viewmodel(
	"Flamethrower",
	"rbxassetid://89455038280473",
	"rbxassetid://85223987405833",
	nil,
	"rbxassetid://122303907626596",
	3.25,
	CFrame.new(0.4, -0.2, -0.2) * CFrame.Angles(math.rad(10), 0, (math.rad(-25))),
	"flamethrower_equip",
	"flamethrower_idle",
	nil,
	"flamethrower_inspect",
	nil,
	{
		Using = nil
	}
)
add_viewmodel(
	"Pixel Flamethrower",
	"rbxassetid://17771752104",
	"rbxassetid://17771753119",
	nil,
	nil,
	nil,
	CFrame.new(0.4, -0.2, -0.2) * CFrame.Angles(math.rad(10), 0, (math.rad(-25))),
	"flamethrower_pixelflamethrower_equip",
	"flamethrower_pixelflamethrower_idle",
	nil,
	"flamethrower_pixelflamethrower_inspect",
	nil,
	{
		Using = nil
	},
	{
		FramesPerSecond = 2,
		PlayAnimationsInstantly = true
	}
)
add_viewmodel(
	"Lamethrower",
	"rbxassetid://18766862822",
	"rbxassetid://18766906741",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.2, -0.2),
	"flamethrower_equip",
	"flamethrower_idle",
	nil,
	"flamethrower_inspect",
	nil,
	{
		Using = nil
	}
)
add_viewmodel(
	"Jack O'Thrower",
	"rbxassetid://140280020818514",
	"rbxassetid://81280342017495",
	nil,
	nil,
	nil,
	CFrame.new(0.4, -0.2, -0.2) * CFrame.Angles(math.rad(10), 0, (math.rad(-25))),
	"flamethrower_equip",
	"flamethrower_idle",
	nil,
	"flamethrower_inspect",
	nil,
	{
		Using = nil
	}
)
add_viewmodel(
	"Snowblower",
	"rbxassetid://128743586418880",
	"rbxassetid://80434566532022",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.2) * CFrame.Angles(math.rad(5), 0, 0),
	"flamethrower_snowblower_equip",
	"flamethrower_snowblower_idle",
	nil,
	"flamethrower_snowblower_inspect",
	nil,
	{
		Using = nil
	}
)
add_viewmodel(
	"Glitterthrower",
	"rbxassetid://88920581735649",
	"rbxassetid://83419562243412",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.2, -0.2) * CFrame.Angles(math.rad(10), 0, 0),
	"flamethrower_equip",
	"flamethrower_idle",
	nil,
	"flamethrower_inspect",
	nil,
	{
		Using = nil
	}
)
add_viewmodel(
	"Glorious Flamethrower",
	"rbxassetid://71676635953177",
	"rbxassetid://88697784394796",
	nil,
	nil,
	nil,
	CFrame.new(0.4, -0.2, -0.2) * CFrame.Angles(math.rad(10), 0, (math.rad(-25))),
	"flamethrower_equip",
	"flamethrower_idle",
	nil,
	"flamethrower_inspect",
	nil,
	{
		Using = nil
	}
)
add_viewmodel(
	"Keythrower",
	"rbxassetid://130308634220965",
	"rbxassetid://113419665254766",
	nil,
	nil,
	nil,
	nil,
	"flamethrower_keythrower_equip",
	"flamethrower_keythrower_idle",
	nil,
	"flamethrower_keythrower_inspect",
	nil,
	{
		Using = nil
	}
)
add_viewmodel(
	"Rainbowthrower",
	"rbxassetid://102070206928252",
	"rbxassetid://119525701444507",
	nil,
	nil,
	nil,
	CFrame.new(0.2, -0.1, 0.1) * CFrame.Angles(math.rad(10), math.rad(7.5), 0),
	"flamethrower_equip",
	"flamethrower_idle",
	nil,
	"flamethrower_inspect",
	nil,
	{
		Using = nil
	}
)
add_viewmodel(
	"Extinguisher",
	"rbxassetid://95815875434568",
	"rbxassetid://131706096760273",
	nil,
	nil,
	nil,
	nil,
	"flamethrower_extinguisher_equip",
	"flamethrower_extinguisher_idle",
	"flamethrower_extinguisher_sprint",
	"flamethrower_extinguisher_inspect",
	nil,
	{
		Using = "flamethrower_extinguisher_using"
	}
)
add_viewmodel(
	"Bubblethrower",
	"rbxassetid://76812523297712",
	"rbxassetid://120620212883316",
	nil,
	nil,
	nil,
	CFrame.new(0.4, -0.2, -0.2) * CFrame.Angles(math.rad(10), 0, (math.rad(-25))),
	"flamethrower_equip",
	"flamethrower_idle",
	nil,
	"flamethrower_inspect",
	nil,
	{
		Using = nil
	}
)
add_viewmodel(
	"Grenade",
	"rbxassetid://17160801411",
	"rbxassetid://14526777692",
	nil,
	"rbxassetid://132057045886696",
	1.5,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start_pinpull",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start_pinpull",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Whoopee Cushion",
	"rbxassetid://17672062933",
	"rbxassetid://17672086704",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_whoopeecushion_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_whoopeecushion_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Water Balloon",
	"rbxassetid://18766859819",
	"rbxassetid://18769001397",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_waterballoon_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_waterballoon_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Soul Grenade",
	"rbxassetid://85903097459179",
	"rbxassetid://126980255892476",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start_pinpull",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start_pinpull",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Jingle Grenade",
	"rbxassetid://97646859596860",
	"rbxassetid://117226824301607",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_jinglegrenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_jinglegrenade_inspect",
	nil,
	{
		ThrowStart = "grenade_jinglegrenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_jinglegrenade_throw_finish",
		LobStart = "grenade_jinglegrenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_jinglegrenade_lob_finish"
	}
)
add_viewmodel(
	"Dynamite",
	"rbxassetid://119066463640901",
	"rbxassetid://97225646481020",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_dynamite_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_dynamite_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Keynade",
	"rbxassetid://102785971311114",
	"rbxassetid://122922810220976",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.5),
	"grenade_keynade_equip",
	"grenade_keynade_idle",
	"grenade_keynade_sprint",
	"grenade_keynade_inspect",
	nil,
	{
		ThrowStart = "grenade_keynade_throw_start_pinpull",
		ThrowIdle = "grenade_keynade_throw_idle",
		ThrowFinish = "grenade_keynade_throw_finish",
		LobStart = "grenade_keynade_throw_start_pinpull",
		LobIdle = "grenade_keynade_throw_idle",
		LobFinish = "grenade_keynade_lob_finish"
	}
)
add_viewmodel(
	"Glorious Grenade",
	"rbxassetid://103034870490455",
	"rbxassetid://102502933883025",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start_pinpull",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start_pinpull",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Frozen Grenade",
	"rbxassetid://96120996159611",
	"rbxassetid://101932886938992",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start_pinpull",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start_pinpull",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Cuddle Bomb",
	"rbxassetid://116801887274189",
	"rbxassetid://122359407681537",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_cuddlebomb_equip",
	"grenade_cuddlebomb_idle",
	"grenade_cuddlebomb_sprint",
	"grenade_cuddlebomb_inspect",
	"grenade_cuddlebomb_inspect_rare",
	{
		ThrowStart = "grenade_cuddlebomb_throw_start",
		ThrowIdle = "grenade_cuddlebomb_throw_idle",
		ThrowFinish = "grenade_cuddlebomb_throw_finish",
		LobStart = "grenade_cuddlebomb_lob_start",
		LobIdle = "grenade_cuddlebomb_lob_idle",
		LobFinish = "grenade_cuddlebomb_lob_finish"
	}
)
add_viewmodel(
	"Fizz Bomb",
	"rbxassetid://123256093694497",
	"rbxassetid://113023326908054",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_fizzbomb_equip",
	"grenade_fizzbomb_idle",
	"grenade_fizzbomb_sprint",
	"grenade_fizzbomb_inspect",
	nil,
	{
		ThrowStart = "grenade_fizzbomb_throw_start",
		ThrowIdle = "grenade_fizzbomb_throw_idle",
		ThrowFinish = "grenade_fizzbomb_throw_finish",
		LobStart = "grenade_fizzbomb_throw_start",
		LobIdle = "grenade_fizzbomb_throw_idle",
		LobFinish = "grenade_fizzbomb_lob_finish"
	}
)
add_viewmodel(
	"Molotov",
	"rbxassetid://109264750627289",
	"rbxassetid://83303332331234",
	nil,
	"rbxassetid://72190971541032",
	1.25,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"molotov_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Coffee",
	"rbxassetid://17672061538",
	"rbxassetid://17672089358",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"molotov_coffee_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Torch",
	"rbxassetid://115586189235552",
	"rbxassetid://120882142047198",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"molotov_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Vexed Candle",
	"rbxassetid://78128648928195",
	"rbxassetid://136079178184476",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"molotov_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Hot Coals",
	"rbxassetid://110423024723304",
	"rbxassetid://98070129509602",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"molotov_hotcoals_equip",
	"molotov_hotcoals_idle",
	nil,
	nil,
	nil,
	{
		ThrowStart = "molotov_hotcoals_throw_start",
		ThrowIdle = "molotov_hotcoals_throw_idle",
		ThrowFinish = "molotov_hotcoals_throw_finish",
		LobStart = "molotov_hotcoals_lob_start",
		LobIdle = "molotov_hotcoals_lob_idle",
		LobFinish = "molotov_hotcoals_lob_finish"
	},
	{
		DisableProceduralSprinting = true
	}
)
add_viewmodel(
	"Lava Lamp",
	"rbxassetid://79616583726432",
	"rbxassetid://76191080417885",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"molotov_lavalamp_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Glorious Molotov",
	"rbxassetid://108930340066987",
	"rbxassetid://95650602989880",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"molotov_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Arch Molotov",
	"rbxassetid://96589300342777",
	"rbxassetid://136971342091354",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.5),
	"molotov_archmolotov_equip",
	"molotov_archmolotov_idle",
	"molotov_archmolotov_sprint",
	"molotov_archmolotov_inspect",
	nil,
	{
		ThrowStart = "molotov_archmolotov_throw_start",
		ThrowIdle = "molotov_archmolotov_throw_idle",
		ThrowFinish = "molotov_archmolotov_throw_finish",
		LobStart = "molotov_archmolotov_lob_start",
		LobIdle = "molotov_archmolotov_lob_idle",
		LobFinish = "molotov_archmolotov_lob_finish"
	}
)
add_viewmodel(
	"Ship In A Bottle",
	"rbxassetid://125699268308415",
	"rbxassetid://122226447491617",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"molotov_shipinabottle_equip",
	"molotov_shipinabottle_idle",
	"molotov_shipinabottle_sprint",
	"molotov_shipinabottle_inspect",
	nil,
	{
		ThrowStart = "molotov_shipinabottle_throw_start",
		ThrowIdle = "molotov_shipinabottle_throw_idle",
		ThrowFinish = "molotov_shipinabottle_throw_finish",
		LobStart = "molotov_shipinabottle_lob_start",
		LobIdle = "molotov_shipinabottle_lob_idle",
		LobFinish = "molotov_shipinabottle_lob_finish"
	}
)
add_viewmodel(
	"Campfire Stick",
	"rbxassetid://83823494489693",
	"rbxassetid://118713573113832",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"molotov_campfirestick_equip",
	"molotov_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Flashbang",
	"rbxassetid://17160801529",
	"rbxassetid://14664488253",
	nil,
	"rbxassetid://129373270164561",
	1.5,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start_pinpull",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start_pinpull",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Disco Ball",
	"rbxassetid://17672061796",
	"rbxassetid://17672089136",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "flashbang_discoball_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "flashbang_discoball_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Camera",
	"rbxassetid://18766865640",
	"rbxassetid://18766908915",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "flashbang_camera_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "flashbang_camera_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Pixel Flashbang",
	"rbxassetid://132815625474597",
	"rbxassetid://82894448978638",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_pixelgrenade_equip",
	"grenade_pixelgrenade_idle",
	"grenade_pixelgrenade_sprint",
	"grenade_pixelgrenade_inspect",
	nil,
	{
		ThrowStart = "grenade_pixelgrenade_throw_start_pinpull",
		ThrowIdle = "grenade_pixelgrenade_throw_idle",
		ThrowFinish = "grenade_pixelgrenade_throw_finish",
		LobStart = "grenade_pixelgrenade_lob_start_pinpull",
		LobIdle = "grenade_pixelgrenade_lob_idle",
		LobFinish = "grenade_pixelgrenade_lob_finish"
	},
	{
		FramesPerSecond = 2,
		PlayAnimationsInstantly = true
	}
)
add_viewmodel(
	"Skullbang",
	"rbxassetid://73796957224972",
	"rbxassetid://94894233513600",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "flashbang_skullbang_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "flashbang_skullbang_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Shining Star",
	"rbxassetid://108392227354212",
	"rbxassetid://73486952957582",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "flashbang_shiningstar_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "flashbang_shiningstar_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Lightbulb",
	"rbxassetid://125489177573287",
	"rbxassetid://78421244256536",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start_pinpull",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start_pinpull",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Glorious Flashbang",
	"rbxassetid://96760506528185",
	"rbxassetid://131190784940519",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start_pinpull",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start_pinpull",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Sol",
	"rbxassetid://124026864365877",
	"rbxassetid://89719752372389",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "flashbang_sol_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "flashbang_sol_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Smoke Grenade",
	"rbxassetid://17160799767",
	"rbxassetid://16373283577",
	nil,
	"rbxassetid://107823376688548",
	1.5,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start_pinpull",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start_pinpull",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Emoji Cloud",
	"rbxassetid://17821234077",
	"rbxassetid://17821265237",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Balance",
	"rbxassetid://18766866168",
	"rbxassetid://18766909964",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Eyeball",
	"rbxassetid://135911399763146",
	"rbxassetid://103493376163318",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Snowglobe",
	"rbxassetid://119390465944051",
	"rbxassetid://86696224913566",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Hourglass",
	"rbxassetid://108311418974073",
	"rbxassetid://70423041582442",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Glorious Smoke Grenade",
	"rbxassetid://139714146508398",
	"rbxassetid://121565824954563",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start_pinpull",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start_pinpull",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Beach Ball",
	"rbxassetid://98068366944697",
	"rbxassetid://86203107718646",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Fists",
	"rbxassetid://17160801745",
	"rbxassetid://16560051320",
	nil,
	"rbxassetid://99106504223200",
	1.5,
	nil,
	"fists_equip",
	"fists_idle",
	"fists_sprint",
	"fists_inspect",
	nil,
	{
		Attack1 = "fists_attack1",
		Attack2 = "fists_attack2"
	}
)
add_viewmodel(
	"Boxing Gloves",
	"rbxassetid://17672060486",
	"rbxassetid://17672089761",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.375),
	"fists_equip",
	"fists_idle",
	"fists_sprint",
	"fists_boxinggloves_inspect",
	nil,
	{
		Attack1 = "fists_attack1",
		Attack2 = "fists_attack2"
	}
)
add_viewmodel(
	"Brass Knuckles",
	"rbxassetid://106879679389340",
	"rbxassetid://116610825846650",
	nil,
	nil,
	nil,
	nil,
	"fists_equip",
	"fists_idle",
	"fists_sprint",
	"fists_inspect",
	nil,
	{
		Attack1 = "fists_attack1",
		Attack2 = "fists_attack2"
	}
)
add_viewmodel(
	"Pumpkin Claws",
	"rbxassetid://90996407819750",
	"rbxassetid://110587168549532",
	nil,
	nil,
	nil,
	nil,
	"fists_equip",
	"fists_idle",
	"fists_sprint",
	"fists_inspect",
	nil,
	{
		Attack1 = "fists_attack1",
		Attack2 = "fists_attack2"
	}
)
add_viewmodel(
	"Festive Fists",
	"rbxassetid://102757458529795",
	"rbxassetid://98061476050478",
	nil,
	nil,
	nil,
	nil,
	"fists_equip",
	"fists_idle",
	"fists_sprint",
	"fists_inspect",
	nil,
	{
		Attack1 = "fists_attack1",
		Attack2 = "fists_attack2"
	}
)
add_viewmodel(
	"Fists of Hurt",
	"rbxassetid://140103672289959",
	"rbxassetid://71585039030211",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.375),
	"fists_equip",
	"fists_idle",
	"fists_sprint",
	"fists_fistsofhurt_inspect",
	nil,
	{
		Attack1 = "fists_fistsofhurt_attack1",
		Attack2 = "fists_fistsofhurt_attack2"
	}
)
add_viewmodel(
	"Glorious Fists",
	"rbxassetid://112839297231399",
	"rbxassetid://72268337520152",
	nil,
	nil,
	nil,
	nil,
	"fists_equip",
	"fists_idle",
	"fists_sprint",
	"fists_inspect",
	nil,
	{
		Attack1 = "fists_attack1",
		Attack2 = "fists_attack2"
	}
)
add_viewmodel(
	"Fist",
	"rbxassetid://109585706680035",
	"rbxassetid://78704206164484",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(0, 0, (math.rad(20))),
	"fists_fist_equip",
	"fists_fist_idle",
	"fists_fist_sprint",
	"fists_fist_inspect",
	nil,
	{
		Attack1 = "fists_fist_attack1",
		Attack2 = nil
	}
)
add_viewmodel(
	"Spy Gloves",
	"rbxassetid://117198095640784",
	"rbxassetid://112947025953634",
	nil,
	nil,
	nil,
	nil,
	"fists_equip",
	"fists_idle",
	"fists_sprint",
	"fists_inspect",
	nil,
	{
		Attack1 = "fists_attack1",
		Attack2 = "fists_attack2"
	}
)
add_viewmodel(
	"Pirate Hook",
	"rbxassetid://116717593932616",
	"rbxassetid://97614245490635",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.375),
	"fists_piratehook_equip",
	"fists_piratehook_idle",
	"fists_piratehook_sprint",
	"fists_piratehook_inspect",
	nil,
	{
		Attack1 = "fists_piratehook_attack1",
		Attack2 = "fists_piratehook_attack2"
	}
)
add_viewmodel(
	"Crab Claws",
	"rbxassetid://127492118111080",
	"rbxassetid://71811592012118",
	nil,
	nil,
	nil,
	nil,
	"fists_crabclaws_equip",
	"fists_crabclaws_idle",
	"fists_crabclaws_sprint",
	"fists_crabclaws_inspect",
	nil,
	{
		Attack1 = "fists_crabclaws_attack1",
		Attack2 = "fists_crabclaws_attack2"
	}
)
add_viewmodel(
	"Knife",
	"rbxassetid://17160800983",
	"rbxassetid://13197583583",
	nil,
	"rbxassetid://86335100734691",
	2,
	nil,
	"knife_equip",
	"knife_idle",
	"knife_sprint",
	"knife_inspect",
	"knife_inspect_rare",
	{
		Attack1 = "knife_attack1",
		Attack2 = "knife_attack2",
		HeavyAttack1 = "knife_heavyattack1",
		HeavyAttackAnimationHit = nil
	}
)
add_viewmodel(
	"Chancla",
	"rbxassetid://17672060795",
	"rbxassetid://17672089600",
	nil,
	nil,
	nil,
	nil,
	"knife_equip",
	"knife_idle",
	"knife_sprint",
	"knife_inspect",
	"knife_inspect_rare",
	{
		Attack1 = "knife_attack1",
		Attack2 = "knife_attack2",
		HeavyAttack1 = "knife_heavyattack1",
		HeavyAttackAnimationHit = nil
	}
)
add_viewmodel(
	"Karambit",
	"rbxassetid://18766863586",
	"rbxassetid://18766907079",
	nil,
	nil,
	nil,
	nil,
	"knife_karambit_equip",
	"knife_karambit_idle",
	"knife_karambit_sprint",
	"knife_karambit_inspect",
	nil,
	{
		Attack1 = "knife_karambit_attack1",
		Attack2 = "knife_karambit_attack2",
		HeavyAttack1 = "knife_karambit_heavyattack1",
		HeavyAttackAnimationHit = "knife_karambit_heavyattack_hit"
	}
)
add_viewmodel(
	"Machete",
	"rbxassetid://84364955819899",
	"rbxassetid://90332754966135",
	nil,
	nil,
	nil,
	nil,
	"knife_equip",
	"knife_idle",
	"knife_sprint",
	"knife_inspect",
	"knife_inspect_rare",
	{
		Attack1 = "knife_attack1",
		Attack2 = "knife_attack2",
		HeavyAttack1 = "knife_heavyattack1",
		HeavyAttackAnimationHit = nil
	}
)
add_viewmodel(
	"Candy Cane",
	"rbxassetid://124021545052910",
	"rbxassetid://84302121354096",
	nil,
	nil,
	nil,
	nil,
	"knife_karambit_equip",
	"knife_karambit_idle",
	"knife_karambit_sprint",
	"knife_karambit_inspect",
	nil,
	{
		Attack1 = "knife_karambit_attack1",
		Attack2 = "knife_karambit_attack2",
		HeavyAttack1 = "knife_karambit_heavyattack1",
		HeavyAttackAnimationHit = "knife_karambit_heavyattack_hit"
	}
)
add_viewmodel(
	"Balisong",
	"rbxassetid://93303458333011",
	"rbxassetid://114825371645118",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.25),
	"knife_balisong_equip",
	"knife_balisong_idle",
	"knife_balisong_sprint",
	"knife_balisong_inspect",
	nil,
	{
		Attack1 = "knife_balisong_attack1",
		Attack2 = "knife_balisong_attack2",
		HeavyAttack1 = "knife_balisong_heavyattack1",
		HeavyAttackAnimationHit = "knife_balisong_heavyattack_hit"
	}
)
add_viewmodel(
	"Armature.001",
	"rbxassetid://104026327618871",
	"rbxassetid://91555068782550",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.25),
	"knife_balisong_equip",
	"knife_balisong_idle",
	"knife_balisong_sprint",
	"knife_balisong_inspect",
	nil,
	{
		Attack1 = "knife_balisong_attack1",
		Attack2 = "knife_balisong_attack2",
		HeavyAttack1 = "knife_balisong_heavyattack1",
		HeavyAttackAnimationHit = "knife_armature001_heavyattack_hit"
	}
)
add_viewmodel(
	"Glorious Knife",
	"rbxassetid://77448895595314",
	"rbxassetid://122760026905111",
	nil,
	nil,
	nil,
	nil,
	"knife_equip",
	"knife_idle",
	"knife_sprint",
	"knife_inspect",
	"knife_inspect_rare",
	{
		Attack1 = "knife_attack1",
		Attack2 = "knife_attack2",
		HeavyAttack1 = "knife_heavyattack1",
		HeavyAttackAnimationHit = nil
	}
)
add_viewmodel(
	"Keyrambit",
	"rbxassetid://108512337101248",
	"rbxassetid://73252950434501",
	nil,
	nil,
	nil,
	nil,
	"knife_keyrambit_equip",
	"knife_karambit_idle",
	"knife_karambit_sprint",
	"knife_karambit_inspect",
	nil,
	{
		Attack1 = "knife_keyrambit_attack1",
		Attack2 = "knife_keyrambit_attack2",
		HeavyAttack1 = "knife_keyrambit_heavyattack1",
		HeavyAttackAnimationHit = "knife_keyrambit_heavyattack_hit"
	}
)
add_viewmodel(
	"Keylisong",
	"rbxassetid://100084654831857",
	"rbxassetid://118944160521617",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.25),
	"knife_keylisong_equip",
	"knife_balisong_idle",
	"knife_balisong_sprint",
	"knife_keylisong_inspect",
	nil,
	{
		Attack1 = "knife_keylisong_attack1",
		Attack2 = "knife_keylisong_attack2",
		HeavyAttack1 = "knife_keylisong_heavyattack1",
		HeavyAttackAnimationHit = "knife_keylisong_heavyattack_hit"
	}
)
add_viewmodel(
	"Caladbolg",
	"rbxassetid://101180142582964",
	"rbxassetid://72181228743456",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.25),
	"knife_caladbolg_equip",
	"knife_caladbolg_idle",
	"knife_caladbolg_sprint",
	"knife_caladbolg_inspect",
	nil,
	{
		Attack1 = "knife_caladbolg_attack1",
		Attack2 = "knife_caladbolg_attack2",
		HeavyAttack1 = "knife_caladbolg_heavyattack1",
		HeavyAttackAnimationHit = "knife_caladbolg_heavyattack_hit"
	}
)
add_viewmodel(
	"Pencil",
	"rbxassetid://131450909376802",
	"rbxassetid://70869179257286",
	nil,
	nil,
	nil,
	nil,
	"knife_pencil_equip",
	"knife_pencil_idle",
	"knife_pencil_sprint",
	"knife_pencil_inspect",
	nil,
	{
		Attack1 = "knife_pencil_attack1",
		Attack2 = "knife_pencil_attack2",
		HeavyAttack1 = "knife_pencil_heavyattack1",
		HeavyAttackAnimationHit = "knife_pencil_heavyattack_hit"
	}
)
add_viewmodel(
	"Birthday Candle",
	"rbxassetid://74148583096733",
	"rbxassetid://83325442238415",
	nil,
	nil,
	nil,
	nil,
	"knife_equip",
	"knife_birthdaycandle_idle",
	"knife_sprint",
	"knife_inspect",
	"knife_inspect_rare",
	{
		Attack1 = "knife_birthdaycandle_attack1",
		Attack2 = "knife_birthdaycandle_attack2",
		HeavyAttack1 = "knife_birthdaycandle_heavyattack1",
		HeavyAttackAnimationHit = nil
	}
)
add_viewmodel(
	"Shark Tooth",
	"rbxassetid://124265657652842",
	"rbxassetid://129966569376566",
	nil,
	nil,
	nil,
	nil,
	"knife_equip",
	"knife_idle",
	"knife_sprint",
	"knife_inspect",
	"knife_inspect_rare",
	{
		Attack1 = "knife_attack1",
		Attack2 = "knife_attack2",
		HeavyAttack1 = "knife_heavyattack1",
		HeavyAttackAnimationHit = nil
	}
)
add_viewmodel(
	"Trophy Knife",
	"rbxassetid://78822531823097",
	"rbxassetid://88522490384925",
	nil,
	nil,
	nil,
	nil,
	"knife_equip",
	"knife_idle",
	"knife_sprint",
	"knife_inspect",
	"knife_inspect_rare",
	{
		Attack1 = "knife_attack1",
		Attack2 = "knife_attack2",
		HeavyAttack1 = "knife_heavyattack1",
		HeavyAttackAnimationHit = nil
	}
)
add_viewmodel(
	"Chainsaw",
	"rbxassetid://17160801873",
	"rbxassetid://13717445410",
	nil,
	"rbxassetid://81316332892810",
	2.75,
	nil,
	"chainsaw_equip",
	"chainsaw_idle",
	"chainsaw_sprint",
	"chainsaw_inspect",
	nil,
	{
		Attack1 = "chainsaw_attack1",
		Attack2 = "chainsaw_attack2",
		HoldStart = "chainsaw_hold_start",
		HoldLoop = "chainsaw_hold_loop",
		HoldFinish = "chainsaw_hold_finish"
	}
)
add_viewmodel(
	"Blobsaw",
	"rbxassetid://17825963589",
	"rbxassetid://17825961425",
	nil,
	nil,
	nil,
	nil,
	"chainsaw_equip",
	"chainsaw_idle",
	"chainsaw_sprint",
	"chainsaw_inspect",
	nil,
	{
		Attack1 = "chainsaw_attack1",
		Attack2 = "chainsaw_attack2",
		HoldStart = "chainsaw_hold_start",
		HoldLoop = "chainsaw_hold_loop",
		HoldFinish = "chainsaw_hold_finish"
	}
)
add_viewmodel(
	"Handsaws",
	"rbxassetid://18766864583",
	"rbxassetid://18769002596",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.5),
	"chainsaw_handsaws_equip",
	"chainsaw_handsaws_idle",
	"chainsaw_handsaws_sprint",
	"chainsaw_handsaws_inspect",
	nil,
	{
		Attack1 = "chainsaw_handsaws_attack1",
		Attack2 = "chainsaw_handsaws_attack2",
		HoldStart = "chainsaw_handsaws_hold_start",
		HoldLoop = "chainsaw_handsaws_hold_loop",
		HoldFinish = "chainsaw_handsaws_hold_finish"
	}
)
add_viewmodel(
	"Buzzsaw",
	"rbxassetid://74057448201836",
	"rbxassetid://128354991167944",
	nil,
	nil,
	nil,
	CFrame.new(0, 0.125, -0.125),
	"chainsaw_buzzsaw_equip",
	"chainsaw_buzzsaw_idle",
	"chainsaw_buzzsaw_sprint",
	"chainsaw_buzzsaw_inspect",
	nil,
	{
		Attack1 = "chainsaw_buzzsaw_attack1",
		Attack2 = "chainsaw_buzzsaw_attack2",
		HoldStart = "chainsaw_buzzsaw_hold_start",
		HoldLoop = "chainsaw_buzzsaw_hold_loop",
		HoldFinish = "chainsaw_buzzsaw_hold_finish"
	}
)
add_viewmodel(
	"Festive Buzzsaw",
	"rbxassetid://80811854818775",
	"rbxassetid://111566667788893",
	nil,
	nil,
	nil,
	CFrame.new(0, 0.125, -0.125),
	"chainsaw_buzzsaw_equip",
	"chainsaw_buzzsaw_idle",
	"chainsaw_buzzsaw_sprint",
	"chainsaw_buzzsaw_inspect",
	nil,
	{
		Attack1 = "chainsaw_buzzsaw_attack1",
		Attack2 = "chainsaw_buzzsaw_attack2",
		HoldStart = "chainsaw_buzzsaw_hold_start",
		HoldLoop = "chainsaw_buzzsaw_hold_loop",
		HoldFinish = "chainsaw_buzzsaw_hold_finish"
	}
)
add_viewmodel(
	"Mega Drill",
	"rbxassetid://76663867023998",
	"rbxassetid://78828669740807",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.25),
	"chainsaw_megadrill_equip",
	"chainsaw_megadrill_idle",
	"chainsaw_megadrill_sprint",
	"chainsaw_megadrill_inspect",
	nil,
	{
		Attack1 = "chainsaw_megadrill_attack1",
		Attack2 = "chainsaw_megadrill_attack2",
		HoldStart = "chainsaw_megadrill_hold_start",
		HoldLoop = "chainsaw_megadrill_hold_loop",
		HoldFinish = "chainsaw_megadrill_hold_finish"
	}
)
add_viewmodel(
	"Glorious Chainsaw",
	"rbxassetid://122622447397834",
	"rbxassetid://140353527719287",
	nil,
	nil,
	nil,
	nil,
	"chainsaw_equip",
	"chainsaw_idle",
	"chainsaw_sprint",
	"chainsaw_inspect",
	nil,
	{
		Attack1 = "chainsaw_attack1",
		Attack2 = "chainsaw_attack2",
		HoldStart = "chainsaw_hold_start",
		HoldLoop = "chainsaw_hold_loop",
		HoldFinish = "chainsaw_hold_finish"
	}
)
add_viewmodel(
	"Sharksaw",
	"rbxassetid://136881251000627",
	"rbxassetid://103400035987179",
	nil,
	nil,
	nil,
	nil,
	"chainsaw_equip",
	"chainsaw_idle",
	"chainsaw_sprint",
	"chainsaw_inspect",
	nil,
	{
		Attack1 = "chainsaw_attack1",
		Attack2 = "chainsaw_attack2",
		HoldStart = "chainsaw_hold_start",
		HoldLoop = "chainsaw_hold_loop",
		HoldFinish = "chainsaw_hold_finish"
	}
)
add_viewmodel(
	"Katana",
	"rbxassetid://17160801158",
	"rbxassetid://13968137196",
	nil,
	"rbxassetid://94254432866649",
	3,
	CFrame.new(0, -0.125, -0.25),
	"katana_equip",
	"katana_idle",
	"katana_sprint2",
	"katana_inspect",
	"katana_inspect_rare",
	{
		Attack1 = "katana_attack1",
		Attack2 = "katana_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_deflect_idle",
		Deflect1 = "katana_deflect1",
		Deflect2 = "katana_deflect2",
		Deflect3 = "katana_deflect3",
		Deflect4 = "katana_deflect4",
		Deflect5 = "katana_deflect5"
	}
)
add_viewmodel(
	"Saber",
	"rbxassetid://17672062341",
	"rbxassetid://17672087756",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"katana_saber_equip",
	"katana_idle",
	"katana_sprint2",
	"katana_saber_inspect",
	"katana_saber_inspect_rare",
	{
		Attack1 = "katana_saber_attack1",
		Attack2 = "katana_saber_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_saber_deflect_idle",
		Deflect1 = "katana_deflect1",
		Deflect2 = "katana_deflect2",
		Deflect3 = "katana_deflect3",
		Deflect4 = "katana_deflect4",
		Deflect5 = "katana_deflect5"
	}
)
add_viewmodel(
	"Lightning Bolt",
	"rbxassetid://18768968241",
	"rbxassetid://18769002278",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"katana_lightningbolt_equip",
	"katana_idle",
	"katana_sprint2",
	"katana_inspect",
	"katana_lightningbolt_inspect_rare",
	{
		Attack1 = "katana_lightningbolt_attack1",
		Attack2 = "katana_lightningbolt_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_lightningbolt_deflect_idle",
		Deflect1 = "katana_deflect1",
		Deflect2 = "katana_deflect2",
		Deflect3 = "katana_deflect3",
		Deflect4 = "katana_deflect4",
		Deflect5 = "katana_deflect5"
	}
)
add_viewmodel(
	"Pixel Katana",
	"rbxassetid://127922483074145",
	"rbxassetid://83686692916164",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"katana_pixelkatana_equip",
	"katana_pixelkatana_idle",
	"katana_pixelkatana_sprint",
	"katana_pixelkatana_inspect",
	"katana_pixelkatana_inspect_rare",
	{
		Attack1 = "katana_pixelkatana_attack1",
		Attack2 = "katana_pixelkatana_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_pixelkatana_deflect_idle",
		Deflect1 = "katana_deflect1",
		Deflect2 = "katana_deflect2",
		Deflect3 = "katana_deflect3",
		Deflect4 = "katana_deflect4",
		Deflect5 = "katana_deflect5"
	},
	{
		FramesPerSecond = 2,
		PlayAnimationsInstantly = true
	}
)
add_viewmodel(
	"Evil Trident",
	"rbxassetid://101234805269080",
	"rbxassetid://91973056969213",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"katana_equip",
	"katana_idle",
	"katana_sprint2",
	"katana_inspect",
	"katana_inspect_rare",
	{
		Attack1 = "katana_eviltrident_attack1",
		Attack2 = "katana_eviltrident_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_deflect_idle",
		Deflect1 = "katana_deflect1",
		Deflect2 = "katana_deflect2",
		Deflect3 = "katana_deflect3",
		Deflect4 = "katana_deflect4",
		Deflect5 = "katana_deflect5"
	}
)
add_viewmodel(
	"New Year Katana",
	"rbxassetid://102866488046710",
	"rbxassetid://79288379571855",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"katana_equip",
	"katana_idle",
	"katana_sprint2",
	"katana_inspect",
	"katana_inspect_rare",
	{
		Attack1 = "katana_attack1",
		Attack2 = "katana_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_deflect_idle",
		Deflect1 = "katana_deflect1",
		Deflect2 = "katana_deflect2",
		Deflect3 = "katana_deflect3",
		Deflect4 = "katana_deflect4",
		Deflect5 = "katana_deflect5"
	}
)
add_viewmodel(
	"Keytana",
	"rbxassetid://118899310989170",
	"rbxassetid://120478111112813",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"katana_keytana_equip",
	"katana_keytana_idle",
	"katana_keytana_sprint",
	"katana_keytana_inspect",
	"katana_keytana_inspect_rare",
	{
		Attack1 = "katana_keytana_attack1",
		Attack2 = "katana_keytana_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_keytana_deflect_idle",
		Deflect1 = "katana_keytana_deflect1",
		Deflect2 = "katana_keytana_deflect2",
		Deflect3 = "katana_keytana_deflect3"
	}
)
add_viewmodel(
	"Stellar Katana",
	"rbxassetid://72617738655198",
	"rbxassetid://90901679194899",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"katana_equip",
	"katana_idle",
	"katana_sprint2",
	"katana_inspect",
	"katana_inspect_rare",
	{
		Attack1 = "katana_attack1",
		Attack2 = "katana_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_deflect_idle",
		Deflect1 = "katana_deflect1",
		Deflect2 = "katana_deflect2",
		Deflect3 = "katana_deflect3",
		Deflect4 = "katana_deflect4",
		Deflect5 = "katana_deflect5"
	}
)
add_viewmodel(
	"Glorious Katana",
	"rbxassetid://75588958786035",
	"rbxassetid://94429900086533",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"katana_equip",
	"katana_idle",
	"katana_sprint2",
	"katana_inspect",
	"katana_inspect_rare",
	{
		Attack1 = "katana_attack1",
		Attack2 = "katana_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_deflect_idle",
		Deflect1 = "katana_deflect1",
		Deflect2 = "katana_deflect2",
		Deflect3 = "katana_deflect3",
		Deflect4 = "katana_deflect4",
		Deflect5 = "katana_deflect5"
	}
)
add_viewmodel(
	"Arch Katana",
	"rbxassetid://94679283541658",
	"rbxassetid://98068422294741",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.375),
	"katana_archkatana_equip",
	"katana_archkatana_idle",
	"katana_archkatana_sprint",
	"katana_archkatana_inspect",
	"katana_archkatana_inspect_rare",
	{
		Attack1 = "katana_archkatana_attack1",
		Attack2 = "katana_archkatana_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_archkatana_deflect_idle",
		Deflect1 = "katana_archkatana_deflect1",
		Deflect2 = "katana_archkatana_deflect2",
		Deflect3 = "katana_archkatana_deflect3",
		Deflect4 = "katana_archkatana_deflect4",
		Deflect5 = "katana_archkatana_deflect5"
	}
)
add_viewmodel(
	"Crystal Katana",
	"rbxassetid://88872493010693",
	"rbxassetid://107573852829996",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"katana_crystalkatana_equip",
	"katana_crystalkatana_idle",
	"katana_crystalkatana_sprint",
	"katana_crystalkatana_inspect",
	"katana_crystalkatana_inspect_rare",
	{
		Attack1 = "katana_crystalkatana_attack1",
		Attack2 = "katana_crystalkatana_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_crystalkatana_deflect_idle",
		Deflect1 = "katana_crystalkatana_deflect1",
		Deflect2 = "katana_crystalkatana_deflect2",
		Deflect3 = "katana_crystalkatana_deflect3",
		Deflect4 = "katana_crystalkatana_deflect4",
		Deflect5 = "katana_crystalkatana_deflect5"
	}
)
add_viewmodel(
	"Linked Sword",
	"rbxassetid://83575725004177",
	"rbxassetid://131281564276137",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"katana_linkedsword_equip",
	"katana_idle",
	"katana_sprint2",
	"katana_linkedsword_inspect",
	"katana_linkedsword_inspect_rare",
	{
		Attack1 = "katana_linkedsword_attack1",
		Attack2 = "katana_linkedsword_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_linkedsword_deflect_idle",
		Deflect1 = "katana_deflect1",
		Deflect2 = "katana_deflect2",
		Deflect3 = "katana_deflect3",
		Deflect4 = "katana_deflect4",
		Deflect5 = "katana_deflect5"
	}
)
add_viewmodel(
	"Cutlass",
	"rbxassetid://77773371747122",
	"rbxassetid://92434199424881",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.25),
	"katana_cutlass_equip",
	"katana_cutlass_idle",
	"katana_cutlass_sprint",
	"katana_cutlass_inspect",
	"katana_cutlass_inspect_rare",
	{
		Attack1 = "katana_cutlass_attack1",
		Attack2 = "katana_cutlass_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_cutlass_deflect_idle",
		Deflect1 = "katana_cutlass_deflect1",
		Deflect2 = "katana_cutlass_deflect2",
		Deflect3 = "katana_cutlass_deflect3",
		Deflect4 = "katana_cutlass_deflect4",
		Deflect5 = "katana_cutlass_deflect5",
		Deflect6 = "katana_cutlass_deflect5"
	}
)
add_viewmodel(
	"Riptide Katana",
	"rbxassetid://136245206320139",
	"rbxassetid://92795187640191",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.25),
	"katana_riptidekatana_equip",
	"katana_riptidekatana_idle",
	"katana_riptidekatana_sprint",
	"katana_riptidekatana_inspect",
	"katana_riptidekatana_inspect_rare",
	{
		Attack1 = "katana_riptidekatana_attack1",
		Attack2 = "katana_riptidekatana_attack2",
		Attack3 = "katana_riptidekatana_attack3",
		DeflectIdle = "katana_riptidekatana_deflect_idle",
		Deflect1 = "katana_riptidekatana_deflect1",
		Deflect2 = "katana_riptidekatana_deflect2",
		Deflect3 = "katana_riptidekatana_deflect3",
		Deflect4 = "katana_riptidekatana_deflect4",
		Deflect5 = "katana_riptidekatana_deflect5"
	}
)
add_viewmodel(
	"Swordfish",
	"rbxassetid://105748422389590",
	"rbxassetid://83041177417961",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"katana_equip",
	"katana_idle",
	"katana_sprint2",
	"katana_inspect",
	"katana_inspect_rare",
	{
		Attack1 = "katana_attack1",
		Attack2 = "katana_attack2",
		Attack3 = nil,
		DeflectIdle = "katana_deflect_idle",
		Deflect1 = "katana_deflect1",
		Deflect2 = "katana_deflect2",
		Deflect3 = "katana_deflect3",
		Deflect4 = "katana_deflect4",
		Deflect5 = "katana_deflect5"
	}
)
add_viewmodel(
	"Scythe",
	"rbxassetid://17160800186",
	"rbxassetid://13834995858",
	"rbxassetid://18200943790",
	"rbxassetid://129311929685726",
	2,
	nil,
	"scythe_equip",
	"scythe_idle",
	"scythe_sprint",
	"scythe_inspect",
	nil,
	{
		Attack1 = "scythe_attack1",
		Attack2 = "scythe_attack2",
		Dash = nil
	}
)
add_viewmodel(
	"Scythe of Death",
	"rbxassetid://17825996537",
	"rbxassetid://17825961272",
	nil,
	nil,
	nil,
	nil,
	"scythe_equip",
	"scythe_idle",
	"scythe_sprint",
	"scythe_inspect",
	nil,
	{
		Attack1 = "scythe_attack1",
		Attack2 = "scythe_attack2",
		Dash = nil
	}
)
add_viewmodel(
	"Anchor",
	"rbxassetid://18766866743",
	"rbxassetid://18769023932",
	nil,
	nil,
	nil,
	nil,
	"scythe_equip",
	"scythe_idle",
	"scythe_sprint",
	"scythe_inspect",
	nil,
	{
		Attack1 = "scythe_anchor_attack1",
		Attack2 = "scythe_anchor_attack2",
		Dash = nil
	}
)
add_viewmodel(
	"Keythe",
	"rbxassetid://114560926055433",
	"rbxassetid://75967374711732",
	nil,
	nil,
	nil,
	nil,
	"scythe_keythe_equip",
	"scythe_idle",
	"scythe_sprint",
	"scythe_inspect",
	nil,
	{
		Attack1 = "scythe_keythe_attack1",
		Attack2 = "scythe_keythe_attack2",
		Dash = nil
	}
)
add_viewmodel(
	"Bat Scythe",
	"rbxassetid://131711174838548",
	"rbxassetid://104168535403995",
	nil,
	nil,
	nil,
	nil,
	"scythe_equip",
	"scythe_idle",
	"scythe_sprint",
	"scythe_inspect",
	nil,
	{
		Attack1 = "scythe_batscythe_attack1",
		Attack2 = "scythe_batscythe_attack2",
		Dash = nil
	}
)
add_viewmodel(
	"Cryo Scythe",
	"rbxassetid://119930754357379",
	"rbxassetid://84690820919174",
	nil,
	nil,
	nil,
	nil,
	"scythe_cryoscythe_equip",
	"scythe_idle",
	"scythe_sprint",
	"scythe_inspect",
	nil,
	{
		Attack1 = "scythe_cryoscythe_attack1",
		Attack2 = "scythe_cryoscythe_attack2",
		Dash = nil
	}
)
add_viewmodel(
	"Bug Net",
	"rbxassetid://115620701626004",
	"rbxassetid://99173928762511",
	nil,
	nil,
	nil,
	nil,
	"scythe_bugnet_equip",
	"scythe_bugnet_idle",
	"scythe_bugnet_sprint",
	"scythe_bugnet_inspect",
	nil,
	{
		Attack1 = "scythe_bugnet_attack1",
		Attack2 = "scythe_bugnet_attack2",
		Dash = nil
	}
)
add_viewmodel(
	"Sakura Scythe",
	"rbxassetid://133811689655966",
	"rbxassetid://115063494552764",
	nil,
	nil,
	nil,
	nil,
	"scythe_equip",
	"scythe_idle",
	"scythe_sprint",
	"scythe_inspect",
	nil,
	{
		Attack1 = "scythe_sakurascythe_attack1",
		Attack2 = "scythe_sakurascythe_attack2",
		Dash = nil
	}
)
add_viewmodel(
	"Glorious Scythe",
	"rbxassetid://115811939422419",
	"rbxassetid://113721128462866",
	nil,
	nil,
	nil,
	nil,
	"scythe_equip",
	"scythe_idle",
	"scythe_sprint",
	"scythe_inspect",
	nil,
	{
		Attack1 = "scythe_attack1",
		Attack2 = "scythe_attack2",
		Dash = nil
	}
)
add_viewmodel(
	"Crystal Scythe",
	"rbxassetid://73971549402646",
	"rbxassetid://88778703942724",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, 0),
	"scythe_crystalscythe_equip",
	"scythe_crystalscythe_idle",
	"scythe_crystalscythe_sprint",
	"scythe_crystalscythe_inspect",
	nil,
	{
		Attack1 = "scythe_crystalscythe_attack1",
		Attack2 = "scythe_crystalscythe_attack2",
		Dash = "scythe_crystalscythe_dash"
	}
)
add_viewmodel(
	"Palm Scythe",
	"rbxassetid://97379805071194",
	"rbxassetid://100772860594083",
	nil,
	nil,
	nil,
	CFrame.new(0, -1, 0),
	"scythe_palmscythe_equip",
	"scythe_palmscythe_idle",
	"scythe_palmscythe_sprint",
	"scythe_palmscythe_inspect",
	nil,
	{
		Attack1 = "scythe_palmscythe_attack1",
		Attack2 = "scythe_palmscythe_attack2",
		Dash = "scythe_palmscythe_dash"
	}
)
add_viewmodel(
	"Plastic Flamingo",
	"rbxassetid://112023194890462",
	"rbxassetid://106304321940736",
	nil,
	nil,
	nil,
	nil,
	"scythe_equip",
	"scythe_idle",
	"scythe_sprint",
	"scythe_inspect",
	nil,
	{
		Attack1 = "scythe_attack1",
		Attack2 = "scythe_attack2",
		Dash = nil
	}
)
add_viewmodel(
	"Trowel",
	"rbxassetid://17160799172",
	"rbxassetid://16560547384",
	nil,
	"rbxassetid://103642431355604",
	1.5,
	CFrame.new(0, -0.25, -0.375),
	"trowel_equip",
	"trowel_idle",
	"trowel_sprint",
	"trowel_inspect",
	nil,
	{
		Attack1 = "trowel_attack1",
		Attack2 = "trowel_attack2",
		Build = "trowel_build"
	}
)
add_viewmodel(
	"Plastic Shovel",
	"rbxassetid://17672062201",
	"rbxassetid://17672088012",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"trowel_equip",
	"trowel_idle",
	"trowel_sprint",
	"trowel_inspect",
	nil,
	{
		Attack1 = "trowel_attack1",
		Attack2 = "trowel_attack2",
		Build = "trowel_build"
	}
)
add_viewmodel(
	"Garden Shovel",
	"rbxassetid://18766864873",
	"rbxassetid://18766908058",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"trowel_equip",
	"trowel_idle",
	"trowel_sprint",
	"trowel_inspect",
	nil,
	{
		Attack1 = "trowel_attack1",
		Attack2 = "trowel_attack2",
		Build = "trowel_build"
	}
)
add_viewmodel(
	"Pumpkin Carver",
	"rbxassetid://78827307308671",
	"rbxassetid://130169648063116",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"trowel_equip",
	"trowel_idle",
	"trowel_sprint",
	"trowel_inspect",
	nil,
	{
		Attack1 = "trowel_attack1",
		Attack2 = "trowel_attack2",
		Build = "trowel_build"
	}
)
add_viewmodel(
	"Snow Shovel",
	"rbxassetid://78271338778848",
	"rbxassetid://96400887574950",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"trowel_equip",
	"trowel_idle",
	"trowel_sprint",
	"trowel_inspect",
	nil,
	{
		Attack1 = "trowel_attack1",
		Attack2 = "trowel_attack2",
		Build = "trowel_build"
	}
)
add_viewmodel(
	"Paintbrush",
	"rbxassetid://84687920829755",
	"rbxassetid://83196688094998",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"trowel_equip",
	"trowel_idle",
	"trowel_sprint",
	"trowel_inspect",
	nil,
	{
		Attack1 = "trowel_attack1",
		Attack2 = "trowel_attack2",
		Build = "trowel_build"
	}
)
add_viewmodel(
	"Glorious Trowel",
	"rbxassetid://100888500368219",
	"rbxassetid://132433921578446",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"trowel_equip",
	"trowel_idle",
	"trowel_sprint",
	"trowel_inspect",
	nil,
	{
		Attack1 = "trowel_attack1",
		Attack2 = "trowel_attack2",
		Build = "trowel_build"
	}
)
add_viewmodel(
	"Scooper",
	"rbxassetid://100816728062854",
	"rbxassetid://104183807294971",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"trowel_equip",
	"trowel_idle",
	"trowel_sprint",
	"trowel_inspect",
	nil,
	{
		Attack1 = "trowel_attack1",
		Attack2 = "trowel_attack2",
		Build = "trowel_build"
	}
)
add_viewmodel(
	"Flare Gun",
	"rbxassetid://17160801627",
	"rbxassetid://13197583892",
	nil,
	"rbxassetid://113217458668564",
	1.5,
	CFrame.new(0, -0.125, -0.25),
	"flaregun_equip",
	"flaregun_idle",
	"flaregun_sprint",
	"flaregun_inspect",
	nil,
	{
		Shoot1 = "flaregun_shoot1",
		FinalShoot = nil,
		Reload = "flaregun_reload",
		EmptyReload = nil,
		EquipEmpty = "flaregun_equip_empty",
		IdleEmpty = "flaregun_idle_empty",
		SprintEmpty = "flaregun_sprint_empty",
		InspectEmpty = "flaregun_inspect_empty"
	}
)
add_viewmodel(
	"Firework Gun",
	"rbxassetid://17691132917",
	"rbxassetid://17691136322",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"flaregun_equip",
	"flaregun_idle",
	"flaregun_sprint",
	"flaregun_inspect",
	nil,
	{
		Shoot1 = "flaregun_shoot1",
		FinalShoot = nil,
		Reload = "flaregun_reload",
		EmptyReload = nil,
		EquipEmpty = "flaregun_equip_empty",
		IdleEmpty = "flaregun_idle_empty",
		SprintEmpty = "flaregun_sprint_empty",
		InspectEmpty = "flaregun_inspect_empty"
	}
)
add_viewmodel(
	"Dynamite Gun",
	"rbxassetid://18766865384",
	"rbxassetid://18766908547",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"flaregun_equip",
	"flaregun_idle",
	"flaregun_sprint",
	"flaregun_inspect",
	nil,
	{
		Shoot1 = "flaregun_dynamitegun_shoot1",
		FinalShoot = nil,
		Reload = "flaregun_reload",
		EmptyReload = nil,
		EquipEmpty = "flaregun_equip_empty",
		IdleEmpty = "flaregun_idle_empty",
		SprintEmpty = "flaregun_sprint_empty",
		InspectEmpty = "flaregun_inspect_empty"
	}
)
add_viewmodel(
	"Vexed Flare Gun",
	"rbxassetid://116287930550049",
	"rbxassetid://138983159218333",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"flaregun_equip",
	"flaregun_idle",
	"flaregun_sprint",
	"flaregun_inspect",
	nil,
	{
		Shoot1 = "flaregun_shoot1",
		FinalShoot = nil,
		Reload = "flaregun_reload",
		EmptyReload = nil,
		EquipEmpty = "flaregun_equip_empty",
		IdleEmpty = "flaregun_idle_empty",
		SprintEmpty = "flaregun_sprint_empty",
		InspectEmpty = "flaregun_inspect_empty"
	}
)
add_viewmodel(
	"Wrapped Flare Gun",
	"rbxassetid://135638020129378",
	"rbxassetid://135904023852615",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"flaregun_wrappedflaregun_equip",
	"flaregun_idle",
	"flaregun_sprint",
	"flaregun_inspect",
	nil,
	{
		Shoot1 = "flaregun_shoot1",
		FinalShoot = nil,
		Reload = "flaregun_reload",
		EmptyReload = nil,
		EquipEmpty = "flaregun_equip_empty",
		IdleEmpty = "flaregun_idle_empty",
		SprintEmpty = "flaregun_sprint_empty",
		InspectEmpty = "flaregun_inspect_empty"
	}
)
add_viewmodel(
	"Banana Flare",
	"rbxassetid://123589213761955",
	"rbxassetid://135246839855870",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"flaregun_bananaflare_equip",
	"flaregun_bananaflare_idle",
	"flaregun_bananaflare_sprint",
	"flaregun_bananaflare_inspect",
	"flaregun_bananaflare_inspect_rare",
	{
		Shoot1 = "flaregun_bananaflare_shoot1",
		FinalShoot = nil,
		Reload = "flaregun_bananaflare_reload",
		EmptyReload = nil,
		EquipEmpty = nil,
		IdleEmpty = nil,
		SprintEmpty = nil,
		InspectEmpty = nil
	}
)
add_viewmodel(
	"Glorious Flare Gun",
	"rbxassetid://115324763672074",
	"rbxassetid://128135635660577",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"flaregun_equip",
	"flaregun_idle",
	"flaregun_sprint",
	"flaregun_inspect",
	nil,
	{
		Shoot1 = "flaregun_shoot1",
		FinalShoot = nil,
		Reload = "flaregun_reload",
		EmptyReload = nil,
		EquipEmpty = "flaregun_equip_empty",
		IdleEmpty = "flaregun_idle_empty",
		SprintEmpty = "flaregun_sprint_empty",
		InspectEmpty = "flaregun_inspect_empty"
	}
)
add_viewmodel(
	"Pocket Volcano",
	"rbxassetid://133260045254190",
	"rbxassetid://132446634091281",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"flaregun_pocketvolcano_equip",
	"flaregun_pocketvolcano_idle",
	"flaregun_pocketvolcano_sprint",
	"flaregun_pocketvolcano_inspect",
	nil,
	{
		Shoot1 = "flaregun_pocketvolcano_shoot1",
		FinalShoot = nil,
		Reload = "flaregun_pocketvolcano_reload",
		EmptyReload = nil,
		EquipEmpty = nil,
		IdleEmpty = nil,
		SprintEmpty = nil,
		InspectEmpty = nil
	}
)
add_viewmodel(
	"Assault Rifle",
	"rbxassetid://17160682738",
	"rbxassetid://13197584241",
	nil,
	"rbxassetid://101393097640802",
	2.5,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"assaultrifle_equip",
	"assaultrifle_idle",
	"assaultrifle_sprint",
	"assaultrifle_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"AK-47",
	"rbxassetid://17691132793",
	"rbxassetid://17691136128",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"assaultrifle_equip",
	"assaultrifle_idle",
	"assaultrifle_sprint",
	"assaultrifle_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_ak47_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Augmented Rifle",
	"rbxassetid://18770192853",
	"rbxassetid://18770201102",
	nil,
	nil,
	nil,
	CFrame.new(0.15, -0.2, -0.25) * CFrame.Angles(0, math.rad(-3), 0),
	"assaultrifle_aug_equip",
	"assaultrifle_aug_idle",
	"assaultrifle_aug_sprint",
	"assaultrifle_aug_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_aug_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_aug_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Boneclaw Rifle",
	"rbxassetid://100015754284323",
	"rbxassetid://116725320040796",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"assaultrifle_equip",
	"assaultrifle_idle",
	"assaultrifle_sprint",
	"assaultrifle_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_boneclawrifle_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"AKEY-47",
	"rbxassetid://80017496220683",
	"rbxassetid://77244120212187",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"assaultrifle_akey47_equip",
	"assaultrifle_idle",
	"assaultrifle_sprint",
	"assaultrifle_akey47_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_akey47_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_akey47_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Gingerbread Augmented Rifle",
	"rbxassetid://85584922619813",
	"rbxassetid://108476862508992",
	nil,
	nil,
	nil,
	CFrame.new(0.15, -0.2, -0.25) * CFrame.Angles(0, math.rad(-3), 0),
	"assaultrifle_gingerbreadaug_equip",
	"assaultrifle_gingerbreadaug_idle",
	"assaultrifle_gingerbreadaug_sprint",
	"assaultrifle_gingerbreadaug_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_gingerbreadaug_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_gingerbreadaug_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Phoenix Rifle",
	"rbxassetid://140228738718621",
	"rbxassetid://115604025497445",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"assaultrifle_equip",
	"assaultrifle_idle",
	"assaultrifle_sprint",
	"assaultrifle_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Drum Gun",
	"rbxassetid://111251887761435",
	"rbxassetid://84369917689099",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"assaultrifle_tommygun_equip",
	"assaultrifle_tommygun_idle",
	"assaultrifle_tommygun_sprint",
	"assaultrifle_tommygun_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_tommygun_shoot1",
		FinalShoot = "assaultrifle_tommygun_shoot_final",
		Reload = "assaultrifle_tommygun_reload",
		EmptyReload = "assaultrifle_tommygun_reload_empty",
		EquipEmpty = "assaultrifle_tommygun_equip_empty",
		IdleEmpty = "assaultrifle_tommygun_idle_empty",
		SprintEmpty = "assaultrifle_tommygun_sprint_empty",
		InspectEmpty = "assaultrifle_tommygun_inspect_empty"
	}
)
add_viewmodel(
	"10B Visits",
	"rbxassetid://122165086598560",
	"rbxassetid://101791753953377",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"assaultrifle_equip",
	"assaultrifle_idle",
	"assaultrifle_sprint",
	"assaultrifle_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Glorious Assault Rifle",
	"rbxassetid://130669996688265",
	"rbxassetid://130592949312939",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"assaultrifle_equip",
	"assaultrifle_idle",
	"assaultrifle_sprint",
	"assaultrifle_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Pearl Rifle",
	"rbxassetid://135277426561503",
	"rbxassetid://103487000984145",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"assaultrifle_equip",
	"assaultrifle_idle",
	"assaultrifle_sprint",
	"assaultrifle_inspect",
	nil,
	{
		Shoot1 = "assaultrifle_pearlrifle_shoot1",
		FinalShoot = nil,
		Reload = "assaultrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Handgun",
	"rbxassetid://17160801282",
	"rbxassetid://13197583693",
	nil,
	"rbxassetid://113347796650411",
	1.5,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_equip",
	"handgun_idle",
	"handgun_sprint",
	"handgun_inspect",
	nil,
	{
		Shoot1 = "handgun_shoot1",
		FinalShoot = "handgun_shoot_final",
		Reload = "handgun_reload",
		EmptyReload = "handgun_reload_empty"
	}
)
add_viewmodel(
	"Blaster",
	"rbxassetid://17821234554",
	"rbxassetid://17821265750",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_equip",
	"handgun_idle",
	"handgun_sprint",
	"handgun_inspect",
	nil,
	{
		Shoot1 = "handgun_blaster_shoot1",
		FinalShoot = "handgun_blaster_shoot_final",
		Reload = "handgun_reload",
		EmptyReload = "handgun_reload_empty"
	}
)
add_viewmodel(
	"Hand Gun",
	"rbxassetid://18837670624",
	"rbxassetid://18837677423",
	nil,
	nil,
	nil,
	CFrame.new(0.25, 0, -0.5) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_handgun_equip",
	"handgun_handgun_idle",
	"handgun_handgun_sprint",
	"handgun_handgun_inspect",
	"handgun_handgun_inspect_rare",
	{
		Shoot1 = "handgun_handgun_shoot1",
		FinalShoot = "handgun_handgun_shoot_final",
		Reload = "handgun_handgun_reload",
		EmptyReload = "handgun_handgun_reload_empty"
	}
)
add_viewmodel(
	"Pixel Handgun",
	"rbxassetid://82199841278177",
	"rbxassetid://72665687846028",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_pixelhandgun_equip",
	"handgun_pixelhandgun_idle",
	"handgun_pixelhandgun_sprint",
	"handgun_pixelhandgun_inspect",
	nil,
	{
		Shoot1 = "handgun_pixelhandgun_shoot1",
		FinalShoot = "handgun_pixelhandgun_shoot_final",
		Reload = "handgun_pixelhandgun_reload",
		EmptyReload = "handgun_pixelhandgun_reload_empty"
	},
	{
		FramesPerSecond = 2,
		PlayAnimationsInstantly = true
	}
)
add_viewmodel(
	"Pumpkin Handgun",
	"rbxassetid://88495685924653",
	"rbxassetid://92824393890642",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_equip",
	"handgun_idle",
	"handgun_sprint",
	"handgun_inspect",
	nil,
	{
		Shoot1 = "handgun_pumpkinhandgun_shoot1",
		FinalShoot = "handgun_pumpkinhandgun_shoot_final",
		Reload = "handgun_reload",
		EmptyReload = "handgun_reload_empty"
	}
)
add_viewmodel(
	"Gingerbread Handgun",
	"rbxassetid://95881238590412",
	"rbxassetid://72714528734588",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_equip",
	"handgun_idle",
	"handgun_sprint",
	"handgun_inspect",
	nil,
	{
		Shoot1 = "handgun_gingerbreadhandgun_shoot1",
		FinalShoot = "handgun_gingerbreadhandgun_shoot_final",
		Reload = "handgun_reload",
		EmptyReload = "handgun_reload_empty"
	}
)
add_viewmodel(
	"Gumball Handgun",
	"rbxassetid://106890990556815",
	"rbxassetid://138794077251754",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_equip",
	"handgun_idle",
	"handgun_sprint",
	"handgun_inspect",
	nil,
	{
		Shoot1 = "handgun_gumballhandgun_shoot1",
		FinalShoot = "handgun_gumballhandgun_shoot_final",
		Reload = "handgun_reload",
		EmptyReload = "handgun_reload_empty"
	}
)
add_viewmodel(
	"Stealth Handgun",
	"rbxassetid://124919185835138",
	"rbxassetid://99321324367928",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_equip",
	"handgun_idle",
	"handgun_sprint",
	"handgun_inspect",
	nil,
	{
		Shoot1 = "handgun_stealthhandgun_shoot1",
		FinalShoot = "handgun_stealthhandgun_shoot_final",
		Reload = "handgun_reload",
		EmptyReload = "handgun_reload_empty"
	}
)
add_viewmodel(
	"Glorious Handgun",
	"rbxassetid://85129427786041",
	"rbxassetid://73041314820303",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_equip",
	"handgun_idle",
	"handgun_sprint",
	"handgun_inspect",
	nil,
	{
		Shoot1 = "handgun_shoot1",
		FinalShoot = "handgun_shoot_final",
		Reload = "handgun_reload",
		EmptyReload = "handgun_reload_empty"
	}
)
add_viewmodel(
	"Warp Handgun",
	"rbxassetid://102974911528828",
	"rbxassetid://117404871573487",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_equip",
	"handgun_idle",
	"handgun_sprint",
	"handgun_inspect",
	nil,
	{
		Shoot1 = "handgun_shoot1",
		FinalShoot = "handgun_shoot_final",
		Reload = "handgun_reload",
		EmptyReload = "handgun_reload_empty"
	}
)
add_viewmodel(
	"Towerstone Handgun",
	"rbxassetid://88654252790032",
	"rbxassetid://116418326352365",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_equip",
	"handgun_idle",
	"handgun_sprint",
	"handgun_inspect",
	nil,
	{
		Shoot1 = "handgun_shoot1",
		FinalShoot = "handgun_shoot_final",
		Reload = "handgun_reload",
		EmptyReload = "handgun_reload_empty"
	}
)
add_viewmodel(
	"Sandgun",
	"rbxassetid://111746039012812",
	"rbxassetid://98739529709778",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"handgun_sandgun_equip",
	"handgun_idle",
	"handgun_sprint",
	"handgun_sandgun_inspect",
	nil,
	{
		Shoot1 = "handgun_sandgun_shoot1",
		FinalShoot = "handgun_sandgun_shoot_final",
		Reload = "handgun_sandgun_reload",
		EmptyReload = "handgun_sandgun_reload_empty"
	}
)
add_viewmodel(
	"Burst Rifle",
	"rbxassetid://17160801983",
	"rbxassetid://13482243466",
	nil,
	"rbxassetid://98231967024816",
	2.5,
	CFrame.new(0, -0.125, 0),
	"burstrifle_equip",
	"burstrifle_idle",
	"burstrifle_sprint",
	"burstrifle_inspect",
	nil,
	{
		Shoot1 = "burstrifle_shoot1",
		FinalShoot = nil,
		Reload = "burstrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Electro Rifle",
	"rbxassetid://132227459821018",
	"rbxassetid://87621360986223",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0),
	"burstrifle_equip",
	"burstrifle_idle",
	"burstrifle_sprint",
	"burstrifle_inspect",
	nil,
	{
		Shoot1 = "burstrifle_electrorifle_shoot1",
		FinalShoot = nil,
		Reload = "burstrifle_electrorifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Aqua Burst",
	"rbxassetid://18837670807",
	"rbxassetid://18837677725",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0),
	"burstrifle_equip",
	"burstrifle_idle",
	"burstrifle_sprint",
	"burstrifle_inspect",
	nil,
	{
		Shoot1 = "burstrifle_aquaburst_shoot1",
		FinalShoot = nil,
		Reload = "burstrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Pixel Burst",
	"rbxassetid://102648809593259",
	"rbxassetid://81440970309830",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0),
	"burstrifle_pixelburst_equip",
	"burstrifle_pixelburst_idle",
	"burstrifle_pixelburst_sprint",
	"burstrifle_pixelburst_inspect",
	nil,
	{
		Shoot1 = "burstrifle_pixelburst_shoot1",
		FinalShoot = nil,
		Reload = "burstrifle_pixelburst_reload",
		EmptyReload = nil
	},
	{
		FramesPerSecond = 2,
		PlayAnimationsInstantly = true
	}
)
add_viewmodel(
	"Spectral Burst",
	"rbxassetid://135012309412679",
	"rbxassetid://135650382469411",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0),
	"burstrifle_equip",
	"burstrifle_idle",
	"burstrifle_sprint",
	"burstrifle_inspect",
	nil,
	{
		Shoot1 = "burstrifle_spectralburst_shoot1",
		FinalShoot = nil,
		Reload = "burstrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Pine Burst",
	"rbxassetid://132753732294083",
	"rbxassetid://100589243117991",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0),
	"burstrifle_equip",
	"burstrifle_idle",
	"burstrifle_sprint",
	"burstrifle_inspect",
	nil,
	{
		Shoot1 = "burstrifle_pineburst_shoot1",
		FinalShoot = nil,
		Reload = "burstrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Bullpup Burst",
	"rbxassetid://74974560606812",
	"rbxassetid://110423034763836",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.25) * CFrame.Angles(0, math.rad(-5), 0),
	"burstrifle_famas_equip",
	"burstrifle_famas_idle",
	"burstrifle_famas_sprint",
	"burstrifle_famas_inspect",
	nil,
	{
		Shoot1 = "burstrifle_famas_shoot1",
		FinalShoot = nil,
		Reload = "burstrifle_famas_reload",
		EmptyReload = "burstrifle_famas_reload_empty"
	}
)
add_viewmodel(
	"Glorious Burst Rifle",
	"rbxassetid://78517330608597",
	"rbxassetid://125258150017244",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0),
	"burstrifle_equip",
	"burstrifle_idle",
	"burstrifle_sprint",
	"burstrifle_inspect",
	nil,
	{
		Shoot1 = "burstrifle_shoot1",
		FinalShoot = nil,
		Reload = "burstrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Keyst Rifle",
	"rbxassetid://78377522426003",
	"rbxassetid://138268719789353",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.5),
	"burstrifle_keystrifle_equip",
	"burstrifle_keystrifle_idle",
	"burstrifle_keystrifle_sprint",
	"burstrifle_keystrifle_inspect",
	nil,
	{
		Shoot1 = "burstrifle_keystrifle_shoot1",
		FinalShoot = nil,
		Reload = "burstrifle_keystrifle_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Sand Bullpup Burst",
	"rbxassetid://130731663986683",
	"rbxassetid://139402443573256",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.25) * CFrame.Angles(0, math.rad(-5), 0),
	"burstrifle_famas_equip",
	"burstrifle_famas_idle",
	"burstrifle_famas_sprint",
	"burstrifle_sandfamas_inspect",
	nil,
	{
		Shoot1 = "burstrifle_sandfamas_shoot1",
		FinalShoot = nil,
		Reload = "burstrifle_sandfamas_reload",
		EmptyReload = "burstrifle_sandfamas_reload_empty"
	}
)
add_viewmodel(
	"Sniper",
	"rbxassetid://17160799574",
	"rbxassetid://13197583098",
	nil,
	"rbxassetid://132853334508822",
	3.25,
	CFrame.new(0, -0.125, -0.125),
	"sniper_equip",
	"sniper_idle",
	"sniper_sprint",
	"sniper_inspect",
	nil,
	{
		Shoot1 = "sniper_shoot1",
		FinalShoot = nil,
		Reload = "sniper_reload",
		EmptyReload = "sniper_reload_empty"
	}
)
add_viewmodel(
	"Pixel Sniper",
	"rbxassetid://17676081196",
	"rbxassetid://17676083400",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"sniper_pixelsniper_equip",
	"sniper_pixelsniper_idle",
	"sniper_pixelsniper_sprint",
	"sniper_pixelsniper_inspect",
	nil,
	{
		Shoot1 = "sniper_pixelsniper_shoot1",
		FinalShoot = nil,
		Reload = "sniper_pixelsniper_reload",
		EmptyReload = "sniper_pixelsniper_reload_empty"
	},
	{
		FramesPerSecond = 2,
		PlayAnimationsInstantly = true
	}
)
add_viewmodel(
	"Hyper Sniper",
	"rbxassetid://18766864081",
	"rbxassetid://18766907266",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"sniper_equip",
	"sniper_idle",
	"sniper_sprint",
	"sniper_inspect",
	nil,
	{
		Shoot1 = "sniper_hypersniper_shoot1",
		FinalShoot = nil,
		Reload = "sniper_reload",
		EmptyReload = "sniper_reload_empty"
	}
)
add_viewmodel(
	"Keyper",
	"rbxassetid://85472935605264",
	"rbxassetid://122634584511896",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"sniper_keyper_equip",
	"sniper_idle",
	"sniper_sprint",
	"sniper_inspect",
	nil,
	{
		Shoot1 = "sniper_keyper_shoot1",
		FinalShoot = nil,
		Reload = "sniper_reload",
		EmptyReload = "sniper_reload_empty"
	}
)
add_viewmodel(
	"Eyething Sniper",
	"rbxassetid://103915302076013",
	"rbxassetid://96377501719526",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"sniper_equip",
	"sniper_idle",
	"sniper_sprint",
	"sniper_inspect",
	nil,
	{
		Shoot1 = "sniper_eyethingsniper_shoot1",
		FinalShoot = nil,
		Reload = "sniper_reload",
		EmptyReload = "sniper_reload_empty"
	}
)
add_viewmodel(
	"Gingerbread Sniper",
	"rbxassetid://99943841952995",
	"rbxassetid://120163896680390",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"sniper_equip",
	"sniper_idle",
	"sniper_sprint",
	"sniper_inspect",
	nil,
	{
		Shoot1 = "sniper_gingerbreadsniper_shoot1",
		FinalShoot = nil,
		Reload = "sniper_reload",
		EmptyReload = "sniper_reload_empty"
	}
)
add_viewmodel(
	"Event Horizon",
	"rbxassetid://80749667426815",
	"rbxassetid://82446563771968",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.25),
	"sniper_eventhorizon_equip",
	"sniper_eventhorizon_idle",
	"sniper_eventhorizon_sprint",
	"sniper_eventhorizon_inspect",
	nil,
	{
		Shoot1 = "sniper_eventhorizon_shoot1",
		FinalShoot = nil,
		Reload = "sniper_eventhorizon_reload",
		EmptyReload = "sniper_eventhorizon_reload_empty"
	}
)
add_viewmodel(
	"Glorious Sniper",
	"rbxassetid://118012090175286",
	"rbxassetid://94794978921271",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"sniper_equip",
	"sniper_idle",
	"sniper_sprint",
	"sniper_inspect",
	nil,
	{
		Shoot1 = "sniper_shoot1",
		FinalShoot = nil,
		Reload = "sniper_reload",
		EmptyReload = "sniper_reload_empty"
	}
)
add_viewmodel(
	"Kraken Sniper",
	"rbxassetid://95011666797584",
	"rbxassetid://99189706803523",
	nil,
	nil,
	nil,
	CFrame.new(-0.125, -0.125, -0.25) * CFrame.Angles(0, math.rad(-10), 0),
	"sniper_krakensniper_equip",
	"sniper_krakensniper_idle",
	"sniper_krakensniper_sprint",
	"sniper_krakensniper_inspect",
	nil,
	{
		Shoot1 = "sniper_krakensniper_shoot1",
		FinalShoot = nil,
		Reload = "sniper_krakensniper_reload",
		EmptyReload = "sniper_krakensniper_reload_empty"
	}
)
add_viewmodel(
	"Campfire Sniper",
	"rbxassetid://127790438907599",
	"rbxassetid://129718669232752",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"sniper_campfiresniper_equip",
	"sniper_idle",
	"sniper_sprint",
	"sniper_campfiresniper_inspect",
	nil,
	{
		Shoot1 = "sniper_shoot1",
		FinalShoot = nil,
		Reload = "sniper_campfiresniper_reload",
		EmptyReload = "sniper_campfiresniper_reload_empty"
	}
)
add_viewmodel(
	"Light Fifty",
	"rbxassetid://138029440298487",
	"rbxassetid://92969788673528",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.25),
	"sniper_lightfifty_equip",
	"sniper_lightfifty_idle",
	"sniper_lightfifty_sprint",
	"sniper_lightfifty_inspect",
	nil,
	{
		Shoot1 = "sniper_lightfifty_shoot1",
		FinalShoot = nil,
		Reload = "sniper_lightfifty_reload",
		EmptyReload = "sniper_lightfifty_reload_empty"
	}
)
add_viewmodel(
	"RPG",
	"rbxassetid://17160802243",
	"rbxassetid://13197583434",
	nil,
	"rbxassetid://95169761396387",
	3.5,
	CFrame.new(0, -0.125, -0.25),
	"rpg_equip",
	"rpg_idle",
	"rpg_sprint",
	"rpg_inspect",
	"rpg_inspect_rare",
	{
		Shoot1 = "rpg_shoot1",
		FinalShoot = nil,
		Reload = "rpg_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Nuke Launcher",
	"rbxassetid://17672061995",
	"rbxassetid://17672088925",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"rpg_equip",
	"rpg_idle",
	"rpg_sprint",
	"rpg_inspect",
	"rpg_inspect_rare",
	{
		Shoot1 = "rpg_shoot1",
		FinalShoot = nil,
		Reload = "rpg_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"RPKEY",
	"rbxassetid://108438721125410",
	"rbxassetid://122750504849596",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"rpg_rpkey_equip",
	"rpg_idle",
	"rpg_sprint",
	"rpg_inspect",
	"rpg_inspect_rare",
	{
		Shoot1 = "rpg_shoot1",
		FinalShoot = nil,
		Reload = "rpg_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Spaceship Launcher",
	"rbxassetid://18766860860",
	"rbxassetid://18766904375",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"rpg_equip",
	"rpg_idle",
	"rpg_sprint",
	"rpg_inspect",
	"rpg_inspect_rare",
	{
		Shoot1 = "rpg_shoot1",
		FinalShoot = nil,
		Reload = "rpg_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Pumpkin Launcher",
	"rbxassetid://94648176067808",
	"rbxassetid://130301464984534",
	nil,
	nil,
	nil,
	CFrame.new(0.375, -0.5, -0.75),
	"rpg_equip",
	"rpg_idle",
	"rpg_sprint",
	"rpg_inspect",
	"rpg_inspect_rare",
	{
		Shoot1 = "rpg_shoot1",
		FinalShoot = nil,
		Reload = "rpg_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Firework Launcher",
	"rbxassetid://75233372670156",
	"rbxassetid://93131277391830",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"rpg_equip",
	"rpg_idle",
	"rpg_sprint",
	"rpg_inspect",
	"rpg_inspect_rare",
	{
		Shoot1 = "rpg_shoot1",
		FinalShoot = nil,
		Reload = "rpg_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Squid Launcher",
	"rbxassetid://130764310743404",
	"rbxassetid://80877003243435",
	nil,
	nil,
	nil,
	CFrame.new(0.125, -0.25, -0.5) * CFrame.Angles(0, math.rad(5), 0),
	"rpg_equip",
	"rpg_idle",
	"rpg_sprint",
	"rpg_inspect",
	"rpg_inspect_rare",
	{
		Shoot1 = "rpg_shoot1",
		FinalShoot = nil,
		Reload = "rpg_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Pencil Launcher",
	"rbxassetid://106934516693548",
	"rbxassetid://74125168400547",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.5) * CFrame.Angles(0, math.rad(5), 0),
	"rpg_equip",
	"rpg_idle",
	"rpg_sprint",
	"rpg_inspect",
	"rpg_inspect_rare",
	{
		Shoot1 = "rpg_shoot1",
		FinalShoot = nil,
		Reload = "rpg_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Glorious RPG",
	"rbxassetid://130506879885802",
	"rbxassetid://77567945870953",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"rpg_equip",
	"rpg_idle",
	"rpg_sprint",
	"rpg_inspect",
	"rpg_inspect_rare",
	{
		Shoot1 = "rpg_shoot1",
		FinalShoot = nil,
		Reload = "rpg_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Rocket Launcher",
	"rbxassetid://116931956715309",
	"rbxassetid://90083302291399",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"rpg_rocketlauncher_equip",
	"rpg_rocketlauncher_idle",
	"rpg_rocketlauncher_sprint",
	"rpg_rocketlauncher_inspect",
	nil,
	{
		Shoot1 = "rpg_rocketlauncher_shoot1",
		FinalShoot = nil,
		Reload = "rpg_rocketlauncher_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Cupcake Launcher",
	"rbxassetid://100541838356180",
	"rbxassetid://126442330139931",
	nil,
	nil,
	nil,
	CFrame.new(0.125, -0.25, -0.5),
	"rpg_equip",
	"rpg_idle",
	"rpg_sprint",
	"rpg_inspect",
	"rpg_inspect_rare",
	{
		Shoot1 = "rpg_shoot1",
		FinalShoot = nil,
		Reload = "rpg_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Sundae Launcher",
	"rbxassetid://70578055340962",
	"rbxassetid://99837466191060",
	nil,
	nil,
	nil,
	CFrame.new(0.375, -0.5, -0.75),
	"rpg_equip",
	"rpg_idle",
	"rpg_sprint",
	"rpg_inspect",
	"rpg_inspect_rare",
	{
		Shoot1 = "rpg_shoot1",
		FinalShoot = nil,
		Reload = "rpg_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Shorty",
	"rbxassetid://17160800091",
	"rbxassetid://13255103172",
	nil,
	"rbxassetid://89929289810261",
	2,
	CFrame.new(0, -0.125, -0.25),
	"shorty_equip",
	"shorty_idle",
	"shorty_sprint",
	"shorty_inspect",
	"shorty_inspect_rare",
	{
		Shoot1 = "shorty_shoot1",
		FinalShoot = nil,
		Reload = "shorty_reload",
		EmptyReload = "shorty_reload_empty"
	}
)
add_viewmodel(
	"Not So Shorty",
	"rbxassetid://17672062572",
	"rbxassetid://17672087325",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"shorty_equip",
	"shorty_idle",
	"shorty_sprint",
	"shorty_inspect",
	"shorty_inspect_rare",
	{
		Shoot1 = "shorty_shoot1",
		FinalShoot = nil,
		Reload = "shorty_reload",
		EmptyReload = "shorty_reload_empty"
	}
)
add_viewmodel(
	"Too Shorty",
	"rbxassetid://18129531276",
	"rbxassetid://18129532343",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"shorty_equip",
	"shorty_idle",
	"shorty_sprint",
	"shorty_inspect",
	"shorty_inspect_rare",
	{
		Shoot1 = "shorty_shoot1",
		FinalShoot = nil,
		Reload = "shorty_reload",
		EmptyReload = "shorty_reload_empty"
	}
)
add_viewmodel(
	"Lovely Shorty",
	"rbxassetid://18766862000",
	"rbxassetid://18766906011",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"shorty_equip",
	"shorty_idle",
	"shorty_sprint",
	"shorty_inspect",
	"shorty_inspect_rare",
	{
		Shoot1 = "shorty_shoot1",
		FinalShoot = nil,
		Reload = "shorty_reload",
		EmptyReload = "shorty_reload_empty"
	}
)
add_viewmodel(
	"Demon Shorty",
	"rbxassetid://116443498278384",
	"rbxassetid://110819203451709",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"shorty_equip",
	"shorty_idle",
	"shorty_sprint",
	"shorty_inspect",
	"shorty_inspect_rare",
	{
		Shoot1 = "shorty_demonshorty_shoot1",
		FinalShoot = nil,
		Reload = "shorty_reload",
		EmptyReload = "shorty_reload_empty"
	}
)
add_viewmodel(
	"Wrapped Shorty",
	"rbxassetid://136522183669611",
	"rbxassetid://85255622402845",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"shorty_wrappedshorty_equip",
	"shorty_idle",
	"shorty_sprint",
	"shorty_inspect",
	"shorty_inspect_rare",
	{
		Shoot1 = "shorty_shoot1",
		FinalShoot = nil,
		Reload = "shorty_reload",
		EmptyReload = "shorty_reload_empty"
	}
)
add_viewmodel(
	"Balloon Shorty",
	"rbxassetid://75590262133322",
	"rbxassetid://87872312114961",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"shorty_equip",
	"shorty_idle",
	"shorty_sprint",
	"shorty_inspect",
	"shorty_balloonshorty_inspect_rare",
	{
		Shoot1 = "shorty_balloonshorty_shoot1",
		FinalShoot = nil,
		Reload = "shorty_balloonshorty_reload",
		EmptyReload = "shorty_balloonshorty_reload_empty"
	}
)
add_viewmodel(
	"Glorious Shorty",
	"rbxassetid://105834197552222",
	"rbxassetid://78845944937729",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"shorty_equip",
	"shorty_idle",
	"shorty_sprint",
	"shorty_inspect",
	"shorty_inspect_rare",
	{
		Shoot1 = "shorty_shoot1",
		FinalShoot = nil,
		Reload = "shorty_reload",
		EmptyReload = "shorty_reload_empty"
	}
)
add_viewmodel(
	"Cannon Shorty",
	"rbxassetid://137616738436928",
	"rbxassetid://91250869936830",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.25),
	"shorty_equip",
	"shorty_idle",
	"shorty_sprint",
	"shorty_inspect",
	"shorty_inspect_rare",
	{
		Shoot1 = "shorty_cannonshorty_shoot1",
		FinalShoot = nil,
		Reload = "shorty_reload2",
		EmptyReload = "shorty_reload2_empty"
	}
)
add_viewmodel(
	"Bubble Shorty",
	"rbxassetid://111294137896866",
	"rbxassetid://83774188272329",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.375),
	"shorty_bubbleshorty_equip",
	"shorty_bubbleshorty_idle",
	"shorty_bubbleshorty_sprint",
	"shorty_bubbleshorty_inspect",
	nil,
	{
		Shoot1 = "shorty_bubbleshorty_shoot1",
		FinalShoot = nil,
		Reload = "shorty_bubbleshorty_reload",
		EmptyReload = "shorty_bubbleshorty_reload_empty"
	}
)
add_viewmodel(
	"Shotgun",
	"rbxassetid://17160800007",
	"rbxassetid://13197583302",
	nil,
	"rbxassetid://102792045452343",
	2.75,
	CFrame.new(0, -0.25, -0.55),
	"shotgun_equip",
	"shotgun_idle",
	"shotgun_sprint",
	"shotgun_inspect",
	"shotgun_inspect_rare",
	{
		Shoot1 = "shotgun_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ReloadStart = "shotgun_reload_start",
		ReloadSegment = "shotgun_reload_segment",
		ReloadSegmentFinal = nil,
		ReloadFinish = "shotgun_reload_finish",
		EmptyReloadStart = "shotgun_reload_empty_start",
		EmptyReloadSegment = "shotgun_reload_segment",
		EmptyReloadSegmentFinal = nil,
		EmptyReloadFinish = "shotgun_reload_empty_finish2"
	}
)
add_viewmodel(
	"Balloon Shotgun",
	"rbxassetid://17821234823",
	"rbxassetid://17821266090",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.55),
	"shotgun_balloonshotgun_equip",
	"shotgun_idle",
	"shotgun_sprint",
	"shotgun_balloonshotgun_inspect",
	"shotgun_balloonshotgun_inspect_rare",
	{
		Shoot1 = "shotgun_balloonshotgun_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ReloadStart = "shotgun_reload_start",
		ReloadSegment = "shotgun_balloonshotgun_reload_segment",
		ReloadSegmentFinal = nil,
		ReloadFinish = "shotgun_balloonshotgun_reload_finish",
		EmptyReloadStart = "shotgun_balloonshotgun_reload_empty_start",
		EmptyReloadSegment = "shotgun_balloonshotgun_reload_segment",
		EmptyReloadSegmentFinal = nil,
		EmptyReloadFinish = "shotgun_balloonshotgun_reload_empty_finish2"
	}
)
add_viewmodel(
	"Hyper Shotgun",
	"rbxassetid://18768968419",
	"rbxassetid://18768974410",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.55),
	"shotgun_equip",
	"shotgun_idle",
	"shotgun_sprint",
	"shotgun_inspect",
	"shotgun_inspect_rare",
	{
		Shoot1 = "shotgun_hypershotgun_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ReloadStart = "shotgun_reload_start",
		ReloadSegment = "shotgun_reload_segment",
		ReloadSegmentFinal = nil,
		ReloadFinish = "shotgun_reload_finish",
		EmptyReloadStart = "shotgun_reload_empty_start",
		EmptyReloadSegment = "shotgun_reload_segment",
		EmptyReloadSegmentFinal = nil,
		EmptyReloadFinish = "shotgun_reload_empty_finish2"
	}
)
add_viewmodel(
	"Broomstick",
	"rbxassetid://118061559757082",
	"rbxassetid://126607371232554",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.5),
	"shotgun_broomstick_equip",
	"shotgun_idle",
	"shotgun_sprint",
	"shotgun_inspect",
	"shotgun_inspect_rare",
	{
		Shoot1 = "shotgun_broomstick_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ReloadStart = "shotgun_reload_start",
		ReloadSegment = "shotgun_reload_segment",
		ReloadSegmentFinal = nil,
		ReloadFinish = "shotgun_reload_finish",
		EmptyReloadStart = "shotgun_reload_empty_start",
		EmptyReloadSegment = "shotgun_reload_segment",
		EmptyReloadSegmentFinal = nil,
		EmptyReloadFinish = "shotgun_reload_empty_finish2"
	}
)
add_viewmodel(
	"Wrapped Shotgun",
	"rbxassetid://74894345245237",
	"rbxassetid://122560535811833",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.5),
	"shotgun_wrappedshotgun_equip",
	"shotgun_idle",
	"shotgun_sprint",
	"shotgun_inspect",
	"shotgun_inspect_rare",
	{
		Shoot1 = "shotgun_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ReloadStart = "shotgun_reload_start",
		ReloadSegment = "shotgun_reload_segment",
		ReloadSegmentFinal = nil,
		ReloadFinish = "shotgun_reload_finish",
		EmptyReloadStart = "shotgun_reload_empty_start",
		EmptyReloadSegment = "shotgun_reload_segment",
		EmptyReloadSegmentFinal = nil,
		EmptyReloadFinish = "shotgun_reload_empty_finish2"
	}
)
add_viewmodel(
	"Cactus Shotgun",
	"rbxassetid://131606483507460",
	"rbxassetid://128141817339029",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.55),
	"shotgun_equip",
	"shotgun_idle",
	"shotgun_sprint",
	"shotgun_inspect",
	"shotgun_inspect_rare",
	{
		Shoot1 = "shotgun_cactusshotgun_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ReloadStart = "shotgun_reload_start",
		ReloadSegment = "shotgun_reload_segment",
		ReloadSegmentFinal = nil,
		ReloadFinish = "shotgun_reload_finish",
		EmptyReloadStart = "shotgun_reload_empty_start",
		EmptyReloadSegment = "shotgun_reload_segment",
		EmptyReloadSegmentFinal = nil,
		EmptyReloadFinish = "shotgun_reload_empty_finish2"
	}
)
add_viewmodel(
	"Shotkey",
	"rbxassetid://93004214983981",
	"rbxassetid://101615278610735",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.5),
	"shotgun_shotkey_equip",
	"shotgun_shotkey_idle",
	"shotgun_shotkey_sprint",
	"shotgun_shotkey_inspect",
	nil,
	{
		Shoot1 = "shotgun_shotkey_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ReloadStart = "shotgun_shotkey_reload_start",
		ReloadSegment = "shotgun_shotkey_reload_segment",
		ReloadSegmentFinal = nil,
		ReloadFinish = "shotgun_shotkey_reload_finish",
		EmptyReloadStart = "shotgun_shotkey_reload_empty_start",
		EmptyReloadSegment = "shotgun_shotkey_reload_segment",
		EmptyReloadSegmentFinal = nil,
		EmptyReloadFinish = "shotgun_shotkey_reload_empty_finish2",
		EmptyInspect = "shotgun_shotkey_inspect_empty"
	}
)
add_viewmodel(
	"Glorious Shotgun",
	"rbxassetid://71704618059601",
	"rbxassetid://104100596412940",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.55),
	"shotgun_equip",
	"shotgun_idle",
	"shotgun_sprint",
	"shotgun_inspect",
	"shotgun_inspect_rare",
	{
		Shoot1 = "shotgun_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ReloadStart = "shotgun_reload_start",
		ReloadSegment = "shotgun_reload_segment",
		ReloadSegmentFinal = nil,
		ReloadFinish = "shotgun_reload_finish",
		EmptyReloadStart = "shotgun_reload_empty_start",
		EmptyReloadSegment = "shotgun_reload_segment",
		EmptyReloadSegmentFinal = nil,
		EmptyReloadFinish = "shotgun_reload_empty_finish2"
	}
)
add_viewmodel(
	"Shark Shotgun",
	"rbxassetid://116415689080224",
	"rbxassetid://122650006341042",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.55),
	"shotgun_sharkshotgun_equip",
	"shotgun_sharkshotgun_idle",
	"shotgun_sharkshotgun_sprint",
	"shotgun_sharkshotgun_inspect",
	nil,
	{
		Shoot1 = "shotgun_sharkshotgun_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ReloadStart = "shotgun_sharkshotgun_reload_start",
		ReloadSegment = "shotgun_sharkshotgun_reload_segment",
		ReloadSegmentFinal = "shotgun_sharkshotgun_reload_segment_final",
		ReloadFinish = "shotgun_sharkshotgun_reload_finish",
		EmptyReloadStart = "shotgun_sharkshotgun_reload_empty_start",
		EmptyReloadSegment = "shotgun_sharkshotgun_reload_segment",
		EmptyReloadSegmentFinal = "shotgun_sharkshotgun_reload_segment_final",
		EmptyReloadFinish = "shotgun_sharkshotgun_reload_empty_finish2"
	}
)
add_viewmodel(
	"Bow",
	"rbxassetid://17160802080",
	"rbxassetid://13717212331",
	nil,
	"rbxassetid://108384017179119",
	2,
	nil,
	"bow_equip",
	"bow_idle",
	"bow_sprint",
	"bow_inspect",
	nil,
	{
		Shoot1 = "bow_shoot1",
		FinalShoot = nil,
		Reload = "bow_reload",
		EmptyReload = nil,
		Charge = "bow_charge",
		ChargeLoop = "bow_charge_loop",
		ChargeRelease = "bow_charge_release"
	}
)
add_viewmodel(
	"Compound Bow",
	"rbxassetid://17672234242",
	"rbxassetid://17672229023",
	nil,
	nil,
	nil,
	nil,
	"bow_equip",
	"bow_idle",
	"bow_sprint",
	"bow_inspect",
	nil,
	{
		Shoot1 = "bow_shoot1",
		FinalShoot = nil,
		Reload = "bow_reload",
		EmptyReload = nil,
		Charge = "bow_charge",
		ChargeLoop = "bow_charge_loop",
		ChargeRelease = "bow_charge_release"
	}
)
add_viewmodel(
	"Raven Bow",
	"rbxassetid://18766861627",
	"rbxassetid://18766905321",
	nil,
	nil,
	nil,
	nil,
	"bow_ravenbow_equip",
	"bow_idle",
	"bow_sprint",
	"bow_inspect",
	nil,
	{
		Shoot1 = "bow_shoot1",
		FinalShoot = nil,
		Reload = "bow_reload",
		EmptyReload = nil,
		Charge = "bow_charge",
		ChargeLoop = "bow_charge_loop",
		ChargeRelease = "bow_charge_release"
	}
)
add_viewmodel(
	"Bat Bow",
	"rbxassetid://108984987378619",
	"rbxassetid://71508472340303",
	nil,
	nil,
	nil,
	nil,
	"bow_batbow_equip",
	"bow_idle",
	"bow_sprint",
	"bow_inspect",
	nil,
	{
		Shoot1 = "bow_batbow_shoot1",
		FinalShoot = nil,
		Reload = "bow_reload",
		EmptyReload = nil,
		Charge = "bow_charge",
		ChargeLoop = "bow_charge_loop",
		ChargeRelease = "bow_batbow_charge_release"
	}
)
add_viewmodel(
	"Frostbite Bow",
	"rbxassetid://121895626623160",
	"rbxassetid://82246935699705",
	nil,
	nil,
	nil,
	nil,
	"bow_frostbitebow_equip",
	"bow_idle",
	"bow_sprint",
	"bow_inspect",
	nil,
	{
		Shoot1 = "bow_frostbitebow_shoot1",
		FinalShoot = nil,
		Reload = "bow_reload",
		EmptyReload = nil,
		Charge = "bow_charge",
		ChargeLoop = "bow_charge_loop",
		ChargeRelease = "bow_frostbitebow_charge_release"
	}
)
add_viewmodel(
	"Dream Bow",
	"rbxassetid://101089313144218",
	"rbxassetid://104571173348964",
	nil,
	nil,
	nil,
	nil,
	"bow_dreambow_equip",
	"bow_idle",
	"bow_sprint",
	"bow_inspect",
	nil,
	{
		Shoot1 = "bow_dreambow_shoot1",
		FinalShoot = nil,
		Reload = "bow_reload",
		EmptyReload = nil,
		Charge = "bow_charge",
		ChargeLoop = "bow_charge_loop",
		ChargeRelease = "bow_dreambow_charge_release"
	}
)
add_viewmodel(
	"Key Bow",
	"rbxassetid://122525140091212",
	"rbxassetid://101924188286368",
	nil,
	nil,
	nil,
	CFrame.new(-0.125, -0.25, -0.5),
	"bow_keybow_equip",
	"bow_keybow_idle",
	"bow_keybow_sprint",
	"bow_keybow_inspect",
	"bow_keybow_inspect_rare",
	{
		Shoot1 = "bow_keybow_shoot1",
		FinalShoot = nil,
		Reload = "bow_keybow_reload",
		EmptyReload = nil,
		Charge = "bow_keybow_charge",
		ChargeLoop = "bow_keybow_charge_loop",
		ChargeRelease = "bow_keybow_charge_release",
		InspectEmpty = "bow_keybow_inspect_empty"
	}
)
add_viewmodel(
	"Glorious Bow",
	"rbxassetid://84201415206621",
	"rbxassetid://139021383472653",
	nil,
	nil,
	nil,
	nil,
	"bow_equip",
	"bow_idle",
	"bow_sprint",
	"bow_inspect",
	nil,
	{
		Shoot1 = "bow_shoot1",
		FinalShoot = nil,
		Reload = "bow_reload",
		EmptyReload = nil,
		Charge = "bow_charge",
		ChargeLoop = "bow_charge_loop",
		ChargeRelease = "bow_charge_release"
	}
)
add_viewmodel(
	"Balloon Bow",
	"rbxassetid://128957010941029",
	"rbxassetid://123350417110914",
	nil,
	nil,
	nil,
	nil,
	"bow_balloonbow_equip",
	"bow_idle",
	"bow_sprint",
	"bow_inspect",
	nil,
	{
		Shoot1 = "bow_balloonbow_shoot1",
		FinalShoot = nil,
		Reload = "bow_balloonbow_reload",
		EmptyReload = nil,
		Charge = "bow_charge",
		ChargeLoop = "bow_charge_loop",
		ChargeRelease = "bow_balloonbow_charge_release"
	}
)
add_viewmodel(
	"Beloved Bow",
	"rbxassetid://110219131386799",
	"rbxassetid://92379249333386",
	nil,
	nil,
	nil,
	nil,
	"bow_belovedbow_equip",
	"bow_idle",
	"bow_sprint",
	"bow_inspect",
	nil,
	{
		Shoot1 = "bow_belovedbow_shoot1",
		FinalShoot = nil,
		Reload = "bow_reload",
		EmptyReload = nil,
		Charge = "bow_charge",
		ChargeLoop = "bow_charge_loop",
		ChargeRelease = "bow_belovedbow_charge_release"
	}
)
add_viewmodel(
	"Palm Bow",
	"rbxassetid://82899577710787",
	"rbxassetid://125910045538332",
	nil,
	nil,
	nil,
	nil,
	"bow_palmbow_equip",
	"bow_idle",
	"bow_sprint",
	"bow_inspect",
	nil,
	{
		Shoot1 = "bow_palmbow_shoot1",
		FinalShoot = nil,
		Reload = "bow_reload",
		EmptyReload = nil,
		Charge = "bow_charge",
		ChargeLoop = "bow_charge_loop",
		ChargeRelease = "bow_palmbow_charge_release"
	}
)
add_viewmodel(
	"Uzi",
	"rbxassetid://17160798908",
	"rbxassetid://14020829706",
	nil,
	"rbxassetid://83641084870257",
	1.5,
	CFrame.new(0, -0.125, 0.125),
	"uzi_equip",
	"uzi_idle",
	"uzi_sprint",
	"uzi_inspect",
	nil,
	{
		Shoot1 = "uzi_shoot1",
		FinalShoot = nil,
		Reload = "uzi_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Water Uzi",
	"rbxassetid://17821233590",
	"rbxassetid://17821264784",
	nil,
	nil,
	nil,
	CFrame.new(-0.125, -0.25, -0.375),
	"uzi_equip",
	"uzi_idle",
	"uzi_sprint",
	"uzi_inspect",
	nil,
	{
		Shoot1 = "uzi_wateruzi_shoot1",
		FinalShoot = nil,
		Reload = "uzi_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Electro Uzi",
	"rbxassetid://96806694653207",
	"rbxassetid://98294074022488",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0.125),
	"uzi_equip",
	"uzi_idle",
	"uzi_sprint",
	"uzi_inspect",
	nil,
	{
		Shoot1 = "uzi_electrouzi_shoot1",
		FinalShoot = nil,
		Reload = "uzi_electrouzi_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Demon Uzi",
	"rbxassetid://132973040482576",
	"rbxassetid://81076572654230",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0.125),
	"uzi_equip",
	"uzi_idle",
	"uzi_sprint",
	"uzi_inspect",
	nil,
	{
		Shoot1 = "uzi_demonuzi_shoot1",
		FinalShoot = nil,
		Reload = "uzi_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Pine Uzi",
	"rbxassetid://82545206964916",
	"rbxassetid://80778273701013",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0.125),
	"uzi_equip",
	"uzi_idle",
	"uzi_sprint",
	"uzi_inspect",
	nil,
	{
		Shoot1 = "uzi_pineuzi_shoot1",
		FinalShoot = nil,
		Reload = "uzi_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Money Gun",
	"rbxassetid://100705725115757",
	"rbxassetid://73092203311844",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"uzi_moneygun_equip",
	"uzi_moneygun_idle",
	"uzi_moneygun_sprint",
	"uzi_moneygun_inspect",
	nil,
	{
		Shoot1 = "uzi_moneygun_shoot1",
		FinalShoot = nil,
		Reload = "uzi_moneygun_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Keyzi",
	"rbxassetid://100392703246534",
	"rbxassetid://127937206087121",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.375),
	"uzi_keyzi_equip",
	"uzi_keyzi_idle",
	"uzi_keyzi_sprint",
	"uzi_keyzi_inspect",
	nil,
	{
		Shoot1 = "uzi_keyzi_shoot1",
		FinalShoot = nil,
		Reload = "uzi_keyzi_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Glorious Uzi",
	"rbxassetid://120045334159124",
	"rbxassetid://121978889022374",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0.125),
	"uzi_equip",
	"uzi_idle",
	"uzi_sprint",
	"uzi_inspect",
	nil,
	{
		Shoot1 = "uzi_shoot1",
		FinalShoot = nil,
		Reload = "uzi_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Arch Uzi",
	"rbxassetid://139852585731073",
	"rbxassetid://129292939007924",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0.125),
	"uzi_equip",
	"uzi_idle",
	"uzi_sprint",
	"uzi_inspect",
	nil,
	{
		Shoot1 = "uzi_shoot1",
		FinalShoot = nil,
		Reload = "uzi_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Ducky Uzi",
	"rbxassetid://133780419950894",
	"rbxassetid://104334764509025",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, 0.125),
	"uzi_equip",
	"uzi_idle",
	"uzi_sprint",
	"uzi_inspect",
	nil,
	{
		Shoot1 = "uzi_duckyuzi_shoot1",
		FinalShoot = nil,
		Reload = "uzi_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Revolver",
	"rbxassetid://17160800299",
	"rbxassetid://14020829500",
	nil,
	"rbxassetid://122164679882999",
	1.5,
	CFrame.new(0, -0.125, -0.125),
	"revolver_equip",
	"revolver_idle",
	"revolver_sprint",
	"revolver_inspect",
	nil,
	{
		Shoot1 = "revolver_shoot1",
		FinalShoot = nil,
		Reload = "revolver_reload",
		EmptyReload = "revolver_reload_empty",
		QuickShot = "revolver_quickshot",
		FinalQuickShot = nil
	}
)
add_viewmodel(
	"Desert Eagle",
	"rbxassetid://17821234372",
	"rbxassetid://17821265603",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.125) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"revolver_deserteagle_equip",
	"handgun_idle",
	"handgun_sprint",
	"handgun_inspect",
	nil,
	{
		Shoot1 = "revolver_deserteagle_shoot1",
		FinalShoot = "revolver_deserteagle_shoot_final",
		Reload = "revolver_deserteagle_reload",
		EmptyReload = "revolver_deserteagle_reload_empty",
		QuickShot = "revolver_deserteagle_shoot1",
		FinalQuickShot = "revolver_deserteagle_shoot_final"
	}
)
add_viewmodel(
	"Sheriff",
	"rbxassetid://18770192507",
	"rbxassetid://18770200449",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.375) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"revolver_sheriff_equip",
	"revolver_sheriff_idle",
	"revolver_sheriff_sprint",
	"revolver_sheriff_inspect",
	nil,
	{
		Shoot1 = "revolver_sheriff_shoot1",
		FinalShoot = nil,
		Reload = "revolver_sheriff_reload",
		EmptyReload = "revolver_sheriff_reload_empty",
		QuickShot = "revolver_sheriff_quickshot",
		FinalQuickShot = nil
	}
)
add_viewmodel(
	"Boneclaw Revolver",
	"rbxassetid://119174697609264",
	"rbxassetid://134217952089145",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"revolver_equip",
	"revolver_idle",
	"revolver_sprint",
	"revolver_inspect",
	nil,
	{
		Shoot1 = "revolver_boneclawrevolver_shoot1",
		FinalShoot = nil,
		Reload = "revolver_reload",
		EmptyReload = "revolver_reload_empty",
		QuickShot = "revolver_boneclawrevolver_quickshot",
		FinalQuickShot = nil
	}
)
add_viewmodel(
	"Peppermint Sheriff",
	"rbxassetid://95859403750768",
	"rbxassetid://71229586558137",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.375) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"revolver_peppermintsheriff_equip",
	"revolver_peppermintsheriff_idle",
	"revolver_peppermintsheriff_sprint",
	"revolver_peppermintsheriff_inspect",
	nil,
	{
		Shoot1 = "revolver_peppermintsheriff_shoot1",
		FinalShoot = nil,
		Reload = "revolver_peppermintsheriff_reload",
		EmptyReload = "revolver_peppermintsheriff_reload_empty",
		QuickShot = "revolver_peppermintsheriff_quickshot",
		FinalQuickShot = nil
	}
)
add_viewmodel(
	"Keyvolver",
	"rbxassetid://87974031410344",
	"rbxassetid://73746116648532",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.375),
	"revolver_keyvolver_equip",
	"revolver_keyvolver_idle",
	"revolver_keyvolver_sprint",
	"revolver_keyvolver_inspect",
	nil,
	{
		Shoot1 = "revolver_keyvolver_shoot1",
		FinalShoot = "revolver_keyvolver_shoot_final",
		Reload = "revolver_keyvolver_reload",
		EmptyReload = "revolver_keyvolver_reload_empty",
		QuickShot = "revolver_keyvolver_quickshot",
		FinalQuickShot = nil,
		EquipEmpty = "revolver_keyvolver_equip_empty",
		IdleEmpty = "revolver_keyvolver_idle_empty",
		SprintEmpty = "revolver_keyvolver_sprint_empty",
		InspectEmpty = "revolver_keyvolver_inspect_empty"
	}
)
add_viewmodel(
	"Peppergun",
	"rbxassetid://124178691056979",
	"rbxassetid://112311707478578",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.125, -0.375) * CFrame.Angles(0, math.rad(5), (math.rad(-10))),
	"revolver_peppergun_equip",
	"revolver_peppergun_idle",
	"revolver_peppergun_sprint",
	"revolver_peppergun_inspect",
	nil,
	{
		Shoot1 = "revolver_peppergun_shoot1",
		FinalShoot = "revolver_peppergun_shoot_final",
		Reload = "revolver_peppergun_reload",
		EmptyReload = "revolver_peppergun_reload_empty",
		QuickShot = "revolver_peppergun_quickshot",
		FinalQuickShot = nil,
		EquipEmpty = "revolver_peppergun_equip_empty",
		IdleEmpty = "revolver_peppergun_idle_empty",
		SprintEmpty = "revolver_peppergun_sprint_empty",
		InspectEmpty = "revolver_peppergun_inspect_empty"
	}
)
add_viewmodel(
	"Glorious Revolver",
	"rbxassetid://118135542031794",
	"rbxassetid://137749607553707",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"revolver_equip",
	"revolver_idle",
	"revolver_sprint",
	"revolver_inspect",
	nil,
	{
		Shoot1 = "revolver_shoot1",
		FinalShoot = nil,
		Reload = "revolver_reload",
		EmptyReload = "revolver_reload_empty",
		QuickShot = "revolver_quickshot",
		FinalQuickShot = nil
	}
)
add_viewmodel(
	"Cruise Revolver",
	"rbxassetid://72223124823807",
	"rbxassetid://118294610207863",
	nil,
	nil,
	nil,
	CFrame.new(-0.05, -0.2, -0.1),
	"revolver_cruiserevolver_equip",
	"revolver_cruiserevolver_idle",
	"revolver_cruiserevolver_sprint",
	"revolver_cruiserevolver_inspect",
	nil,
	{
		Shoot1 = "revolver_cruiserevolver_shoot1",
		FinalShoot = "revolver_cruiserevolver_shoot_final",
		Reload = "revolver_cruiserevolver_reload",
		EmptyReload = "revolver_cruiserevolver_reload_empty",
		QuickShot = "revolver_cruiserevolver_quickshot",
		FinalQuickShot = nil,
		EquipEmpty = "revolver_cruiserevolver_equip_empty",
		IdleEmpty = "revolver_cruiserevolver_idle_empty",
		SprintEmpty = "revolver_cruiserevolver_sprint_empty",
		InspectEmpty = "revolver_cruiserevolver_inspect_empty"
	}
)
add_viewmodel(
	"Paintball Gun",
	"rbxassetid://17160853798",
	"rbxassetid://16560547676",
	nil,
	"rbxassetid://82789508344248",
	2,
	CFrame.new(0, -0.25, -0.375),
	"paintballgun_equip",
	"paintballgun_idle",
	"paintballgun_sprint",
	"paintballgun_inspect",
	nil,
	{
		Shoot1 = "paintballgun_shoot1",
		FinalShoot = nil,
		Reload = "paintballgun_reload",
		EmptyReload = nil,
		Throw = "paintballgun_throw"
	}
)
add_viewmodel(
	"Slime Gun",
	"rbxassetid://17672062472",
	"rbxassetid://17672087561",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"paintballgun_equip",
	"paintballgun_idle",
	"paintballgun_sprint",
	"paintballgun_inspect",
	nil,
	{
		Shoot1 = "paintballgun_slimegun_shoot1",
		FinalShoot = nil,
		Reload = "paintballgun_reload",
		EmptyReload = nil,
		Throw = "paintballgun_throw"
	}
)
add_viewmodel(
	"Boba Gun",
	"rbxassetid://18768830660",
	"rbxassetid://18768828072",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"paintballgun_equip",
	"paintballgun_idle",
	"paintballgun_sprint",
	"paintballgun_inspect",
	"paintballgun_bobagun_inspect_rare",
	{
		Shoot1 = "paintballgun_bobagun_shoot1",
		FinalShoot = nil,
		Reload = "paintballgun_reload",
		EmptyReload = nil,
		Throw = "paintballgun_throw"
	}
)
add_viewmodel(
	"Brain Gun",
	"rbxassetid://85970592668118",
	"rbxassetid://135843933439701",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"paintballgun_equip",
	"paintballgun_idle",
	"paintballgun_sprint",
	"paintballgun_inspect",
	nil,
	{
		Shoot1 = "paintballgun_slimegun_shoot1",
		FinalShoot = nil,
		Reload = "paintballgun_reload",
		EmptyReload = nil,
		Throw = "paintballgun_throw"
	}
)
add_viewmodel(
	"Snowball Gun",
	"rbxassetid://113685354916533",
	"rbxassetid://78161595959189",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"paintballgun_equip",
	"paintballgun_idle",
	"paintballgun_sprint",
	"paintballgun_inspect",
	nil,
	{
		Shoot1 = "paintballgun_snowballgun_shoot1",
		FinalShoot = nil,
		Reload = "paintballgun_reload",
		EmptyReload = nil,
		Throw = "paintballgun_throw"
	}
)
add_viewmodel(
	"Ketchup Gun",
	"rbxassetid://76083615050939",
	"rbxassetid://130402361506639",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"paintballgun_equip",
	"paintballgun_idle",
	"paintballgun_sprint",
	"paintballgun_inspect",
	nil,
	{
		Shoot1 = "paintballgun_ketchupgun_shoot1",
		FinalShoot = nil,
		Reload = "paintballgun_reload",
		EmptyReload = nil,
		Throw = "paintballgun_throw"
	}
)
add_viewmodel(
	"Glorious Paintball Gun",
	"rbxassetid://86297318955856",
	"rbxassetid://92272641219379",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"paintballgun_equip",
	"paintballgun_idle",
	"paintballgun_sprint",
	"paintballgun_inspect",
	nil,
	{
		Shoot1 = "paintballgun_shoot1",
		FinalShoot = nil,
		Reload = "paintballgun_reload",
		EmptyReload = nil,
		Throw = "paintballgun_throw"
	}
)
add_viewmodel(
	"Paintballoon Gun",
	"rbxassetid://100129918948246",
	"rbxassetid://71822933033710",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"paintballgun_equip",
	"paintballgun_idle",
	"paintballgun_sprint",
	"paintballgun_inspect",
	nil,
	{
		Shoot1 = "paintballgun_paintballoongun_shoot1",
		FinalShoot = nil,
		Reload = "paintballgun_paintballoongun_reload",
		EmptyReload = nil,
		Throw = "paintballgun_throw"
	}
)
add_viewmodel(
	"Lemonade Gun",
	"rbxassetid://119390099120478",
	"rbxassetid://128074622676219",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"paintballgun_equip",
	"paintballgun_idle",
	"paintballgun_sprint",
	"paintballgun_inspect",
	nil,
	{
		Shoot1 = "paintballgun_lemonadegun_shoot1",
		FinalShoot = nil,
		Reload = "paintballgun_reload",
		EmptyReload = nil,
		Throw = "paintballgun_throw"
	}
)
add_viewmodel(
	"Slingshot",
	"rbxassetid://17160799888",
	"rbxassetid://17095306079",
	nil,
	"rbxassetid://75643870124560",
	1.25,
	CFrame.new(0, -0.375, -0.5),
	"slingshot_equip",
	"slingshot_idle",
	"slingshot_sprint",
	"slingshot_inspect",
	nil,
	{
		Shoot1 = "slingshot_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Goalpost",
	"rbxassetid://17672063165",
	"rbxassetid://17672086378",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.5),
	"slingshot_equip",
	"slingshot_idle",
	"slingshot_sprint",
	"slingshot_inspect",
	nil,
	{
		Shoot1 = "slingshot_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Stick",
	"rbxassetid://17672063048",
	"rbxassetid://17672086502",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.5),
	"slingshot_equip",
	"slingshot_idle",
	"slingshot_sprint",
	"slingshot_inspect",
	nil,
	{
		Shoot1 = "slingshot_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Boneshot",
	"rbxassetid://86606957688341",
	"rbxassetid://103283614012077",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.5),
	"slingshot_equip",
	"slingshot_idle",
	"slingshot_sprint",
	"slingshot_inspect",
	nil,
	{
		Shoot1 = "slingshot_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Reindeer Slingshot",
	"rbxassetid://121612921203624",
	"rbxassetid://106406735551091",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.5),
	"slingshot_equip",
	"slingshot_idle",
	"slingshot_sprint",
	"slingshot_inspect",
	nil,
	{
		Shoot1 = "slingshot_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Harp",
	"rbxassetid://80850043664453",
	"rbxassetid://89702051394732",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.5),
	"slingshot_harp_equip",
	"slingshot_harp_idle",
	"slingshot_harp_sprint",
	"slingshot_harp_inspect",
	nil,
	{
		Shoot1 = "slingshot_harp_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Glorious Slingshot",
	"rbxassetid://101195664167288",
	"rbxassetid://111031840425662",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.5),
	"slingshot_equip",
	"slingshot_idle",
	"slingshot_sprint",
	"slingshot_inspect",
	nil,
	{
		Shoot1 = "slingshot_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Lucky Horseshoe",
	"rbxassetid://131242126669282",
	"rbxassetid://126152077516450",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.5),
	"slingshot_equip",
	"slingshot_idle",
	"slingshot_sprint",
	"slingshot_inspect",
	nil,
	{
		Shoot1 = "slingshot_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Keyshot",
	"rbxassetid://74006265601388",
	"rbxassetid://112207648939743",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.5),
	"slingshot_keyshot_equip",
	"slingshot_keyshot_idle",
	"slingshot_keyshot_sprint",
	"slingshot_keyshot_inspect",
	nil,
	{
		Shoot1 = "slingshot_keyshot_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Palmshot",
	"rbxassetid://109640024736812",
	"rbxassetid://103005257458281",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.5),
	"slingshot_equip",
	"slingshot_idle",
	"slingshot_sprint",
	"slingshot_inspect",
	nil,
	{
		Shoot1 = "slingshot_palmshot_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Grenade Launcher",
	"rbxassetid://17250453814",
	"rbxassetid://17250456230",
	nil,
	"rbxassetid://96911371491753",
	2.75,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"grenadelauncher_equip",
	"grenadelauncher_idle",
	"grenadelauncher_sprint",
	"grenadelauncher_inspect",
	nil,
	{
		Shoot1 = "grenadelauncher_shoot1",
		FinalShoot = nil,
		Reload = "grenadelauncher_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Swashbuckler",
	"rbxassetid://17821233828",
	"rbxassetid://17821265007",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.5) * CFrame.Angles(math.rad(5), 0, 0),
	"grenadelauncher_equip",
	"grenadelauncher_idle",
	"grenadelauncher_sprint",
	"grenadelauncher_inspect",
	nil,
	{
		Shoot1 = "grenadelauncher_shoot1",
		FinalShoot = nil,
		Reload = "grenadelauncher_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Uranium Launcher",
	"rbxassetid://18766860114",
	"rbxassetid://18766902983",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"grenadelauncher_equip",
	"grenadelauncher_idle",
	"grenadelauncher_sprint",
	"grenadelauncher_inspect",
	nil,
	{
		Shoot1 = "grenadelauncher_shoot1",
		FinalShoot = nil,
		Reload = "grenadelauncher_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Skull Launcher",
	"rbxassetid://103257281022910",
	"rbxassetid://88061081371943",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.5) * CFrame.Angles(math.rad(5), 0, 0),
	"grenadelauncher_equip",
	"grenadelauncher_idle",
	"grenadelauncher_sprint",
	"grenadelauncher_inspect",
	nil,
	{
		Shoot1 = "grenadelauncher_skulllauncher_shoot1",
		FinalShoot = nil,
		Reload = "grenadelauncher_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Snowball Launcher",
	"rbxassetid://112349955391111",
	"rbxassetid://136762406657736",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.5) * CFrame.Angles(math.rad(5), 0, 0),
	"grenadelauncher_snowballlauncher_equip",
	"grenadelauncher_idle",
	"grenadelauncher_sprint",
	"grenadelauncher_inspect",
	nil,
	{
		Shoot1 = "grenadelauncher_shoot1",
		FinalShoot = nil,
		Reload = "grenadelauncher_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Gearnade Launcher",
	"rbxassetid://133756750612042",
	"rbxassetid://91208130484582",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(5), 0, 0),
	"grenadelauncher_gearnadelauncher_equip",
	"grenadelauncher_idle",
	"grenadelauncher_sprint",
	"grenadelauncher_gearnadelauncher_inspect",
	nil,
	{
		Shoot1 = "grenadelauncher_gearnadelauncher_shoot1",
		FinalShoot = nil,
		Reload = "grenadelauncher_gearnadelauncher_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Glorious Grenade Launcher",
	"rbxassetid://134130354519919",
	"rbxassetid://133636006123737",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"grenadelauncher_equip",
	"grenadelauncher_idle",
	"grenadelauncher_sprint",
	"grenadelauncher_inspect",
	nil,
	{
		Shoot1 = "grenadelauncher_shoot1",
		FinalShoot = nil,
		Reload = "grenadelauncher_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Balloon Launcher",
	"rbxassetid://137862701599991",
	"rbxassetid://104286567552270",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"grenadelauncher_balloonlauncher_equip",
	"grenadelauncher_idle",
	"grenadelauncher_sprint",
	"grenadelauncher_balloonlauncher_inspect",
	nil,
	{
		Shoot1 = "grenadelauncher_balloonlauncher_shoot1",
		FinalShoot = nil,
		Reload = "grenadelauncher_balloonlauncher_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Coconut Launcher",
	"rbxassetid://77621998397460",
	"rbxassetid://110218225884153",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125) * CFrame.Angles(math.rad(2.5), 0, 0),
	"grenadelauncher_equip",
	"grenadelauncher_idle",
	"grenadelauncher_sprint",
	"grenadelauncher_inspect",
	nil,
	{
		Shoot1 = "grenadelauncher_shoot1",
		FinalShoot = nil,
		Reload = "grenadelauncher_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Minigun",
	"rbxassetid://17250458611",
	"rbxassetid://17250457775",
	nil,
	"rbxassetid://139259875015340",
	3.25,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(5), math.rad(2), 0),
	"minigun_equip",
	"minigun_idle",
	"minigun_sprint",
	"minigun_inspect",
	nil,
	{
		Shoot1 = nil,
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ChargeStart = "minigun_charge_start",
		ChargeLoop = "minigun_charge_loop",
		ChargeFinish = "minigun_charge_finish"
	}
)
add_viewmodel(
	"Lasergun 3000",
	"rbxassetid://103437974285778",
	"rbxassetid://116040043955852",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.5, -0.5) * CFrame.Angles(math.rad(5), math.rad(2), 0),
	"minigun_equip",
	"minigun_idle",
	"minigun_sprint",
	"minigun_inspect",
	nil,
	{
		Shoot1 = nil,
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ChargeStart = "minigun_charge_start",
		ChargeLoop = "minigun_charge_loop",
		ChargeFinish = "minigun_charge_finish"
	}
)
add_viewmodel(
	"Pixel Minigun",
	"rbxassetid://18766861798",
	"rbxassetid://18769001642",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(5), math.rad(2), 0),
	"minigun_pixelminigun_equip",
	"minigun_pixelminigun_idle",
	"minigun_pixelminigun_sprint",
	"minigun_pixelminigun_inspect",
	nil,
	{
		Shoot1 = nil,
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ChargeStart = "minigun_pixelminigun_charge_start",
		ChargeLoop = "minigun_pixelminigun_charge_loop",
		ChargeFinish = "minigun_pixelminigun_charge_finish"
	},
	{
		FramesPerSecond = 2,
		PlayAnimationsInstantly = true
	}
)
add_viewmodel(
	"Pumpkin Minigun",
	"rbxassetid://77388785880854",
	"rbxassetid://101609024294564",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(5), math.rad(2), 0),
	"minigun_equip",
	"minigun_idle",
	"minigun_sprint",
	"minigun_inspect",
	nil,
	{
		Shoot1 = nil,
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ChargeStart = "minigun_charge_start",
		ChargeLoop = "minigun_charge_loop",
		ChargeFinish = "minigun_charge_finish"
	}
)
add_viewmodel(
	"Wrapped Minigun",
	"rbxassetid://127077702465909",
	"rbxassetid://77902572458498",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(5), math.rad(2), 0),
	"minigun_wrappedminigun_equip",
	"minigun_idle",
	"minigun_sprint",
	"minigun_inspect",
	nil,
	{
		Shoot1 = nil,
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ChargeStart = "minigun_charge_start",
		ChargeLoop = "minigun_charge_loop",
		ChargeFinish = "minigun_charge_finish"
	}
)
add_viewmodel(
	"Fighter Jet",
	"rbxassetid://70780739230558",
	"rbxassetid://95650502925488",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(5), math.rad(2), 0),
	"minigun_fighterjet_equip",
	"minigun_fighterjet_idle",
	"minigun_fighterjet_sprint",
	"minigun_fighterjet_inspect",
	nil,
	{
		Shoot1 = nil,
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ChargeStart = "minigun_fighterjet_charge_start",
		ChargeLoop = "minigun_fighterjet_charge_loop",
		ChargeFinish = "minigun_fighterjet_charge_finish"
	}
)
add_viewmodel(
	"Glorious Minigun",
	"rbxassetid://84246894288637",
	"rbxassetid://99372535399034",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(5), math.rad(2), 0),
	"minigun_equip",
	"minigun_idle",
	"minigun_sprint",
	"minigun_inspect",
	nil,
	{
		Shoot1 = nil,
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ChargeStart = "minigun_charge_start",
		ChargeLoop = "minigun_charge_loop",
		ChargeFinish = "minigun_charge_finish"
	}
)
add_viewmodel(
	"Shark Minigun",
	"rbxassetid://89295703576175",
	"rbxassetid://79060347820981",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(5), math.rad(2), 0),
	"minigun_sharkminigun_equip",
	"minigun_sharkminigun_idle",
	"minigun_sharkminigun_sprint",
	"minigun_sharkminigun_inspect",
	nil,
	{
		Shoot1 = nil,
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ChargeStart = "minigun_sharkminigun_charge_start",
		ChargeLoop = "minigun_sharkminigun_charge_loop",
		ChargeFinish = "minigun_sharkminigun_charge_finish"
	}
)
add_viewmodel(
	"Exogun",
	"rbxassetid://17344796376",
	"rbxassetid://17344797370",
	nil,
	"rbxassetid://88192617023871",
	1.5,
	CFrame.new(0, -0.25, 0) * CFrame.Angles(math.rad(5), 0, 0),
	"exogun_equip",
	"exogun_idle",
	"exogun_sprint",
	"exogun_inspect",
	nil,
	{
		Shoot1 = "exogun_shoot1",
		FinalShoot = nil,
		Reload = "exogun_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Wondergun",
	"rbxassetid://17672060360",
	"rbxassetid://17672086052",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, 0) * CFrame.Angles(math.rad(5), 0, 0),
	"exogun_equip",
	"exogun_idle",
	"exogun_sprint",
	"exogun_inspect",
	nil,
	{
		Shoot1 = "exogun_shoot1",
		FinalShoot = nil,
		Reload = "exogun_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Singularity",
	"rbxassetid://17676876756",
	"rbxassetid://17676875650",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, 0) * CFrame.Angles(math.rad(5), 0, 0),
	"exogun_singularity_equip",
	"exogun_idle",
	"exogun_sprint",
	"exogun_inspect",
	nil,
	{
		Shoot1 = "exogun_singularity_shoot1",
		FinalShoot = nil,
		Reload = "exogun_singularity_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Ray Gun",
	"rbxassetid://18766861454",
	"rbxassetid://18766905089",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, 0) * CFrame.Angles(math.rad(5), 0, 0),
	"exogun_equip",
	"exogun_idle",
	"exogun_sprint",
	"exogun_inspect",
	nil,
	{
		Shoot1 = "exogun_shoot1",
		FinalShoot = nil,
		Reload = "exogun_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Exogourd",
	"rbxassetid://137140750597688",
	"rbxassetid://125880131168138",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, 0) * CFrame.Angles(math.rad(5), 0, 0),
	"exogun_equip",
	"exogun_idle",
	"exogun_sprint",
	"exogun_inspect",
	nil,
	{
		Shoot1 = "exogun_shoot1",
		FinalShoot = nil,
		Reload = "exogun_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Midnight Festive Exogun",
	"rbxassetid://127612442529810",
	"rbxassetid://80015495064851",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, 0) * CFrame.Angles(math.rad(5), 0, 0),
	"exogun_equip",
	"exogun_idle",
	"exogun_sprint",
	"exogun_inspect",
	nil,
	{
		Shoot1 = "exogun_shoot1",
		FinalShoot = nil,
		Reload = "exogun_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Repulsor",
	"rbxassetid://109263387714628",
	"rbxassetid://130472229545721",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.25) * CFrame.Angles(math.rad(5), 0, 0),
	"exogun_repulsor_equip",
	"exogun_repulsor_idle",
	"exogun_repulsor_sprint",
	"exogun_repulsor_inspect",
	nil,
	{
		Shoot1 = "exogun_repulsor_shoot1",
		FinalShoot = nil,
		Reload = "exogun_repulsor_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Glorious Exogun",
	"rbxassetid://129125201034206",
	"rbxassetid://105785189977176",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, 0) * CFrame.Angles(math.rad(5), 0, 0),
	"exogun_equip",
	"exogun_idle",
	"exogun_sprint",
	"exogun_inspect",
	nil,
	{
		Shoot1 = "exogun_shoot1",
		FinalShoot = nil,
		Reload = "exogun_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Pearl Exogun",
	"rbxassetid://77698515863000",
	"rbxassetid://111669080370620",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, 0) * CFrame.Angles(math.rad(5), 0, 0),
	"exogun_equip",
	"exogun_idle",
	"exogun_sprint",
	"exogun_inspect",
	nil,
	{
		Shoot1 = "exogun_pearlexogun_shoot1",
		FinalShoot = nil,
		Reload = "exogun_pearlexogun_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Freeze Ray",
	"rbxassetid://18429552328",
	"rbxassetid://18429549331",
	nil,
	"rbxassetid://72287797030544",
	1.5,
	nil,
	"freezeray_equip",
	"freezeray_idle",
	"freezeray_sprint",
	"freezeray_inspect",
	nil,
	{
		Shoot1 = "freezeray_shoot1"
	}
)
add_viewmodel(
	"Temporal Ray",
	"rbxassetid://18429552503",
	"rbxassetid://18429549663",
	nil,
	nil,
	nil,
	nil,
	"freezeray_equip",
	"freezeray_idle",
	"freezeray_sprint",
	"freezeray_inspect",
	nil,
	{
		Shoot1 = "freezeray_temporalray_shoot1"
	}
)
add_viewmodel(
	"Bubble Ray",
	"rbxassetid://18766865819",
	"rbxassetid://18769002868",
	nil,
	nil,
	nil,
	nil,
	"freezeray_bubbleray_equip",
	"freezeray_idle",
	"freezeray_sprint",
	"freezeray_inspect",
	nil,
	{
		Shoot1 = "freezeray_shoot1"
	}
)
add_viewmodel(
	"Spider Ray",
	"rbxassetid://136838810668332",
	"rbxassetid://92621276006979",
	nil,
	nil,
	nil,
	nil,
	"freezeray_spiderray_equip",
	"freezeray_spiderray_idle",
	"freezeray_spiderray_sprint",
	"freezeray_spiderray_inspect",
	nil,
	{
		Shoot1 = "freezeray_spiderray_shoot1"
	}
)
add_viewmodel(
	"Wrapped Freeze Ray",
	"rbxassetid://76183738050112",
	"rbxassetid://77624613843681",
	nil,
	nil,
	nil,
	nil,
	"freezeray_wrappedfreezeray_equip",
	"freezeray_idle",
	"freezeray_sprint",
	"freezeray_inspect",
	nil,
	{
		Shoot1 = "freezeray_shoot1"
	}
)
add_viewmodel(
	"Gum Ray",
	"rbxassetid://121504417727123",
	"rbxassetid://124339207784760",
	nil,
	nil,
	nil,
	nil,
	"freezeray_equip",
	"freezeray_idle",
	"freezeray_sprint",
	"freezeray_inspect",
	nil,
	{
		Shoot1 = "freezeray_shoot1"
	}
)
add_viewmodel(
	"Glorious Freeze Ray",
	"rbxassetid://120211873831101",
	"rbxassetid://96505833323714",
	nil,
	nil,
	nil,
	nil,
	"freezeray_equip",
	"freezeray_idle",
	"freezeray_sprint",
	"freezeray_inspect",
	nil,
	{
		Shoot1 = "freezeray_shoot1"
	}
)
add_viewmodel(
	"Cooler",
	"rbxassetid://117258208589940",
	"rbxassetid://114403955066222",
	nil,
	nil,
	nil,
	nil,
	"freezeray_cooler_equip",
	"freezeray_cooler_idle",
	"freezeray_cooler_sprint",
	"freezeray_cooler_inspect",
	nil,
	{
		Shoot1 = "freezeray_cooler_shoot1"
	}
)
add_viewmodel(
	"War Horn",
	"rbxassetid://104600246515190",
	"rbxassetid://97997387092919",
	nil,
	"rbxassetid://98364412304002",
	1.5,
	nil,
	"warhorn_equip",
	"warhorn_idle",
	"warhorn_sprint",
	"warhorn_inspect",
	nil,
	{
		Use = "warhorn_use"
	}
)
add_viewmodel(
	"Trumpet",
	"rbxassetid://88975601634708",
	"rbxassetid://113408430051712",
	nil,
	nil,
	nil,
	nil,
	"warhorn_equip",
	"warhorn_idle",
	"warhorn_sprint",
	"warhorn_inspect",
	nil,
	{
		Use = "warhorn_trumpet_use"
	}
)
add_viewmodel(
	"Mammoth Horn",
	"rbxassetid://93076834584542",
	"rbxassetid://107659166723688",
	nil,
	nil,
	nil,
	nil,
	"warhorn_equip",
	"warhorn_idle",
	"warhorn_sprint",
	"warhorn_inspect",
	nil,
	{
		Use = "warhorn_mammothhorn_use"
	}
)
add_viewmodel(
	"Megaphone",
	"rbxassetid://107074211847347",
	"rbxassetid://100739584109870",
	nil,
	nil,
	nil,
	nil,
	"warhorn_equip",
	"warhorn_idle",
	"warhorn_sprint",
	"warhorn_inspect",
	nil,
	{
		Use = "warhorn_megaphone_use"
	}
)
add_viewmodel(
	"Air Horn",
	"rbxassetid://111168146142976",
	"rbxassetid://128732687072177",
	nil,
	nil,
	nil,
	nil,
	"warhorn_equip",
	"warhorn_idle",
	"warhorn_sprint",
	"warhorn_inspect",
	nil,
	{
		Use = "warhorn_airhorn_use"
	}
)
add_viewmodel(
	"Glorious War Horn",
	"rbxassetid://96293355496772",
	"rbxassetid://123021790391323",
	nil,
	nil,
	nil,
	nil,
	"warhorn_equip",
	"warhorn_idle",
	"warhorn_sprint",
	"warhorn_inspect",
	nil,
	{
		Use = "warhorn_use"
	}
)
add_viewmodel(
	"Boneclaw Horn",
	"rbxassetid://138360812591331",
	"rbxassetid://126578341307256",
	nil,
	nil,
	nil,
	nil,
	"warhorn_boneclawhorn_equip",
	"warhorn_idle",
	"warhorn_sprint",
	"warhorn_inspect",
	nil,
	{
		Use = "warhorn_boneclawhorn_use"
	}
)
add_viewmodel(
	"Lifeguard Whistle",
	"rbxassetid://93791958663348",
	"rbxassetid://109008283215115",
	nil,
	nil,
	nil,
	nil,
	"warhorn_lifeguardwhistle_equip",
	"warhorn_lifeguardwhistle_idle",
	"warhorn_lifeguardwhistle_sprint",
	"warhorn_lifeguardwhistle_inspect",
	nil,
	{
		Use = "warhorn_lifeguardwhistle_use"
	}
)
add_viewmodel(
	"Satchel",
	"rbxassetid://82237471151891",
	"rbxassetid://132559258532984",
	nil,
	"rbxassetid://99042007892528",
	1.5,
	nil,
	"satchel_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish",
		Detonate = "satchel_detonate"
	}
)
add_viewmodel(
	"Advanced Satchel",
	"rbxassetid://113860326910548",
	"rbxassetid://118684510688617",
	nil,
	nil,
	nil,
	nil,
	"satchel_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish",
		Detonate = "satchel_advancedsatchel_detonate"
	}
)
add_viewmodel(
	"Suspicious Gift",
	"rbxassetid://76209303162814",
	"rbxassetid://131542627171282",
	nil,
	nil,
	nil,
	nil,
	"satchel_suspiciousgift_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish",
		Detonate = "satchel_detonate"
	}
)
add_viewmodel(
	"Notebook Satchel",
	"rbxassetid://124817464748150",
	"rbxassetid://85589408404069",
	nil,
	nil,
	nil,
	nil,
	"satchel_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish",
		Detonate = "satchel_detonate"
	}
)
add_viewmodel(
	"Bag o' Money",
	"rbxassetid://129192426700659",
	"rbxassetid://118634288543707",
	nil,
	nil,
	nil,
	nil,
	"satchel_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish",
		Detonate = "satchel_detonate"
	}
)
add_viewmodel(
	"Glorious Satchel",
	"rbxassetid://100521994805910",
	"rbxassetid://85737788428846",
	nil,
	nil,
	nil,
	nil,
	"satchel_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish",
		Detonate = "satchel_detonate"
	}
)
add_viewmodel(
	"Potion Satchel",
	"rbxassetid://76787046046890",
	"rbxassetid://112434777433399",
	nil,
	nil,
	nil,
	nil,
	"satchel_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish",
		Detonate = "satchel_potionsatchel_detonate"
	}
)
add_viewmodel(
	"Pizza Box",
	"rbxassetid://99166555665247",
	"rbxassetid://97977209980062",
	nil,
	nil,
	nil,
	nil,
	"satchel_pizzabox_equip",
	"satchel_pizzabox_idle",
	"satchel_pizzabox_sprint",
	"satchel_pizzabox_inspect",
	nil,
	{
		ThrowStart = "satchel_pizzabox_throw_start",
		ThrowIdle = "satchel_pizzabox_throw_idle",
		ThrowFinish = "satchel_pizzabox_throw_finish",
		LobStart = "satchel_pizzabox_throw_start",
		LobIdle = "satchel_pizzabox_throw_idle",
		LobFinish = "satchel_pizzabox_throw_finish",
		Detonate = "satchel_pizzabox_detonate"
	}
)
add_viewmodel(
	"Lifeguard Satchel",
	"rbxassetid://105277357472003",
	"rbxassetid://71359205931940",
	nil,
	nil,
	nil,
	nil,
	"satchel_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish",
		Detonate = "satchel_lifeguardsatchel_detonate"
	}
)
add_viewmodel(
	"Battle Axe",
	"rbxassetid://93390542043222",
	"rbxassetid://78364101927650",
	nil,
	"rbxassetid://89974468602998",
	2,
	nil,
	"battleaxe_equip",
	"battleaxe_idle",
	"battleaxe_sprint",
	"battleaxe_inspect",
	nil,
	{
		Attack1 = "battleaxe_attack1",
		Attack2 = "battleaxe_attack2",
		SpinAttack = "battleaxe_spinattack"
	}
)
add_viewmodel(
	"The Shred",
	"rbxassetid://71234381808727",
	"rbxassetid://95922136476180",
	nil,
	nil,
	nil,
	nil,
	"battleaxe_equip",
	"battleaxe_idle",
	"battleaxe_sprint",
	"battleaxe_theshred_inspect",
	nil,
	{
		Attack1 = "battleaxe_theshred_attack1",
		Attack2 = "battleaxe_theshred_attack2",
		SpinAttack = "battleaxe_theshred_spinattack"
	}
)
add_viewmodel(
	"Nordic Axe",
	"rbxassetid://80052264197135",
	"rbxassetid://86476943038006",
	nil,
	nil,
	nil,
	nil,
	"battleaxe_equip",
	"battleaxe_idle",
	"battleaxe_sprint",
	"battleaxe_inspect",
	nil,
	{
		Attack1 = "battleaxe_nordicaxe_attack1",
		Attack2 = "battleaxe_nordicaxe_attack2",
		SpinAttack = "battleaxe_nordicaxe_spinattack"
	}
)
add_viewmodel(
	"Ban Axe",
	"rbxassetid://111046431576859",
	"rbxassetid://100159715604530",
	nil,
	nil,
	nil,
	nil,
	"battleaxe_equip",
	"battleaxe_idle",
	"battleaxe_sprint",
	"battleaxe_inspect",
	nil,
	{
		Attack1 = "battleaxe_banaxe_attack1",
		Attack2 = "battleaxe_banaxe_attack2",
		SpinAttack = "battleaxe_banaxe_spinattack"
	}
)
add_viewmodel(
	"Cerulean Axe",
	"rbxassetid://76353832683350",
	"rbxassetid://82989708806032",
	nil,
	nil,
	nil,
	nil,
	"battleaxe_equip",
	"battleaxe_idle",
	"battleaxe_sprint",
	"battleaxe_inspect",
	nil,
	{
		Attack1 = "battleaxe_ceruleanaxe_attack1",
		Attack2 = "battleaxe_ceruleanaxe_attack2",
		SpinAttack = "battleaxe_ceruleanaxe_spinattack"
	}
)
add_viewmodel(
	"Glorious Battle Axe",
	"rbxassetid://87227212476138",
	"rbxassetid://72356106057179",
	nil,
	nil,
	nil,
	nil,
	"battleaxe_equip",
	"battleaxe_idle",
	"battleaxe_sprint",
	"battleaxe_inspect",
	nil,
	{
		Attack1 = "battleaxe_attack1",
		Attack2 = "battleaxe_attack2",
		SpinAttack = "battleaxe_spinattack"
	}
)
add_viewmodel(
	"Mimic Axe",
	"rbxassetid://111717370450373",
	"rbxassetid://96746396437552",
	nil,
	nil,
	nil,
	nil,
	"battleaxe_equip",
	"battleaxe_idle",
	"battleaxe_sprint",
	"battleaxe_inspect",
	nil,
	{
		Attack1 = "battleaxe_mimicaxe_attack1",
		Attack2 = "battleaxe_mimicaxe_attack2",
		SpinAttack = "battleaxe_mimicaxe_spinattack"
	}
)
add_viewmodel(
	"Keyttle Axe",
	"rbxassetid://122117068984402",
	"rbxassetid://100168194779130",
	nil,
	nil,
	nil,
	nil,
	"battleaxe_keyttleaxe_equip",
	"battleaxe_keyttleaxe_idle",
	"battleaxe_keyttleaxe_sprint",
	"battleaxe_keyttleaxe_inspect",
	nil,
	{
		Attack1 = "battleaxe_keyttleaxe_attack1",
		Attack2 = "battleaxe_keyttleaxe_attack2",
		SpinAttack = "battleaxe_keyttleaxe_spinattack"
	}
)
add_viewmodel(
	"Balloon Axe",
	"rbxassetid://102429983628211",
	"rbxassetid://85852980135764",
	nil,
	nil,
	nil,
	nil,
	"battleaxe_equip",
	"battleaxe_idle",
	"battleaxe_sprint",
	"battleaxe_inspect",
	nil,
	{
		Attack1 = "battleaxe_balloonaxe_attack1",
		Attack2 = "battleaxe_balloonaxe_attack2",
		SpinAttack = "battleaxe_balloonaxe_spinattack"
	}
)
add_viewmodel(
	"Street Sign",
	"rbxassetid://121743888148209",
	"rbxassetid://81822645000119",
	nil,
	nil,
	nil,
	nil,
	"battleaxe_equip",
	"battleaxe_idle",
	"battleaxe_sprint",
	"battleaxe_inspect",
	nil,
	{
		Attack1 = "battleaxe_attack1",
		Attack2 = "battleaxe_attack2",
		SpinAttack = "battleaxe_spinattack"
	}
)
add_viewmodel(
	"Tiki Axe",
	"rbxassetid://87247443182820",
	"rbxassetid://89942969656097",
	nil,
	nil,
	nil,
	nil,
	"battleaxe_tikiaxe_equip",
	"battleaxe_idle",
	"battleaxe_sprint",
	"battleaxe_inspect",
	nil,
	{
		Attack1 = "battleaxe_tikiaxe_attack1",
		Attack2 = "battleaxe_tikiaxe_attack2",
		SpinAttack = "battleaxe_tikiaxe_spinattack"
	}
)
add_viewmodel(
	"Riot Shield",
	"rbxassetid://121172272442833",
	"rbxassetid://126785276332335",
	nil,
	"rbxassetid://97178934256596",
	1.75,
	nil,
	"riotshield_equip",
	"riotshield_idle",
	"riotshield_sprint",
	"riotshield_inspect",
	nil,
	{
		Attack1 = "riotshield_attack1",
		Attack2 = "riotshield_attack2",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Door",
	"rbxassetid://79242603995428",
	"rbxassetid://137027368393353",
	nil,
	nil,
	nil,
	nil,
	"riotshield_equip",
	"riotshield_idle",
	"riotshield_sprint",
	"riotshield_inspect",
	nil,
	{
		Attack1 = "riotshield_attack1",
		Attack2 = "riotshield_attack2",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Sled",
	"rbxassetid://73881731607231",
	"rbxassetid://127016476735322",
	nil,
	nil,
	nil,
	nil,
	"riotshield_equip",
	"riotshield_idle",
	"riotshield_sprint",
	"riotshield_inspect",
	nil,
	{
		Attack1 = "riotshield_attack1",
		Attack2 = "riotshield_attack2",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Energy Shield",
	"rbxassetid://90215439337413",
	"rbxassetid://127037252186171",
	nil,
	nil,
	nil,
	nil,
	"riotshield_energyshield_equip",
	"riotshield_idle",
	"riotshield_sprint",
	"riotshield_inspect",
	nil,
	{
		Attack1 = "riotshield_energyshield_attack1",
		Attack2 = "riotshield_energyshield_attack2",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Masterpiece",
	"rbxassetid://79914271483818",
	"rbxassetid://72274483575028",
	nil,
	nil,
	nil,
	nil,
	"riotshield_equip",
	"riotshield_idle",
	"riotshield_sprint",
	"riotshield_inspect",
	nil,
	{
		Attack1 = "riotshield_attack1",
		Attack2 = "riotshield_attack2",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Glorious Riot Shield",
	"rbxassetid://132866851386509",
	"rbxassetid://117405461442739",
	nil,
	nil,
	nil,
	nil,
	"riotshield_equip",
	"riotshield_idle",
	"riotshield_sprint",
	"riotshield_inspect",
	nil,
	{
		Attack1 = "riotshield_attack1",
		Attack2 = "riotshield_attack2",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Tombstone Shield",
	"rbxassetid://125895528641243",
	"rbxassetid://114630737114417",
	nil,
	nil,
	nil,
	nil,
	"riotshield_equip",
	"riotshield_idle",
	"riotshield_sprint",
	"riotshield_inspect",
	nil,
	{
		Attack1 = "riotshield_attack1",
		Attack2 = "riotshield_attack2",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Broken Surfboard",
	"rbxassetid://114987869792187",
	"rbxassetid://100547242019243",
	nil,
	nil,
	nil,
	nil,
	"riotshield_equip",
	"riotshield_idle",
	"riotshield_sprint",
	"riotshield_inspect",
	nil,
	{
		Attack1 = "riotshield_attack1",
		Attack2 = "riotshield_attack2",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Daggers",
	"rbxassetid://91885384580845",
	"rbxassetid://138508026547275",
	nil,
	"rbxassetid://112790625455883",
	2,
	CFrame.new(0, -0.125, -0.125),
	"daggers_equip",
	"daggers_idle",
	"daggers_sprint",
	"daggers_inspect",
	nil,
	{
		Shoot1 = "daggers_shoot1",
		FinalShoot = "daggers_shoot2",
		Reload = "daggers_reload",
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Aces",
	"rbxassetid://139089881483398",
	"rbxassetid://78850921968876",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"daggers_equip",
	"daggers_idle",
	"daggers_sprint",
	"daggers_inspect",
	nil,
	{
		Shoot1 = "daggers_aces_shoot1",
		FinalShoot = "daggers_aces_shoot2",
		Reload = "daggers_aces_reload",
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Cookies",
	"rbxassetid://114482325531769",
	"rbxassetid://112581667413176",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"daggers_equip",
	"daggers_idle",
	"daggers_sprint",
	"daggers_inspect",
	nil,
	{
		Shoot1 = "daggers_shoot1",
		FinalShoot = "daggers_shoot2",
		Reload = "daggers_cookies_reload",
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Crystal Daggers",
	"rbxassetid://126221748659600",
	"rbxassetid://92405854307880",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"daggers_crystaldaggers_equip",
	"daggers_idle",
	"daggers_sprint",
	"daggers_crystaldaggers_inspect",
	nil,
	{
		Shoot1 = "daggers_crystaldaggers_shoot1",
		FinalShoot = "daggers_crystaldaggers_shoot2",
		Reload = "daggers_crystaldaggers_reload",
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Paper Planes",
	"rbxassetid://84003122595879",
	"rbxassetid://90572065167686",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"daggers_equip",
	"daggers_idle",
	"daggers_sprint",
	"daggers_inspect",
	nil,
	{
		Shoot1 = "daggers_shoot1",
		FinalShoot = "daggers_shoot2",
		Reload = "daggers_paperplanes_reload",
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Shurikens",
	"rbxassetid://135574097643275",
	"rbxassetid://118592510576313",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"daggers_equip",
	"daggers_idle",
	"daggers_sprint",
	"daggers_inspect",
	nil,
	{
		Shoot1 = "daggers_shurikens_shoot1",
		FinalShoot = "daggers_shurikens_shoot2",
		Reload = "daggers_reload",
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Glorious Daggers",
	"rbxassetid://76023189104485",
	"rbxassetid://89590724074968",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"daggers_equip",
	"daggers_idle",
	"daggers_sprint",
	"daggers_inspect",
	nil,
	{
		Shoot1 = "daggers_shoot1",
		FinalShoot = "daggers_shoot2",
		Reload = "daggers_reload",
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Bat Daggers",
	"rbxassetid://92001964015225",
	"rbxassetid://137570635514267",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"daggers_equip",
	"daggers_idle",
	"daggers_sprint",
	"daggers_inspect",
	nil,
	{
		Shoot1 = "daggers_batdaggers_shoot1",
		FinalShoot = "daggers_batdaggers_shoot2",
		Reload = "daggers_reload",
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Keynais",
	"rbxassetid://84562761142610",
	"rbxassetid://133742080595679",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"daggers_keynais_equip",
	"daggers_keynais_idle",
	"daggers_keynais_sprint",
	"daggers_keynais_inspect",
	nil,
	{
		Shoot1 = "daggers_keynais_shoot1",
		FinalShoot = "daggers_keynais_shoot2",
		Reload = "daggers_keynais_reload",
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Broken Hearts",
	"rbxassetid://74156924296351",
	"rbxassetid://136682361594607",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"daggers_brokenhearts_equip",
	"daggers_idle",
	"daggers_sprint",
	"daggers_inspect",
	nil,
	{
		Shoot1 = "daggers_brokenhearts_shoot1",
		FinalShoot = "daggers_brokenhearts_shoot2",
		Reload = "daggers_reload",
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Toaster",
	"rbxassetid://103344379002564",
	"rbxassetid://87473023041771",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"daggers_toaster_equip",
	"daggers_toaster_idle",
	"daggers_toaster_sprint",
	"daggers_toaster_inspect",
	nil,
	{
		Shoot1 = "daggers_toaster_shoot1",
		FinalShoot = "daggers_toaster_shoot2",
		Reload = "daggers_toaster_reload",
		EmptyReload = nil,
		EmptyEquip = nil,
		EmptyIdle = nil,
		EmptyInspect = "daggers_toaster_inspect_empty"
	}
)
add_viewmodel(
	"Starfish",
	"rbxassetid://114567820096083",
	"rbxassetid://71333279491287",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"daggers_equip",
	"daggers_idle",
	"daggers_sprint",
	"daggers_inspect",
	nil,
	{
		Shoot1 = "daggers_shoot1",
		FinalShoot = "daggers_shoot2",
		Reload = "daggers_reload",
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Energy Pistols",
	"rbxassetid://79471670126710",
	"rbxassetid://125338509278840",
	nil,
	"rbxassetid://110320793833810",
	2.5,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(10), 0, 0),
	"energypistols_equip",
	"energypistols_idle",
	"energypistols_sprint",
	"energypistols_inspect",
	nil,
	{
		Shoot1 = "energypistols_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Hacker Pistols",
	"rbxassetid://140621407555872",
	"rbxassetid://105705939354438",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(10), 0, 0),
	"energypistols_equip",
	"energypistols_idle",
	"energypistols_sprint",
	"energypistols_inspect",
	nil,
	{
		Shoot1 = "energypistols_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Apex Pistols",
	"rbxassetid://136156057859453",
	"rbxassetid://132394469151873",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(10), 0, 0),
	"energypistols_equip",
	"energypistols_idle",
	"energypistols_sprint",
	"energypistols_inspect",
	nil,
	{
		Shoot1 = "energypistols_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"New Year Energy Pistols",
	"rbxassetid://126589959779039",
	"rbxassetid://88240834599421",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(10), 0, 0),
	"energypistols_equip",
	"energypistols_idle",
	"energypistols_sprint",
	"energypistols_inspect",
	nil,
	{
		Shoot1 = "energypistols_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Void Pistols",
	"rbxassetid://111278471262300",
	"rbxassetid://114821885011907",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(10), 0, 0),
	"energypistols_voidpistols_equip",
	"energypistols_idle",
	"energypistols_sprint",
	"energypistols_voidpistols_inspect",
	nil,
	{
		Shoot1 = "energypistols_voidpistols_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Hydro Pistols",
	"rbxassetid://115281889984097",
	"rbxassetid://102390688726302",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(10), 0, 0),
	"energypistols_equip",
	"energypistols_idle",
	"energypistols_sprint",
	"energypistols_inspect",
	nil,
	{
		Shoot1 = "energypistols_hydropistols_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Glorious Energy Pistols",
	"rbxassetid://114418789647547",
	"rbxassetid://85080210873739",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(10), 0, 0),
	"energypistols_equip",
	"energypistols_idle",
	"energypistols_sprint",
	"energypistols_inspect",
	nil,
	{
		Shoot1 = "energypistols_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Soul Pistols",
	"rbxassetid://72213738067158",
	"rbxassetid://95359207769282",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(10), 0, 0),
	"energypistols_soulpistols_equip",
	"energypistols_idle",
	"energypistols_sprint",
	"energypistols_inspect",
	nil,
	{
		Shoot1 = "energypistols_soulpistols_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Hyperlaser Guns",
	"rbxassetid://106947526362970",
	"rbxassetid://97275763845090",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(10), 0, 0),
	"energypistols_hyperlaserguns_equip",
	"energypistols_idle",
	"energypistols_sprint",
	"energypistols_inspect",
	nil,
	{
		Shoot1 = "energypistols_hyperlaserguns_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Sol Pistols",
	"rbxassetid://115012735954576",
	"rbxassetid://131475504863136",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(10), 0, 0),
	"energypistols_equip",
	"energypistols_idle",
	"energypistols_sprint",
	"energypistols_inspect",
	nil,
	{
		Shoot1 = "energypistols_solpistols_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Enerkey Pistols",
	"rbxassetid://116755982646605",
	"rbxassetid://132598841852147",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.375) * CFrame.Angles(math.rad(10), 0, 0),
	"energypistols_enerkeypistols_equip",
	"energypistols_enerkeypistols_idle",
	"energypistols_enerkeypistols_sprint",
	"energypistols_enerkeypistols_inspect",
	nil,
	{
		Shoot1 = "energypistols_enerkeypistols_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Energy Rifle",
	"rbxassetid://110259279810005",
	"rbxassetid://103736834693278",
	nil,
	"rbxassetid://129961481216137",
	2.5,
	CFrame.new(0, -0.125, -0.125),
	"energyrifle_equip",
	"energyrifle_idle",
	"energyrifle_sprint",
	"energyrifle_inspect",
	nil,
	{
		Shoot1 = "energyrifle_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Hacker Rifle",
	"rbxassetid://122816271917525",
	"rbxassetid://89213922790170",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"energyrifle_equip",
	"energyrifle_idle",
	"energyrifle_sprint",
	"energyrifle_inspect",
	nil,
	{
		Shoot1 = "energyrifle_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Apex Rifle",
	"rbxassetid://88144772234151",
	"rbxassetid://111748806401551",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"energyrifle_equip",
	"energyrifle_idle",
	"energyrifle_sprint",
	"energyrifle_inspect",
	nil,
	{
		Shoot1 = "energyrifle_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"New Year Energy Rifle",
	"rbxassetid://111446782522703",
	"rbxassetid://101868484686291",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"energyrifle_equip",
	"energyrifle_idle",
	"energyrifle_sprint",
	"energyrifle_inspect",
	nil,
	{
		Shoot1 = "energyrifle_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Hydro Rifle",
	"rbxassetid://73690448730060",
	"rbxassetid://101984348353475",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"energyrifle_equip",
	"energyrifle_idle",
	"energyrifle_sprint",
	"energyrifle_inspect",
	nil,
	{
		Shoot1 = "energyrifle_hydrorifle_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Void Rifle",
	"rbxassetid://95985016411441",
	"rbxassetid://107749233395884",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"energyrifle_voidrifle_equip",
	"energyrifle_idle",
	"energyrifle_sprint",
	"energyrifle_inspect",
	nil,
	{
		Shoot1 = "energyrifle_voidrifle_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Glorious Energy Rifle",
	"rbxassetid://72632815443247",
	"rbxassetid://95552510838071",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"energyrifle_equip",
	"energyrifle_idle",
	"energyrifle_sprint",
	"energyrifle_inspect",
	nil,
	{
		Shoot1 = "energyrifle_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Soul Rifle",
	"rbxassetid://129351366788323",
	"rbxassetid://140115840236565",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"energyrifle_soulrifle_equip",
	"energyrifle_idle",
	"energyrifle_sprint",
	"energyrifle_inspect",
	nil,
	{
		Shoot1 = "energyrifle_soulrifle_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Sol Rifle",
	"rbxassetid://96272849525291",
	"rbxassetid://79567441337018",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"energyrifle_equip",
	"energyrifle_idle",
	"energyrifle_sprint",
	"energyrifle_inspect",
	nil,
	{
		Shoot1 = "energyrifle_solrifle_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Enerkey Rifle",
	"rbxassetid://104929541135510",
	"rbxassetid://130531895348468",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.125),
	"energyrifle_enerkeyrifle_equip",
	"energyrifle_enerkeyrifle_idle",
	"energyrifle_enerkeyrifle_sprint",
	"energyrifle_enerkeyrifle_inspect",
	nil,
	{
		Shoot1 = "energyrifle_enerkeyrifle_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Spray",
	"rbxassetid://92882887485248",
	"rbxassetid://87291726953666",
	nil,
	"rbxassetid://100057833634628",
	2.25,
	CFrame.new(0, -0.2, -0.15),
	"spray_equip",
	"spray_idle",
	"spray_sprint",
	"spray_inspect",
	nil,
	{
		Shoot1 = "spray_shoot1",
		FinalShoot = "spray_shoot_final",
		Reload = "spray_reload",
		EmptyReload = "spray_reload_empty"
	}
)
add_viewmodel(
	"Lovely Spray",
	"rbxassetid://131203015026683",
	"rbxassetid://138177960576401",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.2, -0.3),
	"spray_equip",
	"spray_idle",
	"spray_sprint",
	"spray_inspect",
	nil,
	{
		Shoot1 = "spray_shoot1",
		FinalShoot = "spray_shoot_final",
		Reload = "spray_reload",
		EmptyReload = "spray_reload_empty"
	}
)
add_viewmodel(
	"Pine Spray",
	"rbxassetid://128285758736343",
	"rbxassetid://79010014206302",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.2, -0.3),
	"spray_equip",
	"spray_idle",
	"spray_sprint",
	"spray_inspect",
	nil,
	{
		Shoot1 = "spray_pinespray_shoot1",
		FinalShoot = "spray_pinespray_shoot_final",
		Reload = "spray_reload",
		EmptyReload = "spray_reload_empty"
	}
)
add_viewmodel(
	"Nail Gun",
	"rbxassetid://110577809934251",
	"rbxassetid://79527532659144",
	nil,
	nil,
	nil,
	CFrame.new(0.125, -0.2, -0.15),
	"spray_equip",
	"spray_idle",
	"spray_sprint",
	"spray_inspect",
	nil,
	{
		Shoot1 = "spray_nailgun_shoot1",
		FinalShoot = "spray_nailgun_shoot_final",
		Reload = "spray_reload",
		EmptyReload = "spray_nailgun_reload_empty"
	}
)
add_viewmodel(
	"Spray Bottle",
	"rbxassetid://137955019285700",
	"rbxassetid://88384629194597",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.2, -0.15),
	"spray_spraybottle_equip",
	"spray_idle",
	"spray_sprint",
	"spray_inspect",
	nil,
	{
		Shoot1 = "spray_spraybottle_shoot1",
		FinalShoot = "spray_spraybottle_shoot_final",
		Reload = "spray_spraybottle_reload",
		EmptyReload = "spray_spraybottle_reload_empty"
	}
)
add_viewmodel(
	"Glorious Spray",
	"rbxassetid://138246745001490",
	"rbxassetid://103484739840527",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.2, -0.15),
	"spray_equip",
	"spray_idle",
	"spray_sprint",
	"spray_inspect",
	nil,
	{
		Shoot1 = "spray_shoot1",
		FinalShoot = "spray_shoot_final",
		Reload = "spray_reload",
		EmptyReload = "spray_reload_empty"
	}
)
add_viewmodel(
	"Boneclaw Spray",
	"rbxassetid://114078818081911",
	"rbxassetid://127336875478381",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.2, -0.15),
	"spray_equip",
	"spray_idle",
	"spray_sprint",
	"spray_inspect",
	nil,
	{
		Shoot1 = "spray_boneclawspray_shoot1",
		FinalShoot = "spray_boneclawspray_shoot_final",
		Reload = "spray_reload",
		EmptyReload = "spray_reload_empty"
	}
)
add_viewmodel(
	"Key Spray",
	"rbxassetid://94061940442700",
	"rbxassetid://104758575159924",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.1, -0.625),
	"spray_keyspray_equip",
	"spray_keyspray_idle",
	"spray_keyspray_sprint",
	"spray_keyspray_inspect",
	nil,
	{
		Shoot1 = "spray_keyspray_shoot1",
		FinalShoot = "spray_keyspray_shoot_final",
		Reload = "spray_keyspray_reload",
		EmptyReload = "spray_keyspray_reload_empty"
	}
)
add_viewmodel(
	"Campfire Spray",
	"rbxassetid://129294699009828",
	"rbxassetid://121514032743947",
	nil,
	nil,
	nil,
	CFrame.new(-0.125, -0.25, 0.125),
	"spray_campfirespray_equip",
	"spray_campfirespray_idle",
	"spray_campfirespray_sprint",
	"spray_campfirespray_inspect",
	nil,
	{
		Shoot1 = "spray_campfirespray_shoot1",
		FinalShoot = nil,
		Reload = "spray_campfirespray_reload",
		EmptyReload = "spray_campfirespray_reload_empty"
	}
)
add_viewmodel(
	"Crossbow",
	"rbxassetid://140211832612284",
	"rbxassetid://130065160832422",
	nil,
	"rbxassetid://120023204894177",
	3,
	CFrame.new(0.25, -0.375, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"crossbow_equip",
	"crossbow_idle",
	"crossbow_sprint",
	"crossbow_inspect",
	nil,
	{
		Shoot1 = "crossbow_shoot1",
		FinalShoot = nil,
		Reload = "crossbow_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Pixel Crossbow",
	"rbxassetid://115931961841903",
	"rbxassetid://129836248906904",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.375, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"crossbow_pixelcrossbow_equip",
	"crossbow_pixelcrossbow_idle",
	"crossbow_pixelcrossbow_sprint",
	"crossbow_pixelcrossbow_inspect",
	nil,
	{
		Shoot1 = "crossbow_pixelcrossbow_shoot1",
		FinalShoot = nil,
		Reload = "crossbow_pixelcrossbow_reload",
		EmptyReload = nil
	},
	{
		FramesPerSecond = 2,
		PlayAnimationsInstantly = true
	}
)
add_viewmodel(
	"Frostbite Crossbow",
	"rbxassetid://101536997945363",
	"rbxassetid://116171878456521",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.375, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"crossbow_frostbitecrossbow_equip",
	"crossbow_idle",
	"crossbow_sprint",
	"crossbow_inspect",
	nil,
	{
		Shoot1 = "crossbow_frostbitecrossbow_shoot1",
		FinalShoot = nil,
		Reload = "crossbow_frostbitecrossbow_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Harpoon Crossbow",
	"rbxassetid://107460405492001",
	"rbxassetid://127546301627893",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.375, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"crossbow_harpooncrossbow_equip",
	"crossbow_harpooncrossbow_idle",
	"crossbow_harpooncrossbow_sprint",
	"crossbow_harpooncrossbow_inspect",
	nil,
	{
		Shoot1 = "crossbow_harpooncrossbow_shoot1",
		FinalShoot = nil,
		Reload = "crossbow_harpooncrossbow_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Violin Crossbow",
	"rbxassetid://74401302514014",
	"rbxassetid://119666131999240",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.5, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"crossbow_equip",
	"crossbow_violincrossbow_idle",
	"crossbow_sprint",
	"crossbow_inspect",
	"crossbow_violincrossbow_inspect_rare",
	{
		Shoot1 = "crossbow_violincrossbow_shoot1",
		FinalShoot = nil,
		Reload = "crossbow_violincrossbow_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Glorious Crossbow",
	"rbxassetid://70875146419725",
	"rbxassetid://125494419498405",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.375, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"crossbow_equip",
	"crossbow_idle",
	"crossbow_sprint",
	"crossbow_inspect",
	nil,
	{
		Shoot1 = "crossbow_shoot1",
		FinalShoot = nil,
		Reload = "crossbow_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Crossbone",
	"rbxassetid://103469183638638",
	"rbxassetid://81476287380261",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.375, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"crossbow_equip",
	"crossbow_idle",
	"crossbow_sprint",
	"crossbow_inspect",
	nil,
	{
		Shoot1 = "crossbow_shoot1",
		FinalShoot = nil,
		Reload = "crossbow_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Arch Crossbow",
	"rbxassetid://94981733362451",
	"rbxassetid://107213949119266",
	nil,
	nil,
	nil,
	CFrame.new(-0.125, 0.125, -0.875) * CFrame.Angles(math.rad(-2.5), 0, 0),
	"crossbow_archcrossbow_equip",
	"crossbow_archcrossbow_idle",
	"crossbow_archcrossbow_sprint",
	"crossbow_archcrossbow_inspect",
	nil,
	{
		Shoot1 = "crossbow_archcrossbow_shoot1",
		FinalShoot = nil,
		Reload = "crossbow_archcrossbow_reload",
		EmptyReload = nil,
		InspectEmpty = "crossbow_archcrossbow_inspect_empty"
	}
)
add_viewmodel(
	"Campfire Crossbow",
	"rbxassetid://76911697867059",
	"rbxassetid://124546389126498",
	nil,
	nil,
	nil,
	CFrame.new(0.25, -0.375, -0.125) * CFrame.Angles(math.rad(5), 0, 0),
	"crossbow_campfirecrossbow_equip",
	"crossbow_idle",
	"crossbow_sprint",
	"crossbow_inspect",
	nil,
	{
		Shoot1 = "crossbow_shoot1",
		FinalShoot = nil,
		Reload = "crossbow_reload",
		EmptyReload = nil
	}
)
add_viewmodel(
	"Gunblade",
	"rbxassetid://131231034374465",
	"rbxassetid://131462750179690",
	nil,
	"rbxassetid://79528657538147",
	3,
	CFrame.new(0.125, 0, 0) * CFrame.Angles(0, math.rad(2.5), 0),
	"gunblade_equip",
	"gunblade_idle",
	"gunblade_sprint",
	"gunblade_inspect",
	nil,
	{
		Shoot1 = "gunblade_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ToBlade = "gunblade_to_blade",
		BladeEquip = "gunblade_equip_blade",
		BladeIdle = "gunblade_idle_blade",
		BladeSprint = "gunblade_sprint_blade",
		BladeInspect = "gunblade_inspect_blade",
		BladeAttack1 = "gunblade_attack1_blade",
		BladeAttack2 = "gunblade_attack2_blade",
		ToGun1 = "gunblade_to_gun",
		ToGun2 = "gunblade_to_gun2",
		BladeAttackOnHit = "gunblade_attack_blade_onhit",
		BladeAttackOnHitNoAmmo = "gunblade_attack_blade_onhit2",
		Dash = nil
	}
)
add_viewmodel(
	"Hyper Gunblade",
	"rbxassetid://134415898983004",
	"rbxassetid://134499903901922",
	nil,
	nil,
	nil,
	CFrame.new(0.125, 0, 0) * CFrame.Angles(0, math.rad(2.5), 0),
	"gunblade_equip",
	"gunblade_idle",
	"gunblade_sprint",
	"gunblade_inspect",
	nil,
	{
		Shoot1 = "gunblade_hypergunblade_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ToBlade = "gunblade_to_blade",
		BladeEquip = "gunblade_equip_blade",
		BladeIdle = "gunblade_idle_blade",
		BladeSprint = "gunblade_sprint_blade",
		BladeInspect = "gunblade_inspect_blade",
		BladeAttack1 = "gunblade_hypergunblade_attack1_blade",
		BladeAttack2 = "gunblade_hypergunblade_attack2_blade",
		ToGun1 = "gunblade_to_gun",
		ToGun2 = "gunblade_to_gun2",
		BladeAttackOnHit = "gunblade_hypergunblade_attack_blade_onhit",
		BladeAttackOnHitNoAmmo = "gunblade_hypergunblade_attack_blade_onhit2",
		Dash = nil
	}
)
add_viewmodel(
	"Elf's Gunblade",
	"rbxassetid://114103306647123",
	"rbxassetid://81214817732179",
	nil,
	nil,
	nil,
	CFrame.new(0.125, 0, 0) * CFrame.Angles(0, math.rad(2.5), 0),
	"gunblade_equip",
	"gunblade_idle",
	"gunblade_sprint",
	"gunblade_inspect",
	nil,
	{
		Shoot1 = "gunblade_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ToBlade = "gunblade_to_blade",
		BladeEquip = "gunblade_equip_blade",
		BladeIdle = "gunblade_idle_blade",
		BladeSprint = "gunblade_sprint_blade",
		BladeInspect = "gunblade_inspect_blade",
		BladeAttack1 = "gunblade_attack1_blade",
		BladeAttack2 = "gunblade_attack2_blade",
		ToGun1 = "gunblade_to_gun",
		ToGun2 = "gunblade_to_gun2",
		BladeAttackOnHit = "gunblade_attack_blade_onhit",
		BladeAttackOnHitNoAmmo = "gunblade_attack_blade_onhit2",
		Dash = nil
	}
)
add_viewmodel(
	"Crude Gunblade",
	"rbxassetid://126996645502136",
	"rbxassetid://111573250598753",
	nil,
	nil,
	nil,
	CFrame.new(0.125, 0, 0) * CFrame.Angles(0, math.rad(2.5), 0),
	"gunblade_equip",
	"gunblade_idle",
	"gunblade_sprint",
	"gunblade_inspect",
	nil,
	{
		Shoot1 = "gunblade_crudegunblade_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ToBlade = "gunblade_to_blade",
		BladeEquip = "gunblade_equip_blade",
		BladeIdle = "gunblade_idle_blade",
		BladeSprint = "gunblade_sprint_blade",
		BladeInspect = "gunblade_inspect_blade",
		BladeAttack1 = "gunblade_crudegunblade_attack1_blade",
		BladeAttack2 = "gunblade_crudegunblade_attack2_blade",
		ToGun1 = "gunblade_to_gun",
		ToGun2 = "gunblade_to_gun2",
		BladeAttackOnHit = "gunblade_crudegunblade_attack_blade_onhit",
		BladeAttackOnHitNoAmmo = "gunblade_crudegunblade_attack_blade_onhit2",
		Dash = nil
	}
)
add_viewmodel(
	"Gunsaw",
	"rbxassetid://102700915422689",
	"rbxassetid://136642950174663",
	nil,
	nil,
	nil,
	CFrame.new(0.125, 0, 0) * CFrame.Angles(0, math.rad(2.5), 0),
	"gunblade_gunsaw_equip",
	"gunblade_gunsaw_idle",
	"gunblade_gunsaw_sprint",
	"gunblade_gunsaw_inspect",
	nil,
	{
		Shoot1 = "gunblade_gunsaw_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ToBlade = "gunblade_gunsaw_to_blade",
		BladeEquip = "gunblade_gunsaw_equip_blade",
		BladeIdle = "gunblade_gunsaw_idle_blade",
		BladeSprint = "gunblade_gunsaw_sprint_blade",
		BladeInspect = "gunblade_gunsaw_inspect_blade",
		BladeAttack1 = "gunblade_gunsaw_attack1_blade",
		BladeAttack2 = "gunblade_gunsaw_attack2_blade",
		ToGun1 = "gunblade_gunsaw_to_gun",
		ToGun2 = "gunblade_gunsaw_to_gun2",
		BladeAttackOnHit = "gunblade_gunsaw_attack_blade_onhit",
		BladeAttackOnHitNoAmmo = "gunblade_gunsaw_attack_blade_onhit2",
		Dash = nil
	}
)
add_viewmodel(
	"Glorious Gunblade",
	"rbxassetid://88003799126136",
	"rbxassetid://88582922101753",
	nil,
	nil,
	nil,
	CFrame.new(0.125, 0, 0) * CFrame.Angles(0, math.rad(2.5), 0),
	"gunblade_equip",
	"gunblade_idle",
	"gunblade_sprint",
	"gunblade_inspect",
	nil,
	{
		Shoot1 = "gunblade_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ToBlade = "gunblade_to_blade",
		BladeEquip = "gunblade_equip_blade",
		BladeIdle = "gunblade_idle_blade",
		BladeSprint = "gunblade_sprint_blade",
		BladeInspect = "gunblade_inspect_blade",
		BladeAttack1 = "gunblade_attack1_blade",
		BladeAttack2 = "gunblade_attack2_blade",
		ToGun1 = "gunblade_to_gun",
		ToGun2 = "gunblade_to_gun2",
		BladeAttackOnHit = "gunblade_attack_blade_onhit",
		BladeAttackOnHitNoAmmo = "gunblade_attack_blade_onhit2",
		Dash = nil
	}
)
add_viewmodel(
	"Boneblade",
	"rbxassetid://126327381608481",
	"rbxassetid://126287813768518",
	nil,
	nil,
	nil,
	CFrame.new(0.125, 0, 0) * CFrame.Angles(0, math.rad(2.5), 0),
	"gunblade_equip",
	"gunblade_idle",
	"gunblade_sprint",
	"gunblade_inspect",
	nil,
	{
		Shoot1 = "gunblade_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ToBlade = "gunblade_to_blade",
		BladeEquip = "gunblade_equip_blade",
		BladeIdle = "gunblade_idle_blade",
		BladeSprint = "gunblade_sprint_blade",
		BladeInspect = "gunblade_inspect_blade",
		BladeAttack1 = "gunblade_attack1_blade",
		BladeAttack2 = "gunblade_attack2_blade",
		ToGun1 = "gunblade_to_gun",
		ToGun2 = "gunblade_to_gun2",
		BladeAttackOnHit = "gunblade_attack_blade_onhit",
		BladeAttackOnHitNoAmmo = "gunblade_attack_blade_onhit2",
		Dash = nil
	}
)
add_viewmodel(
	"Keyblade",
	"rbxassetid://117153249348040",
	"rbxassetid://131097713481055",
	nil,
	nil,
	nil,
	nil,
	"gunblade_keyblade_equip",
	"gunblade_keyblade_idle",
	"gunblade_keyblade_sprint",
	"gunblade_keyblade_inspect",
	nil,
	{
		Shoot1 = "gunblade_keyblade_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ToBlade = "gunblade_keyblade_to_blade",
		BladeEquip = "gunblade_keyblade_equip_blade",
		BladeIdle = "gunblade_keyblade_idle_blade",
		BladeSprint = "gunblade_keyblade_sprint_blade",
		BladeInspect = "gunblade_keyblade_inspect_blade",
		BladeAttack1 = "gunblade_keyblade_attack1_blade",
		BladeAttack2 = "gunblade_keyblade_attack2_blade",
		ToGun1 = "gunblade_keyblade_to_gun",
		ToGun2 = "gunblade_keyblade_to_gun2",
		BladeAttackOnHit = "gunblade_keyblade_attack_blade_onhit",
		BladeAttackOnHitNoAmmo = "gunblade_keyblade_attack_blade_onhit2",
		Dash = "gunblade_keyblade_dash"
	}
)
add_viewmodel(
	"Sharkbite",
	"rbxassetid://85479471132931",
	"rbxassetid://105863842643669",
	nil,
	nil,
	nil,
	CFrame.new(0.125, 0, 0) * CFrame.Angles(0, math.rad(2.5), 0),
	"gunblade_equip",
	"gunblade_idle",
	"gunblade_sprint",
	"gunblade_inspect",
	nil,
	{
		Shoot1 = "gunblade_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		ToBlade = "gunblade_to_blade",
		BladeEquip = "gunblade_equip_blade",
		BladeIdle = "gunblade_idle_blade",
		BladeSprint = "gunblade_sprint_blade",
		BladeInspect = "gunblade_inspect_blade",
		BladeAttack1 = "gunblade_attack1_blade",
		BladeAttack2 = "gunblade_attack2_blade",
		ToGun1 = "gunblade_to_gun",
		ToGun2 = "gunblade_to_gun2",
		BladeAttackOnHit = "gunblade_attack_blade_onhit",
		BladeAttackOnHitNoAmmo = "gunblade_attack_blade_onhit2",
		Dash = nil
	}
)
add_viewmodel(
	"Jump Pad",
	"rbxassetid://79459600453621",
	"rbxassetid://102532564314723",
	nil,
	"rbxassetid://113965546523164",
	1.5,
	nil,
	"jumppad_equip",
	"jumppad_idle",
	"jumppad_sprint",
	"jumppad_inspect",
	nil,
	{
		Use = "jumppad_use"
	}
)
add_viewmodel(
	"Trampoline",
	"rbxassetid://103567857194140",
	"rbxassetid://92310435035049",
	nil,
	nil,
	nil,
	nil,
	"jumppad_equip",
	"jumppad_idle",
	"jumppad_sprint",
	"jumppad_inspect",
	nil,
	{
		Use = "jumppad_use"
	}
)
add_viewmodel(
	"Bounce House",
	"rbxassetid://71226436012588",
	"rbxassetid://79326657484315",
	nil,
	nil,
	nil,
	nil,
	"jumppad_equip",
	"jumppad_idle",
	"jumppad_sprint",
	"jumppad_inspect",
	nil,
	{
		Use = "jumppad_use"
	}
)
add_viewmodel(
	"Shady Chicken Sandwich",
	"rbxassetid://86361684164972",
	"rbxassetid://113753042073837",
	nil,
	nil,
	nil,
	nil,
	"jumppad_equip",
	"jumppad_idle",
	"jumppad_sprint",
	"jumppad_inspect",
	nil,
	{
		Use = "jumppad_use"
	}
)
add_viewmodel(
	"Glorious Jump Pad",
	"rbxassetid://71803398862947",
	"rbxassetid://96408475917789",
	nil,
	nil,
	nil,
	nil,
	"jumppad_equip",
	"jumppad_idle",
	"jumppad_sprint",
	"jumppad_inspect",
	nil,
	{
		Use = "jumppad_use"
	}
)
add_viewmodel(
	"Spider Web",
	"rbxassetid://84204578032332",
	"rbxassetid://133104747106136",
	nil,
	nil,
	nil,
	nil,
	"jumppad_equip",
	"jumppad_idle",
	"jumppad_sprint",
	"jumppad_inspect",
	nil,
	{
		Use = "jumppad_use"
	}
)
add_viewmodel(
	"Jolly Man",
	"rbxassetid://97375473537804",
	"rbxassetid://98002300428288",
	nil,
	nil,
	nil,
	nil,
	"jumppad_equip",
	"jumppad_idle",
	"jumppad_sprint",
	"jumppad_inspect",
	nil,
	{
		Use = "jumppad_use"
	}
)
add_viewmodel(
	"Flamingo Floatie",
	"rbxassetid://127511599700842",
	"rbxassetid://89246792456166",
	nil,
	nil,
	nil,
	nil,
	"jumppad_equip",
	"jumppad_idle",
	"jumppad_sprint",
	"jumppad_inspect",
	nil,
	{
		Use = "jumppad_use"
	}
)
add_viewmodel(
	"Scepter",
	"rbxassetid://99183402177823",
	"rbxassetid://89220212871603",
	nil,
	"rbxassetid://102084909464865",
	3,
	nil,
	"scepter_equip",
	"scepter_idle",
	"scepter_sprint",
	"scepter_inspect",
	nil,
	{
		Shoot1 = "scepter_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Elixir",
	"rbxassetid://123677194704684",
	"rbxassetid://96734141776078",
	nil,
	"rbxassetid://106686303136827",
	1,
	nil,
	"elixir_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Glass Cannon",
	"rbxassetid://138882843694218",
	"rbxassetid://82999887306387",
	nil,
	"rbxassetid://109359544961471",
	1.5,
	CFrame.new(0, -0.125, -0.2),
	"glasscannon_equip",
	"glasscannon_idle",
	"glasscannon_sprint",
	"glasscannon_inspect",
	nil,
	{
		Shoot1 = "glasscannon_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil,
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptySprint = "fists_sprint",
		EmptyInspect = "fists_inspect"
	}
)
add_viewmodel(
	"Glast Shard",
	"rbxassetid://102980815872652",
	"rbxassetid://136181940429732",
	nil,
	"rbxassetid://89682549635116",
	2,
	nil,
	"knife_karambit_equip",
	"knife_karambit_idle",
	"knife_karambit_sprint",
	"knife_karambit_inspect",
	nil,
	{
		Attack1 = "knife_karambit_attack1",
		Attack2 = "knife_karambit_attack2",
		HeavyAttack1 = "knife_karambit_heavyattack1",
		HeavyAttackAnimationHit = "knife_karambit_heavyattack_hit"
	}
)
add_viewmodel(
	"RNG Dice",
	"rbxassetid://98372867049331",
	"rbxassetid://75601061529918",
	nil,
	"rbxassetid://86815994192766",
	1.5,
	nil,
	"rngdice_equip",
	"rngdice_idle",
	"rngdice_sprint",
	"rngdice_inspect",
	nil,
	{
		Use = "rngdice_use"
	}
)
add_viewmodel(
	"Distortion",
	"rbxassetid://115712150398379",
	"rbxassetid://130153907701944",
	nil,
	"rbxassetid://136813016262803",
	2.5,
	CFrame.new(0, -0, -0.375) * CFrame.Angles(math.rad(2.5), 0, 0),
	"distortion_equip",
	"distortion_idle",
	"distortion_sprint",
	"distortion_inspect",
	nil,
	{
		Shoot1 = "distortion_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Glorious Distortion",
	"rbxassetid://134722661973710",
	"rbxassetid://107736694179886",
	nil,
	nil,
	nil,
	CFrame.new(0, -0, -0.375) * CFrame.Angles(math.rad(2.5), 0, 0),
	"distortion_equip",
	"distortion_idle",
	"distortion_sprint",
	"distortion_inspect",
	nil,
	{
		Shoot1 = "distortion_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Electropunk Distortion",
	"rbxassetid://109544539643046",
	"rbxassetid://91778033503945",
	nil,
	nil,
	nil,
	CFrame.new(0, -0, -0.375) * CFrame.Angles(math.rad(2.5), 0, 0),
	"distortion_equip",
	"distortion_idle",
	"distortion_sprint",
	"distortion_inspect2",
	nil,
	{
		Shoot1 = "distortion_electropunkdistortion_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Experiment D15",
	"rbxassetid://103446773933340",
	"rbxassetid://118366946179457",
	nil,
	nil,
	nil,
	CFrame.new(0, -0, -0.375) * CFrame.Angles(math.rad(2.5), 0, 0),
	"distortion_equip",
	"distortion_idle",
	"distortion_sprint",
	"distortion_inspect",
	nil,
	{
		Shoot1 = "distortion_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Plasma Distortion",
	"rbxassetid://126813935337091",
	"rbxassetid://83622093873798",
	nil,
	nil,
	nil,
	CFrame.new(0, -0, -0.375) * CFrame.Angles(math.rad(2.5), 0, 0),
	"distortion_equip",
	"distortion_idle",
	"distortion_sprint",
	"distortion_inspect2",
	nil,
	{
		Shoot1 = "distortion_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Magma Distortion",
	"rbxassetid://81103807698156",
	"rbxassetid://109079139956898",
	nil,
	nil,
	nil,
	CFrame.new(0, -0, -0.375) * CFrame.Angles(math.rad(2.5), 0, 0),
	"distortion_equip",
	"distortion_idle",
	"distortion_sprint",
	"distortion_inspect2",
	nil,
	{
		Shoot1 = "distortion_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Cyber Distortion",
	"rbxassetid://88995062151276",
	"rbxassetid://78940266607471",
	nil,
	nil,
	nil,
	CFrame.new(0, -0, -0.375) * CFrame.Angles(math.rad(2.5), 0, 0),
	"distortion_equip",
	"distortion_idle",
	"distortion_sprint",
	"distortion_inspect",
	nil,
	{
		Shoot1 = "distortion_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Sleighstortion",
	"rbxassetid://111242141481650",
	"rbxassetid://113075083434001",
	nil,
	nil,
	nil,
	CFrame.new(0, -0, -0.375) * CFrame.Angles(math.rad(2.5), 0, 0),
	"distortion_equip",
	"distortion_idle",
	"distortion_sprint",
	"distortion_inspect",
	nil,
	{
		Shoot1 = "distortion_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Bubble Distortion",
	"rbxassetid://73319804282513",
	"rbxassetid://110018703040757",
	nil,
	nil,
	nil,
	CFrame.new(0, -0, -0.375) * CFrame.Angles(math.rad(2.5), 0, 0),
	"distortion_equip",
	"distortion_idle",
	"distortion_sprint",
	"distortion_inspect2",
	nil,
	{
		Shoot1 = "distortion_bubbledistortion_shoot1",
		FinalShoot = nil,
		Reload = nil,
		EmptyReload = nil
	}
)
add_viewmodel(
	"Warper",
	"rbxassetid://88033795039891",
	"rbxassetid://97537499062821",
	nil,
	"rbxassetid://131943126657510",
	2,
	CFrame.new(0, -0.125, -0.375) * CFrame.Angles(math.rad(5), 0, 0),
	"warper_equip",
	"warper_idle",
	"warper_sprint",
	"warper_inspect",
	nil,
	{
		Shoot1 = "warper_shoot1"
	}
)
add_viewmodel(
	"Glorious Warper",
	"rbxassetid://95823647035211",
	"rbxassetid://117284572803988",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.375) * CFrame.Angles(math.rad(5), 0, 0),
	"warper_equip",
	"warper_idle",
	"warper_sprint",
	"warper_inspect",
	nil,
	{
		Shoot1 = "warper_shoot1"
	}
)
add_viewmodel(
	"Electropunk Warper",
	"rbxassetid://75386728379756",
	"rbxassetid://96080679722284",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.375) * CFrame.Angles(math.rad(5), 0, 0),
	"warper_equip",
	"warper_idle",
	"warper_sprint",
	"warper_inspect",
	nil,
	{
		Shoot1 = "warper_electropunkwarper_shoot1"
	}
)
add_viewmodel(
	"Experiment W4",
	"rbxassetid://126884960764998",
	"rbxassetid://77873591123909",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.375) * CFrame.Angles(math.rad(5), 0, 0),
	"warper_equip",
	"warper_idle",
	"warper_sprint",
	"warper_inspect",
	nil,
	{
		Shoot1 = "warper_shoot1"
	}
)
add_viewmodel(
	"Glitter Warper",
	"rbxassetid://94607497565715",
	"rbxassetid://128289126916762",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.375) * CFrame.Angles(math.rad(5), 0, 0),
	"warper_equip",
	"warper_idle",
	"warper_sprint",
	"warper_inspect",
	nil,
	{
		Shoot1 = "warper_shoot1"
	}
)
add_viewmodel(
	"Arcane Warper",
	"rbxassetid://83632373572638",
	"rbxassetid://92765478127490",
	nil,
	nil,
	nil,
	CFrame.new(0, 0, -0.375) * CFrame.Angles(math.rad(5), 0, 0),
	"warper_arcanewarper_equip",
	"warper_arcanewarper_idle",
	"warper_arcanewarper_sprint",
	"warper_arcanewarper_inspect",
	nil,
	{
		Shoot1 = "warper_arcanewarper_shoot1"
	}
)
add_viewmodel(
	"Hotel Bell",
	"rbxassetid://117742703173821",
	"rbxassetid://74303585805484",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.375) * CFrame.Angles(math.rad(5), 0, 0),
	"warper_hotelbell_equip",
	"warper_hotelbell_idle",
	"warper_hotelbell_sprint",
	"warper_hotelbell_inspect",
	nil,
	{
		Shoot1 = "warper_hotelbell_shoot1"
	}
)
add_viewmodel(
	"Frost Warper",
	"rbxassetid://70539216094396",
	"rbxassetid://84458438183331",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.375) * CFrame.Angles(math.rad(5), 0, 0),
	"warper_equip",
	"warper_idle",
	"warper_sprint",
	"warper_inspect",
	nil,
	{
		Shoot1 = "warper_shoot1"
	}
)
add_viewmodel(
	"Bubbler",
	"rbxassetid://106002684466857",
	"rbxassetid://85451017537725",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.375, -0.25) * CFrame.Angles(math.rad(5), 0, 0),
	"warper_equip",
	"warper_idle",
	"warper_sprint",
	"warper_inspect",
	nil,
	{
		Shoot1 = "warper_bubbler_shoot1"
	}
)
add_viewmodel(
	"Warpstone",
	"rbxassetid://94035693279005",
	"rbxassetid://99660718217521",
	nil,
	"rbxassetid://114944189821030",
	1.5,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Glorious Warpstone",
	"rbxassetid://137583560042806",
	"rbxassetid://99142505492556",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Unstable Warpstone",
	"rbxassetid://110083777654388",
	"rbxassetid://71896071193185",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Warpeye",
	"rbxassetid://127023603234857",
	"rbxassetid://129554679066276",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"warpstone_warpeye_equip",
	"warpstone_warpeye_idle",
	"warpstone_warpeye_sprint",
	"warpstone_warpeye_inspect",
	nil,
	{
		ThrowStart = "warpstone_warpeye_throw_start",
		ThrowIdle = "warpstone_warpeye_throw_idle",
		ThrowFinish = "warpstone_warpeye_throw_finish",
		LobStart = "warpstone_warpeye_lob_start",
		LobIdle = "warpstone_warpeye_lob_idle",
		LobFinish = "warpstone_warpeye_lob_finish"
	}
)
add_viewmodel(
	"Warpbone",
	"rbxassetid://96452209607150",
	"rbxassetid://132473085580193",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Cyber Warpstone",
	"rbxassetid://133002984228937",
	"rbxassetid://78671282003316",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Teleport Disc",
	"rbxassetid://104608154111107",
	"rbxassetid://81728761431901",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.375),
	"warpstone_teleportdisc_equip",
	"warpstone_teleportdisc_idle",
	"warpstone_teleportdisc_sprint",
	"warpstone_teleportdisc_inspect",
	nil,
	{
		ThrowStart = "warpstone_teleportdisc_throw_start",
		ThrowIdle = "warpstone_teleportdisc_throw_idle",
		ThrowFinish = "warpstone_teleportdisc_throw_finish",
		LobStart = "warpstone_teleportdisc_lob_start",
		LobIdle = "warpstone_teleportdisc_lob_idle",
		LobFinish = "warpstone_teleportdisc_lob_finish"
	}
)
add_viewmodel(
	"Electropunk Warpstone",
	"rbxassetid://75299042976369",
	"rbxassetid://121167052087315",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Warpstar",
	"rbxassetid://102652397897598",
	"rbxassetid://85728240647371",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"warpstone_warpstar_equip",
	"warpstone_warpstar_idle",
	"warpstone_warpstar_sprint",
	"warpstone_warpstar_inspect",
	nil,
	{
		ThrowStart = "warpstone_warpstar_throw_start",
		ThrowIdle = "warpstone_warpstar_throw_idle",
		ThrowFinish = "warpstone_warpstar_throw_finish",
		LobStart = "warpstone_warpstar_lob_start",
		LobIdle = "warpstone_warpstar_lob_idle",
		LobFinish = "warpstone_warpstar_lob_finish"
	}
)
add_viewmodel(
	"Warp Juice",
	"rbxassetid://74381576761026",
	"rbxassetid://87229911094803",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.375),
	"grenade_equip",
	"grenade_idle",
	"grenade_sprint",
	"grenade_inspect",
	nil,
	{
		ThrowStart = "grenade_throw_start",
		ThrowIdle = "grenade_throw_idle",
		ThrowFinish = "grenade_throw_finish",
		LobStart = "grenade_lob_start",
		LobIdle = "grenade_lob_idle",
		LobFinish = "grenade_lob_finish"
	}
)
add_viewmodel(
	"Maul",
	"rbxassetid://81478141693597",
	"rbxassetid://96956174894354",
	"rbxassetid://92218373099093",
	"rbxassetid://92986282671073",
	2,
	nil,
	"maul_equip",
	"maul_idle",
	"maul_sprint",
	"maul_inspect",
	nil,
	{
		Attack1 = "maul_attack1",
		Attack2 = "maul_attack2",
		SlamIntro = "maul_slam_intro",
		SlamLoop = "maul_slam_loop",
		SlamOutro = "maul_slam_outro"
	}
)
add_viewmodel(
	"Sleigh Maul",
	"rbxassetid://114892026951995",
	"rbxassetid://112835874307935",
	nil,
	nil,
	nil,
	nil,
	"maul_equip",
	"maul_idle",
	"maul_sprint",
	"maul_inspect",
	nil,
	{
		Attack1 = "maul_sleighmaul_attack1",
		Attack2 = "maul_sleighmaul_attack2",
		SlamIntro = "maul_slam_intro",
		SlamLoop = "maul_slam_loop",
		SlamOutro = "maul_slam_outro"
	}
)
add_viewmodel(
	"Ice Maul",
	"rbxassetid://100001888078290",
	"rbxassetid://79987597452893",
	nil,
	nil,
	nil,
	nil,
	"maul_equip",
	"maul_idle",
	"maul_sprint",
	"maul_inspect",
	nil,
	{
		Attack1 = "maul_attack1",
		Attack2 = "maul_attack2",
		SlamIntro = "maul_slam_intro",
		SlamLoop = "maul_slam_loop",
		SlamOutro = "maul_slam_outro"
	}
)
add_viewmodel(
	"Glorious Maul",
	"rbxassetid://125917253783002",
	"rbxassetid://109898315901573",
	nil,
	nil,
	nil,
	nil,
	"maul_equip",
	"maul_idle",
	"maul_sprint",
	"maul_inspect",
	nil,
	{
		Attack1 = "maul_attack1",
		Attack2 = "maul_attack2",
		SlamIntro = "maul_slam_intro",
		SlamLoop = "maul_slam_loop",
		SlamOutro = "maul_slam_outro"
	}
)
add_viewmodel(
	"Ban Hammer",
	"rbxassetid://126491383967029",
	"rbxassetid://139055067677915",
	nil,
	nil,
	nil,
	nil,
	"maul_equip",
	"maul_idle",
	"maul_sprint",
	"maul_inspect",
	nil,
	{
		Attack1 = "maul_banhammer_attack1",
		Attack2 = "maul_banhammer_attack2",
		SlamIntro = "maul_slam_intro",
		SlamLoop = "maul_slam_loop",
		SlamOutro = "maul_slam_outro"
	}
)
add_viewmodel(
	"Giant Popsicle",
	"rbxassetid://91916939347642",
	"rbxassetid://73293329481030",
	nil,
	nil,
	nil,
	nil,
	"maul_equip",
	"maul_idle",
	"maul_sprint",
	"maul_inspect",
	nil,
	{
		Attack1 = "maul_attack1",
		Attack2 = "maul_attack2",
		SlamIntro = "maul_slam_intro",
		SlamLoop = "maul_slam_loop",
		SlamOutro = "maul_slam_outro"
	}
)
add_viewmodel(
	"Starforge Maul",
	"rbxassetid://113691709735527",
	"rbxassetid://75908084519560",
	nil,
	nil,
	nil,
	nil,
	"maul_equip",
	"maul_idle",
	"maul_sprint",
	"maul_inspect",
	nil,
	{
		Attack1 = "maul_starforgemaul_attack1",
		Attack2 = "maul_starforgemaul_attack2",
		SlamIntro = "maul_slam_intro",
		SlamLoop = "maul_slam_loop",
		SlamOutro = "maul_slam_outro"
	}
)
add_viewmodel(
	"Clown Hammer",
	"rbxassetid://95487416883384",
	"rbxassetid://126738169262750",
	nil,
	nil,
	nil,
	nil,
	"maul_equip",
	"maul_idle",
	"maul_sprint",
	"maul_inspect",
	nil,
	{
		Attack1 = "maul_attack1",
		Attack2 = "maul_attack2",
		SlamIntro = "maul_slam_intro",
		SlamLoop = "maul_slam_loop",
		SlamOutro = "maul_slam_outro"
	}
)
add_viewmodel(
	"Excalibur",
	"rbxassetid://81905348145140",
	"rbxassetid://104902093629888",
	nil,
	nil,
	nil,
	nil,
	"maul_equip",
	"maul_idle",
	"maul_sprint",
	"maul_inspect",
	nil,
	{
		Attack1 = "maul_attack1",
		Attack2 = "maul_attack2",
		SlamIntro = "maul_slam_intro",
		SlamLoop = "maul_slam_loop",
		SlamOutro = "maul_slam_outro"
	}
)
add_viewmodel(
	"Permafrost",
	"rbxassetid://74353733133888",
	"rbxassetid://78468628083590",
	nil,
	"rbxassetid://112007420940132",
	2.25,
	CFrame.new(0, -0.125, -0.5),
	"permafrost_equip",
	"permafrost_idle",
	"permafrost_sprint",
	"permafrost_inspect",
	nil,
	{
		Shoot1 = "permafrost_shoot1",
		FinalShoot = nil,
		Reload = "permafrost_reload",
		EmptyReload = nil,
		Throw = "permafrost_throw"
	}
)
add_viewmodel(
	"Snowman Permafrost",
	"rbxassetid://100890626643184",
	"rbxassetid://70467865456788",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.5),
	"permafrost_equip",
	"permafrost_idle",
	"permafrost_sprint",
	"permafrost_inspect",
	nil,
	{
		Shoot1 = "permafrost_shoot1",
		FinalShoot = nil,
		Reload = "permafrost_reload",
		EmptyReload = nil,
		Throw = "permafrost_throw"
	}
)
add_viewmodel(
	"Ice Permafrost",
	"rbxassetid://83722160119335",
	"rbxassetid://122848886028890",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.5),
	"permafrost_equip",
	"permafrost_idle",
	"permafrost_sprint",
	"permafrost_inspect",
	nil,
	{
		Shoot1 = "permafrost_shoot1",
		FinalShoot = nil,
		Reload = "permafrost_reload",
		EmptyReload = nil,
		Throw = "permafrost_throw"
	}
)
add_viewmodel(
	"Glorious Permafrost",
	"rbxassetid://119977291442329",
	"rbxassetid://82134252571554",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.5),
	"permafrost_equip",
	"permafrost_idle",
	"permafrost_sprint",
	"permafrost_inspect",
	nil,
	{
		Shoot1 = "permafrost_shoot1",
		FinalShoot = nil,
		Reload = "permafrost_reload",
		EmptyReload = nil,
		Throw = "permafrost_throw"
	}
)
add_viewmodel(
	"Permasand",
	"rbxassetid://108398272946629",
	"rbxassetid://78346736007202",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -1),
	"permafrost_equip",
	"permafrost_idle",
	"permafrost_sprint",
	"permafrost_permasand_inspect",
	nil,
	{
		Shoot1 = "permafrost_permasand_shoot1",
		FinalShoot = nil,
		Reload = "permafrost_permasand_reload",
		EmptyReload = nil,
		Throw = "permafrost_permasand_throw"
	}
)
add_viewmodel(
	"Temporal Permafrost",
	"rbxassetid://124975247676715",
	"rbxassetid://102512211072596",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.5),
	"permafrost_temporalpermafrost_equip",
	"permafrost_idle",
	"permafrost_sprint",
	"permafrost_inspect",
	nil,
	{
		Shoot1 = "permafrost_temporalpermafrost_shoot1",
		FinalShoot = nil,
		Reload = "permafrost_reload",
		EmptyReload = nil,
		Throw = "permafrost_throw"
	}
)
add_viewmodel(
	"Permafrost.rbxm",
	"rbxassetid://77732280270853",
	"rbxassetid://70936739713658",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.5),
	"permafrost_equip",
	"permafrost_idle",
	"permafrost_sprint",
	"permafrost_inspect",
	nil,
	{
		Shoot1 = "permafrost_shoot1",
		FinalShoot = nil,
		Reload = "permafrost_reload",
		EmptyReload = nil,
		Throw = "permafrost_throw"
	}
)
add_viewmodel(
	"Starforge Permafrost",
	"rbxassetid://105290041968367",
	"rbxassetid://125277951481670",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.125, -0.5),
	"permafrost_equip",
	"permafrost_idle",
	"permafrost_sprint",
	"permafrost_inspect",
	nil,
	{
		Shoot1 = "permafrost_starforgepermafrost_shoot1",
		FinalShoot = nil,
		Reload = "permafrost_reload",
		EmptyReload = nil,
		Throw = "permafrost_throw"
	}
)
add_viewmodel(
	"Grappler",
	"rbxassetid://103255844976245",
	"rbxassetid://87568033383502",
	nil,
	"rbxassetid://133662495148200",
	2,
	CFrame.new(-0.125, -0.25, -0.25),
	"grappler_equip",
	"grappler_idle",
	"grappler_sprint",
	"grappler_inspect",
	nil,
	{
		Shoot = "grappler_shoot",
		ShootWaiting = nil,
		ShootMissed = nil,
		Pull = "grappler_pull"
	}
)
add_viewmodel(
	"Lasso",
	"rbxassetid://77061966583531",
	"rbxassetid://108092530029598",
	nil,
	nil,
	nil,
	CFrame.new(-0.125, 0.25, -0.25),
	"grappler_lasso_equip",
	"grappler_lasso_idle",
	"grappler_lasso_sprint",
	"grappler_lasso_inspect",
	nil,
	{
		Shoot = "grappler_lasso_shoot",
		ShootWaiting = "grappler_lasso_shoot_waiting",
		ShootMissed = "grappler_lasso_shoot_missed",
		Pull = "grappler_lasso_pull"
	}
)
add_viewmodel(
	"Glorious Grappler",
	"rbxassetid://113576961532090",
	"rbxassetid://88153994788904",
	nil,
	nil,
	nil,
	CFrame.new(-0.125, -0.25, -0.25),
	"grappler_equip",
	"grappler_idle",
	"grappler_sprint",
	"grappler_inspect",
	nil,
	{
		Shoot = "grappler_shoot",
		ShootWaiting = nil,
		ShootMissed = nil,
		Pull = "grappler_pull"
	}
)
add_viewmodel(
	"Lifeguard Grappler",
	"rbxassetid://91214316625102",
	"rbxassetid://88452918330544",
	nil,
	nil,
	nil,
	CFrame.new(-0.125, -0.25, -0.25),
	"grappler_equip",
	"grappler_idle",
	"grappler_sprint",
	"grappler_inspect2",
	nil,
	{
		Shoot = "grappler_shoot",
		ShootWaiting = nil,
		ShootMissed = nil,
		Pull = "grappler_pull"
	}
)
add_viewmodel(
	"Fishing Rod",
	"rbxassetid://86648406311812",
	"rbxassetid://117073216031732",
	nil,
	nil,
	nil,
	CFrame.new(-0.125, -0.25, -0.25),
	"grappler_fishingrod_equip",
	"grappler_fishingrod_idle",
	"grappler_fishingrod_sprint",
	"grappler_fishingrod_inspect",
	nil,
	{
		Shoot = "grappler_fishingrod_shoot",
		ShootWaiting = "grappler_fishingrod_shoot_waiting",
		ShootMissed = "grappler_fishingrod_shoot_missed",
		Pull = "grappler_fishingrod_pull"
	}
)
add_viewmodel(
	"Genie Lamp",
	"rbxassetid://118514051859760",
	"rbxassetid://109485237618085",
	nil,
	nil,
	nil,
	CFrame.new(-0.125, -0.25, -0.25),
	"grappler_genielamp_equip",
	"grappler_genielamp_idle",
	"grappler_genielamp_sprint",
	"grappler_genielamp_inspect",
	nil,
	{
		Shoot = "grappler_genielamp_shoot",
		ShootWaiting = "grappler_genielamp_shoot_waiting",
		ShootMissed = nil,
		Pull = "grappler_genielamp_pull"
	}
)
add_viewmodel(
	"Arcade Claw",
	"rbxassetid://81529455948004",
	"rbxassetid://103015494369795",
	nil,
	nil,
	nil,
	CFrame.new(-0.125, -0.25, -0.25),
	"grappler_arcadeclaw_equip",
	"grappler_arcadeclaw_idle",
	"grappler_arcadeclaw_sprint",
	"grappler_arcadeclaw_inspect",
	nil,
	{
		Shoot = "grappler_arcadeclaw_shoot",
		ShootWaiting = "grappler_arcadeclaw_shoot_waiting",
		ShootMissed = "grappler_arcadeclaw_shoot_missed",
		Pull = "grappler_arcadeclaw_pull"
	}
)
add_viewmodel(
	"Spear",
	"rbxassetid://122801133017271",
	"rbxassetid://111446720428762",
	"rbxassetid://118645037655070",
	"rbxassetid://133317189223963",
	3.25,
	CFrame.new(-0.25, 0, 0),
	"spear_equip",
	"spear_idle",
	"spear_sprint",
	"spear_inspect",
	nil,
	{
		Attack1 = "spear_attack1",
		Attack2 = "spear_attack2",
		Throw = "spear_throw",
		ThrowFinal = "spear_throw_final",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Giant Pencil",
	"rbxassetid://107812045486260",
	"rbxassetid://76085189198864",
	nil,
	nil,
	nil,
	CFrame.new(-0.25, 0, 0),
	"spear_equip",
	"spear_idle",
	"spear_sprint",
	"spear_inspect",
	nil,
	{
		Attack1 = "spear_attack1",
		Attack2 = "spear_attack2",
		Throw = "spear_throw",
		ThrowFinal = "spear_throw_final",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Studio Light",
	"rbxassetid://70443632958263",
	"rbxassetid://84596578566011",
	nil,
	nil,
	nil,
	CFrame.new(-0.25, 0, 0),
	"spear_equip",
	"spear_idle",
	"spear_sprint",
	"spear_inspect",
	nil,
	{
		Attack1 = "spear_attack1",
		Attack2 = "spear_attack2",
		Throw = "spear_throw",
		ThrowFinal = "spear_throw_final",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Glorious Spear",
	"rbxassetid://98259628954838",
	"rbxassetid://108275754332894",
	nil,
	nil,
	nil,
	CFrame.new(-0.25, 0, 0),
	"spear_equip",
	"spear_idle",
	"spear_sprint",
	"spear_inspect",
	nil,
	{
		Attack1 = "spear_attack1",
		Attack2 = "spear_attack2",
		Throw = "spear_throw",
		ThrowFinal = "spear_throw_final",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Chark Kebab",
	"rbxassetid://74005839754537",
	"rbxassetid://119960723782790",
	nil,
	nil,
	nil,
	CFrame.new(-0.25, 0, 0),
	"spear_equip",
	"spear_idle",
	"spear_sprint",
	"spear_inspect",
	nil,
	{
		Attack1 = "spear_attack1",
		Attack2 = "spear_attack2",
		Throw = "spear_throw",
		ThrowFinal = "spear_throw_final",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Plunger",
	"rbxassetid://82393330699241",
	"rbxassetid://100137022004558",
	nil,
	nil,
	nil,
	CFrame.new(-0.25, 0, 0),
	"spear_equip",
	"spear_idle",
	"spear_sprint",
	"spear_inspect",
	nil,
	{
		Attack1 = "spear_attack1",
		Attack2 = "spear_attack2",
		Throw = "spear_throw",
		ThrowFinal = "spear_throw_final",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Fork",
	"rbxassetid://105821360943308",
	"rbxassetid://99666359128492",
	nil,
	nil,
	nil,
	CFrame.new(-0.25, 0, 0),
	"spear_equip",
	"spear_idle",
	"spear_sprint",
	"spear_inspect",
	nil,
	{
		Attack1 = "spear_attack1",
		Attack2 = "spear_attack2",
		Throw = "spear_throw",
		ThrowFinal = "spear_throw_final",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Thunderpike",
	"rbxassetid://137630900832105",
	"rbxassetid://98009731162020",
	nil,
	nil,
	nil,
	CFrame.new(-0.25, 0, 0),
	"spear_equip",
	"spear_idle",
	"spear_sprint",
	"spear_inspect",
	nil,
	{
		Attack1 = "spear_thunderpike_attack1",
		Attack2 = "spear_thunderpike_attack2",
		Throw = "spear_throw",
		ThrowFinal = "spear_throw_final",
		EmptyEquip = "fists_equip",
		EmptyIdle = "fists_idle",
		EmptyInspect = "fists_inspect",
		EmptySprint = "fists_sprint"
	}
)
add_viewmodel(
	"Wildcat",
	"rbxassetid://77401164737509",
	"rbxassetid://124155708481848",
	nil,
	"rbxassetid://75811955088086",
	2.5,
	CFrame.new(0, -0.25, -0.5),
	"wildcat_state1_equip",
	"wildcat_state1_idle",
	"wildcat_state1_sprint",
	"wildcat_state1_inspect",
	nil,
	{
		Shoot1 = "wildcat_state1_shoot1",
		Reload = "wildcat_state1_reload",
		Reload2 = "wildcat_state2_reload",
		State2Equip = "wildcat_state2_equip",
		State2Idle = "wildcat_state2_idle",
		State2Sprint = "wildcat_state2_sprint",
		State2Inspect = "wildcat_state2_inspect",
		State2Shoot1 = "wildcat_state2_shoot1"
	}
)
add_viewmodel(
	"Glorious Wildcat",
	"rbxassetid://115657943825380",
	"rbxassetid://134370234190592",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.5),
	"wildcat_state1_equip",
	"wildcat_state1_idle",
	"wildcat_state1_sprint",
	"wildcat_state1_inspect",
	nil,
	{
		Shoot1 = "wildcat_state1_shoot1",
		Reload = "wildcat_state1_reload",
		Reload2 = "wildcat_state2_reload",
		State2Equip = "wildcat_state2_equip",
		State2Idle = "wildcat_state2_idle",
		State2Sprint = "wildcat_state2_sprint",
		State2Inspect = "wildcat_state2_inspect",
		State2Shoot1 = "wildcat_state2_shoot1"
	}
)
add_viewmodel(
	"Plasma Wildcat",
	"rbxassetid://88584176541333",
	"rbxassetid://76436412524361",
	nil,
	nil,
	nil,
	CFrame.new(0, -0.25, -0.5),
	"wildcat_state1_equip",
	"wildcat_state1_idle",
	"wildcat_state1_sprint",
	"wildcat_state1_inspect",
	nil,
	{
		Shoot1 = "wildcat_plasmawildcat_state1_shoot1",
		Reload = "wildcat_state1_reload",
		Reload2 = "wildcat_state2_reload",
		State2Equip = "wildcat_state2_equip",
		State2Idle = "wildcat_state2_idle",
		State2Sprint = "wildcat_state2_sprint",
		State2Inspect = "wildcat_state2_inspect",
		State2Shoot1 = "wildcat_plasmawildcat_state2_shoot1"
	}
)

local function add_item(p, status, class, name, equipCooldown, canEliminate, walkSpeedMultiplier, maxDoubleJumps, crosshairType, mobileInputSettings, startShooting, startAiming, quickAttackInputs, p14, options)
	local result = {
		Type = p,
		Status = status,
		Class = class,
		Name = name,
		Image = ItemLibrary.ViewModels[name].Image,
		EquipCooldown = equipCooldown,
		CanEliminate = canEliminate,
		WalkSpeedMultiplier = walkSpeedMultiplier,
		MaxDoubleJumps = maxDoubleJumps,
		CrosshairType = crosshairType,
		MobileInputSettings = mobileInputSettings,
		QuickAttackInputs = quickAttackInputs,
		QuickAttackInputsEasy = p14 or quickAttackInputs,
		InputSpammingEnabled = {
			StartShooting = startShooting,
			StartAiming = startAiming,
			StartReloading = 0.5,
			StartInspecting = false
		}
	}

	for k, v3 in pairs(options or {}) do
		result[k] = v3
	end

	ItemLibrary.Items[name] = result
	table.insert(ItemLibrary.ItemOrder, name)

	if not CONSTANTS.IS_SERVER then
		return result
	end

	if v2[name] then
		warn("[ITEM] Duplicate item name: " .. name)
		return result
	else
		v2[name] = true
	end

	return result
end

local function add_custom(status, class, name, equipCooldown, canEliminate, walkSpeedMultiplier, maxDoubleJumps, crosshairType, mobileInputSettings, startShooting, startAiming, quickAttackInputs, p13, options)
	local v3 = {}

	for k, v4 in pairs(options or {}) do
		v3[k] = v4
	end

	add_item(
		"Custom",
		status,
		class,
		name,
		equipCooldown,
		canEliminate,
		walkSpeedMultiplier,
		maxDoubleJumps,
		crosshairType,
		mobileInputSettings,
		startShooting,
		startAiming,
		quickAttackInputs,
		p13,
		v3
	)
end

add_custom("Prime", "Utility", "Medkit", 0.9, false, 0.9, nil, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, 0, 0, { "StartAiming" }, nil, {
	Cooldown = 90,
	LongHeal = 70,
	LongLength = 6.857,
	LongActionTimestamp = 6,
	QuickHeal = 25,
	QuickLength = 1,
	QuickActionTimestamp = 0.45
})
add_custom("Prime", "Utility", "Subspace Tripmine", 0.5, true, 1, nil, "Default", {
	Inspect = false,
	Shoot = false
}, 0, 0, { "StartShooting" }, nil, {
	Cooldown = 0.5,
	AmmoType = "Tripmine",
	MaxAmmo = 2,
	MaxReach = 3,
	HitboxDelay = 1,
	ExplosionRadius = 12,
	ExplosionDamage = 149,
	CriticalExplosionDamage = 150,
	ExplosionKnockback = 1.5,
	BalancedAmmoRefill = 1
})
add_custom("Prime", "Primary", "Flamethrower", 0.9, true, 0.95, nil, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, 0, 0, { "StartAiming" }, nil, {
	AmmoType = "Fuel",
	DamagePerSecond = 85,
	DamageTicksPerSecond = 10,
	AfterburnDamage = 25,
	AfterburnDuration = 4,
	AfterburnTicks = 8,
	Reach = 26,
	MaxAmmo = 100,
	MaxAmmoReserve = 0,
	AirblastCooldown = 4,
	AirblastKnockback = 1.5,
	AirblastRecoilKnockback = 1.5,
	InternalUseCooldown = 0.25
})
add_custom("Standard", "Utility", "War Horn", 0.4, false, 1, nil, "Default", {
	Inspect = false,
	Shoot = false
}, 0, 0, { "StartShooting" }, nil, {
	Cooldown = 45,
	SpeedBoost = 0.25,
	SpeedBoostDuration = 6,
	UseEndLag = 0.9
})
add_custom("Standard", "Utility", "Jump Pad", 0.5, false, 1, nil, "Default", {
	Inspect = false,
	Shoot = false
}, 0, 0, { "StartShooting" }, nil, {
	Cooldown = 0.5,
	Lifetime = 90,
	Strength = 1,
	AmmoType = "Jump Pad",
	MaxAmmo = 3,
	MaxReach = 32,
	HitboxSize = Vector3.new(11, 11, 2),
	BalancedAmmoRefill = 1
})
add_custom("Contraband", "Utility", "RNG Dice", 0.5, false, 1, nil, "Default", {
	Inspect = false,
	Shoot = false
}, 0, 0, { "StartShooting" }, nil, {
	RollDuration = 0.25,
	Cooldown = 3.75,
	MaxItems = 2
})
add_custom("Contraband", "Secondary", "Warper", 1, false, 1, nil, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, 0, 0, { "StartAiming" }, nil, {
	ShootCooldown = 0.25,
	MaxPortalRange = 512,
	PortalDeadzone = 10,
	PortalDelayedSpawnThreshold = 64,
	PortalDelayedSpawnSecondsPerStud = 0.025
})
add_custom("Contraband", "Utility", "Grappler", 0.5, false, 0.9, nil, "Default", {
	Inspect = false,
	Shoot = false
}, 0, 0, { "StartShooting" }, nil, {
	Cooldown = 8,
	HookSpeed = 128,
	HookRange = 100,
	SelfPullForce = 100,
	EnemyPullForce = 100,
	MissedCooldown = 1
})

local function add_throwable(status, class, name, equipCooldown, canEliminate, walkSpeedMultiplier, maxDoubleJumps, crosshairType, value, value2, cooldown, lifetime, maxAmmo, throwMaxChargeTime, p13, _, throwGravity, lobMaxChargeTime, p16, _, lobGravity, options)
	local v3 = {
		CriticalDamage = value2 or 2,
		UseEndLag = 0.25,
		DirectHitDamage = value or 0,
		Cooldown = cooldown,
		Lifetime = lifetime,
		MaxAmmo = maxAmmo,
		AmmoType = maxAmmo and "Grenade" or nil,
		ThrowMaxChargeTime = throwMaxChargeTime,
		ThrowForceMin = p13,
		ThrowForceMax = p13,
		ThrowGravity = throwGravity,
		LobMaxChargeTime = lobMaxChargeTime,
		LobForceMin = p16,
		LobForceMax = p16,
		LobGravity = lobGravity
	}

	for k, v6 in pairs(options or {}) do
		v3[k] = v6
	end

	add_item(
		"Throwable",
		status,
		class,
		name,
		equipCooldown,
		canEliminate,
		walkSpeedMultiplier,
		maxDoubleJumps,
		crosshairType,
		{
			Inspect = false,
			Shoot = false,
			Aim = false
		},
		0.1,
		0.1,
		{ "StartShooting", "FinishShooting" },
		nil,
		v3
	)
end

add_throwable(
	"Standard",
	"Utility",
	"Grenade",
	0.5,
	true,
	1,
	nil,
	"Default",
	1,
	nil,
	30,
	10,
	nil,
	4,
	100,
	300,
	0.375,
	4,
	50,
	150,
	0.75,
	{
		CanCook = true,
		DetonateDelay = 2,
		ExplosionRadius = 16,
		ExplosionDamage = 75,
		ExplosionKnockback = 1.5
	}
)
add_throwable(
	"Standard",
	"Utility",
	"Molotov",
	0.5,
	true,
	1,
	nil,
	"Default",
	1,
	nil,
	30,
	10,
	nil,
	4,
	100,
	300,
	0.375,
	4,
	50,
	150,
	0.75,
	{
		FireRadius = 16,
		FireDuration = 7,
		SplashDamage = 10,
		DamagePerSecond = 25,
		DamageTicksPerSecond = 10,
		AfterburnDamage = 25,
		AfterburnDuration = 4,
		AfterburnTicks = 8
	}
)
add_throwable(
	"Standard",
	"Utility",
	"Flashbang",
	0.5,
	false,
	1,
	nil,
	"Default",
	1,
	nil,
	0.5,
	10,
	2,
	4,
	100,
	300,
	0.375,
	4,
	50,
	150,
	0.75,
	{
		DetonateDelay = 1.5,
		BlindDuration = 3,
		BalancedAmmoRefill = 1
	}
)
add_throwable(
	"Standard",
	"Utility",
	"Smoke Grenade",
	0.5,
	false,
	1,
	nil,
	"Default",
	1,
	nil,
	0.5,
	10,
	3,
	4,
	100,
	300,
	0.375,
	4,
	50,
	150,
	0.75,
	{
		SmokeRadius = 24,
		SmokeDuration = 15,
		BalancedAmmoRefill = 1
	}
)
add_throwable(
	"Contraband",
	"Utility",
	"Elixir",
	0.5,
	true,
	1,
	nil,
	"Default",
	1,
	nil,
	30,
	10,
	nil,
	4,
	100,
	300,
	0.375,
	4,
	50,
	150,
	0.75,
	{
		SplashRadius = 16,
		Heal = 25,
		HealDuration = 4,
		Damage = 50,
		DamageDuration = 4
	}
)
add_throwable(
	"Standard",
	"Utility",
	"Satchel",
	0,
	true,
	1,
	nil,
	"Default",
	nil,
	0,
	0.5,
	90,
	3,
	4,
	100,
	300,
	0.375,
	4,
	50,
	150,
	0.75,
	{
		ExplosionRadius = 12,
		ExplosionDamage = 25,
		CriticalExplosionDamage = 50,
		ExplosionKnockback = 1.5,
		BalancedAmmoRefill = 1
	}
)
add_throwable(
	"Prime",
	"Utility",
	"Warpstone",
	0.5,
	false,
	1,
	nil,
	"Default",
	1,
	nil,
	30,
	10,
	nil,
	4,
	100,
	300,
	0.375,
	4,
	50,
	150,
	0.75
)

local function add_melee(status, class, name, equipCooldown, canEliminate, walkSpeedMultiplier, maxDoubleJumps, crosshairType, p9, p10, value, value2, attackCooldown, value3, value4, attackDamage, attackReach, p14, p15, p16, options)
	local startAiming = p16 == nil and 0 or p16
	local v4 = {
		AttackMaxHits = p10 or math.huge,
		BurstCount = value or 1,
		BurstCooldown = value2 or 0,
		AttackCooldown = attackCooldown,
		AttackDelay = value3 or 0,
		AttackConeAngle = value4 or 90,
		AttackDamage = attackDamage,
		AttackReach = attackReach
	}

	for k, v7 in pairs(options or {}) do
		v4[k] = v7
	end

	add_item(
		"Melee",
		status,
		class,
		name,
		equipCooldown,
		canEliminate,
		walkSpeedMultiplier,
		maxDoubleJumps,
		crosshairType,
		p9 or {
			Inspect = false,
			Shoot = false
		},
		0,
		startAiming,
		p14 or { "StartShooting" },
		p15,
		v4
	)
end

add_melee(
	"Standard",
	"Melee",
	"Fists",
	0.55,
	true,
	1.05,
	1,
	"Default",
	nil,
	2,
	nil,
	nil,
	0.35,
	nil,
	nil,
	30,
	6,
	nil,
	nil,
	nil
)
add_melee("Standard", "Melee", "Knife", 0.45, true, 1.1, nil, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, nil, nil, nil, 0.6, nil, nil, 40, 6, { "StartAiming" }, nil, nil, {
	HeavyAttackCooldown = 1.25,
	HeavyAttackDamage = 40,
	HeavyAttackReach = 7,
	CriticalDamage = 150
})
add_melee("Standard", "Melee", "Chainsaw", 0.6, true, 0.9, nil, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, nil, nil, nil, 0.6, nil, nil, 60, 6, nil, nil, nil, {
	AmmoType = "Fuel",
	MaxAmmo = 150,
	MaxAmmoReserve = 0,
	HoldSpeedBoostMin = 0.25,
	HoldSpeedBoostMax = 0.85,
	HoldSpeedBoostRampTime = 0.5,
	HoldDamageMultiplier = 3,
	InternalHoldCooldown = 0.25
})
add_melee("Standard", "Melee", "Katana", 0.65, true, 1, nil, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, nil, nil, nil, 0.7, nil, nil, 45, 6, nil, { "StartShooting", "StartAiming" }, nil, {
	DeflectDuration = 1,
	DeflectCooldown = 4,
	DeflectDamageMultiplier = 1
})
add_melee("Standard", "Melee", "Scythe", 1, true, 1, nil, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, nil, nil, nil, 0.7, nil, nil, 35, 6, nil, { "StartShooting", "StartAiming" }, nil, {
	DashCooldown = 4,
	DashDuration = 0.25,
	DashSpeed = 100
})
add_melee("Prime", "Melee", "Trowel", 1, true, 1.1, nil, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, nil, nil, nil, 0.6, nil, nil, 50, 6, nil, { "StartShooting", "StartAiming" }, nil, {
	BuildCooldown = 4,
	BuildReach = 50,
	MaxBricks = 25,
	BrickLifetime = 30
})
add_melee("Standard", "Melee", "Battle Axe", 0.85, true, 0.9, nil, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, nil, nil, nil, 0.7, nil, nil, 55, 6, { "StartAiming" }, nil, nil, {
	SpinCooldown = 4,
	SpinDuration = 0.25,
	SpinSpeed = 75,
	SpinRadius = 10,
	SpinDamage = 30
})
add_melee("Standard", "Melee", "Riot Shield", 1.05, true, 0.9, nil, "Default", {
	Inspect = false,
	Shoot = false
}, nil, nil, nil, 0.7, nil, nil, 25, 6, nil, nil, nil, {
	KnockbackForce = 64,
	MaxAbsorption = 500,
	AbsorptionPercent = 1,
	AmmoType = "Shield",
	NeedsAmmoToAttack = true
})
add_melee("Contraband", "Melee", "Glast Shard", 0.45, true, 1.1, 1, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, nil, nil, nil, 0.6, nil, nil, 1, 6, { "StartAiming" }, nil, nil, {
	HeavyAttackCooldown = 1.25,
	HeavyAttackDamage = 1,
	HeavyAttackReach = 7,
	CriticalDamage = 150
})
add_melee("Prime", "Melee", "Maul", 1, true, 0.8, nil, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, nil, nil, nil, 1, 0.45, nil, 75, 8, nil, nil, nil, {
	KnockbackForce = 64,
	SlamCooldown = 6,
	SlamRadius = 24,
	SlamDamage = 50,
	SlamEndLag = 1,
	SlamFloorDistance = 8,
	LeapCooldown = 0.25
})
add_melee("Prime", "Melee", "Spear", 1.25, true, 1, nil, "Default", {
	Inspect = false,
	Shoot = false,
	Aim = false
}, nil, 3, 0.075, 0.5, nil, 30, 15, 18, nil, { "StartShooting", "StartAiming" }, nil, {
	NeedsAmmoToAttack = true,
	AmmoType = "Spear",
	MaxAmmo = 3,
	ThrowCooldown = 1,
	ThrowDamage = 25,
	CriticalThrowDamage = 50,
	ThrowKnockbackForce = 80,
	ThrownSpearLength = 5,
	ThrownSpearLifetime = 90
})

local function add_gun(status, class, name, equipCooldown, canEliminate, walkSpeedMultiplier, maxDoubleJumps, crosshairType, p9, p10, value, value2, shootCooldown, p12, criticalDamage, disableTraditionalCrits, shootRecoil, shootAccuracy, value3, value4, value5, value6, p17, value7, value8, p18, p19, p20, value9, raycastBounceAlwaysCrits, value10, value11, raycastDamageDropoffMultiplier, raycastDamageDropoffStartDistance, raycastDamageDropoffEndDistance, projectileType, value12, p26, value13, value14, value15, p27, value16, value17, value18, p28, _, p29, p30, p31, ammoType, maxAmmo, maxAmmoReserve, value19, aimScopePercent, value20, value21, disableTracerEffects, p35, p36, options)
	if not p35 then
		p35 = {
			Inspect = false,
			Shoot = false,
			Aim = true
		}
		p35.Reload = (not maxAmmoReserve or maxAmmoReserve <= 0) and nil
	end

	local startShooting = p9 == nil and 0 or p9
	local startAiming = p10 == nil and 0 or p10
	local isProjectile = projectileType and true or false
	local v7 = AnimationLibrary.Info[ItemLibrary.ViewModels[name].Animations.Reload]
	local v8 = AnimationLibrary.Info[ItemLibrary.ViewModels[name].Animations.ReloadStart]
	local v9 = AnimationLibrary.Info[ItemLibrary.ViewModels[name].Animations.ReloadSegment]
	local v10 = AnimationLibrary.Info[ItemLibrary.ViewModels[name].Animations.ReloadFinish]
	local v11 = AnimationLibrary.Info[ItemLibrary.ViewModels[name].Animations.Reload2]
	local v12 = AnimationLibrary.Info[ItemLibrary.ViewModels[name].Animations.EmptyReload]
	local v13 = AnimationLibrary.Info[ItemLibrary.ViewModels[name].Animations.EmptyReloadStart]
	local v14 = AnimationLibrary.Info[ItemLibrary.ViewModels[name].Animations.EmptyReloadSegment]
	local v15 = AnimationLibrary.Info[ItemLibrary.ViewModels[name].Animations.EmptyReloadFinish]
	local reloadType = v7 and "Regular" or v8 and "Segmented" or nil
	local v17 = {
		CriticalDamage = criticalDamage,
		DisableTraditionalCrits = disableTraditionalCrits,
		BurstCount = value or 1,
		BurstCooldown = value2 or 0,
		ShootCooldown = shootCooldown,
		ShootDamage = p12,
		ShootRecoil = shootRecoil,
		ShootAccuracy = shootAccuracy,
		ShootExplosionRadius = value3 or 0,
		ShootExplosionDamage = p12,
		ShootExplosionKnockback = value4 or 1,
		ShootPellets = value5 or 1,
		ShootSpread = value6 or 0.5,
		ShootSpreadConsistent = p17 or false,
		ShootSpreadPerVelocityUnit = value7 or 0,
		ShootSpreadPerVelocityLimit = value8 or 0,
		ShootCameraDisplacementRecoil = p18 or Vector2.zero,
		ShootCameraDisplacementRecoilWhileAiming = p19 or nil,
		IsRaycast = not isProjectile,
		RaycastGrabSmallHitboxes = p20 or false,
		RaycastBounceCount = value9 or 0,
		RaycastBounceAlwaysCrits = raycastBounceAlwaysCrits,
		RaycastBounceRedirectionAngle = math.rad(value10 or 0) / 2,
		RaycastPierceCount = value11 or 0,
		RaycastDamageDropoffMultiplier = raycastDamageDropoffMultiplier,
		RaycastDamageDropoffStartDistance = raycastDamageDropoffStartDistance,
		RaycastDamageDropoffEndDistance = raycastDamageDropoffEndDistance,
		IsProjectile = isProjectile,
		ProjectileType = projectileType,
		ProjectileSpeed = value13 or 300,
		ProjectileGravity = value14 or 0,
		ProjectileMaxHits = value15 or 1,
		ProjectileSpawnOffset = p27 or CFrame.new(0, 0, -3),
		ProjectileGrowthSpeed = value16 or 0,
		ProjectileGrowthLimit = value17 or 1,
		ProjectileLifetime = value18 or 5,
		ProjectileDontExplodeOnImpact = p28 or false,
		ProjectileWallClipPreventionEnabled = true,
		ProjectileLogicDisabled = p29 or false,
		ProjectileLogicOptimized = p30 or false,
		ProjectilePhysicalClientSided = p26 or false,
		ProjectileRaycastRadius = value12 or 1,
		DamageType = p31 or value3 and value3 > 0 and "Splash" or isProjectile and "Projectile" or "Bullet",
		AmmoType = ammoType,
		MaxAmmo = maxAmmo,
		MaxAmmoReserve = maxAmmoReserve,
		ReloadType = reloadType,
		NumReloadFiles = ((v7 or v8) and 1 or 0) + (v11 and 1 or 0),
		NumEmptyReloadFiles = (reloadType == "Regular" and v12 ~= nil or reloadType == "Segmented" and v13 ~= nil) and 1 or 0
	}
	local actionTimestamp

	if v7 then
		actionTimestamp = v7.ActionTimestamp
	end

	local length

	if v7 then
		length = v7.Length
	end

	local startActionTimestamp

	if v8 then
		startActionTimestamp = v8.ActionTimestamp
	end

	local startLength

	if v8 then
		startLength = v8.Length
	end

	local segmentActionTimestamp

	if v9 then
		segmentActionTimestamp = v9.ActionTimestamp
	end

	local segmentLength

	if v9 then
		segmentLength = v9.Length
	end

	local finishActionTimestamp

	if v10 then
		finishActionTimestamp = v10.ActionTimestamp
	end

	local finishLength

	if v10 then
		finishLength = v10.Length
	end

	local actionTimestamp2

	if v11 then
		actionTimestamp2 = v11.ActionTimestamp
	end

	local length2

	if v11 then
		length2 = v11.Length
	end

	local actionTimestamp3

	if v12 then
		actionTimestamp3 = v12.ActionTimestamp
	end

	local length3

	if v12 then
		length3 = v12.Length
	end

	local startActionTimestamp2

	if v13 then
		startActionTimestamp2 = v13.ActionTimestamp
	end

	local startLength2

	if v13 then
		startLength2 = v13.Length
	end

	local segmentActionTimestamp2

	if v14 then
		segmentActionTimestamp2 = v14.ActionTimestamp
	end

	local segmentLength2

	if v14 then
		segmentLength2 = v14.Length
	end

	local finishActionTimestamp2

	if v15 then
		finishActionTimestamp2 = v15.ActionTimestamp
	end

	local finishLength2

	if v15 then
		finishLength2 = v15.Length
	end

	v17.ReloadFiles = {
		Reload = {
			{
				ActionTimestamp = actionTimestamp,
				Length = length,
				StartActionTimestamp = startActionTimestamp,
				StartLength = startLength,
				SegmentActionTimestamp = segmentActionTimestamp,
				SegmentLength = segmentLength,
				FinishActionTimestamp = finishActionTimestamp,
				FinishLength = finishLength
			},
			{
				ActionTimestamp = actionTimestamp2,
				Length = length2
			}
		},
		EmptyReload = {
			{
				ActionTimestamp = actionTimestamp3,
				Length = length3,
				StartActionTimestamp = startActionTimestamp2,
				StartLength = startLength2,
				SegmentActionTimestamp = segmentActionTimestamp2,
				SegmentLength = segmentLength2,
				FinishActionTimestamp = finishActionTimestamp2,
				FinishLength = finishLength2
			}
		}
	}
	v17.AimFOVOffset = value21 or -50
	v17.AimSpeed = value19 or 1
	v17.AimScopePercent = aimScopePercent
	v17.AimSpreadMultiplier = value20 or 0
	v17.DisableTracerEffects = disableTracerEffects

	for k, v42 in pairs(options or {}) do
		v17[k] = v42
	end

	add_item(
		"Gun",
		status,
		class,
		name,
		equipCooldown,
		canEliminate,
		walkSpeedMultiplier,
		maxDoubleJumps,
		crosshairType,
		p35,
		startShooting,
		startAiming,
		p36 or { "StartShooting" },
		nil,
		v17
	)
end

add_gun(
	"Standard",
	"Primary",
	"MISSING_WEAPON",
	0.65,
	true,
	0.9,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.1,
	12,
	15,
	nil,
	1,
	1,
	nil,
	nil,
	nil,
	1,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	0.25,
	50,
	200,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Medium",
	20,
	100,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Secondary",
	"Flare Gun",
	1.3,
	true,
	1.1,
	nil,
	"Default",
	false,
	nil,
	nil,
	nil,
	0.25,
	nil,
	nil,
	nil,
	2.5,
	0.75,
	8,
	0,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"PhysicalProjectile",
	nil,
	nil,
	150,
	0.5,
	nil,
	CFrame.new(1, -1, -3) * CFrame.Angles(math.rad(4), 0, 0),
	nil,
	nil,
	30,
	nil,
	nil,
	true,
	nil,
	nil,
	"Shells",
	1,
	1,
	nil,
	nil,
	nil,
	-40,
	nil,
	nil,
	nil,
	{
		DamagePerSecond = 50,
		DamageTicksPerSecond = 10,
		AfterburnDamage = 25,
		AfterburnDuration = 4,
		AfterburnTicks = 8
	}
)
add_gun(
	"Standard",
	"Primary",
	"Assault Rifle",
	0.65,
	true,
	0.9,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.1,
	12,
	15,
	nil,
	1,
	1,
	nil,
	nil,
	nil,
	1,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	0.25,
	50,
	200,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Medium",
	20,
	100,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Secondary",
	"Handgun",
	0.2,
	true,
	1,
	nil,
	"Default",
	false,
	nil,
	nil,
	nil,
	0.13,
	12,
	15,
	nil,
	1,
	1,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	0.25,
	50,
	125,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Light",
	13,
	91,
	nil,
	nil,
	nil,
	-40,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Primary",
	"Burst Rifle",
	0.75,
	true,
	0.9,
	nil,
	"Default",
	nil,
	nil,
	3,
	0.08,
	0.6,
	20,
	25,
	nil,
	1.5,
	0.75,
	nil,
	nil,
	nil,
	2,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	0.25,
	60,
	200,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Medium",
	12,
	60,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Primary",
	"Sniper",
	1.15,
	true,
	0.8,
	nil,
	"Default",
	false,
	false,
	nil,
	nil,
	1.5,
	50,
	150,
	nil,
	10,
	0.2,
	nil,
	nil,
	nil,
	15,
	nil,
	nil,
	nil,
	nil,
	nil,
	true,
	nil,
	nil,
	nil,
	9,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Heavy",
	4,
	12,
	0.55,
	0.925,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Primary",
	"RPG",
	1,
	true,
	0.85,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.25,
	50,
	100,
	nil,
	5,
	0.4,
	16,
	1.5,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"RaycastProjectile",
	nil,
	nil,
	100,
	nil,
	nil,
	CFrame.new(1, -1, -3),
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Rockets",
	1,
	17,
	0.625,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Secondary",
	"Shorty",
	0.6,
	true,
	1,
	nil,
	"SpreadH",
	false,
	nil,
	nil,
	nil,
	0.125,
	75,
	112.5,
	nil,
	5,
	0.25,
	nil,
	nil,
	10,
	6.5,
	true,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	0.333,
	10,
	25,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Shells",
	2,
	18,
	nil,
	nil,
	0.75,
	-40,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Primary",
	"Shotgun",
	0.75,
	true,
	1,
	nil,
	"Spread",
	false,
	false,
	nil,
	nil,
	0.7,
	80,
	120,
	nil,
	2.5,
	0.75,
	nil,
	nil,
	10,
	6.5,
	true,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	2,
	0.333,
	10,
	50,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Shells",
	7,
	35,
	nil,
	nil,
	0.75,
	-20,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Primary",
	"Bow",
	0.85,
	true,
	1.05,
	1,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.25,
	30,
	60,
	nil,
	0,
	1,
	nil,
	nil,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"RaycastProjectile",
	0.25,
	true,
	300,
	0.25,
	nil,
	CFrame.new(0, -1, -2),
	100,
	6,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Arrows",
	1,
	30,
	nil,
	nil,
	nil,
	nil,
	nil,
	{
		Inspect = false,
		Shoot = false,
		Aim = false,
		Reload = false
	},
	nil,
	{
		ChargeReleaseCooldown = 1,
		ChargeReleaseReloadTimestamp = 0.65,
		ChargeLevelTimestamps = {
			0,
			0.3,
			1,
			1.8
		},
		ChargeLevelDamageMultipliers = {
			1,
			1.25,
			1.5,
			2
		}
	}
)
add_gun(
	"Standard",
	"Secondary",
	"Uzi",
	0.45,
	true,
	1,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.07,
	8,
	10,
	nil,
	1,
	0.8,
	nil,
	nil,
	nil,
	1,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	0.25,
	50,
	125,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Light",
	27,
	108,
	1.5,
	nil,
	0.5,
	-40,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Secondary",
	"Revolver",
	0.6,
	true,
	0.95,
	nil,
	"Default",
	false,
	nil,
	nil,
	nil,
	0.4,
	30,
	40,
	nil,
	2,
	3,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	0.25,
	75,
	200,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Light",
	6,
	36,
	nil,
	nil,
	nil,
	-40,
	nil,
	{
		Inspect = false,
		Shoot = false,
		Aim = false,
		Reload = false
	},
	nil,
	{
		QuickShotCooldown = 0.15,
		QuickShotSpread = 10
	}
)
add_gun(
	"Prime",
	"Primary",
	"Paintball Gun",
	0.8,
	true,
	0.9,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.15,
	22,
	nil,
	nil,
	0.5,
	2,
	nil,
	nil,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"RaycastProjectile",
	0.25,
	nil,
	550,
	0,
	1,
	CFrame.new(1, -1.5, -3),
	100,
	7.5,
	nil,
	nil,
	nil,
	nil,
	true,
	nil,
	"Ball",
	16,
	48,
	nil,
	nil,
	nil,
	-20,
	nil,
	{
		Inspect = false,
		Shoot = false,
		Aim = false,
		Reload = false
	},
	{ "StartAiming" },
	{
		GrenadeShootCooldown = 0.75,
		GrenadeCooldown = 8,
		GrenadeExplosionRadius = 12
	}
)
add_gun(
	"Prime",
	"Secondary",
	"Slingshot",
	0.45,
	true,
	1.1,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.1,
	8,
	12,
	nil,
	0.5,
	1.5,
	nil,
	nil,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"RaycastProjectile",
	0.375,
	nil,
	300,
	1,
	3,
	CFrame.new(0, -2, -3) * CFrame.Angles(math.rad(4), 0, 0),
	100,
	3.333,
	nil,
	nil,
	true,
	nil,
	true,
	nil,
	"Ball",
	99,
	0,
	nil,
	nil,
	nil,
	-10,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Prime",
	"Primary",
	"Grenade Launcher",
	1,
	true,
	0.9,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.6,
	40,
	80,
	nil,
	4,
	0.75,
	14,
	1.25,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"RaycastProjectile",
	0.375,
	nil,
	90,
	0.25,
	math.huge,
	CFrame.new(0.5, -1, -3) * CFrame.Angles(math.rad(4), 0, 0),
	nil,
	nil,
	10,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Shells",
	6,
	24,
	0.75,
	nil,
	nil,
	-15,
	nil,
	{
		Inspect = false,
		Shoot = false,
		Aim = false,
		Reload = false
	},
	nil,
	nil
)
add_gun(
	"Prime",
	"Primary",
	"Minigun",
	1,
	true,
	0.75,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.05,
	8,
	10,
	nil,
	1,
	1,
	nil,
	nil,
	nil,
	2,
	nil,
	0.18,
	2,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	2,
	0.5,
	50,
	200,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Heavy",
	300,
	0,
	0.15,
	nil,
	0.5,
	-5,
	nil,
	nil,
	nil,
	{
		ChargingSpeedBoost = -0.5,
		ChargingWindUpLength = 0.8
	}
)
add_gun(
	"Prime",
	"Secondary",
	"Exogun",
	0.7,
	true,
	1,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.28,
	10,
	20,
	nil,
	2,
	1,
	6.28,
	0,
	nil,
	0.628,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	0.2143,
	60,
	280,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Ball",
	6,
	28,
	nil,
	nil,
	nil,
	-30,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Utility",
	"Freeze Ray",
	0.5,
	false,
	1,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.5,
	0,
	nil,
	nil,
	2,
	1,
	16,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"PhysicalProjectile",
	nil,
	nil,
	75,
	0.25,
	nil,
	CFrame.new(0.5, -0.5, -3) * CFrame.Angles(math.rad(4), 0, 0),
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Ball",
	1,
	0,
	nil,
	nil,
	nil,
	-30,
	nil,
	nil,
	{ "StartShooting" },
	{
		FreezeDuration = 4,
		SlowDuration = 2.5,
		SlowBoost = -0.5
	}
)
add_gun(
	"Contraband",
	"Secondary",
	"Scepter",
	1,
	true,
	1,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.5,
	25,
	nil,
	nil,
	0,
	1,
	12,
	0,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"PhysicalProjectile",
	nil,
	true,
	200,
	0,
	nil,
	CFrame.new(1, -1, 0),
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Ball",
	30,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	{
		TransformDelay = 0.5
	}
)
add_gun(
	"Standard",
	"Secondary",
	"Daggers",
	0.6,
	true,
	1.1,
	1,
	"Default",
	nil,
	nil,
	2,
	0.1,
	0.6,
	20,
	40,
	nil,
	0,
	1,
	nil,
	nil,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"RaycastProjectile",
	0.25,
	true,
	300,
	0.25,
	nil,
	CFrame.new(0, -1, -2) * CFrame.Angles(math.rad(4), 0, 0),
	100,
	6,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Daggers",
	2,
	60,
	nil,
	nil,
	nil,
	nil,
	nil,
	{
		Inspect = false,
		Shoot = false,
		Reload = false
	},
	nil,
	nil
)
add_gun(
	"Prime",
	"Secondary",
	"Energy Pistols",
	0.6,
	true,
	1,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.03,
	2.1,
	2.625,
	nil,
	0.2,
	1,
	nil,
	nil,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Light",
	math.huge,
	0,
	nil,
	nil,
	nil,
	-20,
	true,
	nil,
	nil,
	nil
)
add_gun(
	"Prime",
	"Primary",
	"Energy Rifle",
	1.05,
	true,
	1,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.3,
	20,
	25,
	nil,
	2,
	1,
	nil,
	nil,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	2,
	nil,
	15,
	9,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Medium",
	math.huge,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Secondary",
	"Spray",
	0.45,
	true,
	1.05,
	nil,
	"Default",
	nil,
	nil,
	5,
	0.04,
	0.5,
	8,
	10,
	nil,
	2,
	0.75,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	0.25,
	50,
	125,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Light",
	30,
	90,
	1.25,
	nil,
	nil,
	-40,
	nil,
	nil,
	nil,
	{
		DealsTrueDamage = true
	}
)
add_gun(
	"Standard",
	"Primary",
	"Crossbow",
	1.15,
	true,
	1.05,
	nil,
	"Default",
	false,
	false,
	nil,
	nil,
	1,
	37.5,
	75,
	nil,
	1,
	0.2,
	nil,
	nil,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Projectile",
	"Arrows",
	1,
	20,
	0.75,
	0.875,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil
)
add_gun(
	"Standard",
	"Primary",
	"Gunblade",
	1,
	true,
	1,
	nil,
	"Default",
	nil,
	false,
	nil,
	nil,
	0.75,
	45,
	55,
	nil,
	3,
	1,
	nil,
	nil,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Medium",
	12,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	{
		Inspect = false,
		Shoot = false,
		Aim = true
	},
	nil,
	{
		TransitionCooldown = 0.6,
		BladeDamage = 35,
		BladeCriticalDamage = 50,
		BladeCooldown = 0.5,
		BladeReach = 8,
		BladeMaxHits = math.huge,
		DashCooldown = 1.5,
		DashDuration = 0.1875,
		DashSpeed = 100,
		BladeModeMobileInputSettings = {
			Inspect = false,
			Shoot = false,
			Aim = false
		}
	}
)
add_gun(
	"Contraband",
	"Secondary",
	"Glass Cannon",
	0.75,
	true,
	0.95,
	nil,
	"Default",
	false,
	nil,
	nil,
	nil,
	1,
	150,
	nil,
	true,
	15,
	3,
	nil,
	nil,
	nil,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Heavy",
	1,
	0,
	nil,
	nil,
	nil,
	nil,
	nil,
	{
		Inspect = false,
		Shoot = false,
		Reload = false
	},
	nil,
	nil
)
add_gun(
	"Contraband",
	"Primary",
	"Distortion",
	1.25,
	true,
	1,
	nil,
	"SpreadH",
	nil,
	nil,
	nil,
	nil,
	0.4,
	35,
	nil,
	nil,
	1,
	0.5,
	4,
	0,
	5,
	5,
	true,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	90,
	0.25,
	nil,
	CFrame.new(0.5, -1, -3) * CFrame.Angles(math.rad(4), 0, 0),
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Ball",
	45,
	0,
	0.75,
	nil,
	nil,
	nil,
	nil,
	{
		Inspect = false,
		Shoot = false,
		Aim = false
	},
	{ "StartAiming" },
	{
		VortexCooldown = 30,
		VortexRadius = 12,
		VortexLifetime = 4
	}
)
add_gun(
	"Contraband",
	"Primary",
	"Permafrost",
	0.5,
	true,
	1,
	nil,
	"Default",
	nil,
	nil,
	2,
	0.08,
	0.2,
	14,
	17.5,
	nil,
	1,
	1,
	nil,
	0,
	nil,
	1,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	0.25,
	40,
	100,
	nil,
	nil,
	nil,
	75,
	0.25,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Medium",
	24,
	72,
	nil,
	nil,
	nil,
	nil,
	nil,
	{
		Inspect = false,
		Shoot = false,
		Aim = false,
		Reload = false
	},
	nil,
	{
		MaxFreezeDuration = 3,
		SlowDuration = 1.5,
		MaxSlowBoost = -0.5,
		MaxSlowStacks = 8
	}
)
add_gun(
	"Standard",
	"Primary",
	"Wildcat",
	0.45,
	true,
	1.1,
	nil,
	"Default",
	nil,
	nil,
	nil,
	nil,
	0.06,
	10,
	13,
	nil,
	1,
	0.8,
	nil,
	nil,
	nil,
	3,
	nil,
	nil,
	nil,
	Vector2.new(25, 5),
	Vector2.new(10, 2),
	nil,
	nil,
	nil,
	nil,
	nil,
	0.25,
	40,
	100,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"Light",
	30,
	120,
	1.5,
	nil,
	0.3,
	-40,
	nil,
	nil,
	nil,
	nil
)

local function alphabetize()
	for _, v3 in pairs(ItemLibrary.ItemOrder) do
		table.insert(ItemLibrary.ItemsAlphabetized, v3)
	end

	table.sort(ItemLibrary.ItemsAlphabetized, function(a, b)
		return Utility:StringLessThan(string.lower(a), string.lower(b))
	end)
end

alphabetize()

local function animation_check()
	if not (CONSTANTS.IS_STUDIO and CONSTANTS.IS_SERVER) then
		return
	end

	local v3 = {}
	local v4 = {
		grenade_lob = true,
		grenade_lob_pinpull = true,
		grenade_pixelgrenade_lob_start = true,
		grenade_pixelgrenade_throw = true,
		grenade_pixelgrenade_throw_pinpull = true,
		grenade_pixelgrenade_throw_start = true,
		grenade_throw = true,
		grenade_throw_pinpull = true,
		katana_deflect_loop = true,
		katana_sprint = true,
		shotgun_reload_empty_finish = true,
		shotgun_reload_finish2 = true,
		shotgun_shotkey_shoot_aiming = true,
		flamethrower_keythrower_sprint = true,
		maul_charge_intro = true,
		maul_charge_loop = true,
		maul_charge_outro = true,
		maul_sleighmaul_charge_outro = true
	}

	for _, viewModel in pairs(ItemLibrary.ViewModels) do
		for _, animation in pairs(viewModel.Animations) do
			v3[animation] = true
		end
	end

	local v5 = {}

	for k in pairs(AnimationLibrary.Info) do
		if not (v3[k] or v4[k]) then
			v5[k] = true
		end
	end

	if next(v5) then
		warn("[STUDIO] Unused animations:", v5)
	end
end

animation_check()
return ItemLibrary