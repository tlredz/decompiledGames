local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)
local Rarity = require(ReplicatedStorage.Data.Rarity)
local Translations = require(script.Translations)
local en = Translations.en
local v = Promise.try(function()
	return LocalizationService:GetTranslatorForPlayerAsync(Players.LocalPlayer)
end):catch(function()
	return nil
end)
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Escape(value: string)
	local v3 = string.gsub(value, "&", "&amp;")
	local v4 = string.gsub(v3, "<", "&lt;")
	return (string.gsub(v4, ">", "&gt;"))
end

local function TranslateName(value: string, callback)
	local v3 = callback(value)

	if v3 ~= value then
		return v3
	end

	for _, rarity in Rarity.Rarities do
		local v4 = rarity.DisplayName .. " "

		if string.sub(value, 1, #v4) == v4 then
			return callback(rarity.DisplayName) .. " " .. callback((string.sub(value, #v4 + 1)))
		end
	end

	return value
end

local function TranslateSpan(value: string, callback)
	return (string.gsub(value, "(<font color=\"#%x+\">.-</font>)", function(value2: string)
		local v3, v4 = string.match(value2, "^(<font color=\"#%x+\">)(.-)</font>$")
		assert(v3 and v4)
		return v3 .. Escape(TranslateName(v4, callback)) .. "</font>"
	end))
end

function v2.Parse(value: string)
	local egg, area, emoji = string.match(value, "^A (.+) spawned in (<font color=\"#%x+\">.-</font>)(.-)!$")

	if egg == nil or area == nil or emoji == nil then
		return nil
	end

	return {
		Egg = egg,
		Area = area,
		Emoji = emoji
	}
end

function v2.Render(data, value: string, callback)
	local v3 = callback(en)

	if v3 == en or not (string.find(v3, "{Egg}", 1, true) and string.find(v3, "{Area}", 1, true) and string.find(
		v3,
		"{Emoji}",
		1,
		true
	)) then
		local v4 = string.lower(value)
		local v5 = string.match(v4, "^[^-]+")
		v3 = Translations[v4] or v5 and Translations[v5] or en
	end

	local egg = data.Egg
	local v4 = {
		Egg = string.gsub(egg, "(<font color=\"#%x+\">.-</font>)", function(value2: string)
			local v5, v6 = string.match(value2, "^(<font color=\"#%x+\">)(.-)</font>$")
			assert(v5 and v6)
			return v5 .. Escape(TranslateName(v6, callback)) .. "</font>"
		end),
		Area = 0,
		Emoji = 0
	}
	local area = data.Area
	v4.Area = string.gsub(area, "(<font color=\"#%x+\">.-</font>)", function(value2: string)
		local v5, v6 = string.match(value2, "^(<font color=\"#%x+\">)(.-)</font>$")
		assert(v5 and v6)
		return v5 .. Escape(TranslateName(v6, callback)) .. "</font>"
	end)
	v4.Emoji = Escape(data.Emoji)
	return (string.gsub(v3, "{(%w+)}", v4))
end

function v2.Localize(p, p2, callback)
	local v3 = true
	v:andThen(function(p3)
		if not v3 then
			return
		end

		local localeId

		if p3 then
			localeId = p3.LocaleId
		else
			localeId = LocalizationService.RobloxLocaleId
		end

		local function translate(p4: string)
			if p3 == nil then
				return p4
			end

			local success, result = pcall(p3.Translate, p3, p2, p4)

			if success then
				return result
			end

			return p4
		end

		callback(v2.Render(p, localeId, translate))
	end)
	return function()
		v3 = false
	end
end

return table.freeze(v2)