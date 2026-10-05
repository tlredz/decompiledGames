local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local UI = require(ReplicatedStorage.Modules.UI)
local Money = require(ReplicatedStorage.Modules.Money)
local Server = require(ReplicatedStorage.Modules.Server)
require(ReplicatedStorage.Modules.Component)
local ServerData = require(ReplicatedStorage.Modules.ServerData)
local Worlds = require(ReplicatedStorage.Assets.Data.Worlds)
local Global = require(ReplicatedStorage.Assets.Data.Global)
local Languages = require(ReplicatedStorage.Assets.Data.PlayerData.Languages)
local _ = Players.LocalPlayer
local parent = script.Parent
local worlds = parent.Worlds
local list = worlds.List
local info = parent.Info
local template = list.Template
template.Parent = script

local function isWorldEnabled(p: string)
	if workspace:GetAttribute((`{p}World`)) == nil then
		return true
	end

	return workspace:GetAttribute((`{p}World`)) and true or false
end

local function getPrimaryWorldInfo()
	return Worlds.Neighborhood
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showWorldInfo(activeWorldName: string)
	info:SetAttribute("ActiveWorldName", activeWorldName)
	info.Visible = true
end

local function updateAllCCUs()
	local total = 0
	local total2 = 0

	for _, server in next, ServerData.Servers, nil do
		if not (Server:GetWorldInfoFromPlaceId(server.PlaceId) and Languages:HasLanguage(server.Language)) then
			continue
		end

		if server.CustomServerData then
			total += server.Count
		else
			total2 += server.Count
		end
	end

	local neighborhood = list:FindFirstChild("Neighborhood")
	local custom = list:FindFirstChild("Custom")

	if neighborhood then
		neighborhood.PlayerCount.Text = `{Money(total2, true)} CCU`
	end

	if custom then
		custom.PlayerCount.Text = `{Money(total, true)} CCU`
	end
end

local function initializeHeader()
	parent.Navigation.Title.Text = Global.GameName

	if Server:IsAdultServer() then
		parent.Navigation.Title.Text = parent.Navigation.Title.Text .. " 18+"
		parent.Navigation.Buttons.Position += UDim2.new(0, 40, 0, 0)
	end
end

local function initializeWorlds()
	for k, world in next, Worlds, nil do
		local clone = template:Clone()
		clone.Name = k
		clone.Title.Text = world.Display
		clone.PlayerCount.Text = "? CCU"
		clone.LayoutOrder = world.Order

		if world.Thumbnail then
			clone.Background.Image = "rbxassetid://" .. world.Thumbnail
			clone.Background.Visible = true
		end

		UI:Bind(clone.Button)
		UI:AddShadowOnHover(clone)
		local v = k
		clone.Button.Activated:connect(function()
			if info.Visible then
				return
			else
				return showWorldInfo(v)
			end
		end)
		clone.Parent = list
	end
end

for _, v in CollectionService:GetTagged("CustomServerPrompt") do
	v.Triggered:Connect(function()
		parent.Visible = true
		showWorldInfo("Custom") -- equivalent call inferred; original call site unknown
	end)
end

CollectionService:GetInstanceAddedSignal("CustomServerPrompt"):Connect(function(p)
	p.Triggered:Connect(function()
		parent.Visible = true
		showWorldInfo("Custom") -- equivalent call inferred; original call site unknown
	end)
end)
parent.Close.Activated:Connect(function()
	parent.Visible = false
end)
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible then
		ServerData:Refresh()
	end
end)
UI:Bind(parent.Close)
parent.Visible = false
worlds.Visible = true
initializeHeader()
initializeWorlds()
updateAllCCUs()
ServerData.ServersUpdated:Connect(updateAllCCUs)

if parent.Visible then
	ServerData:Refresh()
end