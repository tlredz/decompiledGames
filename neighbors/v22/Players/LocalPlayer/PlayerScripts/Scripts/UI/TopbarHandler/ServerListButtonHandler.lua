local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Server = require(ReplicatedStorage.Modules.Server)
local LanguageCode = require(ReplicatedStorage.Assets.Data.LanguageCode)
local Icon = require(ReplicatedStorage.Modules:WaitForChild("Icon"))
local v = Icon.new()
v:setLabel("Servers")
v:setCaption("View all servers!")
v:setOrder(30)
v:oneClick()

local function updateServerIcon()
	local language = LanguageCode:GetLanguage(workspace:GetAttribute("ServerLanguage") or "en") or LanguageCode:GetLanguage("en")
	local v2 = Server:IsAdultServer() and "Servers 18+" or "Servers"
	v:setLabel((`{language.flag}  {v2}`))
end

workspace:GetAttributeChangedSignal("ServerLanguage"):Connect(updateServerIcon)
v:bindEvent("deselected", function()
	if playerGui:FindFirstChild("Worlds") then
		playerGui.Worlds.Frame.Visible = not playerGui.Worlds.Frame.Visible
	end
end)
updateServerIcon()