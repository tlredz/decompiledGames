local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local v = {
	hi = "EY",
	hey = "EY",
	hello = "EY",
	yo = "YO",
	sup = "SUPP",
	i = "ME",
	im = "ME IS",
	["i'm"] = "ME IS",
	me = "ME",
	my = "MY X",
	mine = "MY X",
	you = "U",
	your = "UR",
	yours = "URS",
	youre = "U IS",
	["you're"] = "U IS",
	are = "IS",
	am = "IS",
	is = "IS",
	was = "WAS",
	were = "WAS",
	be = "BE",
	the = "2E",
	to = "2",
	too = "2",
	two = "2",
	four = "4",
	because = "BEC",
	cause = "BEC",
	please = "PLS",
	with = "WIT",
	without = "WITOUT",
	what = "WAT",
	why = "Y",
	where = "WERE",
	when = "WEN",
	who = "WHO",
	how = "HOWW",
	yes = "YUSSS",
	no = "NOOO",
	ok = "OKE",
	okay = "OKE",
	lol = "LOLOLOL",
	lmao = "LMAOOO",
	power = "POWA",
	powers = "POWAS",
	admin = "ADMIN POWA",
	game = "GAME BLOX",
	blox = "BLOX",
	fruit = "FRUIT",
	fruits = "FRUITS",
	inventory = "INVENTARY",
	interesting = "INTRASTIN",
	something = "SMTHN",
	nothing = "NUTHIN",
	friend = "BESTO FRIENDO",
	friends = "BESTO FRIENDOS",
	script = "SKRIPT",
	scripting = "SKRIPTIN",
	code = "KODE",
	coding = "KODIN",
	vidsmurf = "VIDA SMURF",
	dethsmurf = "DETHA SMURF",
	zer0 = "ZERU",
	cj = "CEE JEY",
	xonae = "ZOO NEY",
	wrathsong = "WRACK SONG",
	kinty = "KING TEA",
	heffner = "EP NAH",
	zioles = "ZEE O LES",
	quasi = "AQUA SEA",
	suizei = "SIU ZEY",
	arkesium = "AH KE SEE UM",
	azarth = "A ZAPH",
	E = "ADMEN E",
	mygame = "MI GAM",
	uzoth = "HANDSOME UZOTH",
	indra = "RIP_INDRA POPS",
	frank = "FRANK GOLD SAMA",
	queen = "QUEENA",
	doghouse = "DOGHOUSE"
}
local v2 = {
	" 🤪",
	" 😡",
	" 🐶🏠",
	" 💀",
	" 🔥",
	" 😤",
	" ;C"
}
local v3 = {
	"!",
	"!!",
	"...",
	" GRR",
	" HMM"
}
local v4 = { "!", "!!", "..." }

local function getSeed(value, p)
	local v5 = #value * 31 + p

	for i = 1, #value do
		v5 += string.byte(value, i) * i
	end

	return v5
end

local function corruptUnknownWord(value, object)
	local v5 = string.lower(value):gsub("tion$", "shun"):gsub("sion$", "shun"):gsub("ing$", "in"):gsub("ed$", "d"):gsub(
		"er$",
		"a"
	):gsub(
		"or$",
		"a"
	):gsub(
		"ly$",
		"li"
	):gsub(
		"th",
		"d"
	):gsub(
		"ph",
		"f"
	):gsub(
		"ck",
		"k"
	):gsub(
		"qu",
		"kw"
	):gsub(
		"oo",
		"u"
	):gsub(
		"ou",
		"u"
	):gsub(
		"ee",
		"i"
	):gsub(
		"ea",
		"e"
	):gsub(
		"ai",
		"e"
	):gsub(
		"ay",
		"e"
	):gsub(
		"gh",
		""
	):gsub(
		"x",
		"ks"
	):gsub(
		"c",
		"k"
	):gsub(
		"v",
		"b"
	)

	if #v5 >= 5 then
		local integer = object:NextInteger(1, 4)

		if integer == 1 then
			v5 = v5:gsub("a", "o", 1)
		elseif integer == 2 then
			v5 = v5:gsub("e", "i", 1)
		elseif integer == 3 then
			v5 = v5:gsub("o", "u", 1)
		end
	end

	if #v5 <= 2 then
		v5 ..= "Y"
	end

	if #v5 >= 4 and object:NextNumber() < 0.18 then
		local v6 = v5:sub(-1)
		v5 ..= string.rep(v6, object:NextInteger(1, 3))
	end

	return string.upper(v5)
end

local v5 = {
	"niga",
	"nige",
	"nigo",
	"nigu",
	"nigr",
	"niger",
	"nigah",
	"fagot",
	"fagit",
	"kike"
}

local function containsBlocked(value)
	local v6 = string.lower(value):gsub("[^%a]", ""):gsub("(%a)%1+", "%1")

	for _, v7 in v5 do
		if v6:find(v7, 1, true) then
			return true
		end
	end

	return false
end

local function dogHouseWord(value, p)
	if value:match("^#+$") then
		return value
	end

	local v6 = string.lower(value)

	if v[v6] then
		return v[v6]
	end

	local v7 = corruptUnknownWord(value, p)

	if containsBlocked(v7) then
		return "GRR"
	end

	return v7
end

local function Translate(text, userId)
	local v6 = #text * 31 + userId

	for i = 1, #text do
		v6 += string.byte(text, i) * i
	end

	local random = Random.new(v6)
	local count = 0

	for _ in string.gmatch(text, "%S+") do
		count += 1
	end

	local v7 = text:gsub("[%a']+", function(value)
		if value:match("^#+$") then
			return value
		end

		local v9 = string.lower(value)

		if v[v9] then
			return v[v9]
		end

		local v10 = corruptUnknownWord(value, random)

		if containsBlocked(v10) then
			return "GRR"
		end

		return v10
	end)

	if v7 == "" then
		return "HM! 🤔"
	end

	if containsBlocked(v7) then
		return "GRR! 🐶"
	end

	if count <= 1 then
		return v7 .. v4[random:NextInteger(1, #v4)]
	end

	if #v7 <= 6 then
		return v7 .. v3[random:NextInteger(1, #v3)]
	end

	return v7 .. v2[random:NextInteger(1, #v2)]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isDogHouseTalking(playerByUserId)
	local character = playerByUserId.Character
	return character and character:GetAttribute("DogHouseFormM1") == true
end

return function(_)
	if TextChatService:GetAttribute("DogHouseChatTranslatorInstalled") then
		return
	end

	TextChatService:SetAttribute("DogHouseChatTranslatorInstalled", true)

	TextChatService.OnIncomingMessage = function(data)
		local textSource = data.TextSource

		if not textSource then
			return nil
		end

		local playerByUserId = Players:GetPlayerByUserId(textSource.UserId)

		if not playerByUserId then
			return nil
		end

		local newMessageProperties = TextChatService.ChatWindowConfiguration:DeriveNewMessageProperties()
		local chatTagText = playerByUserId:GetAttribute("ChatTagText")
		local chatTagTextColor = playerByUserId:GetAttribute("ChatTagTextColor")
		local formatted = `<font color="#{playerByUserId.TeamColor.Color:ToHex()}">{playerByUserId.DisplayName}</font>:`
		newMessageProperties.PrefixText = `{not (chatTagText and chatTagTextColor) and "" or `<font color="#{chatTagTextColor:ToHex()}">[{chatTagText}]</font> `}{formatted}`

		if isDogHouseTalking(playerByUserId) and data.Status == Enum.TextChatMessageStatus.Success then
			newMessageProperties.Text = Translate(data.Text, playerByUserId.UserId)
		end

		return newMessageProperties
	end
end