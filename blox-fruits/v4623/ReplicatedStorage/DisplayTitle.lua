local TitleData = require(game.ServerStorage.TitleData)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local v = {
	Youtuber = "YouTuber"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function isStarCreatorTitle(value: string)
	return string.sub(value, 1, 5) == "STAR_"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getStarCreatorIdFromTitle(value: string)
	return (tonumber((string.sub(value, 6))))
end

local DisplayTitle = {}

function DisplayTitle.IsTitleValid(value: string)
	if string.sub(value, 1, 5) ~= "STAR_" then
		return true
	end

	local starCreatorIdFromTitle = getStarCreatorIdFromTitle(value) -- equivalent call inferred; original call site unknown

	if not starCreatorIdFromTitle then
		return false
	end

	local BloxFruitsStars = require(game.ServerScriptService.Services.BloxFruitsStars)
	local starTitleData = BloxFruitsStars.GetStarTitleData(starCreatorIdFromTitle)
	return starTitleData ~= nil and starTitleData.Hidden == false
end

function DisplayTitle.GetTitleText(value: string)
	local v2 = isStarCreatorTitle(value) and tonumber((string.sub(value, 6)))

	if v2 then
		local BloxFruitsStars = require(game.ServerScriptService.Services.BloxFruitsStars)
		local starTitleData = BloxFruitsStars.GetStarTitleData(v2)

		if starTitleData then
			return starTitleData.Text
		end
	end

	local v3 = v[value]

	if v3 then
		return v3
	end

	local nullable = ItemConfig.match(value, "Title"):asNullable()

	if nullable then
		return nullable.Display.Title or nullable.Display.Name or nullable.Index.StorageKey
	end

	return value
end

function DisplayTitle.GetTitleColor(value: string)
	if isStarCreatorTitle(value) then
		local starCreatorIdFromTitle = getStarCreatorIdFromTitle(value) -- equivalent call inferred; original call site unknown

		if not starCreatorIdFromTitle then
			return nil
		end

		local BloxFruitsStars = require(game.ServerScriptService.Services.BloxFruitsStars)
		local starTitleData = BloxFruitsStars.GetStarTitleData(starCreatorIdFromTitle)

		if starTitleData == nil or starTitleData.Color == nil then
			return nil
		end

		return Color3.fromHex(starTitleData.Color)
	else
		return TitleData.list[value] ~= nil and TitleData.list[value][4]
	end
end

return DisplayTitle