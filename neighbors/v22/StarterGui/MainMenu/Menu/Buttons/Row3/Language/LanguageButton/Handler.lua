local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LanguageCode = require(ReplicatedStorage.Assets.Data.LanguageCode)
local Languages = require(ReplicatedStorage.Assets.Data.PlayerData.Languages)
Players.LocalPlayer:WaitForChild("PlayerGui")
local parent = script.Parent
local button = parent.Button
local label = parent.Label

local function getLanguageInfo(p: string)
	local language = LanguageCode:GetLanguage(p)

	if language then
		return language
	end

	if p == "multiple" then
		return {
			name = "Multiple",
			flag = "🌍",
			code = "multiple"
		}
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setLocale(p: string)
	local language = LanguageCode:GetLanguage(p) or p == "multiple" and {
		name = "Multiple",
		flag = "🌍",
		code = "multiple"
	} or nil

	if language then
		label.Text = `{language.name}`
		button.Text = language.flag
	else
		label.Text = "Unknown"
		button.Text = ""
	end
end

local function update()
	if Languages:HasLanguage("all") then
		return setLocale("all")
	end

	if Languages.MultiLingual then
		return setLocale("multiple")
	end

	setLocale(Languages.List[1] or "en") -- equivalent call inferred; original call site unknown
end

Languages.Updated:Connect(update)

if Languages:HasLanguage("all") then
	local language = LanguageCode:GetLanguage("all") or nil

	if language then
		label.Text = `{language.name}`
		button.Text = language.flag
	else
		label.Text = "Unknown"
		button.Text = ""
	end
elseif Languages.MultiLingual then
	local language = LanguageCode:GetLanguage("multiple") or {
		name = "Multiple",
		flag = "🌍",
		code = "multiple"
	}

	if language then
		label.Text = `{language.name}`
		button.Text = language.flag
	else
		label.Text = "Unknown"
		button.Text = ""
	end
else
	setLocale(Languages.List[1] or "en") -- equivalent call inferred; original call site unknown
end