local AdIntegrationsController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local AdIntegrationsConfig = require(ReplicatedStorage.Modules.Shared.DB.AdIntegrations.AdIntegrationsConfig)
local AdIntegrationLabel = require(ReplicatedStorage.Modules.Client.UI.AdIntegrationLabel)
local IntroController = require(ReplicatedStorage.Modules.Client.UI.IntroController)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = {}
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = 0
local v7 = false
local maid = nil
local v8 = nil
local names = {}
local v9 = nil
local v10 = nil
local namesByTool = {}
local namesByEmote = {}
local v11 = nil
local v12 = nil
local names2 = {}

function AdIntegrationsController.FrameworkInit() end

local function DisplayLabel(p: string)
	v4 = p

	if not IntroController.HasPassedIntro() then
		return
	end

	v5 = v[p]
	local v13 = AdIntegrationsConfig.GetConfig()[v5]

	if not v13 then
		warn("AdIntegrationsController.DisplayAdLabel() - No config found for " .. v5)
		return false
	end

	v2 = PanelController.WaitForPanel("MainGUIAlwaysVisible", "AdIntegrationsLabel")

	if not v2 then
		warn("AdIntegrationsController.DisplayAdLabel() - No panel found")
		return false
	end

	PanelController.Open("MainGUIAlwaysVisible", "AdIntegrationsLabel")
	v3 = AdIntegrationLabel:WaitForInstance(v2.Instance):expect()

	if v3 then
		v3:Init(v5, v13)
	else
		warn("AdIntegrationsController.DisplayAdLabel() - No ad integration label found")
		return false
	end
end

function AdIntegrationsController.HideAdLabel(p: string)
	if v[p] == nil then
		return
	end

	v6 -= 1
	v[p] = nil

	if v6 == 0 then
		PanelController.Close("MainGUIAlwaysVisible", "AdIntegrationsLabel")
		v4 = nil
		v5 = nil
		v3 = nil
	else
		local v13 = nil
		local v14 = nil

		for k, v16 in v do
			v13 = k
			v14 = v16
			break
		end

		if v5 == v14 then
			v4 = v13
			return
		end

		if not v3 then
			DisplayLabel(v13)
			return
		end

		v4 = v13
		v5 = v[v13]
		local v16 = AdIntegrationsConfig.GetConfig()[v14]

		if v16 then
			v3:Init(v14, v16)
		else
			warn("AdIntegrationsController.HideAdLabel() - No config found for " .. v14)
		end
	end
end

function AdIntegrationsController.DisplayAdLabel(p: string)
	local GUID = HttpService:GenerateGUID(false)

	if not v[GUID] then
		v6 += 1
	end

	v[GUID] = p

	if not v4 then
		DisplayLabel(GUID)
	end

	return GUID
end

local function onSeatPartChanged(p)
	local seatPart = p.SeatPart

	if seatPart then
		local adIntegrationName = seatPart:GetAttribute("AdIntegrationName")

		if not adIntegrationName then
			return
		end

		v8 = AdIntegrationsController.DisplayAdLabel(adIntegrationName)
	else
		if v8 then
			AdIntegrationsController.HideAdLabel(v8)
		end

		v8 = nil
	end
end

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	maid:Cleanup()
	maid:Add(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
		local seatPart = humanoid.SeatPart

		if seatPart then
			local adIntegrationName = seatPart:GetAttribute("AdIntegrationName")

			if not adIntegrationName then
				return
			end

			v8 = AdIntegrationsController.DisplayAdLabel(adIntegrationName)
		else
			if v8 then
				AdIntegrationsController.HideAdLabel(v8)
			end

			v8 = nil
		end
	end))
end

function AdIntegrationsController.GetUGCIntegrationName(p: number)
	return names2[p]
end

function AdIntegrationsController.FrameworkStart()
	maid = Janitor.new()
	localPlayer.CharacterAdded:Connect(function(character)
		onCharacterAdded(character)
	end)

	if localPlayer.Character then
		onCharacterAdded(localPlayer.Character)
	end

	maid:Add(IntroController.OnPlayButtonPressed:Connect(function()
		if v4 then
			DisplayLabel(v4)
		end
	end))
	AdIntegrationsController.PropsSetup()
	AdIntegrationsController.ToolsSetup()
	AdIntegrationsController.EmotesSetup()
	AdIntegrationsController.UGCSetup()
end

function AdIntegrationsController.PropsSetup()
	local playersBag = localPlayer:WaitForChild("PlayersBag")

	if not playersBag then
		warn("AdIntegrationsController.FrameworkStart() - No players bag found")
		return
	end

	local propName = playersBag:WaitForChild("PropName")

	if not propName then
		warn("AdIntegrationsController.FrameworkStart() - No prop name found")
		return
	end

	local config = AdIntegrationsConfig.GetConfig()

	for _, v13 in config do
		if not v13.Props then
			continue
		end

		for _, v14 in v13.Props do
			names[v14] = v13.Name
		end
	end

	propName:GetPropertyChangedSignal("Value"):Connect(function()
		local v13 = names[propName.Value]

		if v9 == v13 then
			return
		end

		v9 = nil

		if v13 then
			v9 = v13
		end

		AdIntegrationsController.CheckIfNeedProLabel()
	end)
end

function AdIntegrationsController.ToolsSetup()
	local config = AdIntegrationsConfig.GetConfig()

	for _, v13 in config do
		if not v13.Tools then
			continue
		end

		for _, tool in v13.Tools do
			namesByTool[tool] = v13.Name
		end
	end
end

function AdIntegrationsController.EmotesSetup()
	local config = AdIntegrationsConfig.GetConfig()

	for _, v13 in config do
		if not v13.Emotes then
			continue
		end

		for _, emote in v13.Emotes do
			namesByEmote[emote] = v13.Name
		end
	end
end

function AdIntegrationsController.UGCSetup()
	local config = AdIntegrationsConfig.GetConfig()

	for _, v13 in config do
		if not v13.UGCList then
			continue
		end

		for _, v14 in v13.UGCList do
			names2[v14] = v13.Name
		end
	end
end

function AdIntegrationsController.GetToolAdIntegrationName(p: string)
	return namesByTool[p]
end

function AdIntegrationsController.NotifyEmoteChanged(p: string?)
	local v13

	if p ~= nil then
		v13 = namesByEmote[p]
	end

	if v13 == v12 then
		return
	end

	if v11 then
		AdIntegrationsController.HideAdLabel(v11)
		v11 = nil
		v12 = nil
	end

	if v13 ~= nil then
		v12 = v13
		v11 = AdIntegrationsController.DisplayAdLabel(v13)
	end
end

function AdIntegrationsController.CheckIfNeedProLabel()
	local v13

	if v9 == nil then
		v13 = false
	else
		v13 = v7
	end

	if v10 then
		AdIntegrationsController.HideAdLabel(v10)
	end

	if v13 then
		v10 = AdIntegrationsController.DisplayAdLabel(v9)
	else
		v10 = nil
	end
end

function AdIntegrationsController.NotifyPropMakerEquipped()
	v7 = true
	AdIntegrationsController.CheckIfNeedProLabel()
end

function AdIntegrationsController.NotifyPropMakerUnequipped()
	v7 = false
	AdIntegrationsController.CheckIfNeedProLabel()
end

return AdIntegrationsController