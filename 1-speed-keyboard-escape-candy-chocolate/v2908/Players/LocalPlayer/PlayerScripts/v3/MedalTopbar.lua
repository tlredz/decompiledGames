local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local MedalQuest = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("MedalQuest"))

if not MedalQuest.ENABLED then
	return
end

local Icon = require(ReplicatedStorage:WaitForChild("TopbarPlus"):WaitForChild("Icon"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function getModal()
	for _, v in ipairs(CollectionService:GetTagged("MedalQuestModal")) do
		if v:IsDescendantOf(playerGui) then
			return v
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isAuraOwned()
	local ownedAuras = ClientState:Get().OwnedAuras or {}
	return table.find(ownedAuras, "MedalAura") ~= nil
end

local v = Icon.new():setName("MedalQuest"):setLabel("Medal Quest"):setImage("rbxassetid://6023426952")
v:setEnabled(false)

local function openModal()
	local MedalUISystem = require(ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("MedalUISystem"))
	MedalUISystem:InitLogic()
	local modal = getModal()

	if not modal then
		return
	end

	local v2 = ClientState.ActiveModal ~= modal
	ClientState:ToggleModal(modal, MedalUISystem)

	if v2 and ClientState.ActiveModal == modal then
		MedalUISystem:Open()
	end
end

v.selected:Connect(function()
	openModal()
end)
v.deselected:Connect(function()
	local modal = getModal()

	if modal and ClientState.ActiveModal == modal then
		ClientState:CloseCurrentModal()
	end
end)
ClientState:RegisterModalListener(function(p)
	if not p then
		v:deselect()
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshIconVisibility()
	if isAuraOwned() then
		v:setEnabled(false)
	else
		v:setEnabled(true)
	end
end

remotes:WaitForChild("UpdateUI").OnClientEvent:Connect(function(p)
	if p and p.OwnedAuras then
		refreshIconVisibility() -- equivalent call inferred; original call site unknown
	end
end)
task.wait(2)
refreshIconVisibility() -- equivalent call inferred; original call site unknown