local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Languages = require(ReplicatedStorage.Assets.Data.PlayerData.Languages)
local ServerData = require(ReplicatedStorage.Modules.ServerData)
local LanguageCode = require(ReplicatedStorage.Assets.Data.LanguageCode)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local _ = script.Parent.Parent.Parent
local button = script.Parent.Button
local content = script.Parent.Content

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

local function getServerCount()
	local count = 0

	for _, server in next, ServerData.Servers, nil do
		if server.Language and Languages:HasLanguage(server.Language) then
			count += 1
		end
	end

	return count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setLocale(p: string)
	local language = LanguageCode:GetLanguage(p) or p == "multiple" and {
		name = "Multiple",
		flag = "🌍",
		code = "multiple"
	} or nil
	local serverCount = getServerCount()

	if language then
		content.Title.Text = `{language.name} ({serverCount})`
		content.Country.Text = language.flag
	else
		content.Title.Text = "Unknown"
		content.Country.Text = ""
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

button.MouseButton1Click:Connect(function()
	playerGui.Prompts.LanguageSetting.Visible = true
end)
Languages.Updated:Connect(update)
ServerData.ServersUpdated:Connect(update)

if Languages:HasLanguage("all") then
	local language = LanguageCode:GetLanguage("all") or nil
	local serverCount = getServerCount()

	if language then
		content.Title.Text = `{language.name} ({serverCount})`
		content.Country.Text = language.flag
	else
		content.Title.Text = "Unknown"
		content.Country.Text = ""
	end
elseif Languages.MultiLingual then
	local language = LanguageCode:GetLanguage("multiple") or {
		name = "Multiple",
		flag = "🌍",
		code = "multiple"
	}
	local serverCount = getServerCount()

	if language then
		content.Title.Text = `{language.name} ({serverCount})`
		content.Country.Text = language.flag
	else
		content.Title.Text = "Unknown"
		content.Country.Text = ""
	end
else
	setLocale(Languages.List[1] or "en") -- equivalent call inferred; original call site unknown
end